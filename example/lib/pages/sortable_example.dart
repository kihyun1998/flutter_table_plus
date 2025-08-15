import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class SortableExample extends StatefulWidget {
  const SortableExample({super.key});

  @override
  State<SortableExample> createState() => _SortableExampleState();
}

class _SortableExampleState extends State<SortableExample> {
  // Sample data with 10 employees - grouped by department for merging
  List<Map<String, dynamic>> data = [
    // Engineering Department (will be merged)
    {
      'id': '1',
      'name': 'Alice Johnson',
      'department': 'Engineering',
      'salary': 95000,
      'age': 28,
      'location': 'New York'
    },
    {
      'id': '3',
      'name': 'Charlie Brown',
      'department': 'Engineering',
      'salary': 88000,
      'age': 25,
      'location': 'Texas'
    },
    {
      'id': '7',
      'name':
          'George Wilson with a very long name that should wrap to multiple lines',
      'department': 'Engineering',
      'salary': 102000,
      'age': 38,
      'location': 'Oregon State with a very long location name'
    },
    {
      'id': '9',
      'name': 'Ian Foster',
      'department': 'Engineering',
      'salary': 89000,
      'age': 31,
      'location': 'Colorado'
    },
    // Marketing Department (will be merged)
    {
      'id': '2',
      'name': 'Bob Smith',
      'department': 'Marketing',
      'salary': 75000,
      'age': 32,
      'location': 'California'
    },
    {
      'id': '8',
      'name': 'Hannah Davis',
      'department': 'Marketing',
      'salary': 71000,
      'age': 26,
      'location': 'Arizona'
    },
    // Finance Department (will be merged)
    {
      'id': '6',
      'name': 'Fiona Green',
      'department': 'Finance',
      'salary': 78000,
      'age': 29,
      'location': 'Washington'
    },
    {
      'id': '10',
      'name': 'Julia Roberts',
      'department': 'Finance',
      'salary': 85000,
      'age': 34,
      'location': 'Michigan'
    },
    // Individual departments
    {
      'id': '4',
      'name': 'Diana Prince',
      'department': 'HR',
      'salary': 82000,
      'age': 35,
      'location': 'Florida'
    },
    {
      'id': '5',
      'name': 'Ethan Hunt',
      'department': 'Security',
      'salary': 92000,
      'age': 30,
      'location': 'Nevada'
    },
  ];

  // Current sort configuration
  String? currentSortColumn;
  SortDirection? currentSortDirection;

  // Dynamic merged groups configuration - updates based on current data order
  List<MergedRowGroup> get mergedGroups => _generateMergedGroups();

  // Generate merged groups based on current data order
  List<MergedRowGroup> _generateMergedGroups() {
    // Group data by department and track their positions in current data
    final Map<String, List<String>> departmentGroups = {};

    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      final department = row['department'] as String;
      final rowId = row['id'] as String;

      departmentGroups.putIfAbsent(department, () => []).add(rowId);
    }

    // Only create merged groups for departments with more than 1 employee
    final List<MergedRowGroup> groups = [];

    departmentGroups.forEach((department, rowIds) {
      if (rowIds.length > 1) {
        // Create merged group based on department
        Widget mergedContent;
        Color color;
        IconData icon;

        switch (department) {
          case 'Engineering':
            color = Colors.blue;
            icon = Icons.computer;
            break;
          case 'Marketing':
            color = Colors.orange;
            icon = Icons.campaign;
            break;
          case 'Finance':
            color = Colors.green;
            icon = Icons.account_balance;
            break;
          default:
            color = Colors.grey;
            icon = Icons.business;
        }

        mergedContent = Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                department,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

        groups.add(
          MergedRowGroup(
            groupId: '${department.toLowerCase()}_group',
            rowKeys: rowIds,
            mergeConfig: {
              'department': MergeCellConfig(
                shouldMerge: true,
                spanningRowIndex: 0,
                mergedContent: mergedContent,
              ),
            },
          ),
        );
      }
    });

