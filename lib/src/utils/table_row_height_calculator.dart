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
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  /// 
  /// Returns the calculated height needed to display the text.
  static double calculateTextHeight({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
    TextAlign textAlign = TextAlign.start,
    double minHeight = 48.0,
  }) {
    if (text.isEmpty || maxWidth <= 0) {
      return minHeight;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: null,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    
    // Add some padding for cell content
    const double verticalPadding = 16.0; // Default cell padding
    final calculatedHeight = textPainter.height + verticalPadding;
    
    return math.max(minHeight, calculatedHeight);
  }

  /// Calculate the height needed for a table row based on its content.
  /// 
  /// This method examines all text columns in the row and returns the
  /// height needed to accommodate the tallest cell.
  /// 
  /// Parameters:
  /// - [rowData]: The data for this row
  /// - [columns]: List of table columns
  /// - [columnWidths]: List of calculated column widths
  /// - [defaultTextStyle]: Default text style for cells
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  /// 
  /// Returns the calculated height needed for the entire row.
  static double calculateRowHeight({
    required Map<String, dynamic> rowData,
    required List<TablePlusColumn> columns,
    required List<double> columnWidths,
    required TextStyle defaultTextStyle,
    double minHeight = 48.0,
  }) {
    double maxHeight = minHeight;

    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];
      
      // Skip columns with custom cell builders (can't calculate height)
      if (column.cellBuilder != null) continue;
      
      // Skip if TextOverflow is not visible (no dynamic height needed)
      if (column.textOverflow != TextOverflow.visible) continue;
      
      final cellValue = rowData[column.key];
      if (cellValue == null) continue;
      
      final text = cellValue.toString();
      if (text.isEmpty) continue;
      
      final columnWidth = columnWidths.isNotEmpty ? columnWidths[i] : column.width;
      
      // Account for cell padding when calculating available text width
      const double horizontalPadding = 32.0; // Default cell horizontal padding
      final availableTextWidth = columnWidth - horizontalPadding;
      
      if (availableTextWidth <= 0) continue;
      
      final cellHeight = calculateTextHeight(
        text: text,
        textStyle: defaultTextStyle,
        maxWidth: availableTextWidth,
        textAlign: column.textAlign,
        minHeight: minHeight,
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
  /// - [minHeight]: Minimum height to return (defaults to 48.0)
  /// 
  /// Returns a function that can be used as FlutterTablePlus.calculateRowHeight
  static double? Function(int, Map<String, dynamic>) createHeightCalculator({
    required List<TablePlusColumn> columns,
    required List<double> columnWidths,
    required TextStyle defaultTextStyle,
    double minHeight = 48.0,
  }) {
    return (int rowIndex, Map<String, dynamic> rowData) {
      return calculateRowHeight(
        rowData: rowData,
        columns: columns,
        columnWidths: columnWidths,
        defaultTextStyle: defaultTextStyle,
        minHeight: minHeight,
      );
    };
  }
}