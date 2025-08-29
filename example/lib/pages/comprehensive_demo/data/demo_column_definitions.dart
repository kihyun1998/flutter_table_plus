import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Column definitions for comprehensive table demo
class DemoColumnDefinitions {
  /// Get basic employee columns (Phase 1 - text only)
  static Map<String, TablePlusColumn> getBasicEmployeeColumns() {
    return {
      'name': TablePlusColumn(
        key: 'name',
        label: 'Name',
        width: 180,
        order: 0,
        alignment: Alignment.centerLeft,
        sortable: true,
        editable: false, // Name should not be editable
        tooltipFormatter: (rowData) {
          return '''Employee Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Name: ${rowData['name']}
🏢 Department: ${rowData['department']}
💼 Position: ${rowData['position']}
📧 Contact: ${rowData['email'] ?? 'N/A'}''';
        },
      ),
      'position': TablePlusColumn(
        key: 'position',
        label: 'Position',
        width: 200,
        order: 1,
        alignment: Alignment.centerLeft,
        sortable: true,
        editable: true, // Phase 3: Enable editing
      ),
      'department': TablePlusColumn(
        key: 'department',
        label: 'Department',
        width: 150,
        order: 2,
        alignment: Alignment.centerLeft,
        sortable: true,
        editable: true, // Phase 3: Enable editing
      ),
      'salary': TablePlusColumn(
        key: 'salary',
        label: 'Salary',
        width: 120,
        order: 3,
        alignment: Alignment.centerRight,
        sortable: true,
        editable: true, // Phase 4: Enable editing
        tooltipFormatter: (rowData) {
          final rawSalary = rowData['rawSalary'] ?? 0;
          final performance = rowData['rawPerformance'] ?? 0.0;
          final bonus = (rawSalary * performance * 0.1).round();
          final total = rawSalary + bonus;

          return '''Compensation Details:
💰 Base Salary: \$${rawSalary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}
🎯 Performance: ${(performance * 100).toStringAsFixed(1)}%
🏆 Est. Bonus: \$${bonus.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}
💸 Total Est.: \$${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}''';
        },
      ),
      'performance': TablePlusColumn(
        key: 'performance',
        label: 'Performance',
        width: 120,
        order: 4,
        alignment: Alignment.center,
        sortable: true,
        editable: true, // Phase 4: Enable editing
      ),
      'joinDate': TablePlusColumn(
        key: 'joinDate',
        label: 'Join Date',
        width: 120,
        order: 5,
        alignment: Alignment.center,
        sortable: true,
        editable: false,
        // Will add date formatting in Phase 2
      ),
      'skills': TablePlusColumn(
        key: 'skills',
        label: 'Skills',
        width: 200,
        order: 6,
        alignment: Alignment.centerLeft,
        sortable: false, // Lists are not sortable
        editable: false,
        tooltipFormatter: (rowData) {
          final skills = rowData['rawSkills'] as List<String>? ?? [];
          final skillCount = skills.length;
          final primarySkills = skills.take(3).join(', ');
          final additionalSkills =
              skillCount > 3 ? skills.skip(3).join(', ') : '';

          return '''Skills Profile:
🎯 Total Skills: $skillCount
⭐ Primary: $primarySkills${additionalSkills.isNotEmpty ? '\n🔧 Additional: $additionalSkills' : ''}
📊 Skill Level: ${skillCount >= 5 ? 'Expert' : skillCount >= 3 ? 'Advanced' : 'Intermediate'}''';
        },
        // Will add tags cell builder in Phase 8
      ),
    };
  }

  /// Helper method to format column titles with icons (for later phases)
  static String formatColumnTitle(String title, {IconData? icon}) {
    if (icon != null) {
      return title; // Icon will be added in cellBuilder later
    }
    return title;
  }

  /// Get column width constraints
  static double getMinColumnWidth(String columnKey) {
    switch (columnKey) {
      case 'name':
        return 120;
      case 'position':
        return 150;
      case 'department':
        return 100;
      case 'salary':
        return 80;
      case 'performance':
        return 100;
      case 'joinDate':
        return 100;
      case 'skills':
        return 150;
      default:
        return 80;
    }
  }

  /// Get default sort configuration
  static Map<String, dynamic> getDefaultSortConfig() {
    return {
      'column': 'name',
      'direction': SortDirection.ascending,
    };
  }

  /// Validate column key exists
  static bool isValidColumnKey(String key) {
    return getBasicEmployeeColumns().containsKey(key);
  }

  /// Get column display order
  static List<String> getColumnOrder() {
    final columns = getBasicEmployeeColumns().values.toList();
    columns.sort((a, b) => a.order.compareTo(b.order));
    return columns.map((c) => c.key).toList();
  }
}
