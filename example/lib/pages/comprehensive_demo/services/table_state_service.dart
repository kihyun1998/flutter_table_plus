import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/demo_merged_groups.dart';

/// Static service for managing table state operations
/// 
/// This service provides static methods for:
/// - Selection state management  
/// - Merged rows configuration
/// - Table feature state validation
/// - State synchronization helpers
class TableStateService {
  // Private constructor to prevent instantiation
  TableStateService._();

  /// Handle row selection with mode-specific logic
  static Set<String> updateSelection(
    Set<String> currentSelection,
    String rowId,
    bool isSelected,
    SelectionMode selectionMode,
  ) {
    final updatedSelection = Set<String>.from(currentSelection);
    
    if (selectionMode == SelectionMode.single) {
      // Single selection mode: clear previous and select new
      if (isSelected) {
        updatedSelection.clear();
        updatedSelection.add(rowId);
      } else {
        updatedSelection.remove(rowId);
      }
    } else {
      // Multiple selection mode: normal toggle behavior
      if (isSelected) {
        updatedSelection.add(rowId);
      } else {
        updatedSelection.remove(rowId);
      }
    }
    
    return updatedSelection;
  }

  /// Select all rows from data
  static Set<String> selectAllRows(List<Map<String, dynamic>> data) {
    return data.map((row) => row['id'].toString()).toSet();
  }

  /// Clear all selections
  static Set<String> clearAllSelections() {
    return <String>{};
  }

  /// Select rows based on condition
  static Set<String> selectRowsWhere(
    List<Map<String, dynamic>> data,
    bool Function(Map<String, dynamic>) condition,
  ) {
    return data
        .where(condition)
        .map((row) => row['id'].toString())
        .toSet();
  }

  /// Get selected row data
  static List<Map<String, dynamic>> getSelectedRowsData(
    List<Map<String, dynamic>> data,
    Set<String> selectedRows,
  ) {
    return data.where((row) => selectedRows.contains(row['id'].toString())).toList();
  }

  /// Get selected names for display
  static List<String> getSelectedNames(
    List<Map<String, dynamic>> data,
    Set<String> selectedRows,
  ) {
    return getSelectedRowsData(data, selectedRows)
        .map((row) => row['name']?.toString() ?? 'Unknown')
        .toList();
  }

  /// Create merged row groups based on current data and settings
  static List<MergedRowGroup> createMergedGroups(
    List<Map<String, dynamic>> currentData, {
    bool expanded = false,
    String groupBy = 'department',
  }) {
    return DemoMergedGroups.createDepartmentGroups(
      expanded: expanded,
      currentData: currentData,
    );
  }

  /// Update merged group expansion state
  static List<MergedRowGroup> updateGroupExpansion(
    List<MergedRowGroup> currentGroups,
    String groupId,
    bool isExpanded,
  ) {
    return currentGroups.map((group) {
      if (group.groupId == groupId) {
        return MergedRowGroup(
          groupId: group.groupId,
          rowKeys: group.rowKeys,
          mergeConfig: group.mergeConfig,
          isExpandable: group.isExpandable,
          isExpanded: isExpanded,
          summaryRowData: group.summaryRowData,
        );
      }
      return group;
    }).toList();
  }

  /// Expand all groups
  static List<MergedRowGroup> expandAllGroups(List<MergedRowGroup> groups) {
    return groups.map((group) => MergedRowGroup(
      groupId: group.groupId,
      rowKeys: group.rowKeys,
      mergeConfig: group.mergeConfig,
      isExpandable: group.isExpandable,
      isExpanded: true,
      summaryRowData: group.summaryRowData,
    )).toList();
  }

  /// Collapse all groups
  static List<MergedRowGroup> collapseAllGroups(List<MergedRowGroup> groups) {
    return groups.map((group) => MergedRowGroup(
      groupId: group.groupId,
      rowKeys: group.rowKeys,
      mergeConfig: group.mergeConfig,
      isExpandable: group.isExpandable,
      isExpanded: false,
      summaryRowData: group.summaryRowData,
    )).toList();
  }

