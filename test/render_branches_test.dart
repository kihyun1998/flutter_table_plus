import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Small widget/render-branch coverage: showRowCheckbox, dim/alternate row
// colors, dynamic row heights, and the hover tooltip.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() => {
      'name': TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 0,
        valueAccessor: (r) => r['name'],
        width: 200,
      ),
    };

Future<void> _pump(
  WidgetTester tester, {
  TablePlusTheme theme = const TablePlusTheme(),
  bool isSelectable = false,
  bool Function(Map<String, dynamic>)? isDimRow,
  double? Function(int, Map<String, dynamic>)? calculateRowHeight,
  int rows = 3,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(),
          data: [
            for (int i = 0; i < rows; i++) {'id': '$i', 'name': 'R$i'}
          ],
          rowId: (r) => r['id'] as String,
          theme: theme,
          isSelectable: isSelectable,
          onRowSelectionChanged: isSelectable ? (_, __) {} : null,
          isDimRow: isDimRow,
          calculateRowHeight: calculateRowHeight,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _hasBoxColor(WidgetTester tester, Color color) {
  return tester.widgetList<Container>(find.byType(Container)).any((c) {
    final d = c.decoration;
    return d is BoxDecoration && d.color == color;
  });
}

void main() {
  group('showRowCheckbox', () {
    testWidgets('true (default) renders one row checkbox per row',
        (tester) async {
      await _pump(
        tester,
        isSelectable: true,
        theme: const TablePlusTheme(
          checkboxTheme: TablePlusCheckboxTheme(showSelectAllCheckbox: false),
        ),
        rows: 2,
      );
      expect(find.byType(FlutterCheckbox), findsNWidgets(2));
    });

    testWidgets('false renders no row checkbox', (tester) async {
      await _pump(
        tester,
        isSelectable: true,
        theme: const TablePlusTheme(
          checkboxTheme: TablePlusCheckboxTheme(
            showRowCheckbox: false,
            showSelectAllCheckbox: false,
          ),
        ),
        rows: 2,
      );
      expect(find.byType(FlutterCheckbox), findsNothing);
    });
  });

  group('row background colors', () {
    testWidgets('a dim row uses dimRowColor', (tester) async {
      const dim = Color(0xFF112233);
      await _pump(
        tester,
        theme: const TablePlusTheme(
          bodyTheme: TablePlusBodyTheme(dimRowColor: dim),
        ),
        isDimRow: (r) => r['id'] == '1',
        rows: 3,
      );
      expect(_hasBoxColor(tester, dim), isTrue);
    });

    testWidgets('odd rows use alternateRowColor', (tester) async {
      const alt = Color(0xFF445566);
      await _pump(
        tester,
        theme: const TablePlusTheme(
          bodyTheme: TablePlusBodyTheme(alternateRowColor: alt),
        ),
        rows: 4,
      );
      expect(_hasBoxColor(tester, alt), isTrue);
    });
  });

  testWidgets('calculateRowHeight sets the rendered row height',
      (tester) async {
    await _pump(tester, calculateRowHeight: (i, r) => 80, rows: 3);
    final spacing = tester.getCenter(find.text('R1')).dy -
        tester.getCenter(find.text('R0')).dy;
    expect(spacing, closeTo(80, 0.5));
  });

  testWidgets('and re-measures when only calculateRowHeight changes',
      (tester) async {
    // The list is built once and passed to both pumps **on purpose**.
    //
    // `_pump` builds a fresh one per call, and a fresh list makes
    // `!identical(widget.data, oldWidget.data)` true — which invalidates every
    // height cache on the way past and hides the thing under test. That is why
    // the test above could sit next to this bug without ever reaching it: it
    // pumps once, so no invalidation path runs at all.
    //
    // Holding `data` identical is not a contrivance either. A height function
    // that closes over state — a density toggle, a font-size slider — is a new
    // closure on every build while the list it reads is the same one. That is
    // the ordinary way to write one, and it is the case that was broken: a
    // static tear-off, which is what every other test here passes, can never
    // change identity and so can never expose it.
    final data = [
      for (int i = 0; i < 3; i++) {'id': '$i', 'name': 'R$i'}
    ];

    Future<void> pumpWith(double height) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterTablePlus<Map<String, dynamic>>(
                columns: _columns(),
                data: data,
                rowId: (r) => r['id'] as String,
                calculateRowHeight: (i, r) => height,
              ),
            ),
          ),
        );

    await pumpWith(100);
    await tester.pumpAndSettle();
    final before = tester.getCenter(find.text('R1')).dy -
        tester.getCenter(find.text('R0')).dy;
    expect(before, closeTo(100, 0.5));

    await pumpWith(40);
    await tester.pumpAndSettle();
    final after = tester.getCenter(find.text('R1')).dy -
        tester.getCenter(find.text('R0')).dy;

    expect(after, closeTo(40, 0.5),
        reason: 'the body kept its cached heights — a new height function over '
            'the same list changed nothing on screen. The parent watches '
            'calculateRowHeight and re-measured; TablePlusBody.didUpdateWidget '
            'did not, so its rows and the total height the parent reports were '
            'measured by different functions');

    // The side condition, so the assertion above cannot be satisfied by a
    // table that simply stopped drawing rows at their measured height.
    expect(after, isNot(closeTo(before, 0.5)));
    expect(find.text('R2'), findsOneWidget);
  });

  testWidgets('and re-measures when only scale changes', (tester) async {
    // The sibling of the test above, and it is here because a mutation found
    // that nothing covered it.
    //
    // `scale` has always been in this branch — it is the clause
    // `calculateRowHeight` was missing from. But deleting it left the whole
    // suite green, so the line was carrying the behaviour on trust. Reaching it
    // needs two things at once: a table that uses `calculateRowHeight`, and a
    // rebuild that changes `scale` and nothing else. No test had both.
    //
    // A cached height is already multiplied by `scale` when it is stored, so
    // without the invalidation a zoomed table draws its rows at the previous
    // zoom's heights — the same defect as above, in the clause next door.
    final data = [
      for (int i = 0; i < 3; i++) {'id': '$i', 'name': 'R$i'}
    ];

    // One function object, reused, so `calculateRowHeight` identity cannot be
    // what triggers the rebuild. Only `scale` differs between the two pumps.
    double? height(int i, Map<String, dynamic> r) => 50;

    Future<void> pumpAt(double scale) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterTablePlus<Map<String, dynamic>>(
                columns: _columns(),
                data: data,
                rowId: (r) => r['id'] as String,
                calculateRowHeight: height,
                scale: scale,
              ),
            ),
          ),
        );

    await pumpAt(1.0);
    await tester.pumpAndSettle();
    final before = tester.getCenter(find.text('R1')).dy -
        tester.getCenter(find.text('R0')).dy;
    expect(before, closeTo(50, 0.5));

    await pumpAt(2.0);
    await tester.pumpAndSettle();
    final after = tester.getCenter(find.text('R1')).dy -
        tester.getCenter(find.text('R0')).dy;

    expect(after, closeTo(100, 0.5),
        reason: 'the body kept heights measured at the previous scale');
    expect(after, isNot(closeTo(before, 0.5)));
    expect(find.text('R2'), findsOneWidget);
  });

  testWidgets('a theme rowHeight change re-decides whether the table scrolls',
      (tester) async {
    // The parent half of #128. `FlutterTablePlusState` caches a total data
    // height and that total decides `needsVerticalScroll` — which gates the
    // vertical scrollbar and feeds the last row's bottom border.
    //
    // It watched `data`, `mergedGroups`, `calculateRowHeight` and `scale`, and
    // not the theme. So growing the rows past the viewport through the theme
    // left the table believing it still fit, and **the scrollbar silently did
    // not appear** — no exception, no layout error, nothing to notice.
    //
    // Asserted at the screen, by count, per this repo's rule: at 20px the six
    // rows fit and only the horizontal scrollbar is built; at 40px they do not
    // and a second one appears.
    final data = [
      for (int i = 0; i < 6; i++) {'id': '$i', 'name': 'R$i'}
    ];

    Future<void> pumpAt(double rowHeight) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 200,
                  child: FlutterTablePlus<Map<String, dynamic>>(
                    columns: _columns(),
                    data: data,
                    rowId: (r) => r['id'] as String,
                    theme: TablePlusTheme(
                      bodyTheme: TablePlusBodyTheme(rowHeight: rowHeight),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    await pumpAt(20);
    await tester.pumpAndSettle();
    final fits = tester.widgetList(find.byType(Scrollbar)).length;

    await pumpAt(40);
    await tester.pumpAndSettle();
    final overflows = tester.widgetList(find.byType(Scrollbar)).length;

    expect(overflows, greaterThan(fits),
        reason: 'the table kept the total height it measured at 20px, so it '
            'still believed six rows fit and drew no vertical scrollbar');

    // The side condition: a fresh list reaches the same answer, so the count
    // itself is right and only the invalidation was missing.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 200,
              child: FlutterTablePlus<Map<String, dynamic>>(
                columns: _columns(),
                data: [
                  for (int i = 0; i < 6; i++) {'id': '$i', 'name': 'R$i'}
                ],
                rowId: (r) => r['id'] as String,
                theme: const TablePlusTheme(
                  bodyTheme: TablePlusBodyTheme(rowHeight: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widgetList(find.byType(Scrollbar)).length, overflows);
  });

  testWidgets('a scale change alone re-decides whether the table scrolls',
      (tester) async {
    // The parent's scale path, and it exists because a mutation survived
    // without it.
    //
    // The shared predicate takes a row height from each caller, and the two
    // callers hand it *different* things: the body gets `theme.rowHeight`,
    // which the parent has already run through `scaledBy`, while the parent
    // gets `theme.bodyTheme.rowHeight` unscaled and multiplies by `scale`
    // itself. So a scale change moves the body's height term on its own — the
    // scale term is redundant there — and does not move the parent's. For the
    // parent it is the only term that can notice, and nothing exercised it.
    final data = [
      for (int i = 0; i < 6; i++) {'id': '$i', 'name': 'R$i'}
    ];

    Future<void> pumpAt(double scale) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 200,
                  child: FlutterTablePlus<Map<String, dynamic>>(
                    columns: _columns(),
                    data: data,
                    rowId: (r) => r['id'] as String,
                    scale: scale,
                    theme: const TablePlusTheme(
                      bodyTheme: TablePlusBodyTheme(rowHeight: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    await pumpAt(0.5);
    await tester.pumpAndSettle();
    final small = tester.widgetList(find.byType(Scrollbar)).length;

    await pumpAt(1.0);
    await tester.pumpAndSettle();
    final large = tester.widgetList(find.byType(Scrollbar)).length;

    expect(large, greaterThan(small),
        reason: 'the parent kept the total it measured at scale 0.5, so six '
            'rows that no longer fit were still believed to');
  });

  testWidgets('hovering a cell shows its tooltip', (tester) async {
    await _pump(tester, rows: 2); // columns default to TooltipBehavior.always

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('R0')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // past the wait duration

    // The tooltip echoes the cell text into an overlay -> a second 'R0'.
    expect(find.text('R0'), findsNWidgets(2));
  });

  testWidgets('uniform table scrolls to the last row (fixed itemExtent path)',
      (tester) async {
    // No merged groups and no calculateRowHeight -> the fixed-itemExtent path.
    await _pump(tester, rows: 1000);

    final vertical = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    final pos = tester.state<ScrollableState>(vertical.first).position;
    pos.jumpTo(pos.maxScrollExtent);
    await tester.pumpAndSettle();

    // Offset<->index mapping is correct under RenderSliverFixedExtentList.
    expect(find.text('R999'), findsOneWidget);
  });
}
