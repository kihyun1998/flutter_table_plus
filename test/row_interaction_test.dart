import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterization tests for row interaction (selection tap + hover buttons)
// across both normal and merged rows. These guard the shared row-rendering
// refactor: the behaviors must survive deduplication into TablePlusRowWidget.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final builder = TableColumnsBuilder<Map<String, dynamic>>();
  builder.addColumn(
    'name',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'name',
      label: 'Name',
      order: 0,
      valueAccessor: (r) => r['name'],
      width: 200,
    ),
  );
  return builder.build();
}

List<Map<String, dynamic>> _data() => [
      {'id': '1', 'name': 'Alice'},
      {'id': '2', 'name': 'Bob'},
      {'id': '3', 'name': 'Carol'},
    ];

Future<void> _pumpTable(
  WidgetTester tester, {
  required Widget Function(FlutterTablePlus<Map<String, dynamic>>) frame,
  List<MergedRowGroup<Map<String, dynamic>>> mergedGroups = const [],
  void Function(String rowId, bool selected)? onRowSelectionChanged,
  Widget? Function(String rowId, Map<String, dynamic> data)? hoverButtonBuilder,
}) async {
  await tester.pumpWidget(
    frame(
      FlutterTablePlus<Map<String, dynamic>>(
        columns: _columns(),
        data: _data(),
        rowId: (r) => r['id'] as String,
        isSelectable: true,
        mergedGroups: mergedGroups,
        onRowSelectionChanged: onRowSelectionChanged,
        hoverButtonBuilder: hoverButtonBuilder,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _scaffold(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('tapping a merged row selects it by group id', (tester) async {
    String? selectedId;
    await _pumpTable(
      tester,
      frame: _scaffold,
      mergedGroups: const [
        MergedRowGroup<Map<String, dynamic>>(
          groupId: 'g1',
          rowKeys: ['1', '2'],
          mergeConfig: {},
        ),
      ],
      onRowSelectionChanged: (rowId, selected) => selectedId = rowId,
    );

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(selectedId, 'g1',
        reason: 'a merged row toggles selection by its group id, not a row id');
  });

  testWidgets('hovering a normal row shows its hover button', (tester) async {
    await _pumpTable(
      tester,
      frame: _scaffold,
      hoverButtonBuilder: (rowId, data) => Text('HOVER-$rowId'),
    );

    expect(find.text('HOVER-3'), findsNothing);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Carol')));
    await tester.pumpAndSettle();

    expect(find.text('HOVER-3'), findsOneWidget);
  });

  testWidgets('hovering a merged row shows its hover button', (tester) async {
    await _pumpTable(
      tester,
      frame: _scaffold,
      mergedGroups: const [
        MergedRowGroup<Map<String, dynamic>>(
          groupId: 'g1',
          rowKeys: ['1', '2'],
          mergeConfig: {},
        ),
      ],
      hoverButtonBuilder: (rowId, data) => Text('HOVER-$rowId'),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Alice')));
    await tester.pumpAndSettle();

    expect(find.text('HOVER-g1'), findsOneWidget,
        reason: 'merged row hover button is built with the group id');
  });
}
