import 'package:flutter/material.dart';
import '../data/demo_data_source.dart';

/// Data summary widget for the comprehensive table demo
/// 
/// Displays key statistics about the current table state including
/// employee count, departments, projects, columns, and merged groups information.
class DemoDataSummary extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> columns;
  final bool showMergedRows;
  final bool expandedGroups;
  final List<dynamic> mergedGroups;

  const DemoDataSummary({
    super.key,
    required this.data,
    required this.columns,
    required this.showMergedRows,
    required this.expandedGroups,
    required this.mergedGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryItem('Employees', '${data.length}', Icons.people),
        _buildSummaryItem('Departments', '${DemoDataSource.departments.length}',
            Icons.business),
        _buildSummaryItem(
            'Projects', '${DemoDataSource.projects.length}', Icons.folder),
        _buildSummaryItem('Columns', '${columns.length}', Icons.view_column),
        if (showMergedRows) ...[
          _buildSummaryItem('Merged Groups', '${mergedGroups.length}', Icons.merge_type),
          _buildSummaryItem('Group Mode', expandedGroups ? 'Expanded' : 'Collapsed', Icons.expand_more),
        ],
      ],
    );
  }

  /// Build individual summary item with icon, label, and value
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
}