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
