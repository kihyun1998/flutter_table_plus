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
        tooltipBuilder: (context, rowData) {
          final performance = rowData['rawPerformance'] ?? 0.0;
          final experienceYears = (rowData['rawSalary'] as int? ?? 50000) ~/ 10000; // Rough estimate

          return Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with avatar and name
                    Row(
                      children: [
                        Hero(
                          tag: 'avatar_${rowData['name']}',
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: _getAvatarColor(rowData['department'] ?? ''),
                            child: Text(
                              '${rowData['name']}'.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rowData['name']}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${rowData['position']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Performance indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPerformanceColor(performance).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getPerformanceColor(performance), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(_getPerformanceIcon(performance), 
                               color: _getPerformanceColor(performance), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Performance Score',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${(performance * 100).toInt()}% (${_getPerformanceLabel(performance)})',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getPerformanceColor(performance),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(context, Icons.business_center, 
                                     '${rowData['department']}', 'Department'),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildStatItem(context, Icons.timeline, 
                                     '${experienceYears}Y', 'Experience'),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildStatItem(context, Icons.email_outlined, 
                                     'Contact', 'Available'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
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

  // Helper methods for tooltipBuilder examples

  /// Get avatar color based on department
  static Color _getAvatarColor(String department) {
    switch (department.toLowerCase()) {
      case 'engineering':
        return Colors.blue;
      case 'marketing':
        return Colors.orange;
      case 'sales':
        return Colors.green;
      case 'hr':
        return Colors.purple;
      case 'finance':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Get performance color based on score
  static Color _getPerformanceColor(double performance) {
    if (performance >= 0.8) return Colors.green;
    if (performance >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// Get performance icon based on score
  static IconData _getPerformanceIcon(double performance) {
    if (performance >= 0.8) return Icons.trending_up;
    if (performance >= 0.6) return Icons.trending_flat;
    return Icons.trending_down;
  }

  /// Get performance label based on score
  static String _getPerformanceLabel(double performance) {
    if (performance >= 0.9) return 'Excellent';
    if (performance >= 0.8) return 'Great';
    if (performance >= 0.7) return 'Good';
    if (performance >= 0.6) return 'Average';
    return 'Needs Improvement';
  }

  /// Build stat item for tooltip
  static Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
