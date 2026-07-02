import '../models/table_column.dart';

/// The next sort direction when a header is tapped.
///
/// Pure extraction of the sort-cycle state machine (previously inline in the
/// header State), so its full truth table is unit-testable.
///
/// - Tapping a **different** column than the currently-sorted one ([sortedKey])
///   starts fresh in the cycle's first direction (ascending for
///   [SortCycleOrder.ascendingFirst], descending otherwise).
/// - Tapping the **same** column advances the cycle:
///   ascendingFirst → none → ascending → descending → none,
///   descendingFirst → none → descending → ascending → none.
SortDirection nextSortDirection({
  required SortDirection current,
  required String tappedKey,
  required String? sortedKey,
  required SortCycleOrder cycle,
}) {
  if (sortedKey != tappedKey) {
    return cycle == SortCycleOrder.ascendingFirst
        ? SortDirection.ascending
        : SortDirection.descending;
  }

  return switch (cycle) {
    SortCycleOrder.ascendingFirst => switch (current) {
        SortDirection.none => SortDirection.ascending,
        SortDirection.ascending => SortDirection.descending,
        SortDirection.descending => SortDirection.none,
      },
    SortCycleOrder.descendingFirst => switch (current) {
        SortDirection.none => SortDirection.descending,
        SortDirection.descending => SortDirection.ascending,
        SortDirection.ascending => SortDirection.none,
      },
  };
}
