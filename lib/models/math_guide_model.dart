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

    // Grade 5 - Fractions
    'fractions_grade5': MathGuide(
      id: 'fractions_grade5',
      concept: MathConcept.fractions,
      gradeLevel: GradeLevel.grade5,
      title: '分数の基本',
      subtitle: '5年生向け',
      overview: '分数は、ケーキやピザのように全体を等しく分けた時の一部を表します。',
      emoji: '🍰',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '分数とは何か',
          description: '分数は「全体をいくつに分けたうちの、いくつ分か」を表す数です。',
          example: 'ピザを4等分して2ピース食べた → 2/4（全体の1/2）',
          visualHint: 'ピザやケーキを分割する図で表現',
          tips: [
            '上の数字 = 分子（何個か）',
            '下の数字 = 分母（全体いくつ分か）',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '分数の大きさ比べ',
          description: '分数の大きさは、分母と分子の関係で決まります。',
          example: '1/2 > 1/4 （同じ全体を分ける時、分けた数が少ないほど大きい）',
          visualHint: '同じ大きさのケーキを2等分と4等分に分けた図',
          tips: [
            '分母が小さい = ピース1個が大きい',
            '分子が大きい = 食べた量が多い',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '通分と約分',
          description: '異なる分母の分数を足し引きするには、分母を同じにします。',
          example: '1/2 + 1/4 = 2/4 + 1/4 = 3/4',
          visualHint: '分母を合わせるイメージ図',
          tips: [
            '通分：分母を同じにする',
            '約分：分子分母を同じ数で割る',
          ],
        ),
      ],
      relatedConcepts: ['割り算', '小数'],
    ),

    // Grade 5 - Decimals
    'decimals_grade5': MathGuide(
      id: 'decimals_grade5',
      concept: MathConcept.decimals,
      gradeLevel: GradeLevel.grade5,
      title: '小数の仕組み',
      subtitle: '5年生向け',
      overview: '小数は整数では表せない、1より小さい数や中間の数を表します。',
      emoji: '🔢',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '小数とは',
          description: '小数は、1を10等分、100等分…した時の一部の大きさです。',
          example: '0.5 = 5/10（1の5個分），0.25 = 25/100（1の25個分）',
          visualHint: '目盛りのついた数直線で0と1の間を分割',
          tips: [
            '小数点の右 = 1より小さい数',
            '0.1 = 1/10（10分の1）',
            '0.01 = 1/100（100分の1）',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '小数の足し算・引き算',
          description: '小数も整数と同じように足し引きできます。ただし、小数点の位置に注意します。',
          example: '2.3 + 1.5 = 3.8 （小数点の位置を揃える）',
          visualHint: '数直線上での移動を示す図',
          tips: [
            '小数点の位置をそろえて計算する',
            '1 + 0.5 = 1.5 （1と0.5をセットで考える）',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '小数とお金・メートル',
          description: '日常生活で小数は、お金や長さに使われています。',
          example: '150円 = 1.5百円，1.5m = 150cm',
          tips: [
            'お金：100円 = 1，1円 = 0.01',
            '長さ：1m = 1, 1cm = 0.01',
          ],
        ),
      ],
      relatedConcepts: ['分数', 'お金', 'メートル'],
    ),

    // Grade 6 - Geometry
    'geometry_grade6': MathGuide(
      id: 'geometry_grade6',
      concept: MathConcept.geometry,
      gradeLevel: GradeLevel.grade6,
      title: '図形の面積と体積',
      subtitle: '6年生向け',
      overview: '図形がどれくらい大きいかを、面積と体積で表すことができます。',
      emoji: '📐',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '面積とは',
          description: '面積は、図形の広さのことです。1cm × 1cm の正方形（1㎠）がいくつ入るか数えます。',
          example: 'たて3cm ×よこ4cm の長方形 = 3×4 = 12㎠',
          visualHint: 'グリッド上に図形を描き、マスを数える',
          tips: [
            '長方形の面積 = 縦 × 横',
            '三角形の面積 = 底辺 × 高さ ÷ 2',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '体積とは',
          description: '体積は、立体図形がどれくらいの空間を占めているかです。1cm × 1cm × 1cm の立方体（1㎤）で測ります。',
          example: '縦2cm × 横3cm × 高さ4cm の直方体 = 2×3×4 = 24㎤',
          visualHint: '積み木を積み上げた図',
          tips: [
            '直方体の体積 = 縦 × 横 × 高さ',
            '容積（液体が入る量）も同じ式で計算',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '周の長さと表面積',
          description: '周の長さは図形のふちの長さ、表面積は立体の全ての面の面積の合計です。',
          example: '正方形のふち：1辺4cm × 4 = 16cm',
          tips: [
            '周の長さ = 全てのふちを足す',
            '表面積 = 全ての面の面積を足す',
          ],
        ),
      ],
      relatedConcepts: ['正方形', '三角形', '立方体'],
    ),

    // Grade 6 - Word Problems
    'wordProblems_grade6': MathGuide(
      id: 'wordProblems_grade6',
      concept: MathConcept.wordProblems,
      gradeLevel: GradeLevel.grade6,
      title: '文章問題の解き方',
      subtitle: '6年生向け',
      overview: '文章問題は、日常の状況を数学で表して、答えを求める問題です。',
      emoji: '📖',
      steps: [
        GuideStep(
          stepNumber: 1,
          title: '問題を読み取る',
          description: '文章問題を解く時は、まず何がわかっていて、何を求めるのかを整理します。',
          example: '「りんごが5個、みかんが3個あります。全部でいくつ？」 → わかっている：りんご5個、みかん3個 求める：全部の個数',
          visualHint: '情報を四角で囲むメモの取り方',
          tips: [
             '「全部で」「残り」などの言葉に注意',
            'わかっていることと求めることを分ける',
          ],
        ),
        GuideStep(
          stepNumber: 2,
          title: '式を立てる',
          description: '読み取った情報から、計算式を作ります。',
          example: '5個 + 3個 = 8個（足し算），10個 - 3個 = 7個（引き算）',
          visualHint: '図や表を使って情報を整理',
          tips: [
            '図や表に書いてみると分かりやすい',
            '式は「何 + 何 = 答え」の形で',
          ],
        ),
        GuideStep(
          stepNumber: 3,
          title: '計算して検算する',
          description: '式から答えを計算し、その答えが問題として合っているか確認します。',
          example: '5 + 3 = 8，確認：「りんご5個とみかん3個で全部8個」→正しい！',
          tips: [
            '計算ミスがないか2回計算する',
            '答えが問題の状況に合っているか確認する',
          ],
        ),
      ],
      relatedConcepts: ['足し算', '引き算', 'かけ算', '割り算'],
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
