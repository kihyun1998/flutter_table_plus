import 'package:flutter_table_plus/src/models/table_column.dart';
import 'package:flutter_table_plus/src/utils/column_width_access.dart';
import 'package:flutter_test/flutter_test.dart';

TablePlusColumn<Map<String, dynamic>> _col({double width = 111}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: 'c',
    label: 'C',
    order: 0,
    valueAccessor: (r) => r['c'],
    width: width,
  );
}

void main() {
  group('List<double>.widthAt', () {
    test('returns the computed width at a valid index', () {
      expect([10.0, 20.0, 30.0].widthAt(1, _col()), 20.0);
    });

    test('falls back to the column width when widths are empty', () {
      expect(<double>[].widthAt(0, _col(width: 111)), 111);
    });

    test('falls back to the column width when the index is out of range', () {
      expect([10.0, 20.0].widthAt(5, _col(width: 111)), 111);
      expect([10.0, 20.0].widthAt(-1, _col(width: 111)), 111);
    });
  });
}
