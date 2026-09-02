import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_merged_row.dart';
import 'package:flutter_test/flutter_test.dart';

// #135. `data` and `mergedGroups` are two caller-supplied lists that nothing
// validates against each other, and four separate derivations answer "which
// rows, and how tall" from them. Two of the four were wrong, both in the body,
// and both in the direction of disagreeing with the parent:
//
//   computeTableMetrics      (parent count)   anchors on the earliest present
//                                             member -- correct
//   computeRenderableIndices (body render)    anchored on `rowKeys.first`
//   _getMergedRowHeight      (parent height)  skips a key absent from `data`
//   _getMergedGroupExtent    (body height)    added `theme.rowHeight` for it
//
// These are widget-level because the pure functions are already covered in
// `table_metrics_test.dart`; what cannot be seen there is that the parent and
// the body then act on their two answers -- one deciding whether a scrollbar
// exists, the other laying rows out and being indexed into.

typedef Row = Map<String, dynamic>;

Map<String, TablePlusColumn<Row>> _columns() {
  final builder = TableColumnsBuilder<Row>();
  builder.addColumn(
    'c0',
    TablePlusColumn<Row>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 100,
    ),
  );
  return builder.build();
}

List<Row> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'c0': 'r$id'}
    ];

MergedRowGroup<Row> _group(List<String> keys) => MergedRowGroup<Row>(
      groupId: 'g0',
      rowKeys: keys,
      mergeConfig: const {},
    );

