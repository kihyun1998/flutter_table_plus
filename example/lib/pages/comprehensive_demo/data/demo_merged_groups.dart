import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'demo_data_source.dart';
import '../models/demo_employee.dart';
import '../models/demo_department.dart';

/// Merged row group configurations for comprehensive demo
class DemoMergedGroups {
  /// Create department-based merged row groups
  static List<MergedRowGroup> createDepartmentGroups({
    bool expanded = false,
  }) {
    final groups = <MergedRowGroup>[];
    final departments = DemoDataSource.departments;
    
    for (final department in departments) {
      // Get employees for this department
      final departmentEmployees = DemoDataSource.employees
          .where((emp) => emp.department == department.name)
          .toList();
      
      if (departmentEmployees.isEmpty) continue;
      
      // Create row keys from employee IDs
      final rowKeys = departmentEmployees.map((emp) => emp.id).toList();
      
      // Create merge configuration for each column
      final mergeConfig = <String, MergeCellConfig>{
        'name': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          mergedContent: _buildDepartmentSummaryCell(department, departmentEmployees),
        ),
        'position': MergeCellConfig(
          shouldMerge: true,
          spanningRowIndex: 0,
          mergedContent: _buildPositionSummaryCell(departmentEmployees),
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
        'name': '📊 Department Summary',
        'position': '${departmentEmployees.length} employees',
        'department': department.name,
        'salary': _formatCurrency(_calculateAverageSalary(departmentEmployees)),
        'performance': '${(_calculateAveragePerformance(departmentEmployees) * 100).toStringAsFixed(0)}%',
        'joinDate': 'Various dates',
        'skills': 'Mixed skills',
      };
      
      groups.add(MergedRowGroup(
        groupId: 'dept_${department.id}',
        rowKeys: rowKeys,
        mergeConfig: mergeConfig,
        isExpandable: true,
        isExpanded: expanded,
        summaryRowData: summaryRowData,
      ));
    }
    
    return groups;
  }
  
  /// Build department summary cell with expand/collapse functionality
  static Widget _buildDepartmentSummaryCell(
    DemoDepartment department, 
    List<DemoEmployee> employees
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Department icon/color indicator
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: department.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // Department info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  department.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${employees.length} employees • ${department.manager}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Employee count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: department.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: department.color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '${employees.length}',
              style: TextStyle(
                color: department.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build position summary for the department
  static Widget _buildPositionSummaryCell(List<DemoEmployee> employees) {
    final positions = employees.map((e) => e.position).toSet().toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${positions.length} role${positions.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (positions.length <= 3) ...[
            const SizedBox(height: 2),
            Text(
              positions.join(', '),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const SizedBox(height: 2),
            Text(
              '${positions.take(2).join(', ')} +${positions.length - 2} more',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build department badge (centered)
  static Widget _buildDepartmentBadge(DemoDepartment department) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: department.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: department.color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          department.name,
          style: TextStyle(
            color: department.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
  
  /// Build salary summary for the department
  static Widget _buildSalarySummaryCell(List<DemoEmployee> employees) {
    final totalSalary = employees.fold<double>(0, (sum, emp) => sum + emp.salary);
    final avgSalary = totalSalary / employees.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatCurrency(totalSalary),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Avg: ${_formatCurrency(avgSalary)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build performance summary for the department
  static Widget _buildPerformanceSummaryCell(List<DemoEmployee> employees) {
    final avgPerformance = employees.fold<double>(0, (sum, emp) => sum + emp.performance) / employees.length;
    final highPerformers = employees.where((emp) => emp.performance >= 0.9).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Average performance percentage
          Text(
            '${(avgPerformance * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _getPerformanceColor(avgPerformance),
            ),
          ),
          const SizedBox(height: 2),
          
          // High performers count
          if (highPerformers > 0) 
            Text(
              '$highPerformers top performer${highPerformers != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              'Avg performance',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Calculate average salary for employees
  static double _calculateAverageSalary(List<DemoEmployee> employees) {
    if (employees.isEmpty) return 0.0;
    final totalSalary = employees.fold<double>(0, (sum, emp) => sum + emp.salary);
    return totalSalary / employees.length;
  }
  
  /// Calculate average performance for employees
  static double _calculateAveragePerformance(List<DemoEmployee> employees) {
    if (employees.isEmpty) return 0.0;
    final totalPerformance = employees.fold<double>(0, (sum, emp) => sum + emp.performance);
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
  
  /// Get color based on performance level
  static Color _getPerformanceColor(double performance) {
    if (performance >= 0.9) {
      return Colors.green.shade600;
    } else if (performance >= 0.8) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }
  
  /// Get summary statistics for all departments
  static Map<String, dynamic> getDepartmentSummaryStats() {
    final allEmployees = DemoDataSource.employees;
    final departments = DemoDataSource.departments;
    
    return {
      'totalEmployees': allEmployees.length,
      'totalDepartments': departments.length,
      'avgDepartmentSize': (allEmployees.length / departments.length).toStringAsFixed(1),
      'totalSalaryBudget': allEmployees.fold<double>(0, (sum, emp) => sum + emp.salary),
      'avgPerformance': allEmployees.fold<double>(0, (sum, emp) => sum + emp.performance) / allEmployees.length,
    };
  }
}