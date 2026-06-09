import 'package:cloud_firestore/cloud_firestore.dart';

/// 紹介コード管理モデル
class ReferralCode {
  final String code; // 例: SANSU20260608ABCDE
  final String creatorId; // 紹介者のUID
  final String? creatorName; // 紹介者の名前（表示用）
  final int creatorCoinsEarned; // 紹介者が獲得したコイン
  final int usedCount; // 使用済みカウント
  final int maxUses; // 最大使用回数（デフォルト5）
  final DateTime createdAt; // 生成日時
  final DateTime? expiresAt; // 有効期限（30日）

  // 使用可能かどうかを判定
  bool get isAvailable =>
      usedCount < maxUses &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  ReferralCode({
    required this.code,
    required this.creatorId,
    this.creatorName,
    this.creatorCoinsEarned = 0,
    this.usedCount = 0,
    this.maxUses = 5,
    required this.createdAt,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? DateTime.now().add(const Duration(days: 30));

  // Firestore に保存する形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorCoinsEarned': creatorCoinsEarned,
      'usedCount': usedCount,
      'maxUses': maxUses,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  // Firestore から復元
  factory ReferralCode.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ReferralCode(
      code: data['code'] as String,
      creatorId: data['creatorId'] as String,
      creatorName: data['creatorName'] as String?,
      creatorCoinsEarned: data['creatorCoinsEarned'] as int? ?? 0,
      usedCount: data['usedCount'] as int? ?? 0,
      maxUses: data['maxUses'] as int? ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  // コピーコンストラクタ（更新用）
  ReferralCode copyWith({
    String? code,
    String? creatorId,
    String? creatorName,
    int? creatorCoinsEarned,
    int? usedCount,
    int? maxUses,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return ReferralCode(
      code: code ?? this.code,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorCoinsEarned: creatorCoinsEarned ?? this.creatorCoinsEarned,
      usedCount: usedCount ?? this.usedCount,
      maxUses: maxUses ?? this.maxUses,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() => 'ReferralCode($code, creator: $creatorId, '
      'used: $usedCount/$maxUses, coins: $creatorCoinsEarned)';
}

/// 紹介結果のモデル
class ReferralResult {
  final bool success;
  final String message;
  final int? coinsAwarded; // 付与されたコイン
  final String? referrerName; // 紹介者の名前

  ReferralResult({
    required this.success,
    required this.message,
    this.coinsAwarded,
    this.referrerName,
  });

  factory ReferralResult.success({
    required int coinsAwarded,
    required String referrerName,
  }) {
    return ReferralResult(
      success: true,
      message: '$referrerName さんの紹介で $coinsAwarded コイン ゲット！',
      coinsAwarded: coinsAwarded,
      referrerName: referrerName,
    );
  }

  factory ReferralResult.error(String message) {
    return ReferralResult(
      success: false,
      message: message,
    );
  }
}
