import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/quest_model.dart';
import '../providers/premium_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

class StageSelectScreen extends ConsumerStatefulWidget {
  const StageSelectScreen({super.key});

  @override
  ConsumerState<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends ConsumerState<StageSelectScreen> {
  int _gradeFilter = 0; // 0=全て
  MathTopicType? _topicFilter;

  List<Stage> get _filteredStages {
    final all = <Stage>[];
    for (var g = 1; g <= 6; g++) {
      all.addAll(getStagesForGrade(g));
    }
    return all.where((s) {
      if (_gradeFilter != 0 && s.grade != _gradeFilter) return false;
      if (_topicFilter != null && s.topicType != _topicFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final premium = ref.watch(premiumProvider);
    final filtered = _filteredStages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ステージ選択'),
        backgroundColor: kPrimaryColor,
        actions: [
          if (!premium.isPremium)
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/upgrade'),
              icon: const Icon(Icons.star, color: Colors.white, size: 16),
              label: premium.isTrialActive
                  ? Text('トライアル${premium.trialDaysLeft}日',
                      style: const TextStyle(color: Colors.white, fontSize: 12))
                  : const Text('PRO', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // 学年フィルター
          _GradeFilterBar(
            selected: _gradeFilter,
            onSelected: (g) => setState(() => _gradeFilter = g),
          ),
          // ステージリスト
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('ステージがありません'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final stage = filtered[i];
                      final isCleared = progress.isCleared(stage.grade, stage.stageNumber);
                      final sameGroup = filtered
                          .where((s) => s.grade == stage.grade)
                          .toList();
                      final idx = sameGroup.indexOf(stage);
                      final isLocked = idx > 0 &&
                          !progress.isCleared(sameGroup[idx - 1].grade, sameGroup[idx - 1].stageNumber);
                      final isPremiumLocked =
                          !premium.isPremium && !premium.isTrialActive &&
                          stage.stageNumber > kFreeStageLimit;

                      return _StageCard(
                        stage: stage,
                        isCleared: isCleared,
                        isLocked: isLocked,
                        isPremiumLocked: isPremiumLocked,
                        onTap: () {
                          if (isPremiumLocked) {
                            Navigator.of(context).pushNamed('/upgrade');
                          } else if (!isLocked) {
                            Navigator.of(context).pushNamed('/quest', arguments: stage);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GradeFilterBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _GradeFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _FilterChip(label: '全て', selected: selected == 0, onTap: () => onSelected(0)),
          ...List.generate(6, (i) => _FilterChip(
            label: '小${i + 1}',
            selected: selected == i + 1,
            onTap: () => onSelected(i + 1),
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? kPrimaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : kTextMuted,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final Stage stage;
  final bool isCleared;
  final bool isLocked;
  final bool isPremiumLocked;
  final VoidCallback onTap;

  const _StageCard({
    required this.stage,
    required this.isCleared,
    required this.isLocked,
    required this.isPremiumLocked,
    required this.onTap,
  });

  String _topicEmoji(MathTopicType t) {
    switch (t) {
      case MathTopicType.addition: return '➕';
      case MathTopicType.subtraction: return '➖';
      case MathTopicType.multiplication: return '✖️';
      case MathTopicType.division: return '➗';
      case MathTopicType.fraction: return '½';
      case MathTopicType.decimal: return '0.5';
      case MathTopicType.geometry: return '📐';
      case MathTopicType.word: return '📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = isLocked || isPremiumLocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: locked ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCleared ? kAccentGreen : Colors.grey.shade200,
                width: isCleared ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isCleared ? kAccentGreen.withAlpha(20) : kPrimaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      locked ? '🔒' : _topicEmoji(stage.topicType),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '小${stage.grade}',
                              style: const TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ステージ ${stage.stageNumber}',
                            style: const TextStyle(fontSize: 12, color: kTextMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
                      ),
                      Text(
                        '${stage.totalQuestions}問',
                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                      ),
                    ],
                  ),
                ),
                if (isCleared)
                  const Icon(Icons.check_circle, color: kAccentGreen, size: 28)
                else if (isPremiumLocked)
                  const Icon(Icons.star, color: kAccentOrange, size: 28)
                else if (!isLocked)
                  const Icon(Icons.arrow_forward_ios, color: kTextMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
