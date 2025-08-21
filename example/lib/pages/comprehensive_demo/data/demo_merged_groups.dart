import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../models/demo_department.dart';
import '../models/demo_employee.dart';
import 'demo_data_source.dart';

/// Merged row group configurations for comprehensive demo
class DemoMergedGroups {
  /// Create department-based merged row groups based on current data order
  static List<MergedRowGroup> createDepartmentGroups({
    bool expanded = false,
    required List<Map<String, dynamic>> currentData,
  }) {
    final groups = <MergedRowGroup>[];

    // Group ALL rows by department (not just consecutive ones)
    final Map<String, List<String>> departmentGroups = {};

    // Collect all rows by department
    for (int i = 0; i < currentData.length; i++) {
      final row = currentData[i];
      final department = row['department'] as String;
      final rowId = row['id'] as String;

      departmentGroups.putIfAbsent(department, () => []).add(rowId);
    }

    // Create groups for departments with more than 1 employee
    final List<Map<String, dynamic>> departmentGroupsList = [];
    departmentGroups.forEach((department, rowIds) {
      if (rowIds.length > 1) {
        departmentGroupsList.add({
          'department': department,
          'rowIds': rowIds,
        });
      }
    });

    // Create merged groups for each department group
    for (int groupIndex = 0;
        groupIndex < departmentGroupsList.length;
        groupIndex++) {
      final groupData = departmentGroupsList[groupIndex];
      final departmentName = groupData['department'] as String;
      final rowIds = groupData['rowIds'] as List<String>;

      // Find the department info
      final department = DemoDataSource.departments
          .firstWhere((dept) => dept.name == departmentName);

      // Get employees for this group
      final departmentEmployees = rowIds
          .map((id) =>
              DemoDataSource.employees.firstWhere((emp) => emp.id == id))
          .toList();

      // Create merge configuration for each column - only merge department
      final mergeConfig = <String, MergeCellConfig>{
        'name': MergeCellConfig(
          shouldMerge: false, // Keep individual names visible
        ),
        'position': MergeCellConfig(
          shouldMerge: false, // Keep individual positions visible
        ),
        'department': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          mergedContent: _buildDepartmentBadge(department),
        ),
        'salary': MergeCellConfig(
          shouldMerge: false, // Keep individual cells, show average in summary
        ),
        'performance': MergeCellConfig(
          shouldMerge: false, // Keep individual cells, show average in summary
        ),
        'joinDate': MergeCellConfig(
          shouldMerge: false,
        ),
        'skills': MergeCellConfig(
          shouldMerge: false,
        ),
      };

      // Create summary row data for expanded groups
      final summaryRowData = <String, dynamic>{
        'name': '📊 ${department.name} Summary',
        'position': '${departmentEmployees.length} employees total',
        'department': department.name,
        'salary':
            'Avg: ${_formatCurrency(_calculateAverageSalary(departmentEmployees))}',
        'performance':
            'Avg: ${(_calculateAveragePerformance(departmentEmployees) * 100).toStringAsFixed(0)}%',
        'joinDate': 'Various',
        'skills': 'Mixed',
      };

      groups.add(MergedRowGroup(
        groupId:
            '${departmentName.toLowerCase()}_group', // Unique ID for each department group
        rowKeys: rowIds,
        mergeConfig: mergeConfig,
        isExpandable: true,
        isExpanded: expanded,
        summaryRowData: summaryRowData,
      ));
    }

    return groups;
  }

  /// Build department badge (centered)
  static Widget _buildDepartmentBadge(DemoDepartment department) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: department.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: department.color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDepartmentIcon(department.name),
              color: department.color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              department.name,
              style: TextStyle(
                color: department.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon for department
  static IconData _getDepartmentIcon(String departmentName) {
    switch (departmentName) {
      case 'Engineering':
        return Icons.computer;
      case 'Design':
        return Icons.palette;
      case 'Marketing':
        return Icons.campaign;
      case 'Sales':
        return Icons.trending_up;
      case 'HR':
        return Icons.people;
      default:
        return Icons.business;
    }
  }

  /// Calculate average salary for employees
  static double _calculateAverageSalary(List<DemoEmployee> employees) {
    if (employees.isEmpty) return 0.0;
    final totalSalary =
        employees.fold<double>(0, (sum, emp) => sum + emp.salary);
    return totalSalary / employees.length;
  }

  /// Calculate average performance for employees
  static double _calculateAveragePerformance(List<DemoEmployee> employees) {
    if (employees.isEmpty) return 0.0;
    final totalPerformance =
        employees.fold<double>(0, (sum, emp) => sum + emp.performance);
    return totalPerformance / employees.length;
  }

  /// Format currency without external dependencies
  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  /// Get summary statistics for all departments
  static Map<String, dynamic> getDepartmentSummaryStats() {
    final allEmployees = DemoDataSource.employees;
    final departments = DemoDataSource.departments;

    return {
      'totalEmployees': allEmployees.length,
      'totalDepartments': departments.length,
      'avgDepartmentSize':
          (allEmployees.length / departments.length).toStringAsFixed(1),
      'totalSalaryBudget':
          allEmployees.fold<double>(0, (sum, emp) => sum + emp.salary),
      'avgPerformance':
          allEmployees.fold<double>(0, (sum, emp) => sum + emp.performance) /
              allEmployees.length,
    };
  }
}
