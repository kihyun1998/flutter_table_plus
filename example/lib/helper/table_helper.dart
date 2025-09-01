import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/sample_data.dart' show SampleData;
import '../widgets/table_controls.dart' show SelectionDialog;

class TableHelper {
  /// Initialize columns with default order
  static Map<String, TablePlusColumn> initializeColumns() {
    return TableColumnsBuilder()
        .addColumn(
          'id',
          const TablePlusColumn(
            key: 'id',
            label: 'ID',
            order: 0,
            width: 60,
            minWidth: 50,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true,
            editable: false,
          ),
        )
        .addColumn(
          'name',
          TablePlusColumn(
            key: 'name',
            label: 'Full Name',
            order: 0,
            width: 150,
            minWidth: 120,
            sortable: true,
            editable: true,
            tooltipBuilder: (context, rowData) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${rowData['name']}'.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${rowData['name']}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${rowData['department']}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${rowData['email']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.cake_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${rowData['age']} years old',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (rowData['active'] as bool? ?? false)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (rowData['active'] as bool? ?? false)
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (rowData['active'] as bool? ?? false) ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: (rowData['active'] as bool? ?? false)
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .addColumn(
          'email',
          const TablePlusColumn(
            key: 'email',
            label: 'Email Address',
            order: 0,
            width: 200,
            minWidth: 150,
            sortable: true,
            editable: true,
          ),
        )
        .addColumn(
          'age',
          const TablePlusColumn(
            key: 'age',
            label: 'Age is Overflow column name',
            order: 0,
            width: 60,
            minWidth: 50,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true,
            editable: true,
          ),
        )
        .addColumn(
          'department',
          const TablePlusColumn(
            key: 'department',
            label: 'Department',
            order: 0,
            width: 120,
            minWidth: 100,
            sortable: true,
            editable: true,
          ),
        )
        .addColumn(
          'salary',
          TablePlusColumn(
            key: 'salary',
            label: 'Salary',
            order: 0,
            width: 100,
            minWidth: 80,
            textAlign: TextAlign.right,
            alignment: Alignment.centerRight,
            sortable: true,
            editable: true,
            cellBuilder: TableHelper._buildSalaryCell,
            tooltipBuilder: (context, rowData) {
              final salary = rowData['salary'] as int? ?? 0;
              final department = rowData['department'] as String? ?? 'Unknown';
              final yearlyTotal = salary * 12;
              final taxEstimate = (yearlyTotal * 0.25).round();
              final netAnnual = yearlyTotal - taxEstimate;
              final benefits = (salary * 0.3).round();

              return Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.attach_money, color: Colors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Salary Breakdown',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    department,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSalaryRow(context, 'Monthly Salary', '\$${_formatNumber(salary)}', Colors.blue),
                        _buildSalaryRow(context, 'Annual Gross', '\$${_formatNumber(yearlyTotal)}', Colors.green),
                        _buildSalaryRow(context, 'Est. Benefits', '\$${_formatNumber(benefits)}', Colors.orange),
                        _buildSalaryRow(context, 'Est. Tax (25%)', '\$${_formatNumber(taxEstimate)}', Colors.red),
                        const Divider(height: 20),
                        _buildSalaryRow(context, 'Net Annual', '\$${_formatNumber(netAnnual)}', Colors.purple, isBold: true),
                        const SizedBox(height: 16),
                        // Visual breakdown
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (netAnnual * 100 ~/ yearlyTotal),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (taxEstimate * 100 ~/ yearlyTotal),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.red),
                                ),
                              ),
                              Expanded(
                                flex: (benefits * 100 ~/ yearlyTotal),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Net Income • Taxes • Benefits',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .addColumn(
          'active',
          TablePlusColumn(
            key: 'active',
            label: 'Status',
            order: 0,
            width: 80,
            minWidth: 70,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            sortable: true,
            editable: true,
            cellBuilder: TableHelper._buildStatusCell,
            tooltipFormatter: (rowData) {
              final isActive = rowData['active'] as bool? ?? false;
              final name = rowData['name'] as String? ?? 'Unknown';
              final department = rowData['department'] as String? ?? 'Unknown';

              return '''Employee Status:
${isActive ? '✅ Active' : '❌ Inactive'}
👤 Employee: $name
🏢 Department: $department
📊 Status: ${isActive ? 'Currently working' : 'On leave or terminated'}''';
            },
          ),
        )
        .addColumn(
          'description',
          const TablePlusColumn(
            key: 'description',
            label: 'Description',
            order: 0,
            width: 250,
            minWidth: 200,
            sortable: true,
            editable: true,
          ),
        )
        .build();
  }

  /// Initialize sorted data with original data
  static List<Map<String, dynamic>> initializeSortedData() {
    return List.from(SampleData.employeeData);
  }

  /// Sort data based on column key and direction
  static void sortData(List<Map<String, dynamic>> data, String columnKey,
      SortDirection direction) {
    data.sort((a, b) {
      final aValue = a[columnKey];
      final bValue = b[columnKey];

      // Handle null values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return direction == SortDirection.ascending ? -1 : 1;
      if (bValue == null) return direction == SortDirection.ascending ? 1 : -1;

      int comparison;

      // Type-specific comparison
      if (aValue is int && bValue is int) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is double && bValue is double) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is bool && bValue is bool) {
        comparison = aValue == bValue ? 0 : (aValue ? 1 : -1);
      } else {
        // String comparison (default)
        comparison = aValue.toString().toLowerCase().compareTo(
              bValue.toString().toLowerCase(),
            );
      }

      // Reverse for descending
      return direction == SortDirection.ascending ? comparison : -comparison;
    });
  }

