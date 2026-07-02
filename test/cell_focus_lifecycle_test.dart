import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #36 guard: the cell FocusNode is about to become lazily created (only when a
// cell can edit). These pin the two behaviors that rely on it — focusing on tap
// (edit entry) and auto-saving on blur (the FocusNode listener) — so the
// refactor must keep them green.

Widget _table(void Function(Map<String, dynamic> row) onCommit) {
  final columns = TableColumnsBuilder<Map<String, dynamic>>()
    ..addColumn(
      'name',
      TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 0,
        valueAccessor: (r) => r['name'],
        width: 200,
        editable: true,
      ),
    );

  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        columns: columns.build(),
        data: const [
          {'id': 'a', 'name': 'Alpha'},
        ],
        rowId: (r) => r['id'] as String,
        isEditable: true,
        onCellChanged: (row, columnKey, rowIndex, oldValue, newValue) =>
            onCommit(row),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping an editable cell enters edit mode (focus on tap)',
      (tester) async {
    await tester.pumpWidget(_table((_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('editing auto-saves on blur (the cell FocusNode listener)',
      (tester) async {
    Map<String, dynamic>? committed;
    await tester.pumpWidget(_table((row) => committed = row));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'A-EDITED');
    await tester.pump();

    // Losing focus should commit the pending edit.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(committed?['id'], 'a', reason: 'blur must auto-save the edited row');
  });
}
