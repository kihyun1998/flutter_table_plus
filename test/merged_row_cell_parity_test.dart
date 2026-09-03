import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #155. The merged row draws its own cells instead of reusing the ordinary one,
// so every decision the ordinary cell makes exists twice and the copy drifted.
//
// The control is the whole test, exactly as in `merged_row_member_heights_test`:
// the same rows are rendered TWICE, once inside a group and once not, and the
// grouped run is asserted against the ungrouped one. The expected value is
// produced by a different code path, never written down here — so these
// assertions cannot be satisfied by making both sides wrong the same way.
//
// `kT` is deliberately NOT the default. At `dividerThickness: 1.0` the hardcoded
// literal in the merged row and the theme's value are the same number, and every
// assertion about the horizontal divider becomes unfailable. That is this repo's
// own lesson from #121, where a tolerance happened to equal the default
// thickness and hid the error it was meant to catch.
const double kT = 4.0;

typedef Row = Map<String, dynamic>;

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
      // Both this and the table's `isEditable` must be true. Without it the tap
      // in the editing case does nothing, no `EditableText` is ever built, and
      // the assertion below fails because it found NOTHING rather than because
      // the border was removed — a red that proves the opposite of what it
      // claims. Measured: that is exactly how this test first failed.
      editable: true,
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
  bool isEditable = false,
  bool showVerticalDividers = true,
  bool showHorizontalDividers = true,
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
              isEditable: isEditable,
              theme: TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(
                  rowHeight: 40,
                  dividerThickness: kT,
                  showVerticalDividers: showVerticalDividers,
                  showHorizontalDividers: showHorizontalDividers,
                ),
                headerTheme: const TablePlusHeaderTheme(height: 40),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A group over every id in [ids], merging nothing — so every column renders
/// through the STACKED branch, which is the branch under test.
List<MergedRowGroup<Row>> _groupOf(List<String> ids) => [
      MergedRowGroup<Row>(
        groupId: 'g',
        rowKeys: ids,
        mergeConfig: const {},
      ),
    ];

/// The border the cell itself paints around the glyphs of [label].
///
/// Walks up from the glyphs rather than looking for a widget type: anchoring on
/// `TablePlusCell` would break the day the widget is swapped and would pass
/// while the drawn result was wrong, which is the wrong way round (#62).
///
/// Two ancestors legitimately draw a side — the cell's border and the row's
/// `rowDecoration` bottom — and `find.ancestor` yields nearest-first (verified
/// against `flutter_test`'s `_AncestorFinderMixin`), so the innermost is the
/// cell's. What identifies it is [expectRight]: `rowDecoration` composes a
/// bottom and never a right, so a border with a right side is the cell's and
/// nothing else's.
///
/// **Known limit, stated rather than papered over.** This is stable against a
/// refactor that moves decoration outward and not against one that adds a
/// decorated box *inside* the cell — a hover wash, a focus ring — which would
/// become the innermost answer. Pinning the *count* of side-drawing ancestors
/// was tried and abandoned: the grouped and ungrouped trees produce different
/// counts for reasons this run did not chase, and a guard whose expected value
/// nobody can explain is a guard that gets edited until it passes.
Border? _cellBorder(WidgetTester tester, String label,
    {bool expectRight = true}) {
  final borders = tester
      .widgetList<Container>(
        find.ancestor(of: find.text(label), matching: find.byType(Container)),
      )
      .map((c) => c.decoration)
      .whereType<BoxDecoration>()
      .map((d) => d.border)
      .whereType<Border>()
      .where((b) =>
          b.right.style != BorderStyle.none ||
          b.bottom.style != BorderStyle.none ||
          b.top.style != BorderStyle.none)
      .toList();
  if (borders.isEmpty) return null;
  final innermost = borders.first;
  if (expectRight) {
    expect(innermost.right.style, isNot(BorderStyle.none),
        reason: 'the innermost side-drawing ancestor of "$label" has no right '
            'side, so it is not the cell — `rowDecoration` composes a bottom '
            'and never a right. Every assertion below would be reading the '
            'wrong box');
  }
  return innermost;
}

