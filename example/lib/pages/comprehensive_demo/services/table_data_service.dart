import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/demo_data_formatters.dart';
import '../data/demo_data_source.dart';

/// Static service for managing table data operations
///
/// This service provides static methods for:
/// - Data initialization and formatting
/// - Sorting operations
/// - Cell editing and data updates
/// - Data parsing and validation
class TableDataService {
  // Private constructor to prevent instantiation
  TableDataService._();

  /// Initialize and format employee data for display
  static List<Map<String, dynamic>> initializeData() {
    return DemoDataSource.employeeTableData.map((employee) {
      return {
        ...employee,
        // Store raw data for tooltipFormatter and sorting
        'rawSalary': employee['salary'],
        'rawPerformance': employee['performance'],
        'rawSkills': employee['skills'],
        // Format data for better display
        'salary': DemoDataFormatters.formatCurrency(
            employee['salary']?.toDouble() ?? 0.0),
        'performance': DemoDataFormatters.formatPercentage(
            employee['performance']?.toDouble() ?? 0.0),
        'joinDate': DemoDataFormatters.formatDate(
            employee['joinDate'] ?? DateTime.now()),
        'skills': DemoDataFormatters.formatSkills(
            List<String>.from(employee['skills'] ?? [])),
      };
    }).toList();
  }

  /// Get default sort configuration
  static Map<String, dynamic> getDefaultSortConfig() {
    return {
      'column': 'name',
      'direction': SortDirection.ascending,
    };
  }

  /// Sort data by column with proper handling of formatted values
  static void sortData(
    List<Map<String, dynamic>> data,
    String columnKey,
    SortDirection direction,
  ) {
    if (direction == SortDirection.none) return;

    data.sort((a, b) {
      final aValue = a[columnKey];
      final bValue = b[columnKey];

      // Handle null values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      int comparison = 0;

      // Special handling for formatted columns
      switch (columnKey) {
        case 'salary':
          final aNum = extractSalaryNumber(aValue.toString());
          final bNum = extractSalaryNumber(bValue.toString());
          comparison = aNum.compareTo(bNum);
          break;
        case 'performance':
          final aNum = extractPercentageNumber(aValue.toString());
          final bNum = extractPercentageNumber(bValue.toString());
          comparison = aNum.compareTo(bNum);
          break;
        case 'joinDate':
          // For formatted dates, use original DateTime for comparison
          final aEmployee =
              DemoDataSource.employees.firstWhere((e) => e.id == a['id']);
          final bEmployee =
              DemoDataSource.employees.firstWhere((e) => e.id == b['id']);
          comparison = aEmployee.joinDate.compareTo(bEmployee.joinDate);
          break;
        case 'skills':
          // For skills, compare by the number of skills
          final aSkills = DemoDataSource.employees
              .firstWhere((e) => e.id == a['id'])
              .skills;
          final bSkills = DemoDataSource.employees
              .firstWhere((e) => e.id == b['id'])
              .skills;
          comparison = aSkills.length.compareTo(bSkills.length);
          break;
        default:
          if (aValue is String && bValue is String) {
            comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
          } else {
            comparison = aValue.toString().compareTo(bValue.toString());
          }
      }

      // Apply sort direction
      return direction == SortDirection.ascending ? comparison : -comparison;
    });
  }

  /// Update cell data with proper validation and formatting
  static Map<String, dynamic> updateCellData(
    List<Map<String, dynamic>> data,
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    if (rowIndex < 0 || rowIndex >= data.length) {
      return {'success': false, 'error': 'Invalid row index'};
    }

    // Update the display data
    data[rowIndex][columnKey] = newValue;

    // Also update the original data source for consistency
    final rowId = data[rowIndex]['id'];
    final employeeIndex =
        DemoDataSource.employees.indexWhere((e) => e.id == rowId);

    if (employeeIndex != -1) {
      final originalEmployee = DemoDataSource.employees[employeeIndex];

      // Handle different column types
      dynamic updatedValue = newValue;
      if (columnKey == 'salary') {
        updatedValue = parseCurrencyValue(newValue.toString());
      } else if (columnKey == 'performance') {
        updatedValue = parsePerformanceValue(newValue.toString());
      }

      DemoDataSource.employees[employeeIndex] = originalEmployee.copyWith(
        position:
            columnKey == 'position' ? newValue : originalEmployee.position,
        department:
            columnKey == 'department' ? newValue : originalEmployee.department,
        salary: columnKey == 'salary' ? updatedValue : originalEmployee.salary,
        performance: columnKey == 'performance'
            ? updatedValue
            : originalEmployee.performance,
      );

      // Re-format the display data after updating the source
      if (columnKey == 'salary') {
        data[rowIndex][columnKey] =
            DemoDataFormatters.formatCurrency(updatedValue);
      } else if (columnKey == 'performance') {
        data[rowIndex][columnKey] =
            DemoDataFormatters.formatPercentage(updatedValue);
      }

      return {
        'success': true,
        'rowId': rowId,
        'updatedValue': columnKey == 'salary' || columnKey == 'performance'
            ? data[rowIndex][columnKey]
            : newValue
      };
    }

    return {'success': false, 'error': 'Employee not found'};
  }

  /// Extract numeric value from formatted currency string
  static double extractSalaryNumber(String formattedValue) {
    final numericString = formattedValue.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Extract numeric value from percentage string
  static double extractPercentageNumber(String formattedValue) {
    final numericString = formattedValue.replaceAll('%', '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Parse currency value from string (removes $ and commas)
  static double parseCurrencyValue(String value) {
    final numericString = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Parse performance value from string (removes % and converts to decimal)
  static double parsePerformanceValue(String value) {
    final numericString = value.replaceAll('%', '');
    final percentage = double.tryParse(numericString) ?? 0.0;
    return percentage / 100.0; // Convert percentage to decimal
  }

  /// Filter data based on search criteria
  static List<Map<String, dynamic>> filterData(
    List<Map<String, dynamic>> originalData,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) {
      return List<Map<String, dynamic>>.from(originalData);
    }

    return originalData.where((row) {
      return row.values.any((value) =>
          value.toString().toLowerCase().contains(searchTerm.toLowerCase()));
    }).toList();
  }

  /// Validate cell input based on column type
  static Map<String, dynamic> validateCellInput(
      String columnKey, String input) {
    switch (columnKey) {
      case 'salary':
        final numericValue = parseCurrencyValue(input);
        if (numericValue < 0) {
          return {'valid': false, 'error': 'Salary cannot be negative'};
        }
        if (numericValue > 1000000) {
          return {'valid': false, 'error': 'Salary seems too high'};
        }
        return {'valid': true, 'value': numericValue};

      case 'performance':
        final percentageValue = parsePerformanceValue(input);
        if (percentageValue < 0 || percentageValue > 100) {
          return {
            'valid': false,
            'error': 'Performance must be between 0-100%'
          };
        }
        return {'valid': true, 'value': percentageValue / 100};

      case 'age':
        final age = int.tryParse(input);
        if (age == null) {
          return {'valid': false, 'error': 'Age must be a number'};
        }
        if (age < 18 || age > 100) {
          return {'valid': false, 'error': 'Age must be between 18-100'};
        }
        return {'valid': true, 'value': age};

      default:
        if (input.trim().isEmpty) {
          return {'valid': false, 'error': 'Field cannot be empty'};
        }
        return {'valid': true, 'value': input.trim()};
    }
  }
}
