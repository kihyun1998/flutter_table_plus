import 'package:flutter/material.dart';

/// Abstract base class for table row widgets.
/// 
/// This allows for different types of row implementations (normal rows, merged rows, etc.)
/// while maintaining a consistent interface for the ListView builder.
abstract class TablePlusRowWidget extends StatelessWidget {
  const TablePlusRowWidget({super.key});

  /// The number of rows this widget effectively represents in the UI.
  /// - Normal row: 1
  /// - Merged row: 1 (visually appears as one row but may contain data from multiple rows)
  int get effectiveRowCount;

  /// The original data indices that this row widget represents.
  /// - Normal row: [rowIndex]
  /// - Merged row: [index1, index2, index3, ...] for all merged rows
  List<int> get originalDataIndices;

  /// The height this row should occupy.
  /// Can be calculated or fixed depending on the implementation.
  double? get calculatedHeight;

  /// Whether this row represents the last row in the table.
  /// Used for styling purposes (borders, etc.).
  bool get isLastRow;

  /// The background color for this row.
  /// Can vary based on selection state, alternating colors, etc.
  Color get backgroundColor;
}