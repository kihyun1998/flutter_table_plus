import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import 'demo_data_summary.dart';

/// Table area widget for the comprehensive table demo
///
/// Contains the main FlutterTablePlus widget with all configured features
/// including sorting, selection, editing, and merged rows functionality.
class DemoTableArea extends StatelessWidget {
  final Map<String, TablePlusColumn> columns;
  final List<Map<String, dynamic>> data;
  final String? currentSortColumn;
  final SortDirection currentSortDirection;
  final Function(String, SortDirection) onSort;
  final Function(int, int) onColumnReorder;
  final bool isSelectable;
  final SelectionMode selectionMode;
  final Set<String> selectedRows;
  final Function(String, bool) onRowSelectionChanged;
  final bool isEditable;
  final Function(String, int, dynamic, dynamic) onCellChanged;
  final List<MergedRowGroup> mergedGroups;
  final Function(String) onMergedRowExpandToggle;
  final double? Function(int, Map<String, dynamic>)? calculateRowHeight;
  final TablePlusTheme theme;
  final bool showMergedRows;
  final bool expandedGroups;

  const DemoTableArea({
    super.key,
    required this.columns,
    required this.data,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.onSort,
    required this.onColumnReorder,
    required this.isSelectable,
    required this.selectionMode,
    required this.selectedRows,
    required this.onRowSelectionChanged,
    required this.isEditable,
    required this.onCellChanged,
    required this.mergedGroups,
    required this.onMergedRowExpandToggle,
    required this.calculateRowHeight,
    required this.theme,
    required this.showMergedRows,
    required this.expandedGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(context),
            const SizedBox(height: 16),
            _buildStatusInfo(),
            const SizedBox(height: 16),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Text(
      'Table Area',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildStatusInfo() {
    return Container(
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
                showMergedRows
                    ? 'Phase 4 Active: Department Groups with Merged Rows'
                    : 'Phase 3 Complete: Selection, Editing & Advanced Interactions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: showMergedRows
                      ? Colors.purple.shade900
                      : Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DemoDataSummary(
            data: data,
            columns: columns,
            showMergedRows: showMergedRows,
            expandedGroups: expandedGroups,
            mergedGroups: mergedGroups,
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FlutterTablePlus(
            columns: columns,
            data: data,

            // Phase 2: Sorting functionality
            onSort: onSort,
            sortColumnKey: currentSortColumn,
            sortDirection: currentSortDirection,

            // Phase 2: Column reordering functionality
            onColumnReorder: onColumnReorder,

            // Phase 3: Selection functionality
            isSelectable: isSelectable,
            selectionMode: selectionMode,
            selectedRows: selectedRows,
            onRowSelectionChanged: onRowSelectionChanged,

            // Phase 3: Editing functionality
            isEditable: isEditable,
            onCellChanged: onCellChanged,

            // Phase 4: Merged rows functionality
            mergedGroups: mergedGroups,
            onMergedRowExpandToggle: onMergedRowExpandToggle,

            // Phase 4: Dynamic row height calculation
            calculateRowHeight: calculateRowHeight,

            // Phase 4: Theme configuration
            theme: theme,
          ),
        ),
      ),
    );
  }
}
