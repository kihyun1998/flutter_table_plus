import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/merged_row_group.dart';
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

    // For visible overflow, calculate exact text height without extra spacing
    if (text.trim().isEmpty) {
      return padding.vertical;
    }

    // Calculate available width for text (subtract horizontal padding)
    final availableWidth = math.max(0.0, width - padding.horizontal);

    if (availableWidth <= 0) {
      return _getSingleLineHeight(textStyle) + padding.vertical;
    }

    // Create TextPainter with StrutStyle for accurate height calculation
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle.fromTextStyle(textStyle),
    );

    // Layout with available width and proper constraints
    textPainter.layout(
      minWidth: 0,
      maxWidth: availableWidth,
    );

    // Return TextPainter height directly for most accurate result
    // This includes proper line metrics with StrutStyle consideration
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

  /// Calculates row heights considering merged groups.
  ///
  /// This function first calculates individual row heights, then ensures that all rows
  /// within the same merged group have the same height (the maximum height within the group).
  ///
  /// [data] - Table data
  /// [columns] - Column definitions
  /// [mergedGroups] - List of merged row groups
  /// [bodyTextStyle] - Default text style for body cells
  /// [bodyPadding] - Default padding for body cells
  /// [mode] - Height calculation mode (uniform or dynamic)
  /// [rowIdKey] - Key used to identify rows (default: 'id')
  /// [minRowHeight] - Minimum allowed row height
  static Map<int, double> calculateMergedRowHeights({
    required List<Map<String, dynamic>> data,
    required Map<String, TablePlusColumn> columns,
    required List<MergedRowGroup> mergedGroups,
    required TextStyle bodyTextStyle,
    required EdgeInsets bodyPadding,
    required RowHeightMode mode,
    String rowIdKey = 'id',
    double minRowHeight = 48.0,
  }) {
    if (data.isEmpty) {
      return {};
    }

    // Step 1: Calculate individual row heights using existing logic
    final individualHeights = calculateRowHeights(
      data: data,
      columns: columns,
      bodyTextStyle: bodyTextStyle,
      bodyPadding: bodyPadding,
      mode: mode,
      minRowHeight: minRowHeight,
    );

    // Step 2: Process merged groups to ensure uniform heights within each group
    for (final group in mergedGroups) {
      double maxGroupHeight = minRowHeight;
      final groupRowIndices = <int>[];

      // Find all row indices in this group and determine the maximum height
      for (final rowKey in group.rowKeys) {
        final rowIndex =
            data.indexWhere((row) => row[rowIdKey]?.toString() == rowKey);
        if (rowIndex != -1) {
          groupRowIndices.add(rowIndex);
          if (individualHeights.containsKey(rowIndex)) {
            maxGroupHeight =
                math.max(maxGroupHeight, individualHeights[rowIndex]!);
          }
        }
      }

      // Apply the maximum height to all rows in this group
      for (final rowIndex in groupRowIndices) {
        individualHeights[rowIndex] = maxGroupHeight;
      }
    }

    return individualHeights;
  }

  /// Clears the internal cache. Useful for memory management in long-running applications.
  static void clearCache() {
    _singleLineHeightCache.clear();
  }
}
