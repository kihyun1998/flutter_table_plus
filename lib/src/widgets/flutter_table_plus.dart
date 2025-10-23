import 'dart:math';

import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusTheme, HoverButtonPosition;
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
    this.onCheckboxChanged,
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.isEditable = false,
    this.onCellChanged,
    this.onMergedCellChanged,
    this.onRowDoubleTap,
    this.onRowSecondaryTapDown,
    this.onMergedRowExpandToggle,
    this.noDataWidget,
    this.calculateRowHeight,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.isDimRow,
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

  /// Callback when a row's selection state changes via row click.
  /// Provides the row ID and the new selection state.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when a row's selection state changes via checkbox click.
  /// Provides the row ID and the new selection state.
  /// If not provided, falls back to [onRowSelectionChanged].
  final void Function(String rowId, bool isSelected)? onCheckboxChanged;

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
  /// Provides the row ID, TapDownDetails, RenderBox for position calculations, and selection state. Only active when [isSelectable] is true.
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;

  /// Callback when a merged row group's expand/collapse state should be toggled.
  /// Provides the group ID for the group that was clicked.
  /// The parent widget should handle updating the MergedRowGroup's isExpanded state.
  final void Function(String groupId)? onMergedRowExpandToggle;

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

  /// Builder function to create custom hover buttons for each row.
  ///
  /// Called when a row is hovered, providing the row ID and row data.
  /// Should return a Widget to display as an overlay on the row.
  /// If null, no hover buttons will be displayed.
  ///
  /// The position of the buttons can be controlled via [hoverButtonPosition].
  ///
  /// Example:
  /// ```dart
  /// hoverButtonBuilder: (rowId, rowData) => Row(
  ///   mainAxisSize: MainAxisSize.min,
  ///   children: [
  ///     IconButton(
  ///       icon: Icon(Icons.edit),
  ///       onPressed: () => _editRow(rowId),
  ///     ),
  ///     IconButton(
  ///       icon: Icon(Icons.delete),
  ///       onPressed: () => _deleteRow(rowId),
  ///     ),
  ///   ],
  /// )
  /// ```
  final Widget? Function(String rowId, Map<String, dynamic> rowData)?
      hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  ///
  /// Defaults to [HoverButtonPosition.right].
  ///
  /// - [HoverButtonPosition.left]: Buttons appear on the left side
  /// - [HoverButtonPosition.center]: Buttons appear in the center
  /// - [HoverButtonPosition.right]: Buttons appear on the right side (default)
  final HoverButtonPosition hoverButtonPosition;

  /// Callback to determine if a row should be displayed as a dim row.
  /// Provides the row data and should return true if the row should be dimmed.
  /// Dim rows can have different styling as defined in [TablePlusBodyTheme].
  ///
  /// Priority: selected > dim > normal
  /// Note: Selected rows will always use selected styling, regardless of dim state.
  final bool Function(Map<String, dynamic> rowData)? isDimRow;

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
  /// Automatically adjusts checkbox theme based on selection mode.
  TablePlusTheme get _currentTheme {
    final baseTheme = widget.theme ?? TablePlusTheme.defaultTheme;

    // For single selection mode, automatically disable select-all checkbox
    if (widget.isSelectable && widget.selectionMode == SelectionMode.single) {
      return baseTheme.copyWith(
        checkboxTheme: baseTheme.checkboxTheme.copyWith(
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
    if (widget.isSelectable && _currentTheme.checkboxTheme.showCheckboxColumn) {
      final checkboxColumnWidth =
          _currentTheme.checkboxTheme.checkboxColumnWidth;
      final selectionColumn = TablePlusColumn(
        key: '__selection__', // Special key for selection column
        label: '', // Empty label, will show select-all checkbox
        order: -1, // Always first
        width: checkboxColumnWidth,
        minWidth: checkboxColumnWidth,
        maxWidth: checkboxColumnWidth,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
      );

      return [selectionColumn, ...visibleColumns];
    }

    return visibleColumns;
  }

  /// Get the height for an individual row.
  /// Returns calculated height if available, otherwise returns theme row height.
  double _getRowHeight(int index) {
    return widget.calculateRowHeight?.call(index, widget.data[index]) ??
        _currentTheme.bodyTheme.rowHeight;
  }

  /// Calculate the total height for a merged row group.
  /// Sums the heights of all rows in the group including summary row if expanded.
  double _getMergedRowHeight(MergedRowGroup mergeGroup) {
    double totalHeight = 0;
    for (final rowKey in mergeGroup.rowKeys) {
      final rowIndex = widget.data
          .indexWhere((row) => row[widget.rowIdKey]?.toString() == rowKey);
      if (rowIndex != -1) {
        totalHeight += _getRowHeight(rowIndex);
      }
    }

    // Add summary row height if expandable and expanded
    if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
      totalHeight += _currentTheme.bodyTheme.rowHeight;
    }

    return totalHeight;
  }

  /// Calculate the total height of all data rows.
  double _calculateTotalDataHeight() {
    if (widget.data.isEmpty) return 0;

    double totalHeight = 0;
    Set<int> processedIndices = {};

    for (int i = 0; i < widget.data.length; i++) {
      if (processedIndices.contains(i)) continue;

      // Check if this row is part of a merged group
      final mergeGroup = _getMergedGroupForRow(i);
      if (mergeGroup != null) {
        // Calculate merged row height using helper method
        totalHeight += _getMergedRowHeight(mergeGroup);
        // Add all merged row indices to processed set
        for (final rowKey in mergeGroup.rowKeys) {
          final rowIndex = widget.data
              .indexWhere((row) => row[widget.rowIdKey]?.toString() == rowKey);
          if (rowIndex != -1) {
            processedIndices.add(rowIndex);
          }
        }
      } else {
        // Regular row - use helper method
        totalHeight += _getRowHeight(i);
        processedIndices.add(i);
      }
    }

    return totalHeight;
  }

  /// Calculate the actual width for columns based on available space.
  List<double> _calculateColumnWidths(double availableWidth) {
    final columns = _visibleColumns;
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

  /// Get minimum width needed for all columns.
  double get _columnsMinWidth {
    return _visibleColumns.fold(0.0, (sum, col) => sum + col.minWidth);
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
        final double columnsMinWidth = _columnsMinWidth;

        // Calculate preferred width for all columns
        final double columnsPreferredWidth =
            _visibleColumns.fold(0.0, (sum, col) => sum + col.width);

        // Actual content width (can be wider than available space for horizontal scroll)
        final double contentWidth = max(
          max(columnsMinWidth, columnsPreferredWidth),
          availableWidth,
        );

        // Calculate column widths based on content width
        final List<double> columnWidths = _calculateColumnWidths(contentWidth);

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
            horizontalScrollController,
            horizontalScrollbarController,
          ) {
            // Determine if scrolling is needed
            final bool needsVerticalScroll =
                totalContentHeight > availableHeight;
            final bool needsHorizontalScroll = contentWidth > availableWidth;

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
                    SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          children: [
                            // Scrollable Header
                            TablePlusHeader(
                              columns: _visibleColumns,
                              columnWidths: columnWidths,
                              totalWidth: contentWidth,
                              theme: theme.headerTheme,
                              isSelectable: widget.isSelectable,
                              selectionMode: widget.selectionMode,
                              selectedRows: widget.selectedRows,
                              sortCycleOrder: widget.sortCycleOrder,
                              totalRowCount: _getTotalRowCount(),
                              tooltipTheme: theme.tooltipTheme,
                              checkboxTheme: theme.checkboxTheme,
                              onSelectAll: widget.onSelectAll,
                              onColumnReorder: widget.onColumnReorder,
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
                                      builder: (context, constraints) {
                                        // Ensure table has proper height for scrolling
                                        return SizedBox(
                                          height: max(constraints.maxHeight,
                                              tableDataHeight),
                                          child: TablePlusBody(
                                            columns: _visibleColumns,
                                            data: widget.data,
                                            mergedGroups: widget.mergedGroups,
                                            columnWidths: columnWidths,
                                            theme: theme.bodyTheme,
                                            needsVerticalScroll:
                                                needsVerticalScroll,
                                            verticalController:
                                                verticalScrollController,
                                            rowIdKey: widget.rowIdKey,
                                            isSelectable: widget.isSelectable,
                                            selectionMode: widget.selectionMode,
                                            selectedRows: widget.selectedRows,
                                            checkboxTheme: theme.checkboxTheme,
                                            onRowSelectionChanged:
                                                widget.onRowSelectionChanged,
                                            onCheckboxChanged:
                                                widget.onCheckboxChanged,
                                            onRowDoubleTap:
                                                widget.onRowDoubleTap,
                                            onRowSecondaryTapDown:
                                                widget.onRowSecondaryTapDown,
                                            isEditable: widget.isEditable,
                                            editableTheme: theme.editableTheme,
                                            tooltipTheme: theme.tooltipTheme,
                                            isCellEditing: _isCellEditing,
                                            getCellController:
                                                _getCellController,
                                            onCellTap: _handleCellTap,
                                            onStopEditing: _stopCurrentEditing,
                                            onMergedCellChanged:
                                                widget.onMergedCellChanged,
                                            onMergedRowExpandToggle:
                                                widget.onMergedRowExpandToggle,
                                            calculateRowHeight:
                                                widget.calculateRowHeight,
                                            hoverButtonBuilder:
                                                widget.hoverButtonBuilder,
                                            hoverButtonPosition:
                                                widget.hoverButtonPosition,
                                            hoverButtonTheme:
                                                theme.hoverButtonTheme,
                                            isDimRow: widget.isDimRow,
                                          ),
                                        );
                                      },
                                    ),
                            ),
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
                        child: AnimatedOpacity(
                          opacity: theme.scrollbarTheme.hoverOnly
                              ? (_isHovered
                                  ? theme.scrollbarTheme.opacity
                                  : 0.0)
                              : theme.scrollbarTheme.opacity,
                          duration: theme.scrollbarTheme.animationDuration,
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

                    // Horizontal Scrollbar (bottom overlay) - only for scrollable area
                    if (theme.scrollbarTheme.showHorizontal &&
                        needsHorizontalScroll)
                      Positioned(
                        left: 0,
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
