import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader extends StatefulWidget {
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
    this.onColumnReorder,
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

  /// Callback when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  @override
  State<TablePlusHeader> createState() => _TablePlusHeaderState();
}

class _TablePlusHeaderState extends State<TablePlusHeader> {
  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths() {
    if (widget.columns.isEmpty) return [];

    // Separate selection column from regular columns
    List<TablePlusColumn> regularColumns = [];
    TablePlusColumn? selectionColumn;

    for (final column in widget.columns) {
      if (column.key == '__selection__') {
        selectionColumn = column;
      } else {
        regularColumns.add(column);
      }
    }

    // Calculate available width for regular columns (excluding selection column)
    double availableWidth = widget.totalWidth;
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

    for (final column in widget.columns) {
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
    if (widget.totalRowCount == 0) return false;
    if (widget.selectedRows.isEmpty) return false;
    if (widget.selectedRows.length == widget.totalRowCount) return true;
    return null; // Indeterminate state
  }

  /// Get reorderable columns (excludes selection column)
  List<TablePlusColumn> _getReorderableColumns() {
    return widget.columns
        .where((column) => column.key != '__selection__')
        .toList();
  }

  /// Get reorderable column widths (excludes selection column width)
  List<double> _getReorderableColumnWidths(List<double> allWidths) {
    List<double> reorderableWidths = [];
    for (int i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].key != '__selection__') {
        reorderableWidths.add(allWidths[i]);
      }
    }
    return reorderableWidths;
  }

  /// Handle column reorder
  void _handleColumnReorder(int oldIndex, int newIndex) {
    if (widget.onColumnReorder == null) return;

    // Adjust newIndex if dragging down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    widget.onColumnReorder!(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = _calculateColumnWidths();
    final reorderableColumns = _getReorderableColumns();
    final reorderableWidths = _getReorderableColumnWidths(columnWidths);

    return Container(
      height: widget.theme.height,
      width: widget.totalWidth,
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        border: widget.theme.decoration != null
            ? null
            : (widget.theme.showBottomDivider
                ? Border(
                    bottom: BorderSide(
                      color: widget.theme.dividerColor,
                      width: 1.0,
                    ),
                  )
                : null),
      ),
      child: Row(
        children: [
          // Selection column (fixed, non-reorderable)
          if (widget.isSelectable &&
              widget.columns.any((col) => col.key == '__selection__'))
            _SelectionHeaderCell(
              width: widget.selectionTheme.checkboxColumnWidth,
              theme: widget.theme,
              selectionTheme: widget.selectionTheme,
              selectAllState: _getSelectAllState(),
              selectedRows: widget.selectedRows,
              onSelectAll: widget.onSelectAll,
            ),

          // Reorderable columns
          if (reorderableColumns.isNotEmpty)
            Expanded(
              child: SizedBox(
                height: widget.theme.height,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles:
                      false, // Disable default drag handles
                  onReorder: _handleColumnReorder,
                  itemCount: reorderableColumns.length,
                  itemBuilder: (context, index) {
                    final column = reorderableColumns[index];
                    final width = reorderableWidths.isNotEmpty
                        ? reorderableWidths[index]
                        : column.width;

                    return ReorderableDragStartListener(
                      key: ValueKey(column.key),
                      index: index,
                      child: _HeaderCell(
                        column: column,
                        width: width,
                        theme: widget.theme,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
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
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              )
            : null,
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
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              )
            : null,
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
