import 'dart:async';

import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/theme/checkbox_theme.dart';
import '../models/theme/header_theme.dart';
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../utils/column_width_access.dart';
import '../utils/select_all_state.dart';
import '../utils/sort_cycle.dart';
import 'table_header_cell.dart';
import 'table_resize_handle.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader<T> extends StatefulWidget {
  /// Creates a [TablePlusHeader] with the specified configuration.
  const TablePlusHeader({
    super.key,
    required this.columns,
    required this.columnWidths,
    required this.totalWidth,
    required this.theme,
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.totalRowCount = 0,
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.checkboxTheme = const TablePlusCheckboxTheme(),
    this.onSelectAll,
    this.onColumnReorder,
    this.resizable = false,
    this.onColumnResize,
    this.onColumnResizeEnd,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.onColumnAutoFit,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn<T>> columns;

  /// The calculated width for each column.
  final List<double> columnWidths;

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

  /// The theme configuration for tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// The theme configuration for checkboxes.
  final TablePlusCheckboxTheme checkboxTheme;

  /// Callback when the select-all state changes.
  final void Function(bool selectAll)? onSelectAll;

  /// Callback when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// Whether columns can be resized by dragging their header edges.
  final bool resizable;

  /// Callback during column resize drag with live width updates.
  final void Function(String columnKey, double newWidth)? onColumnResize;

  /// Callback when column resize drag ends.
  final void Function(String columnKey, double finalWidth)? onColumnResizeEnd;

  /// The key of the currently sorted column.
  final String? sortColumnKey;

  /// The current sort direction for the sorted column.
  final SortDirection sortDirection;

  /// Callback when a sortable column header is clicked.
  final void Function(String columnKey, SortDirection direction)? onSort;

  /// Callback when a column resize handle is double-tapped for auto-fit.
  final void Function(String columnKey)? onColumnAutoFit;

  @override
  State<TablePlusHeader<T>> createState() => _TablePlusHeaderState<T>();
}

class _TablePlusHeaderState<T> extends State<TablePlusHeader<T>> {
  /// Track if column reordering is currently active to prevent tooltip positioning errors
  bool _isReordering = false;

  /// Determine the state of the select-all checkbox.
  bool? _getSelectAllState() => selectAllState(
        total: widget.totalRowCount,
        selectedCount: widget.selectedRows.length,
      );

  /// Handle column reorder
  void _handleColumnReorder(int oldIndex, int newIndex) {
    if (widget.onColumnReorder == null) return;
    if (oldIndex == newIndex) return;

    // Set reordering state to prevent tooltip positioning errors
    setState(() {
      _isReordering = true;
    });

    widget.onColumnReorder!(oldIndex, newIndex);

    // Reset reordering state after a brief delay to allow layout to stabilize
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isReordering = false;
        });
      }
    });
  }

  /// Build decoration for the main header container
  Decoration _buildHeaderDecoration() {
    final customDecoration = widget.theme.decoration;

    if (customDecoration != null) {
      return customDecoration;
    }

    final topBorder = widget.theme.topBorder;
    final bottomBorder = widget.theme.bottomBorder;
    final hasAnyBorder = topBorder.show || bottomBorder.show;

    return BoxDecoration(
      color: widget.theme.backgroundColor,
      border: hasAnyBorder
          ? Border(
              top: topBorder.show
                  ? BorderSide(
                      color: topBorder.color,
                      width: topBorder.thickness,
                    )
                  : BorderSide.none,
              bottom: bottomBorder.show
                  ? BorderSide(
                      color: bottomBorder.color,
                      width: bottomBorder.thickness,
                    )
                  : BorderSide.none,
            )
          : null,
    );
  }

  /// Handle sort click for a column
  void _handleSortClick(String columnKey) {
    if (widget.onSort == null) return;

    final nextDirection = nextSortDirection(
      current: widget.sortDirection,
      tappedKey: columnKey,
      sortedKey: widget.sortColumnKey,
      cycle: widget.sortCycleOrder,
    );

    widget.onSort!(columnKey, nextDirection);
  }

  @override
  Widget build(BuildContext context) {
    // Count reorderable columns (non-selection) for trailing drop target
    final reorderableCount =
        widget.columns.where((col) => col.key != '__selection__').length;

    Widget content = Row(
      children: [
        ...() {
          int reorderIndex = 0;
          return widget.columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            final width = widget.columnWidths.widthAt(index, column);

            // Selection column (non-reorderable)
            if (widget.isSelectable && column.key == '__selection__') {
              return SelectionHeaderCell(
                width: width,
                theme: widget.theme,
                selectAllState: _getSelectAllState(),
                selectedRows: widget.selectedRows,
                onSelectAll: widget.onSelectAll,
                checkboxTheme: widget.checkboxTheme,
                showSelectAllCheckbox:
                    widget.checkboxTheme.showSelectAllCheckbox,
              );
            }

            final currentReorderIndex = reorderIndex;
            reorderIndex++;

            final headerCell = HeaderCell(
              column: column,
              width: width,
              theme: widget.theme,
              tooltipTheme: widget.tooltipTheme,
              isSorted: widget.sortColumnKey == column.key,
              sortDirection: widget.sortColumnKey == column.key
                  ? widget.sortDirection
                  : SortDirection.none,
              isReordering: _isReordering,
              onSortClick: column.sortable &&
                      widget.onSort != null &&
                      widget.totalRowCount > 0
                  ? () => _handleSortClick(column.key)
                  : null,
            );

            Widget result = headerCell;

            if (widget.onColumnReorder != null) {
              result = Draggable<int>(
                data: currentReorderIndex,
                axis: Axis.horizontal,
                feedback: Material(
                  elevation: 4,
                  child: HeaderCell(
                    column: column,
                    width: width,
                    theme: widget.theme,
                    tooltipTheme: widget.tooltipTheme,
                    isSorted: widget.sortColumnKey == column.key,
                    sortDirection: widget.sortColumnKey == column.key
                        ? widget.sortDirection
                        : SortDirection.none,
                    isReordering: true,
                    showDivider: false,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: headerCell,
                ),
                child: DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    _handleColumnReorder(details.data, currentReorderIndex);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return headerCell;
                  },
                ),
              );
            }

            return result;
          });
        }(),

        // Trailing drop zone: covers empty space right of the last column.
        // Dropping here reorders the dragged column to the last position.
        if (widget.onColumnReorder != null && reorderableCount > 0)
          Expanded(
            child: DragTarget<int>(
              onAcceptWithDetails: (details) {
                _handleColumnReorder(details.data, reorderableCount - 1);
              },
              builder: (context, candidateData, rejectedData) {
                return SizedBox(height: widget.theme.height);
              },
            ),
          ),
      ],
    );

    // Overlay resize handles centered on column boundaries
    if (widget.resizable) {
      final handles = <Widget>[];
      double cumulativeWidth = 0;
      final handleWidth = widget.theme.resizeHandle.width;
      final handleColor =
          widget.theme.resizeHandle.color ?? widget.theme.verticalDivider.color;

      for (int i = 0; i < widget.columns.length; i++) {
        final column = widget.columns[i];
        final width = widget.columnWidths.widthAt(i, column);
        cumulativeWidth += width;

        // Skip selection column — not resizable
        if (widget.isSelectable && column.key == '__selection__') continue;

        handles.add(
          Positioned(
            key: ValueKey('resize_${column.key}'),
            left: cumulativeWidth - handleWidth / 2,
            top: 0,
            bottom: 0,
            width: handleWidth,
            child: ResizeHandle(
              columnKey: column.key,
              columnWidth: width,
              minWidth: column.minWidth,
              maxWidth: column.maxWidth,
              handleColor: handleColor,
              handleThickness: widget.theme.resizeHandle.thickness,
              handleIndent: widget.theme.resizeHandle.indent,
              handleEndIndent: widget.theme.resizeHandle.endIndent,
              onResize: widget.onColumnResize,
              onResizeEnd: widget.onColumnResizeEnd,
              onDoubleTap: widget.onColumnAutoFit != null
                  ? () => widget.onColumnAutoFit!(column.key)
                  : null,
            ),
          ),
        );
      }

      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          ...handles,
        ],
      );
    }

    return Container(
      height: widget.theme.height,
      width: widget.totalWidth,
      decoration: _buildHeaderDecoration(),
      child: content,
    );
  }
}
