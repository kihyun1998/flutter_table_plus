/// The tri-state value for the header select-all checkbox.
///
/// Pure extraction of the header's checkbox-state rule so it can be unit-tested
/// directly:
/// - `false` — nothing selected (or there are no rows).
/// - `true`  — every row is selected.
/// - `null`  — some but not all rows are selected (indeterminate).
bool? selectAllState({required int total, required int selectedCount}) {
  if (total == 0) return false;
  if (selectedCount == 0) return false;
  if (selectedCount == total) return true;
  return null;
}
