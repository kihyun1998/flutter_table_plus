import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A row tooltip's hover region is the whole row; its anchor is the pointer.
// Those two must not be the same rect — a row is as wide as the table's content,
// which can far exceed the viewport, so anchoring to the row would aim at a
// point the user never pointed at.
//
// A cell that has a tooltip of its own wins over the row card: exactly one
// tooltip is visible, the innermost under the pointer.

const _card = 'CARD';
const _full = 'FULL';

const _rows = [
  {'id': '1', 'name': 'A', 'note': 'a value long enough to be cut off'},
];

Future<void> _hoverAt(WidgetTester tester, Offset location) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();

  await mouse.moveTo(location);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Widget _table({
  required Map<String, TablePlusColumn<Map<String, dynamic>>> columns,
  bool withCard = true,
  TablePlusTheme theme = const TablePlusTheme(),
  double scale = 1.0,
  List<Map<String, dynamic>> data = _rows,
  void Function(String rowId, bool isSelected)? onRowSelectionChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        columns: columns,
        data: data,
        rowId: (r) => r['id'] as String,
        theme: theme,
        scale: scale,
        isSelectable: onRowSelectionChanged != null,
        onRowSelectionChanged: onRowSelectionChanged,
        rowTooltipBuilder: withCard ? (context, r) => const Text(_card) : null,
      ),
    ),
  );
}

TablePlusColumn<Map<String, dynamic>> _col(
  String key, {
  double width = 400,
  double? maxWidth,
  TooltipBehavior behavior = TooltipBehavior.never,
  String Function(Map<String, dynamic>)? tooltipFormatter,
}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: key,
    order: 0,
    valueAccessor: (r) => r[key],
    width: width,
    maxWidth: maxWidth,
    tooltipBehavior: behavior,
    tooltipFormatter: tooltipFormatter,
  );
}

