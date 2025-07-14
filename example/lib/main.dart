import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Table Plus Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TableExamplePage(),
    );
  }
}

class TableExamplePage extends StatefulWidget {
  const TableExamplePage({super.key});

  @override
  State<TableExamplePage> createState() => _TableExamplePageState();
}

class _TableExamplePageState extends State<TableExamplePage> {
  // Selection state management
  bool _isSelectable = false;
  final Set<String> _selectedRows = <String>{};

  // Sample data for the table
  final List<Map<String, dynamic>> _sampleData = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'age': 28,
      'department': 'Engineering',
      'salary': 75000,
      'active': true,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'age': 32,
      'department': 'Marketing',
      'salary': 68000,
      'active': true,
    },
    {
      'id': 3,
      'name': 'Bob Johnson',
      'email': 'bob.johnson@example.com',
      'age': 45,
      'department': 'Sales',
      'salary': 82000,
      'active': false,
    },
    {
      'id': 4,
      'name': 'Alice Brown',
      'email': 'alice.brown@example.com',
      'age': 29,
      'department': 'Engineering',
      'salary': 79000,
      'active': true,
    },
    {
      'id': 5,
      'name': 'Charlie Wilson',
      'email': 'charlie.wilson@example.com',
      'age': 38,
      'department': 'HR',
      'salary': 65000,
      'active': true,
    },
    {
      'id': 6,
      'name': 'Diana Davis',
      'email': 'diana.davis@example.com',
      'age': 31,
      'department': 'Finance',
      'salary': 72000,
      'active': true,
    },
    {
      'id': 7,
      'name': 'Eva Garcia',
      'email': 'eva.garcia@example.com',
      'age': 26,
      'department': 'Design',
      'salary': 63000,
      'active': false,
    },
    {
      'id': 8,
      'name': 'Frank Miller',
      'email': 'frank.miller@example.com',
      'age': 42,
      'department': 'Operations',
      'salary': 71000,
      'active': true,
    },
  ];

  // Define table columns
  final List<TablePlusColumn> _columns = [
    const TablePlusColumn(
      key: 'id',
      label: 'ID',
      width: 60,
      minWidth: 50,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
    ),
    const TablePlusColumn(
      key: 'name',
      label: 'Full Name',
      width: 150,
      minWidth: 120,
    ),
    const TablePlusColumn(
      key: 'email',
      label: 'Email Address',
      width: 200,
      minWidth: 150,
    ),
    const TablePlusColumn(
      key: 'age',
      label: 'Age',
      width: 60,
      minWidth: 50,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
    ),
    const TablePlusColumn(
      key: 'department',
      label: 'Department',
      width: 120,
      minWidth: 100,
    ),
    TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      width: 100,
      minWidth: 80,
      textAlign: TextAlign.right,
      alignment: Alignment.centerRight,
      cellBuilder: (context, rowData) {
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
      },
    ),
    TablePlusColumn(
      key: 'active',
      label: 'Status',
      width: 80,
      minWidth: 70,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
      cellBuilder: (context, rowData) {
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
      },
    ),
  ];

  /// Handle row selection change
  void _onRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
      }
    });

    // Debug print
    print('Row $rowId ${isSelected ? 'selected' : 'deselected'}');
    print('Total selected: ${_selectedRows.length}');
  }

  /// Handle select all/none
  void _onSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        // Select all rows
        _selectedRows.clear();
        for (final row in _sampleData) {
          final id = row['id']?.toString();
          if (id != null) {
            _selectedRows.add(id);
          }
        }
      } else {
        // Deselect all rows
        _selectedRows.clear();
      }
    });

    // Debug print
    print('Select all: $selectAll');
    print('Total selected: ${_selectedRows.length}');
  }

  /// Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectable = !_isSelectable;
      if (!_isSelectable) {
        _selectedRows.clear(); // Clear selections when disabling
      }
    });
  }

  /// Clear all selections
  void _clearSelections() {
    setState(() {
      _selectedRows.clear();
    });
  }

  /// Select active employees only
  void _selectActiveEmployees() {
    setState(() {
      _selectedRows.clear();
      for (final row in _sampleData) {
        if (row['active'] == true) {
          final id = row['id']?.toString();
          if (id != null) {
            _selectedRows.add(id);
          }
        }
      }
    });
  }

  /// Get selected employee names for display
  List<String> _getSelectedNames() {
    return _sampleData
        .where((row) => _selectedRows.contains(row['id']?.toString()))
        .map((row) => row['name']?.toString() ?? '')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  'Showing ${_sampleData.length} employees',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
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

            // Selection controls (only show when selectable)
            if (_isSelectable) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearSelections,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectActiveEmployees,
                    icon: const Icon(Icons.people, size: 16),
                    label: const Text('Select Active'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade700,
                    ),
                  ),
                  if (_selectedRows.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Example action with selected items
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Selected Employees'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Selected ${_selectedRows.length} employees:'),
                                const SizedBox(height: 8),
                                ..._getSelectedNames().map(
                                  (name) => Text('• $name'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.info, size: 16),
                      label: const Text('Show Selected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Table
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _sampleData,
                    isSelectable: _isSelectable,
                    selectedRows: _selectedRows,
                    onRowSelectionChanged: _onRowSelectionChanged,
                    onSelectAll: _onSelectAll,
                    theme: const TablePlusTheme(
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
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Features info
            Text(
              'Features demonstrated:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('• Column width management'),
            const Text('• Custom cell builders (Salary, Status)'),
            const Text('• Alternating row colors'),
            const Text('• Synchronized scrolling'),
            const Text('• Responsive layout'),
            if (_isSelectable) ...[
              const Text('• Row selection with checkboxes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text('• Tap to select rows',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text('• Select all/none functionality',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text('• Custom selection actions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ],
        ),
      ),
    );
  }
}
