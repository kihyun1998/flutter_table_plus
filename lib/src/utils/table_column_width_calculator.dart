import 'package:flutter/material.dart';

/// Utility class for calculating column widths in FlutterTablePlus.
///
/// Use this alongside [FlutterTablePlus.autoFitColumnWidth] to provide
/// accurate width measurements for columns that use custom cell builders
/// with non-default text styles, padding, or text transformations.
///
/// See also:
/// - [measureTextWidth] for measuring a single text string.
/// - [calculateColumnWidth] for measuring an entire column (header + body).
class TableColumnWidthCalculator {
  /// Measure the rendered width of a single text string.
  ///
  /// Uses [TextPainter] to calculate the exact pixel width needed to display
  /// [text] with the given [textStyle], then adds [padding] and [extraWidth].
  ///
  /// Parameters:
  /// - [text]: The text content to measure.
  /// - [textStyle]: The [TextStyle] used to render the text.
  /// - [padding]: Horizontal padding around the text (defaults to 16px each side).
  /// - [extraWidth]: Additional width to add (e.g., for icons or decorations).
  /// - [textScaler]: The [TextScaler] to apply (defaults to [TextScaler.noScaling]).
  ///
  /// Returns the total width needed: text width + padding + extra.
  static double measureTextWidth({
    required String text,
    required TextStyle textStyle,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0),
    double extraWidth = 0.0,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    final width = textPainter.width + padding.horizontal + extraWidth;
    textPainter.dispose();

    return width;
  }

  /// Calculate the optimal column width by measuring header and all body values.
  ///
  /// Iterates through [data], extracting each row's display text via
  /// [valueAccessor], measures every value with [bodyTextStyle], and returns
  /// the maximum width found (including the header). The result is clamped
  /// to [[minWidth], [maxWidth]].
  ///
  /// Parameters:
  /// - [headerLabel]: The column header text.
  /// - [headerTextStyle]: The [TextStyle] used for the header.
  /// - [data]: The list of row data objects.
  /// - [valueAccessor]: Function to extract the display value from each row.
  /// - [bodyTextStyle]: The [TextStyle] used for body cells.
  /// - [headerPadding]: Padding around the header text (defaults to 16px horizontal).
  /// - [bodyPadding]: Padding around body cell text (defaults to 16px horizontal).
  /// - [headerExtraWidth]: Extra width for header (e.g., sort icon area).
  /// - [bodyExtraWidth]: Extra width for body cells (e.g., border width).
  /// - [textScaler]: The [TextScaler] to apply (defaults to [TextScaler.noScaling]).
  /// - [minWidth]: Minimum column width (defaults to 50.0).
  /// - [maxWidth]: Maximum column width (defaults to unlimited).
  ///
  /// Returns the optimal width clamped to [[minWidth], [maxWidth]].
  static double calculateColumnWidth<T>({
    required String headerLabel,
    required TextStyle headerTextStyle,
    required List<T> data,
    required dynamic Function(T row) valueAccessor,
    required TextStyle bodyTextStyle,
    EdgeInsets headerPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    EdgeInsets bodyPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    double headerExtraWidth = 0.0,
    double bodyExtraWidth = 0.0,
    TextScaler textScaler = TextScaler.noScaling,
    double minWidth = 50.0,
    double? maxWidth,
  }) {
    // Measure header
    double widest = measureTextWidth(
      text: headerLabel,
      textStyle: headerTextStyle,
      padding: headerPadding,
      extraWidth: headerExtraWidth,
      textScaler: textScaler,
    );

    // Measure body cells
    for (final row in data) {
      final value = valueAccessor(row);
      final text = value?.toString() ?? '';
      if (text.isEmpty) continue;

      final cellWidth = measureTextWidth(
        text: text,
        textStyle: bodyTextStyle,
        padding: bodyPadding,
        extraWidth: bodyExtraWidth,
        textScaler: textScaler,
      );

      if (cellWidth > widest) {
        widest = cellWidth;
      }
    }

    // Add 1px buffer to prevent ellipsis from rounding errors
    widest = (widest + 1.0).ceilToDouble();

    return widest.clamp(minWidth, maxWidth ?? double.infinity);
  }
}
