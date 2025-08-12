import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/table_column.dart';

/// Utility class for calculating text heights in table cells.
class TextHeightCalculator {
  // Cache for single line height calculations
  static final Map<TextStyle, double> _singleLineHeightCache = {};

  /// Calculates the required height for a text cell considering all styling factors.
  ///
  /// [text] - The text content to measure
  /// [width] - Available width for the text (column width minus padding)
  /// [textStyle] - Text style to apply
  /// [padding] - Cell padding that affects available text width
  /// [textOverflow] - How text overflow should be handled
  /// [maxLines] - Maximum lines allowed (null for unlimited)
  static double calculateCellHeight({
    required String text,
    required double width,
    required TextStyle textStyle,
    required EdgeInsets padding,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    int? maxLines,
  }) {
    // For non-visible overflow modes, return a standard single-line height
    if (textOverflow != TextOverflow.visible) {
      return _getSingleLineHeight(textStyle) + padding.vertical;
    }

    // Calculate available width for text (subtract horizontal padding)
    final availableWidth = math.max(0.0, width - padding.horizontal);

    if (availableWidth <= 0) {
      return _getSingleLineHeight(textStyle) + padding.vertical;
    }

    // Create TextPainter to measure actual text dimensions
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );

    // Layout the text with available width
    textPainter.layout(maxWidth: availableWidth);

    // Return height plus padding
    return textPainter.height + padding.vertical;
  }

  /// Calculates row heights for all rows in the table data.
  ///
  /// [data] - Table data
  /// [columns] - Column definitions
  /// [bodyTextStyle] - Default text style for body cells
  /// [bodyPadding] - Default padding for body cells
  /// [mode] - Height calculation mode (uniform or dynamic)
  /// [minRowHeight] - Minimum allowed row height
  static Map<int, double> calculateRowHeights({
    required List<Map<String, dynamic>> data,
    required Map<String, TablePlusColumn> columns,
    required TextStyle bodyTextStyle,
    required EdgeInsets bodyPadding,
    required RowHeightMode mode,
    double minRowHeight = 48.0,
  }) {
    if (data.isEmpty) {
      return {};
    }

    // Get only visible columns
    final visibleColumns = columns.values.where((col) => col.visible).toList();

    final rowHeights = <int, double>{};
    final allHeights = <double>[];

    // Calculate height for each row
    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final rowData = data[rowIndex];
      double maxRowHeight = minRowHeight;

      // Check each visible column for this row
      for (final column in visibleColumns) {
        final cellValue = rowData[column.key];
        final cellText = cellValue?.toString() ?? '';

        // Only calculate for TextOverflow.visible columns
        if (column.textOverflow == TextOverflow.visible) {
          final cellHeight = calculateCellHeight(
            text: cellText,
            width: column.width,
            textStyle: bodyTextStyle,
            padding: bodyPadding,
            textOverflow: column.textOverflow,
          );

          maxRowHeight = math.max(maxRowHeight, cellHeight);
        }
      }

      rowHeights[rowIndex] = maxRowHeight;
      allHeights.add(maxRowHeight);
    }

    // For uniform mode, use the maximum height for all rows
    if (mode == RowHeightMode.uniform && allHeights.isNotEmpty) {
      final uniformHeight = allHeights.reduce(math.max);
      for (int i = 0; i < data.length; i++) {
        rowHeights[i] = uniformHeight;
      }
    }

    return rowHeights;
  }

  /// Gets the height of a single line of text with the given style.
  static double _getSingleLineHeight(TextStyle textStyle) {
    // Check cache first
    if (_singleLineHeightCache.containsKey(textStyle)) {
      return _singleLineHeightCache[textStyle]!;
    }

    final textPainter = TextPainter(
      text: TextSpan(
          text: 'Ag', style: textStyle), // Test text with ascenders/descenders
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();
    final height = textPainter.height;

    // Cache the result
    _singleLineHeightCache[textStyle] = height;
    return height;
  }

  /// Checks if any visible column has TextOverflow.visible setting.
  static bool hasVisibleOverflowColumns(Map<String, TablePlusColumn> columns) {
    return columns.values
        .where((col) => col.visible)
        .any((col) => col.textOverflow == TextOverflow.visible);
  }

  /// Clears the internal cache. Useful for memory management in long-running applications.
  static void clearCache() {
    _singleLineHeightCache.clear();
  }
}