Future<void> _pump(
  WidgetTester tester, {
  required List<Row> data,
  required List<MergedRowGroup<Row>> groups,
  double tableHeight = 400,
  double? Function(int, Row)? calculateRowHeight,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: tableHeight,
            child: FlutterTablePlus<Row>(
              columns: _columns(),
              data: data,
              rowId: (r) => r['id'] as String,
              mergedGroups: groups,
              calculateRowHeight: calculateRowHeight,
              theme: const TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(rowHeight: 40),
                headerTheme: TablePlusHeaderTheme(height: 40),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The top of each visible `c0` cell, relative to the body's `ListView`. This
/// is what the **body's** group extent moves; the parent's scrollbar decision
/// comes from `_getMergedRowHeight`, which never had the phantom, so asserting
/// a scrollbar here would prove nothing about the body at all.
List<double> _rowTops(WidgetTester tester) {
  final listTop = tester.getRect(find.byType(ListView)).top;
  return [
    for (final t in tester.widgetList<Text>(find.byType(Text)))
      if (t.data != null && t.data!.startsWith('r'))
        tester.getRect(find.text(t.data!)).top - listTop,
  ];
}

/// The `c0` cell texts on screen, in order. Asserted as a list rather than a
/// count so a row that moves is not mistaken for a row that survived.
List<String> _visible(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data)
    .whereType<String>()
    .where((s) => s.startsWith('r'))
    .toList();

void main() {
  group('a group naming a row that data does not hold', () {
    testWidgets('renders the members it does have', (tester) async {
      // The group names 0 and 1; the caller hands over a list without 0. Row 1
      // is present, belongs to the group, and used to be drawn nowhere --
      // `indexOf(rowKeys.first)` was null, so the render condition could not be
      // satisfied while the loop still marked 1 processed.
      await _pump(
        tester,
        data: _rows(['1', '2', '3']),
        groups: [
          _group(const ['0', '1'])
        ],
      );

      expect(_visible(tester), ['r1', 'r2', 'r3'],
          reason: 'r1 is in `data`, belongs to the group, and must be drawn');

      // **Text on screen is not enough**, and a first version of this test
      // stopped there. A group that renders as ungrouped rows draws exactly the
      // same strings — so the assertion passed while `_buildRowWidget` was
      // still anchoring on `rowKeys.first` and falling through to the plain-row
      // branch. Asserted by type, which is the only thing that separates them.
      expect(find.byType(TablePlusMergedRow<Row>), findsOneWidget,
          reason: 'the group rendered as loose rows rather than as a group');
    });

    testWidgets('renders as a group when rowKeys are out of data order',
        (tester) async {
      // The same defect without anything missing: `rowKeys.first` is `1`, whose
      // index is 1, so the anchor test failed at index 0 and the group fell
      // through — while `computeRenderableIndices` had already marked index 1
      // processed. r1 was drawn by nobody.
      await _pump(
        tester,
        data: _rows(['0', '1', '2']),
        groups: [
          _group(const ['1', '0'])
        ],
      );

      expect(find.byType(TablePlusMergedRow<Row>), findsOneWidget);
      // A merged row stacks its members in **`rowKeys` order**, not data order,
      // so `['1','0']` draws r1 above r0. That is pre-existing and is #121's
      // territory (how a group distributes itself among its members); what #135
      // is about is that r1 is drawn *at all*.
      expect(_visible(tester), ['r1', 'r0', 'r2'],
          reason: 'r1 belongs to the group and was drawn by neither branch');
    });

    testWidgets('does not reserve height for the member it does not have',
        (tester) async {
      // The group names 0 and 1 and `data` holds only 1, so the group is one
      // row tall. Row 2 follows it at 40.
      //
      // **Asserted on row positions, not on a scrollbar.** A first draft of
      // this test asserted `findsNothing` for `Scrollbar` and passed with the
      // phantom height restored — because the parent's total comes from
      // `_getMergedRowHeight`, which never had the phantom. The body's extent
      // feeds `itemExtentBuilder`, so where the rows sit is the only thing that
      // can see it.
      await _pump(
        tester,
        data: _rows(['1', '2']),
        groups: [
          _group(const ['0', '1'])
        ],
      );

      // These are text tops, not row tops -- a cell centres its text, and a
      // merged cell centres it differently from a plain one. The discriminating
      // fact is the *gap*: one row of 40 between them, not two.
      // The merged row asks for exactly what the list allocated it. Without
      // this it fell back to `theme.rowHeight * effectiveRowCount`, and
      // `effectiveRowCount` counts `rowKeys` — including the absent member — so
      // it asked for 80 in a 40 box and squeezed its own cells. Nothing threw;
      // the constraint just won.
      expect(tester.getSize(find.byType(TablePlusMergedRow<Row>)).height, 40.0,
          reason: 'the group is one present member tall');

      final tops = _rowTops(tester);
      expect(tops, hasLength(2));
      expect(tops[1] - tops[0], lessThan(60),
          reason: 'the group reserved a phantom 40 for the member `data` does '
              'not hold, so r2 sat a whole extra row lower and the body '
              'disagreed with the parent by exactly one row height');
    });
  });

  group('the group is exactly as tall as the members it holds', () {
    testWidgets('an absent member takes up no room in the group',
        (tester) async {
      // The group draws one stacked cell per member. It walked `rowKeys`
      // unconditionally, so a key `data` does not hold got an **empty cell**
      // that still took space in the Column — and once #135 made the group's
      // height count only the present members, the cells and the height they
      // were dividing had stopped agreeing.
      //
      // Observed on where the surviving member's text lands, which is the only
      // thing that moves: measured 2026-08-31 the phantom cell pushed `r1` down
      // by 10.5px inside a box whose size did not change.
      await _pump(
        tester,
        data: _rows(['1', '2']),
        groups: [
          _group(const ['0', '1'])
        ],
      );

      final tops = _rowTops(tester);
      expect(tops, hasLength(2));
      expect(tops[0], lessThan(15.0),
          reason: 'r1 is the only member the group has, so it sits at the top '
              'of it — an empty cell for the absent member pushes it down');
    });

    // **One change in this issue deliberately has no test, and the reason is
    // that it has no observable behaviour.** `_buildRowWidget` now passes the
    // allocated extent as `calculatedHeight` instead of letting the widget fall
    // back to `theme.rowHeight * effectiveRowCount`. Measured under mutation it
    // changes only the height the merged row's inner `SizedBox` *asks* for — 80
    // or 60 instead of 40 — and the list hands that row a tight constraint, so
    // the box, the texts and every position are byte-identical either way.
    //
    // **The other one stopped being unobservable, in the same unreleased
    // version.** This used to say "two changes", the second being the per-member
    // height loop skipping an absent key. #121 gave that loop's output a job —
    // it sets each member's fixed extent — so restoring the absent key now moves
    // a surviving member on screen, and `merged_row_member_heights_test.dart`
    // asserts it. A reason with an expiry date, and the expiry arrived four
    // issues later.
    //
    // They are still right: a widget asking for a height it will not be given
    // is a disagreement waiting for the constraint to loosen. But the only way
    // to assert them is to reach for that inner `SizedBox`, and asserting on
    // the implementation rather than the screen is the thing this repo's
    // divergence list forbids outright. A test that can only be written wrong
    // is worse than the sentence you are reading.
  });

  group('shrinking data in place, with merged groups', () {
    testWidgets('does not throw', (tester) async {
      // The caller violates the documented contract -- the same list object,
      // mutated. That is a caller error and it is *documented* as one, but the
      // package throwing `RangeError` for it is not the documented outcome:
      // `itemCount` read the cached render-index list while the row build read
      // `data` live, and Flutter's own delegate range-guards the same read while
      // documenting the same obligation.
      final data = _rows(['0', '1', '2', '3', '4', '5']);
      final groups = [
        _group(const ['0', '1'])
      ];

      await _pump(tester, data: data, groups: groups);
      expect(tester.takeException(), isNull);

      data.removeWhere((r) => r['id'] == '5');
      await _pump(tester, data: data, groups: groups);

      expect(tester.takeException(), isNull,
          reason:
              'RangeError: itemCount came from the cached indices while the '
              'row build indexed the live, now-shorter list');
    });

    testWidgets('and the rows it still holds are the rows on screen',
        (tester) async {
      // Not throwing is not the same as being right. Without this the fix could
      // be a swallowed exception.
      final data = _rows(['0', '1', '2', '3', '4', '5']);
      final groups = [
        _group(const ['0', '1'])
      ];

      await _pump(tester, data: data, groups: groups);
      data.removeWhere((r) => r['id'] == '4');
      await _pump(tester, data: data, groups: groups);

      expect(_visible(tester), ['r0', 'r1', 'r2', 'r3', 'r5'],
          reason: 'r4 is gone from `data` and everything else is still drawn');
    });

    testWidgets('sorting in place is seen, and the length never changes',
        (tester) async {
      // The guard compares the *ids*, not the list length, and every other case
      // here shrinks the list — so a guard comparing only `length` passed the
      // whole suite. Measured, and the reason this test exists.
      //
      // **It needs a merged group to observe anything.** A first draft sorted a
      // plain table and asserted the rendered order, which passes either way:
      // rendering reads `widget.data[index]` live, so the screen is right even
      // when every cache behind it is stale. What goes stale is `RowLookup`'s
      // id -> index map, and a group is the thing that reads it.
      final data = _rows(['0', '1', '2', '3']);
      final groups = [
        _group(const ['0', '1'])
      ];

      await _pump(tester, data: data, groups: groups);
      expect(_visible(tester), ['r0', 'r1', 'r2', 'r3'],
          reason: 'the group is one render row and still draws both members');

      data.sort((a, b) => (b['id'] as String).compareTo(a['id'] as String));
      await _pump(tester, data: data, groups: groups);
      expect(tester.takeException(), isNull,
          reason:
              'a stale id -> index map after an in-place sort walks off the '
              'end of the reordered list');

      expect(_visible(tester), ['r3', 'r2', 'r0', 'r1'],
          reason: 'after the reversal the group sits at the end, anchored at '
              'r1(2), and stacks its members in rowKeys order. A stale '
              'id -> index map anchors it where it used to be and renders a '
              'different set entirely');
    });
  });

  testWidgets('the parent re-totals too, not only the body', (tester) async {
    // `FlutterTablePlusState` and `TablePlusBodyState` each hold the guard, and
    // removing it from the parent alone left the whole suite green — the same
    // shape as #128's `scale` term, load-bearing for one widget and covered by
    // nothing.
    //
    // What only the parent produces is `_cachedTotalDataHeight`, which decides
    // `needsVerticalScroll` and is handed back down. Counted at the screen: the
    // horizontal scrollbar is always built, so six rows in a 200px box give two
    // and two rows give one.
    final data = _rows(['0', '1', '2', '3', '4', '5']);

    await _pump(tester, data: data, groups: const [], tableHeight: 200);
    final overflowing = tester.widgetList(find.byType(Scrollbar)).length;
    expect(overflowing, greaterThan(0),
        reason: '6 rows of 40 plus a 40 header do not fit 200 — at 0 the '
            'fixture stopped overflowing and the assertion below is vacuous');

    data.removeWhere((r) => int.parse(r['id'] as String) > 1);
    await _pump(tester, data: data, groups: const [], tableHeight: 200);

    expect(tester.widgetList(find.byType(Scrollbar)).length, overflowing - 1,
        reason: 'the parent kept a total height computed from six rows, so the '
            'table still believed it needed to scroll');
  });
}