    return groups;
  }

  @override
  void initState() {
    super.initState();
    // Ensure merged groups are properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Column configuration with sorting enabled
    final Map<String, TablePlusColumn> columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'ID',
        order: 0,
        width: 60,
        sortable: true,
      ),
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        order: 1,
        width: 150,
        sortable: true,
        textOverflow: TextOverflow.ellipsis,
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 2,
        width: 130,
        sortable: true,
      ),
      'salary': TablePlusColumn(
        key: 'salary',
        label: 'Salary',
        order: 3,
        width: 100,
        sortable: true,
        alignment: Alignment.centerRight,
        cellBuilder: (context, rowData) {
          final salary = rowData['salary'] as int;
          return Text(
            '\$${salary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: salary > 90000 ? Colors.green.shade700 : Colors.black87,
            ),
          );
        },
      ),
      'age': TablePlusColumn(
        key: 'age',
        label: 'Age',
        order: 4,
        width: 80,
        sortable: true,
        alignment: Alignment.center,
      ),
      'location': TablePlusColumn(
        key: 'location',
        label: 'Location',
        order: 5,
        width: 120,
        sortable: true,
        textOverflow: TextOverflow.ellipsis,
      ),
    };

    // Debug columns (commented out for production)
    // columns.forEach((key, col) {
    //   print('📋 $key: sortable=${col.sortable}');
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortable & Merged Table'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sort, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Sortable Table with Merged Departments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click on any column header to sort the data. Departments are merged by groups with custom styling.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (currentSortColumn != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Sorted by: ${columns[currentSortColumn]?.label} (${currentSortDirection?.name.toUpperCase()})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics row
            Row(
              children: [
                _buildStatCard(
                  'Total Employees',
                  data.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Avg Salary',
                  '\$${(data.map((e) => e['salary'] as int).reduce((a, b) => a + b) / data.length).round()}',
                  Icons.attach_money,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Departments',
                  data.map((e) => e['department']).toSet().length.toString(),
                  Icons.business,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Table section
            Container(
              height: 700, // Increased table height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlutterTablePlus(
                columns: columns,
                data: data,
                rowIdKey: 'id',
                mergedGroups: mergedGroups,
                onSort: (col, dir) {
                  _handleSort(col, dir);
                },
                sortColumnKey: currentSortColumn,
                sortDirection: currentSortDirection ?? SortDirection.none,
                theme: TablePlusTheme(
                  headerTheme: TablePlusHeaderTheme(
                    backgroundColor: Colors.grey.shade100,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    height: 50,
                    showBottomDivider: true,
                    dividerColor: Colors.grey.shade300,
                    sortIcons: const SortIcons(
                      ascending: Icon(Icons.arrow_upward,
                          size: 20, color: Colors.green),
                      descending: Icon(Icons.arrow_downward,
                          size: 20, color: Colors.red),
                      unsorted: Icon(Icons.unfold_more,
                          size: 20, color: Colors.black),
                    ),
                  ),
                  bodyTheme: TablePlusBodyTheme(
                    alternateRowColor: Colors.grey.shade50,
                    rowHeight: 48,
                    textStyle: const TextStyle(fontSize: 13),
                    dividerColor: Colors.grey.shade200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Footer with additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features Demonstrated:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Column sorting (click headers to sort)'),
                  const Text('• Merged row groups by department'),
                  const Text('• Custom merged cell content with icons'),
                  const Text('• Custom cell rendering (salary formatting)'),
                  const Text('• Different column alignments'),
                  const Text('• Themed table appearance'),
                  const Text('• Scrollable table with fixed height'),
                  const SizedBox(height: 12),
                  Text(
                    'Data includes ${data.length} employees across ${data.map((e) => e['department']).toSet().length} departments',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.lerp(color, Colors.black, 0.3)!,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.lerp(color, Colors.black, 0.2)!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      currentSortColumn = columnKey;
      currentSortDirection = direction;

      // Reset to none means restore original order
      if (direction == SortDirection.none) {
        // Restore original data order
        data = [
          {
            'id': '1',
            'name': 'Alice Johnson',
            'department': 'Engineering',
            'salary': 95000,
            'age': 28,
            'location': 'New York'
          },
          {
            'id': '3',
            'name': 'Charlie Brown',
            'department': 'Engineering',
            'salary': 88000,
            'age': 25,
            'location': 'Texas'
          },
          {
            'id': '7',
            'name':
                'George Wilson with a very long name that should wrap to multiple lines',
            'department': 'Engineering',
            'salary': 102000,
            'age': 38,
            'location': 'Oregon State with a very long location name'
          },
          {
            'id': '9',
            'name': 'Ian Foster',
            'department': 'Engineering',
            'salary': 89000,
            'age': 31,
            'location': 'Colorado'
          },
          {
            'id': '2',
            'name': 'Bob Smith',
            'department': 'Marketing',
            'salary': 75000,
            'age': 32,
            'location': 'California'
          },
          {
            'id': '8',
            'name': 'Hannah Davis',
            'department': 'Marketing',
            'salary': 71000,
            'age': 26,
            'location': 'Arizona'
          },
          {
            'id': '6',
            'name': 'Fiona Green',
            'department': 'Finance',
            'salary': 78000,
            'age': 29,
            'location': 'Washington'
          },
          {
            'id': '10',
            'name': 'Julia Roberts',
            'department': 'Finance',
            'salary': 85000,
            'age': 34,
            'location': 'Michigan'
          },
          {
            'id': '4',
            'name': 'Diana Prince',
            'department': 'HR',
            'salary': 82000,
            'age': 35,
            'location': 'Florida'
          },
          {
            'id': '5',
            'name': 'Ethan Hunt',
            'department': 'Security',
            'salary': 92000,
            'age': 30,
            'location': 'Nevada'
          },
        ];
        return;
      }

      // Sort data by the specified column
      data.sort((a, b) {
        dynamic valueA = a[columnKey];
        dynamic valueB = b[columnKey];

        // Handle different data types
        int comparison;
        if (valueA is String && valueB is String) {
          comparison = valueA.toLowerCase().compareTo(valueB.toLowerCase());
        } else if (valueA is num && valueB is num) {
          comparison = valueA.compareTo(valueB);
        } else {
          comparison = valueA.toString().compareTo(valueB.toString());
        }

        // Apply sort direction
        return direction == SortDirection.ascending ? comparison : -comparison;
      });
    });
  }
}
