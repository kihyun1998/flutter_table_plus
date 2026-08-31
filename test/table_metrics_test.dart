import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/table_metrics.dart';
import 'package:flutter_table_plus/src/widgets/row_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

// computeTableMetrics / computeRenderableIndices are the two single-pass
// derivations lifted out of the parent and body _rebuildCaches. Expectations
// are hand-traced against the loop rules.

List<Map<String, dynamic>> _rows(List<String> ids) => [
      for (final id in ids) {'id': id}
    ];

String _idOf(Map<String, dynamic> r) => r['id'] as String;

MergedRowGroup<Map<String, dynamic>> _group(String gid, List<String> keys) =>
    MergedRowGroup<Map<String, dynamic>>(
      groupId: gid,
      rowKeys: keys,
      mergeConfig: const {},
    );

RowLookup<Map<String, dynamic>> _lookup(
  List<String> ids,
  List<MergedRowGroup<Map<String, dynamic>>> groups,
) {
  return RowLookup.build(
    data: _rows(ids),
    mergedGroups: groups,
    rowId: _idOf,
  );
}

void main() {
  group('computeRenderableIndices', () {
    test('returns null when there are no merged groups', () {
      expect(
        computeRenderableIndices<Map<String, dynamic>>(
          data: _rows(['a', 'b']),
          lookup: _lookup(['a', 'b'], const []),
          rowId: _idOf,
          hasMergedGroups: false,
        ),
        isNull,
      );
    });

    test('a group contributes one render row at its first member', () {
      final g = _group('g1', ['b', 'c']);
      // a(0) ungrouped, b(1)+c(2) grouped -> render row at 1, d(3) ungrouped.
      expect(
        computeRenderableIndices<Map<String, dynamic>>(
          data: _rows(['a', 'b', 'c', 'd']),
          lookup: _lookup(['a', 'b', 'c', 'd'], [g]),
          rowId: _idOf,
          hasMergedGroups: true,
        ),
        [0, 1, 3],
      );
    });

    test('out-of-order rowKeys still render, at the earliest member', () {
      // `rowKeys.first` (c@2) is not the group's earliest data row (b@1). This
      // used to render nothing for the group at all — `[0, 3]`, with both b and
      // c simply absent from a table that held them — and a test here pinned
      // that as correct, under the name "preserves the out-of-order-rowKeys
      // quirk". #135 measured what the quirk costs and this is the fix: the
      // anchor is the earliest present member, which is what `computeTableMetrics`
      // three groups down has always used.
      final g = _group('g1', ['c', 'b']);
      expect(
        computeRenderableIndices<Map<String, dynamic>>(
          data: _rows(['a', 'b', 'c', 'd']),
          lookup: _lookup(['a', 'b', 'c', 'd'], [g]),
          rowId: _idOf,
          hasMergedGroups: true,
        ),
        [0, 1, 3],
      );
    });

    test('a group whose first key is absent from data still renders', () {
      // The extreme of the case above, and the one that reaches a user: the
      // caller passes a list that no longer holds `b`, the group still names it,
      // and `indexOf('b')` is null. Anchoring on `rowKeys.first` made the render
      // condition unsatisfiable while the loop still marked `c` processed, so
      // **both** rows left the screen for the sake of one that was gone.
      final g = _group('g1', ['b', 'c']);
      expect(
        computeRenderableIndices<Map<String, dynamic>>(
          data: _rows(['a', 'c', 'd']),
          lookup: _lookup(['a', 'c', 'd'], [g]),
          rowId: _idOf,
          hasMergedGroups: true,
        ),
        [0, 1, 2],
        reason: 'a(0), the group anchored at its surviving member c(1), d(2)',
      );
    });

    test('and it agrees with computeTableMetrics, which is the point', () {
      // The two derive the same fact and used to disagree about it. A test that
      // only pinned this one would let them drift apart again, so the anchor is
      // asserted against the count that shares it.
      final g = _group('g1', ['b', 'c']);
      final ids = ['a', 'c', 'd'];
      final lookup = _lookup(ids, [g]);

      final rendered = computeRenderableIndices<Map<String, dynamic>>(
        data: _rows(ids),
        lookup: lookup,
        rowId: _idOf,
        hasMergedGroups: true,
      );
      final counted = computeTableMetrics<Map<String, dynamic>>(
        data: _rows(ids),
        lookup: lookup,
        rowHeightOf: (_) => 10,
        mergedGroupHeightOf: (_) => 10,
      );

      expect(rendered!.length, counted.totalCount,
          reason: 'the body renders one row per thing the parent counted');
    });
  });

  group('computeTableMetrics', () {
    TableMetrics metrics(
      List<String> ids,
      List<MergedRowGroup<Map<String, dynamic>>> groups, {
      double Function(int)? rowHeightOf,
      double Function(MergedRowGroup<Map<String, dynamic>>)?
          mergedGroupHeightOf,
    }) {
      return computeTableMetrics<Map<String, dynamic>>(
        data: _rows(ids),
        lookup: _lookup(ids, groups),
        rowHeightOf: rowHeightOf ?? (_) => 10,
        mergedGroupHeightOf: mergedGroupHeightOf ?? (_) => 25,
      );
    }

    test('sums per-row heights and counts every row when ungrouped', () {
      final m = metrics(['a', 'b', 'c'], const []);
      expect(m.totalHeight, 30);
      expect(m.totalCount, 3);
    });

    test('a group counts once and uses the injected group height', () {
      // a(10) + group[b,c](25) + d(10) = 45; count a, group, d = 3.
      final m = metrics([
        'a',
        'b',
        'c',
        'd'
      ], [
        _group('g1', ['b', 'c'])
      ]);
      expect(m.totalHeight, 45);
      expect(m.totalCount, 3);
    });

    test('the injected group height can depend on the group', () {
      final m = metrics(
        ['a', 'b', 'c'],
        [
          _group('g1', ['b', 'c'])
        ],
        mergedGroupHeightOf: (g) => g.rowKeys.length * 10,
      );
      // a(10) + group(2*10=20) = 30; count = 2.
      expect(m.totalHeight, 30);
      expect(m.totalCount, 2);
    });
  });
}
