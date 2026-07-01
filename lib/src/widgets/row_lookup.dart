import '../models/merged_row_group.dart';

/// A pure, immutable view of "which row is where" for one snapshot of table
/// data.
///
/// Both [FlutterTablePlus] (to total up data height / row count) and
/// [TablePlusBody] (to render rows and answer the [RowLocator] port) need the
/// same two derived facts:
///
/// 1. `rowId → data index`, and
/// 2. `rowId → the [MergedRowGroup] that contains it`.
///
/// Before, each side rebuilt these with its own copy-pasted loop, so the same
/// fact lived in two places and could — in principle — drift. [RowLookup] is
/// the single home for that derivation: build it once from a data snapshot and
/// read the facts back. It deliberately does **not** own the consumer-specific
/// caches (the parent's scalar totals, the body's renderable-index list and
/// per-row height memoization) — those serve different consumers and stay with
/// them.
class RowLookup<T> {
  RowLookup._(this._ids, this._idToIndex, this._idToGroup);

  /// Derives the lookups from a snapshot of [data] and [mergedGroups].
  ///
  /// [rowId] extracts the stable id from a row. When ids collide, the last
  /// occurrence wins (mirroring the previous map-building behavior).
  factory RowLookup.build({
    required List<T> data,
    required List<MergedRowGroup<T>> mergedGroups,
    required String Function(T) rowId,
  }) {
    final ids = List<String>.generate(data.length, (i) => rowId(data[i]),
        growable: false);

    final idToIndex = <String, int>{};
    for (int i = 0; i < ids.length; i++) {
      idToIndex[ids[i]] = i;
    }

    final idToGroup = <String, MergedRowGroup<T>>{};
    for (final group in mergedGroups) {
      for (final rowKey in group.rowKeys) {
        idToGroup[rowKey] = group;
      }
    }

    return RowLookup._(ids, idToIndex, idToGroup);
  }

  final List<String> _ids;
  final Map<String, int> _idToIndex;
  final Map<String, MergedRowGroup<T>> _idToGroup;

  /// The number of rows in the snapshot.
  int get rowCount => _ids.length;

  /// The data index of the row with [rowId], or `null` if absent.
  int? indexOf(String rowId) => _idToIndex[rowId];

  /// The merged group containing [rowId], or `null` if the row is not grouped.
  MergedRowGroup<T>? groupOf(String rowId) => _idToGroup[rowId];

  /// The merged group at data [rowIndex], or `null` when the index is out of
  /// range or the row is not grouped.
  MergedRowGroup<T>? groupForRowIndex(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _ids.length) return null;
    return _idToGroup[_ids[rowIndex]];
  }
}
