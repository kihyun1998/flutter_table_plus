import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../demo_data/demo_data.dart';
import 'models/playground_settings.dart';
import 'playground_format.dart';

/// The columns the playground builds from its [PlaygroundSettings].
///
/// Free of `BuildContext` and of widget state: the `context`s below are handed
/// in by the cell builders the table calls, not the page's own.
Map<String, TablePlusColumn<Employee>> buildPlaygroundColumns(
  PlaygroundSettings settings,
) {
  final builder = TableColumnsBuilder<Employee>();

  final cellTooltip = settings.tooltipBehavior;
  final headerTooltip = settings.headerTooltipBehavior;
  final minW = settings.columnMinWidth;

  builder.addColumn(
    'avatar',
    TablePlusColumn<Employee>(
      key: 'avatar',
      label: '👤',
      order: 0,
      valueAccessor: (row) => row.avatar,
      width: 60,
      minWidth: minW,
      maxWidth: 80,
      sortable: false,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
    ),
  );

  builder.addColumn(
    'name',
    TablePlusColumn<Employee>(
      key: 'name',
      label: 'Name',
      order: 0,
      valueAccessor: (row) => row.name,
      width: 180,
      minWidth: minW,
      sortable: settings.sortingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
      tooltipBuilder: settings.showTooltipBuilder
          ? (context, employee) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${employee.position} - ${employee.department}'),
                  Text(
                    '\$${formatPlaygroundNumber(employee.salary)}',
                    style: TextStyle(color: Colors.green.shade300),
                  ),
                ],
              )
          : null,
    ),
  );

  builder.addColumn(
    'position',
    TablePlusColumn<Employee>(
      key: 'position',
      label: 'Position',
      order: 0,
      valueAccessor: (row) => row.position,
      width: 200,
      minWidth: minW,
      sortable: settings.sortingEnabled,
      editable: settings.editingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
    ),
  );

  builder.addColumn(
    'department',
    TablePlusColumn<Employee>(
      key: 'department',
      label: 'Department',
      order: 0,
      valueAccessor: (row) => row.department,
      width: 150,
      minWidth: minW,
      sortable: settings.sortingEnabled,
      editable: settings.editingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
    ),
  );

  builder.addColumn(
    'salary',
    TablePlusColumn<Employee>(
      key: 'salary',
      label: 'Salary',
      order: 0,
      valueAccessor: (row) => row.salary,
      width: 120,
      minWidth: minW,
      maxWidth: 150,
      sortable: settings.sortingEnabled,
      editable: settings.editingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
      statefulCellBuilder: (context, employee, isSelected, isDim) {
        return Center(
          child: Text(
            '\$${formatPlaygroundNumber(employee.salary)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : isDim
                      ? Colors.green.shade300
                      : Colors.green.shade700,
            ),
          ),
        );
      },
    ),
  );

  builder.addColumn(
    'performance',
    TablePlusColumn<Employee>(
      key: 'performance',
      label: 'Performance',
      order: 0,
      valueAccessor: (row) => row.performance,
      width: 130,
      minWidth: minW,
      maxWidth: 160,
      sortable: settings.sortingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
      statefulCellBuilder: (context, employee, isSelected, isDim) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDim
                  ? performanceColor(employee.performance)
                      .withValues(alpha: 0.5)
                  : performanceColor(employee.performance),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(employee.performance * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    ),
  );

  builder.addColumn(
    'email',
    TablePlusColumn<Employee>(
      key: 'email',
      label: 'Email',
      order: 0,
      valueAccessor: (row) => row.email,
      width: 220,
      minWidth: minW,
      sortable: settings.sortingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
      tooltipFormatter: settings.showTooltipFormatter
          ? (employee) => 'Send to: ${employee.email}'
          : null,
    ),
  );

  builder.addColumn(
    'phone',
    TablePlusColumn<Employee>(
      key: 'phone',
      label: 'Phone',
      order: 0,
      valueAccessor: (row) => row.phone,
      width: 130,
      minWidth: minW,
      maxWidth: 160,
      sortable: settings.sortingEnabled,
      tooltipBehavior: cellTooltip,
      headerTooltipBehavior: headerTooltip,
    ),
  );

  return builder.build();
}
