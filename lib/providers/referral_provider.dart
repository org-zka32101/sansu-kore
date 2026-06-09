import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/referral_model.dart';

// Firestore インスタンス
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Firebase Auth インスタンス
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// 現在のユーザーID
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.currentUser?.id;
});

// 紹介コード生成Provider
final generateReferralCodeProvider = FutureProvider.family<String, String>(
  (ref, creatorId) async {
    // SANSU + 日付 + ランダム5文字
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    // ランダム5文字生成（A-Z 0-9）
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = _generateRandomString(5, chars);

    return 'SANSU$dateStr$random';
  },
);

// 紹介コード作成・保存Provider
final createReferralCodeProvider =
    FutureProvider.family<ReferralCode, CreateReferralRequest>((ref, request) async {
  final firestore = ref.watch(firestoreProvider);
  final code = request.code;
  final creatorId = request.creatorId;
  final creatorName = request.creatorName;

  final referralCode = ReferralCode(
    code: code,
    creatorId: creatorId,
    creatorName: creatorName,
    createdAt: DateTime.now(),
  );

  // Firestore に保存
  await firestore
      .collection('referral_codes')
      .doc(code)
      .set(referralCode.toFirestore());

  return referralCode;
});

// 紹介コード検証・適用Provider
final applyReferralCodeProvider =
    FutureProvider.family<ReferralResult, String>((ref, code) async {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  final currentUserId = auth.currentUser?.uid;

  if (currentUserId == null) {
    return ReferralResult.error('ログインしてください');
  }

  try {
    // コードを取得
    final docSnapshot = await firestore.collection('referral_codes').doc(code).get();

    if (!docSnapshot.exists) {
      return ReferralResult.error('招待コードが見つかりません');
    }

    final referralCode = ReferralCode.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);

    // 使用可能か確認
    if (!referralCode.isAvailable) {
      if (referralCode.usedCount >= referralCode.maxUses) {
        return ReferralResult.error('このコードは使用上限に達しました');
      }
      return ReferralResult.error('このコードは有効期限切れです');
    }

    // 既に使用済みか確認（重複防止）
    final usedSnapshot = await firestore
        .collection('referral_uses')
        .where('userId', isEqualTo: currentUserId)
        .where('code', isEqualTo: code)
        .get();

    if (usedSnapshot.docs.isNotEmpty) {
      return ReferralResult.error('このコードは既に使用済みです');
    }

    // コインを付与
    const referrerCoins = 100; // 紹介した側
    const referredCoins = 50;  // 紹介された側

    // トランザクション開始
    final result = await firestore.runTransaction((transaction) async {
      // 1. 紹介コードのusedCountを増加
      final updatedReferral = referralCode.copyWith(
        usedCount: referralCode.usedCount + 1,
        creatorCoinsEarned: referralCode.creatorCoinsEarned + referrerCoins,
      );

      transaction.update(
        firestore.collection('referral_codes').doc(code),
        {
          'usedCount': updatedReferral.usedCount,
          'creatorCoinsEarned': updatedReferral.creatorCoinsEarned,
        },
      );

      // 2. 紹介した側（creatorId）のコイン加算
      final creatorRef =
          firestore.collection('users').doc(referralCode.creatorId);
      transaction.update(creatorRef, {
        'coins': FieldValue.increment(referrerCoins),
      });

      // 3. 紹介された側（currentUser）のコイン加算
      final currentUserRef = firestore.collection('users').doc(currentUserId);
      transaction.update(currentUserRef, {
        'coins': FieldValue.increment(referredCoins),
      });

      // 4. 紹介使用履歴を記録
      final usedRef = firestore.collection('referral_uses').doc();
      transaction.set(usedRef, {
        'code': code,
        'userId': currentUserId,
        'referrerId': referralCode.creatorId,
        'referrerCoinsAwarded': referrerCoins,
        'referredCoinsAwarded': referredCoins,
        'usedAt': Timestamp.now(),
      });

      return updatedReferral;
    });

    // Riverpod の coin provider を更新
    ref.invalidate(coinProvider);

    return ReferralResult.success(
      coinsAwarded: referredCoins,
      referrerName: referralCode.creatorName ?? '友達',
    );
  } catch (e) {
    return ReferralResult.error('エラーが発生しました: $e');
  }
});

// ユーザーの紹介コード取得Provider
final userReferralCodeProvider = StreamProvider.family<ReferralCode?, String>(
  (ref, userId) {
    final firestore = ref.watch(firestoreProvider);
    return firestore
        .collection('referral_codes')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return ReferralCode.fromFirestore(
        snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
      );
    });
  },
);

// ダミーProvider（実装の参考用）
final coinProvider = StateNotifierProvider<CoinNotifier, int>(
  (ref) => CoinNotifier(),
);

class CoinNotifier extends StateNotifier<int> {
  CoinNotifier() : super(0);

  void addCoins(int amount) {
    state += amount;
  }
}

// ヘルパー関数
String _generateRandomString(int length, String characters) {
  final random = DateTime.now().millisecondsSinceEpoch;
  String result = '';
  for (int i = 0; i < length; i++) {
    result += characters[(random + i) % characters.length];
  }
  return result;
}

// リクエストクラス
class CreateReferralRequest {
  final String code;
  final String creatorId;
  final String? creatorName;

  CreateReferralRequest({
    required this.code,
    required this.creatorId,
    this.creatorName,
  });
}
