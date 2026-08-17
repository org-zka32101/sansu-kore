import 'package:cloud_firestore/cloud_firestore.dart';

/// 紹介コードのFirestoreドキュメントモデル（コレクション: `referral_codes`）
class ReferralCode {
  final String code;
  final String creatorId;
  final int creatorCoins; // これまでに紹介成立で貯まったコイン合計（クリエイター向け）
  final int usedCount;
  final int maxUses;
  final DateTime createdAt;

  const ReferralCode({
    required this.code,
    required this.creatorId,
    required this.creatorCoins,
    required this.usedCount,
    required this.maxUses,
    required this.createdAt,
  });

  static const validDays = 30;
  static const maxUsesDefault = 5;
  static const creatorRewardCoins = 100;
  static const inviteeRewardCoins = 50;

  bool get isExpired =>
      DateTime.now().difference(createdAt).inDays >= validDays;
  bool get isExhausted => usedCount >= maxUses;
  bool get isRedeemable => !isExpired && !isExhausted;

  factory ReferralCode.fromMap(String code, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : (createdAtRaw is DateTime ? createdAtRaw : DateTime.now());

    return ReferralCode(
      code: code,
      creatorId: data['creatorId'] as String? ?? '',
      creatorCoins: (data['creatorCoins'] as num?)?.toInt() ?? 0,
      usedCount: (data['usedCount'] as num?)?.toInt() ?? 0,
      maxUses: (data['maxUses'] as num?)?.toInt() ?? maxUsesDefault,
      createdAt: createdAt,
    );
  }
}
