import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/daily_login_provider.dart';
import '../providers/adaptive_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).currentProfile;
    final premium = ref.watch(premiumProvider);
    final daily = ref.watch(dailyLoginProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('せってい'),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィール
            if (profile != null) ...[
              _SectionHeader('プロフィール'),
              _SettingCard(
                emoji: '👤',
                title: profile.name,
                subtitle: '小学${profile.grade}年生',
                onTap: () => Navigator.of(context).pushNamed('/profile-selection'),
              ),
            ],

            const SizedBox(height: 16),

            // デイリーログイン情報
            _SectionHeader('デイリーログイン'),
            _InfoCard(
              children: [
                _InfoRow('連続ログイン', '${daily.loginStreak}日'),
                _InfoRow('累計ログイン', '${daily.totalLoginDays}日'),
                _InfoRow('今日の受け取り', daily.todayClaimed ? '✅ 受け取り済み' : '🎁 未受け取り'),
              ],
            ),

            const SizedBox(height: 16),

            // サブスクリプション
            _SectionHeader('プラン'),
            _SettingCard(
              emoji: premium.isPremium ? '⭐' : '🔓',
              title: premium.isPremium
                  ? 'プレミアム会員'
                  : premium.isTrialActive
                      ? 'トライアル中（あと${premium.trialDaysLeft}日）'
                      : '無料プラン',
              subtitle: premium.isPremium ? '全ステージ利用可能' : 'アップグレードで全機能解放',
              onTap: () => Navigator.of(context).pushNamed('/upgrade'),
            ),

            const SizedBox(height: 16),

            // 親のほめメッセージ
            _SectionHeader('保護者へのメッセージ'),
            FutureBuilder<List<PraiseMessage>>(
              future: NotificationService.getPraiseQueue(),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('まだメッセージはありません', style: TextStyle(color: kTextMuted, fontSize: 14)),
                  );
                }
                return Column(
                  children: messages.reversed.take(5).map((msg) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isRead ? Colors.white : const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('👨‍👩‍👧', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.achievement, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(
                                '${msg.timestamp.month}/${msg.timestamp.day} ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: kTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 16),

            // その他
            _SectionHeader('その他'),
            _SettingCard(
              emoji: '📬',
              title: '成長タイムカプセル',
              subtitle: '最初の記録と今を比べよう',
              onTap: () => Navigator.of(context).pushNamed('/growth'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '👫',
              title: 'ともコレ！友達招待',
              subtitle: 'お友達を招待して30コインゲット',
              onTap: () => Navigator.of(context).pushNamed('/invite'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '📄',
              title: 'プライバシーポリシー',
              subtitle: null,
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
            ),
            const SizedBox(height: 8),
            _SettingCard(
              emoji: '🗑️',
              title: '学習データをリセット',
              subtitle: '進捗・コインが全て削除されます',
              onTap: () => _showResetDialog(context, ref),
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text(
                '算数コレ！ v1.0.0',
                style: TextStyle(color: kTextMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('リセットしますか？'),
        content: const Text('学習履歴・コイン・バッジが全て削除されます。この操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              await ref.read(progressProvider.notifier).reset();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.bold)),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingCard({required this.emoji, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: kTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: kTextMuted)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
