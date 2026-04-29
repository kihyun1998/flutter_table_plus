import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row.dart';

import '../../flutter_table_plus.dart'
    show HoverButtonPosition, TablePlusHoverButtonTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/checkbox_theme.dart';
import '../models/theme/drag_selection_theme.dart'
    show TablePlusDragSelectionTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import 'table_plus_merged_row.dart';
import 'table_plus_row_widget.dart';

/// A widget that renders the data rows of the table.
class TablePlusBody<T> extends StatefulWidget {
  /// Creates a [TablePlusBody] with the specified configuration.
  const TablePlusBody({
    super.key,
    required this.columns,
    required this.data,
    required this.columnWidths,
    required this.theme,
    required this.verticalController,
    required this.rowId,
    this.mergedGroups = const [],
    this.isDimRow,
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.onRowSelectionChanged,
    this.onCheckboxChanged,
    this.enableDragSelection = false,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.dragSelectionTheme = const TablePlusDragSelectionTheme(),
    this.onRowDoubleTap,
    this.onRowSecondaryTapDown,
    this.isEditable = false,
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onMergedCellChanged,
    this.onMergedRowExpandToggle,
    this.calculateRowHeight,
    this.scale = 1.0,
    this.scrollPhysics = const ClampingScrollPhysics(),
    this.needsVerticalScroll = false,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.hoverButtonTheme,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
  });

  /// The list of columns for the table.
  final List<TablePlusColumn<T>> columns;

  /// The data to display in the table rows.
  final List<T> data;

  /// The calculated width for each column.
  final List<double> columnWidths;

  /// List of merged row groups.
  final List<MergedRowGroup<T>> mergedGroups;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

  /// Function to extract the row ID from a row object.
  final String Function(T) rowId;

  /// Function to determine if a row should be dimmed.
  final bool Function(T)? isDimRow;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The selection mode for the table.
  final SelectionMode selectionMode;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// Callback when a row's selection state changes via row click.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when a row's selection state changes via checkbox click.
  final void Function(String rowId, bool isSelected)? onCheckboxChanged;

  /// Whether drag-to-select is enabled.
  final bool enableDragSelection;

  /// Callback fired during drag-selection with the full set of row IDs to select.
  final void Function(Set<String> selectedRowIds)? onDragSelectionUpdate;

  /// Callback fired once when drag-selection ends with the final set.
  final void Function(Set<String> selectedRowIds)? onDragSelectionEnd;

  /// Theme for the rubber band rectangle drawn during drag selection.
  final TablePlusDragSelectionTheme dragSelectionTheme;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked.
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;

  /// Whether the table supports cell editing.
  final bool isEditable;

  /// The theme configuration for editing.
  final TablePlusEditableTheme editableTheme;

  /// The theme configuration for tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// Function to check if a cell is currently being edited.
  final bool Function(int rowIndex, String columnKey)? isCellEditing;

  /// Function to get the TextEditingController for a cell.
  final TextEditingController? Function(int rowIndex, String columnKey)?
      getCellController;

  /// Callback when a cell is tapped for editing.
  final void Function(int rowIndex, String columnKey)? onCellTap;

  /// Callback to stop current editing.
  final void Function({required bool save})? onStopEditing;

  /// Callback when a merged cell value is changed.
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;

  /// Callback when a merged row group's expand/collapse state should be toggled.
  final void Function(String groupId)? onMergedRowExpandToggle;

  /// Callback to calculate the height of a specific row.
  final double? Function(int rowIndex, T rowData)? calculateRowHeight;

  /// The scale factor applied to row heights from [calculateRowHeight].
  ///
  /// When [calculateRowHeight] returns a value, it is multiplied by [scale].
  /// The fallback height from [TablePlusBodyTheme.rowHeight] is already
  /// pre-scaled by the parent, so only the callback result needs scaling.
  final double scale;

  /// The scroll physics for the vertical [ListView].
  final ScrollPhysics scrollPhysics;

  /// Builder function to create custom hover buttons for each row.
  final Widget? Function(String rowId, T rowData)? hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  final HoverButtonPosition hoverButtonPosition;

  /// Theme configuration for hover buttons.
  final TablePlusHoverButtonTheme? hoverButtonTheme;

  /// Theme configuration for checkboxes.
  final TablePlusCheckboxTheme checkboxTheme;

  /// Whether the table needs vertical scrolling.
  final bool needsVerticalScroll;

