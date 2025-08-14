import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Example demonstrating editing functionality with merged rows.
class EditableMergedExample extends StatefulWidget {
  const EditableMergedExample({super.key});

  @override
  State<EditableMergedExample> createState() => _EditableMergedExampleState();
}

class _EditableMergedExampleState extends State<EditableMergedExample> {
  // Sample data that can be edited
  List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'name': 'Alice',
      'department': 'IT',
      'salary': 100,
      'level': 'Senior',
      'notes': 'Team lead'
    },
    {
      'id': '2',
      'name': 'Bob',
      'department': 'IT',
      'salary': 120,
      'level': 'Junior',
      'notes': 'New hire'
    },
    {
      'id': '3',
      'name': 'Charlie',
      'department': 'IT',
      'salary': 110,
      'level': 'Senior',
      'notes': 'Architect'
    },
    {
      'id': '4',
      'name': 'David',
      'department': 'Sales',
      'salary': 90,
      'level': 'Manager',
      'notes': 'Regional lead'
    },
    {
      'id': '5',
      'name': 'Eve',
      'department': 'Sales',
      'salary': 95,
      'level': 'Senior',
      'notes': 'Top performer'
    },
    {
      'id': '6',
      'name': 'Frank',
      'department': 'Marketing',
      'salary': 85,
      'level': 'Junior',
      'notes': 'Creative specialist'
    },
  ];

  // Column configuration with different editability
  late final Map<String, TablePlusColumn> columns = {
    'id': TablePlusColumn(
      key: 'id',
      label: 'ID',
      order: 0,
      width: 60,
      alignment: Alignment.center, // Center align for better visibility
      textAlign: TextAlign.center,
      editable: false, // ID is not editable
    ),
    'name': TablePlusColumn(
      key: 'name',
      label: 'Name',
      order: 1,
      width: 120,
      alignment: Alignment.center, // Center align for better visibility
      textAlign: TextAlign.center,
      editable: true,
      hintText: 'Enter name',
    ),
    'department': TablePlusColumn(
      key: 'department',
      label: 'Department',
      order: 2,
      width: 150,
      alignment: Alignment.center, // Center align for better visibility
      textAlign: TextAlign.center,
      editable: true,
      hintText: 'Enter department',
    ),
    'level': TablePlusColumn(
      key: 'level',
      label: 'Level',
      order: 3,
      width: 100,
      alignment: Alignment.center, // Center align for better visibility
      textAlign: TextAlign.center,
      editable: true,
      hintText: 'Enter level',
    ),
    'salary': TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      order: 4,
      width: 100,
      alignment: Alignment.center, // Center align for better visibility
      textAlign: TextAlign.center,
      editable: true,
      hintText: 'Enter salary',
    ),
    'notes': TablePlusColumn(
      key: 'notes',
      label: 'Notes',
      order: 5,
      width: 150,
      alignment: Alignment.centerLeft, // Left align for notes (better for text)
      textAlign: TextAlign.left,
      editable: true,
      hintText: 'Enter notes',
    ),
  };

  // Merged groups configuration with editing support
  late final List<MergedRowGroup> mergedGroups = [
    // IT department group
    MergedRowGroup(
      groupId: 'it_group',
      rowKeys: ['1', '2', '3'], // Alice, Bob, Charlie
      mergeConfig: {
        'department': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          isEditable: true, // Department field is editable in merged cell
        ),
        'level': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 1,
          isEditable: true, // Level field is editable in merged cell
        ),
        // name, salary, notes are stacked (individual cells, all editable)
      },
    ),
    // Sales department group
    MergedRowGroup(
      groupId: 'sales_group',
      rowKeys: ['4', '5'], // David, Eve
      mergeConfig: {
        'department': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          isEditable: true, // Department field is editable
        ),
        'notes': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          isEditable: true, // Notes field is editable in merged cell
        ),
        // name, level, salary are stacked (individual cells)
      },
    ),
    // Marketing department - Frank (individual row, all editable)
  ];

  String lastAction = 'No actions yet';

  void _handleCellChanged(
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    setState(() {
      data[rowIndex][columnKey] = newValue;
      lastAction =
          'Changed ${data[rowIndex]['name']}\'s $columnKey from "$oldValue" to "$newValue"';
    });
  }

  void _handleMergedCellChanged(
      String groupId, String columnKey, dynamic newValue) {
    setState(() {
      // Find the group and update the appropriate row's data
      final group = mergedGroups.firstWhere((g) => g.groupId == groupId);
      final spanningRowKey = group.getSpanningRowKey(columnKey);
      final dataIndex =
          data.indexWhere((row) => row['id']?.toString() == spanningRowKey);

      if (dataIndex != -1) {
        final oldValue = data[dataIndex][columnKey];
        data[dataIndex][columnKey] = newValue;

        lastAction =
            'Changed $groupId\'s merged $columnKey from "$oldValue" to "$newValue"';
      }
    });
  }

  String _getEditingInfo() {
    int editableMergedCells = 0;
    int editableStackedCells = 0;
    int nonEditableCells = 0;

    for (final group in mergedGroups) {
      for (final entry in columns.entries) {
        final columnKey = entry.key;
        final column = entry.value;

        if (group.shouldMergeColumn(columnKey)) {
          if (group.isMergedCellEditable(columnKey)) {
            editableMergedCells++;
          } else {
            nonEditableCells++;
          }
        } else {
          if (column.editable) {
            editableStackedCells += group.rowCount;
          } else {
            nonEditableCells += group.rowCount;
          }
        }
      }
    }

    // Add individual rows (Frank)
    final individualRowCount = data.length -
        mergedGroups.fold<int>(0, (sum, group) => sum + group.rowCount);
    for (final column in columns.values) {
      if (column.editable) {
        editableStackedCells += individualRowCount;
      } else {
        nonEditableCells += individualRowCount;
      }
    }

    return 'Editable merged: $editableMergedCells, Editable stacked: $editableStackedCells, Non-editable: $nonEditableCells';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editable Merged Table'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description and Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editing with Merged Rows',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Features demonstrated:\n'
                      '• Merged cells that can be edited (same style as regular cells)\n'
                      '• Individual cells within merge groups\n'
                      '• Auto-save when clicking outside (focus lost)\n'
                      '• Center/left alignment support in editing mode\n'
                      '• Different callback handling for merged vs regular cells',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        _getEditingInfo(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'Last action: $lastAction',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
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
                    isEditable: true,
                    onCellChanged: _handleCellChanged,
                    onMergedCellChanged: _handleMergedCellChanged,
                  ),
                ),
              ),
            ),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Click any editable cell to start editing\n'
                      '• Merged cells span multiple rows\n'
                      '• Press Enter to save, Escape to cancel\n'
                      '• Click outside cell to auto-save\n'
                      '• Text is center/left aligned as configured',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
