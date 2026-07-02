import 'package:flutter_table_plus/src/models/table_column.dart';
import 'package:flutter_table_plus/src/utils/column_width_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

// computeColumnWidths is the table's layout algorithm. Every expected width
// below is worked out by hand from the rules, independent of the implementation.

TablePlusColumn<Map<String, dynamic>> col(
  String key, {
  double width = 100,
  double minWidth = 50,
  double? maxWidth,
}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: key,
    order: 0,
    valueAccessor: (r) => r[key],
    width: width,
    minWidth: minWidth,
    maxWidth: maxWidth,
  );
}

List<double> compute(
  List<TablePlusColumn<Map<String, dynamic>>> columns,
  double availableWidth, {
  Map<String, double> resized = const {},
  bool stretch = false,
}) {
  return computeColumnWidths<Map<String, dynamic>>(
    availableWidth: availableWidth,
    columns: columns,
    resizedWidths: resized,
    stretchLastColumn: stretch,
  );
}

void main() {
  test('empty columns yield an empty list', () {
    expect(compute(const [], 300), isEmpty);
  });

  test('flexible columns split leftover space proportionally', () {
    // 3 x width100 (pref 300), avail 600 >= 300 -> each 600 * (100/300) = 200
    expect(
      compute([col('a'), col('b'), col('c')], 600),
      [200, 200, 200],
    );
  });

  test('insufficient space falls back to preferred widths', () {
    // pref 300 > avail 200 -> each keeps its preferred 100 (content overflows)
    expect(
      compute([col('a'), col('b'), col('c')], 200),
      [100, 100, 100],
    );
  });

  test('a flexible column hitting maxWidth is capped and excess redistributed',
      () {
    // A pref100 max150, B/C pref100; avail 600.
    // A share = 600/3 = 200 > 150 -> cap A=150; remaining 450 over pref 200
    // -> B=C=450*0.5=225.
    expect(
      compute([col('a', maxWidth: 150), col('b'), col('c')], 600),
      [150, 225, 225],
    );
  });

  test('a resized column is fixed and clamped, others share the rest', () {
    // A resized 400 but max300 -> fixed 300; B/C flexible over 300 -> 150 each.
    expect(
      compute(
        [col('a', maxWidth: 300), col('b'), col('c')],
        600,
        resized: {'a': 400},
      ),
      [300, 150, 150],
    );
  });

  test('a column narrower than minWidth is clamped up (insufficient space)',
      () {
    // A pref30 min80, B/C pref100 -> pref total 230 > avail 100 -> fallback:
    // A = 30.clamp(80) = 80, B = C = 100.
    expect(
      compute([col('a', width: 30, minWidth: 80), col('b'), col('c')], 100),
      [80, 100, 100],
    );
  });

  test('stretchLastColumn absorbs the remainder into the last column', () {
    // A/B fixed at 100 (width==max); avail 500, stretch -> B gets +300.
    expect(
      compute(
        [col('a', maxWidth: 100), col('b', maxWidth: 100)],
        500,
        stretch: true,
      ),
      [100, 400],
    );
  });

  test('stretchLastColumn skips the selection column', () {
    // selection fixed 60, A fixed 100; avail 500, stretch -> A (last non-
    // selection) gets +340, selection stays 60.
    expect(
      compute(
        [
          col('__selection__', width: 60, maxWidth: 60),
          col('a', maxWidth: 100)
        ],
        500,
        stretch: true,
      ),
      [60, 440],
    );
  });
}
