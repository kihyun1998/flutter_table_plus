# flutter_table_plus
## Project Structure

```
flutter_table_plus/
├── example/
    ├── lib/
    │   ├── data/
    │   │   └── sample_data.dart
    │   ├── models/
    │   │   └── employee.dart
    │   ├── pages/
    │   │   └── table_example_page.dart
    │   ├── widgets/
    │   │   ├── employee_table.dart
    │   │   └── table_controls.dart
    │   └── main.dart
    └── pubspec.yaml
├── lib/
    ├── src/
    │   ├── models/
    │   │   ├── table_column.dart
    │   │   ├── table_columns_builder.dart
    │   │   └── table_theme.dart
    │   └── widgets/
    │   │   ├── custom_ink_well.dart
    │   │   ├── flutter_table_plus.dart
    │   │   ├── synced_scroll_controllers.dart
    │   │   ├── table_body.dart
    │   │   └── table_header.dart
    └── flutter_table_plus.dart
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml
```

## CHANGELOG.md
```md
## 0.0.1

* TODO: Describe initial release.

```
## LICENSE
```
TODO: Add your license here.

```
## example/lib/data/sample_data.dart
```dart
import '../models/employee.dart';

class SampleData {
  static final List<Employee> employees = [
    const Employee(
      id: 1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      age: 28,
      department: 'Engineering',
      salary: 75000,
      active: true,
    ),
    const Employee(
      id: 2,
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      age: 32,
      department: 'Marketing',
      salary: 68000,
      active: true,
    ),
    const Employee(
      id: 3,
      name: 'Bob Johnson',
      email: 'bob.johnson@example.com',
      age: 45,
      department: 'Sales',
      salary: 82000,
      active: false,
    ),
    const Employee(
      id: 4,
      name: 'Alice Brown',
      email: 'alice.brown@example.com',
      age: 29,
      department: 'Engineering',
      salary: 79000,
      active: true,
    ),
    const Employee(
      id: 5,
      name: 'Charlie Wilson',
      email: 'charlie.wilson@example.com',
      age: 38,
      department: 'HR',
      salary: 65000,
      active: true,
    ),
    const Employee(
      id: 6,
      name: 'Diana Davis',
      email: 'diana.davis@example.com',
      age: 31,
      department: 'Finance',
      salary: 72000,
      active: true,
    ),
    const Employee(
      id: 7,
      name: 'Eva Garcia',
      email: 'eva.garcia@example.com',
      age: 26,
      department: 'Design',
      salary: 63000,
      active: false,
    ),
    const Employee(
      id: 8,
      name: 'Frank Miller',
      email: 'frank.miller@example.com',
      age: 42,
      department: 'Operations',
      salary: 71000,
      active: true,
    ),
  ];

  /// Get employees as List<Map<String, dynamic>> for table
  static List<Map<String, dynamic>> get employeeData =>
      employees.map((e) => e.toMap()).toList();

  /// Get active employees only
  static List<Employee> get activeEmployees =>
      employees.where((e) => e.active).toList();
}

```
## example/lib/main.dart
```dart
import 'package:flutter/material.dart';

import 'pages/table_example_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Table Plus Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TableExamplePage(),
    );
  }
}

```
## example/lib/models/employee.dart
```dart
class Employee {
  final int id;
  final String name;
  final String email;
  final int age;
  final String department;
  final int salary;
  final bool active;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.department,
    required this.salary,
    required this.active,
  });

  /// Convert Employee to Map for table usage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'department': department,
      'salary': salary,
      'active': active,
    };
  }

  /// Create Employee from Map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      department: map['department'] as String,
      salary: map['salary'] as int,
      active: map['active'] as bool,
    );
  }
}

```
## example/lib/pages/table_example_page.dart
```dart
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
  .addColumn('id', TablePlusColumn(
    sortable: true, // Enable sorting
    ...
  ))
  .addColumn('name', TablePlusColumn(
    sortable: true,
    ...
  ))
  .build();

FlutterTablePlus(
  columns: columns,
  data: sortedData, // Use your sorted data
  isSelectable: true,
  selectedRows: selectedRowIds,
  sortColumnKey: currentSortColumn,
  sortDirection: currentSortDirection,
  onSort: (columnKey, direction) {
    // Handle sorting: none → asc → desc → none
    setState(() {
      if (direction == SortDirection.none) {
        // Reset to original order
        resetData();
      } else {
        // Sort your data
        sortData(columnKey, direction);
      }
    });
  },
  onColumnReorder: (oldIndex, newIndex) {
    // Handle column reordering
  },
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

```
## example/lib/widgets/employee_table.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class EmployeeTable extends StatelessWidget {
  const EmployeeTable({
    super.key,
    required this.data,
    required this.isSelectable,
    required this.selectedRows,
    required this.onRowSelectionChanged,
    required this.onSelectAll,
    this.theme,
  });

  final List<Map<String, dynamic>> data;
  final bool isSelectable;
  final Set<String> selectedRows;
  final void Function(String rowId, bool isSelected) onRowSelectionChanged;
  final void Function(bool selectAll) onSelectAll;
  final TablePlusTheme? theme;

  /// Define table columns using TableColumnsBuilder
  Map<String, TablePlusColumn> get _columns {
    return TableColumnsBuilder()
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
            cellBuilder: _buildStatusCell,
          ),
        )
        .build();
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

  @override
  Widget build(BuildContext context) {
    // Use provided theme or default theme
    final tableTheme = theme ??
        const TablePlusTheme(
          headerTheme: TablePlusHeaderTheme(
            height: 48,
            backgroundColor: Color(0xFFF8F9FA),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF495057),
            ),
          ),
          bodyTheme: TablePlusBodyTheme(
            rowHeight: 56,
            alternateRowColor: Color(0xFFFAFAFA),
            textStyle: TextStyle(
              fontSize: 14,
              color: Color(0xFF212529),
            ),
          ),
          scrollbarTheme: TablePlusScrollbarTheme(
            hoverOnly: true,
            opacity: 0.8,
          ),
          selectionTheme: TablePlusSelectionTheme(
            selectedRowColor: Color(0xFFE3F2FD),
            checkboxColor: Color(0xFF2196F3),
            checkboxSize: 18.0,
          ),
        );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: FlutterTablePlus(
          columns: _columns,
          data: data,
          isSelectable: isSelectable,
          selectedRows: selectedRows,
          onRowSelectionChanged: onRowSelectionChanged,
          onSelectAll: onSelectAll,
          theme: tableTheme,
        ),
      ),
    );
  }
}

