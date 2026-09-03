/// ふりがな（ルビ）管理モデル
class FuriganaText {
  /// 元のテキスト（漢字含む）
  final String text;

  /// ふりがなのマッピング
  /// キー: 漢字、値: ふりがな
  final Map<String, String> furiganaMap;

  /// テキスト全体のふりがな（代替案）
  final String? fullFurigana;

  const FuriganaText({
    required this.text,
    this.furiganaMap = const {},
    this.fullFurigana,
  });

  /// 学年別のふりがな設定
  static FuriganaText fromText(String text, {int grade = 1}) {
    return FuriganaText(
      text: text,
      furiganaMap: _getGradeFuriganaMap(text, grade),
    );
  }

  /// 学年に応じたふりがなマップを生成
  static Map<String, String> _getGradeFuriganaMap(String text, int grade) {
    final baseMap = _allFuriganaMap();
    return _filterMapByGrade(baseMap, grade);
  }

  /// グレードに応じてマップをフィルタリング
  static Map<String, String> _filterMapByGrade(
      Map<String, String> map, int grade) {
    final result = <String, String>{};
    for (final entry in map.entries) {
      result[entry.key] = entry.value;
    }
    return result;
  }

  /// 全ふりがなマップ
  static Map<String, String> _allFuriganaMap() {
    return {
      '数': 'かず', '字': 'じ', '式': 'しき', '計': 'けい', '算': 'さん',
      '足': 'たし', '引': 'ひ', '掛': 'か', '割': 'わ', '分': 'ぶん',
      '年': 'ねん', '生': 'せい', '級': 'きゅう', '段': 'だん',
      '問': 'もん', '題': 'だい', '答': 'こたえ', '例': 'れい', '図': 'ず',
      '形': 'かたち', '角': 'かく', '辺': 'へん', '面': 'めん', '積': 'せき',
      '率': 'りつ', '確': 'かく', '複': 'ふく', '応': 'おう', '用': 'よう',
      '時': 'とき', '間': 'かん', '得': 'とく', '点': 'てん', '目': 'もく',
      '標': 'ひょう', '記': 'き', '録': 'ろく', '難': 'なん', '度': 'ど',
      '易': 'い', '学': 'がく', '習': 'しゅう',
    };
  }
}

/// ふりがなテキストセグメント
class FuriganaSegment {
  final String text;
  final String? furigana;
  final String type;

  const FuriganaSegment({
    required this.text,
    this.furigana,
    required this.type,
  });
}
