import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/growth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(growthProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final growth = ref.watch(growthProvider);
    final profile = ref.watch(profileProvider);
    final childName = profile.currentProfile?.name ?? 'きみ';

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('成長タイムカプセル'),
        backgroundColor: kPrimaryDeep,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            _SectionHeader(
              icon: '📬',
              title: '$childName の成長記録',
              subtitle: '過去と今を比べてみよう！',
            ),
            const SizedBox(height: 16),

            if (!growth.hasData) ...[
              _EmptyState(childName: childName),
            ] else ...[
              // 成長比較カード
              _GrowthCompareCard(
                growth: growth,
                childName: childName,
              ),
              const SizedBox(height: 16),
              // 履歴グラフ（簡易）
              if (growth.history.length > 1) ...[
                _GrowthHistoryCard(history: growth.history),
                const SizedBox(height: 16),
              ],
            ],

            // タイムカプセルメッセージ
            _TimeCapsuleSection(
              controller: _messageController,
              lastMessage: growth.currentRecord?.message,
              onSave: (message) async {
                final notifier = ref.read(growthProvider.notifier);
                final current = growth.currentRecord;
                await notifier.saveSnapshot(
                  stagesCleared: current?.stagesCleared ?? 0,
                  totalQuestions: current?.totalQuestions ?? 0,
                  correctCount: current?.correctCount ?? 0,
                  totalCoins: current?.totalCoins ?? 0,
                  message: message,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('メッセージを保存したよ！')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class _GrowthCompareCard extends StatelessWidget {
  final GrowthState growth;
  final String childName;

  const _GrowthCompareCard({required this.growth, required this.childName});

  @override
  Widget build(BuildContext context) {
    final first = growth.firstRecord!;
    final current = growth.currentRecord!;
    final stageDiff = current.stagesCleared - first.stagesCleared;
    final accDiff =
        ((current.accuracy - first.accuracy) * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('成長の記録',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GrowthStat(
                label: 'ステージ',
                before: '${first.stagesCleared}',
                after: '${current.stagesCleared}',
                diff: '+$stageDiff',
                icon: '🎯',
              ),
              _GrowthStat(
                label: '正解率',
                before: '${(first.accuracy * 100).toStringAsFixed(0)}%',
                after: '${(current.accuracy * 100).toStringAsFixed(0)}%',
                diff: '+$accDiff%',
                icon: '⭐',
              ),
              _GrowthStat(
                label: 'コイン',
                before: '${first.totalCoins}',
                after: '${current.totalCoins}',
                diff: '+${current.totalCoins - first.totalCoins}',
                icon: '🪙',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '最初の記録: ${_formatDate(first.recordedAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

class _GrowthStat extends StatelessWidget {
  final String label;
  final String before;
  final String after;
  final String diff;
  final String icon;

  const _GrowthStat({
    required this.label,
    required this.before,
    required this.after,
    required this.diff,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(before,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                decoration: TextDecoration.lineThrough)),
        Text(after,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(diff,
              style: const TextStyle(fontSize: 11, color: Colors.white)),
        ),
      ],
    );
  }
}

class _GrowthHistoryCard extends StatelessWidget {
  final List<GrowthRecord> history;

  const _GrowthHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final recent = history.length > 5
        ? history.sublist(history.length - 5)
        : history;
    final maxStages = recent.map((r) => r.stagesCleared).fold(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ステージ数の記録',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recent.map((r) {
                final ratio = r.stagesCleared / maxStages;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${r.stagesCleared}',
                            style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 60 * ratio,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: recent
                .map((r) => Text(
                      '${r.recordedAt.month}/${r.recordedAt.day}',
                      style: const TextStyle(
                          fontSize: 9, color: Colors.grey),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String childName;

  const _EmptyState({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('📬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            '$childName の最初の記録を待っています！',
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ステージをクリアすると自動的に記録されるよ。\n未来の自分に向けてメッセージも残してみよう！',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TimeCapsuleSection extends StatelessWidget {
  final TextEditingController controller;
  final String? lastMessage;
  final void Function(String message) onSave;

  const _TimeCapsuleSection({
    required this.controller,
    required this.lastMessage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (lastMessage != null && controller.text.isEmpty) {
      controller.text = lastMessage!;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✉️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('未来の自分へのメッセージ',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '算数が得意になった未来の自分に伝えたいことを書こう！',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '例: がんばって算数を練習してたらかけ算が好きになったよ！',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final msg = controller.text.trim();
                if (msg.isNotEmpty) onSave(msg);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('メッセージを保存'),
            ),
          ),
        ],
      ),
    );
  }
}
