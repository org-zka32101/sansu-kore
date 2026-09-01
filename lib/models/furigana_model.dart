// Furigana Model - Common kanji and furigana patterns
// Provides standardized furigana for frequently used terms

/// よく使う漢字のふりがなを管理
class FuriganaLibrary {
  // 数学関連の用語
  static const Map<String, String> mathTerms = {
    '足す': 'たす',
    '足し算': 'たしざん',
    '引く': 'ひく',
    '引き算': 'ひきざん',
    'かけ算': 'かけざん',
    '割る': 'わる',
    '割り算': 'わりざん',
    '答え': 'こたえ',
    '合わせ': 'あわせ',
    '数える': 'かぞえる',
    '全部': 'ぜんぶ',
    'のこ': 'のこ',
    '余り': 'あまり',
    '分数': 'ぶんすう',
    '小数': 'しょうすう',
    '図形': 'ずけい',
    '面積': 'めんせき',
    '体積': 'たいせき',
    '周': 'しゅう',
    '文章問題': 'ぶんしょうもんだい',
    '九九': 'くく',
    'グループ': 'ぐるーぷ',
  };

  // 学年
  static const Map<String, String> grades = {
    '1年生': 'いちねんせい',
    '2年生': 'にねんせい',
    '3年生': 'さんねんせい',
    '4年生': 'よんねんせい',
    '5年生': 'ごねんせい',
    '6年生': 'ろくねんせい',
  };

  // 一般用語
  static const Map<String, String> generalTerms = {
    '分ける': 'わける',
    '等しく': 'ひとしく',
    '確認': 'かくにん',
    '大事': 'だいじ',
    '大きい': 'おおきい',
    '小さい': 'ちいさい',
    'イメージ': 'いめーじ',
    'ポイント': 'ぽいんと',
    '基本': 'きほん',
    '仕組み': 'しくみ',
    'ガイド': 'がいど',
    'ステップ': 'すてっぷ',
    '完了': 'かんりょう',
    '前へ': 'まえへ',
    '次へ': 'つぎへ',
  };

  /// 用語集からふりがんを検索
  static String? getFurigana(String kanji) {
    return mathTerms[kanji] ??
        grades[kanji] ??
        generalTerms[kanji];
  }

  /// テキストに含まれるすべての既知の漢字にふりがなを追加
  static String addFuriganaToText(String text) {
    var result = text;

    // 長い用語から順に置換（「1年生」が「1」の「年生」に分割されないように）
    final allTerms = [
      ...mathTerms.entries,
      ...grades.entries,
      ...generalTerms.entries,
    ]..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final entry in allTerms) {
      final kanji = entry.key;
      final furigana = entry.value;
      result = result.replaceAll(kanji, '$kanji($furigana)');
    }

    return result;
  }

  /// 複数の用語セットをマージ
  static Map<String, String> getMergedTerms({
    bool includeMath = true,
    bool includeGrades = true,
    bool includeGeneral = true,
  }) {
    final merged = <String, String>{};

    if (includeMath) merged.addAll(mathTerms);
    if (includeGrades) merged.addAll(grades);
    if (includeGeneral) merged.addAll(generalTerms);

    return merged;
  }
}

/// ふりがん対応テキストの構築を支援
class FuriganaTextBuilder {
  final List<_TextPart> _parts = [];

  /// 通常のテキストを追加
  FuriganaTextBuilder addText(String text) {
    _parts.add(_TextPart(text: text, furigana: null));
    return this;
  }

  /// ふりがな付きテキストを追加
  FuriganaTextBuilder addWithFurigana(String text, String furigana) {
    _parts.add(_TextPart(text: text, furigana: furigana));
    return this;
  }

  /// ライブラリから自動的にふりがんを追加
  FuriganaTextBuilder addAuto(String text) {
    final furigana = FuriganaLibrary.getFurigana(text);
    _parts.add(_TextPart(text: text, furigana: furigana));
    return this;
  }

  /// 括弧形式でふりがん付きテキストを追加
  FuriganaTextBuilder addWithBrackets(String textWithFurigana) {
    // 「漢字(かんじ)」形式を解析
    final regex = RegExp(r'(.+?)\((.+?)\)');
    final match = regex.firstMatch(textWithFurigana);

    if (match != null) {
      final text = match.group(1) ?? '';
      final furigana = match.group(2) ?? '';
      _parts.add(_TextPart(text: text, furigana: furigana));
    } else {
      _parts.add(_TextPart(text: textWithFurigana, furigana: null));
    }
    return this;
  }

  /// 構築完了したテキストを取得
  String build() {
    return _parts
        .map((part) {
          if (part.furigana == null || part.furigana!.isEmpty) {
            return part.text;
          }
          return '${part.text}(${part.furigana})';
        })
        .join();
  }

  /// パーツリストを取得（ウィジェット構築用）
  List<_TextPart> getParts() => List.unmodifiable(_parts);
}

class _TextPart {
  final String text;
  final String? furigana;

  _TextPart({required this.text, required this.furigana});
}
