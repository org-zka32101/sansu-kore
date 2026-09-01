// Math Guide Model - Educational content for arithmetic concepts
// Features: Grade-level math guides, step-by-step explanations, visual examples

enum MathConcept {
  addition,           // 足し算
  subtraction,        // 引き算
  multiplication,     // かけ算
  division,           // 割り算
  fractions,          // 分数
  decimals,           // 小数
  geometry,           // 図形
  wordProblems,       // 文章問題
}

enum GradeLevel {
  grade1,             // 1年生
  grade2,             // 2年生
  grade3,             // 3年生
  grade4,             // 4年生
  grade5,             // 5年生
  grade6,             // 6年生
}

/// 数学ガイドのステップ（説明の単位）
class GuideStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? example;        // 具体例
  final String? visualHint;     // 図解のヒント
  final List<String>? tips;     // ポイント

  const GuideStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.example,
    this.visualHint,
    this.tips,
  });
}

/// 数学ガイド - 特定の概念の学習内容
class MathGuide {
  final String id;
  final MathConcept concept;
  final GradeLevel gradeLevel;
  final String title;
  final String subtitle;
  final String overview;
  final List<GuideStep> steps;
  final String? videoUrl;       // 動画リンク（将来用）
  final List<String>? relatedConcepts;
  final String emoji;

  const MathGuide({
    required this.id,
    required this.concept,
    required this.gradeLevel,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.steps,
    this.videoUrl,
    this.relatedConcepts,
    required this.emoji,
  });

  /// Get guide by concept and grade
  static MathGuide? getGuide(MathConcept concept, GradeLevel gradeLevel) {
    final key = '${concept.name}_${gradeLevel.name}';
    return _guideDatabase[key];
  }

  /// Get all guides for a grade level
  static List<MathGuide> getGuidesForGrade(GradeLevel gradeLevel) {
    return _guideDatabase.values
        .where((guide) => guide.gradeLevel == gradeLevel)
        .toList();
  }

  /// Get all available concepts
  static List<MathConcept> getAvailableConcepts(GradeLevel gradeLevel) {
    return _guideDatabase.values
        .where((guide) => guide.gradeLevel == gradeLevel)
        .map((guide) => guide.concept)
        .toSet()
        .toList();
  }

