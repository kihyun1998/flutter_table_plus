import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class HoverButtonDemo extends StatefulWidget {
  const HoverButtonDemo({super.key});

  @override
  State<HoverButtonDemo> createState() => _HoverButtonDemoState();
}

class _HoverButtonDemoState extends State<HoverButtonDemo> {
  final List<Map<String, dynamic>> _data = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Developer',
      'salary': 75000,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'Designer',
      'salary': 65000,
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'email': 'bob@example.com',
      'role': 'Manager',
      'salary': 85000,
    },
    {
      'id': '4',
      'name': 'Alice Brown',
      'email': 'alice@example.com',
      'role': 'Developer',
      'salary': 72000,
    },
    {
      'id': '5',
      'name': 'Charlie Wilson',
      'email': 'charlie@example.com',
      'role': 'QA Tester',
      'salary': 55000,
    },
  ];

  final Map<String, TablePlusColumn> _columns = {
    'name': TablePlusColumn(key: 'name', label: 'Name', width: 150, order: 0),
    'email':
        TablePlusColumn(key: 'email', label: 'Email', width: 200, order: 1),
    'role': TablePlusColumn(key: 'role', label: 'Role', width: 120, order: 2),
    'salary': TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      width: 100,
      order: 3,
      cellBuilder: (context, data) {
        return Text(
          '\$${data['salary'].toString()}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        );
      },
    ),
  };

  void _handleEdit(String rowId) {
    final row = _data.firstWhere((row) => row['id'] == rowId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit clicked for: ${row['name']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleDelete(String rowId) {
    final row = _data.firstWhere((row) => row['id'] == rowId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${row['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _data.removeWhere((item) => item['id'] == rowId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${row['name']} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hover Button Demo'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.touch_app, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Row Hover Actions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hover over any row to see Edit and Delete buttons appear on the right side. '
                      'This is the new hover button feature!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _data,
                    theme: TablePlusTheme(
                      headerTheme: TablePlusHeaderTheme(
                        backgroundColor: Colors.orange.shade50,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      bodyTheme: TablePlusBodyTheme(
                        alternateRowColor: Colors.grey.shade50,
                      ),
                    ),
                    hoverButtonBuilder: (rowId, rowData) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _handleEdit(rowId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _handleDelete(rowId),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Try hovering over the rows above to see the new hover button feature in action!',
                        style: TextStyle(color: Colors.blue),
                      ),
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
