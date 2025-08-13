import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Example demonstrating selection functionality with merged rows.
class SelectableMergedExample extends StatefulWidget {
  const SelectableMergedExample({super.key});

  @override
  State<SelectableMergedExample> createState() =>
      _SelectableMergedExampleState();
}

class _SelectableMergedExampleState extends State<SelectableMergedExample> {
  // Sample data
  final List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'name': 'Alice',
      'department': 'IT',
      'salary': 100,
      'level': 'Senior'
    },
    {
      'id': '2',
      'name': 'Bob',
      'department': 'IT',
      'salary': 120,
      'level': 'Junior'
    },
    {
      'id': '3',
      'name': 'Charlie',
      'department': 'IT',
      'salary': 110,
      'level': 'Senior'
    },
    {
      'id': '4',
      'name': 'David',
      'department': 'Sales',
      'salary': 90,
      'level': 'Manager'
    },
    {
      'id': '5',
      'name': 'Eve',
      'department': 'Sales',
      'salary': 95,
      'level': 'Senior'
    },
    {
      'id': '6',
      'name': 'Frank',
      'department': 'Marketing',
      'salary': 85,
      'level': 'Junior'
    },
  ];

  // Selection state
  Set<String> selectedRows = {};

  // Current selection mode
  SelectionMode selectionMode = SelectionMode.multiple;

  // Column configuration
  late final Map<String, TablePlusColumn> columns = {
    'id': TablePlusColumn(
      key: 'id',
      label: 'ID',
      order: 0,
      width: 80,
    ),
    'name': TablePlusColumn(
      key: 'name',
      label: 'Name',
      order: 1,
      width: 120,
    ),
    'department': TablePlusColumn(
      key: 'department',
      label: 'Department',
      order: 2,
      width: 150,
    ),
    'level': TablePlusColumn(
      key: 'level',
      label: 'Level',
      order: 3,
      width: 100,
    ),
    'salary': TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      order: 4,
      width: 100,
    ),
  };

  // Merged groups configuration
  late final List<MergedRowGroup> mergedGroups = [
    // IT department group - 3 rows merged
    MergedRowGroup(
      groupId: 'it_group',
      originalIndices: [0, 1, 2], // Alice, Bob, Charlie
      mergeConfig: {
        'department': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          mergedContent: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.computer, color: Colors.blue, size: 16),
                Text(
                  'IT Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  '3 members',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      },
    ),
    // Sales department group - 2 rows merged
    MergedRowGroup(
      groupId: 'sales_group',
      originalIndices: [3, 4], // David, Eve
      mergeConfig: {
        'department': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          mergedContent: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 16),
                Text(
                  'Sales',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  '2 members',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      },
    ),
    // Marketing department - single row (Frank) - not merged
  ];

  void _handleRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (selectionMode == SelectionMode.single) {
        if (isSelected) {
          selectedRows = {rowId};
        } else {
          selectedRows.remove(rowId);
        }
      } else {
        if (isSelected) {
          selectedRows.add(rowId);
        } else {
          selectedRows.remove(rowId);
        }
      }
    });
  }

  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        // Select all available units (merged groups + individual rows)
        selectedRows = {
          'it_group', // IT merged group
          'sales_group', // Sales merged group
          '6', // Frank (individual row)
        };
      } else {
        selectedRows.clear();
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      selectionMode = selectionMode == SelectionMode.multiple
          ? SelectionMode.single
          : SelectionMode.multiple;
      selectedRows.clear(); // Clear selections when switching modes
    });
  }

  String _getSelectionInfo() {
    if (selectedRows.isEmpty) return 'No selections';

    int totalSelectedRows = 0;
    List<String> selectedItems = [];

    for (String selection in selectedRows) {
      if (selection == 'it_group') {
        totalSelectedRows += 3; // IT group has 3 rows
        selectedItems.add('IT Dept (3 rows)');
      } else if (selection == 'sales_group') {
        totalSelectedRows += 2; // Sales group has 2 rows
        selectedItems.add('Sales Dept (2 rows)');
      } else {
        totalSelectedRows += 1; // Individual row
        final personData = data.firstWhere((row) => row['id'] == selection);
        selectedItems
            .add('${personData['name']} (${personData['department']})');
      }
    }

    return '$totalSelectedRows rows selected: ${selectedItems.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selectable Merged Table'),
        backgroundColor: Colors.orange.shade100,
        actions: [
          IconButton(
            icon: Icon(selectionMode == SelectionMode.multiple
                ? Icons.check_box
                : Icons.radio_button_checked),
            onPressed: _toggleSelectionMode,
            tooltip: 'Toggle Selection Mode',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description and Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selection with Merged Rows',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current mode: ${selectionMode == SelectionMode.multiple ? 'Multiple' : 'Single'} selection\n'
                      'Merged groups are treated as single selectable units.',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        _getSelectionInfo(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlutterTablePlus(
                    columns: columns,
                    data: data,
                    mergedGroups: mergedGroups,
                    isSelectable: true,
                    selectionMode: selectionMode,
                    selectedRows: selectedRows,
                    onRowSelectionChanged: _handleRowSelectionChanged,
                    onSelectAll: _handleSelectAll,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
