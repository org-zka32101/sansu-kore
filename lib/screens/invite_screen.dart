import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/profile_provider.dart';
import '../providers/coin_provider.dart';
import '../theme/app_theme.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _shared = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final childName = profile.currentProfile?.name ?? 'お友達';

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('ともコレ！友達招待'),
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ヘッダーカード
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27AE60), Color(0xFF1E8449)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  const Text('👫', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    '$childName のお友達を招待しよう！',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '算数コレ！を紹介してお友達と一緒に勉強しよう',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 招待ボーナス説明
            _BonusCard(
              icon: '🪙',
              title: 'シェアボーナス',
              description: '友達に紹介するだけで 30コイン ゲット！',
            ),
            const SizedBox(height: 12),
            _BonusCard(
              icon: '⭐',
              title: '一緒に算数コレ！',
              description: '小学1〜6年の算数が遊びながら学べる！',
            ),
            const SizedBox(height: 24),

            // シェアメッセージプレビュー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('シェアするメッセージ',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    _buildShareMessage(childName),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // シェアボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shared ? null : () => _share(context, childName),
                icon: const Icon(Icons.share),
                label: Text(
                  _shared ? 'シェアしたよ！ありがとう 🎉' : '友達に紹介する',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _shared
                      ? Colors.grey
                      : const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '※ シェアボーナスは1回のみ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _buildShareMessage(String name) {
    return '[$name からのおすすめ！]\n\n「算数コレ！」で小学算数を楽しく学んでいます📚\n\n✨ 小1〜小6の全単元対応\n🎮 ゲーム感覚で問題を解こう\n🏆 バッジやコインでやる気アップ\n\n一緒に算数を得意にしよう！\n#算数コレ #小学算数';
  }

  Future<void> _share(BuildContext context, String childName) async {
    try {
      await Share.share(
        _buildShareMessage(childName),
        subject: '算数コレ！をお友達に紹介',
      );
      // ボーナスコイン付与
      await ref.read(coinProvider.notifier).addCoins(30);
      setState(() => _shared = true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('シェアありがとう！30コイン獲得！🪙'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (_) {
      // シェアキャンセル or エラー
    }
  }
}

class _BonusCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _BonusCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text(description,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
