import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #121. A merged group's TOTAL height is the sum of its members' measured
// heights and always was. What the members are then DRAWN at was the total
// divided equally, because `_buildStackedCells` laid each cell out in an
// `Expanded` -- `Flexible(fit: FlexFit.tight)`, whose tight children are forced
// to the extent the flex division allocated (`rendering/flex.dart`:
// `FlexFit.tight => minChildExtent = maxChildExtent`).
//
// The control is the whole test. A group of 48/96/48 is SYMMETRIC, so a correct
// layout also produces evenly spaced text tops -- 24 / 96 / 168 as centres,
// differences 72 and 72. An assertion that members are "evenly spaced" passes
// under both behaviours. So every case here renders the same data twice, once
// grouped and once not, and asserts the grouped run against the ungrouped one.
// The expected value is drawn by a different code path, not by this test.

typedef Row = Map<String, dynamic>;

/// The divider thickness every case pins, and the size of the only residual
/// this fix leaves behind.
const double kT = 4.0;

Map<String, TablePlusColumn<Row>> _columns() {
  final b = TableColumnsBuilder<Row>();
  b.addColumn(
    'c0',
    TablePlusColumn<Row>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 200,
    ),
  );
  return b.build();
}

List<Row> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'c0': 'r$id'}
    ];

