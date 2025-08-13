import 'package:flutter/material.dart';

/// Configuration for how a specific cell should be merged within a group.
class MergeCellConfig {
  /// Creates a [MergeCellConfig] with the specified settings.
  const MergeCellConfig({
    required this.shouldMerge,
    this.spanningRowIndex = 0,
    this.mergedContent,
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
}

/// Represents a group of rows that should be merged together for specific columns.
class MergedRowGroup {
  /// Creates a [MergedRowGroup] with the specified configuration.
  const MergedRowGroup({
    required this.groupId,
    required this.originalIndices,
    required this.mergeConfig,
  });

  /// Unique identifier for this merge group.
  /// Used for selection and editing operations.
  final String groupId;

  /// List of original data indices that belong to this group.
  /// These indices refer to positions in the original data list.
  final List<int> originalIndices;

  /// Configuration for how each column should be merged within this group.
  /// Key: column key, Value: merge configuration for that column.
  final Map<String, MergeCellConfig> mergeConfig;

  /// Returns the number of rows in this group.
  int get rowCount => originalIndices.length;

  /// Returns true if the specified column should be merged for this group.
  bool shouldMergeColumn(String columnKey) {
    return mergeConfig[columnKey]?.shouldMerge ?? false;
  }

  /// Returns the row index where the merged content should be displayed for the specified column.
  int getSpanningRowIndex(String columnKey) {
    return mergeConfig[columnKey]?.spanningRowIndex ?? 0;
  }

  /// Returns custom merged content for the specified column, if any.
  Widget? getMergedContent(String columnKey) {
    return mergeConfig[columnKey]?.mergedContent;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MergedRowGroup &&
        other.groupId == groupId &&
        other.originalIndices.length == originalIndices.length &&
        other.originalIndices.every((index) => originalIndices.contains(index));
  }

  @override
  int get hashCode => Object.hash(groupId, originalIndices);
}