import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/hover_button_position.dart';
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/theme.dart' show TablePlusTheme;
import 'synced_scroll_controllers.dart';
import 'table_body.dart';
import 'table_header.dart';

/// A powerful, customizable table widget for Flutter.
///
/// [FlutterTablePlus] provides synchronized scrolling, theming, sorting,
/// selection, column reordering, cell editing, and merged row capabilities.
///
/// The type parameter [T] represents the type of row data objects.
class FlutterTablePlus<T> extends StatefulWidget {
  /// Creates a [FlutterTablePlus] with the specified configuration.
  const FlutterTablePlus({
    super.key,
    required this.columns,
    required this.data,
    required this.rowId,
    this.mergedGroups = const [],
    this.isDimRow,
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.onRowSelectionChanged,
    this.onCheckboxChanged,
    this.onSelectAll,
    this.enableDragSelection = false,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.onRowDoubleTap,
    this.onRowSecondaryTapDown,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.onSort,
    this.isEditable = false,
    this.onCellChanged,
    this.onMergedCellChanged,
    this.onMergedRowExpandToggle,
    this.onColumnReorder,
    this.resizable = false,
    this.onColumnResized,
    this.theme = const TablePlusTheme(),
    this.noDataWidget,
    this.calculateRowHeight,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.autoFitColumnWidth,
    this.stretchLastColumn = false,
  });

  /// The column definitions for the table.
  ///
  /// Keys are column identifiers that match the keys used in data.
  /// Values are [TablePlusColumn] instances defining each column's properties.
  ///
  /// Column display order is determined by each column's [order] property.
  /// Use [TableColumnsBuilder] for safe column creation with automatic ordering.
  final Map<String, TablePlusColumn<T>> columns;

  /// The data to display in the table rows.
  final List<T> data;

  /// Function to extract a unique row ID string from a row object.
  final String Function(T) rowId;

  /// List of merged row groups.
  final List<MergedRowGroup<T>> mergedGroups;

  /// Function to determine if a row should be visually dimmed.
  ///
  /// Return true if the row should be dimmed.
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

  /// Callback when the select-all checkbox is toggled.
  final void Function(bool selectAll)? onSelectAll;

  /// Whether drag-to-select is enabled.
  /// Only works when [isSelectable] is true and [selectionMode] is [SelectionMode.multiple].
  final bool enableDragSelection;

  /// Callback fired during drag-selection with the set of row IDs in the drag range.
  /// Only contains IDs from the current drag — the parent decides whether to
  /// replace or merge with existing [selectedRows].
  final void Function(Set<String> draggedRowIds)? onDragSelectionUpdate;

  /// Callback fired once when drag-selection ends with the final drag range set.
  /// If null, [onDragSelectionUpdate] serves as both live and final callback.
  final void Function(Set<String> draggedRowIds)? onDragSelectionEnd;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked.
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;

  /// The key of the currently sorted column.
  final String? sortColumnKey;

  /// The current sort direction.
  final SortDirection sortDirection;

  /// The order in which sort directions cycle.
  final SortCycleOrder sortCycleOrder;

  /// Callback when a sortable column header is clicked.
  final void Function(String columnKey, SortDirection direction)? onSort;

  /// Whether the table supports cell editing.
  final bool isEditable;

  /// Callback when a cell value is changed.
  final CellChangedCallback<T>? onCellChanged;

  /// Callback when a merged cell value is changed.
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;

  /// Callback when a merged row group's expand/collapse state should be toggled.
  final void Function(String groupId)? onMergedRowExpandToggle;

  /// Callback when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// Whether columns can be resized by dragging their header edges.
  final bool resizable;

  /// Callback when a column resize drag ends.
  ///
  /// Called once per resize operation with the column key and final width.
  /// Use this to persist column widths externally.
  final void Function(String columnKey, double newWidth)? onColumnResized;

  /// The theme configuration for the table.
  final TablePlusTheme theme;

  /// Widget to display when no data is available.
  final Widget? noDataWidget;

  /// Callback to calculate the height of a specific row.
  /// Return null to use the default row height.
  final double? Function(int rowIndex, T rowData)? calculateRowHeight;

