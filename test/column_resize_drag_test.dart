import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for the actual drag-to-resize interaction (distinct from the
// resize auto-scroll test and the static clamp-via-handle-position test):
// dragging a resize handle changes the column width and fires onColumnResized
// once on release with the clamped logical width.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  b.addColumn(
    'c0',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 200,
      minWidth: 80,
      maxWidth: 300,
    ),
  );
  for (final k in ['c1', 'c2']) {
    b.addColumn(
      k,
      TablePlusColumn<Map<String, dynamic>>(
        key: k,
        label: k.toUpperCase(),
        order: 0,
        valueAccessor: (r) => r[k],
        width: 200,
      ),
    );
  }
  return b.build();
}

Future<List<double>> _dragResize(WidgetTester tester, double dx) async {
  final resized = <double>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        // 600 of content in a 300 viewport -> columns keep their preferred
        // widths (no proportional redistribution); c0 renders at 200.
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(),
              data: const [
                {'id': '1', 'c0': 'a', 'c1': 'b', 'c2': 'c'}
              ],
              rowId: (r) => r['id'] as String,
              resizable: true,
              onColumnResized: (_, width) => resized.add(width),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.drag(find.byKey(const ValueKey('resize_c0')), Offset(dx, 0));
  await tester.pumpAndSettle();
  return resized;
}

void main() {
  testWidgets('dragging right widens the column and fires onColumnResized once',
      (tester) async {
    final resized = await _dragResize(tester, 40);

    expect(resized.length, 1);
    expect(resized.single, greaterThan(200)); // widened from 200
    expect(resized.single, lessThanOrEqualTo(240)); // at most +40
  });

  testWidgets('dragging past maxWidth clamps to maxWidth', (tester) async {
    final resized = await _dragResize(tester, 500);

    expect(resized.length, 1);
    expect(resized.single, 300); // clamped to maxWidth
  });

  testWidgets('dragging past minWidth clamps to minWidth', (tester) async {
    final resized = await _dragResize(tester, -500);

    expect(resized.length, 1);
    expect(resized.single, 80); // clamped to minWidth
  });
}