  @override
  State<TablePlusBody<T>> createState() => _TablePlusBodyState<T>();
}

class _TablePlusBodyState<T> extends State<TablePlusBody<T>> {
  /// Cached renderable indices — recomputed only when data or mergedGroups change.
  List<int>? _cachedRenderableIndices;

  /// Cached lookup: rowKey → MergedRowGroup for O(1) access.
  Map<String, MergedRowGroup<T>> _rowKeyToGroup = const {};

  /// Cached lookup: rowKey → data index for O(1) access.
  Map<String, int> _rowKeyToIndex = const {};

  /// Cached row heights.
  Map<int, double> _cachedRowHeights = const {};

  // --- Drag selection state ---
  bool _isDragSelecting = false;
  int? _dragStartRenderIndex;
  int? _dragCurrentRenderIndex;
  Timer? _autoScrollTimer;
  double? _pointerDownY;
  double? _lastPointerGlobalY;
  double _viewportHeight = 0;
  double _bodyGlobalTop = 0;

  /// Whether pointer-down landed in the empty area below the last row.
  /// (Above-data pointer-down is unreachable because the header occludes
  /// hit testing.) When true, returning to that same below-data empty
  /// area during the drag releases the lazy anchor so the selection
  /// collapses, mirroring OS marquee behavior. Crossing above row 1 into
  /// the header area instead preserves the sticky range.
  bool _dragStartedFromEmpty = false;

  // --- Rubber band rectangle state (visual only) ---
  /// Body-local pointer position at pointer-down. Used as the rectangle's
  /// origin point.
  Offset? _pointerDownLocal;

  /// Body-local pointer position on the latest move. Used as the rectangle's
  /// current corner. Triggers a rebuild via setState when changed.
  Offset? _currentPointerLocal;

  /// Scroll offset captured at pointer-down. Used to translate the origin
  /// into viewport coordinates as the list scrolls (content-anchored
  /// rectangle), so the visible rectangle grows when auto-scroll engages.
  double _dragStartScrollOffset = 0;

