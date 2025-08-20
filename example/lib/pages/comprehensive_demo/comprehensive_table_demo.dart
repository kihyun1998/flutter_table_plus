import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import 'data/demo_column_definitions.dart';
import 'data/demo_data_formatters.dart';
import 'data/demo_data_source.dart';

/// Comprehensive Flutter Table Plus Demo
///
/// This demo showcases ALL features of Flutter Table Plus in a single page:
/// - Basic table functionality (sorting, column reordering)
/// - Selection and editing
/// - Frozen columns
/// - Merged rows
/// - Expandable rows
/// - Hover buttons
/// - Custom cells and themes
///
/// Phase 1: Basic structure and data models ✅
/// Phase 2: Basic table and sorting (pending)
/// Phase 3: Selection and editing (pending)
/// Phase 4: Frozen columns (pending)
/// Phase 5: Merged rows (pending)
/// Phase 6: Expandable rows (pending)
/// Phase 7: Hover buttons (pending)
/// Phase 8: Custom cells and themes (pending)
/// Phase 9: Control panel and final integration (pending)
class ComprehensiveTableDemo extends StatefulWidget {
  const ComprehensiveTableDemo({super.key});

  @override
  State<ComprehensiveTableDemo> createState() => _ComprehensiveTableDemoState();
}

class _ComprehensiveTableDemoState extends State<ComprehensiveTableDemo> {
  // Phase 1: Basic data setup
  late Map<String, TablePlusColumn> _columns;
  late List<Map<String, dynamic>> _data;

  // Phase 2: Sorting state
  String? _currentSortColumn;
  SortDirection _currentSortDirection = SortDirection.none;

  // Future phases will add more state variables here:
  // - Selection state
  // - Editing state
  // - Theme configuration
  // - Feature toggles

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize table data and columns
  void _initializeData() {
    // Get column definitions
    _columns = DemoColumnDefinitions.getBasicEmployeeColumns();

    // Get sample data and format it for display
    _data = DemoDataSource.employeeTableData.map((employee) {
      return {
        ...employee,
        // Phase 2: Format data for better display
        'salary': DemoDataFormatters.formatCurrency(
            employee['salary']?.toDouble() ?? 0.0),
        'performance': DemoDataFormatters.formatPercentage(
            employee['performance']?.toDouble() ?? 0.0),
        'joinDate': DemoDataFormatters.formatDate(
            employee['joinDate'] ?? DateTime.now()),
        'skills': DemoDataFormatters.formatSkills(
            List<String>.from(employee['skills'] ?? [])),
      };
    }).toList();

    // Phase 2: Set default sort
    final defaultSort = DemoColumnDefinitions.getDefaultSortConfig();
    _currentSortColumn = defaultSort['column'];
    _currentSortDirection = defaultSort['direction'];

    // Apply initial sort
    _sortData(_currentSortColumn!, _currentSortDirection);

    debugPrint(
        '✅ Phase 2: Initialized with ${_data.length} employees, ${_columns.length} columns, default sort: $_currentSortColumn');
  }

