/// 学年別の算数ガイド用クイックティップス
/// ホーム画面の算数ガイドセクションに表示される

class MathTip {
  final String title;
  final String description;
  final String emoji;

  const MathTip({
    required this.title,
    required this.description,
    required this.emoji,
  });
}

/// 学年別のティップリスト
const Map<int, List<MathTip>> mathTipsByGrade = {
  1: [
    MathTip(
      emoji: '🔢',
      title: 'たし算のやり方',
      description: '2つの数をあわせる計算です',
    ),
    MathTip(
      emoji: '📌',
      title: 'ひき算のやり方',
      description: 'ある数から別の数を取り除く計算です',
    ),
    MathTip(
      emoji: '✍️',
      title: '数字の読み方・書き方',
      description: '1～10の数字を正しく読み書きしよう',
    ),
  ],
  2: [
    MathTip(
      emoji: '✖️',
      title: 'かけ算（乗法）の仕組み',
      description: '同じ数を何回も足す計算です',
    ),
    MathTip(
      emoji: '÷',
      title: 'わり算（除法）とは？',
      description: 'ある数を等しく分ける計算です',
    ),
    MathTip(
      emoji: '🔟',
      title: '10より大きい数',
      description: '10を超える数の考え方',
    ),
  ],
  3: [
    MathTip(
      emoji: '🍕',
      title: '分数（ぶんすう）とは',
      description: 'ケーキやピザを切り分けた部分を表します',
    ),
    MathTip(
      emoji: '🕐',
      title: '時間の読み方',
      description: '時計を読めるようになろう',
    ),
    MathTip(
      emoji: '🔺',
      title: '図形の基本',
      description: 'いろいろな形を勉強します',
    ),
  ],
  4: [
    MathTip(
      emoji: '0️⃣',
      title: '小数（しょうすう）の計算',
      description: '1より小さい数を表す方法です',
    ),
    MathTip(
      emoji: '📏',
      title: '面積（めんせき）と体積',
      description: 'どのくらい広いか、どのくらい入るか',
    ),
    MathTip(
      emoji: '📊',
      title: 'グラフと統計',
      description: 'データを表やグラフで表す方法',
    ),
  ],
  5: [
    MathTip(
      emoji: '🔀',
      title: '分数の計算',
      description: '分数の足し算・引き算・かけ算・割り算',
    ),
    MathTip(
      emoji: '🔗',
      title: '小数と分数の関係',
      description: '小数と分数は同じ数を表す別の方法です',
    ),
    MathTip(
      emoji: '%',
      title: '割合と百分率',
      description: '全体に対する部分の大きさを表します',
    ),
    MathTip(
      emoji: '📐',
      title: '図形と角度',
      description: '三角形・四角形・五角形などの性質',
    ),
  ],
  6: [
    MathTip(
      emoji: '➕➖',
      title: '正と負の数',
      description: '0より大きい数と小さい数を考えます',
    ),
    MathTip(
      emoji: '🔤',
      title: '文字式と方程式',
      description: 'xなどの文字を使って式を表します',
    ),
    MathTip(
      emoji: '🎲',
      title: '確率と統計',
      description: 'ある事柄の起こりやすさ',
    ),
    MathTip(
      emoji: '⚖️',
      title: '比と比例',
      description: 'ものとものの大きさの関係を表します',
    ),
  ],
};

/// 指定された学年のティップを取得
/// グレードが1～6でない場合は、グレード1のティップを返す
List<MathTip> getTipsForGrade(int grade) {
  final normalizedGrade = grade.clamp(1, 6);
  return mathTipsByGrade[normalizedGrade] ?? mathTipsByGrade[1]!;
}

/// 指定されたグレードのティップをランダムに1つ返す
MathTip getRandomTipForGrade(int grade) {
  final tips = getTipsForGrade(grade);
  return tips[DateTime.now().millisecond % tips.length];
}
