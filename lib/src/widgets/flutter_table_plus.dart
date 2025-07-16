import 'dart:math';

import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';
import 'synced_scroll_controllers.dart';
import 'table_body.dart';
import 'table_header.dart';

/// A highly customizable and efficient table widget for Flutter.
///
/// This widget provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
///
/// ⚠️ **Important for selection feature:**
/// Each row data must have a unique 'id' field when using selection features.
/// Duplicate IDs will cause unexpected selection behavior.
class FlutterTablePlus extends StatefulWidget {
  /// Creates a [FlutterTablePlus] with the specified configuration.
  const FlutterTablePlus({
    super.key,
    required this.columns,
    required this.data,
    this.theme,
    this.isSelectable = false,
    this.selectedRows = const <String>{},
    this.onRowSelectionChanged,
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.isEditable = false,
    this.onCellChanged,
  });

  /// The map of columns to display in the table.
  /// Columns are ordered by their `order` field in ascending order.
  /// Use [TableColumnsBuilder] to easily create ordered columns without conflicts.
  final Map<String, TablePlusColumn> columns;

  /// The data to display in the table.
  /// Each map represents a row, with keys corresponding to column keys.
  ///
  /// ⚠️ **For selection features**: Each row must have a unique 'id' field.
  final List<Map<String, dynamic>> data;

  /// The theme configuration for the table.
  /// If not provided, [TablePlusTheme.defaultTheme] will be used.
  final TablePlusTheme? theme;

  /// Whether the table supports row selection.
  /// When true, adds selection checkboxes and enables row selection.
  final bool isSelectable;

  /// The set of currently selected row IDs.
  /// Row IDs are extracted from `rowData['id']`.
  final Set<String> selectedRows;

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
          .map((row) => row['id']?.toString())
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

        print('⚠️ FlutterTablePlus: Duplicate row IDs detected: $duplicates');
        print('   This will cause unexpected selection behavior.');
        print('   Please ensure each row has a unique "id" field.');
      }

      return true;
    }());
  }

  /// Get the current theme, using default if not provided.
  TablePlusTheme get _currentTheme =>
      widget.theme ?? TablePlusTheme.defaultTheme;

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
      );

      return [selectionColumn, ...visibleColumns];
    }

    return visibleColumns;
  }

  /// Calculate the total height of all data rows.
  double _calculateTotalDataHeight() {
    return widget.data.length * _currentTheme.bodyTheme.rowHeight;
  }

  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths(double totalWidth) {
    final visibleColumns = _visibleColumns;
    if (visibleColumns.isEmpty) return [];

    // Separate selection column from regular columns
    List<TablePlusColumn> regularColumns = [];
    TablePlusColumn? selectionColumn;

    for (final column in visibleColumns) {
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

    for (final column in visibleColumns) {
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

  @override
  Widget build(BuildContext context) {
    final visibleColumns = _visibleColumns;
    final theme = _currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Calculate minimum table width
        final double minTableWidth = visibleColumns.fold(
          0.0,
          (sum, col) => sum + col.minWidth,
        );

        // Calculate preferred table width
        final double preferredTableWidth = visibleColumns.fold(
          0.0,
          (sum, col) => sum + col.width,
        );

        // Actual content width: use preferred width, but ensure it's not smaller than minimum
        final double contentWidth = max(
          max(minTableWidth, preferredTableWidth),
          availableWidth,
        );

        // Calculate column widths for the actual content width
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
                    // Main table area (header + data integrated)
                    SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          children: [
                            // Table Header
                            TablePlusHeader(
                              columns: visibleColumns,
                              totalWidth: contentWidth,
                              theme: theme.headerTheme,
                              isSelectable: widget.isSelectable,
                              selectedRows: widget.selectedRows,
                              totalRowCount: widget.data.length,
                              selectionTheme: theme.selectionTheme,
                              onSelectAll: widget.onSelectAll,
                              onColumnReorder: widget.onColumnReorder,
                              // Sort-related properties
                              sortColumnKey: widget.sortColumnKey,
                              sortDirection: widget.sortDirection,
                              onSort: widget.onSort,
                            ),

                            // Table Data
                            Expanded(
                              child: TablePlusBody(
                                columns: visibleColumns,
                                data: widget.data,
                                columnWidths: columnWidths,
                                theme: theme.bodyTheme,
                                verticalController: verticalScrollController,
                                isSelectable: widget.isSelectable,
                                selectedRows: widget.selectedRows,
                                selectionTheme: theme.selectionTheme,
                                onRowSelectionChanged:
                                    widget.onRowSelectionChanged,
                                // Editing-related properties
                                isEditable: widget.isEditable,
                                editableTheme: theme.editableTheme,
                                isCellEditing: _isCellEditing,
                                getCellController: _getCellController,
                                onCellTap: _handleCellTap,
                                onStopEditing: _stopCurrentEditing,
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
                                    height: tableDataHeight,
                                    width: theme.scrollbarTheme.width,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Horizontal Scrollbar (bottom overlay) - full width
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
                                    width: contentWidth,
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
