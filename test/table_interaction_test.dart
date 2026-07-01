import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Tier 3 widget interactions: the sort-direction cycle (both orders), the
// select-all header checkbox, row-tap selection, and cell edit commit (Enter)
// vs cancel (Escape). The table is data-agnostic, so these assert the
// callbacks it emits, not any internal data mutation.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns({
  bool sortable = false,
  bool editable = false,
}) {
  return {
    'name': TablePlusColumn<Map<String, dynamic>>(
      key: 'name',
      label: 'Name',
      order: 1,
      valueAccessor: (r) => r['name'],
      width: 200,
      sortable: sortable,
      editable: editable,
    ),
  };
}

final _data = [
  {'id': '1', 'name': 'Alice'},
  {'id': '2', 'name': 'Bob'},
];

void main() {
  group('sort direction cycle', () {
    Future<SortDirection?> tapSort(
      WidgetTester tester, {
      required SortCycleOrder cycle,
      required SortDirection current,
    }) async {
      SortDirection? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(sortable: true),
              data: _data,
              rowId: (r) => r['id'] as String,
              sortCycleOrder: cycle,
              sortColumnKey: 'name',
              sortDirection: current,
              onSort: (key, dir) => reported = dir,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      return reported;
    }

    testWidgets('ascendingFirst: ascending -> descending -> none',
        (tester) async {
      expect(
        await tapSort(tester,
            cycle: SortCycleOrder.ascendingFirst,
            current: SortDirection.ascending),
        SortDirection.descending,
      );
      expect(
        await tapSort(tester,
            cycle: SortCycleOrder.ascendingFirst,
            current: SortDirection.descending),
        SortDirection.none,
      );
    });

    testWidgets('descendingFirst: none -> descending, descending -> ascending',
        (tester) async {
      expect(
        await tapSort(tester,
            cycle: SortCycleOrder.descendingFirst, current: SortDirection.none),
        SortDirection.descending,
      );
      expect(
        await tapSort(tester,
            cycle: SortCycleOrder.descendingFirst,
            current: SortDirection.descending),
        SortDirection.ascending,
      );
    });
  });

  group('selection surface', () {
    testWidgets(
        'multiple mode: the header select-all checkbox fires onSelectAll',
        (tester) async {
      bool? selectAll;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(),
              data: _data,
              rowId: (r) => r['id'] as String,
              isSelectable: true,
              selectionMode: SelectionMode.multiple,
              onSelectAll: (v) => selectAll = v,
            ),
          ),
        ),
      );

      // The header select-all checkbox renders before the row checkboxes.
      await tester.tap(find.byType(FlutterCheckbox).first);
      await tester.pumpAndSettle();
      expect(selectAll, isTrue);
    });

    testWidgets('tapping a row reports its selection', (tester) async {
      final selected = <String, bool>{};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(),
              data: _data,
              rowId: (r) => r['id'] as String,
              isSelectable: true,
              onRowSelectionChanged: (id, isSel) => selected[id] = isSel,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(selected, {'1': true, '2': true});
    });
  });

  group('cell editing', () {
    Future<void> pumpEditable(
      WidgetTester tester, {
      required void Function(
              Map<String, dynamic>, String, int, dynamic, dynamic)
          onCellChanged,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(editable: true),
              data: _data,
              rowId: (r) => r['id'] as String,
              isEditable: true,
              onCellChanged: onCellChanged,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Enter commits the new value', (tester) async {
      dynamic oldValue, newValue;
      await pumpEditable(tester, onCellChanged: (r, k, i, o, n) {
        oldValue = o;
        newValue = n;
      });

      await tester.tap(find.text('Alice'));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'Alice EDITED');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(oldValue, 'Alice');
      expect(newValue, 'Alice EDITED');
    });

    testWidgets('Escape cancels without committing', (tester) async {
      var committed = false;
      await pumpEditable(tester, onCellChanged: (r, k, i, o, n) {
        committed = true;
      });

      await tester.tap(find.text('Alice'));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'DISCARDED');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(committed, isFalse);
      // The original value is still displayed; the discarded text is gone.
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('DISCARDED'), findsNothing);
    });
  });

  group('column width clamping (layout path)', () {
    // The rendered width of the leftmost column equals the x of its right-edge
    // resize handle, measured from the table's left. This lets us observe the
    // min/max clamp applied inside _calculateColumnWidths without dragging.
    Future<double> renderedFirstColumnWidth(
      WidgetTester tester,
      Map<String, TablePlusColumn<Map<String, dynamic>>> columns,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlutterTablePlus<Map<String, dynamic>>(
                  columns: columns,
                  data: const [
                    {'id': '0', 'c0': 'a', 'c1': 'b', 'c2': 'c', 'c3': 'd'}
                  ],
                  rowId: (r) => r['id'] as String,
                  resizable: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tableLeft = tester
          .getTopLeft(find.byType(FlutterTablePlus<Map<String, dynamic>>))
          .dx;
      final handleX =
          tester.getCenter(find.byKey(const ValueKey('resize_c0'))).dx;
      return handleX - tableLeft;
    }

    TablePlusColumn<Map<String, dynamic>> col(String key,
            {required double width, double minWidth = 50, double? maxWidth}) =>
        TablePlusColumn<Map<String, dynamic>>(
          key: key,
          label: key.toUpperCase(),
          order: 0,
          valueAccessor: (r) => r[key],
          width: width,
          minWidth: minWidth,
          maxWidth: maxWidth,
        );

    testWidgets('a column wider than maxWidth is clamped down', (tester) async {
      final columns = (TableColumnsBuilder<Map<String, dynamic>>()
            ..addColumn('c0', col('c0', width: 200, maxWidth: 150))
            ..addColumn('c1', col('c1', width: 200)))
          .build();

      final width = await renderedFirstColumnWidth(tester, columns);
      expect(width, lessThan(200), reason: 'the requested 200 must be capped');
      expect(width, closeTo(150, 8), reason: 'clamped to maxWidth');
    });

    testWidgets('a column narrower than minWidth is clamped up',
        (tester) async {
      // Four wide columns overflow the 300px viewport, forcing the
      // preferred-width fallback that clamps each column to its own bounds.
      final columns = (TableColumnsBuilder<Map<String, dynamic>>()
            ..addColumn('c0', col('c0', width: 40, minWidth: 90))
            ..addColumn('c1', col('c1', width: 200))
            ..addColumn('c2', col('c2', width: 200))
            ..addColumn('c3', col('c3', width: 200)))
          .build();

      final width = await renderedFirstColumnWidth(tester, columns);
      expect(width, greaterThan(40), reason: 'the requested 40 must be raised');
      expect(width, closeTo(90, 8), reason: 'clamped up to minWidth');
    });
  });
}
