import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../widgets/employee_table.dart';
import '../widgets/table_controls.dart';

class TableExamplePage extends StatefulWidget {
  const TableExamplePage({super.key});

  @override
  State<TableExamplePage> createState() => _TableExamplePageState();
}

class _TableExamplePageState extends State<TableExamplePage> {
  bool _isSelectable = false;
  final Set<String> _selectedRows = <String>{};

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
          SampleData.employeeData.map((row) => row['id'].toString()),
        );
      } else {
        _selectedRows.clear();
      }
    });
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
    return SampleData.employeeData
        .where((row) => _selectedRows.contains(row['id'].toString()))
        .map((row) => row['name'].toString())
        .toList();
  }

  /// Show selected employees dialog
  void _showSelectedEmployees() {
    SelectionDialog.show(
      context,
      selectedCount: _selectedRows.length,
      selectedNames: _selectedNames,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
              child: EmployeeTable(
                data: SampleData.employeeData,
                isSelectable: _isSelectable,
                selectedRows: _selectedRows,
                onRowSelectionChanged: _onRowSelectionChanged,
                onSelectAll: _onSelectAll,
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
  .addColumn('id', TablePlusColumn(...))
  .addColumn('name', TablePlusColumn(...))
  .build();

FlutterTablePlus(
  columns: columns,
  data: data,
  isSelectable: true,
  selectedRows: selectedRowIds,
  onRowSelectionChanged: (rowId, isSelected) {
    // Handle selection
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
