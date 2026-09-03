import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/table_column.dart';

/// Utility class for calculating row heights in FlutterTablePlus.
///
/// This is useful when you want to support TextOverflow.visible or
/// other dynamic height requirements without the performance issues
/// of automatic height calculation.
class TableRowHeightCalculator {
  /// Calculate the height needed for a single text cell.
  ///
  /// Parameters:
  /// - [text]: The text content to measure
  /// - [textStyle]: The TextStyle to apply
  /// - [maxWidth]: The maximum width available for the text
  /// - [textAlign]: Text alignment (optional)
  /// - [padding]: Cell padding (defaults to EdgeInsets.symmetric(vertical: 8.0))
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  /// - [textScaler]: The OS text-size multiplier (defaults to
  ///   [TextScaler.noScaling]). It is **not** part of [textStyle]: a scaled
  ///   theme scales `fontSize` inside the style, while this multiplies the
  ///   resolved size when the paragraph is built. Leave it at the default and
  ///   this predicts one number while the screen draws another.
  ///
  /// **[textStyle] must be the style the glyphs actually get, ambient
  /// inheritance already resolved.** A `Text` merges the inherited
  /// [DefaultTextStyle] under the style it is given, which is where the font
  /// family, `letterSpacing` and `height` come from when a theme style does not
  /// name them — and a bare [TextPainter] sees none of that. Measured on the
  /// default theme: a style declaring only `fontSize` predicts 100px for a
  /// paragraph the screen lays out at 120px, and the text is clipped with no
  /// overflow banner. [createHeightCalculator] resolves this for you when given
  /// a `context`.
  ///
  /// Returns the calculated height needed to display the text.
  static double calculateTextHeight({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
    TextAlign textAlign = TextAlign.start,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 8.0),
    double minHeight = 48.0,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    if (text.isEmpty || maxWidth <= 0) {
      return minHeight;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: null,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      textScaler: textScaler,
    );

    textPainter.layout(maxWidth: maxWidth);

    // Add cell padding
    final calculatedHeight = textPainter.height + padding.vertical;

    textPainter.dispose();

    return math.max(minHeight, calculatedHeight);
  }

  /// Calculate the height needed for a table row based on its content.
  ///
  /// This method examines all text columns in the row and returns the
  /// height needed to accommodate the tallest cell.
  ///
  /// Parameters:
  /// - [rowData]: The data object for this row
  /// - [columns]: List of table columns
  /// - [columnWidths]: List of calculated column widths
  /// - [defaultTextStyle]: Default text style for cells
  /// - [cellPadding]: Cell padding (defaults to EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0))
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  ///
  /// Returns the calculated height needed for the entire row.
  static double calculateRowHeight<T>({
    required T rowData,
    required List<TablePlusColumn<T>> columns,
    required List<double> columnWidths,
    required TextStyle defaultTextStyle,
    EdgeInsets cellPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    double minHeight = 48.0,
    TextScaler textScaler = TextScaler.noScaling,
    double extraWidth = 0.0,
  }) {
    double maxHeight = minHeight;

    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];

      // Skip columns with custom cell builders (can't calculate height)
      if (column.hasCustomCellBuilder) continue;

      // Skip if TextOverflow is not visible (no dynamic height needed)
      if (column.textOverflow != TextOverflow.visible) continue;

      final cellValue = column.valueAccessor(rowData);
      if (cellValue == null) continue;

      final text = cellValue.toString();
      if (text.isEmpty) continue;

      final columnWidth =
          columnWidths.isNotEmpty ? columnWidths[i] : column.width;

      // Account for cell padding when calculating available text width, and
      // for whatever the cell's own decoration takes on top of it: a body
      // cell draws a vertical divider whose border a Container folds into the
      // child's inset, so the glyphs get less than `columnWidth - padding`.
      // The caller supplies it because only the caller knows their theme —
      // `bodyTheme.showVerticalDividers ? bodyTheme.verticalDividerSide.width
      // : 0` — which is the same shape `TableColumnWidthCalculator` takes as
      // `bodyExtraWidth`.
      final availableTextWidth =
          columnWidth - cellPadding.horizontal - extraWidth;

      if (availableTextWidth <= 0) continue;

      final cellHeight = calculateTextHeight(
        text: text,
        textStyle: defaultTextStyle,
        maxWidth: availableTextWidth,
        textAlign: column.textAlign,
        padding: cellPadding,
        minHeight: minHeight,
        textScaler: textScaler,
      );

      maxHeight = math.max(maxHeight, cellHeight);
    }

    return maxHeight;
  }

  /// Create a calculateRowHeight callback for FlutterTablePlus.
  ///
  /// This is a convenience method that returns a function compatible
  /// with FlutterTablePlus.calculateRowHeight parameter.
  ///
  /// Parameters:
  /// - [columns]: List of table columns
  /// - [columnWidths]: List of calculated column widths
  /// - [defaultTextStyle]: Default text style for cells
  /// - [cellPadding]: Cell padding (defaults to EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0))
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  ///
  /// - [context]: when given, the ambient [DefaultTextStyle] is merged under
  ///   [defaultTextStyle] and [MediaQuery.textScalerOf] is read from it — the
  ///   two inputs the painted glyphs get and a bare [TextPainter] does not.
  ///   Pass it unless you have already resolved both yourself.
  ///
  /// Returns a function that can be used as FlutterTablePlus.calculateRowHeight
  ///
  /// **Hold the result in a field; do not build it inline in `build`.** The
  /// height caches — and the `RowGeometry` every drag hit-test is answered
  /// from — drop whenever this callback is not equal to the previous one, and a
  /// closure built fresh each build never is. Measured: two calls with
  /// identical arguments return callbacks that compare `!=`, so the documented
  /// inline form re-measures every row on every frame.
  ///
  /// A value type with an `==` does **not** fix this, which was tried and
  /// measured: Dart compares two tear-offs of the same method by whether their
  /// receivers are `identical`, never by whether they are `==`. A stable
  /// receiver is the only thing that works, and only the caller can hold one.
  static double? Function(int, T) createHeightCalculator<T>({
    required List<TablePlusColumn<T>> columns,
    required List<double> columnWidths,
    required TextStyle defaultTextStyle,
    EdgeInsets cellPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    double minHeight = 48.0,
    TextScaler textScaler = TextScaler.noScaling,
    double extraWidth = 0.0,
    BuildContext? context,
  }) {
    // Mirrors Text.build: the ambient style is merged under the given one only
    // when that one inherits.
    final resolvedStyle = context != null && defaultTextStyle.inherit
        ? DefaultTextStyle.of(context).style.merge(defaultTextStyle)
        : defaultTextStyle;
    final resolvedScaler =
        context != null ? MediaQuery.textScalerOf(context) : textScaler;

    return (int rowIndex, T rowData) {
      return calculateRowHeight<T>(
        rowData: rowData,
        columns: columns,
        columnWidths: columnWidths,
        defaultTextStyle: resolvedStyle,
        cellPadding: cellPadding,
        minHeight: minHeight,
        textScaler: resolvedScaler,
        extraWidth: extraWidth,
      );
    };
  }
}
