import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for column reordering: the header wraps each reorderable cell
// in a Draggable<int> + DragTarget<int>; dropping one header on another fires
// onColumnReorder(oldIndex, newIndex) with the reorderable-column indices.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  for (final key in ['a', 'b', 'c']) {
    b.addColumn(
      key,
      TablePlusColumn<Map<String, dynamic>>(
        key: key,
        label: key.toUpperCase(),
        order: 0,
        valueAccessor: (r) => r[key],
        width: 120,
      ),
    );
  }
  return b.build();
}

Future<void> _pump(
  WidgetTester tester, {
  void Function(int oldIndex, int newIndex)? onColumnReorder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(),
          data: const [
            {'id': '1', 'a': 'a1', 'b': 'b1', 'c': 'c1'}
          ],
          rowId: (r) => r['id'] as String,
          onColumnReorder: onColumnReorder,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dragging a header onto another reorders with the right indices',
      (tester) async {
    int? oldIndex;
    int? newIndex;
    await _pump(tester, onColumnReorder: (o, n) {
      oldIndex = o;
      newIndex = n;
    });

    final from = tester.getCenter(find.text('A')); // reorder index 0
    final to = tester.getCenter(find.text('C')); // reorder index 2

    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(20, 0)); // cross the drag slop
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(oldIndex, 0);
    expect(newIndex, 2);
  });

  testWidgets('onColumnReorder: null disables reordering (no Draggable)',
      (tester) async {
    await _pump(tester, onColumnReorder: null);
    expect(find.byType(Draggable<int>), findsNothing);
  });

  testWidgets(
      'onColumnReorder present builds a Draggable per reorderable column',
      (tester) async {
    await _pump(tester, onColumnReorder: (_, __) {});
    expect(find.byType(Draggable<int>), findsNWidgets(3));
  });
}
