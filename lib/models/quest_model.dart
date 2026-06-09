enum MathTopicType { addition, subtraction, multiplication, division, fraction, decimal, geometry, word }

class QuizQuestion {
  final String id;
  final MathTopicType type;
  final int grade;
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;
  final String? hint;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.grade,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    this.hint,
  });
}

class Stage {
  final int stageNumber;
  final String title;
  final int grade;
  final MathTopicType topicType;
  final List<QuizQuestion> questions;

  const Stage({
    required this.stageNumber,
    required this.title,
    required this.grade,
    required this.topicType,
    required this.questions,
  });

  int get totalQuestions => questions.length;
}

class QuestResult {
  final int correctCount;
  final int totalCount;
  final Duration elapsed;

  const QuestResult({
    required this.correctCount,
    required this.totalCount,
    required this.elapsed,
  });

  int get score => (correctCount / totalCount * 100).round();
  bool get isPerfect => correctCount == totalCount;
  bool get isPassed => correctCount >= (totalCount * 0.6).ceil();
}