  static const double _dragActivationThreshold = 8.0;
  static const double _autoScrollEdgeZone = 40.0;
  static const double _autoScrollMaxSpeed = 10.0;
  static const Duration _autoScrollInterval = Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();
    _rebuildCaches();
  }

  @override
  void didUpdateWidget(covariant TablePlusBody<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.data, oldWidget.data) ||
        !identical(widget.mergedGroups, oldWidget.mergedGroups)) {
      _rebuildCaches();
    } else if (widget.scale != oldWidget.scale) {
      // Clear cached row heights when scale changes
      _cachedRowHeights = {};
    }
  }

  /// Rebuild all lookup caches.
  void _rebuildCaches() {
    final data = widget.data;
    final mergedGroups = widget.mergedGroups;

    // Build rowKey → index map
    final rowKeyToIndex = <String, int>{};
    for (int i = 0; i < data.length; i++) {
      final key = widget.rowId(data[i]);
      rowKeyToIndex[key] = i;
    }

    // Build rowKey → group map
    final rowKeyToGroup = <String, MergedRowGroup<T>>{};
    for (final group in mergedGroups) {
      for (final rowKey in group.rowKeys) {
        rowKeyToGroup[rowKey] = group;
      }
    }

    // Build renderable indices only when merged groups exist
    if (mergedGroups.isEmpty) {
      _cachedRenderableIndices = null;
    } else {
      final renderableIndices = <int>[];
      final processedIndices = <int>{};

      for (int i = 0; i < data.length; i++) {
        if (processedIndices.contains(i)) continue;

        final rowKey = widget.rowId(data[i]);
        final group = rowKeyToGroup[rowKey];

        if (group != null) {
          final firstRowKey = group.rowKeys.first;
          final firstRowIndex = rowKeyToIndex[firstRowKey];
          if (firstRowIndex == i) {
            renderableIndices.add(i);
          }
          for (final gRowKey in group.rowKeys) {
            final idx = rowKeyToIndex[gRowKey];
            if (idx != null) {
              processedIndices.add(idx);
            }
          }
        } else {
          renderableIndices.add(i);
          processedIndices.add(i);
        }
      }

      _cachedRenderableIndices = renderableIndices;
    }

    _rowKeyToGroup = rowKeyToGroup;
    _rowKeyToIndex = rowKeyToIndex;
    _cachedRowHeights = {};
  }

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index, bool isSelected, bool isDim) {
    if (isSelected && widget.isSelectable) {
      return widget.theme.selectedRowColor;
    }

    if (isDim) {
      return widget.theme.dimRowColor ?? widget.theme.backgroundColor;
    }

    if (widget.theme.alternateRowColor != null && index.isOdd) {
      return widget.theme.alternateRowColor!;
    }

    return widget.theme.backgroundColor;
  }

  /// Find the merged group that contains the specified row index.
  MergedRowGroup<T>? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= widget.data.length) return null;
    final rowKey = widget.rowId(widget.data[rowIndex]);
    return _rowKeyToGroup[rowKey];
  }

  /// Handle row selection toggle via row click.
  void _handleRowSelectionToggle(String rowId) {
    if (widget.onRowSelectionChanged == null) return;

    final isCurrentlySelected = widget.selectedRows.contains(rowId);

    final mergeGroup = _getMergedGroupById(rowId);

    if (mergeGroup != null) {
      _handleMergedGroupSelectionToggle(mergeGroup, isCurrentlySelected);
    } else {
      _handleRegularRowSelectionToggle(rowId, isCurrentlySelected);
    }
  }

  /// Handle checkbox selection toggle.
  void _handleCheckboxToggle(String rowId) {
    final callback = widget.onCheckboxChanged ?? widget.onRowSelectionChanged;
    if (callback == null) return;

    final isCurrentlySelected = widget.selectedRows.contains(rowId);

    final mergeGroup = _getMergedGroupById(rowId);

    if (mergeGroup != null) {
      callback(mergeGroup.groupId, !isCurrentlySelected);
    } else {
      callback(rowId, !isCurrentlySelected);
    }
  }

  /// Handle selection toggle for merged groups.
  void _handleMergedGroupSelectionToggle(
      MergedRowGroup<T> mergeGroup, bool isCurrentlySelected) {
    widget.onRowSelectionChanged!(mergeGroup.groupId, !isCurrentlySelected);
  }

  /// Handle selection toggle for regular rows.
  void _handleRegularRowSelectionToggle(
      String rowId, bool isCurrentlySelected) {
    widget.onRowSelectionChanged!(rowId, !isCurrentlySelected);
  }

  /// Find merged group by group ID.
  MergedRowGroup<T>? _getMergedGroupById(String groupId) {
    for (final group in widget.mergedGroups) {
      if (group.groupId == groupId) {
        return group;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  // --- Drag selection helpers ---

  bool get _isDragSelectionEnabled =>
      widget.enableDragSelection &&
      widget.isSelectable &&
      widget.selectionMode == SelectionMode.multiple &&
      widget.onDragSelectionUpdate != null;

  /// Convert a local Y coordinate (relative to the ListView's scroll extent)
  /// into a render index.
  ///
  /// Returns null when the coordinate falls outside the actual row area
  /// (above the first row or below the last row). Callers rely on this
  /// signal to keep drag selection sticky at the last valid row instead of
  /// snapping to a row the pointer never crossed.
  int? _renderIndexFromLocalY(double localY) {
    final indices = _cachedRenderableIndices;
    final itemCount = indices?.length ?? widget.data.length;
    if (itemCount == 0) return null;

    // Absolute Y = localY + scroll offset
    final absoluteY = localY + widget.verticalController.offset;

    if (absoluteY < 0) return null;

    // Fast path: uniform row heights (no calculateRowHeight, no merged groups)
    if (widget.calculateRowHeight == null && widget.mergedGroups.isEmpty) {
      final rowHeight = widget.theme.rowHeight;
      final idx = (absoluteY / rowHeight).floor();
      if (idx >= itemCount) return null;
      return idx;
    }

    // Slow path: accumulate heights
    double cumulativeHeight = 0;
    for (int renderIdx = 0; renderIdx < itemCount; renderIdx++) {
      final actualIndex = indices?[renderIdx] ?? renderIdx;
      final group = _getMergedGroupForRow(actualIndex);
      final double rowHeight;
      if (group != null) {
        rowHeight = _getMergedGroupExtent(group);
      } else {
        rowHeight = _calculateRowHeight(actualIndex) ?? widget.theme.rowHeight;
      }
      cumulativeHeight += rowHeight;
      if (absoluteY < cumulativeHeight) {
        return renderIdx;
      }
    }
    return null;
  }

  /// Collect all row IDs between two render indices (inclusive).
  Set<String> _collectRowIdsInRange(int startRenderIdx, int endRenderIdx) {
    final indices = _cachedRenderableIndices;
    final lo = startRenderIdx < endRenderIdx ? startRenderIdx : endRenderIdx;
    final hi = startRenderIdx < endRenderIdx ? endRenderIdx : startRenderIdx;

    final result = <String>{};
    for (int renderIdx = lo; renderIdx <= hi; renderIdx++) {
      final actualIndex = indices?[renderIdx] ?? renderIdx;
      if (actualIndex >= widget.data.length) continue;

      final group = _getMergedGroupForRow(actualIndex);
      if (group != null) {
        result.add(group.groupId);
      } else {
        result.add(widget.rowId(widget.data[actualIndex]));
      }
    }
    return result;
  }

  /// Fire selection update callback with the drag range IDs only.
  /// The parent decides whether to union with existing selection or replace.
  void _updateDragSelection() {
    if (_dragStartRenderIndex == null || _dragCurrentRenderIndex == null) {
      return;
    }

    final dragIds =
        _collectRowIdsInRange(_dragStartRenderIndex!, _dragCurrentRenderIndex!);
    widget.onDragSelectionUpdate?.call(dragIds);
  }

  // --- Auto-scroll ---

  void _startAutoScroll() {
    if (_autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      _performAutoScroll();
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _performAutoScroll() {
    final globalY = _lastPointerGlobalY;
    if (globalY == null) return;

    final localY = globalY - _bodyGlobalTop;
    double scrollDelta = 0;

    if (localY < _autoScrollEdgeZone) {
      // Near top edge — scroll up
      final proximity = (_autoScrollEdgeZone - localY) / _autoScrollEdgeZone;
      scrollDelta = -_autoScrollMaxSpeed * proximity;
    } else if (localY > _viewportHeight - _autoScrollEdgeZone) {
      // Near bottom edge — scroll down
      final proximity = (localY - (_viewportHeight - _autoScrollEdgeZone)) /
          _autoScrollEdgeZone;
      scrollDelta = _autoScrollMaxSpeed * proximity;
    } else {
      // Pointer is in the middle — stop auto-scroll
      _stopAutoScroll();
      return;
    }

    final controller = widget.verticalController;
    if (!controller.hasClients) return;
    // Snapshot the offset once — reading controller.offset multiple times
    // can race with rebuild cycles where ScrollPosition is briefly
    // re-attached and reports a transient zero, blocking auto-scroll.
    final prevOffset = controller.offset;
    final maxScroll = controller.position.maxScrollExtent;
    final newOffset = (prevOffset + scrollDelta).clamp(0.0, maxScroll);
    if (newOffset == prevOffset) return;
    controller.jumpTo(newOffset);

    // Re-calculate current render index after scroll position change
    final bodyLocalY = globalY - _bodyGlobalTop;
    final renderIdx = _renderIndexFromLocalY(bodyLocalY);
    if (renderIdx != null && renderIdx != _dragCurrentRenderIndex) {
      _dragCurrentRenderIndex = renderIdx;
      _updateDragSelection();
    }

    // Trigger rebuild so the content-anchored rubber band rectangle grows
    // (or shrinks) with the new scroll offset. Without this the overlay
    // stays stale until the next pointer move.
    if (mounted) setState(() {});
  }

  // --- Pointer event handlers ---

  void _onPointerDown(PointerDownEvent event) {
    if (!_isDragSelectionEnabled) return;

    // Capture viewport metrics
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _viewportHeight = renderBox.size.height;
      _bodyGlobalTop = renderBox.localToGlobal(Offset.zero).dy;
    }

    _pointerDownY = event.position.dy;
    _lastPointerGlobalY = event.position.dy;
    _pointerDownLocal = event.localPosition;
    _currentPointerLocal = event.localPosition;
    _dragStartScrollOffset = widget.verticalController.hasClients
        ? widget.verticalController.offset
        : 0;

    // Pre-calculate start render index
    final localY = event.position.dy - _bodyGlobalTop;
    _dragStartRenderIndex = _renderIndexFromLocalY(localY);
    _dragStartedFromEmpty = _dragStartRenderIndex == null;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isDragSelectionEnabled || _pointerDownY == null) return;

    _lastPointerGlobalY = event.position.dy;

    // 1. Threshold gate — independent of anchor. The user's intent to
    //    drag is established by movement distance alone; whether the
    //    pointer has touched a row yet is a separate concern.
    if (!_isDragSelecting) {
      final distance = (event.position.dy - _pointerDownY!).abs();
      if (distance < _dragActivationThreshold) return;
      _isDragSelecting = true;
    }

    // 2. Track body-local pointer for the rubber band overlay —
    //    independent of anchor so the rectangle stays visible even when
    //    the drag is entirely confined to empty space.
    if (mounted && _currentPointerLocal != event.localPosition) {
      setState(() {
        _currentPointerLocal = event.localPosition;
      });
    }

    // 3. Resolve the current render index once for both anchor and
    //    selection logic.
    final localY = event.position.dy - _bodyGlobalTop;
    final renderIdx = _renderIndexFromLocalY(localY);

    // Lazy anchor: first crossing into a real row sets the start. If we
    // are still in empty space, fall through — selection logic will be
    // skipped this frame, but the rubber band continues to update.
    if (_dragStartRenderIndex == null && renderIdx != null) {
      _dragStartRenderIndex = renderIdx;
    }

    // 4. Selection update — only meaningful when the anchor exists.
    if (_dragStartRenderIndex != null) {
      if (renderIdx != null) {
        _dragCurrentRenderIndex = renderIdx;
        _updateDragSelection();
      } else if (_dragStartedFromEmpty) {
        // Pointer-down can only land in the empty area below the data
        // (the header occludes hit testing above), so a release fires
        // only when the pointer is back below the data. Above-data
        // movement (header area) preserves the sticky range.
        final absoluteY = localY + widget.verticalController.offset;
        if (absoluteY >= 0) {
          _dragStartRenderIndex = null;
          _dragCurrentRenderIndex = null;
          widget.onDragSelectionUpdate?.call(<String>{});
        }
      }
    }

    // 5. Auto-scroll
    final bodyLocalY = event.position.dy - _bodyGlobalTop;
    if (bodyLocalY < _autoScrollEdgeZone ||
        bodyLocalY > _viewportHeight - _autoScrollEdgeZone) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isDragSelecting) {
      // Fire final callback
      if (_dragStartRenderIndex != null && _dragCurrentRenderIndex != null) {
        final dragIds = _collectRowIdsInRange(
            _dragStartRenderIndex!, _dragCurrentRenderIndex!);
        if (widget.onDragSelectionEnd != null) {
          widget.onDragSelectionEnd!(dragIds);
        } else {
          widget.onDragSelectionUpdate?.call(dragIds);
        }
      }
    }
    _resetDragState();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _resetDragState();
  }

  void _resetDragState() {
    _stopAutoScroll();
    final hadRubberBand = _pointerDownLocal != null;
    _isDragSelecting = false;
    _dragStartRenderIndex = null;
    _dragCurrentRenderIndex = null;
    _pointerDownY = null;
    _lastPointerGlobalY = null;
    _dragStartedFromEmpty = false;
    _pointerDownLocal = null;
    _currentPointerLocal = null;
    _dragStartScrollOffset = 0;
    if (hadRubberBand && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: widget.theme.rowHeight * 3,
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
        ),
        child: Center(
          child: Text(
            'No data available',
            style: widget.theme.textStyle.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final indices = _cachedRenderableIndices;

    Widget listView = ListView.builder(
      controller: widget.verticalController,
      physics: widget.scrollPhysics,
      itemExtentBuilder: (int index, _) {
        final actualIndex = indices?[index] ?? index;
        final group = _getMergedGroupForRow(actualIndex);
        if (group != null) {
          return _getMergedGroupExtent(group);
        }
        return _calculateRowHeight(actualIndex) ?? widget.theme.rowHeight;
      },
      itemCount: indices?.length ?? widget.data.length,
      itemBuilder: (context, index) {
        final actualIndex = indices?[index] ?? index;
        return _buildRowWidget(actualIndex, index);
      },
    );

    if (_isDragSelectionEnabled) {
      final rubberBand = _buildRubberBand();
      // Always wrap in Stack when drag selection is enabled. Switching
      // Listener.child between `ListView` and `Stack(...)` based on rubber
      // band visibility would change the runtimeType of that slot at the
      // moment the drag activates, forcing Flutter to deactivate the old
      // ListView element and mount a fresh one. The new ListView attaches
      // a brand-new ScrollPosition that starts at `initialScrollOffset` (0),
      // wiping the user's scroll position. By keeping the Stack constant,
      // the ListView element stays in slot 0 and its ScrollPosition is
      // preserved across drag activation.
      listView = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          fit: StackFit.expand,
          children: [
            listView,
            if (rubberBand != null) IgnorePointer(child: rubberBand),
          ],
        ),
      );
    }

    return listView;
  }

  /// Builds the rubber band rectangle overlay shown during drag selection.
  ///
  /// Returns null when no rectangle should be drawn (drag inactive, theme
  /// disabled, or coordinates not yet captured). The rectangle is content-
  /// anchored: its origin shifts with scroll so auto-scroll causes the
  /// visible rectangle to grow, mirroring OS marquee selection.
  Widget? _buildRubberBand() {
    final theme = widget.dragSelectionTheme;
    if (!theme.show) return null;
    if (!_isDragSelecting) return null;
    final downLocal = _pointerDownLocal;
    final currentLocal = _currentPointerLocal;
    if (downLocal == null || currentLocal == null) return null;

    // Translate the origin into the current viewport's coordinates by
    // subtracting the scroll delta since pointer-down. This makes the
    // rectangle's anchor follow the underlying content as the list scrolls.
    final scrollDelta = (widget.verticalController.hasClients
            ? widget.verticalController.offset
            : 0) -
        _dragStartScrollOffset;
    final originY = downLocal.dy - scrollDelta;
    final rect = Rect.fromPoints(
      Offset(downLocal.dx, originY),
      currentLocal,
    );

    return CustomPaint(
      painter: _RubberBandPainter(
        rect: rect,
        fillColor: theme.fillColor,
        borderColor: theme.borderColor,
        borderWidth: theme.borderWidth,
        borderRadius: theme.borderRadius,
      ),
    );
  }

  /// Calculate the total extent for a merged group.
  double _getMergedGroupExtent(MergedRowGroup<T> group) {
    double total = 0;
    for (final rowKey in group.rowKeys) {
      final rowIndex = _rowKeyToIndex[rowKey];
      if (rowIndex != null) {
        total += _calculateRowHeight(rowIndex) ?? widget.theme.rowHeight;
      } else {
        total += widget.theme.rowHeight;
      }
    }
    if (group.isExpandable && group.isExpanded) {
      total += widget.theme.rowHeight;
    }
    return total;
  }

  /// Calculate the height for a specific row, with caching.
  ///
  /// The returned value is already scaled by [widget.scale].
  double? _calculateRowHeight(int index) {
    if (widget.calculateRowHeight == null || index >= widget.data.length) {
      return null;
    }
    final cached = _cachedRowHeights[index];
    if (cached != null) return cached;
    final height = widget.calculateRowHeight!(index, widget.data[index]);
    if (height != null) {
      final scaled = height * widget.scale;
      _cachedRowHeights[index] = scaled;
      return scaled;
    }
    return null;
  }

  /// Build a row widget for the given index.
  TablePlusRowWidget _buildRowWidget(int index, int renderIndex) {
    final mergeGroup = _getMergedGroupForRow(index);

    if (mergeGroup != null) {
      final firstRowKey = mergeGroup.rowKeys.first;
      final firstRowIndex = _rowKeyToIndex[firstRowKey];
      if (firstRowIndex != null && firstRowIndex == index) {
        final isSelected = widget.selectedRows.contains(mergeGroup.groupId);
        final firstRowData = widget.data[firstRowIndex];
        final isDimmed = widget.isDimRow?.call(firstRowData) ?? false;

        double? mergedHeight;
        List<double>? individualHeights;
        if (widget.calculateRowHeight != null) {
          final heights = <double>[];
          double totalHeight = 0;

          for (final rowKey in mergeGroup.rowKeys) {
            final rowIndex = _rowKeyToIndex[rowKey];
            if (rowIndex != null) {
              final height = _calculateRowHeight(rowIndex);
              if (height != null) {
                heights.add(height);
                totalHeight += height;
              } else {
                heights.add(widget.theme.rowHeight);
                totalHeight += widget.theme.rowHeight;
              }
            } else {
              heights.add(widget.theme.rowHeight);
              totalHeight += widget.theme.rowHeight;
            }
          }

          if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
            heights.add(widget.theme.rowHeight);
            totalHeight += widget.theme.rowHeight;
          }

          individualHeights = heights;
          mergedHeight = totalHeight;
        }

        final lastRowKey = mergeGroup.rowKeys.last;
        final lastRowIndex = _rowKeyToIndex[lastRowKey];
        final isLastRow = lastRowIndex == widget.data.length - 1;

        return TablePlusMergedRow<T>(
          mergeGroup: mergeGroup,
          allData: widget.data,
          columns: widget.columns,
          columnWidths: widget.columnWidths,
          theme: widget.theme,
          backgroundColor: _getRowColor(renderIndex, isSelected, isDimmed),
          isLastRow: isLastRow,
          isSelectable: widget.isSelectable,
          selectionMode: widget.selectionMode,
          isSelected: isSelected,
          checkboxTheme: widget.checkboxTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
          onCheckboxChanged: _handleCheckboxToggle,
          isEditable: widget.isEditable,
          editableTheme: widget.editableTheme,
          tooltipTheme: widget.tooltipTheme,
          rowId: widget.rowId,
          isCellEditing: widget.isCellEditing,
          getCellController: widget.getCellController,
          onCellTap: widget.onCellTap,
          onStopEditing: widget.onStopEditing,
          onRowDoubleTap: widget.onRowDoubleTap,
          onRowSecondaryTapDown: widget.onRowSecondaryTapDown,
          onMergedCellChanged: widget.onMergedCellChanged,
          onMergedRowExpandToggle: widget.onMergedRowExpandToggle,
          calculatedHeight: mergedHeight,
          individualHeights: individualHeights,
          needsVerticalScroll: widget.needsVerticalScroll,
          hoverButtonBuilder: widget.hoverButtonBuilder,
          hoverButtonPosition: widget.hoverButtonPosition,
          hoverButtonTheme: widget.hoverButtonTheme,
          isDim: isDimmed,
        );
      }
    }

    // This is a normal row
    final rowData = widget.data[index];
    final rowIdStr = widget.rowId(rowData);
    final isSelected = widget.selectedRows.contains(rowIdStr);
    final calculatedHeight = _calculateRowHeight(index);
    final isDimmed = widget.isDimRow?.call(rowData) ?? false;

    return TablePlusRow<T>(
      rowIndex: index,
      rowData: rowData,
      rowId: rowIdStr,
      columns: widget.columns,
      columnWidths: widget.columnWidths,
      theme: widget.theme,
      backgroundColor: _getRowColor(renderIndex, isSelected, isDimmed),
      isLastRow: index == widget.data.length - 1,
      isSelectable: widget.isSelectable,
      selectionMode: widget.selectionMode,
      isSelected: isSelected,
      checkboxTheme: widget.checkboxTheme,
      onRowSelectionChanged: _handleRowSelectionToggle,
      onCheckboxChanged: _handleCheckboxToggle,
      onRowDoubleTap: widget.onRowDoubleTap,
      onRowSecondaryTapDown: widget.onRowSecondaryTapDown,
      isEditable: widget.isEditable,
      editableTheme: widget.editableTheme,
      tooltipTheme: widget.tooltipTheme,
      isCellEditing: widget.isCellEditing,
      getCellController: widget.getCellController,
      onCellTap: widget.onCellTap,
      onStopEditing: widget.onStopEditing,
      calculatedHeight: calculatedHeight,
      needsVerticalScroll: widget.needsVerticalScroll,
      hoverButtonBuilder: widget.hoverButtonBuilder,
      hoverButtonPosition: widget.hoverButtonPosition,
      hoverButtonTheme: widget.hoverButtonTheme,
      isDim: isDimmed,
    );
  }
}

/// Paints the rubber band rectangle for drag selection.
class _RubberBandPainter extends CustomPainter {
  _RubberBandPainter({
    required this.rect,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  final Rect rect;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect.isEmpty) return;
    final clipped = rect.intersect(Offset.zero & size);
    if (clipped.isEmpty) return;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(clipped, fillPaint);
      if (borderWidth > 0) canvas.drawRect(clipped, borderPaint);
    } else {
      final rrect = borderRadius.toRRect(clipped);
      canvas.drawRRect(rrect, fillPaint);
      if (borderWidth > 0) canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RubberBandPainter old) {
    return old.rect != rect ||
        old.fillColor != fillColor ||
        old.borderColor != borderColor ||
        old.borderWidth != borderWidth ||
        old.borderRadius != borderRadius;
  }
}
