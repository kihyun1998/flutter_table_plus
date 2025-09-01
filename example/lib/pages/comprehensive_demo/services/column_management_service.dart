import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../data/demo_column_definitions.dart';

/// Static service for managing table column operations
///
/// This service provides static methods for:
/// - Column initialization and configuration
/// - Column reordering with safety checks
/// - Column visibility management
/// - Column validation and error handling
class ColumnManagementService {
  // Private constructor to prevent instantiation
  ColumnManagementService._();

  /// Initialize default columns configuration
  static Map<String, TablePlusColumn> initializeColumns() {
    return DemoColumnDefinitions.getBasicEmployeeColumns();
  }

  /// Safely reorder columns using TableColumnsBuilder pattern
  static Map<String, TablePlusColumn> reorderColumns(
    Map<String, TablePlusColumn> currentColumns,
    int oldIndex,
    int newIndex,
  ) {
    // Get visible columns sorted by order
    final visibleColumns = currentColumns.values
        .where((col) => col.visible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Boundary checks to prevent runtime errors
    if (oldIndex < 0 ||
        oldIndex >= visibleColumns.length ||
        newIndex < 0 ||
        newIndex >= visibleColumns.length) {
      // Return original columns if indices are invalid
      return currentColumns;
    }

    // Get the column being moved
    final movingColumn = visibleColumns[oldIndex];

    // Create new builder with all existing columns
    final builder = TableColumnsBuilder();

    // Add all columns in their current order
    for (final column in currentColumns.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order))) {
      builder.addColumn(column.key, column);
    }

    // Use builder's reorderColumn method to handle the complex logic
    final targetOrder = newIndex + 1; // Convert to 1-based order
    builder.reorderColumn(movingColumn.key, targetOrder);

    return builder.build();
  }

  /// Update column visibility
  static Map<String, TablePlusColumn> updateColumnVisibility(
    Map<String, TablePlusColumn> currentColumns,
    String columnKey,
    bool visible,
  ) {
    final column = currentColumns[columnKey];
    if (column == null) {
      return currentColumns; // Column not found, return unchanged
    }

    final updatedColumns = Map<String, TablePlusColumn>.from(currentColumns);
    updatedColumns[columnKey] = column.copyWith(visible: visible);

    return updatedColumns;
  }

  /// Get visible columns count
  static int getVisibleColumnCount(Map<String, TablePlusColumn> columns) {
    return columns.values.where((col) => col.visible).length;
  }

  /// Get columns sorted by display order
  static List<TablePlusColumn> getColumnsByOrder(
    Map<String, TablePlusColumn> columns, {
    bool visibleOnly = false,
  }) {
    var columnsList = columns.values.toList();

    if (visibleOnly) {
      columnsList = columnsList.where((col) => col.visible).toList();
    }

    columnsList.sort((a, b) => a.order.compareTo(b.order));
    return columnsList;
  }

  /// Validate column configuration
  static Map<String, dynamic> validateColumnConfiguration(
    Map<String, TablePlusColumn> columns,
  ) {
    final issues = <String>[];

    // Check for duplicate orders
    final orders = <int>[];
    for (final column in columns.values) {
      if (orders.contains(column.order)) {
        issues.add('Duplicate order found: ${column.order}');
      }
      orders.add(column.order);
    }

    // Check for missing essential columns
    final requiredColumns = ['id', 'name'];
    for (final requiredColumn in requiredColumns) {
      if (!columns.containsKey(requiredColumn)) {
        issues.add('Missing required column: $requiredColumn');
      }
    }

    // Check for at least one visible column
    final visibleCount = getVisibleColumnCount(columns);
    if (visibleCount == 0) {
      issues.add('At least one column must be visible');
    }

    return {
      'valid': issues.isEmpty,
      'issues': issues,
      'visibleCount': visibleCount,
      'totalCount': columns.length,
    };
  }

  /// Reset columns to default configuration
  static Map<String, TablePlusColumn> resetToDefault() {
    return initializeColumns();
  }

  /// Get column by key with null safety
  static TablePlusColumn? getColumn(
    Map<String, TablePlusColumn> columns,
    String columnKey,
  ) {
    return columns[columnKey];
  }

  /// Update multiple columns at once
  static Map<String, TablePlusColumn> updateMultipleColumns(
    Map<String, TablePlusColumn> currentColumns,
    Map<String, TablePlusColumn> updates,
  ) {
    final updatedColumns = Map<String, TablePlusColumn>.from(currentColumns);

    for (final entry in updates.entries) {
      if (currentColumns.containsKey(entry.key)) {
        updatedColumns[entry.key] = entry.value;
      }
    }

    return updatedColumns;
  }

  /// Get columns summary for debugging/logging
  static Map<String, dynamic> getColumnsSummary(
    Map<String, TablePlusColumn> columns,
  ) {
    final visibleColumns = getColumnsByOrder(columns, visibleOnly: true);
    final hiddenColumns = columns.values.where((col) => !col.visible).toList();

    return {
      'totalColumns': columns.length,
      'visibleColumns': visibleColumns.length,
      'hiddenColumns': hiddenColumns.length,
      'visibleColumnKeys': visibleColumns.map((col) => col.key).toList(),
      'hiddenColumnKeys': hiddenColumns.map((col) => col.key).toList(),
      'columnOrders': Map.fromEntries(
          columns.entries.map((e) => MapEntry(e.key, e.value.order))),
    };
  }

  /// Create a new column with safe order assignment
  static TablePlusColumn createColumn({
    required String key,
    required String label,
    bool sortable = true,
    bool visible = true,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    double? width,
    String Function(dynamic)? tooltipFormatter,
    Widget Function(BuildContext, Map<String, dynamic>)? cellBuilder,
  }) {
    return TablePlusColumn(
      key: key,
      label: label,
      order: 0, // Will be set properly when added to builder
      sortable: sortable,
      visible: visible,
      textOverflow: textOverflow,
      width: width ?? 100.0,
      tooltipFormatter: tooltipFormatter,
      cellBuilder: cellBuilder,
    );
  }

  /// Add new column to existing columns safely
  static Map<String, TablePlusColumn> addColumn(
    Map<String, TablePlusColumn> currentColumns,
    TablePlusColumn newColumn, {
    int? atOrder,
  }) {
    final builder = TableColumnsBuilder();

    // Add all existing columns first
    for (final column in getColumnsByOrder(currentColumns)) {
      builder.addColumn(column.key, column);
    }

    // Add new column
    builder.addColumn(newColumn.key, newColumn);

    // If specific order is requested, reorder to that position
    if (atOrder != null && atOrder > 0) {
      builder.reorderColumn(newColumn.key, atOrder);
    }

    return builder.build();
  }

  /// Remove column from configuration
  static Map<String, TablePlusColumn> removeColumn(
    Map<String, TablePlusColumn> currentColumns,
    String columnKey,
  ) {
    final updatedColumns = Map<String, TablePlusColumn>.from(currentColumns);
    updatedColumns.remove(columnKey);
    return updatedColumns;
  }
}
