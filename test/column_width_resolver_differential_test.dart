import 'dart:math';

import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/column_width_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

// Differential test guarding the O(n^2) -> O(n log n) optimization of
// computeColumnWidths: the new implementation must produce the same widths as
// the original (kept verbatim below as the reference) across many randomized
// inputs.

/// Verbatim copy of the ORIGINAL (pre-optimization) algorithm, used only as the
/// behavior oracle.
List<double> _referenceComputeColumnWidths<T>({
  required double availableWidth,
  required List<TablePlusColumn<T>> columns,
  required Map<String, double> resizedWidths,
  required bool stretchLastColumn,
}) {
  const selectionColumnKey = '__selection__';
  if (columns.isEmpty) return [];

  double fixedTotal = 0;
  double flexiblePreferredTotal = 0;
  final widths = List<double?>.filled(columns.length, null);

  for (int i = 0; i < columns.length; i++) {
    final column = columns[i];
    final resizedWidth = resizedWidths[column.key];

    if (resizedWidth != null) {
      final clamped = resizedWidth.clamp(
        column.minWidth,
        column.maxWidth ?? double.infinity,
      );
      widths[i] = clamped;
      fixedTotal += clamped;
    } else if (column.maxWidth != null && column.width >= column.maxWidth!) {
      final clamped = column.width.clamp(column.minWidth, column.maxWidth!);
      widths[i] = clamped;
      fixedTotal += clamped;
    } else {
      flexiblePreferredTotal += column.width;
    }
  }

  final spaceForFlexible = availableWidth - fixedTotal;

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

    for (int i = 0; i < columns.length; i++) {
      if (widths[i] != null) continue;
      final column = columns[i];
      final proportion = column.width / remainingPreferred;
      widths[i] = (remainingSpace * proportion)
          .clamp(column.minWidth, column.maxWidth ?? double.infinity);
    }
  }

  if (stretchLastColumn) {
    final totalUsed = widths.fold(0.0, (sum, w) => sum + (w ?? 0.0));
    final remaining = availableWidth - totalUsed;
    if (remaining > 0) {
      int lastIdx = -1;
      for (int i = columns.length - 1; i >= 0; i--) {
        if (columns[i].key != selectionColumnKey) {
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

List<TablePlusColumn<Map<String, dynamic>>> _randomColumns(Random rng) {
  final n = 2 + rng.nextInt(30); // 2..31 columns
  return List.generate(n, (i) {
    final w = 50.0 + rng.nextInt(250); // 50..299
    final double? maxW =
        rng.nextInt(3) == 0 ? null : w * (0.5 + rng.nextDouble() * 1.5);
    // minWidth <= maxWidth is required by clamp; keep it in range.
    final minW = maxW != null ? rng.nextDouble() * maxW : rng.nextDouble() * w;
    return TablePlusColumn<Map<String, dynamic>>(
      key: 'c$i',
      label: '',
      order: i,
      valueAccessor: (r) => null,
      width: w,
      minWidth: minW,
      maxWidth: maxW,
    );
  });
}

void main() {
  test('optimized computeColumnWidths matches the reference on random inputs',
      () {
    final rng = Random(20240702);

    for (int trial = 0; trial < 500; trial++) {
      final columns = _randomColumns(rng);
      final preferred = columns.fold<double>(0, (s, c) => s + c.width);
      final available = preferred * (0.3 + rng.nextDouble() * 2.0);

      final resized = <String, double>{};
      if (rng.nextBool()) {
        resized['c${rng.nextInt(columns.length)}'] = 50.0 + rng.nextInt(300);
      }
      final stretch = rng.nextBool();

      final got = computeColumnWidths<Map<String, dynamic>>(
        availableWidth: available,
        columns: columns,
        resizedWidths: resized,
        stretchLastColumn: stretch,
      );
      final want = _referenceComputeColumnWidths<Map<String, dynamic>>(
        availableWidth: available,
        columns: columns,
        resizedWidths: resized,
        stretchLastColumn: stretch,
      );

      expect(got.length, want.length);
      for (int i = 0; i < got.length; i++) {
        expect(
          got[i],
          closeTo(want[i], 1e-6),
          reason: 'trial $trial, column $i '
              '(n=${columns.length}, available=$available, stretch=$stretch)',
        );
      }
    }
  });
}
