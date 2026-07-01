import 'package:flutter/material.dart';

/// Abstract base class for table row widgets.
///
/// This allows for different types of row implementations (normal rows, merged rows, etc.)
/// while maintaining a consistent interface for the ListView builder.
abstract class TablePlusRowWidget extends StatefulWidget {
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

  /// Whether the table is in cell-editing mode (row selection is suppressed).
  bool get isEditable;

  /// Whether row selection is enabled.
  bool get isSelectable;

  /// The identifier this row toggles when tapped for selection: the row id for
  /// a normal row, the group id for a merged row. `null` when the row has no
  /// stable id (selection is then a no-op).
  String? get selectionId;

  /// Invoked with [selectionId] to toggle this row's selection.
  void Function(String id) get onRowSelectionChanged;

  /// Shared row-tap selection gating for every row type. A tap selects only
  /// when selection is enabled, the table is not editing, and the row has an
  /// id — otherwise it is a no-op.
  void handleSelectionTap() {
    if (isEditable || !isSelectable) return;
    final id = selectionId;
    if (id == null) return;
    onRowSelectionChanged(id);
  }
}
