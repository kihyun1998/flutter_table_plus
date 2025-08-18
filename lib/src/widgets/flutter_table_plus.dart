import 'dart:math';

import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import 'synced_scroll_controllers.dart';
import 'table_body.dart';
import 'table_header.dart';

/// A highly customizable and efficient table widget for Flutter.
///
/// This widget provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
///
/// ⚠️ **Important for selection feature:**
/// Each row data must have a unique field for row identification when using selection features.
/// By default, uses 'id' field, but can be customized with [rowIdKey] parameter.
/// Duplicate IDs will cause unexpected selection behavior.
class FlutterTablePlus extends StatefulWidget {
  /// Creates a [FlutterTablePlus] with the specified configuration.
  const FlutterTablePlus({
    super.key,
    required this.columns,
    required this.data,
    this.mergedGroups = const [],
    this.theme,
    this.rowIdKey = 'id',
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.onRowSelectionChanged,
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.isEditable = false,
    this.onCellChanged,
    this.onMergedCellChanged,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.noDataWidget,
    this.calculateRowHeight,
  });

  /// The map of columns to display in the table.
  /// Columns are ordered by their `order` field in ascending order.
  /// Use [TableColumnsBuilder] to easily create ordered columns without conflicts.
  final Map<String, TablePlusColumn> columns;

  /// The data to display in the table.
  /// Each map represents a row, with keys corresponding to column keys.
  ///
  /// ⚠️ **For selection features**: Each row must have a unique field matching [rowIdKey].
  final List<Map<String, dynamic>> data;

  /// List of merged row groups configuration.
  final List<MergedRowGroup> mergedGroups;

  /// The theme configuration for the table.
  /// If not provided, [TablePlusTheme.defaultTheme] will be used.
  final TablePlusTheme? theme;

  /// The key used to extract row IDs from row data.
  /// Defaults to 'id'. Each row must have a unique value for this key when using selection features.
  final String rowIdKey;

  /// Whether the table supports row selection.
  /// When true, adds selection checkboxes and enables row selection.
  final bool isSelectable;

  /// The selection mode for the table.
  /// [SelectionMode.multiple] allows multiple rows to be selected simultaneously.
  /// [SelectionMode.single] allows only one row to be selected at a time.
  /// Only used when [isSelectable] is true.
  final SelectionMode selectionMode;

  /// The set of currently selected row IDs.
  /// Row IDs are extracted from `rowData['id']`.
  final Set<String> selectedRows;

  /// The order in which sort directions cycle when a column header is clicked.
  /// Defaults to [SortCycleOrder.ascendingFirst].
  final SortCycleOrder sortCycleOrder;

  /// Callback when a row's selection state changes.
  /// Provides the row ID and the new selection state.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when the select-all state changes.
  /// Called when the header checkbox is toggled.
  final void Function(bool selectAll)? onSelectAll;

  /// Callback when columns are reordered via drag and drop.
  /// Provides the old index and new index of the reordered column.
  /// Note: Selection column (if present) is excluded from reordering.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// The key of the currently sorted column.
  /// If null, no column is currently sorted.
  final String? sortColumnKey;

  /// The current sort direction for the sorted column.
  /// Ignored if [sortColumnKey] is null.
  final SortDirection sortDirection;

  /// Callback when a sortable column header is clicked.
  /// Provides the column key and the requested sort direction.
  ///
  /// The table widget does not handle sorting internally - it's up to the
  /// parent widget to sort the data and update [sortColumnKey] and [sortDirection].
  final void Function(String columnKey, SortDirection direction)? onSort;

  /// Whether the table supports cell editing.
  /// When true, cells in columns marked as `editable` can be edited by clicking on them.
  /// Note: Row selection via row click is disabled in editable mode.
  final bool isEditable;

  /// Callback when a cell value is changed in editable mode.
  /// Provides the column key, row index, old value, and new value.
  ///
  /// This callback is triggered when:
  /// - Enter key is pressed
  /// - Escape key is pressed (reverts to old value)
  /// - The text field loses focus
  final CellChangedCallback? onCellChanged;

  /// Callback when a merged cell value is changed.
  /// Provides the group ID, column key, and new value.
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;

  /// Callback when a row is double-tapped.
  /// Provides the row ID. Only active when [isSelectable] is true.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked (or long-pressed on touch devices).
  /// Provides the row ID. Only active when [isSelectable] is true.
  final void Function(String rowId)? onRowSecondaryTap;