```
## example/lib/widgets/table_controls.dart
```dart
import 'package:flutter/material.dart';

class TableControls extends StatelessWidget {
  const TableControls({
    super.key,
    required this.isSelectable,
    required this.selectedCount,
    required this.selectedNames,
    required this.onClearSelections,
    required this.onSelectActive,
    required this.onShowSelected,
  });

  final bool isSelectable;
  final int selectedCount;
  final List<String> selectedNames;
  final VoidCallback onClearSelections;
  final VoidCallback onSelectActive;
  final VoidCallback onShowSelected;

  @override
  Widget build(BuildContext context) {
    if (!isSelectable) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Selection actions
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: onClearSelections,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onSelectActive,
              icon: const Icon(Icons.people, size: 16),
              label: const Text('Select Active'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade700,
              ),
            ),
            if (selectedCount > 0)
              ElevatedButton.icon(
                onPressed: onShowSelected,
                icon: const Icon(Icons.info, size: 16),
                label: const Text('Show Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class SelectionDialog extends StatelessWidget {
  const SelectionDialog({
    super.key,
    required this.selectedCount,
    required this.selectedNames,
  });

  final int selectedCount;
  final List<String> selectedNames;

  static void show(
    BuildContext context, {
    required int selectedCount,
    required List<String> selectedNames,
  }) {
    showDialog(
      context: context,
      builder: (context) => SelectionDialog(
        selectedCount: selectedCount,
        selectedNames: selectedNames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selected Employees'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected $selectedCount employees:'),
          const SizedBox(height: 8),
          ...selectedNames.map((name) => Text('• $name')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

```
## example/pubspec.yaml
```yaml
name: example
description: "A new Flutter project."
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: ^3.6.1


dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_table_plus:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```
## lib/flutter_table_plus.dart
```dart
/// A highly customizable and efficient table widget for Flutter.
///
/// This library provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
library;

// Models
export 'src/models/table_column.dart';
export 'src/models/table_columns_builder.dart';
export 'src/models/table_theme.dart';
// Widgets
export 'src/widgets/custom_ink_well.dart';
export 'src/widgets/flutter_table_plus.dart';

```
## lib/src/models/table_column.dart
```dart
import 'package:flutter/material.dart';

/// Enum representing the sorting state of a column.
enum SortDirection {
  /// No sorting applied to this column.
  none,

  /// Column is sorted in ascending order (A-Z, 1-9).
  ascending,

  /// Column is sorted in descending order (Z-A, 9-1).
  descending,
}

/// Configuration for sort icons in table headers.
class SortIcons {
  /// Creates a [SortIcons] with the specified icon widgets.
  const SortIcons({
    required this.ascending,
    required this.descending,
    this.unsorted,
  });

  /// The icon to display when column is sorted in ascending order.
  final Widget ascending;

  /// The icon to display when column is sorted in descending order.
  final Widget descending;

  /// The icon to display when column is not sorted.
  /// If null, no icon will be shown for unsorted columns.
  final Widget? unsorted;

  /// Default sort icons using Material Design icons.
  static const SortIcons defaultIcons = SortIcons(
    ascending: Icon(Icons.arrow_upward, size: 16),
    descending: Icon(Icons.arrow_downward, size: 16),
    unsorted: Icon(Icons.unfold_more, size: 16, color: Colors.grey),
  );

  /// Simple sort icons without unsorted state.
  static const SortIcons simple = SortIcons(
    ascending: Icon(Icons.arrow_upward, size: 16),
    descending: Icon(Icons.arrow_downward, size: 16),
  );
}

/// Defines a column in the table with its properties and behavior.
class TablePlusColumn {
  /// Creates a [TablePlusColumn] with the specified properties.
  const TablePlusColumn({
    required this.key,
    required this.label,
    required this.order,
    this.width = 100.0,
    this.minWidth = 50.0,
    this.maxWidth,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.left,
    this.sortable = false,
    this.visible = true,
    this.cellBuilder,
  });

  /// The unique identifier for this column.
  /// This key is used to extract data from Map entries.
  final String key;

  /// The display label for the column header.
  final String label;

  /// The order position of this column in the table.
  /// Columns are sorted by this value in ascending order.
  /// Selection column uses order: -1 to appear first.
  final int order;

  /// The preferred width of the column in pixels.
  final double width;

  /// The minimum width of the column in pixels.
  final double minWidth;

  /// The maximum width of the column in pixels.
  /// If null, the column can grow indefinitely.
  final double? maxWidth;

  /// The alignment of content within the column cells.
  final Alignment alignment;

  /// The text alignment for text content in the column cells.
  final TextAlign textAlign;

  /// Whether this column can be sorted.
  final bool sortable;

  /// Whether this column is visible in the table.
  final bool visible;

  /// Optional custom cell builder for this column.
  /// If provided, this will be used instead of the default cell rendering.
  /// The function receives the row data and should return a Widget.
  final Widget Function(BuildContext context, Map<String, dynamic> rowData)?
      cellBuilder;

  /// Creates a copy of this column with the given fields replaced with new values.
  TablePlusColumn copyWith({
    String? key,
    String? label,
    int? order,
    double? width,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    TextAlign? textAlign,
    bool? sortable,
    bool? visible,
    Widget Function(BuildContext context, Map<String, dynamic> rowData)?
        cellBuilder,
  }) {
    return TablePlusColumn(
      key: key ?? this.key,
      label: label ?? this.label,
      order: order ?? this.order,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      alignment: alignment ?? this.alignment,
      textAlign: textAlign ?? this.textAlign,
      sortable: sortable ?? this.sortable,
      visible: visible ?? this.visible,
      cellBuilder: cellBuilder ?? this.cellBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TablePlusColumn &&
        other.key == key &&
        other.label == label &&
        other.order == order &&
        other.width == width &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.alignment == alignment &&
        other.textAlign == textAlign &&
        other.sortable == sortable &&
        other.visible == visible;
  }

  @override
  int get hashCode {
    return Object.hash(
      key,
      label,
      order,
      width,
      minWidth,
      maxWidth,
      alignment,
      textAlign,
      sortable,
      visible,
    );
  }

  @override
  String toString() {
    return 'TableColumn(key: $key, label: $label, order: $order, width: $width, visible: $visible, sortable: $sortable)';
  }
}

```
## lib/src/models/table_columns_builder.dart
```dart
import 'table_column.dart';

/// A builder class for creating ordered table columns with automatic order management.
///
/// This builder prevents order conflicts by automatically assigning sequential orders
/// and handling insertions by shifting existing column orders as needed.
///
/// Example usage:
/// ```dart
/// final columns = TableColumnsBuilder()
///   .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0))
///   .addColumn('name', TablePlusColumn(key: 'name', label: 'Name', order: 0))
///   .insertColumn('email', TablePlusColumn(key: 'email', label: 'Email', order: 0), 1)
///   .build();
/// ```
class TableColumnsBuilder {
  final Map<String, TablePlusColumn> _columns = {};
  int _nextOrder = 1;

  /// Adds a column to the end of the table with automatically assigned order.
  ///
  /// The [column]'s order value will be ignored and replaced with the next available order.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder addColumn(String key, TablePlusColumn column) {
    if (_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" already exists');
    }

    _columns[key] = column.copyWith(order: _nextOrder++);
    return this;
  }

  /// Inserts a column at the specified order position.
  ///
  /// All existing columns with order >= [targetOrder] will be shifted by +1.
  /// The [column]'s order value will be ignored and replaced with [targetOrder].
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder insertColumn(
      String key, TablePlusColumn column, int targetOrder) {
    if (_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" already exists');
    }

    if (targetOrder < 1) {
      throw ArgumentError(
          'Order must be >= 1 (order 0 and negative values are reserved)');
    }

    // Shift existing columns that have order >= targetOrder
    _shiftOrdersFrom(targetOrder);

    // Insert the new column at the target order
    _columns[key] = column.copyWith(order: targetOrder);

    // Update _nextOrder if necessary
    _nextOrder = _getMaxOrder() + 1;

    return this;
  }

  /// Removes a column by key.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder removeColumn(String key) {
    if (!_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" does not exist');
    }

    final removedOrder = _columns[key]!.order;
    _columns.remove(key);

    // Shift down columns that had order > removedOrder
    _shiftOrdersDown(removedOrder);

    // Update _nextOrder
    _nextOrder = _getMaxOrder() + 1;

    return this;
  }

  /// Reorders an existing column to a new position.
  ///
  /// Returns this builder for method chaining.
  TableColumnsBuilder reorderColumn(String key, int newOrder) {
    if (!_columns.containsKey(key)) {
      throw ArgumentError('Column with key "$key" does not exist');
    }

    if (newOrder < 1) {
      throw ArgumentError(
          'Order must be >= 1 (order 0 and negative values are reserved)');
    }

    final currentColumn = _columns[key]!;
    final currentOrder = currentColumn.order;

    if (currentOrder == newOrder) {
      return this; // No change needed
    }

    // Remove the column temporarily
    _columns.remove(key);

    // Adjust orders based on movement direction
    if (newOrder < currentOrder) {
      // Moving up: shift down columns in range [newOrder, currentOrder)
      for (final entry in _columns.entries) {
        final order = entry.value.order;
        if (order >= newOrder && order < currentOrder) {
          _columns[entry.key] = entry.value.copyWith(order: order + 1);
        }
      }
    } else {
      // Moving down: shift up columns in range (currentOrder, newOrder]
      for (final entry in _columns.entries) {
        final order = entry.value.order;
        if (order > currentOrder && order <= newOrder) {
          _columns[entry.key] = entry.value.copyWith(order: order - 1);
        }
      }
    }

    // Re-insert the column at new position
    _columns[key] = currentColumn.copyWith(order: newOrder);

    return this;
  }

  /// Returns the current number of columns.
  int get length => _columns.length;

  /// Returns true if the builder is empty.
  bool get isEmpty => _columns.isEmpty;

  /// Returns true if the builder is not empty.
  bool get isNotEmpty => _columns.isNotEmpty;

  /// Returns true if a column with the given key exists.
  bool containsKey(String key) => _columns.containsKey(key);

  /// Builds and returns an unmodifiable map of columns.
  ///
  /// ⚠️ After calling build(), this builder should not be used again.
  Map<String, TablePlusColumn> build() {
    _validateOrders();
    return Map.unmodifiable(_columns);
  }

  /// Shifts all columns with order >= fromOrder by +1.
  void _shiftOrdersFrom(int fromOrder) {
    for (final entry in _columns.entries) {
      if (entry.value.order >= fromOrder) {
        _columns[entry.key] = entry.value.copyWith(
          order: entry.value.order + 1,
        );
      }
    }
  }

  /// Shifts all columns with order > fromOrder by -1.
  void _shiftOrdersDown(int fromOrder) {
    for (final entry in _columns.entries) {
      if (entry.value.order > fromOrder) {
        _columns[entry.key] = entry.value.copyWith(
          order: entry.value.order - 1,
        );
      }
    }
  }

  /// Returns the maximum order value, or 0 if no columns exist.
  int _getMaxOrder() {
    if (_columns.isEmpty) return 0;
    return _columns.values.map((c) => c.order).reduce((a, b) => a > b ? a : b);
  }

  /// Validates that all orders are unique and sequential starting from 1.
  void _validateOrders() {
    if (_columns.isEmpty) return;

    final orders = _columns.values.map((c) => c.order).toList();
    orders.sort();

    // Check for duplicates
    final uniqueOrders = orders.toSet();
    if (orders.length != uniqueOrders.length) {
      throw StateError('Internal error: Duplicate orders found in builder');
    }

    // Check for proper sequence (should start from 1 and be consecutive)
    for (int i = 0; i < orders.length; i++) {
      if (orders[i] != i + 1) {
        throw StateError(
            'Internal error: Orders are not consecutive starting from 1');
      }
    }
  }
}

```
## lib/src/models/table_theme.dart
```dart
import 'package:flutter/material.dart';

import 'table_column.dart';

/// Theme configuration for the table components.
class TablePlusTheme {
  /// Creates a [TablePlusTheme] with the specified styling properties.
  const TablePlusTheme({
    this.headerTheme = const TablePlusHeaderTheme(),
    this.bodyTheme = const TablePlusBodyTheme(),
    this.scrollbarTheme = const TablePlusScrollbarTheme(),
    this.selectionTheme = const TablePlusSelectionTheme(),
  });

  /// Theme configuration for the table header.
  final TablePlusHeaderTheme headerTheme;

  /// Theme configuration for the table body.
  final TablePlusBodyTheme bodyTheme;

  /// Theme configuration for the scrollbars.
  final TablePlusScrollbarTheme scrollbarTheme;

  /// Theme configuration for row selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
    TablePlusSelectionTheme? selectionTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      selectionTheme: selectionTheme ?? this.selectionTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
}

/// Theme configuration for the table header.
class TablePlusHeaderTheme {
  /// Creates a [TablePlusHeaderTheme] with the specified styling properties.
  const TablePlusHeaderTheme({
    this.height = 56.0,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decoration,
    this.showVerticalDividers = true,
    this.showBottomDivider = true,
    this.dividerColor = const Color(0xFFE0E0E0),
    // Sort-related styling
    this.sortedColumnBackgroundColor,
    this.sortedColumnTextStyle,
    this.sortIcons = SortIcons.defaultIcons,
    this.sortIconSpacing = 4.0,
  });

  /// The height of the header row.
  final double height;

  /// The background color of the header.
  final Color backgroundColor;

  /// The text style for header labels.
  final TextStyle textStyle;

  /// The padding inside header cells.
  final EdgeInsets padding;

  /// Optional decoration for the header.
  final Decoration? decoration;

  /// Whether to show vertical dividers between header columns.
  final bool showVerticalDividers;

  /// Whether to show bottom divider below header.
  final bool showBottomDivider;

  /// The color of header dividers.
  final Color dividerColor;

  /// Background color for columns that are currently sorted.
  /// If null, uses [backgroundColor] for all columns.
  final Color? sortedColumnBackgroundColor;

  /// Text style for columns that are currently sorted.
  /// If null, uses [textStyle] for all columns.
  final TextStyle? sortedColumnTextStyle;

  /// Icons to display for different sort states.
  final SortIcons sortIcons;

  /// Spacing between the column label and sort icon.
  final double sortIconSpacing;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderTheme copyWith({
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Decoration? decoration,
    bool? showVerticalDividers,
    bool? showBottomDivider,
    Color? dividerColor,
    Color? sortedColumnBackgroundColor,
    TextStyle? sortedColumnTextStyle,
    SortIcons? sortIcons,
    double? sortIconSpacing,
  }) {
    return TablePlusHeaderTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showBottomDivider: showBottomDivider ?? this.showBottomDivider,
      dividerColor: dividerColor ?? this.dividerColor,
      sortedColumnBackgroundColor:
          sortedColumnBackgroundColor ?? this.sortedColumnBackgroundColor,
      sortedColumnTextStyle:
          sortedColumnTextStyle ?? this.sortedColumnTextStyle,
      sortIcons: sortIcons ?? this.sortIcons,
      sortIconSpacing: sortIconSpacing ?? this.sortIconSpacing,
    );
  }
}

/// Theme configuration for the table body.
class TablePlusBodyTheme {
  /// Creates a [TablePlusBodyTheme] with the specified styling properties.
  const TablePlusBodyTheme({
    this.rowHeight = 48.0,
    this.backgroundColor = Colors.white,
    this.alternateRowColor,
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.dividerColor = const Color(0xFFE0E0E0),
    this.dividerThickness = 1.0,
    this.showVerticalDividers = true,
    this.showHorizontalDividers = true,
  });

  /// The height of each data row.
  final double rowHeight;

  /// The background color of rows.
  final Color backgroundColor;

  /// The alternate row color for striped tables.
  /// If null, all rows will use [backgroundColor].
  final Color? alternateRowColor;

  /// The text style for body cells.
  final TextStyle textStyle;

  /// The padding inside body cells.
  final EdgeInsets padding;

  /// The color of row dividers.
  final Color dividerColor;

  /// The thickness of row dividers.
  final double dividerThickness;

  /// Whether to show vertical dividers between columns.
  final bool showVerticalDividers;

  /// Whether to show horizontal dividers between rows.
  final bool showHorizontalDividers;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
    bool? showVerticalDividers,
    bool? showHorizontalDividers,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showHorizontalDividers:
          showHorizontalDividers ?? this.showHorizontalDividers,
    );
  }
}

/// Theme configuration for scrollbars.
class TablePlusScrollbarTheme {
  /// Creates a [TablePlusScrollbarTheme] with the specified styling properties.
  const TablePlusScrollbarTheme({
    this.showVertical = true,
    this.showHorizontal = true,
    this.width = 12.0,
    this.color = const Color(0xFF757575),
    this.trackColor = const Color(0xFFE0E0E0),
    this.opacity = 1.0,
    this.hoverOnly = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Whether to show the vertical scrollbar.
  final bool showVertical;

  /// Whether to show the horizontal scrollbar.
  final bool showHorizontal;

  /// The width/thickness of the scrollbar.
  final double width;

  /// The color of the scrollbar thumb.
  final Color color;

  /// The color of the scrollbar track.
  final Color trackColor;

  /// The opacity of the scrollbar.
  final double opacity;

  /// Whether the scrollbar should only appear on hover.
  final bool hoverOnly;

  /// The animation duration for scrollbar appearance.
  final Duration animationDuration;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusScrollbarTheme copyWith({
    bool? showVertical,
    bool? showHorizontal,
    double? width,
    Color? color,
    Color? trackColor,
    double? opacity,
    bool? hoverOnly,
    Duration? animationDuration,
  }) {
    return TablePlusScrollbarTheme(
      showVertical: showVertical ?? this.showVertical,
      showHorizontal: showHorizontal ?? this.showHorizontal,
      width: width ?? this.width,
      color: color ?? this.color,
      trackColor: trackColor ?? this.trackColor,
      opacity: opacity ?? this.opacity,
      hoverOnly: hoverOnly ?? this.hoverOnly,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

/// Theme configuration for row selection.
class TablePlusSelectionTheme {
  /// Creates a [TablePlusSelectionTheme] with the specified styling properties.
  const TablePlusSelectionTheme({
    this.selectedRowColor = const Color(0xFFE3F2FD),
    this.checkboxColor = const Color(0xFF2196F3),
    this.checkboxSize = 18.0,
    this.showCheckboxColumn = true,
    this.checkboxColumnWidth = 60.0,
  });

  /// The background color for selected rows.
  final Color selectedRowColor;

  /// The color of the selection checkboxes.
  final Color checkboxColor;

  /// The size of the selection checkboxes.
  final double checkboxSize;

  /// Whether to show the checkbox column.
  /// If false, rows can only be selected by tapping.
  final bool showCheckboxColumn;

  /// The width of the checkbox column.
  final double checkboxColumnWidth;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusSelectionTheme copyWith({
    Color? selectedRowColor,
    Color? checkboxColor,
    double? checkboxSize,
    bool? showCheckboxColumn,
    double? checkboxColumnWidth,
  }) {
    return TablePlusSelectionTheme(
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      checkboxColor: checkboxColor ?? this.checkboxColor,
      checkboxSize: checkboxSize ?? this.checkboxSize,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
    );
  }
}

```
## lib/src/widgets/custom_ink_well.dart
```dart
import 'dart:async';

import 'package:flutter/material.dart';

/// A custom [InkWell] widget that provides enhanced tap, double-tap, and secondary-tap
/// functionalities without delaying single taps when double-tap is enabled.
class CustomInkWell extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when the user taps this [CustomInkWell].
  final VoidCallback? onTap;

  /// Called when the user double-taps this [CustomInkWell].
  final VoidCallback? onDoubleTap;

  /// Called when the user performs a secondary tap (e.g., right-click on desktop)
  /// on this [CustomInkWell].
  final VoidCallback? onSecondaryTap;

  /// The maximum duration between two taps for them to be considered a double-tap.
  /// Defaults to 300 milliseconds.
  final Duration doubleClickTime;

  /// The color of the ink splash when the [CustomInkWell] is tapped.
  final Color? splashColor;

  /// The highlight color of the [CustomInkWell] when it's pressed.
  final Color? highlightColor;

  /// The border radius of the ink splash and highlight.
  final BorderRadius? borderRadius;

  /// Creates a [CustomInkWell] instance.
  const CustomInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.doubleClickTime = const Duration(milliseconds: 300),
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
  });

  @override
  State<CustomInkWell> createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  int _clickCount = 0;
  Timer? _timer;

  void _handleTap() {
    _clickCount++;

    if (_clickCount == 1) {
      // 첫 번째 클릭 - 즉시 처리 (지연 없음!)
      widget.onTap?.call();

      if (widget.onDoubleTap != null) {
        // 더블클릭 콜백이 있으면 타이머 시작
        _timer = Timer(widget.doubleClickTime, () {
          _clickCount = 0;
        });
      } else {
        _clickCount = 0;
      }
    } else if (_clickCount == 2) {
      // 두 번째 클릭 - 더블클릭 처리
      _timer?.cancel();
      widget.onDoubleTap?.call();
      _clickCount = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: widget.onSecondaryTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (widget.onTap != null || widget.onDoubleTap != null)
              ? _handleTap
              : null,
          splashColor: widget.splashColor,
          highlightColor: widget.highlightColor,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}

```
## lib/src/widgets/flutter_table_plus.dart
```dart
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

  @override
  State<FlutterTablePlus> createState() => _FlutterTablePlusState();
}

class _FlutterTablePlusState extends State<FlutterTablePlus> {
  bool _isHovered = false;

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
    }
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

```
## lib/src/widgets/synced_scroll_controllers.dart
```dart
import 'package:flutter/material.dart';

/// A widget that synchronizes multiple [ScrollController]s.
///
/// This is particularly useful for scenarios where different scrollable widgets
/// (e.g., a main content area and its corresponding scrollbar) need to scroll
/// in unison. It manages both vertical and horizontal scroll synchronization.
class SyncedScrollControllers extends StatefulWidget {
  /// Creates a [SyncedScrollControllers] instance.
  ///
  /// The [builder] function is required and provides the synchronized scroll
  /// controllers to its child widgets.
  ///
  /// [scrollController]: An optional external [ScrollController] for the main vertical scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [verticalScrollbarController]: An optional external [ScrollController] for the vertical scrollbar.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollController]: An optional external [ScrollController] for the main horizontal scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollbarController]: An optional external [ScrollController] for the horizontal scrollbar.
  ///   If not provided, an internal controller will be created.
  ///
  /// The `builder` function provides the following controllers:
  /// - `verticalDataController`: The primary controller for vertical scrolling of data.
  /// - `verticalScrollbarController`: The controller for the vertical scrollbar.
  /// - `horizontalMainController`: The primary controller for horizontal scrolling (shared by header and data).
  /// - `horizontalScrollbarController`: The controller for the horizontal scrollbar.
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollbarController,
    this.horizontalScrollController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  /// A builder function that provides the synchronized [ScrollController]s.
  ///
  /// [context]: The build context.
  /// [verticalDataController]: The primary controller for vertical scrolling of data.
  /// [verticalScrollbarController]: The controller for the vertical scrollbar.
  /// [horizontalMainController]: The primary controller for horizontal scrolling (shared by header and data).
  /// [horizontalScrollbarController]: The controller for the horizontal scrollbar.
  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController,
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // 메인 수직 (ListView 용)
  late ScrollController _sc12; // 수직 스크롤바
  ScrollController? _sc21; // 메인 수평 (헤더 & 데이터 공통)
  late ScrollController _sc22; // 수평 스크롤바

  // 각 컨트롤러에 대한 리스너들을 명확하게 관리하기 위한 Map
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인, ListView 용)
    _sc11 = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (메인, 헤더와 데이터 영역의 가로 스크롤 공통)
    _sc21 = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _sc12 = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc11!.hasClients && _sc11!.positions.isNotEmpty
              ? _sc11!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _sc22 = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _sc11?.dispose();
    if (widget.horizontalScrollController == null) _sc21?.dispose();
    if (widget.verticalScrollbarController == null) _sc12.dispose();
    if (widget.horizontalScrollbarController == null) _sc22.dispose();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    // 마스터 컨트롤러에 리스너 추가
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _sc11!,
        _sc12,
        _sc21!,
        _sc22,
      );
}

```
## lib/src/widgets/table_body.dart
```dart
import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';
import 'custom_ink_well.dart';

/// A widget that renders the data rows of the table.
class TablePlusBody extends StatelessWidget {
  /// Creates a [TablePlusBody] with the specified configuration.
  const TablePlusBody({
    super.key,
    required this.columns,
    required this.data,
    required this.columnWidths,
    required this.theme,
    required this.verticalController,
    this.isSelectable = false,
    this.selectedRows = const <String>{},
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onRowSelectionChanged,
  });

  /// The list of columns for the table.
  final List<TablePlusColumn> columns;

  /// The data to display in the table rows.
  final List<Map<String, dynamic>> data;

  /// The calculated width for each column.
  final List<double> columnWidths;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when a row's selection state changes.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index, bool isSelected) {
    // Selected rows get selection color
    if (isSelected && isSelectable) {
      return selectionTheme.selectedRowColor;
    }

    // Alternate row colors
    if (theme.alternateRowColor != null && index.isOdd) {
      return theme.alternateRowColor!;
    }

    return theme.backgroundColor;
  }

  /// Extract the row ID from row data.
  String? _getRowId(Map<String, dynamic> rowData) {
    return rowData['id']?.toString();
  }

  /// Handle row selection toggle.
  void _handleRowSelectionToggle(String rowId) {
    if (onRowSelectionChanged == null) return;

    final isCurrentlySelected = selectedRows.contains(rowId);
    onRowSelectionChanged!(rowId, !isCurrentlySelected);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: theme.rowHeight * 3, // Show some height even when empty
        decoration: BoxDecoration(
          color: theme.backgroundColor,
        ),
        child: Center(
          child: Text(
            'No data available',
            style: theme.textStyle.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: verticalController,
      physics: const ClampingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final rowData = data[index];
        final rowId = _getRowId(rowData);
        final isSelected = rowId != null && selectedRows.contains(rowId);

        return _TablePlusRow(
          rowData: rowData,
          rowId: rowId,
          columns: columns,
          columnWidths: columnWidths,
          theme: theme,
          backgroundColor: _getRowColor(index, isSelected),
          isLastRow: index == data.length - 1,
          isSelectable: isSelectable,
          isSelected: isSelected,
          selectionTheme: selectionTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
        );
      },
    );
  }
}

/// A single table row widget.
class _TablePlusRow extends StatelessWidget {
  const _TablePlusRow({
    required this.rowData,
    required this.rowId,
    required this.columns,
    required this.columnWidths,
    required this.theme,
    required this.backgroundColor,
    required this.isLastRow,
    required this.isSelectable,
    required this.isSelected,
    required this.selectionTheme,
    required this.onRowSelectionChanged,
  });

  final Map<String, dynamic> rowData;
  final String? rowId;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  final Color backgroundColor;
  final bool isLastRow;
  final bool isSelectable;
  final bool isSelected;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onRowSelectionChanged;

  /// Handle row tap for selection.
  void _handleRowTap() {
    if (!isSelectable || rowId == null) return;
    onRowSelectionChanged(rowId!);
  }

  @override
  Widget build(BuildContext context) {
    Widget rowContent = Container(
      height: theme.rowHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: (!isLastRow && theme.showHorizontalDividers)
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width =
              columnWidths.isNotEmpty ? columnWidths[index] : column.width;

          // Special handling for selection column
          if (isSelectable && column.key == '__selection__') {
            return _SelectionCell(
              width: width,
              rowId: rowId,
              isSelected: isSelected,
              theme: theme,
              selectionTheme: selectionTheme,
              onSelectionChanged: onRowSelectionChanged,
            );
          }

          return _TablePlusCell(
            column: column,
            rowData: rowData,
            width: width,
            theme: theme,
          );
        }),
      ),
    );

