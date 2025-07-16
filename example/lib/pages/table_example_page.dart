import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/sample_data.dart';
import '../widgets/table_controls.dart';

class TableExamplePage extends StatefulWidget {
  const TableExamplePage({super.key});

  @override
  State<TableExamplePage> createState() => _TableExamplePageState();
}

class _TableExamplePageState extends State<TableExamplePage> {
  bool _isSelectable = false;
  final Set<String> _selectedRows = <String>{};
  bool _showVerticalDividers = true; // 세로줄 표시 여부
  bool _isEditable = false; // 편집 모드

  // Sort state
  String? _sortColumnKey;
  SortDirection _sortDirection = SortDirection.none;
  List<Map<String, dynamic>> _sortedData = [];

  // Column reorder를 위한 컬럼 정의 (Map으로 변경)
  late Map<String, TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _initializeSortedData();
  }

  /// Initialize sorted data with original data
  void _initializeSortedData() {
    _sortedData = List.from(SampleData.employeeData);
  }

  /// Initialize columns with default order
  void _initializeColumns() {
    _columns = TableColumnsBuilder()
        .addColumn(
          'id',
          const TablePlusColumn(
            key: 'id',
            label: 'ID',
            order: 0,
            width: 60,
            minWidth: 50,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true, // Enable sorting
            editable: false, // ID는 편집 불가
          ),
        )
        .addColumn(
          'name',
          const TablePlusColumn(
            key: 'name',
            label: 'Full Name',
            order: 0,
            width: 150,
            minWidth: 120,
            sortable: true, // Enable sorting
            editable: true, // 이름은 편집 가능
          ),
        )
        .addColumn(
          'email',
          const TablePlusColumn(
            key: 'email',
            label: 'Email Address',
            order: 0,
            width: 200,
            minWidth: 150,
            sortable: true, // Enable sorting
            editable: true, // 이메일은 편집 가능
          ),
        )
        .addColumn(
          'age',
          const TablePlusColumn(
            key: 'age',
            label: 'Age',
            order: 0,
            width: 60,
            minWidth: 50,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true, // Enable sorting
            editable: true, // 나이는 편집 가능
          ),
        )
        .addColumn(
          'department',
          const TablePlusColumn(
            key: 'department',
            label: 'Department',
            order: 0,
            width: 120,
            minWidth: 100,
            sortable: true, // Enable sorting
            editable: true, // 부서는 편집 가능
          ),
        )
        .addColumn(
          'salary',
          TablePlusColumn(
            key: 'salary',
            label: 'Salary',
            order: 0,
            width: 100,
            minWidth: 80,
            textAlign: TextAlign.right,
            alignment: Alignment.centerRight,
            sortable: true, // Enable sorting
            editable: false, // cellBuilder가 있어서 편집 불가
            cellBuilder: _buildSalaryCell,
          ),
        )
        .addColumn(
          'active',
          TablePlusColumn(
            key: 'active',
            label: 'Status',
            order: 0,
            width: 80,
            minWidth: 70,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true, // Enable sorting
            editable: false, // cellBuilder가 있어서 편집 불가
            cellBuilder: _buildStatusCell,
          ),
        )
        .build();
  }

  /// Handle sort callback
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      if (direction == SortDirection.none) {
        // Reset to original order
        _sortColumnKey = null;
        _sortDirection = SortDirection.none;
        _sortedData = List.from(SampleData.employeeData);
      } else {
        // Sort data
        _sortColumnKey = columnKey;
        _sortDirection = direction;
        _sortData(columnKey, direction);
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

  /// Sort data based on column key and direction
  void _sortData(String columnKey, SortDirection direction) {
    _sortedData.sort((a, b) {
      final aValue = a[columnKey];
      final bValue = b[columnKey];

      // Handle null values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return direction == SortDirection.ascending ? -1 : 1;
      if (bValue == null) return direction == SortDirection.ascending ? 1 : -1;

      int comparison;

      // Type-specific comparison
      if (aValue is int && bValue is int) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is double && bValue is double) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is bool && bValue is bool) {
        comparison = aValue == bValue ? 0 : (aValue ? 1 : -1);
      } else {
        // String comparison (default)
        comparison = aValue.toString().toLowerCase().compareTo(
              bValue.toString().toLowerCase(),
            );
      }

      // Reverse for descending
      return direction == SortDirection.ascending ? comparison : -comparison;
    });
  }

  /// Handle cell value change in editable mode
  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      // Update the data
      _sortedData[rowIndex][columnKey] = newValue;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated $columnKey: "$oldValue" → "$newValue"'),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  /// Custom cell builder for salary
  Widget _buildSalaryCell(BuildContext context, Map<String, dynamic> rowData) {
    final salary = rowData['salary'] as int?;
    return Text(
      salary != null
          ? '\$${salary.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}'
          : '',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.green,
      ),
    );
  }

  /// Custom cell builder for status
  Widget _buildStatusCell(BuildContext context, Map<String, dynamic> rowData) {
    final isActive = rowData['active'] as bool? ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  /// Handle row selection change
  void _onRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
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
      final targetColumn = visibleColumns[newIndex];

      // Create new builder and rebuild with new order
      final builder = TableColumnsBuilder();

      // Add all columns except the moving one, adjusting orders
      for (int i = 0; i < visibleColumns.length; i++) {
        final column = visibleColumns[i];

        if (column.key == movingColumn.key) {
          continue; // Skip the moving column for now
        }

        int newOrder;
        if (oldIndex < newIndex) {
          // Moving down: shift columns up
          if (i <= oldIndex) {
            newOrder = i + 1;
          } else if (i <= newIndex) {
            newOrder = i;
          } else {
            newOrder = i + 1;
          }
        } else {
          // Moving up: shift columns down
          if (i < newIndex) {
            newOrder = i + 1;
          } else if (i < oldIndex) {
            newOrder = i + 2;
          } else {
            newOrder = i + 1;
          }
        }

        builder.addColumn(column.key, column.copyWith(order: 0));
      }

      // Insert the moved column at the new position
      final newOrder = newIndex + 1;
      builder.insertColumn(
          movingColumn.key, movingColumn.copyWith(order: 0), newOrder);

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
      // When enabling selection mode, disable editing mode
      if (_isSelectable && _isEditable) {
        _isEditable = false;
      }
    });
  }

  /// Toggle editing mode
  void _toggleEditingMode() {
    setState(() {
      _isEditable = !_isEditable;
      // When enabling editing mode, disable selection mode
      if (_isEditable && _isSelectable) {
        _isSelectable = false;
        _selectedRows.clear();
      }
    });
  }

  /// Toggle vertical dividers
  void _toggleVerticalDividers() {
    setState(() {
      _showVerticalDividers = !_showVerticalDividers;
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
    return _sortedData
        .where((row) => _selectedRows.contains(row['id'].toString()))
        .map((row) => row['name'].toString())
        .toList();
  }

  /// Get current table theme based on settings
  TablePlusTheme get _currentTheme {
    return TablePlusTheme(
      headerTheme: TablePlusHeaderTheme(
        height: 48,
        backgroundColor: Colors.blue.shade50, // 헤더 배경색 변경!
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF495057),
        ),
        showVerticalDividers: _showVerticalDividers,
        showBottomDivider: true,
        dividerColor: Colors.grey.shade300,
        // Sort styling
        sortedColumnBackgroundColor: Colors.blue.shade100,
        sortedColumnTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1976D2),
        ),
        sortIcons: const SortIcons(
          ascending:
              Icon(Icons.arrow_upward, size: 14, color: Color(0xFF1976D2)),
          descending:
              Icon(Icons.arrow_downward, size: 14, color: Color(0xFF1976D2)),
          unsorted: Icon(Icons.unfold_more, size: 14, color: Colors.grey),
        ),
      ),
      bodyTheme: TablePlusBodyTheme(
        rowHeight: 56,
        alternateRowColor: null, // null로 설정하면 모든 행이 같은 색!
        backgroundColor: Colors.white, // 모든 행이 흰색
        textStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
        ),
        showVerticalDividers: _showVerticalDividers,
        showHorizontalDividers: true,
        dividerColor: Colors.grey.shade300,
        dividerThickness: 1.0,
      ),
      scrollbarTheme: const TablePlusScrollbarTheme(
        hoverOnly: true,
        opacity: 0.8,
      ),
      selectionTheme: const TablePlusSelectionTheme(
        selectedRowColor: Color(0xFFE3F2FD),
        checkboxColor: Color(0xFF2196F3),
        checkboxSize: 18.0,
      ),
      editableTheme: const TablePlusEditableTheme(
        editingCellColor: Color(0xFFFFFDE7), // 연한 노란색
        editingTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
          fontWeight: FontWeight.w500,
        ),
        editingBorderColor: Color(0xFF2196F3), // 파란색 테두리
        editingBorderWidth: 2.0,
        editingBorderRadius: BorderRadius.all(Radius.circular(6.0)), // 둥근 모서리
        textFieldPadding:
            EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // 더 넉넉한 패딩
        cursorColor: Color(0xFF2196F3),
        textAlignVertical: TextAlignVertical.center, // 수직 가운데 정렬
        focusedBorderColor: Color(0xFF1976D2), // 포커스 시 더 진한 파란색
        enabledBorderColor: Color(0xFFBBBBBB), // 비활성 시 회색
        fillColor: Color(0xFFFFFDE7), // TextField 배경색
        filled: true, // 배경색 채우기
        isDense: true, // 컴팩트한 레이아웃
      ),
    );
  }

  /// Show selected employees dialog
  void _showSelectedEmployees() {
    SelectionDialog.show(
      context,
      selectedCount: _selectedRows.length,
      selectedNames: _selectedNames,
    );
  }

  /// Reset column order to default
  void _resetColumnOrder() {
    setState(() {
      _initializeColumns();
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
      _sortedData = List.from(SampleData.employeeData);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sort cleared - showing original order'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Reset sort button
          if (_sortColumnKey != null)
            IconButton(
              onPressed: _resetSort,
              icon: const Icon(Icons.sort_outlined),
              tooltip: 'Clear Sort',
            ),
          // Reset column order button
          IconButton(
            onPressed: _resetColumnOrder,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Column Order',
          ),
          // Toggle vertical dividers button
          IconButton(
            onPressed: _toggleVerticalDividers,
            icon: Icon(
              _showVerticalDividers
                  ? Icons.grid_on
                  : Icons.format_list_bulleted,
            ),
            tooltip: _showVerticalDividers
                ? 'Hide Vertical Lines'
                : 'Show Vertical Lines',
          ),
          // Toggle editing mode button
          IconButton(
            onPressed: _toggleEditingMode,
            icon: Icon(
              _isEditable ? Icons.edit : Icons.edit_outlined,
              color: _isEditable ? Colors.orange : null,
            ),
            tooltip: _isEditable ? 'Disable Editing' : 'Enable Editing',
          ),
          // Toggle selection mode button
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: Icon(
              _isSelectable ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            tooltip: _isSelectable ? 'Disable Selection' : 'Enable Selection',
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

            // Status info
            Row(
              children: [
                Text(
                  'Showing ${SampleData.employees.length} employees',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                if (_sortColumnKey != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sorted by $_sortColumnKey (${_sortDirection.name})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
                if (_isSelectable) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedRows.length} selected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
                if (_isEditable) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Editing Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
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

            // Table with fixed height
            SizedBox(
              height: 600, // Fixed height for table
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _sortedData, // Use sorted data instead of original
                    isSelectable: _isSelectable,
                    selectedRows: _selectedRows,
                    onRowSelectionChanged: _onRowSelectionChanged,
                    onSelectAll: _onSelectAll,
                    onColumnReorder: _onColumnReorder,
                    theme: _currentTheme,
                    // Sort-related properties
                    sortColumnKey: _sortColumnKey,
                    sortDirection: _sortDirection,
                    onSort: _handleSort,
                    // Editing-related properties
                    isEditable: _isEditable,
                    onCellChanged: _handleCellChanged,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Features info
            Text(
              'Features demonstrated:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
                '• Map-based column management with TableColumnsBuilder'),
            const Text('• Automatic order assignment and conflict prevention'),
            const Text(
                '• Custom cell builders (Salary formatting, Status badges)'),
            const Text('• Alternating row colors and responsive layout'),
            const Text('• Synchronized horizontal and vertical scrolling'),
            const Text('• Hover-based scrollbar visibility'),
            const Text('• Column width management with min/max constraints'),
            Text(
                '• Customizable table borders (${_showVerticalDividers ? "Grid" : "Horizontal only"})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple)),
            const Text('• Column reordering via drag and drop',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange)),
            const Text('• Column sorting (click header to sort: ↑ ↓ clear)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('• Cell editing mode (click cells to edit)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange)),
            if (_isSelectable) ...[
              const SizedBox(height: 8),
              const Text('Selection Features:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text('• Individual row selection with checkboxes',
                  style: TextStyle(color: Colors.blue)),
              const Text('• Tap anywhere on row to toggle selection',
                  style: TextStyle(color: Colors.blue)),
              const Text('• Select all/none with header checkbox',
                  style: TextStyle(color: Colors.blue)),
              const Text(
                  '• Intuitive select-all behavior (any selected → clear all)',
                  style: TextStyle(color: Colors.blue)),
              const Text('• Custom selection actions and callbacks',
                  style: TextStyle(color: Colors.blue)),
              const Text('• Selection state management by parent widget',
                  style: TextStyle(color: Colors.blue)),
            ],
            if (_isEditable) ...[
              const SizedBox(height: 8),
              const Text('Editing Features:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange)),
              const Text('• Click on editable cells to start editing',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Beautifully styled inline text fields',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Vertically centered text with rounded borders',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Press Enter or click away to save changes',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Press Escape to cancel editing',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Only specified columns are editable',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Custom cell builders cannot be edited',
                  style: TextStyle(color: Colors.orange)),
              const Text('• Row selection disabled in editing mode',
                  style: TextStyle(color: Colors.orange)),
            ],

            const SizedBox(height: 16),

            // Controls info
            Text(
              'Interactive Controls:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('• 🔄 Reset column order to default'),
            const Text('• 🔀 Clear sort (reset to original order)'),
            const Text(
                '• 🔲 Toggle vertical dividers (Grid vs Horizontal-only design)'),
            const Text(
                '• ✏️ Toggle editing mode (Cell editing with text fields)'),
            const Text(
                '• ☑️ Toggle selection mode (Row selection with checkboxes)'),
            const Text('• 🖱️ Drag column headers to reorder'),
            const Text('• 🔤 Click sortable column headers to sort'),
            if (_isSelectable) ...[
              const Text('• 🧹 Clear all selections'),
              const Text('• 👥 Select only active employees'),
              const Text('• ℹ️ Show selected employee details'),
            ],

            const SizedBox(height: 16),

            // API Usage Example
            Text(
              'Code Example:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''final columns = TableColumnsBuilder()
  .addColumn('name', TablePlusColumn(
    sortable: true,
    editable: true, // Enable cell editing
    ...
  ))
  .addColumn('salary', TablePlusColumn(
    editable: false, // Disable editing (has cellBuilder)
    cellBuilder: customBuilder,
    ...
  ))
  .build();

FlutterTablePlus(
  columns: columns,
  data: data,
  isEditable: true, // Enable editing mode
  theme: TablePlusTheme(
    editableTheme: TablePlusEditableTheme(
      textAlignVertical: TextAlignVertical.center, // Vertical center
      editingBorderRadius: BorderRadius.circular(6.0), // Rounded
      textFieldPadding: EdgeInsets.symmetric(
        horizontal: 12.0, 
        vertical: 8.0
      ),
      filled: true, // Fill background
      focusedBorderColor: Colors.blue,
      enabledBorderColor: Colors.grey,
    ),
  ),
  onCellChanged: (columnKey, rowIndex, oldValue, newValue) {
    // Handle cell value changes
    print('Updated \$columnKey: \$oldValue → \$newValue');
  },
  // Note: Row selection is disabled in editing mode
)''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 32), // Extra space at bottom
          ],
        ),
      ),
    );
  }
}
