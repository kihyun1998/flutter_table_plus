import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_cell.dart';
import 'package:flutter_test/flutter_test.dart';

// #157. A member's separator was gated on the GROUP's `isLastRow` — a row-level
// question deciding a member-level line — and one substitution produced two
// opposite symptoms: with the group not last every member drew including the
// last, whose line then sat against the group's own border; with the group last
// the default `LastRowBorderBehavior.never` silenced every member and the group
// rendered as one undivided block.
//
// The repair gives every boundary exactly one owner: a group's inner boundaries
// belong to its members, its outer boundary belongs to the group's own
// decoration. **So these assert who draws, not how it looks.** Comparing one
// side against another cannot state the defect — before the fix the two lines
// at a doubled edge had different colours and widths, so an equality assertion
// between them passed while both were painted.
//
// Counting lines "at a y" was tried first and does not work: a `Container`
// folds its border into the child's inset, so the group's border sits
// `dividerThickness` BELOW the last member's cell rect rather than on it. The
// two lines are adjacent, not coincident, which is what makes a doubled edge
// read as one heavier rule instead of as a mistake.
//
// `kT` is deliberately NOT the default. At `dividerThickness: 1.0` the member
// separator and the row divider are the same width, and a doubled edge is
// unmeasurable — the same lesson #121 recorded about a tolerance equal to the
// error it was meant to catch.

typedef Row = Map<String, dynamic>;

const double kT = 4.0;

Map<String, TablePlusColumn<Row>> _columns() {
  final b = TableColumnsBuilder<Row>();
  b.addColumn(
    'c0',
    TablePlusColumn<Row>(
      key: 'c0',
      label: 'C0',
      order: 0,
      width: 200,
      valueAccessor: (r) => r['c0'],
    ),
  );
  return b.build();
}

List<Row> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'c0': 'r$id'}
    ];

Future<void> _pump(
  WidgetTester tester, {
  required List<String> data,
  List<String>? groupKeys,
  bool summary = false,
  bool horizontalDividers = true,
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
          child: FlutterTablePlus<Row>(
            columns: _columns(),
            data: _rows(data),
            rowId: (r) => r['id'] as String,
            mergedGroups: groupKeys == null
                ? const []
                : [
                    MergedRowGroup<Row>(
                      groupId: 'g',
                      rowKeys: groupKeys,
                      mergeConfig: const {},
                      isExpanded: summary,
                      summaryBuilder: summary ? (_) => const Text('sum') : null,
                    ),
                  ],
            theme: TablePlusTheme(
              bodyTheme: TablePlusBodyTheme(
                rowHeight: 60,
                dividerThickness: kT,
                showHorizontalDividers: horizontalDividers,
              ),
              headerTheme: const TablePlusHeaderTheme(height: 40),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The bottom side the cell showing [label] paints itself, or null.
///
/// A member cell is the only cell in the package handed a `bottomSide`, so this
/// is the member half of the ownership rule.
BorderSide? _cellBottom(WidgetTester tester, String label) {
  final cell = find
      .ancestor(of: find.text(label), matching: find.byType(TablePlusCell<Row>))
      .evaluate()
      .first
      .widget as TablePlusCell<Row>;
  final side = cell.bottomSide;
  return side == null || side.style == BorderStyle.none ? null : side;
}

/// The top side the cell showing [label] paints, or null. Only the summary cell
/// ever had one.
BorderSide? _cellTop(WidgetTester tester, String label) {
  for (final element in find
      .ancestor(of: find.text(label), matching: find.byType(Container))
      .evaluate()) {
    final decoration = (element.widget as Container).decoration;
    if (decoration is! BoxDecoration) continue;
    final border = decoration.border;
    if (border is Border && border.top.style != BorderStyle.none) {
      return border.top;
    }
  }
  return null;
}

/// The bottom side painted by the outermost decorated box around [label] — the
/// row or group container, which owns the boundary between rows.
BorderSide? _rowBottom(WidgetTester tester, String label) {
  BorderSide? outermost;
  for (final element in find
      .ancestor(of: find.text(label), matching: find.byType(Container))
      .evaluate()) {
    final decoration = (element.widget as Container).decoration;
    if (decoration is! BoxDecoration) continue;
    final border = decoration.border;
    if (border is Border && border.bottom.style != BorderStyle.none) {
      outermost = border.bottom;
    }
  }
  return outermost;
}

void main() {
  const themed = TablePlusBodyTheme(dividerThickness: kT);

  group('one owner per boundary (#157)', () {
    testWidgets('a group that is not last draws one line at its bottom edge',
        (tester) async {
      await _pump(tester,
          data: ['a', 'b', 'c', 'd'], groupKeys: ['a', 'b', 'c']);

      expect(_cellBottom(tester, 'rc'), isNull,
          reason: 'the last member used to draw here too, so the edge was the '
              'member separator at alpha 0.3 with the group border at full '
              'dividerColor immediately below it');
      final edge = _rowBottom(tester, 'rc');
      expect(edge, isNotNull);
      expect(edge!.color, const TablePlusBodyTheme().dividerColor,
          reason: 'the surviving line is the group boundary, and a group '
              'boundary is a row boundary — it is drawn like every other one');
      expect(edge.width, kT);
    });

    testWidgets('the control: a plain row boundary has one owner too',
        (tester) async {
      await _pump(tester, data: ['a', 'b', 'c', 'd']);

      expect(_cellBottom(tester, 'rc'), isNull,
          reason: 'a plain cell is never handed a bottomSide — the row owns '
              'that edge, which is the arrangement the group now matches');
      final edge = _rowBottom(tester, 'rc');
      expect(edge, isNotNull);
      expect(edge!.color, const TablePlusBodyTheme().dividerColor);
      expect(edge.width, kT);
    });

    testWidgets('a group that IS the last row still separates its members',
        (tester) async {
      await _pump(tester, data: ['a', 'b', 'c'], groupKeys: ['a', 'b', 'c']);

      final between = _cellBottom(tester, 'ra');
      expect(between, isNotNull,
          reason: 'at the default LastRowBorderBehavior.never the old gate '
              'returned false for EVERY member, so the whole group rendered as '
              'one undivided block');
      expect(between!.width, themed.memberDividerSide.width);
      expect(between.color, themed.memberDividerSide.color);

      expect(_cellBottom(tester, 'rc'), isNull,
          reason: 'and the last member still draws nothing — nothing follows '
              'it, exactly as for a plain last row');
      expect(_rowBottom(tester, 'rc'), isNull,
          reason: 'nor does the group, because LastRowBorderBehavior.never '
              'still governs its own outer edge');
    });

    testWidgets('the summary boundary draws one line, not two', (tester) async {
      await _pump(tester,
          data: ['a', 'b', 'c', 'd'],
          groupKeys: ['a', 'b', 'c'],
          summary: true);

      final above = _cellBottom(tester, 'rc');
      expect(above, isNotNull,
          reason: 'the summary follows the last member, so the member draws');
      expect(above!.width, kT);

      expect(_cellTop(tester, 'sum'), isNull,
          reason: 'and the summary does not draw the same boundary a second '
              'time. It used to, hardcoded at 0.5px and ungated, so this one '
              'boundary painted 4px + 0.5px where every other member boundary '
              'painted 4px');
    });

    testWidgets('showHorizontalDividers still silences every member',
        (tester) async {
      await _pump(tester,
          data: ['a', 'b', 'c', 'd'],
          groupKeys: ['a', 'b', 'c'],
          horizontalDividers: false);

      expect(_cellBottom(tester, 'ra'), isNull);
      expect(_cellBottom(tester, 'rb'), isNull);
    });
  });
}
