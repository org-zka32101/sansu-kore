import 'package:flutter/material.dart';
import '../models/quest_model.dart';

/// 計算過程を表示するウィジェット（筆算ヒント）
class CalculationStepsWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showSteps;

  const CalculationStepsWidget({
    Key? key,
    required this.question,
    this.showSteps = false,
  }) : super(key: key);

  @override
  State<CalculationStepsWidget> createState() => _CalculationStepsWidgetState();
}

class _CalculationStepsWidgetState extends State<CalculationStepsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _displayedSteps = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.showSteps) {
      _animateSteps();
    }
  }

  void _animateSteps() {
    final steps = _parseSteps(widget.question);
    for (int i = 0; i < steps.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * (i + 1)), () {
        if (mounted) setState(() => _displayedSteps = i + 1);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalculationStepsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSteps && oldWidget.showSteps != widget.showSteps) {
      _displayedSteps = 0;
      _animateSteps();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showSteps) return const SizedBox.shrink();

    final steps = _parseSteps(widget.question);
    if (steps.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 計算過程',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              _displayedSteps,
              (i) => _StepTile(step: steps[i], stepNumber: i + 1),
            ),
          ],
        ),
      ),
    );
  }

  List<CalculationStep> _parseSteps(QuizQuestion question) {
    // 問題テキストから計算過程を抽出
    // 例: "5 + 3 = ?" → [Step 1: "5 + 3の一の位", "5 + 3 = 8", ...]
    final steps = <CalculationStep>[];

    // サンプル実装: 簡単な計算の場合
    if (question.questionText.contains('+')) {
      steps.add(CalculationStep(
        description: '一の位を足します',
        operation: question.questionText,
      ));
    } else if (question.questionText.contains('-')) {
      steps.add(CalculationStep(
        description: '一の位を引きます',
        operation: question.questionText,
      ));
    } else if (question.questionText.contains('×')) {
      steps.add(CalculationStep(
        description: 'かけ算をします',
        operation: question.questionText,
      ));
    } else if (question.questionText.contains('÷')) {
      steps.add(CalculationStep(
        description: '割り算をします',
        operation: question.questionText,
      ));
    }

    return steps;
  }
}

class CalculationStep {
  final String description;
  final String operation;

  CalculationStep({
    required this.description,
    required this.operation,
  });
}

class _StepTile extends StatelessWidget {
  final CalculationStep step;
  final int stepNumber;

  const _StepTile({
    required this.step,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.operation,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
