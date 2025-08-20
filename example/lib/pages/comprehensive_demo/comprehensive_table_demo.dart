import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import 'data/demo_data_source.dart';
import 'data/demo_column_definitions.dart';

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

  // Future phases will add more state variables here:
  // - Sort state
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
    
    // Get sample data
    _data = DemoDataSource.employeeTableData;
    
    debugPrint('✅ Phase 1: Initialized with ${_data.length} employees and ${_columns.length} columns');
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Phase 1 Complete: Basic Structure & Data Models',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
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
            
            // Placeholder for actual table (Phase 2)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_chart,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FlutterTablePlus will appear here in Phase 2',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to implement basic table and sorting',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
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
        _buildSummaryItem('Departments', '${DemoDataSource.departments.length}', Icons.business),
        _buildSummaryItem('Projects', '${DemoDataSource.projects.length}', Icons.folder),
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

  /// Phase 1: Placeholder stats panel
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
          const Spacer(),
          Text(
            'Next: Phase 2 - Basic Table & Sorting',
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