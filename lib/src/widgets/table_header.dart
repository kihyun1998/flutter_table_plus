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
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.totalRowCount = 0,
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn> columns;

  /// The total width available for the table.
  final double totalWidth;

  /// The theme configuration for the header.
  final TablePlusHeaderTheme theme;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The selection mode for the table.
  final SelectionMode selectionMode;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The order in which sort directions cycle.
  final SortCycleOrder sortCycleOrder;

  /// The total number of rows in the table.
  final int totalRowCount;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when the select-all state changes.
  final void Function(bool selectAll)? onSelectAll;

  /// Callback when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// The key of the currently sorted column.
  final String? sortColumnKey;

  /// The current sort direction for the sorted column.
  final SortDirection sortDirection;

  /// Callback when a sortable column header is clicked.
  final void Function(String columnKey, SortDirection direction)? onSort;

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

  /// Handle sort click for a column
  void _handleSortClick(String columnKey) {
    if (widget.onSort == null) return;

    // Determine next sort direction based on cycle order
    SortDirection nextDirection;
    if (widget.sortColumnKey == columnKey) {
      // Same column - cycle through directions based on sortCycleOrder
      if (widget.sortCycleOrder == SortCycleOrder.ascendingFirst) {
        // none -> ascending -> descending -> none
        switch (widget.sortDirection) {
          case SortDirection.none:
            nextDirection = SortDirection.ascending;
            break;
          case SortDirection.ascending:
            nextDirection = SortDirection.descending;
            break;
          case SortDirection.descending:
            nextDirection = SortDirection.none;
            break;
        }
      } else {
        // none -> descending -> ascending -> none
        switch (widget.sortDirection) {
          case SortDirection.none:
            nextDirection = SortDirection.descending;
            break;
          case SortDirection.descending:
            nextDirection = SortDirection.ascending;
            break;
          case SortDirection.ascending:
            nextDirection = SortDirection.none;
            break;
        }
      }
    } else {
      // Different column - start based on sortCycleOrder
      nextDirection = widget.sortCycleOrder == SortCycleOrder.ascendingFirst
          ? SortDirection.ascending
          : SortDirection.descending;
    }

    widget.onSort!(columnKey, nextDirection);
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
                      width: widget.theme.dividerThickness,
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
              showSelectAllCheckbox:
                  widget.selectionTheme.showSelectAllCheckbox,
            ),

          // Reorderable or non-reorderable columns
          if (reorderableColumns.isNotEmpty)
            Expanded(
              child: SizedBox(
                height: widget.theme.height,
                child: widget.onColumnReorder != null
                    ? ReorderableListView.builder(
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
                              isSorted: widget.sortColumnKey == column.key,
                              sortDirection: widget.sortColumnKey == column.key
                                  ? widget.sortDirection
                                  : SortDirection.none,
                              onSortClick:
                                  column.sortable && widget.onSort != null
                                      ? () => _handleSortClick(column.key)
                                      : null,
                            ),
                          );
                        },
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              reorderableColumns.asMap().entries.map((entry) {
                            final index = entry.key;
                            final column = entry.value;
                            final width = reorderableWidths.isNotEmpty
                                ? reorderableWidths[index]
                                : column.width;

                            return _HeaderCell(
                              column: column,
                              width: width,
                              theme: widget.theme,
                              isSorted: widget.sortColumnKey == column.key,
                              sortDirection: widget.sortColumnKey == column.key
                                  ? widget.sortDirection
                                  : SortDirection.none,
                              onSortClick:
                                  column.sortable && widget.onSort != null
                                      ? () => _handleSortClick(column.key)
                                      : null,
                            );
                          }).toList(),
                        ),
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
    required this.isSorted,
    required this.sortDirection,
    this.onSortClick,
  });

  final TablePlusColumn column;
  final double width;
  final TablePlusHeaderTheme theme;
  final bool isSorted;
  final SortDirection sortDirection;
  final VoidCallback? onSortClick;

  /// Get the sort icon widget for current state
  Widget? _getSortIcon() {
    if (!column.sortable || onSortClick == null) return null;

    switch (sortDirection) {
      case SortDirection.ascending:
        return theme.sortIcons.ascending;
      case SortDirection.descending:
        return theme.sortIcons.descending;
      case SortDirection.none:
        return theme.sortIcons.unsorted;
    }
  }

  /// Get the background color for this header cell
  Color _getBackgroundColor() {
    if (isSorted && theme.sortedColumnBackgroundColor != null) {
      return theme.sortedColumnBackgroundColor!;
    }
    return theme.backgroundColor;
  }

  /// Get the text style for this header cell
  TextStyle _getTextStyle() {
    if (isSorted && theme.sortedColumnTextStyle != null) {
      return theme.sortedColumnTextStyle!;
    }
    return theme.textStyle;
  }

  @override
  Widget build(BuildContext context) {
    final sortIcon = _getSortIcon();
    final backgroundColor = _getBackgroundColor();
    final textStyle = _getTextStyle();

    Widget content = Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Align(
        alignment: column.alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Column label
            Flexible(
              child: Text(
                column.label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                textAlign: column.textAlign,
              ),
            ),

            // Sort icon
            if (sortIcon != null) ...[
              SizedBox(width: theme.sortIconSpacing),
              sortIcon,
            ],
          ],
        ),
      ),
    );

    // Wrap with GestureDetector for sortable columns
    if (column.sortable && onSortClick != null) {
      return GestureDetector(
        onTap: onSortClick,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }

    return content;
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
    this.showSelectAllCheckbox = true,
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;
  final bool showSelectAllCheckbox;

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
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: showSelectAllCheckbox
          ? Center(
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
            )
          : const SizedBox.shrink(), // Empty space when checkbox is hidden
    );
  }
}