  // Database of guides
  static const Map<String, MathGuide> _guideDatabase = {
    // Grade 1 - Addition
    'addition_grade1': MathGuide(
      id: 'addition_grade1',
      concept: MathConcept.addition,
      gradeLevel: GradeLevel.grade1,
      title: '足し算のやり方',
      subtitle: '1年生向け',
      overview: '足し算は2つ以上の数を合わせることです。',
      emoji: '➕',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '数を数える',
          description: 'まず、足す2つの数がいくつか指で数えます。',
          example: '例：3 + 2 = ？',
          visualHint: '● ● ● と ● ● の絵を描いてイメージします',
          tips: [
            '指を使って数えるのはOKです',
            'ゆっくり数えることが大事',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: 'すべての数を合わせる',
          description: '数えた数字を全部合わせます。',
          example: '3 + 2 = 1, 2, 3, 4, 5 = 5',
          visualHint: 'すべての●を一緒に数えます',
          tips: [
            '合わせた後、全部で何個か数えます',
            '1から数え直すのは大丈夫です',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '答えを書く',
          description: '数えた答えを書きます。',
          example: '3 + 2 = 5',
          tips: [
            '=の後に答えを書きます',
          ],
        ),
      ],
      relatedConcepts: ['数字の認識', '数える'],
    ),

    // Grade 2 - Subtraction
    'subtraction_grade2': MathGuide(
      id: 'subtraction_grade2',
      concept: MathConcept.subtraction,
      gradeLevel: GradeLevel.grade2,
      title: '引き算のやり方',
      subtitle: '2年生向け',
      overview: '引き算は大きい数から小さい数を取り除くことです。',
      emoji: '➖',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '大きい数を数える',
          description: '最初の数をします。',
          example: '例：5 - 2 = ？ → 5個を数えます',
          visualHint: '● ● ● ● ● の絵を描きます',
          tips: [
            '最初の数はしっかり把握します',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '取り除く数を確認',
          description: '取り除く数だけ、のけます。',
          example: '5から2を取り除く → ● ● をなくします',
          visualHint: '取り除いた●をバツで消します',
          tips: [
            'いくつ取り除くのかを数えます',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '残りを数える',
          description: 'のこった数を数えます。',
          example: '5 - 2 = ● ● ● = 3',
          tips: [
            '残りが答えです',
          ],
        ),
      ],
      relatedConcepts: ['足し算', '数える'],
    ),

    // Grade 3 - Multiplication
    'multiplication_grade3': MathGuide(
      id: 'multiplication_grade3',
      concept: MathConcept.multiplication,
      gradeLevel: GradeLevel.grade3,
      title: 'かけ算の仕組み',
      subtitle: '3年生向け',
      overview: 'かけ算は同じ数を何度も足すことを簡単に書く方法です。',
      emoji: '✖️',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: 'かけ算は何のために？',
          description: '同じ数を何度も足すのは大変です。そこで「かけ算」を使います。',
          example: '2 + 2 + 2 = 6 と書く代わりに、2 × 3 = 6 と書きます',
          visualHint: 'グループ分けの絵を描きます',
          tips: [
            '「×」は「ぐるいのマーク」です',
            '2が3回 = 2 × 3',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: 'かけ算の意味を理解する',
          description: '「4 × 5」は「4が5個」という意味です。',
          example: '4 × 5 = 4 + 4 + 4 + 4 + 4 = 20',
          visualHint: 'ブロック5列、各列4個の図',
          tips: [
            'かけ算記号の前の数がグループの大きさ',
            '後の数がグループの個数',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '九九を使う',
          description: 'よく使うかけ算を暗記します（九九）。',
          example: '2 × 3 = 6, 3 × 4 = 12, etc.',
          tips: [
            '九九は何度も繰り返して覚えます',
            '歌で覚えるのもいいです',
          ],
        ),
      ],
      relatedConcepts: ['足し算', 'グループ化'],
    ),

    // Grade 4 - Division
    'division_grade4': MathGuide(
      id: 'division_grade4',
      concept: MathConcept.division,
      gradeLevel: GradeLevel.grade4,
      title: '割り算の基本',
      subtitle: '4年生向け',
      overview: '割り算は数を等しく分ける、またはグループ分けすることです。',
      emoji: '➗',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '割り算は何のために？',
          description: 'ケーキやお菓子を等しく分けるとき、割り算を使います。',
          example: '12個のお菓子を3人で等しく分ける → 12 ÷ 3 = 4',
          visualHint: 'お菓子を3グループに分ける図',
          tips: [
            '「÷」は「分けるマーク」です',
            '12 ÷ 3 は「12を3で分ける」という意味',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '割り算はかけ算の逆',
          description: '割り算はかけ算の反対操作です。',
          example: '3 × 4 = 12 の反対は 12 ÷ 3 = 4',
          tips: [
            'かけ算がわかれば割り算もわかる',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '余りについて',
          description: 'ぴったり分けられないときは「余り」があります。',
          example: '10 ÷ 3 = 3 あまり 1 （3×3=9, 1個余る）',
          tips: [
            '余りが出ることは普通です',
          ],
        ),
      ],
      relatedConcepts: ['かけ算', 'グループ分け'],
    ),
  };
}

/// ガイド表示の進捗情報
class GuideProgress {
  final String guideId;
  final GradeLevel gradeLevel;
  final DateTime viewedAt;
  final int lastStepViewed;
  final bool isCompleted;

  const GuideProgress({
    required this.guideId,
    required this.gradeLevel,
    required this.viewedAt,
    required this.lastStepViewed,
    this.isCompleted = false,
  });

  GuideProgress copyWith({
    int? lastStepViewed,
    bool? isCompleted,
  }) {
    return GuideProgress(
      guideId: guideId,
      gradeLevel: gradeLevel,
      viewedAt: viewedAt,
      lastStepViewed: lastStepViewed ?? this.lastStepViewed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
