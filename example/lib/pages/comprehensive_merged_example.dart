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
  String? _currentSortColumn;
  SortDirection? _currentSortDirection;

  // Sample data representing employees grouped by department
  final List<Map<String, dynamic>> _data = [
    // Engineering Department
    {
      'id': '1',
      'name': 'Alexandriana Seraphina Aethelreda Abernathy',
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
      'id': '8',
      'name': 'Henry Davis',
      'department': 'Engineering',
      'position': 'DevOps Engineer',
      'salary': 110000,
      'experience': 7,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '9',
      'name': 'Isabella Rodriguez',
      'department': 'Engineering',
      'position': 'Frontend Developer',
      'salary': 95000,
      'experience': 5,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '10',
      'name': 'Jack Thompson',
      'department': 'Engineering',
      'position': 'Backend Developer',
      'salary': 105000,
      'experience': 6,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '11',
      'name': 'Katherine Wilson',
      'department': 'Engineering',
      'position': 'QA Engineer',
      'salary': 85000,
      'experience': 4,
      'location': 'New York',
      'status': 'Active'
    },
    {
      'id': '12',
      'name': 'Liam Anderson',
      'department': 'Engineering',
      'position': 'Mobile Developer',
      'salary': 100000,
      'experience': 5,
      'location': 'New York',
      'status': 'On Leave'
    },

    // Marketing Department
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
      'id': '13',
      'name': 'Michael Brown',
      'department': 'Marketing',
      'position': 'Digital Marketing Specialist',
      'salary': 75000,
      'experience': 3,
      'location': 'San Francisco',
      'status': 'Active'
    },
    {
      'id': '14',
      'name': 'Nina Garcia',
      'department': 'Marketing',
      'position': 'Brand Manager',
      'salary': 88000,
      'experience': 5,
      'location': 'San Francisco',
      'status': 'Active'
    },
    {
      'id': '15',
      'name': 'Oscar Kim',
      'department': 'Marketing',
      'position': 'Social Media Manager',
      'salary': 65000,
      'experience': 2,
      'location': 'San Francisco',
      'status': 'Active'
    },
    {
      'id': '16',
      'name': 'Paula Martinez',
      'department': 'Marketing',
      'position': 'Marketing Analyst',
      'salary': 72000,
      'experience': 3,
      'location': 'San Francisco',
      'status': 'Active'
    },

    // Sales Department
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
    {
      'id': '17',
      'name': 'Quinn Johnson',
      'department': 'Sales',
      'position': 'Sales Representative',
      'salary': 65000,
      'experience': 2,
      'location': 'Chicago',
      'status': 'Active'
    },
    {
      'id': '18',
      'name': 'Rachel White',
      'department': 'Sales',
      'position': 'Senior Account Executive',
      'salary': 95000,
      'experience': 7,
      'location': 'Chicago',
      'status': 'Active'
    },
    {
      'id': '19',
      'name': 'Samuel Turner',
      'department': 'Sales',
      'position': 'Business Development Manager',
      'salary': 105000,
      'experience': 8,
      'location': 'Chicago',
      'status': 'Active'
    },
    {
      'id': '20',
      'name': 'Tiffany Clark',
      'department': 'Sales',
      'position': 'Sales Coordinator',
      'salary': 55000,
      'experience': 1,
      'location': 'Chicago',
      'status': 'Active'
    },

    // HR Department
    {
      'id': '21',
      'name': 'Uma Patel',
      'department': 'HR',
      'position': 'HR Director',
      'salary': 115000,
      'experience': 12,
      'location': 'Austin',
      'status': 'Active'
    },
    {
      'id': '22',
      'name': 'Victor Lopez',
      'department': 'HR',
      'position': 'HR Specialist',
      'salary': 68000,
      'experience': 4,
      'location': 'Austin',
      'status': 'Active'
    },
    {
      'id': '23',
      'name': 'Wendy Adams',
      'department': 'HR',
      'position': 'Recruiter',
      'salary': 62000,
      'experience': 3,
      'location': 'Austin',
      'status': 'Active'
    },
    {
      'id': '24',
      'name': 'Xavier Chen',
      'department': 'HR',
      'position': 'Training Coordinator',
      'salary': 58000,
      'experience': 2,
      'location': 'Austin',
      'status': 'On Leave'
    },

    // Finance Department
    {
      'id': '25',
      'name': 'Yolanda Foster',
      'department': 'Finance',
      'position': 'Finance Director',
      'salary': 125000,
      'experience': 15,
      'location': 'Boston',
      'status': 'Active'
    },
    {
      'id': '26',
      'name': 'Zachary Moore',
      'department': 'Finance',
      'position': 'Senior Accountant',
      'salary': 78000,
      'experience': 6,
      'location': 'Boston',
      'status': 'Active'
    },
    {
      'id': '27',
      'name': 'Aria Scott',
      'department': 'Finance',
      'position': 'Financial Analyst',
      'salary': 72000,
      'experience': 4,
      'location': 'Boston',
      'status': 'Active'
    },
    {
      'id': '28',
      'name': 'Blake Rivera',
      'department': 'Finance',
      'position': 'Budget Analyst',
      'salary': 70000,
      'experience': 3,
      'location': 'Boston',
      'status': 'Active'
    },
    {
      'id': '29',
      'name': 'Chloe Taylor',
      'department': 'Finance',
      'position': 'Accounting Clerk',
      'salary': 52000,
      'experience': 1,
      'location': 'Boston',
      'status': 'Active'
    },

    // Operations Department
    {
      'id': '30',
      'name': 'Dylan Hayes',
      'department': 'Operations',
      'position': 'Operations Manager',
      'salary': 98000,
      'experience': 9,
      'location': 'Seattle',
      'status': 'Active'
    },
    {
      'id': '31',
      'name': 'Emma Watson',
      'department': 'Operations',
      'position': 'Process Improvement Specialist',
      'salary': 75000,
      'experience': 5,
      'location': 'Seattle',
      'status': 'Active'
    },
    {
      'id': '32',
      'name': 'Felix Garcia',
      'department': 'Operations',
      'position': 'Operations Coordinator',
      'salary': 58000,
      'experience': 2,
      'location': 'Seattle',
      'status': 'On Leave'
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
        tooltipBehavior: TooltipBehavior.always),
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

  // Merged row groups - dynamically generated based on current data order
  List<MergedRowGroup> get _mergedGroups {
    final Map<String, List<String>> departmentGroups = {};

    // Group row IDs by department based on current data order
    for (final row in _data) {
      final dept = row['department'] as String;
      final id = row['id'] as String;
      departmentGroups.putIfAbsent(dept, () => []).add(id);
    }

    final groups = <MergedRowGroup>[];

    // Engineering group
    if (departmentGroups.containsKey('Engineering')) {
      groups.add(MergedRowGroup(
        groupId: 'eng_group',
        rowKeys: departmentGroups['Engineering']!,
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
                    '${departmentGroups['Engineering']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    // Marketing group
    if (departmentGroups.containsKey('Marketing')) {
      groups.add(MergedRowGroup(
        groupId: 'marketing_group',
        rowKeys: departmentGroups['Marketing']!,
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
                    '${departmentGroups['Marketing']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    // Sales group
    if (departmentGroups.containsKey('Sales')) {
      groups.add(MergedRowGroup(
        groupId: 'sales_group',
        rowKeys: departmentGroups['Sales']!,
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
                    '${departmentGroups['Sales']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    // HR group
    if (departmentGroups.containsKey('HR')) {
      groups.add(MergedRowGroup(
        groupId: 'hr_group',
        rowKeys: departmentGroups['HR']!,
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, color: Colors.orange.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'HR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Text(
                    '${departmentGroups['HR']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    // Finance group
    if (departmentGroups.containsKey('Finance')) {
      groups.add(MergedRowGroup(
        groupId: 'finance_group',
        rowKeys: departmentGroups['Finance']!,
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money, color: Colors.indigo.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Finance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  Text(
                    '${departmentGroups['Finance']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    // Operations group
    if (departmentGroups.containsKey('Operations')) {
      groups.add(MergedRowGroup(
        groupId: 'operations_group',
        rowKeys: departmentGroups['Operations']!,
        mergeConfig: {
          'department': MergeCellConfig(
            shouldMerge: true,
            mergedContent: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Colors.teal.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Operations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  Text(
                    '${departmentGroups['Operations']!.length} employees',
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
            spanningRowIndex: 0,
          ),
        },
      ));
    }

    return groups;
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
          SizedBox(
            height: 500, // Fixed height to force vertical scrolling
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlutterTablePlus(
                  columns: _columns,
                  data: _data,
                  mergedGroups: _mergedGroups,

                  // Sorting
                  onSort: _isSortable ? _handleSort : null,
                  sortColumnKey: _currentSortColumn,
                  sortDirection: _currentSortDirection ?? SortDirection.none,

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

                  // Hover buttons
                  hoverButtonBuilder: (rowId, rowData) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline,
                            size: 18, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            _handleHoverButtonPress(rowId, rowData),
                        tooltip: 'Show Info',
                      ),
                    );
                  },

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
            ),
          )
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
      _currentSortColumn = columnKey;
      _currentSortDirection = direction;

      // Reset to none means restore original order
      if (direction == SortDirection.none) {
        // Restore original data order
        _data.clear();
        _data.addAll([
          // Engineering Department
          {
            'id': '1',
            'name': 'Alexandriana Seraphina Aethelreda Abernathy',
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
            'id': '8',
            'name': 'Henry Davis',
            'department': 'Engineering',
            'position': 'DevOps Engineer',
            'salary': 110000,
            'experience': 7,
            'location': 'New York',
            'status': 'Active'
          },
          {
            'id': '9',
            'name': 'Isabella Rodriguez',
            'department': 'Engineering',
            'position': 'Frontend Developer',
            'salary': 95000,
            'experience': 5,
            'location': 'New York',
            'status': 'Active'
          },
          {
            'id': '10',
            'name': 'Jack Thompson',
            'department': 'Engineering',
            'position': 'Backend Developer',
            'salary': 105000,
            'experience': 6,
            'location': 'New York',
            'status': 'Active'
          },
          {
            'id': '11',
            'name': 'Katherine Wilson',
            'department': 'Engineering',
            'position': 'QA Engineer',
            'salary': 85000,
            'experience': 4,
            'location': 'New York',
            'status': 'Active'
          },
          {
            'id': '12',
            'name': 'Liam Anderson',
            'department': 'Engineering',
            'position': 'Mobile Developer',
            'salary': 100000,
            'experience': 5,
            'location': 'New York',
            'status': 'On Leave'
          },

          // Marketing Department
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
            'id': '13',
            'name': 'Michael Brown',
            'department': 'Marketing',
            'position': 'Digital Marketing Specialist',
            'salary': 75000,
            'experience': 3,
            'location': 'San Francisco',
            'status': 'Active'
          },
          {
            'id': '14',
            'name': 'Nina Garcia',
            'department': 'Marketing',
            'position': 'Brand Manager',
            'salary': 88000,
            'experience': 5,
            'location': 'San Francisco',
            'status': 'Active'
          },
          {
            'id': '15',
            'name': 'Oscar Kim',
            'department': 'Marketing',
            'position': 'Social Media Manager',
            'salary': 65000,
            'experience': 2,
            'location': 'San Francisco',
            'status': 'Active'
          },
          {
            'id': '16',
            'name': 'Paula Martinez',
            'department': 'Marketing',
            'position': 'Marketing Analyst',
            'salary': 72000,
            'experience': 3,
            'location': 'San Francisco',
            'status': 'Active'
          },

          // Sales Department
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
          {
            'id': '17',
            'name': 'Quinn Johnson',
            'department': 'Sales',
            'position': 'Sales Representative',
            'salary': 65000,
            'experience': 2,
            'location': 'Chicago',
            'status': 'Active'
          },
          {
            'id': '18',
            'name': 'Rachel White',
            'department': 'Sales',
            'position': 'Senior Account Executive',
            'salary': 95000,
            'experience': 7,
            'location': 'Chicago',
            'status': 'Active'
          },
          {
            'id': '19',
            'name': 'Samuel Turner',
            'department': 'Sales',
            'position': 'Business Development Manager',
            'salary': 105000,
            'experience': 8,
            'location': 'Chicago',
            'status': 'Active'
          },
          {
            'id': '20',
            'name': 'Tiffany Clark',
            'department': 'Sales',
            'position': 'Sales Coordinator',
            'salary': 55000,
            'experience': 1,
            'location': 'Chicago',
            'status': 'Active'
          },

          // HR Department
          {
            'id': '21',
            'name': 'Uma Patel',
            'department': 'HR',
            'position': 'HR Director',
            'salary': 115000,
            'experience': 12,
            'location': 'Austin',
            'status': 'Active'
          },
          {
            'id': '22',
            'name': 'Victor Lopez',
            'department': 'HR',
            'position': 'HR Specialist',
            'salary': 68000,
            'experience': 4,
            'location': 'Austin',
            'status': 'Active'
          },
          {
            'id': '23',
            'name': 'Wendy Adams',
            'department': 'HR',
            'position': 'Recruiter',
            'salary': 62000,
            'experience': 3,
            'location': 'Austin',
            'status': 'Active'
          },
          {
            'id': '24',
            'name': 'Xavier Chen',
            'department': 'HR',
            'position': 'Training Coordinator',
            'salary': 58000,
            'experience': 2,
            'location': 'Austin',
            'status': 'On Leave'
          },

          // Finance Department
          {
            'id': '25',
            'name': 'Yolanda Foster',
            'department': 'Finance',
            'position': 'Finance Director',
            'salary': 125000,
            'experience': 15,
            'location': 'Boston',
            'status': 'Active'
          },
          {
            'id': '26',
            'name': 'Zachary Moore',
            'department': 'Finance',
            'position': 'Senior Accountant',
            'salary': 78000,
            'experience': 6,
            'location': 'Boston',
            'status': 'Active'
          },
          {
            'id': '27',
            'name': 'Aria Scott',
            'department': 'Finance',
            'position': 'Financial Analyst',
            'salary': 72000,
            'experience': 4,
            'location': 'Boston',
            'status': 'Active'
          },
          {
            'id': '28',
            'name': 'Blake Rivera',
            'department': 'Finance',
            'position': 'Budget Analyst',
            'salary': 70000,
            'experience': 3,
            'location': 'Boston',
            'status': 'Active'
          },
          {
            'id': '29',
            'name': 'Chloe Taylor',
            'department': 'Finance',
            'position': 'Accounting Clerk',
            'salary': 52000,
            'experience': 1,
            'location': 'Boston',
            'status': 'Active'
          },

          // Operations Department
          {
            'id': '30',
            'name': 'Dylan Hayes',
            'department': 'Operations',
            'position': 'Operations Manager',
            'salary': 98000,
            'experience': 9,
            'location': 'Seattle',
            'status': 'Active'
          },
          {
            'id': '31',
            'name': 'Emma Watson',
            'department': 'Operations',
            'position': 'Process Improvement Specialist',
            'salary': 75000,
            'experience': 5,
            'location': 'Seattle',
            'status': 'Active'
          },
          {
            'id': '32',
            'name': 'Felix Garcia',
            'department': 'Operations',
            'position': 'Operations Coordinator',
            'salary': 58000,
            'experience': 2,
            'location': 'Seattle',
            'status': 'On Leave'
          },
        ]);
        return;
      }

      // Sort entire data by the specified column
      _data.sort((a, b) {
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

  void _handleHoverButtonPress(String rowId, Map<String, dynamic> rowData) {
    // Check if this is a merged row (group ID) or regular row
    final isMergedRow = _mergedGroups.any((group) => group.groupId == rowId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('isMergedRow : $isMergedRow'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
