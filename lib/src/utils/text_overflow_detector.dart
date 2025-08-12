import 'package:flutter/material.dart';

/// Utility class to detect if text will overflow in a given space.
class TextOverflowDetector {
  /// Determines if the given text will overflow when rendered with the
  /// specified style and constraints.
  ///
  /// Returns `true` if the text would be truncated or ellipsized when
  /// rendered in the available width.
  ///
  /// [text] - The text content to measure
  /// [style] - The text style to apply
  /// [maxWidth] - The maximum available width for the text
  /// [textAlign] - The text alignment (affects measurement for some cases)
  static bool willTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    TextAlign textAlign = TextAlign.start,
  }) {
    if (text.isEmpty || maxWidth <= 0) {
      return false;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );

    textPainter.layout(maxWidth: maxWidth);

    // Check if the text was truncated or if it exceeds the available width
    final didExceedMaxLines = textPainter.didExceedMaxLines;
    final textWidth = textPainter.size.width;

    textPainter.dispose();

    return didExceedMaxLines || textWidth > maxWidth;
  }

  /// Determines if text will overflow using the current build context
  /// and inherited text style.
  ///
  /// This is a convenience method that automatically resolves text style
  /// from the current theme context.
  static bool willTextOverflowInContext({
    required BuildContext context,
    required String text,
    required double maxWidth,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
  }) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    return willTextOverflow(
      text: text,
      style: effectiveStyle,
      maxWidth: maxWidth,
      textAlign: textAlign,
    );
  }
}