  /// Builder function to create custom hover buttons for each row.
  /// The function receives the row ID and row data object.
  /// Return null to show no hover buttons for a specific row.
  final Widget? Function(String rowId, T rowData)? hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  final HoverButtonPosition hoverButtonPosition;

  /// Custom auto-fit width calculator for specific columns.
  ///
  /// When provided, this callback is called first during auto-fit (double-tap
  /// on resize handle). Return a width to override the default measurement,
  /// or return null to fall back to the built-in text measurement.
  ///
  /// This is useful for columns that use [TablePlusColumn.statefulCellBuilder]
  /// or [TablePlusColumn.cellBuilder] with custom styles, padding, or text
  /// transformations that the default measurement cannot account for.
  final double? Function(String columnKey)? autoFitColumnWidth;

  /// Whether the last column should stretch to fill remaining space
  /// when all columns have fixed widths (e.g., after auto-fit or manual resize).
  ///
  /// When false (default), columns keep their exact widths and empty space
  /// may appear on the right. When true, the last visible column absorbs
  /// any leftover space.
  final bool stretchLastColumn;

  @override
  State<FlutterTablePlus<T>> createState() => _FlutterTablePlusState<T>();
}

class _FlutterTablePlusState<T> extends State<FlutterTablePlus<T>> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  /// Column resize state: tracks user-resized widths by column key
  final Map<String, double> _resizedWidths = {};

  /// Editing state
  int? _editingRowIndex;
  String? _editingColumnKey;
  TextEditingController? _cellController;
  dynamic _originalCellValue;

  /// Cached rowId → data index lookup for O(1) access
  Map<String, int> _rowIdToIndex = {};

  /// Cached rowId → MergedRowGroup lookup for O(1) access
  Map<String, MergedRowGroup<T>> _rowIdToMergedGroup = {};

  /// Cached total data height
  double _cachedTotalDataHeight = 0;

  /// Cached total row count (merged groups count as 1)
  int _cachedTotalRowCount = 0;

  @override
  void initState() {
    super.initState();
    _validateColumns();
    if (widget.data.isNotEmpty) {
      _validateUniqueIds();
    }
    _rebuildCaches();
  }

  @override
  void didUpdateWidget(covariant FlutterTablePlus<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.data, oldWidget.data)) {
      if (widget.data.isNotEmpty) {
        _validateUniqueIds();
      }
    }
    if (!identical(widget.columns, oldWidget.columns)) {
      _validateColumns();
      // Clean up resize state for removed columns
      _resizedWidths.removeWhere((key, _) => !widget.columns.containsKey(key));
    }
    if (!identical(widget.data, oldWidget.data) ||
        !identical(widget.mergedGroups, oldWidget.mergedGroups) ||
        !identical(widget.calculateRowHeight, oldWidget.calculateRowHeight)) {
      _rebuildCaches();
    }
  }

  /// Validate that columns are properly configured.
  void _validateColumns() {
    if (widget.columns.isEmpty) {
      debugPrint('⚠️ FlutterTablePlus: No columns provided');
    }
  }

  /// Validate that all row IDs are unique.
  void _validateUniqueIds() {
    final ids = <String>{};
    for (final row in widget.data) {
      final id = widget.rowId(row);
      if (ids.contains(id)) {
        debugPrint('⚠️ FlutterTablePlus: Duplicate row ID found: "$id". '
            'Each row must have a unique ID for selection features to work correctly.');
        return;
      }
      ids.add(id);
    }
  }

  /// Rebuild cached values for total height, row count, and lookup maps.
  void _rebuildCaches() {
    // Build rowId → index lookup
    _rowIdToIndex = {};
    for (int i = 0; i < widget.data.length; i++) {
      final key = widget.rowId(widget.data[i]);
      _rowIdToIndex[key] = i;
    }

    // Build rowId → MergedRowGroup lookup
    _rowIdToMergedGroup = {};
    for (final group in widget.mergedGroups) {
      for (final rowKey in group.rowKeys) {
        _rowIdToMergedGroup[rowKey] = group;
      }
    }

    // Calculate total height and row count in a single pass
    double totalHeight = 0;
    int totalCount = 0;
    final Set<int> processedIndices = {};

    for (int i = 0; i < widget.data.length; i++) {
      if (processedIndices.contains(i)) continue;

      final mergeGroup = _getMergedGroupForRow(i);
      if (mergeGroup != null) {
        totalHeight += _getMergedRowHeight(mergeGroup);
        totalCount++;
        for (final rowKey in mergeGroup.rowKeys) {
          final rowIndex = _rowIdToIndex[rowKey];
          if (rowIndex != null) {
            processedIndices.add(rowIndex);
          }
        }
      } else {
        totalHeight += _getRowHeight(i);
        totalCount++;
        processedIndices.add(i);
      }
    }

    _cachedTotalDataHeight = totalHeight;
    _cachedTotalRowCount = totalCount;
  }

  /// Find the merged group that contains the specified row index.
  MergedRowGroup<T>? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= widget.data.length) return null;
    final rowKey = widget.rowId(widget.data[rowIndex]);
    return _rowIdToMergedGroup[rowKey];
  }

  /// Get the height for an individual row.
  double _getRowHeight(int index) {
    return widget.calculateRowHeight?.call(index, widget.data[index]) ??
        widget.theme.bodyTheme.rowHeight;
  }

  /// Calculate the total height for a merged row group.
  double _getMergedRowHeight(MergedRowGroup<T> mergeGroup) {
    double totalHeight = 0;
    for (final rowKey in mergeGroup.rowKeys) {
      final rowIndex = _rowIdToIndex[rowKey];
      if (rowIndex != null) {
        totalHeight += _getRowHeight(rowIndex);
      }
    }

    // Add summary row height if expandable and expanded
    if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
      totalHeight += widget.theme.bodyTheme.rowHeight;
    }

    return totalHeight;
  }

  @override
  void dispose() {
    _isHovered.dispose();
    _cellController?.dispose();
    super.dispose();
  }

  /// Handle live column resize (called during drag).
  void _handleColumnResize(String columnKey, double newWidth) {
    setState(() {
      _resizedWidths[columnKey] = newWidth;
    });
  }

  /// Handle column resize end (called once when drag finishes).
  void _handleColumnResizeEnd(String columnKey, double finalWidth) {
    widget.onColumnResized?.call(columnKey, finalWidth);
  }

  /// Handle auto-fit column width on resize handle double-tap.
  ///
  /// If [autoFitColumnWidth] is provided, it is called first. When it returns
  /// a non-null width, that value is used directly (clamped to column
  /// constraints). Otherwise, falls back to the built-in [TextPainter]
  /// measurement of header and body text.
  void _handleColumnAutoFit(String columnKey) {
    final column = widget.columns[columnKey];
    if (column == null) return;

    // External callback override
    final customWidth = widget.autoFitColumnWidth?.call(columnKey);
    if (customWidth != null) {
      final result = customWidth.clamp(
        column.minWidth,
        column.maxWidth ?? double.infinity,
      );
      setState(() {
        _resizedWidths[columnKey] = result;
      });
      widget.onColumnResized?.call(columnKey, result);
      return;
    }

    final headerTheme = widget.theme.headerTheme;
    final bodyTheme = widget.theme.bodyTheme;

    // Resolve effective text styles by merging with DefaultTextStyle
    // (inherits fontFamily, letterSpacing, etc. from the Material theme)
    final defaultStyle = DefaultTextStyle.of(context).style;
    final resolvedHeaderStyle = defaultStyle.merge(headerTheme.textStyle);
    final resolvedBodyStyle = defaultStyle.merge(bodyTheme.textStyle);
    final textScaler = MediaQuery.textScalerOf(context);

    // Measure header text width
    final headerPainter = TextPainter(
      text: TextSpan(text: column.label, style: resolvedHeaderStyle),
      textDirection: ui.TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    final bool hasSortIcon = column.sortable && widget.onSort != null;
    final double sortIconArea = hasSortIcon
        ? headerTheme.sortIconSpacing + headerTheme.sortIconWidth
        : 0.0;

    double maxWidth =
        headerPainter.width + headerTheme.padding.horizontal + sortIconArea;

    // Account for vertical divider border in body cells (right border 0.5px)
    final double bodyBorderWidth = bodyTheme.showVerticalDividers ? 0.5 : 0.0;

    // Measure body cell widths
    for (final row in widget.data) {
      final value = column.valueAccessor(row);
      final text = value?.toString() ?? '';
      if (text.isEmpty) continue;

      final bodyPainter = TextPainter(
        text: TextSpan(text: text, style: resolvedBodyStyle),
        textDirection: ui.TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();

      final cellWidth =
          bodyPainter.width + bodyTheme.padding.horizontal + bodyBorderWidth;
      if (cellWidth > maxWidth) {
        maxWidth = cellWidth;
      }
    }

    // Add a small buffer (1px) to prevent ellipsis from rounding errors
    maxWidth = (maxWidth + 1.0).ceilToDouble();

    // Clamp to column constraints
    final result = maxWidth.clamp(
      column.minWidth,
      column.maxWidth ?? double.infinity,
    );

    setState(() {
      _resizedWidths[columnKey] = result;
    });
    widget.onColumnResized?.call(columnKey, result);
  }

  /// Get ordered columns, with optional selection column prepended.
  List<TablePlusColumn<T>> _getOrderedColumns() {
    // Sort columns by order
    final sortedColumns = widget.columns.entries.toList()
      ..sort((a, b) => a.value.order.compareTo(b.value.order));

    // Filter out invisible columns
    final visibleColumns =
        sortedColumns.where((entry) => entry.value.visible).toList();

    // Add selection column at the beginning if selectable and checkbox column is enabled
    if (widget.isSelectable && widget.theme.checkboxTheme.showCheckboxColumn) {
      visibleColumns.insert(
        0,
        MapEntry(
          '__selection__',
          TablePlusColumn<T>(
            key: '__selection__',
            label: '',
            order: -1,
            valueAccessor: (_) => null,
            width: widget.theme.checkboxTheme.checkboxColumnWidth,
            minWidth: widget.theme.checkboxTheme.checkboxColumnWidth,
            maxWidth: widget.theme.checkboxTheme.checkboxColumnWidth,
            sortable: false,
          ),
        ),
      );
    }

    return visibleColumns.map((entry) => entry.value).toList();
  }

  /// Calculate column widths based on available space.
  ///
  /// When columns have been resized by the user, their widths are fixed.
  /// Remaining space is distributed proportionally among flexible columns.
  /// Columns whose maxWidth == their preferred width are treated as fixed
  /// and excluded from proportional distribution to prevent space loss.
  List<double> _calculateColumnWidths(
      double availableWidth, List<TablePlusColumn<T>> orderedColumns) {
    if (orderedColumns.isEmpty) return [];

    // Classify each column: resized, fixed (maxWidth caps it), or flexible
    double fixedTotal = 0;
    double flexiblePreferredTotal = 0;
    final widths = List<double?>.filled(orderedColumns.length, null);

    for (int i = 0; i < orderedColumns.length; i++) {
      final column = orderedColumns[i];
      final resizedWidth = _resizedWidths[column.key];

      if (resizedWidth != null) {
        // User-resized column — lock to resized width
        final clamped = resizedWidth.clamp(
          column.minWidth,
          column.maxWidth ?? double.infinity,
        );
        widths[i] = clamped;
        fixedTotal += clamped;
      } else if (column.maxWidth != null && column.width >= column.maxWidth!) {
        // Column whose preferred width already hits maxWidth — fixed
        final clamped = column.width.clamp(column.minWidth, column.maxWidth!);
        widths[i] = clamped;
        fixedTotal += clamped;
      } else {
        // Flexible column — participates in proportional distribution
        flexiblePreferredTotal += column.width;
      }
    }

    final spaceForFlexible = availableWidth - fixedTotal;

    // Not enough space — give each flexible column its clamped preferred width
    if (spaceForFlexible <= 0 || flexiblePreferredTotal <= 0) {
      for (int i = 0; i < orderedColumns.length; i++) {
        if (widths[i] == null) {
          final col = orderedColumns[i];
          widths[i] =
              col.width.clamp(col.minWidth, col.maxWidth ?? double.infinity);
        }
      }
    } else {
      // Iterative redistribution: when a flexible column hits maxWidth,
      // lock it and redistribute the excess to remaining flexible columns.
      double remainingSpace = spaceForFlexible;
      double remainingPreferred = flexiblePreferredTotal;
      final isFlexible = List<bool>.generate(
        orderedColumns.length,
        (i) => widths[i] == null,
      );

      bool changed = true;
      while (changed) {
        changed = false;

        if (remainingPreferred <= 0 || remainingSpace <= 0) {
          for (int i = 0; i < orderedColumns.length; i++) {
            if (!isFlexible[i]) continue;
            final col = orderedColumns[i];
            widths[i] =
                col.width.clamp(col.minWidth, col.maxWidth ?? double.infinity);
          }
          break;
        }

        for (int i = 0; i < orderedColumns.length; i++) {
          if (!isFlexible[i]) continue;
          final column = orderedColumns[i];
          final proportion = column.width / remainingPreferred;
          final calculatedWidth = remainingSpace * proportion;

          if (column.maxWidth != null && calculatedWidth > column.maxWidth!) {
            widths[i] = column.maxWidth!;
            isFlexible[i] = false;
            remainingSpace -= column.maxWidth!;
            remainingPreferred -= column.width;
            changed = true;
            break;
          }
        }
      }

      // Final pass: assign remaining flexible columns
      for (int i = 0; i < orderedColumns.length; i++) {
        if (widths[i] != null) continue;
        final column = orderedColumns[i];
        final proportion = column.width / remainingPreferred;
        widths[i] = (remainingSpace * proportion)
            .clamp(column.minWidth, column.maxWidth ?? double.infinity);
      }
    }

    // stretchLastColumn: absorb any remaining space into the last column
    if (widget.stretchLastColumn) {
      final totalUsed = widths.fold(0.0, (sum, w) => sum + (w ?? 0.0));
      final remaining = availableWidth - totalUsed;
      if (remaining > 0) {
        // Find last non-selection column index
        int lastIdx = -1;
        for (int i = orderedColumns.length - 1; i >= 0; i--) {
          if (orderedColumns[i].key != '__selection__') {
            lastIdx = i;
            break;
          }
        }
        if (lastIdx >= 0) {
          widths[lastIdx] = widths[lastIdx]! + remaining;
        }
      }
    }

    return widths.cast<double>();
  }

  /// Handle starting a cell editing session.
  void _handleCellTap(int rowIndex, String columnKey) {
    if (!widget.isEditable) return;

    // Check if this column is editable
    final column = widget.columns[columnKey];
    if (column == null || !column.editable) return;

    // Check if column has custom cell builder (can't edit custom cells)
    if (column.hasCustomCellBuilder) return;

    setState(() {
      // Stop any current editing
      _stopEditing(save: true);

      // Start editing the new cell
      _editingRowIndex = rowIndex;
      _editingColumnKey = columnKey;

      // Get the current cell value
      _originalCellValue = column.valueAccessor(widget.data[rowIndex]);

      // Create a controller with the current value
      _cellController?.dispose();
      _cellController = TextEditingController(
        text: _originalCellValue?.toString() ?? '',
      );
    });
  }

  /// Stop editing and optionally save the value.
  void _stopEditing({required bool save}) {
    if (_editingRowIndex == null || _editingColumnKey == null) return;

    if (save && widget.onCellChanged != null && _cellController != null) {
      final newValue = _cellController!.text;
      final oldValue = _originalCellValue?.toString() ?? '';

      if (newValue != oldValue) {
        widget.onCellChanged!(
          widget.data[_editingRowIndex!],
          _editingColumnKey!,
          _editingRowIndex!,
          _originalCellValue,
          newValue,
        );
      }
    }

    setState(() {
      _editingRowIndex = null;
      _editingColumnKey = null;
      _originalCellValue = null;
      // Don't dispose the controller here, it will be disposed on next cell tap or widget dispose
    });
  }

  /// Check if a specific cell is being edited.
  bool _isCellEditing(int rowIndex, String columnKey) {
    return _editingRowIndex == rowIndex && _editingColumnKey == columnKey;
  }

  /// Get the controller for a cell being edited.
  TextEditingController? _getCellController(int rowIndex, String columnKey) {
    if (_isCellEditing(rowIndex, columnKey)) {
      return _cellController;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get ordered columns
    final orderedColumns = _getOrderedColumns();

    if (orderedColumns.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = widget.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Calculate column widths
        final columnWidths =
            _calculateColumnWidths(availableWidth, orderedColumns);

        final totalColumnWidth =
            columnWidths.fold(0.0, (sum, width) => sum + width);

        // Actual content width (can be wider than available space for horizontal scroll)
        final double contentWidth = max(totalColumnWidth, availableWidth);

        // Calculate table data height
        final double tableDataHeight = _cachedTotalDataHeight;

        // Total content height for scrollbar calculation
        final double totalContentHeight =
            theme.headerTheme.height + tableDataHeight;

        return SyncedScrollControllers(
          builder: (
            context,
            verticalScrollController,
            verticalScrollbarController,
            horizontalScrollController,
            horizontalScrollbarController,
          ) {
            // Determine if scrolling is needed
            final bool needsVerticalScroll =
                totalContentHeight > availableHeight;
            final bool needsHorizontalScroll = contentWidth > availableWidth;

            return MouseRegion(
              onEnter: (_) => _isHovered.value = true,
              onExit: (_) => _isHovered.value = false,
              child: ScrollConfiguration(
                // Hide default Flutter scrollbars
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          children: [
                            // Scrollable Header
                            TablePlusHeader<T>(
                              columns: orderedColumns,
                              columnWidths: columnWidths,
                              totalWidth: contentWidth,
                              theme: theme.headerTheme,
                              tooltipTheme: theme.tooltipTheme,
                              checkboxTheme: theme.checkboxTheme,
                              isSelectable: widget.isSelectable,
                              selectionMode: widget.selectionMode,
                              selectedRows: widget.selectedRows,
                              sortCycleOrder: widget.sortCycleOrder,
                              totalRowCount: _cachedTotalRowCount,
                              onSelectAll: widget.onSelectAll,
                              onColumnReorder: widget.onColumnReorder,
                              resizable: widget.resizable,
                              onColumnResize: _handleColumnResize,
                              onColumnResizeEnd: _handleColumnResizeEnd,
                              onColumnAutoFit: _handleColumnAutoFit,
                              sortColumnKey: widget.sortColumnKey,
                              sortDirection: widget.sortDirection,
                              onSort: widget.onSort,
                            ),

                            // Scrollable Body
                            Expanded(
                              child: widget.data.isEmpty &&
                                      widget.noDataWidget != null
                                  ? widget.noDataWidget!
                                  : LayoutBuilder(
                                      builder: (context, bodyConstraints) {
                                        return SizedBox(
                                          height: max(bodyConstraints.maxHeight,
                                              tableDataHeight),
                                          child: TablePlusBody<T>(
                                            columns: orderedColumns,
                                            data: widget.data,
                                            columnWidths: columnWidths,
                                            theme: theme.bodyTheme,
                                            editableTheme: theme.editableTheme,
                                            tooltipTheme: theme.tooltipTheme,
                                            checkboxTheme: theme.checkboxTheme,
                                            verticalController:
                                                verticalScrollController,
                                            rowId: widget.rowId,
                                            mergedGroups: widget.mergedGroups,
                                            isDimRow: widget.isDimRow,
                                            isSelectable: widget.isSelectable,
                                            selectionMode: widget.selectionMode,
                                            selectedRows: widget.selectedRows,
                                            onRowSelectionChanged:
                                                widget.onRowSelectionChanged,
                                            onCheckboxChanged:
                                                widget.onCheckboxChanged,
                                            enableDragSelection:
                                                widget.enableDragSelection,
                                            onDragSelectionUpdate:
                                                widget.onDragSelectionUpdate,
                                            onDragSelectionEnd:
                                                widget.onDragSelectionEnd,
                                            onRowDoubleTap:
                                                widget.onRowDoubleTap,
                                            onRowSecondaryTapDown:
                                                widget.onRowSecondaryTapDown,
                                            isEditable: widget.isEditable,
                                            isCellEditing: _isCellEditing,
                                            getCellController:
                                                _getCellController,
                                            onCellTap: _handleCellTap,
                                            onStopEditing: _stopEditing,
                                            onMergedCellChanged:
                                                widget.onMergedCellChanged,
                                            onMergedRowExpandToggle:
                                                widget.onMergedRowExpandToggle,
                                            calculateRowHeight:
                                                widget.calculateRowHeight,
                                            needsVerticalScroll:
                                                needsVerticalScroll,
                                            hoverButtonBuilder:
                                                widget.hoverButtonBuilder,
                                            hoverButtonPosition:
                                                widget.hoverButtonPosition,
                                            hoverButtonTheme:
                                                theme.hoverButtonTheme,
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            // Reserve space for horizontal scrollbar overlay
                            if (theme.scrollbarTheme.showHorizontal &&
                                needsHorizontalScroll)
                              SizedBox(height: theme.scrollbarTheme.trackWidth),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Scrollbar (right overlay) - starts below header
                    if (theme.scrollbarTheme.showVertical &&
                        needsVerticalScroll)
                      Positioned(
                        top: theme.headerTheme.height,
                        right: 0,
                        bottom: (theme.scrollbarTheme.showHorizontal &&
                                needsHorizontalScroll)
                            ? theme.scrollbarTheme.trackWidth
                            : 0,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isHovered,
                          builder: (context, isHovered, child) {
                            return AnimatedOpacity(
                              opacity: theme.scrollbarTheme.hoverOnly
                                  ? (isHovered
                                      ? theme.scrollbarTheme.opacity
                                      : 0.0)
                                  : theme.scrollbarTheme.opacity,
                              duration: theme.scrollbarTheme.animationDuration,
                              child: child,
                            );
                          },
                          child: Container(
                            width: theme.scrollbarTheme.trackWidth,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              border: theme.scrollbarTheme.trackBorder,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.radius ??
                                    theme.scrollbarTheme.trackWidth / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.thumbColor,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.radius ??
                                          theme.scrollbarTheme.trackWidth / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.thickness ??
                                        theme.scrollbarTheme.trackWidth * 0.7,
                                  ),
                                ),
                              ),
                              child: Scrollbar(
                                controller: verticalScrollbarController,
                                thumbVisibility: true,
                                trackVisibility: false,
                                child: SingleChildScrollView(
                                  controller: verticalScrollbarController,
                                  scrollDirection: Axis.vertical,
                                  child: SizedBox(
                                    height: needsHorizontalScroll
                                        ? tableDataHeight -
                                            theme.scrollbarTheme.trackWidth
                                        : tableDataHeight,
                                    width: theme.scrollbarTheme.trackWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Horizontal Scrollbar (bottom overlay)
                    if (theme.scrollbarTheme.showHorizontal &&
                        needsHorizontalScroll)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isHovered,
                          builder: (context, isHovered, child) {
                            return AnimatedOpacity(
                              opacity: theme.scrollbarTheme.hoverOnly
                                  ? (isHovered
                                      ? theme.scrollbarTheme.opacity
                                      : 0.0)
                                  : theme.scrollbarTheme.opacity,
                              duration: theme.scrollbarTheme.animationDuration,
                              child: child,
                            );
                          },
                          child: Container(
                            height: theme.scrollbarTheme.trackWidth,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              border: theme.scrollbarTheme.trackBorder,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.radius ??
                                    theme.scrollbarTheme.trackWidth / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.thumbColor,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.radius ??
                                          theme.scrollbarTheme.trackWidth / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.thickness ??
                                        theme.scrollbarTheme.trackWidth * 0.7,
                                  ),
                                ),
                              ),
                              child: Scrollbar(
                                controller: horizontalScrollbarController,
                                thumbVisibility: true,
                                trackVisibility: false,
                                child: SingleChildScrollView(
                                  controller: horizontalScrollbarController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: contentWidth,
                                    height: theme.scrollbarTheme.trackWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