void main() {
  group('a member cell is decorated like the same row outside a group', () {
    testWidgets('the vertical divider is the theme\'s, not a literal',
        (tester) async {
      // Ungrouped control first: whatever the ordinary cell draws is the
      // expected value, and this test never writes that number down.
      await _pump(tester, data: _rows(['a', 'b', 'c']), groups: const []);
      final ungrouped = _cellBorder(tester, 'ra');
      expect(ungrouped, isNotNull,
          reason: 'the control found no decorated cell — the harness is wrong, '
              'not the code');

      await _pump(
        tester,
        data: _rows(['a', 'b', 'c']),
        groups: _groupOf(['a', 'b', 'c']),
      );
      final grouped = _cellBorder(tester, 'ra');
      expect(grouped, isNotNull);

      // The discriminating assertion, and it is NOT the parity comparison.
      //
      // Parity alone was written first and measured worthless the moment the
      // fix landed: once both paths are the same widget, breaking that widget
      // breaks BOTH sides and `grouped == ungrouped` still holds. Mutation
      // check, run: replacing the cell's `theme.verticalDividerSide` with a
      // hardcoded `BorderSide(width: 1)` left all three tests green. That is
      // `redden`'s shared-wrong-model pattern — the control is drawn by the
      // code under test, so it cannot discriminate.
      //
      // The theme is the authority for a divider's width and nothing in the
      // cell path draws it, so this one reddens when the cell stops reading it.
      const expected = TablePlusBodyTheme(dividerThickness: kT);
      expect(
        grouped!.right.width,
        expected.verticalDividerSide.width,
        reason: 'a member cell hand-built its right divider at width 1 while '
            'theme.verticalDividerSide is 0.5 — twice as thick, at the '
            'DEFAULT theme',
      );
      // The alpha is written HERE, not read back off the same getter: an
      // expectation derived by the code under test cannot fail with it.
      expect(grouped.right.color,
          const TablePlusBodyTheme().dividerColor.withValues(alpha: 0.5));

      // Kept as a weaker second assertion: it can no longer catch a shared
      // error, but it still catches the two paths DIVERGING again, which is
      // the whole subject of this issue.
      expect(grouped.right.width, ungrouped!.right.width);
      expect(grouped.right.color, ungrouped.right.color);
    });

    testWidgets('the member separator follows theme.dividerThickness',
        (tester) async {
      // The group must NOT be the last row. Written first with the group
      // covering every row, this measured 0.0 rather than the hardcoded 1.0 --
      // because a member's separator is gated on the GROUP's `isLastRow`, and
      // at the default `LastRowBorderBehavior.never` the last group's members
      // lose their separators entirely. That is a real defect and it is not
      // this assertion's; it is recorded as a candidate. Keeping the group off
      // the last row is what lets this assertion measure the width it names.
      await _pump(
        tester,
        data: _rows(['a', 'b', 'c', 'd']),
        groups: _groupOf(['a', 'b', 'c']),
      );
      final grouped = _cellBorder(tester, 'ra');
      expect(grouped, isNotNull);

      const expected = TablePlusBodyTheme(dividerThickness: kT);
      expect(
        grouped!.bottom.width,
        expected.memberDividerSide.width,
        reason: 'the separator between two members hardcoded width: 1 while '
            'every other row divider reads theme.dividerThickness. At the '
            'default 1.0 those are the same number and this cannot fail, '
            'which is why kT is 4.0',
      );
      // Width alone left the colour unpinned: alpha 0.3 -> 1.0 was green.
      expect(grouped.bottom.color,
          const TablePlusBodyTheme().dividerColor.withValues(alpha: 0.3));
    });

    testWidgets('the summary cell is decorated like the members beside it',
        (tester) async {
      // Written because both adversarial passes reached it independently: the
      // first version of this change converted the member cells and left
      // `_buildSummaryRowCell` on its literals, so the members drew 0.5 and the
      // summary drew 1.0 in the same column — a visible step in the vertical
      // rule at every expanded group's boundary, INTRODUCED by the fix.
      await _pump(
        tester,
        data: _rows(['a', 'b', 'c', 'd']),
        groups: [
          MergedRowGroup<Row>(
            groupId: 'g',
            rowKeys: const ['a', 'b', 'c'],
            mergeConfig: const {},
            isExpanded: true,
            summaryBuilder: (_) => const Text('sum'),
          ),
        ],
      );

      final member = _cellBorder(tester, 'ra');
      final summary = _cellBorder(tester, 'sum');
      expect(member, isNotNull);
      expect(summary, isNotNull,
          reason: 'the summary row did not render — the control is broken, not '
              'the code');

      expect(summary!.right.width, member!.right.width);
      expect(summary.right.color, member.right.color);
      expect(summary.bottom.width, member.bottom.width);
      expect(summary.bottom.color, member.bottom.color);
    });

    testWidgets('turning horizontal dividers off removes the member separator',
        (tester) async {
      // Protects the gate itself. Without this, deleting `_memberBottomSide`'s
      // call and passing `theme.memberDividerSide` unconditionally left every
      // other test green — measured. That gate is the one carrying a known
      // level error, so leaving it unpinned would let a later change delete it
      // and look correct.
      await _pump(
        tester,
        data: _rows(['a', 'b', 'c', 'd']),
        groups: _groupOf(['a', 'b', 'c']),
        showHorizontalDividers: false,
      );
      final b = _cellBorder(tester, 'ra');
      expect(b?.bottom.style ?? BorderStyle.none, BorderStyle.none);
    });

    testWidgets('turning vertical dividers off leaves the cell undecorated',
        (tester) async {
      // Pins `_composeBorder`'s null return. Replacing its body with an
      // unconditional `Border(...)` was green everywhere before this existed.
      await _pump(
        tester,
        data: _rows(['a', 'b', 'c', 'd']),
        groups: _groupOf(['a', 'b', 'c']),
        showVerticalDividers: false,
        showHorizontalDividers: false,
      );
      // Read the raw decoration, not `_cellBorder`: that helper filters
      // all-none borders away, so it reports `null` for a `Border` with every
      // side none — which is exactly the mutation this test exists to catch.
      final decorations = tester
          .widgetList<Container>(
            find.ancestor(
                of: find.text('ra'), matching: find.byType(Container)),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .toList();
      expect(decorations, isNotEmpty,
          reason: 'no decorated ancestor at all — the harness is wrong');
      expect(decorations.first.border, isNull,
          reason: '_composeBorder must return null when it has nothing to '
              'draw, rather than a Border whose every side is none');
    });
  });

  group('editing does not remove the divider', () {
    testWidgets('an ordinary cell keeps its vertical divider while editing',
        (tester) async {
      // The maintainer's call, 2026-09-03: the line must not disappear.
      // pluto_grid agrees — it branches on isCurrentCell, never on isEditing.
      await _pump(
        tester,
        data: _rows(['a', 'b', 'c']),
        groups: const [],
        isEditable: true,
      );
      final before = _cellBorder(tester, 'ra');
      expect(before, isNotNull);
      expect(before!.right.style, isNot(BorderStyle.none));

      await tester.tap(find.text('ra'));
      await tester.pumpAndSettle();

      // The side condition, asserted rather than assumed. If editing never
      // started there is no editor to find an ancestor of, and the assertion
      // below would report "no bordered container" while measuring nothing.
      expect(find.byType(EditableText), findsOneWidget,
          reason: 'the tap did not start editing — the assertion below would '
              'be vacuous');

      // The glyphs move into a TextField but the cell is still decorated.
      final editing = tester
          .widgetList<Container>(
            find.ancestor(
              of: find.byType(EditableText),
              matching: find.byType(Container),
            ),
          )
          .where((c) {
            final d = c.decoration;
            return d is BoxDecoration && d.border is Border;
          })
          .map((c) => (c.decoration! as BoxDecoration).border! as Border)
          .where((b) => b.right.style != BorderStyle.none);

      expect(
        editing,
        isNotEmpty,
        reason: 'the ordinary cell clears its border while isCellEditing, so '
            'the divider vanishes mid-edit. The maintainer ruled that a '
            'defect, not a contract',
      );
    });
  });
}
