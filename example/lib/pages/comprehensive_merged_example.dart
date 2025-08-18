import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Comprehensive merged row example demonstrating all table features:
/// - Sorting
/// - Column reordering
/// - Cell editing
/// - Row selection (single/multiple)
/// - Custom merged content
/// - Theming
/// - Border behaviors
class ComprehensiveMergedExample extends StatefulWidget {
  const ComprehensiveMergedExample({super.key});

  @override
  State<ComprehensiveMergedExample> createState() =>
      _ComprehensiveMergedExampleState();
}

class _ComprehensiveMergedExampleState
    extends State<ComprehensiveMergedExample> {
  // Feature toggles
  bool _isSortable = true;
  bool _isEditable = true;
  bool _isSelectable = true;
  bool _isReorderable = true;
  SelectionMode _selectionMode = SelectionMode.multiple;
  LastRowBorderBehavior _borderBehavior = LastRowBorderBehavior.smart;

  // Table state
  final Set<String> _selectedRows = {};

  // Sample data representing employees grouped by department
  final List<Map<String, dynamic>> _data = [
    {
      'id': '1',
      'name': 'Alice Johnson',
      'department': 'Engineering',
      'position': 'Senior Developer',
      'salary': 120000,
      'experience': 8,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '2',
      'name': 'Bob Smith',
      'department': 'Engineering',
      'position': 'Junior Developer',
      'salary': 85000,
      'experience': 3,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '3',
      'name': 'Charlie Brown',
      'department': 'Engineering',
      'position': 'Tech Lead',
      'salary': 150000,
      'experience': 12,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '4',
      'name': 'Diana Prince',
      'department': 'Marketing',
      'position': 'Marketing Manager',
      'salary': 95000,
      'experience': 6,
      'location': 'San Francisco',
      'status': 'Active'
    },
    {
      'id': '5',
      'name': 'Eve Wilson',
      'department': 'Marketing',
      'position': 'Content Specialist',
      'salary': 70000,
      'experience': 4,
      'location': 'San Francisco',
      'status': 'On Leave'
    },
    {
      'id': '6',
      'name': 'Frank Miller',
      'department': 'Sales',
      'position': 'Sales Director',
      'salary': 110000,
      'experience': 10,
      'location': 'Chicago',
      'status': 'Active'
    },
    {
      'id': '7',
      'name': 'Grace Lee',
      'department': 'Sales',
      'position': 'Account Executive',
      'salary': 80000,
      'experience': 5,
      'location': 'Chicago',
      'status': 'Active'
    },
  ];

  // Columns configuration
  late final Map<String, TablePlusColumn> _columns = {
    'name': TablePlusColumn(
      key: 'name',
      label: 'Employee Name',
      order: 1,
      width: 180,
      minWidth: 120,
      sortable: true,
      editable: true,
    ),
    'department': TablePlusColumn(
      key: 'department',
      label: 'Department',
      order: 2,
      width: 140,
      minWidth: 100,
      sortable: true,
      editable: false, // Department merging - not editable
    ),
    'position': TablePlusColumn(
      key: 'position',
      label: 'Position',
      order: 3,
      width: 160,
      minWidth: 120,
      sortable: true,
      editable: true,
    ),
    'salary': TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      order: 4,
      width: 120,
      minWidth: 80,
      sortable: true,
      editable: true,
      textAlign: TextAlign.right,
      cellBuilder: (context, rowData) {
        final salary = rowData['salary'] as int?;
        return Text(
          '\$${salary?.toString() ?? '0'}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: salary != null && salary > 100000
                ? Colors.green.shade700
                : Colors.black87,
          ),
          textAlign: TextAlign.right,
        );
      },
    ),
    'experience': TablePlusColumn(
      key: 'experience',
      label: 'Years Exp.',
      order: 5,
      width: 100,
      minWidth: 80,
      sortable: true,
      editable: true,
      textAlign: TextAlign.center,
    ),
    'location': TablePlusColumn(
      key: 'location',
      label: 'Location',
      order: 6,
      width: 130,
      minWidth: 100,
      sortable: true,
      editable: true,
    ),
    'status': TablePlusColumn(
      key: 'status',
      label: 'Status',
      order: 7,
      width: 100,
      minWidth: 80,
      sortable: true,
      editable: true,
      cellBuilder: (context, rowData) {
        final status = rowData['status'] as String? ?? '';
        final isActive = status == 'Active';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade100 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    ),
  };

  // Merged row groups - group by department
  List<MergedRowGroup> get _mergedGroups {
    return [
      // Engineering group
      MergedRowGroup(
        groupId: 'eng_group',
        rowKeys: ['1', '2', '3'],
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.computer, color: Colors.blue.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Engineering',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    '3 employees',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          'location': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0, // Use Alice's location for the group
          ),
        },
      ),
      // Marketing group
      MergedRowGroup(
        groupId: 'marketing_group',
        rowKeys: ['4', '5'],
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, color: Colors.purple.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Marketing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  Text(
                    '2 employees',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          'location': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0, // Use Diana's location for the group
          ),
        },
      ),
      // Sales group
      MergedRowGroup(
        groupId: 'sales_group',
        rowKeys: ['6', '7'],
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: Colors.green.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '2 employees',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          'location': MergeCellConfig(
            shouldMerge: true,
            spanningRowIndex: 0, // Use Frank's location for the group
          ),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Merged Example'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All-in-One Merged Row Features Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Test all table features with merged rows: sorting, editing, selection, reordering, and theming.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // Feature toggles
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildToggleChip(
                      label: 'Sortable',
                      value: _isSortable,
                      onChanged: (value) => setState(() => _isSortable = value),
                    ),
                    _buildToggleChip(
                      label: 'Editable',
                      value: _isEditable,
                      onChanged: (value) => setState(() => _isEditable = value),
                    ),
                    _buildToggleChip(
                      label: 'Selectable',
                      value: _isSelectable,
                      onChanged: (value) =>
                          setState(() => _isSelectable = value),
                    ),
                    _buildToggleChip(
                      label: 'Reorderable',
                      value: _isReorderable,
                      onChanged: (value) =>
                          setState(() => _isReorderable = value),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Selection mode and border behavior
                Row(
                  children: [
                    if (_isSelectable) ...[
                      Text('Selection: ',
                          style: TextStyle(color: Colors.grey.shade700)),
                      DropdownButton<SelectionMode>(
                        value: _selectionMode,
                        onChanged: (value) =>
                            setState(() => _selectionMode = value!),
                        items: const [
                          DropdownMenuItem(
                            value: SelectionMode.single,
                            child: Text('Single'),
                          ),
                          DropdownMenuItem(
                            value: SelectionMode.multiple,
                            child: Text('Multiple'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],
                    Text('Last Row Border: ',
                        style: TextStyle(color: Colors.grey.shade700)),
                    DropdownButton<LastRowBorderBehavior>(
                      value: _borderBehavior,
                      onChanged: (value) =>
                          setState(() => _borderBehavior = value!),
                      items: const [
                        DropdownMenuItem(
                          value: LastRowBorderBehavior.never,
                          child: Text('Never'),
                        ),
                        DropdownMenuItem(
                          value: LastRowBorderBehavior.always,
                          child: Text('Always'),
                        ),
                        DropdownMenuItem(
                          value: LastRowBorderBehavior.smart,
                          child: Text('Smart'),
                        ),
                      ],
                    ),
                  ],
                ),

                if (_selectedRows.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedRows.length} ${_selectedRows.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Table
          Expanded(
            child: FlutterTablePlus(
              columns: _columns,
              data: _data,
              mergedGroups: _mergedGroups,

              // Sorting
              onSort: _isSortable ? _handleSort : null,

              // Column reordering
              onColumnReorder: _isReorderable ? _handleColumnReorder : null,

              // Selection
              isSelectable: _isSelectable,
              selectionMode: _selectionMode,
              selectedRows: _selectedRows,
              onRowSelectionChanged: _handleRowSelection,

              // Editing
              isEditable: _isEditable,
              onCellChanged: _handleCellChanged,
              onMergedCellChanged: _handleMergedCellChanged,

              // Theme with custom border behavior
              theme: TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(
                  lastRowBorderBehavior: _borderBehavior,
                  dividerColor: Colors.blue.shade200,
                  alternateRowColor: Colors.blue.shade50,
                ),
                headerTheme: TablePlusHeaderTheme(
                  backgroundColor: Colors.blue.shade50,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                selectionTheme: TablePlusSelectionTheme(
                  selectedRowColor: Colors.blue.shade100,
                  checkboxColor: Colors.blue.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.shade200,
      backgroundColor: Colors.grey.shade200,
    );
  }

  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      final ascending = direction == SortDirection.ascending;

      // Group data by department to maintain merged row structure
      final Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (final row in _data) {
        final dept = row['department'] as String;
        groupedData.putIfAbsent(dept, () => []).add(row);
      }

      // Sort within each department group
      for (final group in groupedData.values) {
        group.sort((a, b) {
          final aValue = a[columnKey];
          final bValue = b[columnKey];

          int comparison;
          if (aValue is num && bValue is num) {
            comparison = aValue.compareTo(bValue);
          } else {
            comparison = aValue.toString().compareTo(bValue.toString());
          }

          return ascending ? comparison : -comparison;
        });
      }

      // Sort department groups themselves if sorting by department
      final sortedDepartments = groupedData.keys.toList();
      if (columnKey == 'department') {
        sortedDepartments.sort((a, b) {
          final comparison = a.compareTo(b);
          return ascending ? comparison : -comparison;
        });
      }

      // Rebuild the data list maintaining group structure
      _data.clear();
      for (final dept in sortedDepartments) {
        _data.addAll(groupedData[dept]!);
      }
    });
  }

  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Convert column map to ordered list
      final columnEntries = _columns.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));

      // Reorder the list
      final item = columnEntries.removeAt(oldIndex);
      columnEntries.insert(newIndex, item);

      // Update orders
      for (int i = 0; i < columnEntries.length; i++) {
        final key = columnEntries[i].key;
        _columns[key] = _columns[key]!.copyWith(order: i + 1);
      }
    });
  }

  void _handleRowSelection(String rowId, bool isSelected) {
    setState(() {
      if (_selectionMode == SelectionMode.single) {
        _selectedRows.clear();
        if (isSelected) {
          _selectedRows.add(rowId);
        }
      } else {
        if (isSelected) {
          _selectedRows.add(rowId);
        } else {
          _selectedRows.remove(rowId);
        }
      }
    });
  }

  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      _data[rowIndex][columnKey] = newValue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated $columnKey to: $newValue'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMergedCellChanged(
      String groupId, String columnKey, dynamic newValue) {
    setState(() {
      // Find the merged group and update all rows in it
      final group = _mergedGroups.firstWhere((g) => g.groupId == groupId);
      for (final rowKey in group.rowKeys) {
        final rowIndex = _data.indexWhere((row) => row['id'] == rowKey);
        if (rowIndex != -1) {
          _data[rowIndex][columnKey] = newValue;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated merged $columnKey to: $newValue'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
