import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/table_column.dart';
import '../models/theme/checkbox_theme.dart';
import '../models/theme/header_theme.dart' show TablePlusHeaderTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import '../utils/text_overflow_detector.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader extends StatefulWidget {
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
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.checkboxTheme = const TablePlusCheckboxTheme(),
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn> columns;

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

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// The theme configuration for tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// The theme configuration for checkboxes.
  final TablePlusCheckboxTheme checkboxTheme;

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
  /// Track if column reordering is currently active to prevent tooltip positioning errors
  bool _isReordering = false;

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

    // Set reordering state to prevent tooltip positioning errors
    setState(() {
      _isReordering = true;
    });

    // Adjust newIndex if dragging down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

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

    // 사용자 decoration이 있으면 그것을 우선 사용
    if (customDecoration != null) {
      return customDecoration;
    }

    // 없으면 기본 테마 속성들로 BoxDecoration 생성
    return BoxDecoration(
      color: widget.theme.backgroundColor,
      border: widget.theme.showBottomDivider
          ? Border(
              bottom: BorderSide(
                color: widget.theme.dividerColor,
                width: widget.theme.dividerThickness,
              ),
            )
          : null,
    );
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
    final reorderableColumns = _getReorderableColumns();
    final reorderableWidths = _getReorderableColumnWidths(widget.columnWidths);

    return Container(
      height: widget.theme.height,
      width: widget.totalWidth,
      decoration: _buildHeaderDecoration(),
      child: Row(
        children: [
          // Selection column (fixed, non-reorderable)
          if (widget.isSelectable &&
              widget.columns.any((col) => col.key == '__selection__'))
            _SelectionHeaderCell(
              width: widget.selectionTheme
                  .getEffectiveCheckboxColumnWidth(widget.checkboxTheme),
              theme: widget.theme,
              selectionTheme: widget.selectionTheme,
              selectAllState: _getSelectAllState(),
              selectedRows: widget.selectedRows,
              onSelectAll: widget.onSelectAll,
              checkboxTheme: widget.checkboxTheme,
              showSelectAllCheckbox: widget.selectionTheme
                  .getEffectiveShowSelectAllCheckbox(widget.checkboxTheme),
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
    required this.tooltipTheme,
    required this.isSorted,
    required this.sortDirection,
    required this.isReordering,
    this.onSortClick,
  });

  final TablePlusColumn column;
  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool isSorted;
  final SortDirection sortDirection;
  final bool isReordering;
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

  /// Determines whether a tooltip should be shown based on the column's header tooltip behavior.
  bool _shouldShowTooltip(BuildContext context, String label) {
    // Basic checks - tooltip must be enabled and text must not be empty
    if (!tooltipTheme.enabled || label.isEmpty) {
      return false;
    }

    // Disable tooltips during column reordering to prevent positioning errors
    if (isReordering) {
      return false;
    }

    switch (column.headerTooltipBehavior) {
      case TooltipBehavior.never:
        return false;

      case TooltipBehavior.always:
        return true;

      case TooltipBehavior.onlyTextOverflow:
        // Calculate available width for the header text
        final padding = theme.padding;
        final sortIconWidth = column.sortable && onSortClick != null
            ? 24.0
            : 0.0; // Approximate sort icon width
        final availableWidth = width - padding.horizontal - sortIconWidth;

        // Use TextOverflowDetector to check if text would overflow
        return TextOverflowDetector.willTextOverflowInContext(
          context: context,
          text: label,
          maxWidth: availableWidth,
          style: theme.textStyle,
        );
    }
  }

  /// Build header text widget with optional tooltip
  Widget _buildHeaderText(BuildContext context, TextStyle textStyle) {
    Widget textWidget = Text(
      column.label,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
      textAlign: column.textAlign,
    );

    // Add tooltip based on tooltip behavior
    if (_shouldShowTooltip(context, column.label)) {
      try {
        textWidget = Tooltip(
          message: column.label,
          textStyle: tooltipTheme.textStyle,
          decoration: tooltipTheme.decoration,
          padding: tooltipTheme.padding,
          margin: tooltipTheme.margin,
          waitDuration: tooltipTheme.waitDuration,
          showDuration: tooltipTheme.showDuration,
          preferBelow: tooltipTheme.preferBelow,
          child: textWidget,
        );
      } catch (e) {
        // Ignore tooltip creation errors during reordering - tooltip will be restored on next rebuild
      }
    }

    return textWidget;
  }

  /// Build decoration for individual header cell
  Decoration _buildCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    // cellDecoration이 있으면 그것을 우선 사용
    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    // 없으면 기본 테마 속성들로 BoxDecoration 생성
    return BoxDecoration(
      color: _getBackgroundColor(),
      border: theme.showVerticalDividers
          ? Border(
              right: BorderSide(
                color: theme.dividerColor,
                width: theme.dividerThickness,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortIcon = _getSortIcon();
    final textStyle = _getTextStyle();

    Widget content = Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: _buildCellDecoration(),
      child: Align(
        alignment: column.alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Column label
            Flexible(
              child: _buildHeaderText(context, textStyle),
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
    required this.checkboxTheme,
    this.showSelectAllCheckbox = true,
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;
  final TablePlusCheckboxTheme checkboxTheme;
  final bool showSelectAllCheckbox;

  /// Build decoration for selection header cell
  Decoration _buildSelectionCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    // cellDecoration이 있으면 그것을 우선 사용
    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    // 없으면 기본 테마 속성들로 BoxDecoration 생성
    return BoxDecoration(
      color: theme.backgroundColor,
      border: theme.showVerticalDividers
          ? Border(
              right: BorderSide(
                color: theme.dividerColor,
                width: theme.dividerThickness,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: _buildSelectionCellDecoration(),
      child: showSelectAllCheckbox
          ? Center(
              child: SizedBox(
                width: selectionTheme.getEffectiveCheckboxSize(checkboxTheme),
                height: selectionTheme.getEffectiveCheckboxSize(checkboxTheme),
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
                  // Use deprecated properties if available, otherwise fall back to checkboxTheme
                  activeColor: selectionTheme
                      .getEffectiveCheckboxActiveColor(checkboxTheme),
                  hoverColor: selectionTheme
                      .getEffectiveCheckboxHoverColor(checkboxTheme),
                  focusColor: selectionTheme
                      .getEffectiveCheckboxFocusColor(checkboxTheme),
                  fillColor: selectionTheme
                      .getEffectiveCheckboxFillColor(checkboxTheme),
                  checkColor: checkboxTheme.checkColor,
                  side: selectionTheme.getEffectiveCheckboxSide(checkboxTheme),
                  shape: checkboxTheme.shape,
                  mouseCursor: checkboxTheme.mouseCursor,
                  materialTapTargetSize: checkboxTheme.materialTapTargetSize ??
                      MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      checkboxTheme.visualDensity ?? VisualDensity.compact,
                  splashRadius: checkboxTheme.splashRadius,
                  overlayColor: checkboxTheme.overlayColor,
                ),
              ),
            )
          : const SizedBox.shrink(), // Empty space when checkbox is hidden
    );
  }
}
