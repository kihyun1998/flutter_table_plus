import 'package:flutter/material.dart';

/// Configuration for how a specific cell should be merged within a group.
class MergeCellConfig {
  /// Creates a [MergeCellConfig] with the specified settings.
  const MergeCellConfig({
    required this.shouldMerge,
    this.spanningRowIndex = 0,
    this.mergedContent,
    this.isEditable = false,
  });

  /// Whether this column should be merged for this group.
  /// If false, each row in the group will show its individual cell content.
  final bool shouldMerge;

  /// The index (0-based) of the row within the group where the merged cell content should be displayed.
  /// Other rows in the group will have empty cells for this column.
  /// Defaults to 0 (first row).
  final int spanningRowIndex;

  /// Custom widget content to display in the merged cell.
  /// If null, the content from the row at [spanningRowIndex] will be used.
  final Widget? mergedContent;

  /// Whether this merged cell should be editable.
  /// Only applies to merged cells without custom [mergedContent].
  /// If [mergedContent] is provided, this field is ignored.
  final bool isEditable;
}

/// Represents a group of rows that should be merged together for specific columns.
class MergedRowGroup<T> {
  /// Creates a [MergedRowGroup] with the specified configuration.
  const MergedRowGroup({
    required this.groupId,
    required this.rowKeys,
    required this.mergeConfig,
    this.isExpandable = false,
    this.isExpanded = false,
    this.summaryBuilder,
  });

  /// Unique identifier for this merge group.
  /// Used for selection and editing operations.
  final String groupId;

  /// List of row keys that belong to this group.
  /// These keys refer to the unique identifiers of rows in the data list.
  final List<String> rowKeys;

  /// Configuration for how each column should be merged within this group.
  /// Key: column key, Value: merge configuration for that column.
  final Map<String, MergeCellConfig> mergeConfig;

  /// Whether this merge group supports expandable summary row functionality.
  /// When true, an expand/collapse icon will be shown and summary row can be displayed.
  final bool isExpandable;

  /// Whether the summary row is currently expanded.
  /// This state should be managed by the parent widget.
  final bool isExpanded;

  /// Builder function to create summary content for a specific column.
  /// Returns a Widget to display in the summary row cell for the given column key.
  /// If null or returns null for a column, the summary cell will be empty.
  final Widget? Function(String columnKey)? summaryBuilder;

  /// Returns the number of rows in this group.
  int get rowCount => rowKeys.length;

  /// Returns true if the specified column should be merged for this group.
  bool shouldMergeColumn(String columnKey) {
    return mergeConfig[columnKey]?.shouldMerge ?? false;
  }

  /// Returns the row index where the merged content should be displayed for the specified column.
  int getSpanningRowIndex(String columnKey) {
    return mergeConfig[columnKey]?.spanningRowIndex ?? 0;
  }

  /// Returns the row key for the spanning row of the specified column.
  String getSpanningRowKey(String columnKey) {
    final spanningRowIndex = getSpanningRowIndex(columnKey);
    return rowKeys[spanningRowIndex];
  }

  /// Returns the row data for a specific row key from the provided data list.
  T? getRowData(
      List<T> allData, String rowKey, String Function(T) rowId) {
    try {
      return allData.firstWhere((row) => rowId(row) == rowKey);
    } catch (e) {
      return null;
    }
  }

  /// Returns all row data for this group from the provided data list.
  List<T> getAllRowData(
      List<T> allData, String Function(T) rowId) {
    return rowKeys
        .map((rowKey) => getRowData(allData, rowKey, rowId))
        .where((data) => data != null)
        .cast<T>()
        .toList();
  }

  /// Returns custom merged content for the specified column, if any.
  Widget? getMergedContent(String columnKey) {
    return mergeConfig[columnKey]?.mergedContent;
  }

  /// Returns true if the merged cell for the specified column is editable.
  /// Only merged cells without custom content can be editable.
  bool isMergedCellEditable(String columnKey) {
    final config = mergeConfig[columnKey];
    if (config == null || !config.shouldMerge || config.mergedContent != null) {
      return false;
    }
    return config.isEditable;
  }

  /// Returns the effective row count including summary row if expanded.
  int get effectiveRowCount => rowCount + (isExpandable && isExpanded ? 1 : 0);
}
