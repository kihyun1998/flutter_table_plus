import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_merged_row.dart';
import 'package:flutter_test/flutter_test.dart';

// #151. #135 replaced a group's `rowKeys.first` read with `_mergedGroupAnchor`
// — the earliest member `data` actually holds — and left the `rowKeys.last`
// read at the other end untouched. Two consumers were still answering
// positionally:
//
//   1  `isLastRow`, from `rowKeys.last`, which decides the group's own outer
//      border. `indexOf` returns null for a key `data` does not hold and the
//      WRONG index whenever `rowKeys` is not in `data` order.
//   2  `hoverData`, from `rowKeys.first`, which decides which row a hover
//      button represents — and returned null for a group whose first key names
//      an absent row, so the button vanished.
//
// **Both fixtures put `rowKeys` out of `data` order, which is the case #135
// legalised and neither of these had caught up with.** An absent key is the
// other half and is covered too. The two are different failures: out-of-order
// gives a wrong answer, absent gives none.
//
// The control matters here more than usual. `LastRowBorderBehavior.never` is
// the default, so "the group must not draw a bottom border" is also what a
// *correct* non-last group does when `showHorizontalDividers` is off — which is
// why every case pins the theme explicitly and asserts against a second
// rendering rather than against a remembered number.

typedef Emp = Map<String, dynamic>;

const double kT = 4.0;

Map<String, TablePlusColumn<Emp>> _columns() {
  final b = TableColumnsBuilder<Emp>();
  b.addColumn(
    'c0',
    TablePlusColumn<Emp>(
      key: 'c0',
      label: 'C0',
      order: 0,
      width: 200,
      valueAccessor: (r) => r['c0'],
    ),
  );
  return b.build();
}

List<Emp> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'c0': 'r$id'}
    ];

Future<void> _pump(
  WidgetTester tester, {
  required List<String> data,
  required List<String> rowKeys,
  bool hoverButtons = false,
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
          height: 900,
          child: FlutterTablePlus<Emp>(
            columns: _columns(),
            data: _rows(data),
            rowId: (r) => r['id'] as String,
            mergedGroups: [
              MergedRowGroup<Emp>(
                groupId: 'g',
                rowKeys: rowKeys,
                mergeConfig: const {},
              ),
            ],
            hoverButtonBuilder: hoverButtons
                ? (rowId, rowData) => Text('hover:${rowData['id']}')
                : null,
            theme: const TablePlusTheme(
              bodyTheme: TablePlusBodyTheme(
                rowHeight: 60,
                dividerThickness: kT,
              ),
              headerTheme: TablePlusHeaderTheme(height: 40),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The bottom side the **group's own container** paints, or null.
///
/// Targeted rather than inferred, and the first version of this was wrong in a
/// way worth keeping: it took the outermost decorated ancestor that had a
/// bottom side at all, which is the group container only while the group draws
/// one. When it does not — which is exactly the state these cases assert — the
/// walk falls through to a member cell's own separator and reports alpha 0.3
/// as if it were the group's boundary. Two different lines, one helper, and
/// the assertion would have been about whichever happened to exist.
BorderSide? _groupBottom(WidgetTester tester) {
  for (final element in find
      .descendant(
          of: find.byType(TablePlusMergedRow<Emp>),
          matching: find.byType(Container))
      .evaluate()) {
    final decoration = (element.widget as Container).decoration;
    if (decoration is! BoxDecoration) continue;
    // Depth-first, so the group's own container is the first decorated box
    // inside the merged row; everything after it is a cell.
    final border = decoration.border;
    if (border is! Border || border.bottom.style == BorderStyle.none) {
      return null;
    }
    return border.bottom;
  }
  return null;
}

void main() {
  group('a group is answered on the members it actually has (#151)', () {
    testWidgets('isLastRow: rowKeys out of data order', (tester) async {
      // The group covers every row, so it IS the last render row and the
      // default LastRowBorderBehavior.never forbids the border. Read
      // positionally, `rowKeys.last` is 'a' at index 0, which is not
      // `data.length - 1`, so the group reported itself as not-last and drew.
      await _pump(tester, data: ['a', 'b'], rowKeys: ['b', 'a']);

      expect(_groupBottom(tester), isNull,
          reason: 'the group is the last row whichever order its keys are '
              'written in, and never means never');
    });

    testWidgets('isLastRow: the control, same group in data order',
        (tester) async {
      await _pump(tester, data: ['a', 'b'], rowKeys: ['a', 'b']);

      expect(_groupBottom(tester), isNull,
          reason: 'the ordered fixture already passed before #151 — it is here '
              'so the assertion above cannot pass by asserting nothing');
    });

    testWidgets('isLastRow: a group that really is not last still draws',
        (tester) async {
      // The discriminating control. Without it, "returns null" passes for a
      // predicate hardwired to false.
      await _pump(tester, data: ['a', 'b', 'z'], rowKeys: ['b', 'a']);

      final edge = _groupBottom(tester);
      expect(edge, isNotNull,
          reason: 'row z follows the group, so the group owns a real boundary');
      expect(edge!.width, kT);
      expect(edge.color, const TablePlusBodyTheme().dividerColor,
          reason: 'and it is the ROW boundary at full alpha, not a member '
              'separator at 0.3 — the two are the same width and only the '
              'colour tells them apart');
    });

    testWidgets('isLastRow: rowKeys naming a row data does not hold',
        (tester) async {
      // `indexOf` returns null for 'ghost', and `null == data.length - 1` is
      // false — so the group reported not-last and drew a border it must not.
      await _pump(tester, data: ['a', 'b'], rowKeys: ['a', 'b', 'ghost']);

      expect(_groupBottom(tester), isNull,
          reason: 'the tail is the latest member that is present, and a key '
              'naming nothing is not a member');
    });

    testWidgets('hoverData: the first key names a row data does not hold',
        (tester) async {
      await _pump(tester,
          data: ['a', 'b'], rowKeys: ['ghost', 'a', 'b'], hoverButtons: true);

      await tester.startGesture(tester.getCenter(find.text('ra')),
          kind: PointerDeviceKind.mouse);
      await tester.pump();

      expect(find.text('hover:a'), findsOneWidget,
          reason: 'the button used to vanish entirely: hoverData read '
              'rowKeys.first, resolved nothing, and the builder was never '
              'called — while _buildStackedCells beside it already filtered to '
              'the members present');
    });

    testWidgets('hoverData: the control, every key present', (tester) async {
      await _pump(tester,
          data: ['a', 'b'], rowKeys: ['a', 'b'], hoverButtons: true);

      await tester.startGesture(tester.getCenter(find.text('ra')),
          kind: PointerDeviceKind.mouse);
      await tester.pump();

      expect(find.text('hover:a'), findsOneWidget,
          reason: 'unchanged when nothing is absent — the fix adds a fallback, '
              'it does not move the ordinary answer');
    });
  });
}
