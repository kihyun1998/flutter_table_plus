import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Stats panel widget for the comprehensive table demo
/// 
/// Displays current sort information, selection statistics, merged rows status,
/// and phase completion indicators.
class DemoStatsPanel extends StatelessWidget {
  final String? currentSortColumn;
  final SortDirection currentSortDirection;
  final Set<String> selectedRows;
  final bool showMergedRows;
  final bool expandedGroups;
  final List<dynamic> mergedGroups;

  const DemoStatsPanel({
    super.key,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.selectedRows,
    required this.showMergedRows,
    required this.expandedGroups,
    required this.mergedGroups,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildStatsHeader(),
          const SizedBox(width: 16),
          _buildSortInfo(),
          _buildSelectionInfo(),
          _buildMergedRowsInfo(),
          const Spacer(),
          _buildPhaseStatus(),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Row(
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
      ],
    );
  }

  Widget _buildSortInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (currentSortColumn != null && currentSortDirection != SortDirection.none)
            ? Colors.blue.shade100
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        (currentSortColumn != null && currentSortDirection != SortDirection.none)
            ? 'Sort: $currentSortColumn ${currentSortDirection == SortDirection.ascending ? '↑' : '↓'}'
            : 'Sort: Original order',
        style: TextStyle(
          color: (currentSortColumn != null && currentSortDirection != SortDirection.none)
              ? Colors.blue.shade700
              : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    if (selectedRows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Selected: ${selectedRows.length} row${selectedRows.length != 1 ? 's' : ''}',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMergedRowsInfo() {
    if (!showMergedRows) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Merged: ${mergedGroups.length} groups (${expandedGroups ? "expanded" : "collapsed"})',
          style: TextStyle(
            color: Colors.purple.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseStatus() {
    return Text(
      showMergedRows 
          ? 'Phase 4: Merged Rows Active ✨'
          : 'Next: Phase 5 - Expandable Rows',
      style: TextStyle(
        color: showMergedRows 
            ? Colors.purple.shade700
            : Colors.orange.shade700,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}