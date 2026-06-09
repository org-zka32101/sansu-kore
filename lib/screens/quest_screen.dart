import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest_model.dart';
import '../providers/adaptive_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/furigana_text.dart';

class QuestScreen extends ConsumerStatefulWidget {
  final Stage stage;
  const QuestScreen({super.key, required this.stage});

  @override
  ConsumerState<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends ConsumerState<QuestScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  bool _showHint = false;
  late DateTime _startTime;
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  QuizQuestion get _current => widget.stage.questions[_currentIndex];
  bool get _isCorrect => _selectedAnswer == _current.correctIndex;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _feedbackCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _feedbackAnim = CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _onChoiceTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_isCorrect) _correctCount++;
    });
    _feedbackCtrl.forward(from: 0);
  }

  void _onNext() {
    if (_currentIndex < widget.stage.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
        _showHint = false;
      });
      _feedbackCtrl.reset();
    } else {
      final elapsed = DateTime.now().difference(_startTime);
      final result = QuestResult(
        correctCount: _correctCount,
        totalCount: widget.stage.questions.length,
        elapsed: elapsed,
      );
      Navigator.of(context).pushReplacementNamed(
        '/result',
        arguments: {'result': result, 'stage': widget.stage},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.stage.questions.length;
    final progress = (_currentIndex + (_answered ? 1 : 0)) / total;
    final adaptive = ref.watch(adaptiveProvider);
    final shouldShowHint = adaptive.shouldShowHint(widget.stage.topicType);

    return Scaffold(
      appBar: AppBar(
        title: Text('ステージ ${widget.stage.stageNumber}'),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('やめますか？'),
              content: const Text('今の進捗は保存されません。'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('続ける')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('やめる', style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 進捗バー
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 6,
          ),
          // 問題番号
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '問題 ${_currentIndex + 1} / $total',
                  style: const TextStyle(color: kTextMuted, fontSize: 14),
                ),
                // アダプティブ：苦手トピックならヒントボタン表示
                if (!_answered && _current.hint != null && shouldShowHint)
                  TextButton.icon(
                    onPressed: () => setState(() => _showHint = !_showHint),
                    icon: const Icon(Icons.lightbulb_outline, size: 16),
                    label: const Text('ヒント', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: kAccentOrange),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヒント（アダプティブラーニング）
                  if (_showHint && _current.hint != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCC02)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡 ', style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: FuriganaText(
                              _current.hint!,
                              fontSize: 14,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 問題カード
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      _current.question,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 選択肢
                  ...List.generate(_current.choices.length, (i) {
                    final isSelected = _selectedAnswer == i;
                    final isCorrect = i == _current.correctIndex;

                    Color bg = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = kTextDark;

                    if (_answered) {
                      if (isSelected && isCorrect) {
                        bg = const Color(0xFF2ECC71);
                        borderColor = const Color(0xFF27AE60);
                        textColor = Colors.white;
                      } else if (isSelected && !isCorrect) {
                        bg = kPrimaryColor;
                        borderColor = kPrimaryDark;
                        textColor = Colors.white;
                      } else if (!isSelected && isCorrect) {
                        bg = const Color(0xFFD5F5E3);
                        borderColor = const Color(0xFF27AE60);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScaleTransition(
                        scale: isSelected && _answered ? _feedbackAnim : const AlwaysStoppedAnimation(1.0),
                        child: GestureDetector(
                          onTap: () => _onChoiceTap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _current.choices[i],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // 解説（フォーメティブ評価 - 設計書の教育工学機能）
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: _answered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? const Color(0xFFD5F5E3)
                              : const Color(0xFFFAD7D7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCorrect ? '✅ 正解！' : '❌ 不正解...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? kAccentGreen : kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FuriganaText(
                              _current.explanation,
                              fontSize: 14,
                              color: kTextDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: Text(
                        _currentIndex < widget.stage.questions.length - 1 ? 'つぎの問題 →' : '結果を見る！',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
