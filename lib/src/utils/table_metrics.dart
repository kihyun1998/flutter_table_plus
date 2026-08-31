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
/// A merged group contributes **the lowest data index any of its members
/// occupies**, which is the index this forward scan reaches it at: every member
/// is marked processed the first time the group is seen, so arriving here at
/// all means no member came earlier.
///
/// That is the same anchor [computeTableMetrics] has always used, and the two
/// used to disagree. This function anchored on `indexOf(rowKeys.first)`, so a
/// group whose first key was not its earliest data row rendered nothing while
/// the metrics counted it — and a group whose first key was **absent from
/// `data`** dropped every one of its members from the screen while they sat in
/// the list. It was a pure extraction of the body's loop and preserved that
/// behaviour deliberately, which is why the quirk outlived the extraction (#135).
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
      // `i` is the group's earliest present member: the `continue` above skips
      // anything already processed, and every member is processed together
      // below, so reaching a grouped row means no member of it came first.
      // No `rowKeys.first` lookup — a key absent from `data` used to make this
      // condition unsatisfiable and take the whole group off the screen.
      renderable.add(i);
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
