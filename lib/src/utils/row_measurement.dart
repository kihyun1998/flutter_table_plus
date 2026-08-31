/// Whether anything a measured row height is computed from has changed.
///
/// Two widgets cache row heights and both must drop their caches on the same
/// events: `FlutterTablePlusState`, whose total feeds `needsVerticalScroll` and
/// the last row's border, and `TablePlusBodyState`, whose heights feed the
/// rendered extents *and* the `RowGeometry` snapshot every drag hit-test is
/// answered from.
///
/// They used to hold that rule as two hand-written conditions, and the two
/// drifted twice:
///
/// * **#120** — `calculateRowHeight` was in the parent's list and not the
///   body's, so a new height function over the same list changed nothing on
///   screen.
/// * **#128** — `theme.rowHeight` was in neither, so a caller changing row
///   height through the theme kept a hit-test geometry describing the previous
///   height, and the parent kept a total that decides whether a vertical
///   scrollbar appears at all.
///
/// **This is one list, not a derivation, and the difference is worth stating.**
/// Dart cannot enumerate the fields a computation reads, and folding these into
/// a value type with an `==` would move the hand-listing into that operator —
/// which is exactly the shape that dropped fields from `scaledBy` in #50 and
/// #116. What a single predicate removes is the failure that actually happened
/// both times: **two lists that disagree.** What it cannot remove is forgetting
/// a genuinely new input, and that is now a one-site problem with the read
/// sites named below rather than a two-site one with neither.
///
/// The reads this must cover, as of 2.17.0:
///
/// * `FlutterTablePlusState._getRowHeight` — `calculateRowHeight`, else
///   `theme.bodyTheme.rowHeight`, times `scale`.
/// * `TablePlusBodyState._calculateRowHeight` — `calculateRowHeight` times
///   `scale`.
/// * `TablePlusBodyState._buildGeometry` and `_getMergedGroupExtent`, and the
///   `itemExtent` / `itemExtentBuilder` pair — all falling back to
///   `theme.rowHeight`, which the parent has already scaled.
///
/// **Adding a fourth input means editing this function and adding a test that
/// changes only that input.** `test/drag_selection_test.dart` has one per input,
/// each holding the data list identical so the structure path cannot mask it.
///
/// `data` and `mergedGroups` are deliberately absent: they change *which* rows
/// exist, not how tall one is, and the body answers them in a different branch
/// that also rebuilds its row lookup.
///
/// **`rowId` is absent for a different reason, and the two are worth keeping
/// apart.** It is not a measurement input at all — and it is also the one
/// caller function this predicate's own technique cannot reach. `rowId` is
/// *required*, so every call site writes an inline closure, and the cost the
/// comment below prices at "one cache rebuild" becomes one per build per
/// caller; `calculateRowHeight` escapes that only because it is optional and
/// so is usually the same `null` twice running.
///
/// **Comparing `rowId`'s answers rather than its identity does work**, costs
/// about a tenth of the rebuild it prevents, and is the shape
/// `utils/overflow_cache.dart` already uses. It is not here yet because
/// switching it on turns an in-place `RangeError` into a silently missing row
/// until `computeRenderableIndices` is fixed. Until then the contract on
/// `FlutterTablePlus.rowId` stands in for it.
bool rowMeasurementChanged<T>({
  required double? Function(int index, T row)? oldCalculateRowHeight,
  required double? Function(int index, T row)? newCalculateRowHeight,
  required double oldScale,
  required double newScale,
  required double oldRowHeight,
  required double newRowHeight,
}) {
  // `identical`, not `==`: a closure over caller state is a new object on every
  // build even when it computes the same thing. Treating that as a change costs
  // one cache rebuild; treating a real swap as unchanged is #120.
  return !identical(oldCalculateRowHeight, newCalculateRowHeight) ||
      oldScale != newScale ||
      oldRowHeight != newRowHeight;
}
