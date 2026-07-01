import 'package:flutter_table_plus/src/models/merged_row_group.dart';
import 'package:flutter_table_plus/src/widgets/row_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

// RowLookup is the single home for the row→index / row→group derivation that
// the table parent and body both need. These tests pin its behavior against
// hand-computed expectations so both call sites can share it without drift.

List<Map<String, dynamic>> _rows(List<String> ids) => [
      for (final id in ids) {'id': id}
    ];

String _idOf(Map<String, dynamic> r) => r['id'] as String;

RowLookup<Map<String, dynamic>> _lookup(
  List<String> ids, {
  List<MergedRowGroup<Map<String, dynamic>>> groups = const [],
}) {
  return RowLookup.build(
    data: _rows(ids),
    mergedGroups: groups,
    rowId: _idOf,
  );
}

MergedRowGroup<Map<String, dynamic>> _group(
  String groupId,
  List<String> rowKeys,
) {
  return MergedRowGroup<Map<String, dynamic>>(
    groupId: groupId,
    rowKeys: rowKeys,
    mergeConfig: const {},
  );
}

void main() {
  group('RowLookup', () {
    test('rowCount reflects the data length', () {
      expect(_lookup(['a', 'b', 'c']).rowCount, 3);
      expect(_lookup(const []).rowCount, 0);
    });

    test('indexOf returns the data index for a known id', () {
      final lookup = _lookup(['a', 'b', 'c']);
      expect(lookup.indexOf('a'), 0);
      expect(lookup.indexOf('b'), 1);
      expect(lookup.indexOf('c'), 2);
    });

    test('indexOf returns null for an unknown id', () {
      expect(_lookup(['a', 'b']).indexOf('z'), isNull);
    });

    test('groupOf returns null when the row is not in any group', () {
      final lookup = _lookup([
        'a',
        'b'
      ], groups: [
        _group('g1', ['a']),
      ]);
      expect(lookup.groupOf('b'), isNull);
    });

    test('groupOf returns the group that contains the id', () {
      final g = _group('g1', ['a', 'b']);
      final lookup = _lookup(['a', 'b', 'c'], groups: [g]);
      expect(lookup.groupOf('a'), same(g));
      expect(lookup.groupOf('b'), same(g));
      expect(lookup.groupOf('c'), isNull);
    });

    test('groupForRowIndex maps an index through to its group', () {
      final g = _group('g1', ['b', 'c']);
      final lookup = _lookup(['a', 'b', 'c'], groups: [g]);
      expect(lookup.groupForRowIndex(0), isNull); // 'a' ungrouped
      expect(lookup.groupForRowIndex(1), same(g)); // 'b'
      expect(lookup.groupForRowIndex(2), same(g)); // 'c'
    });

    test('groupForRowIndex returns null for out-of-range indices', () {
      final lookup = _lookup(['a', 'b']);
      expect(lookup.groupForRowIndex(-1), isNull);
      expect(lookup.groupForRowIndex(2), isNull);
      expect(lookup.groupForRowIndex(99), isNull);
    });

    test('a row can only belong to the last group that claims it', () {
      // Two groups both list 'b'; the later one wins (mirrors map-build order).
      final g1 = _group('g1', ['a', 'b']);
      final g2 = _group('g2', ['b', 'c']);
      final lookup = _lookup(['a', 'b', 'c'], groups: [g1, g2]);
      expect(lookup.groupOf('b'), same(g2));
    });
  });
}
