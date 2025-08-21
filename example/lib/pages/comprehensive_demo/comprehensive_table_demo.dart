import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import 'data/demo_column_definitions.dart';
import 'data/demo_data_formatters.dart';
import 'data/demo_data_source.dart';
import 'data/demo_merged_groups.dart';
import 'widgets/demo_control_panel.dart';
import 'widgets/demo_stats_panel.dart';
import 'widgets/demo_table_area.dart';

/// Comprehensive Flutter Table Plus Demo
///
/// This demo showcases ALL features of Flutter Table Plus in a single page:
/// - Basic table functionality (sorting, column reordering)
/// - Selection and editing
/// - Merged rows
/// - Expandable rows
/// - Hover buttons
/// - Custom cells and themes
///
/// Phase 1: Basic structure and data models ✅
/// Phase 2: Basic table and sorting ✅
/// Phase 3: Selection and editing ✅
/// Phase 4: Merged rows ✅
/// Phase 5: Expandable rows (pending)
/// Phase 6: Hover buttons (pending)
/// Phase 7: Custom cells and themes (pending)
/// Phase 8: Control panel and final integration (pending)
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
  late List<Map<String, dynamic>> _originalData; // Store original data order

  // Phase 3: Selection and editing state
  final bool _isSelectable = true;
  SelectionMode _selectionMode = SelectionMode.multiple;
  final Set<String> _selectedRows = <String>{};
  final bool _isEditable = true;

  // Phase 4: Merged rows state
  bool _showMergedRows = false;
  bool _expandedGroups = false;
  List<MergedRowGroup> _mergedGroups = [];

  // Phase 6: Individual row expansion and hover buttons state
  bool _showHoverButtons = false;

  // Future phases will add more state variables here:
  // - Theme configuration
  // - Advanced feature toggles

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

    // Store original data order for reset functionality
    _originalData = List<Map<String, dynamic>>.from(_data);

    // Phase 2: Set default sort
    final defaultSort = DemoColumnDefinitions.getDefaultSortConfig();
    _currentSortColumn = defaultSort['column'];
    _currentSortDirection = defaultSort['direction'];

    // Apply initial sort
    _sortData(_currentSortColumn!, _currentSortDirection);

    // Phase 4: Initialize merged groups
    _updateMergedGroups();

    debugPrint(
        '✅ Phase 2: Initialized with ${_data.length} employees, ${_columns.length} columns, default sort: $_currentSortColumn');
  }

  /// Phase 2: Handle column sorting
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      // Reset sort column when direction is none
      if (direction == SortDirection.none) {
        _currentSortColumn = null;
        _currentSortDirection = SortDirection.none;
      } else {
        _currentSortColumn = columnKey;
        _currentSortDirection = direction;
      }

      _sortData(columnKey, direction);

      // Phase 4: Update merged groups after sorting to maintain correct grouping
      if (_showMergedRows) {
        _updateMergedGroups();
      }
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
    if (direction == SortDirection.none) {
      // Restore original data order
      _data = List<Map<String, dynamic>>.from(_originalData);
      debugPrint('🔄 Restored original data order');
      return;
    }

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

  /// Phase 3: Handle row selection
  void _handleRowSelection(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectionMode == SelectionMode.single) {
          // Single selection: clear previous and select new
          _selectedRows.clear();
        }
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
      }
    });

    debugPrint('🔘 Selected rows: $_selectedRows');
  }

  /// Phase 4: Handle cell editing (expanded to include salary and performance)
  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      // Update the display data
      _data[rowIndex][columnKey] = newValue;

      // Also update the original data source for consistency
      final rowId = _data[rowIndex]['id'];
      final employeeIndex =
          DemoDataSource.employees.indexWhere((e) => e.id == rowId);
      if (employeeIndex != -1) {
        final originalEmployee = DemoDataSource.employees[employeeIndex];

        // Handle different column types
        dynamic updatedValue = newValue;
        if (columnKey == 'salary') {
          // Parse salary value (remove currency formatting if present)
          updatedValue = _parseCurrencyValue(newValue.toString());
        } else if (columnKey == 'performance') {
          // Parse percentage value (remove % if present)
          updatedValue = _parsePerformanceValue(newValue.toString());
        }

        DemoDataSource.employees[employeeIndex] = originalEmployee.copyWith(
          position:
              columnKey == 'position' ? newValue : originalEmployee.position,
          department: columnKey == 'department'
              ? newValue
              : originalEmployee.department,
          salary:
              columnKey == 'salary' ? updatedValue : originalEmployee.salary,
          performance: columnKey == 'performance'
              ? updatedValue
              : originalEmployee.performance,
        );

        // Re-format the display data after updating the source
        if (columnKey == 'salary') {
          _data[rowIndex][columnKey] =
              DemoDataFormatters.formatCurrency(updatedValue);
        } else if (columnKey == 'performance') {
          _data[rowIndex][columnKey] =
              DemoDataFormatters.formatPercentage(updatedValue);
        }

        // Update original data to reflect the edit (maintain sort reset functionality)
        final originalRowIndex =
            _originalData.indexWhere((row) => row['id'] == rowId);
        if (originalRowIndex != -1) {
          _originalData[originalRowIndex] =
              Map<String, dynamic>.from(_data[rowIndex]);
        }
      }
    });

    debugPrint(
        '✏️ Cell edited: Row $rowIndex, Column $columnKey: $oldValue -> $newValue');
  }

  /// Parse currency value from string (removes $ and commas)
  double _parseCurrencyValue(String value) {
    final numericString = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Parse performance value from string (removes % and converts to decimal)
  double _parsePerformanceValue(String value) {
    final numericString = value.replaceAll('%', '');
    final percentage = double.tryParse(numericString) ?? 0.0;
    return percentage / 100.0; // Convert percentage to decimal
  }

  /// Phase 3: Clear all selections
  void _clearSelections() {
    setState(() {
      _selectedRows.clear();
    });
    debugPrint('🗑️ Cleared all selections');
  }

  /// Phase 4: Update merged groups based on current settings and data order
  void _updateMergedGroups() {
    _mergedGroups = _showMergedRows
        ? DemoMergedGroups.createDepartmentGroups(
            expanded: _expandedGroups,
            currentData: _data, // Pass current data order
          )
        : [];
    debugPrint(
        '📊 Updated merged groups: ${_mergedGroups.length} groups, expanded: $_expandedGroups');
  }

  /// Phase 4: Toggle merged rows display
  void _toggleMergedRows() {
    setState(() {
      _showMergedRows = !_showMergedRows;
      _updateMergedGroups();

      // Maintain current sort when toggling merged rows
      if (_currentSortColumn != null &&
          _currentSortDirection != SortDirection.none) {
        _sortData(_currentSortColumn!, _currentSortDirection);
      }
    });
    debugPrint('🔄 Toggled merged rows: $_showMergedRows');
  }

  /// Phase 4: Toggle group expansion
  void _toggleGroupExpansion() {
    setState(() {
      _expandedGroups = !_expandedGroups;
      _updateMergedGroups();
    });
    debugPrint('🔄 Toggled group expansion: $_expandedGroups');
  }

  /// Phase 6: Toggle hover buttons display
  void _printButton() {
    setState(() {
      _showHoverButtons = !_showHoverButtons;
    });
    debugPrint('🔄 Toggled hover buttons: $_showHoverButtons');
  }

  /// Phase 6: Handle individual row expansion
  void _handleRowExpansion(String rowId) {
    debugPrint('🔄 Row $rowId expansion toggled. Expanded row');
  }

  /// Phase 4: Handle merged row group expansion change
  void _handleGroupExpansionChanged(String groupId) {
    setState(() {
      // Find the group and toggle its expansion state
      final groupIndex =
          _mergedGroups.indexWhere((group) => group.groupId == groupId);
      if (groupIndex != -1) {
        final currentGroup = _mergedGroups[groupIndex];
        final newExpansionState = !currentGroup.isExpanded;

        // Recreate merged groups with individual expansion state
        _mergedGroups = DemoMergedGroups.createDepartmentGroups(
          expanded: _expandedGroups, // Keep global setting
          currentData: _data,
        );

        // Find the same group again and update its expansion state
        final updatedGroupIndex = _mergedGroups.indexWhere((group) =>
                group.groupId == groupId ||
                group.rowKeys.join(',') ==
                    currentGroup.rowKeys
                        .join(',') // Fallback: match by row keys
            );

        if (updatedGroupIndex != -1) {
          final updatedGroup = _mergedGroups[updatedGroupIndex];
          _mergedGroups[updatedGroupIndex] = MergedRowGroup(
            groupId: updatedGroup.groupId,
            rowKeys: updatedGroup.rowKeys,
            mergeConfig: updatedGroup.mergeConfig,
            isExpandable: updatedGroup.isExpandable,
            isExpanded: newExpansionState,
            summaryRowData: updatedGroup.summaryRowData,
          );
        }
      }
    });
    debugPrint('🔄 Group $groupId expansion toggled');
  }

  /// Phase 4: Calculate dynamic row height based on department
  double _calculateRowHeight(int rowIndex, Map<String, dynamic> rowData) {
    final department = rowData['department']?.toString() ?? '';

    // HR department gets taller rows for better readability
    if (department == 'HR') {
      return 80.0; // Taller rows for HR
    }

    // Engineering department gets slightly taller rows due to technical content
    if (department == 'Engineering') {
      return 60.0;
    }

    // Default height for other departments
    return 50.0;
  }

  /// Phase 6: Build hover buttons for individual rows
  Widget _buildHoverButtons(String rowId, Map<String, dynamic> rowData) {
    final employeeName = rowData['name']?.toString() ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View Details button
          Tooltip(
            message: 'View $employeeName details',
            child: IconButton(
              icon: Icon(
                Icons.visibility,
                size: 18,
                color: Colors.blue.shade700,
              ),
              onPressed: () {
                debugPrint(
                    '👁️ View details clicked for Employee ID: $rowId (Name: $employeeName)');
                _handleRowExpansion(rowId); // Keep for visual feedback
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Edit button
          Tooltip(
            message: 'Edit $employeeName',
            child: IconButton(
              icon: Icon(
                Icons.edit,
                size: 18,
                color: Colors.orange.shade600,
              ),
              onPressed: () {
                debugPrint(
                    '✏️ Edit clicked for Employee ID: $rowId (Name: $employeeName)');
                // Could trigger edit mode for this specific row
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Delete button
          Tooltip(
            message: 'Delete $employeeName',
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade600,
              ),
              onPressed: () {
                debugPrint(
                    '🗑️ Delete clicked for Employee ID: $rowId (Name: $employeeName)');
                // Could show confirmation dialog
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Control panel
            _buildControlPanel(),

            // Main table area with increased height
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.7, // 70% of screen height
              child: _buildTableArea(),
            ),

            // Stats panel
            _buildStatsPanel(),
          ],
        ),
      ),
    );
  }

  /// Control panel with selection controls and feature toggles
  Widget _buildControlPanel() {
    return DemoControlPanel(
      selectionMode: _selectionMode,
      onSelectionModeChanged: (SelectionMode newValue) {
        setState(() {
          _selectionMode = newValue;
          _selectedRows.clear();
        });
      },
      selectedRows: _selectedRows,
      onClearSelections: _clearSelections,
      isEditable: _isEditable,
      showMergedRows: _showMergedRows,
      onToggleMergedRows: _toggleMergedRows,
      expandedGroups: _expandedGroups,
      onToggleGroupExpansion: _toggleGroupExpansion,
      mergedGroups: _mergedGroups,
      showHoverButtons: _showHoverButtons,
      onToggleHoverButtons: _printButton,
    );
  }

  /// Main table area with FlutterTablePlus widget
  Widget _buildTableArea() {
    return DemoTableArea(
      columns: _columns,
      data: _data,
      currentSortColumn: _currentSortColumn,
      currentSortDirection: _currentSortDirection,
      onSort: _handleSort,
      onColumnReorder: _handleColumnReorder,
      isSelectable: _isSelectable,
      selectionMode: _selectionMode,
      selectedRows: _selectedRows,
      onRowSelectionChanged: _handleRowSelection,
      isEditable: _isEditable,
      onCellChanged: _handleCellChanged,
      mergedGroups: _mergedGroups,
      onMergedRowExpandToggle: _handleGroupExpansionChanged,
      calculateRowHeight: _calculateRowHeight,
      theme: _buildPhase6Theme(),
      showMergedRows: _showMergedRows,
      expandedGroups: _expandedGroups,
      showHoverButtons: _showHoverButtons,
      hoverButtonBuilder: _showHoverButtons ? _buildHoverButtons : null,
    );
  }

  /// Phase 6: Build theme with all features including hover buttons
  TablePlusTheme _buildPhase6Theme() {
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
      selectionTheme: TablePlusSelectionTheme(
        selectedRowColor: Colors.blue.shade100.withValues(alpha: 0.6),
        checkboxColor: Colors.blue.shade600,
      ),
      editableTheme: TablePlusEditableTheme(
        editingCellColor: Colors.yellow.shade100,
        editingBorderColor: Colors.orange.shade400,
        editingBorderWidth: 2.0,
      ),
      // Phase 6: Hover button theme
      hoverButtonTheme: TablePlusHoverButtonTheme(
        backgroundColor: Colors.white,
        opacity: 0.95,
        iconSize: 18.0,
        horizontalOffset: 8.0,
        spacing: 4.0,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        borderRadius: BorderRadius.circular(6),
        elevation: 2.0,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Stats panel with current table information
  Widget _buildStatsPanel() {
    return DemoStatsPanel(
      currentSortColumn: _currentSortColumn,
      currentSortDirection: _currentSortDirection,
      selectedRows: _selectedRows,
      showMergedRows: _showMergedRows,
      expandedGroups: _expandedGroups,
      mergedGroups: _mergedGroups,
      showHoverButtons: _showHoverButtons,
    );
  }
}