Future<void> _pump(
  WidgetTester tester, {
  required List<Row> data,
  required List<MergedRowGroup<Row>> groups,
  double? Function(int, Row)? calculateRowHeight,
}) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: FlutterTablePlus<Row>(
              columns: _columns(),
              data: data,
              rowId: (r) => r['id'] as String,
              mergedGroups: groups,
              calculateRowHeight: calculateRowHeight,
              theme: const TablePlusTheme(
                // PINNED, and load-bearing. Every assertion below is stated in
                // terms of this number: the group's bottom border is taken out
                // of the `Column` the members are laid out in, so the last
                // member is short by exactly `dividerThickness` and its centred
                // text sits half that high. Leave it to the default and the
                // assertions read as if they had slack.
                bodyTheme:
                    TablePlusBodyTheme(rowHeight: 40, dividerThickness: kT),
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

/// Each visible `c0` cell's text top, relative to the body's `ListView`.
/// Position rather than widget identity, following the #135 harness.
Map<String, double> _tops(WidgetTester tester, List<String> ids) {
  final listTop = tester.getRect(find.byType(ListView)).top;
  return {
    for (final id in ids) id: tester.getRect(find.text('r$id')).top - listTop,
  };
}

/// Every member except the last lands **exactly** where its ungrouped twin
/// does; the last is high by half the group's bottom border, because that
/// border is taken out of the `Column` and sits against that member.
///
/// Stated as two assertions rather than one loose tolerance on purpose. The
/// first version of this test allowed 1.0px on every member, which is the same
/// number as the default `dividerThickness` — so it passed under a proportional
/// layout that moved all three members, by up to 0.87px. A tolerance equal to
/// the error it is meant to catch is not a tolerance, it is a blindfold.
void expectMembersMatchUngrouped(
  Map<String, double> grouped,
  Map<String, double> ungrouped,
  List<String> members,
) {
  for (final id in members.sublist(0, members.length - 1)) {
    expect(grouped[id], closeTo(ungrouped[id]!, 0.05),
        reason: 'member $id is drawn exactly where an ungrouped row of the '
            'same measured height is drawn');
  }
  final last = members.last;
  expect(ungrouped[last]! - grouped[last]!, closeTo(kT / 2, 0.05),
      reason: 'the last member is short by exactly the group border, and its '
          'centred text by half of it — the border has to come from somewhere '
          'and this is the one cell adjacent to it');
}

MergedRowGroup<Row> _group(List<String> keys, {bool expanded = false}) =>
    MergedRowGroup<Row>(
      groupId: 'g0',
      rowKeys: keys,
      mergeConfig: const {},
      isExpanded: expanded,
    );

void main() {
  group('a merged group draws its members at their own measured heights', () {
    testWidgets('differing heights: grouped matches ungrouped, cell for cell',
        (tester) async {
      final data = _rows(['a', 'b', 'c', 'z']);
      const h = {'a': 48.0, 'b': 96.0, 'c': 48.0, 'z': 48.0};
      double? height(int i, Row r) => h[r['id']];

      await _pump(tester,
          data: data, groups: const [], calculateRowHeight: height);
      final ungrouped = _tops(tester, ['a', 'b', 'c', 'z']);

      await _pump(tester,
          data: data,
          groups: [
            _group(['a', 'b', 'c'])
          ],
          calculateRowHeight: height);
      final grouped = _tops(tester, ['a', 'b', 'c', 'z']);

      expectMembersMatchUngrouped(grouped, ungrouped, ['a', 'b', 'c']);
    });

    // Which mutation reddens this, and which does NOT, was measured rather than
    // assumed -- and the answer relocated the assertion's subject.
    //
    // `mergedHeight = totalHeight + 10` in the body leaves this GREEN. That
    // number becomes the group's `calculatedHeight`, and the group's slot in the
    // list is allocated by a SECOND derivation, `_getMergedGroupExtent`; the
    // slot then clamps the Container, so a wrong `calculatedHeight` never
    // reaches the rendered rect. Asserting the group's own height instead was
    // green for the same reason -- vacuous, and removed rather than kept.
    //
    // `_getMergedGroupExtent` returning `total + 10` DOES redden it: `rz` moves
    // 206.0 -> 216.0. So this guards the derivation that actually owns the
    // total, which is the one a differently-shaped fix would have reached for.
    testWidgets('the group total is unchanged — the row after it does not move',
        (tester) async {
      final data = _rows(['a', 'b', 'c', 'z']);
      const h = {'a': 48.0, 'b': 96.0, 'c': 48.0, 'z': 48.0};
      double? height(int i, Row r) => h[r['id']];

      await _pump(tester,
          data: data, groups: const [], calculateRowHeight: height);
      final ungrouped = _tops(tester, ['z']);

      await _pump(tester,
          data: data,
          groups: [
            _group(['a', 'b', 'c'])
          ],
          calculateRowHeight: height);
      final grouped = _tops(tester, ['z']);

      expect(grouped['z'], closeTo(ungrouped['z']!, 0.05),
          reason: 'the total was already correct; only the distribution moves');
    });

    testWidgets('a member `data` does not hold: the present ones still align',
        (tester) async {
      // #135's equivalence, which this fix must not silently re-break: the
      // height list and the cell list skip the same keys.
      final data = _rows(['a', 'c', 'z']); // 'b' is named by the group, absent
      const h = {'a': 48.0, 'c': 96.0, 'z': 48.0};
      double? height(int i, Row r) => h[r['id']];

      await _pump(tester,
          data: data, groups: const [], calculateRowHeight: height);
      final ungrouped = _tops(tester, ['a', 'c', 'z']);

      await _pump(tester,
          data: data,
          groups: [
            _group(['a', 'b', 'c'])
          ],
          calculateRowHeight: height);
      final grouped = _tops(tester, ['a', 'c', 'z']);

      expectMembersMatchUngrouped(grouped, ungrouped, ['a', 'c']);
      expect(grouped['z'], closeTo(ungrouped['z']!, 0.05),
          reason: 'the row after the group is outside it and moves not at all');
    });

    testWidgets('no height callback: unchanged, and the equal split is correct',
        (tester) async {
      final data = _rows(['a', 'b', 'c', 'z']);

      await _pump(tester, data: data, groups: const []);
      final ungrouped = _tops(tester, ['a', 'b', 'c', 'z']);

      await _pump(tester, data: data, groups: [
        _group(['a', 'b', 'c'])
      ]);
      final grouped = _tops(tester, ['a', 'b', 'c', 'z']);

      // No heights are known, so every cell is flexible and the group is
      // divided equally — right when the rows are equal, and byte-for-byte the
      // pre-#121 code path.
      //
      // The claim here is EQUAL DIVISION, not agreement with the ungrouped
      // rendering, and the difference is not pedantry: an equal split also
      // absorbs the group's bottom border across all three members, so each one
      // sits 0.17px high. That is pre-existing and is what "unchanged" means
      // for this case. Asserting agreement with the ungrouped rows instead
      // would demand of the old path something this fix never promised — and
      // would only pass on a tolerance wide enough to hide the residual it is
      // supposed to be measuring.
      expect(grouped['b']! - grouped['a']!,
          closeTo(grouped['c']! - grouped['b']!, 0.05),
          reason: 'the three members are divided equally');
      for (final id in ['a', 'b', 'c']) {
        expect((ungrouped[id]! - grouped[id]!).abs(), lessThanOrEqualTo(kT),
            reason: 'and no member is off its ungrouped twin by more than the '
                'group border, which is the whole of what the split absorbs');
      }
      expect(grouped['z'], closeTo(ungrouped['z']!, 0.05),
          reason: 'the total is untouched');
    });

    // The refuting pass found this uncovered across all 57 test files, and it
    // is the largest single behaviour change here: the summary row is drawn at
    // `theme.rowHeight` while the members keep their own measurements, so an
    // expanded group of equal members changes even though an unexpanded one
    // does not. Before this fix all four cells were one quarter of the total.
    testWidgets(
        'an expanded group: members keep their heights, the summary row '
        'takes theme.rowHeight', (tester) async {
      final data = _rows(['a', 'b', 'z']);
      const h = {'a': 96.0, 'b': 96.0, 'z': 48.0};
      double? height(int i, Row r) => h[r['id']];

      await _pump(tester,
          data: data, groups: const [], calculateRowHeight: height);
      final ungrouped = _tops(tester, ['a', 'b']);

      await _pump(tester,
          data: data,
          groups: [
            _group(['a', 'b'], expanded: true)
          ],
          calculateRowHeight: height);
      final grouped = _tops(tester, ['a', 'b']);

      // Both members are non-last here — the summary row is the last cell, so
      // it is the one that absorbs the border, and both members land exactly.
      for (final id in ['a', 'b']) {
        expect(grouped[id], closeTo(ungrouped[id]!, 0.05),
            reason: 'member $id keeps its own 96, and does not become '
                '(96+96+40)/3 as an equal split would make it');
      }
    });
  });
}
