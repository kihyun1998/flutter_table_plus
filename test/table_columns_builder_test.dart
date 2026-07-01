import 'package:flutter_table_plus/src/models/table_column.dart';
import 'package:flutter_table_plus/src/models/table_columns_builder.dart';
import 'package:flutter_test/flutter_test.dart';

// TableColumnsBuilder's whole job is to keep column `order` values unique and
// consecutive from 1 as columns are added, inserted, removed, and reordered.
// These tests pin the resulting order numbers against hand-worked expectations.

TablePlusColumn<Map<String, dynamic>> _col(String key) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: key,
    order: 0, // ignored by the builder
    valueAccessor: (r) => r[key],
  );
}

TableColumnsBuilder<Map<String, dynamic>> _abc() {
  return TableColumnsBuilder<Map<String, dynamic>>()
    ..addColumn('a', _col('a'))
    ..addColumn('b', _col('b'))
    ..addColumn('c', _col('c'));
}

void main() {
  group('addColumn', () {
    test('assigns sequential orders starting at 1', () {
      final m = _abc().build();
      expect(m['a']!.order, 1);
      expect(m['b']!.order, 2);
      expect(m['c']!.order, 3);
    });

    test('throws on a duplicate key', () {
      final b = TableColumnsBuilder<Map<String, dynamic>>()
        ..addColumn('a', _col('a'));
      expect(() => b.addColumn('a', _col('a')), throwsArgumentError);
    });
  });

  group('insertColumn', () {
    test('places the new column at the target order and shifts the rest up',
        () {
      final m = (_abc()..insertColumn('x', _col('x'), 2)).build();
      expect(m['a']!.order, 1);
      expect(m['x']!.order, 2);
      expect(m['b']!.order, 3);
      expect(m['c']!.order, 4);
    });

    test('rejects an order below 1', () {
      final b = _abc();
      expect(() => b.insertColumn('x', _col('x'), 0), throwsArgumentError);
    });
  });

  group('removeColumn', () {
    test('renumbers the columns after the removed one', () {
      final m = (_abc()..removeColumn('b')).build();
      expect(m.containsKey('b'), isFalse);
      expect(m['a']!.order, 1);
      expect(m['c']!.order, 2);
    });

    test('throws for a missing key', () {
      final b = _abc();
      expect(() => b.removeColumn('zzz'), throwsArgumentError);
    });
  });

  group('reorderColumn', () {
    test('moving a column up shifts the intervening columns down', () {
      final m = (_abc()..reorderColumn('c', 1)).build();
      expect(m['c']!.order, 1);
      expect(m['a']!.order, 2);
      expect(m['b']!.order, 3);
    });

    test('moving a column down shifts the intervening columns up', () {
      final m = (_abc()..reorderColumn('a', 3)).build();
      expect(m['b']!.order, 1);
      expect(m['c']!.order, 2);
      expect(m['a']!.order, 3);
    });

    test('reordering to the same order is a no-op', () {
      final m = (_abc()..reorderColumn('b', 2)).build();
      expect(m['a']!.order, 1);
      expect(m['b']!.order, 2);
      expect(m['c']!.order, 3);
    });

    test('rejects an order below 1 and a missing key', () {
      expect(() => _abc().reorderColumn('a', 0), throwsArgumentError);
      expect(() => _abc().reorderColumn('zzz', 1), throwsArgumentError);
    });
  });

  group('build', () {
    test('returns an unmodifiable map', () {
      final m = _abc().build();
      expect(() => m['z'] = _col('z'), throwsUnsupportedError);
    });

    test('length / isEmpty / containsKey reflect the current columns', () {
      final b = TableColumnsBuilder<Map<String, dynamic>>();
      expect(b.isEmpty, isTrue);
      b.addColumn('a', _col('a'));
      expect(b.isNotEmpty, isTrue);
      expect(b.length, 1);
      expect(b.containsKey('a'), isTrue);
      expect(b.containsKey('nope'), isFalse);
    });
  });
}
