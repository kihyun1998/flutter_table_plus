import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/column_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

TablePlusColumn<Map<String, dynamic>> col(
  String key, {
  required int order,
  bool visible = true,
}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: key,
    order: order,
    valueAccessor: (r) => r[key],
    visible: visible,
  );
}

List<TablePlusColumn<Map<String, dynamic>>> order(
  Map<String, TablePlusColumn<Map<String, dynamic>>> columns, {
  bool isSelectable = false,
  TablePlusCheckboxTheme checkboxTheme = const TablePlusCheckboxTheme(),
}) {
  return orderVisibleColumns<Map<String, dynamic>>(
    columns: columns,
    isSelectable: isSelectable,
    checkboxTheme: checkboxTheme,
  );
}

void main() {
  group('orderVisibleColumns', () {
    test('sorts by the order field', () {
      final result = order({
        'b': col('b', order: 2),
        'a': col('a', order: 1),
        'c': col('c', order: 3),
      });
      expect(result.map((c) => c.key), ['a', 'b', 'c']);
    });

    test('drops invisible columns', () {
      final result = order({
        'a': col('a', order: 1),
        'b': col('b', order: 2, visible: false),
        'c': col('c', order: 3),
      });
      expect(result.map((c) => c.key), ['a', 'c']);
    });

    test('prepends a selection column when selectable', () {
      final result = order(
        {'a': col('a', order: 1), 'b': col('b', order: 2)},
        isSelectable: true,
      );
      expect(result.map((c) => c.key), ['__selection__', 'a', 'b']);

      final selection = result.first;
      expect(selection.order, -1);
      expect(selection.sortable, isFalse);
      expect(selection.width, 60); // default checkboxColumnWidth
      expect(selection.minWidth, 60);
      expect(selection.maxWidth, 60);
    });

    test('the selection column width follows the checkbox theme', () {
      final result = order(
        {'a': col('a', order: 1)},
        isSelectable: true,
        checkboxTheme: const TablePlusCheckboxTheme(checkboxColumnWidth: 40),
      );
      expect(result.first.width, 40);
      expect(result.first.maxWidth, 40);
    });

    test('no selection column when not selectable', () {
      final result = order(
        {'a': col('a', order: 1)},
        isSelectable: false,
      );
      expect(result.map((c) => c.key), ['a']);
    });

    test('no selection column when the checkbox column is hidden', () {
      final result = order(
        {'a': col('a', order: 1)},
        isSelectable: true,
        checkboxTheme: const TablePlusCheckboxTheme(showCheckboxColumn: false),
      );
      expect(result.map((c) => c.key), ['a']);
    });
  });
}