  /// Validate selection state
  static Map<String, dynamic> validateSelection(
    Set<String> selectedRows,
    List<Map<String, dynamic>> data,
    SelectionMode selectionMode,
  ) {
    final issues = <String>[];
    
    // Check if selected rows exist in data
    final dataIds = data.map((row) => row['id'].toString()).toSet();
    final invalidSelections = selectedRows.where((id) => !dataIds.contains(id)).toList();
    
    if (invalidSelections.isNotEmpty) {
      issues.add('Invalid selections found: ${invalidSelections.join(', ')}');
    }
    
    // Check single selection mode constraint
    if (selectionMode == SelectionMode.single && selectedRows.length > 1) {
      issues.add('Single selection mode allows only one selected row');
    }
    
    return {
      'valid': issues.isEmpty,
      'issues': issues,
      'selectedCount': selectedRows.length,
      'maxAllowed': selectionMode == SelectionMode.single ? 1 : data.length,
      'invalidSelections': invalidSelections,
    };
  }

  /// Synchronize selection with current data after filtering/sorting
  static Set<String> synchronizeSelection(
    Set<String> currentSelection,
    List<Map<String, dynamic>> newData,
  ) {
    final newDataIds = newData.map((row) => row['id'].toString()).toSet();
    return currentSelection.where((id) => newDataIds.contains(id)).toSet();
  }

  /// Get selection statistics
  static Map<String, dynamic> getSelectionStats(
    Set<String> selectedRows,
    List<Map<String, dynamic>> data,
  ) {
    final selectedData = getSelectedRowsData(data, selectedRows);
    
    // Calculate statistics
    final departments = <String, int>{};
    double totalSalary = 0.0;
    int totalAge = 0;
    
    for (final row in selectedData) {
      // Department count
      final dept = row['department']?.toString() ?? 'Unknown';
      departments[dept] = (departments[dept] ?? 0) + 1;
      
      // Salary sum (extract from formatted string)
      final salaryStr = row['salary']?.toString() ?? '0';
      final salary = double.tryParse(salaryStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      totalSalary += salary;
      
      // Age sum
      final age = row['age'] as int? ?? 0;
      totalAge += age;
    }
    
    final selectedCount = selectedRows.length;
    
    return {
      'selectedCount': selectedCount,
      'totalCount': data.length,
      'selectionPercentage': data.isNotEmpty ? (selectedCount / data.length * 100).round() : 0,
      'departmentBreakdown': departments,
      'totalSalary': totalSalary,
      'averageSalary': selectedCount > 0 ? totalSalary / selectedCount : 0.0,
      'averageAge': selectedCount > 0 ? totalAge / selectedCount : 0.0,
      'selectedNames': getSelectedNames(data, selectedRows),
    };
  }

  /// Create selection summary text
  static String createSelectionSummary(
    Set<String> selectedRows,
    List<Map<String, dynamic>> data,
  ) {
    if (selectedRows.isEmpty) {
      return 'No rows selected';
    }
    
    final stats = getSelectionStats(selectedRows, data);
    final count = stats['selectedCount'] as int;
    final total = stats['totalCount'] as int;
    final percentage = stats['selectionPercentage'] as int;
    
    return '$count of $total rows selected ($percentage%)';
  }

  /// Check if merged rows are compatible with current selection
  static Map<String, dynamic> validateMergedRowsWithSelection(
    List<MergedRowGroup> mergedGroups,
    Set<String> selectedRows,
  ) {
    final issues = <String>[];
    final warnings = <String>[];
    
    for (final group in mergedGroups) {
      final groupRowIds = group.rowKeys.toSet();
      final selectedInGroup = selectedRows.intersection(groupRowIds);
      
      // If some but not all rows in group are selected, it might cause confusion
      if (selectedInGroup.isNotEmpty && selectedInGroup.length != groupRowIds.length) {
        warnings.add('Group ${group.groupId} has partial selection (${selectedInGroup.length}/${groupRowIds.length})');
      }
    }
    
    return {
      'valid': issues.isEmpty,
      'issues': issues,
      'warnings': warnings,
    };
  }
}