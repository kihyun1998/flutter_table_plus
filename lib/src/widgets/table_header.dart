import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader extends StatelessWidget {
  /// Creates a [TablePlusHeader] with the specified configuration.
  const TablePlusHeader({
    super.key,
    required this.columns,
    required this.totalWidth,
    required this.theme,
    this.isSelectable = false,
    this.selectedRows = const <String>{},
    this.totalRowCount = 0,
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onSelectAll,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn> columns;

  /// The total width available for the table.
  final double totalWidth;

  /// The theme configuration for the header.
  final TablePlusHeaderTheme theme;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The total number of rows in the table.
  final int totalRowCount;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when the select-all state changes.
  final void Function(bool selectAll)? onSelectAll;

  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths() {
    if (columns.isEmpty) return [];

    // Separate selection column from regular columns
    List<TablePlusColumn> regularColumns = [];
    TablePlusColumn? selectionColumn;

    for (final column in columns) {
      if (column.key == '__selection__') {
        selectionColumn = column;
      } else {
        regularColumns.add(column);
      }
    }

    // Calculate available width for regular columns (excluding selection column)
    double availableWidth = totalWidth;
    if (selectionColumn != null) {
      availableWidth -=
          selectionColumn.width; // Subtract fixed selection column width
    }

    // Calculate widths for regular columns only
    List<double> regularWidths =
        _calculateRegularColumnWidths(regularColumns, availableWidth);

    // Combine selection column width with regular column widths
    List<double> allWidths = [];
    int regularIndex = 0;

    for (final column in columns) {
      if (column.key == '__selection__') {
        allWidths.add(column.width); // Fixed width for selection
      } else {
        allWidths.add(regularWidths[regularIndex]);
        regularIndex++;
      }
    }

    return allWidths;
  }

  /// Calculate widths for regular columns (excluding selection column)
  List<double> _calculateRegularColumnWidths(
      List<TablePlusColumn> columns, double totalWidth) {
    if (columns.isEmpty) return [];

    // Calculate total preferred width
    final double totalPreferredWidth = columns.fold(
      0.0,
      (sum, col) => sum + col.width,
    );

    // Calculate total minimum width
    final double totalMinWidth = columns.fold(
      0.0,
      (sum, col) => sum + col.minWidth,
    );

    List<double> widths = [];

    if (totalPreferredWidth <= totalWidth) {
      // If preferred widths fit, distribute extra space proportionally
      final double extraSpace = totalWidth - totalPreferredWidth;
      final double totalWeight = columns.length.toDouble();

      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
        final double extraWidth = extraSpace / totalWeight;
        double finalWidth = column.width + extraWidth;

        // Respect maximum width if specified
        if (column.maxWidth != null && finalWidth > column.maxWidth!) {
          finalWidth = column.maxWidth!;
        }

        widths.add(finalWidth);
      }
    } else if (totalMinWidth <= totalWidth) {
      // Scale down proportionally but respect minimum widths
      final double scale = totalWidth / totalPreferredWidth;

      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
        final double scaledWidth = column.width * scale;
        final double finalWidth = scaledWidth.clamp(
            column.minWidth, column.maxWidth ?? double.infinity);
        widths.add(finalWidth);
      }
    } else {
      // Use minimum widths (table will be wider than available space)
      widths = columns.map((col) => col.minWidth).toList();
    }

    return widths;
  }

  /// Determine the state of the select-all checkbox.
  bool? _getSelectAllState() {
    if (totalRowCount == 0) return false;
    if (selectedRows.isEmpty) return false;
    if (selectedRows.length == totalRowCount) return true;
    return null; // Indeterminate state
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = _calculateColumnWidths();

    return Container(
      height: theme.height,
      width: totalWidth,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: theme.decoration != null
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width =
              columnWidths.isNotEmpty ? columnWidths[index] : column.width;

          // Special handling for selection column
          if (isSelectable && column.key == '__selection__') {
            return _SelectionHeaderCell(
              width: width,
              theme: theme,
              selectionTheme: selectionTheme,
              selectAllState: _getSelectAllState(),
              selectedRows: selectedRows,
              onSelectAll: onSelectAll,
            );
          }

          return _HeaderCell(
            column: column,
            width: width,
            theme: theme,
          );
        }),
      ),
    );
  }
}

/// A single header cell widget.
class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.width,
    required this.theme,
  });

  final TablePlusColumn column;
  final double width;
  final TablePlusHeaderTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Align(
        alignment: column.alignment,
        child: Text(
          column.label,
          style: theme.textStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: column.textAlign,
        ),
      ),
    );
  }
}

/// A header cell with select-all checkbox.
class _SelectionHeaderCell extends StatelessWidget {
  const _SelectionHeaderCell({
    required this.width,
    required this.theme,
    required this.selectionTheme,
    required this.selectAllState,
    required this.onSelectAll,
    required this.selectedRows,
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: selectionTheme.checkboxSize,
          height: selectionTheme.checkboxSize,
          child: Checkbox(
            value: selectAllState,
            tristate: true, // Allows indeterminate state
            onChanged: onSelectAll != null
                ? (value) {
                    // Improved logic: if any rows are selected, deselect all
                    // If no rows are selected, select all
                    final shouldSelectAll = selectedRows.isEmpty;
                    onSelectAll!(shouldSelectAll);
                  }
                : null,
            activeColor: selectionTheme.checkboxColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
