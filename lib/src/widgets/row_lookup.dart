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

  /// Derives the lookups from a snapshot of [data], [rowId] and
  /// [mergedGroups].
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

  /// Whether [rowId] over [data] still produces the ids this snapshot holds.
  ///
  /// **The invalidation guard for identity, and it compares answers rather than
  /// functions.** `data` and `mergedGroups` are watched by object identity, and
  /// `rowId` cannot be: it is required, so every call site writes an inline
  /// closure, and an inline closure is a new object on every build even when it
  /// captures nothing — watching *that* would rebuild both lookups on every
  /// build for every caller, and this is roughly a tenth of that rebuild while
  /// being complete rather than sampled.
  ///
  /// The numbers, with what produced them, because the two modes differ by
  /// about 3x and quoting one without saying which is how a wrong row got into
  /// `docs/map/territory/row-identity.md`'s own measurement table:
  ///
  /// * **this function, JIT (`flutter test`)** — 0.128% of a 16.7ms frame at
  ///   100 rows, 0.256% at 1,000, 2.968% at 10,000, summed over both widgets.
  /// * **the same shape, AOT (`dart compile exe`)** — 0.010% / 0.112% /
  ///   0.971%, against 10.0% at 10,000 for the rebuild it replaces.
  ///
  /// AOT is what a released app runs; JIT is what anyone re-measuring here
  /// will get.
  ///
  /// `utils/overflow_cache.dart` is the same shape already shipping here: it
  /// takes the `measure` function, never compares it, and keys on a derived
  /// value. #135. (That value was the `(text, width)` pair until #156 measured
  /// the pair to be a hand-written *subset* of what the answer depends on — the
  /// style and the ambient text scale were the two it omitted — and replaced it
  /// with the whole `TextMeasurement`. The property this cites is *key on
  /// derived values, never on a closure*, and that survived; which values it
  /// keyed on did not.)
  ///
  /// What it catches, beyond a swapped [rowId]: a `data` list **sorted in
  /// place** (the ids move), and one **shrunk in place** (the lengths differ).
  /// What it does not catch is an element replaced in place under the same id —
  /// the ids are unchanged, and what goes stale there is the index-keyed height
  /// cache, which is `rowMeasurementChanged`'s axis and not this one.
  bool idsMatch(List<T> data, String Function(T) rowId) {
    if (_ids.length != data.length) return false;
    for (int i = 0; i < data.length; i++) {
      if (_ids[i] != rowId(data[i])) return false;
    }
    return true;
  }

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
