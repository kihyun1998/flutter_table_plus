import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class EmployeeTable extends StatelessWidget {
  const EmployeeTable({
    super.key,
    required this.data,
    required this.isSelectable,
    required this.selectedRows,
    required this.onRowSelectionChanged,
    required this.onSelectAll,
  });

  final List<Map<String, dynamic>> data;
  final bool isSelectable;
  final Set<String> selectedRows;
  final void Function(String rowId, bool isSelected) onRowSelectionChanged;
  final void Function(bool selectAll) onSelectAll;

  /// Define table columns using TableColumnsBuilder
  Map<String, TablePlusColumn> get _columns {
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
          ),
        )
        .addColumn(
          'age',
          const TablePlusColumn(
            key: 'age',
            label: 'Age',
            order: 0,
            width: 60,
            minWidth: 50,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
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
            cellBuilder: _buildSalaryCell,
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
            cellBuilder: _buildStatusCell,
          ),
        )
        .build();
  }

  /// Custom cell builder for salary
  Widget _buildSalaryCell(BuildContext context, Map<String, dynamic> rowData) {
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
  Widget _buildStatusCell(BuildContext context, Map<String, dynamic> rowData) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: FlutterTablePlus(
          columns: _columns,
          data: data,
          isSelectable: isSelectable,
          selectedRows: selectedRows,
          onRowSelectionChanged: onRowSelectionChanged,
          onSelectAll: onSelectAll,
          theme: const TablePlusTheme(
            headerTheme: TablePlusHeaderTheme(
              height: 48,
              backgroundColor: Color(0xFFF8F9FA),
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF495057),
              ),
            ),
            bodyTheme: TablePlusBodyTheme(
              rowHeight: 56,
              alternateRowColor: Color(0xFFFAFAFA),
              textStyle: TextStyle(
                fontSize: 14,
                color: Color(0xFF212529),
              ),
            ),
            scrollbarTheme: TablePlusScrollbarTheme(
              hoverOnly: true,
              opacity: 0.8,
            ),
            selectionTheme: TablePlusSelectionTheme(
              selectedRowColor: Color(0xFFE3F2FD),
              checkboxColor: Color(0xFF2196F3),
              checkboxSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
