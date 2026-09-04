import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #173. `spanningRowIndex` decides which member of a merged group the merged
// cell reads its content from, and it had two failures that were different in
// kind:
//
//   1  An index past the end threw `RangeError` from inside
//      `_buildMergedCell` — out of a widget build, so a red screen in release
//      rather than a caught error.
//   2  An index naming a key `data` does not hold resolved to nothing and
//      rendered an empty cell. Silent: no exception, no banner, and the value
//      that should have been there simply left the screen.
//
// **The contract question came first and is settled here too.** The index is a
// position in `rowKeys` — the list the caller wrote — and NOT a position among
// the rows as `data` orders them. The two agree whenever `rowKeys` is written
// in `data` order, which is why the first case below deliberately is not: an
// ordered fixture passes under both readings and states nothing.
//
// The presence walk in case 2 is a *fallback*, not a re-reading. It runs only
// when the position the caller named has nothing behind it, so it cannot move
// the answer in any case where the named row exists.

typedef Row = Map<String, dynamic>;

Map<String, TablePlusColumn<Row>> _columns() {
  final b = TableColumnsBuilder<Row>();
  b.addColumn(
    'name',
    TablePlusColumn<Row>(
      key: 'name',
      label: 'Name',
      order: 0,
      width: 200,
      valueAccessor: (r) => r['name'],
    ),
  );
  return b.build();
}

/// Each case gets its own [groupId], and that is not cosmetic.
///
/// The debug warnings are emitted **once per (group, column, kind)** for the
/// life of the process — they fire from inside `build`, so warning per build
/// would be one line per frame. Two cases sharing a `groupId` therefore share
/// the warning, and the second one reads as silent. The first version of this
/// file did share it, and the two capture cases below failed against a fix that
/// works: the earlier case had already spent the warning.
MergedRowGroup<Row> _group(List<String> rowKeys, int spanIndex,
        {String groupId = 'g'}) =>
    MergedRowGroup<Row>(
      groupId: groupId,
      rowKeys: rowKeys,
      mergeConfig: {
        'name': MergeCellConfig(shouldMerge: true, spanningRowIndex: spanIndex),
      },
    );

List<Row> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'name': 'VAL-$id'}
    ];

Future<void> _pump(
  WidgetTester tester, {
  required List<String> data,
  required List<String> rowKeys,
  required int spanIndex,
  String groupId = 'g',
}) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 700,
          child: FlutterTablePlus<Row>(
            columns: _columns(),
            data: _rows(data),
            rowId: (r) => r['id'] as String,
            mergedGroups: [_group(rowKeys, spanIndex, groupId: groupId)],
            theme: const TablePlusTheme(
              bodyTheme: TablePlusBodyTheme(rowHeight: 60),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Every `VAL-*` the table is currently showing, in tree order.
List<String> _shown(WidgetTester tester) => find
    .textContaining('VAL-')
    .evaluate()
    .map((e) => (e.widget as Text).data!)
    .toList();

/// Runs [body] with `debugPrint` captured, and returns the lines it produced.
///
/// Restored in a `finally` **inside the test body**, never in `tearDown`:
/// `_verifyInvariants` checks the foundation's debug hooks at the end of the
/// body, before any teardown runs, so a restore scheduled there fails the test
/// with a framework assertion instead of passing. Measured, on the pass that
/// wrote it the other way (#161).
Future<List<String>> _printsWhile(Future<void> Function() body) async {
  final captured = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) captured.add(message);
  };
  try {
    await body();
  } finally {
    debugPrint = original;
  }
  return captured;
}