    // Wrap with CustomInkWell for row selection if selectable
    if (isSelectable && rowId != null) {
      return CustomInkWell(
        onTap: _handleRowTap,
        child: rowContent,
      );
    }

    return rowContent;
  }
}

/// A selection cell with checkbox.
class _SelectionCell extends StatelessWidget {
  const _SelectionCell({
    required this.width,
    required this.rowId,
    required this.isSelected,
    required this.theme,
    required this.selectionTheme,
    required this.onSelectionChanged,
  });

  final double width;
  final String? rowId;
  final bool isSelected;
  final TablePlusBodyTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: selectionTheme.checkboxSize,
          height: selectionTheme.checkboxSize,
          child: Checkbox(
            value: isSelected,
            onChanged:
                rowId != null ? (value) => onSelectionChanged(rowId!) : null,
            activeColor: selectionTheme.checkboxColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}

/// A single table cell widget.
class _TablePlusCell extends StatelessWidget {
  const _TablePlusCell({
    required this.column,
    required this.rowData,
    required this.width,
    required this.theme,
  });

  final TablePlusColumn column;
  final Map<String, dynamic> rowData;
  final double width;
  final TablePlusBodyTheme theme;

  /// Extract the display value for this cell.
  String _getCellDisplayValue() {
    final value = rowData[column.key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Use custom cell builder if provided
    if (column.cellBuilder != null) {
      return Container(
        width: width,
        height: theme.rowHeight,
        padding: theme.padding,
        decoration: BoxDecoration(
          border: theme.showVerticalDividers
              ? Border(
                  right: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Align(
          alignment: column.alignment,
          child: column.cellBuilder!(context, rowData),
        ),
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    return Container(
      width: width,
      height: theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Align(
        alignment: column.alignment,
        child: Text(
          displayValue,
          style: theme.textStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: column.textAlign,
        ),
      ),
    );
  }
}

```
## lib/src/widgets/table_header.dart
```dart
import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader extends StatefulWidget {
  /// Creates a [TablePlusHeader] with the specified configuration.
  const TablePlusHeader({
    super.key,
    required this.columns,
    required this.totalWidth,
    required this.theme,
    this.isSelectable = false,
    this.selectedRows = const <String>{},
    this.totalRowCount = 0,
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onSelectAll,
    this.onColumnReorder,
    this.sortColumnKey,
    this.sortDirection = SortDirection.none,
    this.onSort,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn> columns;

  /// The total width available for the table.
  final double totalWidth;

  /// The theme configuration for the header.
  final TablePlusHeaderTheme theme;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The total number of rows in the table.
  final int totalRowCount;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

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
  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths() {
    if (widget.columns.isEmpty) return [];

    // Separate selection column from regular columns
    List<TablePlusColumn> regularColumns = [];
    TablePlusColumn? selectionColumn;

    for (final column in widget.columns) {
      if (column.key == '__selection__') {
        selectionColumn = column;
      } else {
        regularColumns.add(column);
      }
    }

    // Calculate available width for regular columns (excluding selection column)
    double availableWidth = widget.totalWidth;
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

    for (final column in widget.columns) {
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

    // Adjust newIndex if dragging down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    widget.onColumnReorder!(oldIndex, newIndex);
  }

  /// Handle sort click for a column
  void _handleSortClick(String columnKey) {
    if (widget.onSort == null) return;

    // Determine next sort direction
    SortDirection nextDirection;
    if (widget.sortColumnKey == columnKey) {
      // Same column - cycle through directions
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
      // Different column - start with ascending
      nextDirection = SortDirection.ascending;
    }

    widget.onSort!(columnKey, nextDirection);
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = _calculateColumnWidths();
    final reorderableColumns = _getReorderableColumns();
    final reorderableWidths = _getReorderableColumnWidths(columnWidths);

    return Container(
      height: widget.theme.height,
      width: widget.totalWidth,
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        border: widget.theme.decoration != null
            ? null
            : (widget.theme.showBottomDivider
                ? Border(
                    bottom: BorderSide(
                      color: widget.theme.dividerColor,
                      width: 1.0,
                    ),
                  )
                : null),
      ),
      child: Row(
        children: [
          // Selection column (fixed, non-reorderable)
          if (widget.isSelectable &&
              widget.columns.any((col) => col.key == '__selection__'))
            _SelectionHeaderCell(
              width: widget.selectionTheme.checkboxColumnWidth,
              theme: widget.theme,
              selectionTheme: widget.selectionTheme,
              selectAllState: _getSelectAllState(),
              selectedRows: widget.selectedRows,
              onSelectAll: widget.onSelectAll,
            ),

          // Reorderable columns
          if (reorderableColumns.isNotEmpty)
            Expanded(
              child: SizedBox(
                height: widget.theme.height,
                child: ReorderableListView.builder(
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
                        isSorted: widget.sortColumnKey == column.key,
                        sortDirection: widget.sortColumnKey == column.key
                            ? widget.sortDirection
                            : SortDirection.none,
                        onSortClick: column.sortable
                            ? () => _handleSortClick(column.key)
                            : null,
                      ),
                    );
                  },
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
    required this.isSorted,
    required this.sortDirection,
    this.onSortClick,
  });

  final TablePlusColumn column;
  final double width;
  final TablePlusHeaderTheme theme;
  final bool isSorted;
  final SortDirection sortDirection;
  final VoidCallback? onSortClick;

  /// Get the sort icon widget for current state
  Widget? _getSortIcon() {
    if (!column.sortable) return null;

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

  @override
  Widget build(BuildContext context) {
    final sortIcon = _getSortIcon();
    final backgroundColor = _getBackgroundColor();
    final textStyle = _getTextStyle();

    Widget content = Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Align(
        alignment: column.alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Column label
            Flexible(
              child: Text(
                column.label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                textAlign: column.textAlign,
              ),
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
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: selectionTheme.checkboxSize,
          height: selectionTheme.checkboxSize,
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
            activeColor: selectionTheme.checkboxColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}

```
## pubspec.yaml
```yaml
name: flutter_table_plus
description: "A new Flutter package project."
version: 0.0.1
homepage:

environment:
  sdk: ^3.6.1
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # To add assets to your package, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg
  #
  # For details regarding assets in packages, see
  # https://flutter.dev/to/asset-from-package
  #
  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # To add custom fonts to your package, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts in packages, see
  # https://flutter.dev/to/font-from-package

```
