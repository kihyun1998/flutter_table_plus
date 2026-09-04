import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/cells/editable_text_field.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_cell.dart';
import 'package:flutter_test/flutter_test.dart';

// #171. Six values the table painted had no field behind them: the column
// divider's colour and width, the member divider's colour, the empty-data
// placeholder's style, a merged group's "N rows" caption, and the editor's two
// error borders plus its resting border width.
//
// Every one of them is now `field ?? <what it drew before>`, which is the shape
// `summaryRowBackgroundColor` and `enabledBorderColor` already had in the same
// two classes — so the default is the *derivation*, not the colour it happens
// to produce, and a caller who moves `dividerColor` keeps the hierarchy between
// the three lines without restating any of it.
//
// **Each case is a pair.** A "reachable" assertion alone cannot fail usefully:
// a field wired to the wrong line still shows up somewhere, and a field wired
// to nothing looks identical to a field wired correctly whose default happens
// to match. So every reachability case is written against a control that pins
// what the same rendering does with the field unset, and the two use values
// nothing here would derive.
//
// `kThick` is deliberately far from every default. At 1.0 the row divider and
// the column divider's hardcoded 0.5 are close enough that a width assertion
// cannot distinguish "follows the theme" from "does not" — the same reason
// `merged_row_separator_ownership_test.dart` pins 4.0 and says so.

typedef Row = Map<String, dynamic>;

const Color kProbe = Color(0xFF00FF7F);
const Color kProbe2 = Color(0xFFFF00AA);
const double kThick = 7.0;

Map<String, TablePlusColumn<Row>> _columns() {
  final b = TableColumnsBuilder<Row>();
  for (final k in ['c0', 'c1']) {
    b.addColumn(
      k,
      TablePlusColumn<Row>(
        key: k,
        label: k.toUpperCase(),
        order: 0,
        width: 150,
        valueAccessor: (r) => r[k],
      ),
    );
  }
  return b.build();
}

List<Row> _rows(List<String> ids) => [
      for (final id in ids) {'id': id, 'c0': 'r$id', 'c1': 'x$id'}
    ];

Future<void> _pump(
  WidgetTester tester, {
  required TablePlusBodyTheme body,
  List<String> data = const ['a', 'b'],
  List<String>? groupKeys,
  bool selectable = false,
}) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 500,
          height: 900,
          child: FlutterTablePlus<Row>(
            columns: _columns(),
            data: _rows(data),
            rowId: (r) => r['id'] as String,
            isSelectable: selectable,
            mergedGroups: groupKeys == null
                ? const []
                : [
                    MergedRowGroup<Row>(
                      groupId: 'g',
                      rowKeys: groupKeys,
                      mergeConfig: const {},
                    ),
                  ],
            theme: TablePlusTheme(
              bodyTheme: body,
              headerTheme: const TablePlusHeaderTheme(height: 40),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The right [BorderSide] the cell showing [label] paints — the column rule.
///
/// Read off the cell's own box rather than off the theme, because a getter
/// agreeing with itself is not evidence that the value reaches paint.
BorderSide? _cellRight(WidgetTester tester, String label) {
  final boxes = find
      .descendant(
        of: find.ancestor(
            of: find.text(label), matching: find.byType(TablePlusCell<Row>)),
        matching: find.byType(Container),
      )
      .evaluate();
  for (final element in boxes) {
    final decoration = (element.widget as Container).decoration;
    if (decoration is! BoxDecoration) continue;
    final border = decoration.border;
    if (border is Border && border.right.style != BorderStyle.none) {
      return border.right;
    }
  }
  return null;
}

/// The bottom side the cell showing [label] is handed — the member rule.
BorderSide? _cellBottom(WidgetTester tester, String label) {
  final cell = find
      .ancestor(of: find.text(label), matching: find.byType(TablePlusCell<Row>))
      .evaluate()
      .first
      .widget as TablePlusCell<Row>;
  final side = cell.bottomSide;
  return side == null || side.style == BorderStyle.none ? null : side;
}

TextStyle? _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style;

/// The decoration the editor hands its [TextField], pumped directly.
///
/// Nothing here triggers a validation failure. The question #171 asks is
/// whether a caller can *name* the error colour, and the decoration carries
/// `errorBorder` whether or not one is showing — driving a real rejection would
/// be testing the validator, which is a different subject.
Future<InputDecoration> _editorDecoration(
  WidgetTester tester,
  TablePlusEditableTheme theme,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EditableTextField(
          column: TablePlusColumn<Row>(
            key: 'c0',
            label: 'C0',
            order: 0,
            valueAccessor: (r) => r['c0'],
          ),
          theme: theme,
          autofocus: false,
          onStopEditing: null,
        ),
      ),
    ),
  );
  return tester.widget<TextField>(find.byType(TextField)).decoration!;
}

