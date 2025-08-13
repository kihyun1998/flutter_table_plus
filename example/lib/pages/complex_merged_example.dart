import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Complex example demonstrating multiple column merging and custom content.
class ComplexMergedExample extends StatelessWidget {
  const ComplexMergedExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data with more complex merging scenarios
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
    ];

    // Column configuration
    final Map<String, TablePlusColumn> columns = {
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

    // Complex merged groups configuration
    final List<MergedRowGroup> mergedGroups = [
      // IT department group - merge ID, Department, and Level columns
      MergedRowGroup(
        groupId: 'it_group',
        originalIndices: [0, 1, 2], // Alice, Bob, Charlie
        mergeConfig: {
          'id': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0, // Show Alice's ID
            mergedContent: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.computer, color: Colors.blue, size: 20),
                  Text('IT', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Team',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
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
                  Text(
                    'IT Department',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    '3 members',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          'level': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 1, // Show Bob's level as representative
          ),
          // name and salary are not merged - each row shows its own value
        },
      ),
      // Sales department group - different merge pattern
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
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    '2 members',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Other columns not merged for Sales
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complex Merged Table Example'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complex Merged Table Features',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This example demonstrates:\n'
                      '• Multiple column merging (ID + Department + Level)\n'
                      '• Custom merged content with widgets\n'
                      '• Different spanningRowIndex values\n'
                      '• Multiple merge groups in same table',
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
