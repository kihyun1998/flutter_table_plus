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
          const TablePlusColumn(
            key: 'name',
            label: 'Full Name',
            order: 0,
            width: 150,
            minWidth: 120,
            sortable: true,
            editable: true,
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
        backgroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
        ),
        showVerticalDividers: showVerticalDividers,
        showHorizontalDividers: true,
        dividerColor: Colors.grey.shade300,
        dividerThickness: 1.0,
      ),
      scrollbarTheme: const TablePlusScrollbarTheme(
        hoverOnly: true,
        opacity: 0.8,
      ),
      selectionTheme: const TablePlusSelectionTheme(
        selectedRowColor: Color(0xFFE3F2FD),
        checkboxColor: Color(0xFF2196F3),
        checkboxSize: 18.0,
        rowHoverColor: Colors.red,
        rowSplashColor: Colors.green,
        rowHighlightColor: Colors.blue,
        selectedRowHoverColor: Colors.red,
        selectedRowSplashColor: Colors.green,
        selectedRowHighlightColor: Colors.blue,
        selectedRowTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF1565C0),
          fontWeight: FontWeight.w600,
        ),
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

  /// Check if at least one column is visible
  static bool hasVisibleColumns(Map<String, TablePlusColumn> columns) {
    return columns.values.any((col) => col.visible);
  }
}