  /// Widget to display when there is no data to show in the table.
  /// If not provided, nothing will be displayed when data is empty.
  final Widget? noDataWidget;

  /// Callback to calculate the height of a specific row.
  /// Provides row index and row data, and should return the height for that row.
  /// If null, uses the fixed row height from the theme.
  ///
  /// This is useful for supporting TextOverflow.visible or other dynamic height needs.
  /// The calculation should be efficient as it may be called frequently.
  final double? Function(int rowIndex, Map<String, dynamic> rowData)?
      calculateRowHeight;

  @override
  State<FlutterTablePlus> createState() => _FlutterTablePlusState();
}

class _FlutterTablePlusState extends State<FlutterTablePlus> {
  bool _isHovered = false;

  /// Current editing state: {rowIndex: {columnKey: TextEditingController}}
  final Map<int, Map<String, TextEditingController>> _editingControllers = {};

  /// Current editing cell: {rowIndex, columnKey}
  ({int rowIndex, String columnKey})? _currentEditingCell;

  @override
  void initState() {
    super.initState();
    _validateUniqueIds();
  }

  @override
  void didUpdateWidget(FlutterTablePlus oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data != oldWidget.data) {
      _validateUniqueIds();
      _clearAllEditing(); // Clear editing state when data changes
    }
  }

  @override
  void dispose() {
    _clearAllEditing();
    super.dispose();
  }

  /// Clear all editing controllers and state
  void _clearAllEditing() {
    for (final rowControllers in _editingControllers.values) {
      for (final controller in rowControllers.values) {
        controller.dispose();
      }
    }
    _editingControllers.clear();
    _currentEditingCell = null;
  }

  /// Start editing a cell
  void _startEditingCell(int rowIndex, String columnKey) {
    if (!widget.isEditable) return;

    final column = widget.columns[columnKey];
    if (column == null || !column.editable) return;

    // Stop current editing first
    _stopCurrentEditing(save: true);

    // Get current value
    final currentValue = widget.data[rowIndex][columnKey]?.toString() ?? '';

    // Create controller for this cell
    _editingControllers[rowIndex] ??= {};
    _editingControllers[rowIndex]![columnKey] =
        TextEditingController(text: currentValue);

    // Set current editing cell
    _currentEditingCell = (rowIndex: rowIndex, columnKey: columnKey);

    setState(() {});

    // Focus the text field after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _editingControllers[rowIndex]?[columnKey];
      if (controller != null) {
        // Select all text when starting to edit
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });
  }

  /// Stop current editing
  void _stopCurrentEditing({required bool save}) {
    final currentCell = _currentEditingCell;
    if (currentCell == null) return;

    final controller =
        _editingControllers[currentCell.rowIndex]?[currentCell.columnKey];
    if (controller == null) return;

    if (save && widget.onCellChanged != null) {
      final oldValue = widget.data[currentCell.rowIndex][currentCell.columnKey];
      final newValue = controller.text;

      // Only call callback if value actually changed
      if (oldValue?.toString() != newValue) {
        widget.onCellChanged!(
          currentCell.columnKey,
          currentCell.rowIndex,
          oldValue,
          newValue,
        );
      }
    }

    // Clean up controller
    controller.dispose();
    _editingControllers[currentCell.rowIndex]?.remove(currentCell.columnKey);
    if (_editingControllers[currentCell.rowIndex]?.isEmpty == true) {
      _editingControllers.remove(currentCell.rowIndex);
    }

    _currentEditingCell = null;
    setState(() {});
  }

  /// Check if a cell is currently being edited
  bool _isCellEditing(int rowIndex, String columnKey) {
    return _currentEditingCell?.rowIndex == rowIndex &&
        _currentEditingCell?.columnKey == columnKey;
  }

  /// Get the text editing controller for a cell
  TextEditingController? _getCellController(int rowIndex, String columnKey) {
    return _editingControllers[rowIndex]?[columnKey];
  }

  /// Handle cell tap for editing
  void _handleCellTap(int rowIndex, String columnKey) {
    if (!widget.isEditable) return;
    _startEditingCell(rowIndex, columnKey);
  }

  /// Validates that all row IDs are unique when selection is enabled.
  /// ⚠️ This check only runs in debug mode for performance.
  void _validateUniqueIds() {
    if (!widget.isSelectable) return;

    assert(() {
      final ids = widget.data
          .map((row) => row[widget.rowIdKey]?.toString())
          .where((id) => id != null)
          .toList();

      final uniqueIds = ids.toSet();

      if (ids.length != uniqueIds.length) {
        final duplicates = <String>[];
        for (final id in ids) {
          if (ids.where((x) => x == id).length > 1 &&
              !duplicates.contains(id)) {
            duplicates.add(id!);
          }
        }
      }

      return true;
    }());
  }

  /// Get the current theme, using default if not provided.
  /// Automatically adjusts selection theme based on selection mode.
  TablePlusTheme get _currentTheme {
    final baseTheme = widget.theme ?? TablePlusTheme.defaultTheme;

    // For single selection mode, automatically disable select-all checkbox
    if (widget.isSelectable && widget.selectionMode == SelectionMode.single) {
      return baseTheme.copyWith(
        selectionTheme: baseTheme.selectionTheme.copyWith(
          showSelectAllCheckbox: false,
        ),
      );
    }

    return baseTheme;
  }

  /// Get only visible columns, including selection column if enabled.
  /// Columns are sorted by their order field in ascending order.
  List<TablePlusColumn> get _visibleColumns {
    // Get visible columns from the map and sort by order
    final visibleColumns = widget.columns.values
        .where((col) => col.visible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Add selection column at the beginning if selectable
    if (widget.isSelectable &&
        _currentTheme.selectionTheme.showCheckboxColumn) {
      final selectionColumn = TablePlusColumn(
        key: '__selection__', // Special key for selection column
        label: '', // Empty label, will show select-all checkbox
        order: -1, // Always first
        width: _currentTheme.selectionTheme.checkboxColumnWidth,
        minWidth: _currentTheme.selectionTheme.checkboxColumnWidth,
        maxWidth: _currentTheme.selectionTheme.checkboxColumnWidth,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        frozen: true, // Selection column is always frozen
      );

      return [selectionColumn, ...visibleColumns];
    }

    return visibleColumns;
  }

  /// Get frozen columns from visible columns.
  /// Frozen columns are displayed on the left side and don't scroll horizontally.
  /// Selection column (if present) is automatically frozen.
  List<TablePlusColumn> get _frozenColumns {
    return _visibleColumns.where((col) => col.frozen).toList();
  }

  /// Get scrollable columns from visible columns.
  /// Scrollable columns can be scrolled horizontally.
  List<TablePlusColumn> get _scrollableColumns {
    return _visibleColumns.where((col) => !col.frozen).toList();
  }

  /// Calculate the total height of all data rows.
  double _calculateTotalDataHeight() {
    if (widget.data.isEmpty) return 0;

    double totalHeight = 0;

    if (widget.calculateRowHeight != null) {
      // Use dynamic height calculation
      Set<int> processedIndices = {};

      for (int i = 0; i < widget.data.length; i++) {
        if (processedIndices.contains(i)) continue;

        // Check if this row is part of a merged group
        final mergeGroup = _getMergedGroupForRow(i);
        if (mergeGroup != null) {
          // Calculate merged row height (sum of all rows in the group)
          double mergedHeight = 0;
          for (final rowKey in mergeGroup.rowKeys) {
            final rowIndex = widget.data.indexWhere(
                (row) => row[widget.rowIdKey]?.toString() == rowKey);
            if (rowIndex != -1) {
              final height =
                  widget.calculateRowHeight!(rowIndex, widget.data[rowIndex]);
              if (height != null) {
                mergedHeight += height;
              } else {
                mergedHeight += _currentTheme.bodyTheme.rowHeight; // fallback
              }
              processedIndices.add(rowIndex);
            }
          }
          totalHeight += mergedHeight;
        } else {
          // Regular row
          final height = widget.calculateRowHeight!(i, widget.data[i]);
          totalHeight +=
              height ?? _currentTheme.bodyTheme.rowHeight; // fallback
          processedIndices.add(i);
        }
      }
    } else {
      // Use fixed row height from theme for all displayable rows
      final displayedRowCount = _getTotalRowCount();
      totalHeight = displayedRowCount * _currentTheme.bodyTheme.rowHeight;
    }

    return totalHeight;
  }

  /// Calculate the actual width for frozen columns.
  List<double> _calculateFrozenColumnWidths() {
    final frozenColumns = _frozenColumns;
    if (frozenColumns.isEmpty) return [];

    // For frozen columns, ensure they meet minimum width requirements
    return frozenColumns.map((col) => max(col.width, col.minWidth)).toList();
  }

  /// Calculate the actual width for scrollable columns based on available space.
  List<double> _calculateScrollableColumnWidths(double availableWidth) {
    final scrollableColumns = _scrollableColumns;
    if (scrollableColumns.isEmpty) return [];

    // Ensure available width is at least the minimum required
    final minRequiredWidth =
        scrollableColumns.fold(0.0, (sum, col) => sum + col.minWidth);
    final actualAvailableWidth = max(availableWidth, minRequiredWidth);

    // Calculate widths for scrollable columns using existing logic
    return _calculateRegularColumnWidths(
        scrollableColumns, actualAvailableWidth);
  }

  /// Get total width needed for frozen columns.
  double get _frozenColumnsWidth {
    return _frozenColumns.fold(
        0.0, (sum, col) => sum + max(col.width, col.minWidth));
  }

  /// Get minimum width needed for scrollable columns.
  double get _scrollableColumnsMinWidth {
    return _scrollableColumns.fold(0.0, (sum, col) => sum + col.minWidth);
  }

  /// Get the total number of displayed rows considering merged groups.
  /// Each merged group counts as 1 displayed row, regardless of how many data rows it contains.
  /// This count is used for both selection features and sort functionality.
  int _getTotalRowCount() {
    if (widget.data.isEmpty) return 0;

    Set<int> processedIndices = {};
    int totalCount = 0;

    for (int i = 0; i < widget.data.length; i++) {
      if (processedIndices.contains(i)) continue;

      // Check if this row is part of a merged group
      final mergeGroup = _getMergedGroupForRow(i);
      if (mergeGroup != null) {
        // This row is part of a merged group - count as 1 displayed row
        totalCount++;
        for (final rowKey in mergeGroup.rowKeys) {
          final rowIndex = widget.data
              .indexWhere((row) => row[widget.rowIdKey]?.toString() == rowKey);
          if (rowIndex != -1) {
            processedIndices.add(rowIndex);
          }
        }
      } else {
        // Regular row - count as 1 displayed row
        totalCount++;
        processedIndices.add(i);
      }
    }

    return totalCount;
  }

  /// Find the merged group that contains the specified row index.
  MergedRowGroup? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= widget.data.length) return null;
    final rowData = widget.data[rowIndex];
    final rowKey = rowData[widget.rowIdKey]?.toString();
    if (rowKey == null) return null;

    for (final group in widget.mergedGroups) {
      if (group.rowKeys.contains(rowKey)) {
        return group;
      }
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    final theme = _currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Calculate minimum required widths
        final double scrollableMinWidth = _scrollableColumnsMinWidth;

        // Calculate actual frozen width (preferred or minimum)
        final double frozenWidth = _frozenColumnsWidth;

        // Calculate scrollable area width (ensure it's not negative)
        final double scrollableAreaWidth = max(0, availableWidth - frozenWidth);

        // Calculate column widths for each area
        final List<double> frozenColumnWidths = _calculateFrozenColumnWidths();

        // Calculate preferred width for scrollable columns
        final double scrollablePreferredWidth =
            _scrollableColumns.fold(0.0, (sum, col) => sum + col.width);

        // Actual scrollable content width (can be wider than available space for horizontal scroll)
        final double scrollableContentWidth = max(
          max(scrollableMinWidth, scrollablePreferredWidth),
          scrollableAreaWidth,
        );

        // Calculate scrollable column widths based on content width (not area width!)
        final List<double> scrollableColumnWidths =
            _calculateScrollableColumnWidths(scrollableContentWidth);

        // Calculate table data height
        final double tableDataHeight = _calculateTotalDataHeight();

        // Total content height for scrollbar calculation
        final double totalContentHeight =
            theme.headerTheme.height + tableDataHeight;

        return SyncedScrollControllers(
          builder: (
            context,
            verticalScrollController,
            verticalScrollbarController,
            verticalFrozenController,
            horizontalScrollController,
            horizontalScrollbarController,
          ) {
            // Determine if scrolling is needed
            final bool needsVerticalScroll =
                totalContentHeight > availableHeight;
            final bool needsHorizontalScroll =
                scrollableContentWidth > scrollableAreaWidth;

            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: ScrollConfiguration(
                // Hide default Flutter scrollbars
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: Stack(
                  children: [
                    // Main table area with Row layout (frozen + scrollable)
                    Row(
                      children: [
                        // Frozen Area (left side)
                        if (_frozenColumns.isNotEmpty)
                          SizedBox(
                            width: frozenWidth,
                            child: Column(
                              children: [
                                // Frozen Header
                                TablePlusHeader(
                                  columns: _frozenColumns,
                                  totalWidth: frozenWidth,
                                  theme: theme.headerTheme,
                                  isSelectable: widget.isSelectable,
                                  selectionMode: widget.selectionMode,
                                  selectedRows: widget.selectedRows,
                                  sortCycleOrder: widget.sortCycleOrder,
                                  totalRowCount: _getTotalRowCount(),
                                  selectionTheme: theme.selectionTheme,
                                  tooltipTheme: theme.tooltipTheme,
                                  onSelectAll: widget.onSelectAll,
                                  onColumnReorder:
                                      null, // Disable reordering for frozen area
                                  sortColumnKey: widget.sortColumnKey,
                                  sortDirection: widget.sortDirection,
                                  onSort: widget.onSort,
                                ),

                                // Frozen Body
                                Expanded(
                                  child: widget.data.isEmpty &&
                                          widget.noDataWidget != null
                                      ? widget.noDataWidget!
                                      : LayoutBuilder(
                                          builder: (context, constraints) {
                                            // Ensure both areas have the same vertical scroll extent
                                            return SizedBox(
                                              height: max(constraints.maxHeight,
                                                  tableDataHeight),
                                              child: TablePlusBody(
                                                columns: _frozenColumns,
                                                data: widget.data,
                                                mergedGroups:
                                                    widget.mergedGroups,
                                                columnWidths:
                                                    frozenColumnWidths,
                                                theme: theme.bodyTheme,
                                                verticalController:
                                                    verticalFrozenController,
                                                rowIdKey: widget.rowIdKey,
                                                needsVerticalScroll:
                                                    needsVerticalScroll,
                                                isSelectable:
                                                    widget.isSelectable,
                                                selectionMode:
                                                    widget.selectionMode,
                                                selectedRows:
                                                    widget.selectedRows,
                                                selectionTheme:
                                                    theme.selectionTheme,
                                                onRowSelectionChanged: widget
                                                    .onRowSelectionChanged,
                                                onRowDoubleTap:
                                                    widget.onRowDoubleTap,
                                                onRowSecondaryTap:
                                                    widget.onRowSecondaryTap,
                                                isEditable: widget.isEditable,
                                                editableTheme:
                                                    theme.editableTheme,
                                                tooltipTheme:
                                                    theme.tooltipTheme,
                                                isCellEditing: _isCellEditing,
                                                getCellController:
                                                    _getCellController,
                                                onCellTap: _handleCellTap,
                                                onStopEditing:
                                                    _stopCurrentEditing,
                                                onMergedCellChanged:
                                                    widget.onMergedCellChanged,
                                                calculateRowHeight:
                                                    widget.calculateRowHeight,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),

                        // Frozen Column Divider
                        if (_frozenColumns.isNotEmpty &&
                            _scrollableColumns.isNotEmpty)
                          SizedBox(
                            width: theme.dividerTheme.thickness,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Divider
                                Container(
                                  width: theme.dividerTheme.thickness,
                                  height: theme.headerTheme.height,
                                  margin: EdgeInsets.only(
                                    top: theme.dividerTheme.indent,
                                    bottom: theme.dividerTheme.endIndent,
                                  ),
                                  color: theme.dividerTheme.getEffectiveColor(),
                                ),
                                // Body Divider (flexible height)
                                if (widget.data.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      width: theme.dividerTheme.thickness,
                                      margin: EdgeInsets.only(
                                        top: theme.dividerTheme.indent,
                                        bottom: theme.dividerTheme.endIndent,
                                      ),
                                      color: theme.dividerTheme
                                          .getEffectiveColor(),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Scrollable Area (right side)
                        if (_scrollableColumns.isNotEmpty)
                          Expanded(
                            child: scrollableAreaWidth > 0
                                ? SingleChildScrollView(
                                    controller: horizontalScrollController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const ClampingScrollPhysics(),
                                    child: SizedBox(
                                      width: scrollableContentWidth,
                                      child: Column(
                                        children: [
                                          // Scrollable Header
                                          TablePlusHeader(
                                            columns: _scrollableColumns,
                                            totalWidth: scrollableContentWidth,
                                            theme: theme.headerTheme,
                                            isSelectable:
                                                false, // Selection handled in frozen area
                                            selectionMode: widget.selectionMode,
                                            selectedRows: widget.selectedRows,
                                            sortCycleOrder:
                                                widget.sortCycleOrder,
                                            totalRowCount: _getTotalRowCount(),
                                            selectionTheme:
                                                theme.selectionTheme,
                                            tooltipTheme: theme.tooltipTheme,
                                            onSelectAll:
                                                null, // Handled in frozen area
                                            onColumnReorder:
                                                widget.onColumnReorder,
                                            sortColumnKey: widget.sortColumnKey,
                                            sortDirection: widget.sortDirection,
                                            onSort: widget.onSort,
                                          ),

                                          // Scrollable Body
                                          Expanded(
                                            child: widget.data.isEmpty &&
                                                    widget.noDataWidget != null
                                                ? Container() // No data widget only shown in frozen area
                                                : LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      // Ensure both areas have the same vertical scroll extent
                                                      return SizedBox(
                                                        height: max(
                                                            constraints
                                                                .maxHeight,
                                                            tableDataHeight),
                                                        child: TablePlusBody(
                                                          columns:
                                                              _scrollableColumns,
                                                          data: widget.data,
                                                          mergedGroups: widget
                                                              .mergedGroups,
                                                          columnWidths:
                                                              scrollableColumnWidths,
                                                          theme:
                                                              theme.bodyTheme,
                                                          needsVerticalScroll:
                                                              needsVerticalScroll,
                                                          verticalController:
                                                              verticalScrollController,
                                                          rowIdKey:
                                                              widget.rowIdKey,
                                                          isSelectable:
                                                              false, // Selection handled in frozen area
                                                          selectionMode: widget
                                                              .selectionMode,
                                                          selectedRows: widget
                                                              .selectedRows,
                                                          selectionTheme: theme
                                                              .selectionTheme,
                                                          onRowSelectionChanged:
                                                              null, // Handled in frozen area
                                                          onRowDoubleTap:
                                                              null, // Handed in frozen area
                                                          onRowSecondaryTap:
                                                              null, // Handled in frozen area
                                                          isEditable:
                                                              widget.isEditable,
                                                          editableTheme: theme
                                                              .editableTheme,
                                                          tooltipTheme: theme
                                                              .tooltipTheme,
                                                          isCellEditing:
                                                              _isCellEditing,
                                                          getCellController:
                                                              _getCellController,
                                                          onCellTap:
                                                              _handleCellTap,
                                                          onStopEditing:
                                                              _stopCurrentEditing,
                                                          onMergedCellChanged:
                                                              widget
                                                                  .onMergedCellChanged,
                                                          calculateRowHeight: widget
                                                              .calculateRowHeight,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 1, // Minimal width when no space
                                    child: Column(
                                      children: [
                                        Container(
                                            height: theme.headerTheme.height),
                                        Expanded(child: Container()),
                                      ],
                                    ),
                                  ),
                          ),
                      ],
                    ),

                    // Vertical Scrollbar (right overlay) - starts below header
                    if (theme.scrollbarTheme.showVertical &&
                        needsVerticalScroll)
                      Positioned(
                        top: theme.headerTheme.height,
                        right: 0,
                        bottom: (theme.scrollbarTheme.showHorizontal &&
                                needsHorizontalScroll)
                            ? theme.scrollbarTheme.width
                            : 0,
                        child: AnimatedOpacity(
                          opacity: theme.scrollbarTheme.hoverOnly
                              ? (_isHovered
                                  ? theme.scrollbarTheme.opacity
                                  : 0.0)
                              : theme.scrollbarTheme.opacity,
                          duration: theme.scrollbarTheme.animationDuration,
                          child: Container(
                            width: theme.scrollbarTheme.width,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.width / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.color,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.width / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.width - 4,
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
                                            theme.scrollbarTheme.width
                                        : tableDataHeight,
                                    width: theme.scrollbarTheme.width,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Horizontal Scrollbar (bottom overlay) - only for scrollable area
                    if (theme.scrollbarTheme.showHorizontal &&
                        needsHorizontalScroll &&
                        _scrollableColumns.isNotEmpty)
                      Positioned(
                        left: frozenWidth, // Start after frozen area
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: theme.scrollbarTheme.hoverOnly
                              ? (_isHovered
                                  ? theme.scrollbarTheme.opacity
                                  : 0.0)
                              : theme.scrollbarTheme.opacity,
                          duration: theme.scrollbarTheme.animationDuration,
                          child: Container(
                            height: theme.scrollbarTheme.width,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.width / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.color,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.width / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.width - 4,
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
                                    width: scrollableContentWidth,
                                    height: theme.scrollbarTheme.width,
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
