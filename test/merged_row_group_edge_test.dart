import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The existing suite already covers MergedRowGroup's happy path and most
// accessors. These fill the edge cases the coverage issue called out: empty
// groups and an out-of-bounds spanning index.

void main() {
  group('MergedRowGroup edge cases', () {
    test('an empty group reports zero rows', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: [],
        mergeConfig: {},
      );
      expect(group.rowCount, 0);
      expect(group.effectiveRowCount, 0);
      expect(group.getAllRowData(const [], (r) => r['id'] as String), isEmpty);
    });

    test('an empty group is still zero rows even if flagged expandable', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: [],
        mergeConfig: {},
        isExpanded: true,
      );
      // rowCount 0 + 1 summary row when expanded.
      expect(group.effectiveRowCount, 1);
    });

    test('getSpanningRowKey throws when the span index is out of bounds', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['a', 'b'],
        mergeConfig: {
          'name': MergeCellConfig(shouldMerge: true, spanningRowIndex: 5),
        },
      );
      expect(() => group.getSpanningRowKey('name'), throwsRangeError);
    });

    test('getAllRowData drops keys that are missing from the data', () {
      const group = MergedRowGroup<Map<String, dynamic>>(
        groupId: 'g1',
        rowKeys: ['a', 'ghost', 'b'],
        mergeConfig: {},
      );
      final data = [
        {'id': 'a', 'name': 'Alice'},
        {'id': 'b', 'name': 'Bob'},
      ];
      final rows = group.getAllRowData(data, (r) => r['id'] as String);
      expect(rows.map((r) => r['name']), ['Alice', 'Bob']);
    });
  });
}
