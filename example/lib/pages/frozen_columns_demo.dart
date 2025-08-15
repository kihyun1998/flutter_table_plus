import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class FrozenColumnsDemo extends StatefulWidget {
  const FrozenColumnsDemo({super.key});

  @override
  State<FrozenColumnsDemo> createState() => _FrozenColumnsDemoState();
}

class _FrozenColumnsDemoState extends State<FrozenColumnsDemo> {
  // Table state
  Set<String> _selectedRows = {};
  bool _isSelectable = true;
  bool _isEditable = true;
  bool _isSortable = true;
  final bool _isReorderable = true;
  final SelectionMode _selectionMode = SelectionMode.multiple;

  // Sort state
  String? _sortColumnKey;
  SortDirection _sortDirection = SortDirection.none;
  List<Map<String, dynamic>> _sortedData = [];

  late Map<String, TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _initializeData();
  }

  void _initializeColumns() {
    _columns = {
      'id': TablePlusColumn(
        key: 'id',
        label: 'Employee ID',
        order: 1,
        frozen: true, // Frozen column
        width: 100,
        minWidth: 80,
        sortable: true,
      ),
      'name': TablePlusColumn(
        key: 'name',
        label: 'Full Name',
        order: 2,
        frozen: true, // Frozen column
        width: 150,
        minWidth: 120,
        sortable: true,
        editable: true,
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        order: 3,
        frozen: false, // Scrollable column
        width: 140,
        minWidth: 100,
        sortable: true,
        editable: true,
      ),
      'position': TablePlusColumn(
        key: 'position',
        label: 'Position',
        order: 4,
        frozen: false,
        width: 160,
        minWidth: 120,
        sortable: true,
        editable: true,
      ),
      'email': TablePlusColumn(
        key: 'email',
        label: 'Email Address',
        order: 5,
        frozen: false,
        width: 220,
        minWidth: 150,
        sortable: true,
        editable: true,
      ),
      'phone': TablePlusColumn(
        key: 'phone',
        label: 'Phone Number',
        order: 6,
        frozen: false,
        width: 130,
        minWidth: 100,
        sortable: true,
        editable: true,
      ),
      'salary': TablePlusColumn(
        key: 'salary',
        label: 'Annual Salary',
        order: 7,
        frozen: false,
        width: 120,
        minWidth: 100,
        sortable: true,
        editable: true,
        cellBuilder: (context, rowData) {
          final salary = rowData['salary'] as int? ?? 0;
          return Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '\$${salary.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color:
                    salary >= 100000 ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          );
        },
      ),
      'startDate': TablePlusColumn(
        key: 'startDate',
        label: 'Start Date',
        order: 8,
        frozen: false,
        width: 110,
        minWidth: 90,
        sortable: true,
      ),
      'location': TablePlusColumn(
        key: 'location',
        label: 'Office Location',
        order: 9,
        frozen: false,
        width: 140,
        minWidth: 100,
        sortable: true,
        editable: true,
      ),
      'status': TablePlusColumn(
        key: 'status',
        label: 'Employment Status',
        order: 10,
        frozen: false,
        width: 130,
        minWidth: 100,
        sortable: true,
        editable: true,
        cellBuilder: (context, rowData) {
          final status = rowData['status']?.toString() ?? 'Unknown';
          Color statusColor;
          switch (status.toLowerCase()) {
            case 'active':
              statusColor = Colors.green;
              break;
            case 'on leave':
              statusColor = Colors.orange;
              break;
            case 'inactive':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }

          return Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    };
  }

  void _initializeData() {
    _sortedData = [
      {
        'id': 'EMP001',
        'name': 'John Anderson',
        'department': 'Engineering',
        'position': 'Senior Software Engineer',
        'email': 'john.anderson@company.com',
        'phone': '+1 (555) 123-4567',
        'salary': 120000,
        'startDate': '2021-03-15',
        'location': 'San Francisco, CA',
        'status': 'Active',
      },
      {
        'id': 'EMP002',
        'name': 'Sarah Johnson',
        'department': 'Product Management',
        'position': 'Product Manager',
        'email': 'sarah.johnson@company.com',
        'phone': '+1 (555) 234-5678',
        'salary': 115000,
        'startDate': '2020-07-22',
        'location': 'New York, NY',
        'status': 'Active',
      },
      {
        'id': 'EMP003',
        'name': 'Michael Chen',
        'department': 'Engineering',
        'position': 'Frontend Developer',
        'email': 'michael.chen@company.com',
        'phone': '+1 (555) 345-6789',
        'salary': 95000,
        'startDate': '2022-01-10',
        'location': 'Austin, TX',
        'status': 'Active',
      },
      {
        'id': 'EMP004',
        'name': 'Emily Davis',
        'department': 'Design',
        'position': 'UX Designer',
        'email': 'emily.davis@company.com',
        'phone': '+1 (555) 456-7890',
        'salary': 85000,
        'startDate': '2021-11-08',
        'location': 'Seattle, WA',
        'status': 'On Leave',
      },
      {
        'id': 'EMP005',
        'name': 'David Wilson',
        'department': 'Marketing',
        'position': 'Marketing Director',
        'email': 'david.wilson@company.com',
        'phone': '+1 (555) 567-8901',
        'salary': 130000,
        'startDate': '2019-05-12',
        'location': 'Los Angeles, CA',
        'status': 'Active',
      },
      {
        'id': 'EMP006',
        'name': 'Lisa Thompson',
        'department': 'Human Resources',
        'position': 'HR Manager',
        'email': 'lisa.thompson@company.com',
        'phone': '+1 (555) 678-9012',
        'salary': 88000,
        'startDate': '2020-09-30',
        'location': 'Chicago, IL',
        'status': 'Active',
      },
      {
        'id': 'EMP007',
        'name': 'Robert Garcia',
        'department': 'Engineering',
        'position': 'DevOps Engineer',
        'email': 'robert.garcia@company.com',
        'phone': '+1 (555) 789-0123',
        'salary': 110000,
        'startDate': '2021-08-14',
        'location': 'Denver, CO',
        'status': 'Active',
      },
      {
        'id': 'EMP008',
        'name': 'Jennifer Lee',
        'department': 'Sales',
        'position': 'Sales Representative',
        'email': 'jennifer.lee@company.com',
        'phone': '+1 (555) 890-1234',
        'salary': 75000,
        'startDate': '2022-04-25',
        'location': 'Miami, FL',
        'status': 'Active',
      },
      {
        'id': 'EMP009',
        'name': 'Christopher Brown',
        'department': 'Finance',
        'position': 'Financial Analyst',
        'email': 'christopher.brown@company.com',
        'phone': '+1 (555) 901-2345',
        'salary': 82000,
        'startDate': '2021-12-03',
        'location': 'Boston, MA',
        'status': 'Inactive',
      },
      {
        'id': 'EMP010',
        'name': 'Amanda Rodriguez',
        'department': 'Engineering',
        'position': 'Backend Developer',
        'email': 'amanda.rodriguez@company.com',
        'phone': '+1 (555) 012-3456',
        'salary': 105000,
        'startDate': '2020-11-18',
        'location': 'Portland, OR',
        'status': 'Active',
      },
      {
        'id': 'EMP011',
        'name': 'James Taylor',
        'department': 'Product Management',
        'position': 'Senior Product Manager',
        'email': 'james.taylor@company.com',
        'phone': '+1 (555) 123-0987',
        'salary': 135000,
        'startDate': '2019-02-14',
        'location': 'San Francisco, CA',
        'status': 'Active',
      },
      {
        'id': 'EMP012',
        'name': 'Rachel Williams',
        'department': 'Design',
        'position': 'Visual Designer',
        'email': 'rachel.williams@company.com',
        'phone': '+1 (555) 234-0987',
        'salary': 78000,
        'startDate': '2022-06-07',
        'location': 'New York, NY',
        'status': 'Active',
      },
    ];
  }

  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      if (direction == SortDirection.none) {
        _sortColumnKey = null;
        _sortDirection = SortDirection.none;
        _initializeData(); // Reset to original order
      } else {
        _sortColumnKey = columnKey;
        _sortDirection = direction;
        _sortData(columnKey, direction);
      }
    });
  }

  void _sortData(String columnKey, SortDirection direction) {
    _sortedData.sort((a, b) {
      dynamic aValue = a[columnKey];
      dynamic bValue = b[columnKey];

      // Handle different data types
      if (aValue is String && bValue is String) {
        return direction == SortDirection.ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return direction == SortDirection.ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else {
        // Convert to string for comparison
        String aStr = aValue?.toString() ?? '';
        String bStr = bValue?.toString() ?? '';
        return direction == SortDirection.ascending
            ? aStr.compareTo(bStr)
            : bStr.compareTo(aStr);
      }
    });
  }

  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      if (columnKey == 'salary') {
        // Parse salary string to int
        final cleanValue = newValue.toString().replaceAll(RegExp(r'[^\d]'), '');
        _sortedData[rowIndex][columnKey] = int.tryParse(cleanValue) ?? oldValue;
      } else {
        _sortedData[rowIndex][columnKey] = newValue;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Updated $columnKey for ${_sortedData[rowIndex]['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectionMode == SelectionMode.single) {
          _selectedRows.clear();
        }
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
      }
    });
  }

  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedRows = _sortedData.map((row) => row['id'].toString()).toSet();
      } else {
        _selectedRows.clear();
      }
    });
  }

  void _handleColumnReorder(int oldIndex, int newIndex) {
    // Get reorderable columns (excluding frozen and selection columns)
    final reorderableColumns = _columns.values
        .where(
            (col) => col.visible && !col.frozen && col.key != '__selection__')
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final column = reorderableColumns.removeAt(oldIndex);
    reorderableColumns.insert(newIndex, column);

    // Update orders for reorderable columns only
    setState(() {
      int newOrder = 3; // Start after frozen columns (id=1, name=2)
      for (final col in reorderableColumns) {
        _columns[col.key] = col.copyWith(order: newOrder);
        newOrder++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reordered ${column.label} column'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frozen Columns Demo'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: Icon(_isSelectable
                ? Icons.check_box
                : Icons.check_box_outline_blank),
            onPressed: () => setState(() => _isSelectable = !_isSelectable),
            tooltip: 'Toggle Selection',
          ),
          IconButton(
            icon: Icon(_isEditable ? Icons.edit : Icons.edit_off),
            onPressed: () => setState(() => _isEditable = !_isEditable),
            tooltip: 'Toggle Editing',
          ),
          IconButton(
            icon: Icon(_isSortable ? Icons.sort : null),
            onPressed: () => setState(() => _isSortable = !_isSortable),
            tooltip: 'Toggle Sorting',
          ),
        ],
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
                  'Frozen Columns Feature Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Employee ID and Full Name are frozen (always visible). Other columns scroll horizontally.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text('Selected: ${_selectedRows.length}'),
                      backgroundColor: _selectedRows.isNotEmpty
                          ? Colors.blue.shade100
                          : null,
                    ),
                    Chip(
                      label: Text('Mode: ${_selectionMode.name}'),
                    ),
                    if (_sortColumnKey != null)
                      Chip(
                        label: Text(
                            'Sorted by: $_sortColumnKey (${_sortDirection.name})'),
                        backgroundColor: Colors.green.shade100,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: FlutterTablePlus(
              columns: _columns,
              data: _sortedData,
              isSelectable: _isSelectable,
              selectionMode: _selectionMode,
              selectedRows: _selectedRows,
              onRowSelectionChanged: _handleRowSelectionChanged,
              onSelectAll: _handleSelectAll,
              onColumnReorder: _isReorderable ? _handleColumnReorder : null,
              sortColumnKey: _sortColumnKey,
              sortDirection: _sortDirection,
              onSort: _isSortable ? _handleSort : null,
              isEditable: _isEditable,
              onCellChanged: _handleCellChanged,
              onRowDoubleTap: (rowId) {
                final employee =
                    _sortedData.firstWhere((row) => row['id'] == rowId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Double-tapped on ${employee['name']}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