BorderSide _side(InputBorder border) =>
    (border as OutlineInputBorder).borderSide;

void main() {
  const base = TablePlusBodyTheme(rowHeight: 60, dividerColor: kProbe2);

  group('the column divider is reachable (#171)', () {
    testWidgets('the control: unset, it is dividerColor at alpha 0.5 and 0.5px',
        (tester) async {
      await _pump(tester, body: base);

      final side = _cellRight(tester, 'ra');
      expect(side, isNotNull);
      expect(side!.color, kProbe2.withValues(alpha: 0.5),
          reason: 'the default is the derivation, so it tracks dividerColor');
      expect(side.width, 0.5);
    });

    testWidgets('dividerThickness still does NOT reach it', (tester) async {
      // The measured defect from the issue, kept as an assertion rather than
      // quietly fixed. Defaulting the column rule to `dividerThickness` would
      // change what every existing caller renders, and it is also the wrong
      // half of the seam to move blind: the header's half of this same line
      // reads `headerTheme.verticalDivider.thickness`, which defaults to 1.0.
      // The field below is what makes that choice possible to make and to
      // undo; making it is not this change.
      await _pump(tester, body: base.copyWith(dividerThickness: kThick));

      expect(_cellRight(tester, 'ra')!.width, 0.5);
    });

    testWidgets('both halves are settable', (tester) async {
      await _pump(
        tester,
        body: base.copyWith(
          verticalDividerColor: kProbe,
          verticalDividerThickness: kThick,
        ),
      );

      final side = _cellRight(tester, 'ra');
      expect(side!.color, kProbe,
          reason: 'set, it comes off the alpha derivation entirely');
      expect(side.width, kThick);
    });

    testWidgets('showVerticalDividers still wins over both', (tester) async {
      await _pump(
        tester,
        body: base.copyWith(
          showVerticalDividers: false,
          verticalDividerColor: kProbe,
          verticalDividerThickness: kThick,
        ),
      );

      expect(_cellRight(tester, 'ra'), isNull,
          reason: 'a new colour must not resurrect a line the caller turned '
              'off — the gate is above the derivation, not inside it');
    });
  });

  group('the member divider colour is reachable (#171)', () {
    testWidgets('the control: unset, it is dividerColor at alpha 0.3',
        (tester) async {
      await _pump(tester,
          body: base.copyWith(dividerThickness: kThick),
          data: ['a', 'b', 'c'],
          groupKeys: ['a', 'b']);

      final side = _cellBottom(tester, 'ra');
      expect(side, isNotNull);
      expect(side!.color, kProbe2.withValues(alpha: 0.3));
      expect(side.width, kThick,
          reason: 'the width already followed dividerThickness (#155), and a '
              'field for it is what would undo that');
    });

    testWidgets('set, it replaces the colour and leaves the width alone',
        (tester) async {
      await _pump(tester,
          body: base.copyWith(
            dividerThickness: kThick,
            memberDividerColor: kProbe,
          ),
          data: ['a', 'b', 'c'],
          groupKeys: ['a', 'b']);

      final side = _cellBottom(tester, 'ra');
      expect(side!.color, kProbe);
      expect(side.width, kThick);
    });
  });

  group('the two placeholder styles are reachable (#171)', () {
    testWidgets('empty data: the control is textStyle, grey and italic',
        (tester) async {
      await _pump(tester, body: base, data: const []);

      final style = _styleOf(tester, 'No data available');
      expect(style!.color, const Color(0xFF757575));
      expect(style.fontStyle, FontStyle.italic);
      expect(style.fontSize, base.textStyle.fontSize,
          reason: 'derived from textStyle, so it follows a recoloured or '
              'resized body without being restated');
    });

    testWidgets('empty data: set, the derivation is replaced whole',
        (tester) async {
      await _pump(tester,
          body: base.copyWith(
            emptyStateTextStyle: const TextStyle(fontSize: 30, color: kProbe),
          ),
          data: const []);

      final style = _styleOf(tester, 'No data available');
      expect(style!.color, kProbe);
      expect(style.fontSize, 30);
      expect(style.fontStyle, isNot(FontStyle.italic),
          reason: 'the field is the whole style, not a patch over the default '
              '— otherwise italic could not be turned off');
    });

    testWidgets('the N rows caption: control, then set', (tester) async {
      // rowHeight 90, not the 60 the rest of the file uses, and the reason is
      // the *second* pump rather than this one. A group's selection cell
      // stacks a checkbox, a 4px gap and this caption inside
      // `rowHeight * memberCount`, and the 22px probe caption below does not
      // fit two members of 60. Probed against a tree without this change: at
      // the caption's own 10px nothing overflows at 48, 56, 60 or 64, so this
      // is the fixture asking for a size no caller would, not a defect the
      // change introduced.
      final tall = base.copyWith(rowHeight: 90);
      await _pump(tester,
          body: tall,
          data: ['a', 'b', 'c'],
          groupKeys: ['a', 'b'],
          selectable: true);
      final control = _styleOf(tester, '2 rows');
      expect(control!.color, const Color(0xFF757575));
      expect(control.fontSize, 10);

      await _pump(tester,
          body: tall.copyWith(
            mergedRowCountTextStyle:
                const TextStyle(fontSize: 22, color: kProbe),
          ),
          data: ['a', 'b', 'c'],
          groupKeys: ['a', 'b'],
          selectable: true);
      final set = _styleOf(tester, '2 rows');
      expect(set!.color, kProbe);
      expect(set.fontSize, 22);
    });
  });

  group("the editor's error borders are reachable (#171)", () {
    testWidgets('the control: Material red, and the resting border at 1px',
        (tester) async {
      final d = await _editorDecoration(
          tester, const TablePlusEditableTheme(editingBorderWidth: 5));

      expect(_side(d.errorBorder!).color, const Color(0xFFEF5350));
      expect(_side(d.focusedErrorBorder!).color, const Color(0xFFE53935));
      expect(_side(d.enabledBorder!).width, 1.0,
          reason: 'editingBorderWidth is 5 here and does not reach the resting '
              'border — the half of that border that was never a field');
      expect(_side(d.errorBorder!).width, 1.0);
    });

    testWidgets('set, all four are the caller of the package to choose',
        (tester) async {
      final d = await _editorDecoration(
        tester,
        const TablePlusEditableTheme(
          errorBorderColor: kProbe,
          focusedErrorBorderColor: kProbe2,
          enabledBorderWidth: kThick,
          errorBorderWidth: 3.0,
        ),
      );

      expect(_side(d.errorBorder!).color, kProbe);
      expect(_side(d.focusedErrorBorder!).color, kProbe2);
      expect(_side(d.enabledBorder!).width, kThick);
      expect(_side(d.errorBorder!).width, 3.0);
    });
  });

  group('copyWith and scaledBy name every new field (#171)', () {
    // Per field, never by count. `scaledBy` dropped `rowTooltipTheme` in #50
    // and five `CheckboxStyle` fields in #116 by being a hand-list that was
    // complete on the day it was written.
    const body = TablePlusBodyTheme();
    const editable = TablePlusEditableTheme();

    test('body copyWith carries each new field', () {
      expect(body.copyWith(verticalDividerColor: kProbe).verticalDividerColor,
          kProbe);
      expect(
          body
              .copyWith(verticalDividerThickness: kThick)
              .verticalDividerThickness,
          kThick);
      expect(
          body.copyWith(memberDividerColor: kProbe).memberDividerColor, kProbe);
      expect(
          body
              .copyWith(emptyStateTextStyle: const TextStyle(fontSize: 30))
              .emptyStateTextStyle
              ?.fontSize,
          30);
      expect(
          body
              .copyWith(mergedRowCountTextStyle: const TextStyle(fontSize: 31))
              .mergedRowCountTextStyle
              ?.fontSize,
          31);
    });

    test('editable copyWith carries each new field', () {
      expect(
          editable.copyWith(errorBorderColor: kProbe).errorBorderColor, kProbe);
      expect(
          editable
              .copyWith(focusedErrorBorderColor: kProbe)
              .focusedErrorBorderColor,
          kProbe);
      expect(editable.copyWith(enabledBorderWidth: kThick).enabledBorderWidth,
          kThick);
      expect(
          editable.copyWith(errorBorderWidth: kThick).errorBorderWidth, kThick);
    });

    test('body scaledBy: an unset empty-state style needs no help', () {
      final s = body.scaledBy(2.0);
      expect(s.emptyStateTextStyle, isNull);
      expect(s.effectiveEmptyStateTextStyle.fontSize, 28,
          reason: 'it derives from textStyle, which the same call scaled — '
              'materialising it here would scale it twice');
    });

    test('body scaledBy: a set empty-state style scales once', () {
      final s = body
          .copyWith(emptyStateTextStyle: const TextStyle(fontSize: 20))
          .scaledBy(2.0);
      expect(s.effectiveEmptyStateTextStyle.fontSize, 40);
    });

    test('body scaledBy: the caption is materialised, not skipped', () {
      final s = body.scaledBy(2.0);
      expect(s.effectiveMergedRowCountTextStyle.fontSize, 20,
          reason: 'its default derives from no scaled field, so leaving it '
              'null would hold the caption at 10 while the table doubled');
      expect(s.effectiveMergedRowCountTextStyle.color, const Color(0xFF757575));
    });

    test('body scaledBy leaves the new colours and the divider width alone',
        () {
      final s = base
          .copyWith(
            verticalDividerColor: kProbe,
            verticalDividerThickness: kThick,
            memberDividerColor: kProbe2,
          )
          .scaledBy(2.0);
      expect(s.verticalDividerColor, kProbe);
      expect(s.memberDividerColor, kProbe2);
      expect(s.verticalDividerThickness, kThick,
          reason: 'divider thickness has never scaled and this one is not an '
              'exception — the family scales content, not rules');
    });

    test('editable scaledBy: unset border widths materialise and scale', () {
      final s = editable.scaledBy(2.0);
      expect(s.effectiveEnabledBorderWidth, 2.0);
      expect(s.effectiveErrorBorderWidth, 2.0);
      expect(s.editingBorderWidth, 4.0,
          reason: 'the sibling that already scaled — leaving the other two '
              'null is what held the resting border at a hairline');
    });

    test('editable scaledBy leaves the error colours alone', () {
      final s = editable
          .copyWith(errorBorderColor: kProbe, focusedErrorBorderColor: kProbe2)
          .scaledBy(2.0);
      expect(s.errorBorderColor, kProbe);
      expect(s.focusedErrorBorderColor, kProbe2);
    });
  });

  group('the width measurement follows the field too (#171)', () {
    // The one place this change could have broken something rather than only
    // added to it. A body cell's `Container` folds its right border into the
    // child's inset, so auto-fit has to add that width back or the column is
    // sized against space the glyphs never get (#156). The caller of the
    // calculator restated it as the literal `0.5`, which was correct exactly
    // while the divider's width was hardcoded to match — and stopped being
    // correct the moment `verticalDividerThickness` existed.
    //
    // Relational, because the absolute width is a font measurement. The delta
    // is not: it is the border width and nothing else.
    Future<double> autoFitWidth(
      WidgetTester tester,
      TablePlusBodyTheme body,
    ) async {
      double? reported;
      // Two columns, and the second one is why. With a single column the
      // table stretches it to the viewport and its resize handle lands at
      // x = 800 — off the right edge, where `tap` silently misses and the
      // callback never fires. The filler keeps the measured column's handle
      // inside the surface.
      final columns = (TableColumnsBuilder<Row>()
            ..addColumn(
              'name',
              TablePlusColumn<Row>(
                key: 'name',
                label: 'Name',
                order: 0,
                valueAccessor: (r) => r['c0'],
                width: 250,
                minWidth: 40,
                maxWidth: 600,
              ),
            )
            ..addColumn(
              'filler',
              TablePlusColumn<Row>(
                key: 'filler',
                label: 'Filler',
                order: 0,
                valueAccessor: (r) => r['c1'],
                width: 250,
              ),
            ))
          .build();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Row>(
              columns: columns,
              data: const [
                {'id': '1', 'c0': 'a value long enough to measure', 'c1': 'x'}
              ],
              rowId: (r) => r['id'] as String,
              resizable: true,
              theme: TablePlusTheme(bodyTheme: body),
              onColumnResized: (key, width) => reported = width,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final handle = find.byKey(const ValueKey('resize_name'));
      await tester.tap(handle);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(handle);
      await tester.pumpAndSettle();
      return reported!;
    }

    testWidgets('a thicker column divider widens the auto-fit by its own width',
        (tester) async {
      // 4 and 12 rather than the default and 8, because the calculator ceils:
      // against the same fractional text width, two *integer* insets differ by
      // exactly their difference, while 0.5 against 8 differs by 8.0 rather
      // than 7.5 and the assertion would be pinning the rounding.
      final thin = await autoFitWidth(
          tester, const TablePlusBodyTheme(verticalDividerThickness: 4.0));
      final thick = await autoFitWidth(
          tester, const TablePlusBodyTheme(verticalDividerThickness: 12.0));

      expect(thick - thin, closeTo(8.0, 0.001),
          reason: 'the border grew by 8, so the column must grow by 8 to leave '
              'the glyphs the same room. A measurement still saying 0.5 '
              'reports the same width for both');
    });

    testWidgets('turning the divider off takes the whole width back',
        (tester) async {
      final on = await autoFitWidth(
          tester, const TablePlusBodyTheme(verticalDividerThickness: 8.0));
      final off = await autoFitWidth(
          tester,
          const TablePlusBodyTheme(
              verticalDividerThickness: 8.0, showVerticalDividers: false));

      expect(on - off, closeTo(8.0, 0.001),
          reason: 'no line, no inset — the gate is read on the same side as '
              'the width');
    });
  });
}
