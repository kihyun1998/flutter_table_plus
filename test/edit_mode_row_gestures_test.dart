import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression for #1: with isEditable = true, cells still edit on tap, but
// row-level gestures (onRowDoubleTap / onRowSecondaryTapDown) must still fire —
// e.g. to delete a row while other rows stay editable.
//
// The row gestures are exercised on a NON-editable cell ('tag') so they don't
// race with cell tap-to-edit; the editing guard uses the editable cell ('name').

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  b.addColumn(
    'name',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'name',
      label: 'Name',
      order: 0,
      valueAccessor: (r) => r['name'],
      width: 160,
      editable: true,
    ),
  );
  b.addColumn(
    'tag',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'tag',
      label: 'Tag',
      order: 0,
      valueAccessor: (r) => r['tag'],
      width: 160,
    ),
  );
  return b.build();
}

Future<void> _pump(
  WidgetTester tester, {
  void Function(String id)? onRowDoubleTap,
  void Function(String id, TapDownDetails d, RenderBox box, bool sel)?
      onRowSecondaryTapDown,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(),
          data: const [
            {'id': '1', 'name': 'Alpha', 'tag': 'T1'},
            {'id': '2', 'name': 'Bravo', 'tag': 'T2'},
          ],
          rowId: (r) => r['id'] as String,
          isSelectable: true,
          isEditable: true,
          onCellChanged: (_, __, ___, ____, _____) {},
          onRowDoubleTap: onRowDoubleTap,
          onRowSecondaryTapDown: onRowSecondaryTapDown,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('double-tapping a row still fires onRowDoubleTap in edit mode',
      (tester) async {
    String? doubleTapped;
    await _pump(tester, onRowDoubleTap: (id) => doubleTapped = id);

    // Non-editable cell of row 2, by fixed location so it survives any rebuild.
    final target = tester.getCenter(find.text('T2'));
    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(target);
    await tester.pumpAndSettle();

    expect(doubleTapped, '2');
  });

  testWidgets(
      'right-clicking a row still fires onRowSecondaryTapDown in edit mode',
      (tester) async {
    String? secondary;
    await _pump(tester,
        onRowSecondaryTapDown: (id, _, __, ___) => secondary = id);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('T2')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(secondary, '2');
  });

  testWidgets('tapping an editable cell still starts editing (guard)',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsOneWidget);
  });
}