  /// Phase 2: Handle column sorting
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      _currentSortColumn = columnKey;
      _currentSortDirection = direction;
      _sortData(columnKey, direction);
    });

    debugPrint('🔄 Sorted by $columnKey: $direction');
  }

  /// Phase 2: Handle column reordering
  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Get the list of column keys in order
      final columnKeys = _columns.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      // Adjust newIndex if moving forward
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Reorder the columns
      final movedColumn = columnKeys.removeAt(oldIndex);
      columnKeys.insert(newIndex, movedColumn);

      // Update order values
      for (int i = 0; i < columnKeys.length; i++) {
        final column = columnKeys[i];
        _columns[column.key] = column.copyWith(order: i);
      }
    });

    debugPrint('🔄 Reordered columns: $oldIndex -> $newIndex');
  }

  /// Phase 2: Sort data by column (considering formatted data)
  void _sortData(String columnKey, SortDirection direction) {
    if (direction == SortDirection.none) return;

    _data.sort((a, b) {
      final aValue = a[columnKey];
      final bValue = b[columnKey];

      // Handle null values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      int comparison = 0;

      // Special handling for formatted columns
      if (columnKey == 'salary') {
        // Extract numeric value from formatted currency
        final aNum = _extractSalaryNumber(aValue.toString());
        final bNum = _extractSalaryNumber(bValue.toString());
        comparison = aNum.compareTo(bNum);
      } else if (columnKey == 'performance') {
        // Extract numeric value from percentage
        final aNum = _extractPercentageNumber(aValue.toString());
        final bNum = _extractPercentageNumber(bValue.toString());
        comparison = aNum.compareTo(bNum);
      } else if (columnKey == 'joinDate') {
        // For formatted dates, use original DateTime for comparison
        final aEmployee =
            DemoDataSource.employees.firstWhere((e) => e.id == a['id']);
        final bEmployee =
            DemoDataSource.employees.firstWhere((e) => e.id == b['id']);
        comparison = aEmployee.joinDate.compareTo(bEmployee.joinDate);
      } else if (columnKey == 'skills') {
        // For skills, compare by the number of skills
        final aSkills =
            DemoDataSource.employees.firstWhere((e) => e.id == a['id']).skills;
        final bSkills =
            DemoDataSource.employees.firstWhere((e) => e.id == b['id']).skills;
        comparison = aSkills.length.compareTo(bSkills.length);
      } else if (aValue is String && bValue is String) {
        // Standard string comparison
        comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else {
        // Fallback to string comparison
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      // Apply sort direction
      return direction == SortDirection.ascending ? comparison : -comparison;
    });
  }

  /// Extract numeric value from formatted currency
  double _extractSalaryNumber(String formattedValue) {
    final numericString = formattedValue.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Extract numeric value from percentage
  double _extractPercentageNumber(String formattedValue) {
    final numericString = formattedValue.replaceAll('%', '');
    return double.tryParse(numericString) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Table Plus Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Phase 9: Control panel will be added here
          _buildPlaceholderControlPanel(),

          // Main table area
          Expanded(
            child: _buildTableArea(),
          ),

          // Phase 9: Stats panel will be added here
          _buildPlaceholderStatsPanel(),
        ],
      ),
    );
  }

  /// Phase 1: Placeholder control panel
  Widget _buildPlaceholderControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Control Panel (Phase 9)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Chip(
            label: const Text('Phase 1 ✅'),
            backgroundColor: Colors.green.shade100,
            labelStyle: TextStyle(color: Colors.green.shade800),
          ),
          const SizedBox(width: 8),
          Chip(
            label: const Text('Phase 2 ✅'),
            backgroundColor: Colors.green.shade100,
            labelStyle: TextStyle(color: Colors.green.shade800),
          ),
        ],
      ),
    );
  }

  /// Phase 1: Basic table area (empty for now)
  Widget _buildTableArea() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table Area',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Phase 1: Show basic info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Phase 2 Complete: Basic Table with Sorting & Column Reordering',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDataSummary(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Phase 2: Actual FlutterTablePlus implementation
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _data,

                    // Phase 2: Sorting functionality
                    onSort: _handleSort,
                    sortColumnKey: _currentSortColumn,
                    sortDirection: _currentSortDirection,

                    // Phase 2: Column reordering functionality
                    onColumnReorder: _handleColumnReorder,

                    // Phase 2: Basic theme
                    theme: _buildPhase2Theme(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build data summary for Phase 1
  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryItem('Employees', '${_data.length}', Icons.people),
        _buildSummaryItem('Departments', '${DemoDataSource.departments.length}',
            Icons.business),
        _buildSummaryItem(
            'Projects', '${DemoDataSource.projects.length}', Icons.folder),
        _buildSummaryItem('Columns', '${_columns.length}', Icons.view_column),
      ],
    );
  }

  /// Build individual summary item
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Phase 2: Build basic theme
  TablePlusTheme _buildPhase2Theme() {
    return TablePlusTheme(
      headerTheme: TablePlusHeaderTheme(
        backgroundColor: Colors.blue.shade50,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
          fontSize: 14,
        ),
      ),
      bodyTheme: TablePlusBodyTheme(
        backgroundColor: Colors.white,
        alternateRowColor: Colors.blue.shade50.withValues(alpha: 0.3),
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        dividerColor: Colors.grey.shade300,
        showHorizontalDividers: true,
        showVerticalDividers: true,
      ),
    );
  }

  /// Phase 2: Updated stats panel with sorting info
  Widget _buildPlaceholderStatsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Stats Panel (Phase 9)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          // Phase 2: Show current sort info
          if (_currentSortColumn != null &&
              _currentSortDirection != SortDirection.none)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Sort: $_currentSortColumn ${_currentSortDirection == SortDirection.ascending ? '↑' : '↓'}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          const Spacer(),
          Text(
            'Next: Phase 3 - Selection & Editing',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
