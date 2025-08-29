import 'package:example/helper/table_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/sample_data.dart';
import '../widgets/column_visibility_controls.dart';
import '../widgets/example_documentation.dart';
import '../widgets/table_app_bar.dart';
import '../widgets/table_controls.dart';
import '../widgets/table_status_indicators.dart';

class TableExamplePage extends StatefulWidget {
  const TableExamplePage({super.key});

  @override
  State<TableExamplePage> createState() => _TableExamplePageState();
}

class _TableExamplePageState extends State<TableExamplePage> {
  bool _isSelectable = false;
  SelectionMode _selectionMode = SelectionMode.multiple;
  final SortCycleOrder _sortCycleOrder = SortCycleOrder.ascendingFirst;
  final Set<String> _selectedRows = <String>{};
  bool _showVerticalDividers = true;
  bool _isEditable = false;
  bool _isReorderable = true;
  bool _isSortable = true;
  bool _showNoDataExample = false;
  TextOverflow _textOverflow = TextOverflow.ellipsis;

  // Sort state
  String? _sortColumnKey;
  SortDirection _sortDirection = SortDirection.none;
  List<Map<String, dynamic>> _sortedData = [];

  late Map<String, TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    _columns = TableHelper.initializeColumns();
    _columns = TableHelper.updateColumnsTextOverflow(_columns, _textOverflow);
    _sortedData = TableHelper.initializeSortedData();
  }

  /// Handle sort callback
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      if (direction == SortDirection.none) {
        // Reset to original order
        _sortColumnKey = null;
        _sortDirection = SortDirection.none;
        _sortedData = TableHelper.initializeSortedData();
      } else {
        // Sort data
        _sortColumnKey = columnKey;
        _sortDirection = direction;
        TableHelper.sortData(_sortedData, columnKey, direction);
      }
    });

    // Show feedback
    String message;
    switch (direction) {
      case SortDirection.ascending:
        message = 'Sorted by $columnKey (A-Z)';
        break;
      case SortDirection.descending:
        message = 'Sorted by $columnKey (Z-A)';
        break;
      case SortDirection.none:
        message = 'Sort cleared - showing original order';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Handle cell value change in editable mode
  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    // Convert newValue based on column type
    dynamic convertedValue = newValue;
    setState(() {
      if (columnKey == 'salary') {
        // Convert salary string to int (remove commas and dollar signs)
        final cleanValue = newValue.toString().replaceAll(RegExp(r'[^\d]'), '');
        convertedValue = int.tryParse(cleanValue) ?? oldValue;
      } else if (columnKey == 'active') {
        // Convert status string to boolean
        final lowerValue = newValue.toString().toLowerCase();
        if (lowerValue == 'true' ||
            lowerValue == 'active' ||
            lowerValue == '1') {
          convertedValue = true;
        } else if (lowerValue == 'false' ||
            lowerValue == 'inactive' ||
            lowerValue == '0') {
          convertedValue = false;
        } else {
          convertedValue = oldValue; // Keep old value if can't parse
        }
      } else if (columnKey == 'age') {
        // Convert age string to int
        convertedValue = int.tryParse(newValue.toString()) ?? oldValue;
      }

      // Update the data
      _sortedData[rowIndex][columnKey] = convertedValue;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated $columnKey: "$oldValue" → "$convertedValue"'),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  /// Handle row selection change
  void _onRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (_selectionMode == SelectionMode.single) {
        // Single selection mode: clear all other selections first
        if (isSelected) {
          _selectedRows.clear();
          _selectedRows.add(rowId);
        } else {
          _selectedRows.remove(rowId);
        }
      } else {
        // Multiple selection mode: normal toggle behavior
        if (isSelected) {
          _selectedRows.add(rowId);
        } else {
          _selectedRows.remove(rowId);
        }
      }
    });
  }

  /// Handle select all/none
  void _onSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedRows.clear();
        _selectedRows.addAll(
          _sortedData.map((row) => row['id'].toString()),
        );
      } else {
        _selectedRows.clear();
      }
    });
  }

  /// Handle column reorder
  void _onColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Get visible columns (excluding selection column) sorted by order
      final visibleColumns = _columns.values
          .where((col) => col.visible)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (oldIndex < 0 ||
          oldIndex >= visibleColumns.length ||
          newIndex < 0 ||
          newIndex >= visibleColumns.length) {
        return;
      }

      // Get the column being moved
      final movingColumn = visibleColumns[oldIndex];

      // Create new builder with all existing columns
      final builder = TableColumnsBuilder();

      // Add all columns in their current order
      for (final column in _columns.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order))) {
        builder.addColumn(column.key, column);
      }

      // Use builder's reorderColumn method to handle the complex logic
      final targetOrder = newIndex + 1; // Convert to 1-based order
      builder.reorderColumn(movingColumn.key, targetOrder);

      print("m:: ${movingColumn.order}");

      _columns = builder.build();
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Column reordered: ${oldIndex + 1} → ${newIndex + 1}'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectable = !_isSelectable;
      if (!_isSelectable) {
        _selectedRows.clear();
      }
    });
  }

  /// Toggle between single and multiple selection modes
  void _toggleSelectionModeType() {
    setState(() {
      _selectionMode = _selectionMode == SelectionMode.single
          ? SelectionMode.multiple
          : SelectionMode.single;
      // Clear selections when switching modes
      _selectedRows.clear();
    });
  }

  /// Handle column visibility change
  void _handleColumnVisibilityChanged(String columnKey, bool visible) {
    setState(() {
      _columns =
          TableHelper.updateColumnVisibility(_columns, columnKey, visible);
    });

    // Show feedback
    final column = _columns[columnKey];
    final columnLabel = column?.label ?? columnKey;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Column "$columnLabel" ${visible ? 'shown' : 'hidden'}'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Show column visibility dialog
  void _showColumnVisibilityDialog() {
    ColumnVisibilityDialog.show(
      context,
      columns: _columns,
      onColumnVisibilityChanged: _handleColumnVisibilityChanged,
    );
  }

  /// Toggle editing mode
  void _toggleEditingMode() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  /// Toggle vertical dividers
  void _toggleVerticalDividers() {
    setState(() {
      _showVerticalDividers = !_showVerticalDividers;
    });
  }

  /// Toggle column reordering
  void _toggleColumnReordering() {
    setState(() {
      _isReorderable = !_isReorderable;
    });
  }

  /// Toggle sorting
  void _toggleSorting() {
    setState(() {
      _isSortable = !_isSortable;
      if (!_isSortable) {
        // 정렬이 비활성화되면 현재 정렬 상태를 초기화
        _sortColumnKey = null;
        _sortDirection = SortDirection.none;
        _sortedData = TableHelper.initializeSortedData();
      }
    });
  }

  /// Clear all selections
  void _clearSelections() {
    setState(() => _selectedRows.clear());
  }

  /// Select active employees only
  void _selectActiveEmployees() {
    setState(() {
      _selectedRows.clear();
      _selectedRows.addAll(
        SampleData.activeEmployees.map((e) => e.id.toString()),
      );
    });
  }

  /// Get selected employee names
  List<String> get _selectedNames {
    return TableHelper.getSelectedNames(_sortedData, _selectedRows);
  }

  /// Get current table theme based on settings
  TablePlusTheme get _currentTheme {
    return TableHelper.getCurrentTheme(
        showVerticalDividers: _showVerticalDividers);
  }

  /// Show selected employees dialog
  void _showSelectedEmployees() {
    TableHelper.showSelectedEmployeesDialog(
        context, _selectedRows.length, _selectedNames);
  }

  /// Reset column order to default
  void _resetColumnOrder() {
    setState(() {
      _columns = TableHelper.initializeColumns();
      _columns = TableHelper.updateColumnsTextOverflow(_columns, _textOverflow);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Column order reset to default'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  /// Reset sort to original order
  void _resetSort() {
    setState(() {
      _sortColumnKey = null;
      _sortDirection = SortDirection.none;
      _sortedData = TableHelper.initializeSortedData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sort cleared - showing original order'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  /// Toggle no data example
  void _toggleNoDataExample() {
    setState(() {
      _showNoDataExample = !_showNoDataExample;
    });
  }

  /// Change text overflow setting
  void _changeTextOverflow(TextOverflow newOverflow) {
    setState(() {
      _textOverflow = newOverflow;
      // Update all columns with new text overflow setting
      _columns = TableHelper.updateColumnsTextOverflow(_columns, newOverflow);
    });
  }

  /// Toggle row height mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TableAppBarActions(
            sortColumnKey: _sortColumnKey,
            isSelectable: _isSelectable,
            selectionMode: _selectionMode,
            isEditable: _isEditable,
            isReorderable: _isReorderable,
            isSortable: _isSortable,
            showVerticalDividers: _showVerticalDividers,
            showNoDataExample: _showNoDataExample,
            textOverflow: _textOverflow,
            onResetSort: _resetSort,
            onResetColumnOrder: _resetColumnOrder,
            onToggleVerticalDividers: _toggleVerticalDividers,
            onToggleEditingMode: _toggleEditingMode,
            onToggleSelectionMode: _toggleSelectionMode,
            onToggleSelectionModeType: _toggleSelectionModeType,
            onToggleColumnReordering: _toggleColumnReordering,
            onToggleSorting: _toggleSorting,
            onShowColumnVisibilityDialog: _showColumnVisibilityDialog,
            onToggleNoDataExample: _toggleNoDataExample,
            onChangeTextOverflow: _changeTextOverflow,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Employee Directory',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Status indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing ${_showNoDataExample ? 0 : _sortedData.length} employees',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 8),
                TableStatusIndicators(
                  sortColumnKey: _sortColumnKey,
                  sortDirection: _sortDirection,
                  isSelectable: _isSelectable,
                  selectionMode: _selectionMode,
                  selectedCount: _selectedRows.length,
                  isEditable: _isEditable,
                  isReorderable: _isReorderable,
                  isSortable: _isSortable,
                  visibleColumnCount:
                      TableHelper.getVisibleColumnCount(_columns),
                  totalColumnCount: _columns.length,
                ),
              ],
            ),

            // Controls
            TableControls(
              isSelectable: _isSelectable,
              selectedCount: _selectedRows.length,
              selectedNames: _selectedNames,
              onClearSelections: _clearSelections,
              onSelectActive: _selectActiveEmployees,
              onShowSelected: _showSelectedEmployees,
            ),

            // Column Visibility Controls
            ColumnVisibilityControls(
              columns: _columns,
              onColumnVisibilityChanged: _handleColumnVisibilityChanged,
            ),

            // Table with fixed height
            SizedBox(
              height: 800, // Fixed height for table
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _showNoDataExample
                        ? []
                        : _sortedData, // Use empty data when demonstrating no data
                    isSelectable: _isSelectable,
                    selectionMode: _selectionMode,
                    selectedRows: _selectedRows,
                    sortCycleOrder: _sortCycleOrder,
                    onRowSelectionChanged: _onRowSelectionChanged,
                    onSelectAll: _onSelectAll,
                    onColumnReorder: _isReorderable ? _onColumnReorder : null,
                    theme: _currentTheme,
                    // Sort-related properties
                    sortColumnKey: _sortColumnKey,
                    sortDirection: _sortDirection,
                    onSort: _isSortable ? _handleSort : null,
                    // Editing-related properties
                    isEditable: _isEditable,
                    onCellChanged: _handleCellChanged,
                    onRowDoubleTap: (rowId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Double-tapped row: $rowId'),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    onRowSecondaryTap: (rowId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Secondary-tapped row: $rowId'),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    // No data widget
                    noDataWidget: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No employees found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'There are no employees to display in the table.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Documentation section
            ExampleDocumentation(
              showVerticalDividers: _showVerticalDividers,
              isSelectable: _isSelectable,
              isEditable: _isEditable,
            ),

            const SizedBox(height: 32), // Extra space at bottom
          ],
        ),
      ),
    );
  }
}
