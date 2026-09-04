import '../models/merged_row_group.dart';
import 'row_measurement.dart';

/// What a widget update invalidates about the row-derived caches.
enum RowCacheInvalidation {
  /// Nothing this build changed can have moved any cached answer.
  none,

  /// Which rows exist, which index maps to which row, and which of them a
  /// group swallows are all unchanged — only how tall a row is has moved.
  ///
  /// Answers about **identity** survive: `RowLookup`, and the renderable-index
  /// list derived from it. Answers **accumulated from heights** do not.
  measurementOnly,

  /// The snapshot itself moved. Everything derived from it is stale.
  structural,
}

/// Classify what an update to a table widget invalidates.
///
/// **Two widgets cache row-derived state and both must answer this question the
/// same way.** `FlutterTablePlusState` holds the total that decides whether a
/// vertical scrollbar appears; `TablePlusBodyState` holds the per-row heights
/// that feed the rendered extents *and* the `RowGeometry` every drag hit-test
/// is answered from. They keep different caches and drop different things — but
/// *when* to drop them is one rule, and this is where it lives.
///
/// **The history is why it is a function rather than a convention.** The
/// *inputs* to the measurement half were hand-written in two places and drifted
/// twice — `calculateRowHeight` was in the parent's list and not the body's
/// (#120), `theme.rowHeight` was in neither (#128) — which is what
/// [rowMeasurementChanged] was extracted to fix. The **response** to that
/// predicate stayed copied, and drifted the same way: the body split its update
/// into structural and measurement-only branches and reasoned, in a comment,
/// that identity answers survive a measurement change; the parent kept one
/// branch and rebuilt its `RowLookup` on every `scale` change, for answers no
/// scale can move. That asymmetry was visible inside #120's own issue body,
/// which quotes both files side by side, and it survived #120, #128, #132 and
/// #135. Unifying the predicate and leaving its consumers copied is half a
/// repair; this is the other half.
///
/// **`structural` dominates.** A build can change the snapshot *and* the
/// measurement at once, and then the lookup is stale no matter what the height
/// inputs say. So [idsStillMatch] is consulted before a [measurementOnly] can
/// be returned, and that is a real cost the parent did not pay before: its
/// `||` chain short-circuited the walk away whenever the measurement predicate
/// had already fired. Measured 2026-09-04 — `idsMatch` is **13-15%** of
/// `RowLookup.build` at 1k/10k/50k rows, so trading the walk for the rebuild
/// keeps **85%** of it. Skipping the walk instead would return
/// [measurementOnly] for a list sorted or shrunk in place, which is a wrong
/// answer rather than a cheap one.
///
/// **[idsStillMatch] is a callback so the short-circuit survives.** It walks
/// every row, and the two `identical` checks above it are free; hoisting it to
/// an argument would run it on every build including the ones where the
/// snapshot has visibly moved. `RowLookup.idsMatch` is the intended
/// implementation — identity is watched by *answers* rather than by the
/// extractor's object identity, because `rowId` is required and so every caller
/// writes an inline closure (#135).
///
/// Adding a new measurement input means editing [rowMeasurementChanged], not
/// this function; adding a new *structural* input means editing this one and
/// adding a case to `test/row_cache_invalidation_test.dart` that changes only
/// that input.
RowCacheInvalidation classifyRowCacheInvalidation<T>({
  required List<T> oldData,
  required List<T> newData,
  required List<MergedRowGroup<T>> oldMergedGroups,
  required List<MergedRowGroup<T>> newMergedGroups,
  required double? Function(int index, T row)? oldCalculateRowHeight,
  required double? Function(int index, T row)? newCalculateRowHeight,
  required double oldScale,
  required double newScale,
  required double oldRowHeight,
  required double newRowHeight,
  required bool Function() idsStillMatch,
}) {
  // Free, and they settle the common case: a caller passing a new list.
  if (!identical(oldData, newData) ||
      !identical(oldMergedGroups, newMergedGroups)) {
    return RowCacheInvalidation.structural;
  }

  // Three comparisons, and the single home for which inputs a measured height
  // is computed from.
  final measurementMoved = rowMeasurementChanged<T>(
    oldCalculateRowHeight: oldCalculateRowHeight,
    newCalculateRowHeight: newCalculateRowHeight,
    oldScale: oldScale,
    newScale: newScale,
    oldRowHeight: oldRowHeight,
    newRowHeight: newRowHeight,
  );

  // O(rows), and last for that reason. It cannot be skipped when the
  // measurement moved: `structural` dominates, and a list sorted in place under
  // an unchanged `data` identity is exactly the case that would otherwise be
  // reported as measurement-only.
  if (!idsStillMatch()) {
    return RowCacheInvalidation.structural;
  }

  return measurementMoved
      ? RowCacheInvalidation.measurementOnly
      : RowCacheInvalidation.none;
}