  /// Custom cell builder for salary
  static Widget _buildSalaryCell(
      BuildContext context, Map<String, dynamic> rowData) {
    final salary = rowData['salary'] as int?;
    return Text(
      salary != null
          ? '\$${salary.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}'
          : '',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.green,
      ),
    );
  }

  /// Custom cell builder for status
  static Widget _buildStatusCell(
      BuildContext context, Map<String, dynamic> rowData) {
    final isActive = rowData['active'] as bool? ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  /// Get current table theme based on settings
  static TablePlusTheme getCurrentTheme({
    required bool showVerticalDividers,
  }) {
    return TablePlusTheme(
      headerTheme: TablePlusHeaderTheme(
        height: 48,
        backgroundColor: Colors.blue.shade50,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF495057),
        ),
        showVerticalDividers: showVerticalDividers,
        showBottomDivider: true,
        dividerColor: Colors.grey.shade300,
        sortedColumnBackgroundColor: Colors.blue.shade100,
        sortedColumnTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1976D2),
        ),
        sortIcons: const SortIcons(
          ascending:
              Icon(Icons.arrow_upward, size: 14, color: Color(0xFF1976D2)),
          descending:
              Icon(Icons.arrow_downward, size: 14, color: Color(0xFF1976D2)),
          unsorted: Icon(Icons.unfold_more, size: 14, color: Colors.grey),
        ),
      ),
      bodyTheme: TablePlusBodyTheme(
        rowHeight: 56,
        alternateRowColor: null,
        backgroundColor: const Color.fromARGB(255, 200, 250, 255),
        textStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
        ),
        // Selection styling moved from selectionTheme
        selectedRowColor: Color(0xFFE3F2FD),
        selectedRowTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF1565C0),
          fontWeight: FontWeight.w600,
        ),
        showVerticalDividers: showVerticalDividers,
        showHorizontalDividers: true,
        dividerColor: Colors.grey.shade300,
        dividerThickness: 1.0,
        lastRowBorderBehavior: LastRowBorderBehavior.always,
        // Row interaction colors moved from selectionTheme
        hoverColor: Colors.red,
        splashColor: Colors.green,
        highlightColor: Colors.blue,
        selectedRowHoverColor: Colors.red,
        selectedRowSplashColor: Colors.green,
        selectedRowHighlightColor: Colors.blue,
      ),
      scrollbarTheme: const TablePlusScrollbarTheme(
        hoverOnly: true,
        opacity: 0.8,
      ),
      checkboxTheme: TablePlusCheckboxTheme(
        // Checkbox colors and styling
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blue.shade600;
          }
          return Colors.transparent;
        }),
        hoverColor: Colors.blue.shade100,
        focusColor: Colors.blue.shade200,
        side: BorderSide(
          color: Colors.purple.shade400,
          width: 2.0,
        ),
        size: 18.0,
        showCheckboxColumn: true,
        showSelectAllCheckbox: true,
        checkboxColumnWidth: 60.0,
      ),
      editableTheme: const TablePlusEditableTheme(
        editingCellColor: Color(0xFFFFFDE7),
        editingTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
          fontWeight: FontWeight.w500,
        ),
        editingBorderColor: Color(0xFF2196F3),
        editingBorderWidth: 2.0,
        editingBorderRadius: BorderRadius.all(Radius.circular(6.0)),
        textFieldPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        cursorColor: Color(0xFF2196F3),
        textAlignVertical: TextAlignVertical.center,
        focusedBorderColor: Color(0xFF1976D2),
        enabledBorderColor: Color(0xFFBBBBBB),
        fillColor: Color(0xFFFFFDE7),
        filled: true,
        isDense: true,
      ),
    );
  }

  /// Get selected employee names
  static List<String> getSelectedNames(
      List<Map<String, dynamic>> sortedData, Set<String> selectedRows) {
    return sortedData
        .where((row) => selectedRows.contains(row['id'].toString()))
        .map((row) => row['name'].toString())
        .toList();
  }

  /// Show selected employees dialog
  static void showSelectedEmployeesDialog(
      BuildContext context, int selectedCount, List<String> selectedNames) {
    SelectionDialog.show(
      context,
      selectedCount: selectedCount,
      selectedNames: selectedNames,
    );
  }

  /// Update column visibility
  static Map<String, TablePlusColumn> updateColumnVisibility(
      Map<String, TablePlusColumn> columns, String columnKey, bool visible) {
    final updatedColumns = Map<String, TablePlusColumn>.from(columns);
    final column = updatedColumns[columnKey];
    if (column != null) {
      updatedColumns[columnKey] = column.copyWith(visible: visible);
    }
    return updatedColumns;
  }

  /// Get visible column count
  static int getVisibleColumnCount(Map<String, TablePlusColumn> columns) {
    return columns.values.where((col) => col.visible).length;
  }

  /// Update all columns with new text overflow setting
  static Map<String, TablePlusColumn> updateColumnsTextOverflow(
      Map<String, TablePlusColumn> columns, TextOverflow textOverflow) {
    final updatedColumns = <String, TablePlusColumn>{};
    for (final entry in columns.entries) {
      updatedColumns[entry.key] = entry.value.copyWith(
        textOverflow: textOverflow,
      );
    }
    return updatedColumns;
  }

  /// Check if at least one column is visible
  static bool hasVisibleColumns(Map<String, TablePlusColumn> columns) {
    return columns.values.any((col) => col.visible);
  }

  /// Helper method to build salary breakdown rows for tooltip
  static Widget _buildSalaryRow(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to format numbers with commas
  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
