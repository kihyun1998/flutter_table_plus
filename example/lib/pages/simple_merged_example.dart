import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// A simple example demonstrating merged row functionality.
class SimpleMergedExample extends StatelessWidget {
  const SimpleMergedExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - IT department employees that we want to merge
    final List<Map<String, dynamic>> data = [
      {'id': '1', 'name': 'aman', 'department': 'it', 'salary': 100},
      {'id': '2', 'name': 'bman', 'department': 'it', 'salary': 300},
      {'id': '3', 'name': 'cman', 'department': 'business', 'salary': 500},
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
        label: 'NAME',
        order: 1,
        width: 120,
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 2,
        width: 150,
      ),
      'salary': TablePlusColumn(
        key: 'salary',
        label: 'salary',
        order: 3,
        width: 100,
      ),
    };

    // Merged groups configuration - merge IT department rows
    final List<MergedRowGroup> mergedGroups = [
      MergedRowGroup(
        groupId: 'm1',
        rowKeys: ['1', '2'], // Rows with id '1' and '2' (aman and bman)
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0, // Show in first row of the group
          ),
          // name and salary are not merged - each row shows its own value
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Merged Table Example'),
        backgroundColor: Colors.blue.shade100,
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
                      'Simple Merged Table Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Testing 2 rows merged in Department column only. '
                      'IT department should show as one merged cell spanning 2 rows.',
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
