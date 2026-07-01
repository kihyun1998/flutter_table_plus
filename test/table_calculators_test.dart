import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/models/table_column.dart';
import 'package:flutter_table_plus/src/utils/table_column_width_calculator.dart';
import 'package:flutter_table_plus/src/utils/table_row_height_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

// These utilities lean on TextPainter for the glyph measurement itself (a
// framework concern). The tests below deliberately assert only the arithmetic
// the utilities *own* — padding/extra addition, the +1/ceil/clamp on the
// column width, and the skip/min-height rules on the row height — by isolating
// that logic (e.g. differencing two measurements so the unknown glyph width
// cancels), so they don't depend on exact font metrics.

const _style = TextStyle(fontSize: 14);

TablePlusColumn<Map<String, dynamic>> _col({
  required String key,
  TextOverflow overflow = TextOverflow.visible,
  double width = 200,
  Widget Function(BuildContext, Map<String, dynamic>, bool, bool)?
      statefulCellBuilder,
  dynamic Function(Map<String, dynamic>)? valueAccessor,
}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: key,
    order: 0,
    valueAccessor: valueAccessor ?? (r) => r[key],
    width: width,
    textOverflow: overflow,
    statefulCellBuilder: statefulCellBuilder,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('measureTextWidth', () {
    test('empty text with no padding or extra measures zero', () {
      final w = TableColumnWidthCalculator.measureTextWidth(
        text: '',
        textStyle: _style,
        padding: EdgeInsets.zero,
      );
      expect(w, 0.0);
    });

    test('adds exactly padding.horizontal on top of the glyph width', () {
      final noPad = TableColumnWidthCalculator.measureTextWidth(
        text: 'Hello',
        textStyle: _style,
        padding: EdgeInsets.zero,
      );
      final withPad = TableColumnWidthCalculator.measureTextWidth(
        text: 'Hello',
        textStyle: _style,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(withPad - noPad, 32.0); // 16 left + 16 right
    });

    test('adds exactly extraWidth', () {
      final base = TableColumnWidthCalculator.measureTextWidth(
        text: 'Hi',
        textStyle: _style,
        padding: EdgeInsets.zero,
      );
      final extra = TableColumnWidthCalculator.measureTextWidth(
        text: 'Hi',
        textStyle: _style,
        padding: EdgeInsets.zero,
        extraWidth: 10,
      );
      expect(extra - base, 10.0);
    });

    test('longer text measures wider (monotonic)', () {
      final short = TableColumnWidthCalculator.measureTextWidth(
        text: 'A',
        textStyle: _style,
        padding: EdgeInsets.zero,
      );
      final long = TableColumnWidthCalculator.measureTextWidth(
        text: 'AAAAAAAA',
        textStyle: _style,
        padding: EdgeInsets.zero,
      );
      expect(long, greaterThan(short));
    });
  });

  group('calculateColumnWidth', () {
    double widthOf({
      String header = '',
      List<Map<String, dynamic>> data = const [],
      double minWidth = 50.0,
      double? maxWidth,
    }) {
      return TableColumnWidthCalculator.calculateColumnWidth<
          Map<String, dynamic>>(
        headerLabel: header,
        headerTextStyle: _style,
        data: data,
        valueAccessor: (r) => r['v'],
        bodyTextStyle: _style,
        minWidth: minWidth,
        maxWidth: maxWidth,
      );
    }

    test('clamps up to minWidth when the content is tiny', () {
      expect(widthOf(minWidth: 500), 500.0);
    });

    test('clamps down to maxWidth', () {
      expect(widthOf(minWidth: 0, maxWidth: 5), 5.0);
    });

    test('a longer body value widens the column (measured across rows)', () {
      final short = widthOf(minWidth: 0, data: [
        {'v': 'a'},
      ]);
      final long = widthOf(minWidth: 0, data: [
        {'v': 'aaaaaaaaaaaaaaaaaaaa'},
      ]);
      expect(long, greaterThan(short));
    });

    test('the result is an integer number of pixels (ceil)', () {
      final w = widthOf(minWidth: 0, data: [
        {'v': 'abc'},
      ]);
      expect(w, w.ceilToDouble());
    });
  });

  group('calculateTextHeight', () {
    test('empty text returns minHeight', () {
      final h = TableRowHeightCalculator.calculateTextHeight(
        text: '',
        textStyle: _style,
        maxWidth: 100,
        minHeight: 48,
      );
      expect(h, 48.0);
    });

    test('non-positive maxWidth returns minHeight', () {
      final h = TableRowHeightCalculator.calculateTextHeight(
        text: 'something',
        textStyle: _style,
        maxWidth: 0,
        minHeight: 48,
      );
      expect(h, 48.0);
    });

    test('never returns less than minHeight', () {
      final h = TableRowHeightCalculator.calculateTextHeight(
        text: 'x',
        textStyle: _style,
        maxWidth: 1000,
        minHeight: 200,
      );
      expect(h, 200.0);
    });

    test('wrapping to a narrower width yields a taller result', () {
      const longText =
          'the quick brown fox jumps over the lazy dog repeatedly and often';
      final narrow = TableRowHeightCalculator.calculateTextHeight(
        text: longText,
        textStyle: _style,
        maxWidth: 40,
        minHeight: 1,
      );
      final wide = TableRowHeightCalculator.calculateTextHeight(
        text: longText,
        textStyle: _style,
        maxWidth: 100000,
        minHeight: 1,
      );
      expect(narrow, greaterThan(wide));
    });
  });

  group('calculateRowHeight skip rules', () {
    double heightOf(List<TablePlusColumn<Map<String, dynamic>>> columns,
        Map<String, dynamic> row) {
      return TableRowHeightCalculator.calculateRowHeight<Map<String, dynamic>>(
        rowData: row,
        columns: columns,
        columnWidths: const [],
        defaultTextStyle: _style,
        minHeight: 48,
      );
    }

    test('no columns yields minHeight', () {
      expect(heightOf(const [], const {}), 48.0);
    });

    test('a column that is not TextOverflow.visible is skipped', () {
      final columns = [
        _col(key: 'v', overflow: TextOverflow.ellipsis),
      ];
      expect(
          heightOf(columns, {'v': 'a very very very long value indeed'}), 48.0);
    });

    test('a column with a custom cell builder is skipped', () {
      final columns = [
        _col(
          key: 'v',
          statefulCellBuilder: (_, __, ___, ____) => const SizedBox(),
        ),
      ];
      expect(
          heightOf(columns, {'v': 'a very very very long value indeed'}), 48.0);
    });

    test('a null cell value is skipped', () {
      final columns = [_col(key: 'v')];
      expect(heightOf(columns, const {'v': null}), 48.0);
    });

    test('a visible-overflow column with real text can exceed minHeight', () {
      final columns = [_col(key: 'v', width: 40)];
      final h = heightOf(
        columns,
        {'v': 'the quick brown fox jumps over the lazy dog many times over'},
      );
      expect(h, greaterThan(48.0));
    });
  });
}
