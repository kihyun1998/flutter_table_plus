import 'dart:async';

import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/theme/checkbox_theme.dart';
import '../models/theme/header_theme.dart';
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import '../utils/text_overflow_detector.dart';
import 'flutter_tooltip_plus.dart';

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
  bool? _getSelectAllState() {
    if (widget.totalRowCount == 0) return false;
    if (widget.selectedRows.isEmpty) return false;
    if (widget.selectedRows.length == widget.totalRowCount) return true;
    return null; // Indeterminate state
  }

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
    Widget content = Row(
      children: [
        ...() {
          int reorderIndex = 0;
          return widget.columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            final width = widget.columnWidths.isNotEmpty
                ? widget.columnWidths[index]
                : column.width;

            // Selection column (non-reorderable)
            if (widget.isSelectable && column.key == '__selection__') {
              return _SelectionHeaderCell(
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

            final headerCell = _HeaderCell(
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
                  child: _HeaderCell(
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
        final width = widget.columnWidths.isNotEmpty
            ? widget.columnWidths[i]
            : column.width;
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
            child: _ResizeHandle(
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
    this.showDivider = true,
  });

  final TablePlusColumn<dynamic> column;
  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool isSorted;
  final SortDirection sortDirection;
  final bool isReordering;
  final VoidCallback? onSortClick;

  /// Whether to show the vertical divider on the right edge.
  /// Set to `false` for drag feedback to avoid rendering the divider on the floating cell.
  final bool showDivider;

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
    if (!tooltipTheme.enabled || label.isEmpty) {
      return false;
    }

    if (isReordering) {
      return false;
    }

    switch (column.headerTooltipBehavior) {
      case TooltipBehavior.never:
        return false;

      case TooltipBehavior.always:
        return true;

      case TooltipBehavior.onlyTextOverflow:
        final padding = theme.padding;
        final sortIconArea = _getSortIcon() != null
            ? theme.sortIconSpacing + theme.sortIconWidth
            : 0.0;
        final availableWidth = width - padding.horizontal - sortIconArea;

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

    if (_shouldShowTooltip(context, column.label)) {
      try {
        textWidget = FlutterTooltipPlus(
          message: column.label,
          theme: tooltipTheme,
          child: textWidget,
        );
      } catch (e) {
        // Ignore tooltip creation errors during reordering
      }
    }

    return textWidget;
  }

  /// Build decoration for individual header cell
  Decoration _buildCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    return BoxDecoration(
      color: _getBackgroundColor(),
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
              SizedBox(width: theme.sortIconWidth, child: sortIcon),
            ],
          ],
        ),
      ),
    );

    // Overlay vertical divider with indent support
    final divider = theme.verticalDivider;
    if (showDivider && divider.show) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: 0,
            top: divider.indent,
            bottom: divider.endIndent,
            child: SizedBox(
              width: divider.thickness,
              child: ColoredBox(color: divider.color),
            ),
          ),
        ],
      );
    }

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
    required this.selectAllState,
    required this.onSelectAll,
    required this.selectedRows,
    required this.checkboxTheme,
    this.showSelectAllCheckbox = true,
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;
  final TablePlusCheckboxTheme checkboxTheme;
  final bool showSelectAllCheckbox;

  /// Build decoration for selection header cell
  Decoration _buildSelectionCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    return BoxDecoration(
      color: theme.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: _buildSelectionCellDecoration(),
      child: showSelectAllCheckbox && onSelectAll != null
          ? Center(
              child: SizedBox(
                width: checkboxTheme.tapTargetSize ?? checkboxTheme.size,
                height: checkboxTheme.tapTargetSize ?? checkboxTheme.size,
                child: Checkbox(
                  value: selectAllState,
                  tristate: true, // Allows indeterminate state
                  onChanged: onSelectAll != null
                      ? (value) {
                          final shouldSelectAll = selectedRows.isEmpty;
                          onSelectAll!(shouldSelectAll);
                        }
                      : null,
                  activeColor:
                      checkboxTheme.fillColor?.resolve({WidgetState.selected}),
                  hoverColor: checkboxTheme.hoverColor,
                  focusColor: checkboxTheme.focusColor,
                  fillColor: checkboxTheme.fillColor,
                  checkColor: checkboxTheme.checkColor,
                  side: checkboxTheme.side,
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
          : const SizedBox.shrink(),
    );

    // Overlay vertical divider with indent support
    final divider = theme.verticalDivider;
    if (divider.show) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: 0,
            top: divider.indent,
            bottom: divider.endIndent,
            child: SizedBox(
              width: divider.thickness,
              child: ColoredBox(color: divider.color),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// An overlay resize handle widget centered on a column boundary.
///
/// Positioned by the parent [Stack] at each column's right edge.
/// On hover, a centered indicator line appears. Horizontal drag gestures
/// resize the column in real-time with auto-scroll support.
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.columnKey,
    required this.columnWidth,
    required this.minWidth,
    required this.handleColor,
    this.handleThickness = 2.0,
    this.handleIndent = 0.0,
    this.handleEndIndent = 0.0,
    this.maxWidth,
    this.onResize,
    this.onResizeEnd,
    this.onDoubleTap,
  });

  final String columnKey;
  final double columnWidth;
  final double minWidth;
  final double? maxWidth;
  final Color handleColor;
  final double handleThickness;
  final double handleIndent;
  final double handleEndIndent;
  final void Function(String columnKey, double newWidth)? onResize;
  final void Function(String columnKey, double finalWidth)? onResizeEnd;
  final VoidCallback? onDoubleTap;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;
  double _dragWidth = 0;

  // Auto-scroll state for edge-proximity scrolling during resize drag
  Timer? _autoScrollTimer;
  double _autoScrollDirection = 0;
  ScrollableState? _scrollable;

  /// Distance in pixels from viewport edge where auto-scroll activates.
  static const double _autoScrollEdgeZone = 50.0;

  /// Maximum scroll speed in pixels per tick at the very edge.
  static const double _autoScrollMaxSpeed = 8.0;

  /// Interval between auto-scroll ticks (~60 fps).
  static const Duration _autoScrollInterval = Duration(milliseconds: 16);

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  void _startAutoScroll() {
    if (_autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      _performAutoScroll();
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollDirection = 0;
  }

  /// Perform one auto-scroll tick: scroll the viewport and adjust column width.
  void _performAutoScroll() {
    if (!mounted || _scrollable == null || _autoScrollDirection == 0) return;

    final position = _scrollable!.position;
    final scrollDelta = _autoScrollDirection * _autoScrollMaxSpeed;
    final oldOffset = position.pixels;
    final newOffset = (oldOffset + scrollDelta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final actualDelta = newOffset - oldOffset;

    if (actualDelta.abs() > 0.5) {
      position.jumpTo(newOffset);
      // Adjust column width by the scroll amount so the resize handle
      // stays near the pointer during auto-scroll.
      _dragWidth += actualDelta;
      final clamped = _dragWidth.clamp(
        widget.minWidth,
        widget.maxWidth ?? double.infinity,
      );
      widget.onResize?.call(widget.columnKey, clamped);
    }
  }

  /// Check pointer proximity to viewport edges and start/stop auto-scroll.
  void _updateAutoScroll(Offset globalPosition) {
    if (_scrollable == null) return;

    final renderBox = _scrollable!.context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final viewportLeft = renderBox.localToGlobal(Offset.zero).dx;
    final viewportRight = viewportLeft + renderBox.size.width;
    final pointerX = globalPosition.dx;

    if (pointerX > viewportRight - _autoScrollEdgeZone) {
      // Near right edge – speed proportional to proximity
      final proximity = 1.0 -
          ((viewportRight - pointerX) / _autoScrollEdgeZone).clamp(0.0, 1.0);
      _autoScrollDirection = proximity;
      _startAutoScroll();
    } else if (pointerX < viewportLeft + _autoScrollEdgeZone) {
      // Near left edge – speed proportional to proximity
      final proximity = 1.0 -
          ((pointerX - viewportLeft) / _autoScrollEdgeZone).clamp(0.0, 1.0);
      _autoScrollDirection = -proximity;
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.onDoubleTap,
        onHorizontalDragStart: (details) {
          _scrollable = Scrollable.maybeOf(context);
          setState(() {
            _isDragging = true;
            _dragWidth = widget.columnWidth;
          });
        },
        onHorizontalDragUpdate: (details) {
          _dragWidth += details.delta.dx;
          final clamped = _dragWidth.clamp(
            widget.minWidth,
            widget.maxWidth ?? double.infinity,
          );
          widget.onResize?.call(widget.columnKey, clamped);
          _updateAutoScroll(details.globalPosition);
        },
        onHorizontalDragEnd: (details) {
          _stopAutoScroll();
          _scrollable = null;
          final clamped = _dragWidth.clamp(
            widget.minWidth,
            widget.maxWidth ?? double.infinity,
          );
          setState(() => _isDragging = false);
          widget.onResizeEnd?.call(widget.columnKey, clamped);
        },
        onHorizontalDragCancel: () {
          _stopAutoScroll();
          _scrollable = null;
          setState(() => _isDragging = false);
        },
        child: (_isHovering || _isDragging)
            ? Padding(
                padding: EdgeInsets.only(
                  top: widget.handleIndent,
                  bottom: widget.handleEndIndent,
                ),
                child: Center(
                  child: SizedBox(
                    width: widget.handleThickness,
                    height: double.infinity,
                    child: ColoredBox(color: widget.handleColor),
                  ),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
