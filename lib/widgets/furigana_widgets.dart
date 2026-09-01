// Furigana Widgets - Ruby text support for kanji
// Features: Furigana display, flexible sizing, light/dark theme support

import 'package:flutter/material.dart';

/// ふりがな付きテキスト
/// 漢字の上に読み方を表示する
class FuriganaText extends StatelessWidget {
  final String kanji;
  final String furigana;
  final TextStyle? kanjiStyle;
  final TextStyle? furiganaStyle;

  const FuriganaText({
    Key? key,
    required this.kanji,
    required this.furigana,
    this.kanjiStyle,
    this.furiganaStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultKanjiStyle = kanjiStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        );

    final defaultFuriganaStyle = furiganaStyle ??
        TextStyle(
          fontSize: defaultKanjiStyle.fontSize! * 0.5,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
          height: 0.8,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ふりがな（上）
        Text(
          furigana,
          style: defaultFuriganaStyle,
          textAlign: TextAlign.center,
        ),
        // 漢字（下）
        Text(
          kanji,
          style: defaultKanjiStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// ふりがな対応のテキスト（インライン）
/// 文中に埋め込める柔軟なふりがな表示
class RichFuriganaText extends StatelessWidget {
  final List<FuriganaSegment> segments;
  final TextStyle? baseStyle;
  final double furiganaScale;

  const RichFuriganaText({
    Key? key,
    required this.segments,
    this.baseStyle,
    this.furiganaScale = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = baseStyle ??
        const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        );

    return RichText(
      text: TextSpan(
        style: base,
        children: segments.map((segment) {
          if (segment.furigana == null || segment.furigana!.isEmpty) {
            // ふりがんがない場合は通常テキスト
            return TextSpan(
              text: segment.text,
              style: base,
            );
          } else {
            // ふりがな付きテキスト
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    segment.furigana!,
                    style: TextStyle(
                      fontSize: (base.fontSize ?? 16) * furiganaScale,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      height: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    segment.text,
                    style: base,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}

/// ふりがなセグメント
class FuriganaSegment {
  final String text;
  final String? furigana;

  FuriganaSegment({
    required this.text,
    this.furigana,
  });
}

/// 簡単なふりがん表記（括弧形式）
/// 「漢字(かんじ)」形式を解析して表示
class SimpleFuriganaParser {
  /// 「漢字(かんじ)」形式のテキストをパース
  static List<FuriganaSegment> parse(String text) {
    final segments = <FuriganaSegment>[];
    final regex = RegExp(r'([^\(]+)\(([^\)]+)\)');
    final namedGroupsRegex = RegExp(r'(.+?)\((.+?)\)');

    int lastEnd = 0;
    for (final match in namedGroupsRegex.allMatches(text)) {
      // マッチ前のテキスト
      if (match.start > lastEnd) {
        segments.add(FuriganaSegment(
          text: text.substring(lastEnd, match.start),
          furigana: null,
        ));
      }

      // マッチしたテキスト
      final kanji = match.group(1) ?? '';
      final furigana = match.group(2) ?? '';
      segments.add(FuriganaSegment(
        text: kanji,
        furigana: furigana,
      ));

      lastEnd = match.end;
    }

    // 最後の残りのテキスト
    if (lastEnd < text.length) {
      segments.add(FuriganaSegment(
        text: text.substring(lastEnd),
        furigana: null,
      ));
    }

    return segments.isEmpty
        ? [FuriganaSegment(text: text, furigana: null)]
        : segments;
  }
}

/// ふりがん対応のタイトルウィジェット
class FuriganaTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double furiganaScale;

  const FuriganaTitle({
    Key? key,
    required this.text,
    this.style,
    this.furiganaScale = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = style ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        );

    final segments = SimpleFuriganaParser.parse(text);

    return RichFuriganaText(
      segments: segments,
      baseStyle: titleStyle,
      furiganaScale: furiganaScale,
    );
  }
}

/// ふりがん対応のボディテキストウィジェット
class FuriganaBody extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double furiganaScale;
  final int? maxLines;
  final TextOverflow? overflow;

  const FuriganaBody({
    Key? key,
    required this.text,
    this.style,
    this.furiganaScale = 0.5,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = style ??
        const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
        );

    final segments = SimpleFuriganaParser.parse(text);

    return RichFuriganaText(
      segments: segments,
      baseStyle: bodyStyle,
      furiganaScale: furiganaScale,
    );
  }
}

/// ステップタイトル用ふりがんウィジェット
class FuriganaStepTitle extends StatelessWidget {
  final String text;
  final int stepNumber;

  const FuriganaStepTitle({
    Key? key,
    required this.text,
    required this.stepNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final segments = SimpleFuriganaParser.parse(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichFuriganaText(
        segments: [
          FuriganaSegment(
            text: 'ステップ $stepNumber: ',
            furigana: null,
          ),
          ...segments,
        ],
        baseStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
        furiganaScale: 0.5,
      ),
    );
  }
}
