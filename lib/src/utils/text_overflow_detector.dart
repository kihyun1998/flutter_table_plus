import 'package:flutter/material.dart';

/// Everything the overflow measurement consumes, as one value.
///
/// It exists so the measurement and the memo that caches it read the *same*
/// list. Two lists is how the cache came to key on `(text, width)` while the
/// layout also depended on the style and the ambient [TextScaler] — an input
/// added to one and not the other serves a stale answer forever. There is no
/// way in Dart to make that disagreement impossible; what is achievable is
/// reducing the two lists to one, which is what this type is.
@immutable
class TextMeasurement {
  const TextMeasurement({
    required this.text,
    required this.maxWidth,
    required this.style,
    this.textScaler = TextScaler.noScaling,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
  });

  /// The text content to measure.
  final String text;

  /// The width the glyphs are actually laid out in — not the width the box
  /// declares. A decoration's border is folded into the child's inset, so the
  /// caller subtracts what its own decoration consumes before constructing
  /// this.
  final double maxWidth;

  /// The style the glyphs are painted with, ambient inheritance already
  /// resolved.
  final TextStyle style;

  /// The paint-time multiplier the OS text-size setting applies. It is not in
  /// [style]: `scaledBy` scales `fontSize` *inside* the style, while this
  /// multiplies the resolved size when the paragraph is built.
  final TextScaler textScaler;

  /// Carried because a caller has it, not because it moves the answer: a line
  /// break does not depend on alignment, and the painter's reported width is
  /// clamped to [maxWidth] either way.
  final TextAlign textAlign;

  /// The ambient direction the `Text` resolves from `Directionality`.
  ///
  /// Only bidirectional strings can break differently under it, so no failure
  /// is known — but it is an input the glyphs get, and this type exists so the
  /// measurement and the memo cannot list a different set of those.
  final TextDirection textDirection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMeasurement &&
          other.text == text &&
          other.maxWidth == maxWidth &&
          other.style == style &&
          other.textScaler == textScaler &&
          other.textAlign == textAlign &&
          other.textDirection == textDirection;

  @override
  int get hashCode =>
      Object.hash(text, maxWidth, style, textScaler, textAlign, textDirection);
}

/// Utility class to detect if text will overflow in a given space.
class TextOverflowDetector {
  /// Resolves the inputs the painted glyphs will actually get from [context],
  /// the way `Text` resolves them, and returns the measurement they define.
  ///
  /// Two of those inputs are ambient and invisible to a bare [TextPainter]:
  /// the inherited [DefaultTextStyle] (which supplies the font family,
  /// `letterSpacing` and `height` a theme style typically does not name) and
  /// [MediaQuery.textScalerOf]. A measurement that skips them predicts a
  /// different string than the one on screen.
  ///
  /// [maxWidth] is the width the glyphs receive, which is **not** the width
  /// the cell declares — see [TextMeasurement.maxWidth].
  static TextMeasurement measurementFor({
    required BuildContext context,
    required String text,
    required double maxWidth,
    required TextStyle style,
    TextAlign textAlign = TextAlign.start,
  }) {
    // Mirrors Text.build: the ambient style is merged under the given one only
    // when that one inherits.
    final ambient = DefaultTextStyle.of(context).style;
    return TextMeasurement(
      text: text,
      maxWidth: maxWidth,
      style: style.inherit ? ambient.merge(style) : style,
      textScaler: MediaQuery.textScalerOf(context),
      textAlign: textAlign,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
  }

  /// Determines if [m] would be truncated or ellipsized when rendered.
  ///
  /// Returns `true` if the text does not fit on one line in
  /// [TextMeasurement.maxWidth].
  static bool willTextOverflow(TextMeasurement m) {
    if (m.text.isEmpty || m.maxWidth <= 0) {
      return false;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: m.text, style: m.style),
      maxLines: 1,
      textDirection: m.textDirection,
      textAlign: m.textAlign,
      textScaler: m.textScaler,
    );

    textPainter.layout(maxWidth: m.maxWidth);

    // `didExceedMaxLines` alone, and that is the whole verdict.
    //
    // This used to be `didExceedMaxLines || textWidth > maxWidth`, which reads
    // like a width check and is one the layout has already made impossible:
    // `TextPainter.size.width` is the *content* width, clamped into
    // `[minWidth, maxWidth]` under the default `TextWidthBasis.parent`. It can
    // never exceed the width just laid out at, so the second disjunct was
    // unreachable. `test/text_overflow_detector_test.dart` pins the clamp, so
    // the premise is asserted rather than remembered.
    final didExceedMaxLines = textPainter.didExceedMaxLines;

    textPainter.dispose();

    return didExceedMaxLines;
  }

  /// Convenience for a call site with no cache: resolve, then measure.
  ///
  /// A site that memoizes the answer must not use this — it needs the
  /// [TextMeasurement] itself, so the memo and the measurement key on one
  /// list. Use [measurementFor] there.
  static bool willTextOverflowInContext({
    required BuildContext context,
    required String text,
    required double maxWidth,
    required TextStyle style,
    TextAlign textAlign = TextAlign.start,
  }) {
    return willTextOverflow(measurementFor(
      context: context,
      text: text,
      maxWidth: maxWidth,
      style: style,
      textAlign: textAlign,
    ));
  }
}