void main() {
  group('the index is a position in rowKeys (#173)', () {
    testWidgets('rowKeys out of data order: the caller\'s list wins',
        (tester) async {
      // The discriminating case, and the only shape that separates the two
      // readings. Positionally `rowKeys[1]` is 'a'; among the members in
      // `data` order it would be 'b'. An ordered fixture answers 'b' either
      // way and could not tell them apart.
      await _pump(tester, data: ['a', 'b'], rowKeys: ['b', 'a'], spanIndex: 1);

      expect(_shown(tester), ['VAL-a'],
          reason: 'sorting data must not move which row a merged cell shows — '
              'rowKeys order is the caller\'s and stays put');
    });

    testWidgets('the control: written in data order, both readings agree',
        (tester) async {
      await _pump(tester, data: ['a', 'b'], rowKeys: ['a', 'b'], spanIndex: 1);

      expect(_shown(tester), ['VAL-b'],
          reason: 'here the two readings coincide, which is why this case is '
              'the control and not the proof');
    });
  });

  group('an out-of-range index clamps instead of throwing (#173)', () {
    testWidgets('no exception escapes the build, and the last member shows',
        (tester) async {
      await _pump(tester, data: ['a', 'b'], rowKeys: ['a', 'b'], spanIndex: 5);

      expect(tester.takeException(), isNull,
          reason: 'it threw RangeError from inside _buildMergedCell, which is '
              'a red screen in release rather than a caught error');
      expect(_shown(tester), ['VAL-b']);
    });

    testWidgets('and debug says so once, naming both numbers', (tester) async {
      final lines = await _printsWhile(() => _pump(tester,
          data: ['a', 'b'],
          rowKeys: ['a', 'b'],
          spanIndex: 5,
          groupId: 'range-warning'));

      final warnings =
          lines.where((l) => l.contains('spanningRowIndex 5')).toList();
      expect(warnings, hasLength(1),
          reason: 'once per (group, column), not once per build — these fire '
              'from inside build, so an unguarded print is one line per frame');
      expect(warnings.single, contains('past the end of rowKeys (2)'));
      expect(warnings.single, contains('Clamped to 1'));
    });

    test('the model clamps on its own, with no widget in sight', () {
      expect(_group(['a', 'b', 'c'], 9).getSpanningRowKey('name'), 'c');
      expect(_group(['a', 'b', 'c'], 1).getSpanningRowKey('name'), 'b',
          reason: 'an in-range index is untouched by the clamp');
    });

    test('a duplicated key cannot desync the clamp from the walk', () {
      // `resolveSpanningRowKey` used to find its starting position by asking
      // `rowKeys.indexOf` for the resolved key, which answers 0 here for an
      // index of 2. Nothing validates a group's keys, so a duplicate is a
      // caller state this package supports everywhere else.
      final group = _group(['a', 'b', 'a'], 2);
      expect(
        group.resolveSpanningRowKey(
            'name', _rows(['a', 'b']), (r) => r['id'] as String),
        'a',
      );
      expect(group.getSpanningRowKey('name'), 'a');
    });
  });

  group('an absent key falls forward instead of blanking (#173)', () {
    testWidgets('the value stays on screen', (tester) async {
      // Before: rowKeys[1] is 'ghost', getRowData returns null, and the merged
      // cell renders empty — so VAL-a leaves the screen with no signal at all.
      await _pump(tester,
          data: ['a', 'b'], rowKeys: ['a', 'ghost'], spanIndex: 1);

      expect(_shown(tester), contains('VAL-a'),
          reason: 'the walk continues forward through rowKeys, wrapping once, '
              'to the first member data actually holds');
      expect(tester.takeException(), isNull);
    });

    testWidgets('and debug names the key it wanted and the one it used',
        (tester) async {
      final lines = await _printsWhile(() => _pump(tester,
          data: ['a', 'b'],
          rowKeys: ['a', 'ghost'],
          spanIndex: 1,
          groupId: 'absent-warning'));

      final warnings = lines.where((l) => l.contains('ghost')).toList();
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('which data does not hold'));
      expect(warnings.single, contains('Using "a"'));
    });

    testWidgets('a present key is never second-guessed', (tester) async {
      // The discriminating control for the fallback. Without it, "shows VAL-a"
      // passes for an implementation that always returns the first present
      // member and ignores the index entirely.
      final lines = await _printsWhile(() => _pump(tester,
          data: ['a', 'b', 'c'],
          rowKeys: ['a', 'b', 'c'],
          spanIndex: 2,
          groupId: 'no-warning'));

      expect(_shown(tester), ['VAL-c'],
          reason: 'every member is present, so the index is the whole answer');
      expect(lines.where((l) => l.contains('does not hold')), isEmpty,
          reason: 'and nothing is warned about, because nothing moved');
    });

    test('the walk wraps forward, it does not search backwards', () {
      // Start at 2 ('ghost'), wrap to 0. If it walked backwards it would answer
      // 'b', and both are "the nearest present member" — only the direction
      // tells them apart, so the fixture puts a present member on each side.
      final group = _group(['a', 'b', 'ghost'], 2);
      expect(
        group.resolveSpanningRowKey(
            'name', _rows(['a', 'b']), (r) => r['id'] as String),
        'a',
      );
    });

    test('a group with nothing present resolves to null, not to a key', () {
      final group = _group(['x', 'y'], 0);
      expect(
        group.resolveSpanningRowKey(
            'name', _rows(['a', 'b']), (r) => r['id'] as String),
        isNull,
        reason: 'an empty merged cell is the right answer only here — where '
            'there is no value that went missing',
      );
    });

    test('an empty group resolves to null rather than throwing', () {
      // `getSpanningRowKey` still throws on an empty rowKeys, because there is
      // no key to return. The widget path does not reach it: an expanded empty
      // group renders one summary row, so this call site is live.
      final group = _group([], 0);
      expect(
        group.resolveSpanningRowKey(
            'name', _rows(['a']), (r) => r['id'] as String),
        isNull,
      );
    });
  });
}
