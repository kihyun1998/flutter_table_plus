import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import 'services/column_management_service.dart';
import 'services/table_data_service.dart';
import 'services/table_state_service.dart';
import 'widgets/demo_control_panel.dart';
import 'widgets/demo_stats_panel.dart';
import 'widgets/demo_table_area.dart';

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
  Set<String> _selectedRows = <String>{};
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

  /// Initialize table data and columns using services
  void _initializeData() {
    // Initialize columns using service
    _columns = ColumnManagementService.initializeColumns();

    // Initialize and format data using service
    _data = TableDataService.initializeData();

    // Store original data order for reset functionality
    _originalData = List<Map<String, dynamic>>.from(_data);

    // Set default sort using service
    final defaultSort = TableDataService.getDefaultSortConfig();
    _currentSortColumn = defaultSort['column'];
    _currentSortDirection = defaultSort['direction'];

    // Apply initial sort using service
    TableDataService.sortData(
        _data, _currentSortColumn!, _currentSortDirection);

    // Initialize merged groups using service
    _updateMergedGroups();

    debugPrint(
        '✅ Service-based initialization: ${_data.length} employees, ${_columns.length} columns, default sort: $_currentSortColumn');
  }

  /// Handle column sorting using service
  void _handleSort(String columnKey, SortDirection direction) {
    setState(() {
      // Update sort state
      if (direction == SortDirection.none) {
        _currentSortColumn = null;
        _currentSortDirection = SortDirection.none;
        // Reset to original data order
        _data = List<Map<String, dynamic>>.from(_originalData);
      } else {
        _currentSortColumn = columnKey;
        _currentSortDirection = direction;
        // Use service to sort data
        TableDataService.sortData(_data, columnKey, direction);
      }

      // Update merged groups after sorting to maintain correct grouping
      if (_showMergedRows) {
        _updateMergedGroups();
      }
    });

    debugPrint('🔄 Service-based sort by $columnKey: $direction');
  }

  /// Handle column reordering using service
  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Use service to safely reorder columns
      _columns =
          ColumnManagementService.reorderColumns(_columns, oldIndex, newIndex);
    });

    debugPrint('🔄 Service-based column reorder: $oldIndex -> $newIndex');
  }

  /// Handle row selection using service
  void _handleRowSelection(String rowId, bool isSelected) {
    setState(() {
      _selectedRows = TableStateService.updateSelection(
          _selectedRows, rowId, isSelected, _selectionMode);
    });

    debugPrint('🔘 Service-based selection: $_selectedRows');
  }

  /// Handle cell editing using service
  void _handleCellChanged(
      String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      // Use service to update cell data
      final result = TableDataService.updateCellData(
          _data, columnKey, rowIndex, oldValue, newValue);

      if (result['success'] == true) {
        // Update original data to reflect the edit (maintain sort reset functionality)
        final rowId = result['rowId'];
        final originalRowIndex =
            _originalData.indexWhere((row) => row['id'] == rowId);
        if (originalRowIndex != -1) {
          _originalData[originalRowIndex] =
              Map<String, dynamic>.from(_data[rowIndex]);
        }

        debugPrint(
            '✏️ Service-based cell edit: Row $rowIndex, Column $columnKey: $oldValue -> ${result['updatedValue']}');
      } else {
        debugPrint('❌ Cell edit failed: ${result['error']}');
      }
    });
  }

  /// Clear all selections using service
  void _clearSelections() {
    setState(() {
      _selectedRows = TableStateService.clearAllSelections();
    });
    debugPrint('🗑️ Service-based clear selections');
  }

  /// Update merged groups using service
  void _updateMergedGroups() {
    _mergedGroups = _showMergedRows
        ? TableStateService.createMergedGroups(_data, expanded: _expandedGroups)
        : [];
    debugPrint(
        '📊 Service-based merged groups: ${_mergedGroups.length} groups, expanded: $_expandedGroups');
  }

  /// Phase 4: Toggle merged rows display
  void _toggleMergedRows() {
    setState(() {
      _showMergedRows = !_showMergedRows;
      _updateMergedGroups();

      // Maintain current sort when toggling merged rows
      if (_currentSortColumn != null &&
          _currentSortDirection != SortDirection.none) {
        TableDataService.sortData(
            _data, _currentSortColumn!, _currentSortDirection);
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

  /// Handle merged row group expansion using service
  void _handleGroupExpansionChanged(String groupId) {
    setState(() {
      // Find the current expansion state
      final currentGroup = _mergedGroups.firstWhere(
        (group) => group.groupId == groupId,
        orElse: () => _mergedGroups.first, // Fallback
      );

      // Toggle expansion state using service
      _mergedGroups = TableStateService.updateGroupExpansion(
          _mergedGroups, groupId, !currentGroup.isExpanded);
    });
    debugPrint('🔄 Service-based group $groupId expansion toggled');
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
        selectedRowColor: Colors.blue.shade100.withValues(alpha: 0.6),
      ),

      editableTheme: TablePlusEditableTheme(
        editingCellColor: Colors.yellow.shade100,
        editingBorderColor: Colors.orange.shade400,
        editingBorderWidth: 2.0,
      ),
      // Phase 6: Hover button theme
      hoverButtonTheme: TablePlusHoverButtonTheme(
        horizontalOffset: 8.0,
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
