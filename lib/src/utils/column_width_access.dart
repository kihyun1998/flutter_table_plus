import '../models/table_column.dart';

/// Resolves the render-time width of a column from a computed widths list.
///
/// Centralizes the `columnWidths.isNotEmpty ? columnWidths[i] : column.width`
/// decision that was previously duplicated across the header, rows, and merged
/// rows. The bounds guard makes it safe for every caller (an out-of-range
/// index falls back to the column's declared width instead of throwing).
extension ColumnWidthAccess on List<double> {
  /// The width for the column at [index]: the computed width when present and
  /// in range, otherwise the column's own [TablePlusColumn.width].
  double widthAt(int index, TablePlusColumn column) {
    if (isNotEmpty && index >= 0 && index < length) return this[index];
    return column.width;
  }
}
