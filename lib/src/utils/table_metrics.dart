import '../models/merged_row_group.dart';
import '../widgets/row_lookup.dart';

/// Aggregate vertical metrics for the whole table.
typedef TableMetrics = ({double totalHeight, int totalCount});

/// Total scrollable height and rendered row count (merged groups count as one).
///
/// Pure extraction of the parent's single-pass metrics loop. Heights are
/// injected — [rowHeightOf] for an ungrouped data row, [mergedGroupHeightOf] for
/// a group — so the caller keeps ownership of scale / dynamic-height concerns.
///
/// A group is counted once, at the first of its member rows encountered in data
/// order; its member indices are then skipped.
TableMetrics computeTableMetrics<T>({
  required List<T> data,
  required RowLookup<T> lookup,
  required double Function(int index) rowHeightOf,
  required double Function(MergedRowGroup<T> group) mergedGroupHeightOf,
}) {
  double totalHeight = 0;
  int totalCount = 0;
  final processed = <int>{};

  for (int i = 0; i < data.length; i++) {
    if (processed.contains(i)) continue;

    final group = lookup.groupForRowIndex(i);
    if (group != null) {
      totalHeight += mergedGroupHeightOf(group);
      totalCount++;
      for (final rowKey in group.rowKeys) {
        final idx = lookup.indexOf(rowKey);
        if (idx != null) processed.add(idx);
      }
    } else {
      totalHeight += rowHeightOf(i);
      totalCount++;
      processed.add(i);
    }
  }

  return (totalHeight: totalHeight, totalCount: totalCount);
}

/// The data indices that actually render, one entry per render row, or `null`
/// when there are no merged groups (the body then renders raw indices).
///
/// Pure extraction of the body's renderable-index loop. A merged group
/// contributes the index of `rowKeys.first`, and only when that index is the
/// one currently being visited — matching the existing behavior exactly,
/// including its quirk for out-of-order `rowKeys` (where a group whose first key
/// is not its earliest data row is skipped rather than rendered).
List<int>? computeRenderableIndices<T>({
  required List<T> data,
  required RowLookup<T> lookup,
  required String Function(T) rowId,
  required bool hasMergedGroups,
}) {
  if (!hasMergedGroups) return null;

  final renderable = <int>[];
  final processed = <int>{};

  for (int i = 0; i < data.length; i++) {
    if (processed.contains(i)) continue;

    final group = lookup.groupOf(rowId(data[i]));
    if (group != null) {
      final firstRowIndex = lookup.indexOf(group.rowKeys.first);
      if (firstRowIndex == i) renderable.add(i);
      for (final gRowKey in group.rowKeys) {
        final idx = lookup.indexOf(gRowKey);
        if (idx != null) processed.add(idx);
      }
    } else {
      renderable.add(i);
      processed.add(i);
    }
  }

  return renderable;
}
