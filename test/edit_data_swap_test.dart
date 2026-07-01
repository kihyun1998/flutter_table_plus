import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression test for the edit-during-data-swap defect: while a cell is being
// edited, if the parent replaces `data` (e.g. a sort/filter), the edit must
// stay pinned to the row it started on (by id), not to a now-stale index —
// otherwise committing writes to the wrong row (or throws RangeError).

class _EditHarness extends StatefulWidget {
  const _EditHarness({super.key, required this.onCommitted});

  final void Function(Map<String, dynamic> row) onCommitted;

  @override
  State<_EditHarness> createState() => _EditHarnessState();
}

class _EditHarnessState extends State<_EditHarness> {
  List<Map<String, dynamic>> data = [
    {'id': 'a', 'name': 'Alpha'},
    {'id': 'b', 'name': 'Bravo'},
    {'id': 'c', 'name': 'Charlie'},
  ];

  void setData(List<Map<String, dynamic>> next) => setState(() => data = next);

  @override
  Widget build(BuildContext context) {
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
          data: data,
          rowId: (r) => r['id'] as String,
          isEditable: true,
          onCellChanged: (row, columnKey, rowIndex, oldValue, newValue) =>
              widget.onCommitted(row),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
      'committing after the edited row is reordered writes to the same row',
      (tester) async {
    Map<String, dynamic>? committed;
    final key = GlobalKey<_EditHarnessState>();

    await tester.pumpWidget(
      _EditHarness(key: key, onCommitted: (row) => committed = row),
    );
    await tester.pumpAndSettle();

    // Enter edit mode on row 'b' (index 1) and change its value.
    await tester.tap(find.text('Bravo'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'B-EDITED');
    await tester.pump();

    // The parent reorders the data: 'b' moves from index 1 to index 2.
    key.currentState!.setData([
      {'id': 'a', 'name': 'Alpha'},
      {'id': 'c', 'name': 'Charlie'},
      {'id': 'b', 'name': 'Bravo'},
    ]);
    await tester.pump();

    // Commit the pending edit by tapping another editable cell.
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(committed, isNotNull,
        reason: 'the pending edit should have committed');
    expect(committed!['id'], 'b',
        reason: 'the edit must commit to row "b" (its id), not to whatever row '
            'now sits at the stale index');
  });

  testWidgets('the edit is cancelled (not misapplied) when its row is removed',
      (tester) async {
    Map<String, dynamic>? committed;
    final key = GlobalKey<_EditHarnessState>();

    await tester.pumpWidget(
      _EditHarness(key: key, onCommitted: (row) => committed = row),
    );
    await tester.pumpAndSettle();

    // Edit the last row ('c', index 2), then remove it from the data.
    await tester.tap(find.text('Charlie'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'C-EDITED');
    await tester.pump();

    key.currentState!.setData([
      {'id': 'a', 'name': 'Alpha'},
      {'id': 'b', 'name': 'Bravo'},
    ]);
    await tester.pump();

    // Committing now must not fire onCellChanged for a stale/removed row (and
    // must not throw RangeError indexing the shrunk list).
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(committed, isNull,
        reason: 'an edit whose row was removed is cancelled, not committed to '
            'a stale index');
  });
}