void main() {
  testWidgets('the card shows on the blank part of a row', (tester) async {
    await tester.pumpWidget(_table(columns: {'name': _col('name')}));

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsOneWidget);
  });

  testWidgets('the card shows over a cell whose value is empty',
      (tester) async {
    // An empty cell's Text is zero-wide, so nothing under the pointer is hit —
    // but the row's MouseRegion is opaque and hit-tests itself, so the whole
    // row stays the hover region. The cell itself has no tooltip to win with:
    // TooltipResolver gates a *text* tooltip on non-empty text.
    await tester.pumpWidget(_table(
      columns: {
        'name': _col('name'),
        'note': _col('note', behavior: TooltipBehavior.onlyTextOverflow),
      },
      data: const [
        {'id': '1', 'name': 'A', 'note': ''},
      ],
    ));

    final row = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(600, row.center.dy)); // inside 'note'

    expect(find.text(_card), findsOneWidget);
  });

  testWidgets('the card shows over a cell whose value is not cut off',
      (tester) async {
    // onlyTextOverflow means the cell earns a tooltip solely by being cut. An
    // uncut value leaves the card as the only tooltip under the pointer.
    await tester.pumpWidget(_table(columns: {
      'name': _col(
        'name',
        behavior: TooltipBehavior.onlyTextOverflow,
        tooltipFormatter: (_) => _full,
      ),
    }));

    await _hoverAt(tester, tester.getCenter(find.text('A')));

    expect(find.text(_full), findsNothing);
    expect(find.text(_card), findsOneWidget);
  });

  testWidgets('no card when the builder returns null for the row',
      (tester) async {
    await tester.pumpWidget(
      _table(columns: {'name': _col('name')}, withCard: false),
    );

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsNothing);
  });

  testWidgets('the card anchors at the pointer, not the row rect',
      (tester) async {
    // Three 600px columns: the row is 1800 wide inside an 800px viewport. A
    // child anchor would aim at the centre of the row's *visible* slice — the
    // viewport's centre — which is on screen but unrelated to the cursor.
    await tester.pumpWidget(_table(columns: {
      'name': _col('name', width: 600),
      'note': _col('note', width: 600),
      'id': _col('id', width: 600),
    }));

    const pointer = Offset(120, 90);
    await _hoverAt(tester, pointer);

    final card = tester.getRect(find.text(_card));
    expect(find.text(_card), findsOneWidget);
    expect(
      (card.center.dx - pointer.dx).abs(),
      lessThan(200),
      reason: 'the card should sit beside the pointer, not at the row centre '
          '(x≈900) nor clamped to the screen edge',
    );
  });

  testWidgets('the card ignores the theme anchor and stays on the pointer',
      (tester) async {
    // tooltipTheme.anchor governs cells, and rowTooltipTheme falls back to it
    // when unset — so a caller who anchors their cell tooltips to the child
    // must not thereby drag the row card onto the row's visible centre, which
    // sits wherever the table happens to be scrolled rather than at the
    // cursor.
    await tester.pumpWidget(_table(
      columns: {
        'name': _col('name', width: 600),
        'note': _col('note', width: 600),
        'id': _col('id', width: 600),
      },
      theme: const TablePlusTheme(
        tooltipTheme: TablePlusTooltipTheme(anchor: TooltipAnchor.child),
      ),
    ));

    const pointer = Offset(120, 90);
    await _hoverAt(tester, pointer);

    final card = tester.getRect(find.text(_card));
    expect((card.center.dx - pointer.dx).abs(), lessThan(200));
  });

  testWidgets('a truncated cell shows its text tooltip, not the card',
      (tester) async {
    // `maxWidth` pins the column: a lone column would otherwise be widened to
    // fill the viewport, and the value would never actually overflow.
    await tester.pumpWidget(_table(columns: {
      'note': _col(
        'note',
        width: 60,
        maxWidth: 60,
        behavior: TooltipBehavior.onlyTextOverflow,
        tooltipFormatter: (_) => _full,
      ),
      'name': _col('name'),
    }));

    await _hoverAt(tester, tester.getCenter(find.textContaining('a value')));

    expect(find.text(_full), findsOneWidget);
    expect(find.text(_card), findsNothing,
        reason: 'the innermost tooltip wins; never both');
  });

  testWidgets('a cell tooltip that cannot show does not suppress the card',
      (tester) async {
    // A tooltip claims its ancestors the moment the pointer enters it. Under
    // just_tooltip 0.4.3 it claimed them before deciding it had nothing to
    // draw, so a `hideOnEmptyMessage` cell tooltip over an empty message took
    // the card down and put nothing in its place — this package answered by
    // not building such a tooltip at all. 0.4.4 gates the claim on content, so
    // the empty cell tooltip stands aside on its own and the card survives.
    //
    // This test did not change when that guard was removed, which is what says
    // it observes the contract (the card survives) and not the mechanism.
    await tester.pumpWidget(_table(columns: {
      'note': _col(
        'note',
        width: 60,
        maxWidth: 60,
        behavior: TooltipBehavior.onlyTextOverflow,
        tooltipFormatter: (_) => '',
      ),
      'name': _col('name'),
    }));

    await _hoverAt(tester, tester.getCenter(find.textContaining('a value')));

    expect(find.text(_card), findsOneWidget);
  });

  testWidgets('hideOnEmptyMessage: false keeps the empty cell tooltip winning',
      (tester) async {
    // The rule above is about content, not about emptiness: a caller who turned
    // `hideOnEmptyMessage` off asked for the empty bubble, so that bubble has
    // something to draw and displaces the card the way any other cell tooltip
    // does. This is the half that keeps the theme flag from being ignored.
    await tester.pumpWidget(_table(
      columns: {
        'note': _col(
          'note',
          width: 60,
          maxWidth: 60,
          behavior: TooltipBehavior.onlyTextOverflow,
          tooltipFormatter: (_) => '',
        ),
        'name': _col('name'),
      },
      theme: const TablePlusTheme(
        tooltipTheme: TablePlusTooltipTheme(hideOnEmptyMessage: false),
      ),
    ));

    await _hoverAt(tester, tester.getCenter(find.textContaining('a value')));

    expect(find.text(_card), findsNothing);
  });

  testWidgets('TooltipBehavior.always leaves no room for the card',
      (tester) async {
    // `always` means "whenever the column is ellipsized", not "whenever the
    // text is cut". So an ordinary text column always has a tooltip, and the
    // card never surfaces on it. A table using rowTooltipBuilder wants
    // onlyTextOverflow on its text columns.
    await tester.pumpWidget(_table(columns: {
      'name': _col(
        'name',
        behavior: TooltipBehavior.always,
        tooltipFormatter: (_) => _full,
      ),
    }));

    await _hoverAt(tester, tester.getCenter(find.text('A')));

    expect(find.text(_full), findsOneWidget);
    expect(find.text(_card), findsNothing);
  });

  testWidgets('rowTooltipTheme governs the card, not the cell tooltip theme',
      (tester) async {
    await tester.pumpWidget(_table(
      columns: {'name': _col('name')},
      theme: const TablePlusTheme(
        rowTooltipTheme: TablePlusTooltipTheme(enabled: false),
      ),
    ));

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsNothing);
  });

  testWidgets(
      'the card falls back to tooltipTheme when rowTooltipTheme is null',
      (tester) async {
    await tester.pumpWidget(_table(
      columns: {'name': _col('name')},
      theme: const TablePlusTheme(
        tooltipTheme: TablePlusTooltipTheme(enabled: false),
      ),
    ));

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsNothing);
  });

  testWidgets('rowTooltipTheme still governs the card at a non-1.0 scale',
      (tester) async {
    // Scaling rebuilds the theme. A rebuild that loses rowTooltipTheme falls
    // back to tooltipTheme, which is enabled by default — so the card the
    // caller switched off would come back, wearing the text tooltip's surface.
    await tester.pumpWidget(_table(
      columns: {'name': _col('name')},
      scale: 1.5,
      theme: const TablePlusTheme(
        rowTooltipTheme: TablePlusTooltipTheme(enabled: false),
      ),
    ));

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsNothing);
  });

  testWidgets('a merged row carries no card', (tester) async {
    // A merged row stands for several data rows. Handing the builder the first
    // of them would be a quiet lie, so it gets no card at all.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterTablePlus<Map<String, dynamic>>(
            columns: {'name': _col('name')},
            data: const [
              {'id': '1', 'name': 'A', 'note': 'x'},
              {'id': '2', 'name': 'B', 'note': 'y'},
            ],
            rowId: (r) => r['id'] as String,
            rowTooltipBuilder: (context, r) => const Text(_card),
            mergedGroups: const [
              MergedRowGroup<Map<String, dynamic>>(
                groupId: 'g1',
                rowKeys: ['1', '2'],
                mergeConfig: {'name': MergeCellConfig(shouldMerge: true)},
              ),
            ],
          ),
        ),
      ),
    );

    final text = tester.getRect(find.text('A'));
    await _hoverAt(tester, Offset(text.right + 200, text.center.dy));

    expect(find.text(_card), findsNothing);
  });

  testWidgets('wrapping the row does not swallow its selection tap',
      (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_table(
      columns: {'name': _col('name')},
      onRowSelectionChanged: (id, _) => selected.add(id),
    ));

    final text = tester.getRect(find.text('A'));
    await tester.tapAt(Offset(text.right + 200, text.center.dy));
    await tester.pumpAndSettle();

    expect(selected, ['1']);
  });
}
