import '../models/table_column.dart';

/// The synthetic selection column is never stretched.
const String _selectionColumnKey = '__selection__';

/// Resolves the rendered pixel width of each column.
///
/// Pure extraction of the table's layout algorithm (previously buried in the
/// widget State), so the proportional-distribution / max-width-redistribution /
/// `stretchLastColumn` math can be unit-tested directly instead of only through
/// pumped pixels.
///
/// Rules, in order:
/// 1. A user-**resized** column ([resizedWidths] by key) is fixed at its
///    resized width, clamped to `[minWidth, maxWidth]`.
/// 2. A column whose preferred [TablePlusColumn.width] already meets its
///    `maxWidth` is fixed (clamped).
/// 3. Remaining **flexible** columns share the leftover space in proportion to
///    their preferred widths. When a flexible column's share would exceed its
///    `maxWidth` it is capped and its excess redistributed to the rest. If
///    there isn't enough room for every flexible column's preferred width, each
///    falls back to its own preferred width (clamped).
/// 4. When [stretchLastColumn] is set, any leftover space is absorbed by the
///    last non-selection column.
///
/// Widths are returned in the order of [columns]. [availableWidth] is in the
/// same (logical) units as the column widths — the caller handles scaling.
List<double> computeColumnWidths<T>({
  required double availableWidth,
  required List<TablePlusColumn<T>> columns,
  required Map<String, double> resizedWidths,
  required bool stretchLastColumn,
}) {
  if (columns.isEmpty) return [];

  // Classify each column: resized, fixed (maxWidth caps it), or flexible
  double fixedTotal = 0;
  double flexiblePreferredTotal = 0;
  final widths = List<double?>.filled(columns.length, null);

  for (int i = 0; i < columns.length; i++) {
    final column = columns[i];
    final resizedWidth = resizedWidths[column.key];

    if (resizedWidth != null) {
      // User-resized column — lock to resized width
      final clamped = resizedWidth.clamp(
        column.minWidth,
        column.maxWidth ?? double.infinity,
      );
      widths[i] = clamped;
      fixedTotal += clamped;
    } else if (column.maxWidth != null && column.width >= column.maxWidth!) {
      // Column whose preferred width already hits maxWidth — fixed
      final clamped = column.width.clamp(column.minWidth, column.maxWidth!);
      widths[i] = clamped;
      fixedTotal += clamped;
    } else {
      // Flexible column — participates in proportional distribution
      flexiblePreferredTotal += column.width;
    }
  }

  final spaceForFlexible = availableWidth - fixedTotal;

  // Not enough space for proportional distribution — give preferred widths.
  // Using `< flexiblePreferredTotal` instead of `<= 0` prevents a
  // discontinuous jump when the boundary is crossed during window resize.
  if (spaceForFlexible < flexiblePreferredTotal ||
      flexiblePreferredTotal <= 0) {
    for (int i = 0; i < columns.length; i++) {
      if (widths[i] == null) {
        final col = columns[i];
        widths[i] =
            col.width.clamp(col.minWidth, col.maxWidth ?? double.infinity);
      }
    }
  } else {
    // Iterative redistribution: when a flexible column hits maxWidth,
    // lock it and redistribute the excess to remaining flexible columns.
    double remainingSpace = spaceForFlexible;
    double remainingPreferred = flexiblePreferredTotal;
    final isFlexible = List<bool>.generate(
      columns.length,
      (i) => widths[i] == null,
    );

    bool changed = true;
    while (changed) {
      changed = false;

      if (remainingPreferred <= 0 || remainingSpace <= 0) {
        for (int i = 0; i < columns.length; i++) {
          if (!isFlexible[i]) continue;
          final col = columns[i];
          widths[i] =
              col.width.clamp(col.minWidth, col.maxWidth ?? double.infinity);
        }
        break;
      }

      for (int i = 0; i < columns.length; i++) {
        if (!isFlexible[i]) continue;
        final column = columns[i];
        final proportion = column.width / remainingPreferred;
        final calculatedWidth = remainingSpace * proportion;

        if (column.maxWidth != null && calculatedWidth > column.maxWidth!) {
          widths[i] = column.maxWidth!;
          isFlexible[i] = false;
          remainingSpace -= column.maxWidth!;
          remainingPreferred -= column.width;
          changed = true;
          break;
        }
      }
    }

    // Final pass: assign remaining flexible columns
    for (int i = 0; i < columns.length; i++) {
      if (widths[i] != null) continue;
      final column = columns[i];
      final proportion = column.width / remainingPreferred;
      widths[i] = (remainingSpace * proportion)
          .clamp(column.minWidth, column.maxWidth ?? double.infinity);
    }
  }

  // stretchLastColumn: absorb any remaining space into the last column
  if (stretchLastColumn) {
    final totalUsed = widths.fold(0.0, (sum, w) => sum + (w ?? 0.0));
    final remaining = availableWidth - totalUsed;
    if (remaining > 0) {
      // Find last non-selection column index
      int lastIdx = -1;
      for (int i = columns.length - 1; i >= 0; i--) {
        if (columns[i].key != _selectionColumnKey) {
          lastIdx = i;
          break;
        }
      }
      if (lastIdx >= 0) {
        widths[lastIdx] = widths[lastIdx]! + remaining;
      }
    }
  }

  return widths.cast<double>();
}
