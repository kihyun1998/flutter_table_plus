import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// What `SelectionMode` does, and — the part that cost two wrong doc-comments —
// what it does not.
//
// Both claims corrected here were found from the consumer side while writing
// the example's selection recipe (#103), not from a failing test, because no
// test could fail: the code was always right and only the documentation was
// wrong. That is the expensive shape. A wrong conclusion gets caught by the
// next person who runs it; a wrong *reason* gets believed and built on.
//
//   `SelectionMode.single` said "Previous selection is automatically cleared
//   when a new row is selected". Nothing clears it. `selectionMode` is read in
//   exactly one condition in this package — whether drag-select is wired — and
//   `selectedRows` is never written to at all.
//
//   `showSelectAllCheckbox` said "Automatically disabled for single selection
//   mode". It is not. Its only readers ask `showSelectAllCheckbox &&
//   onSelectAll != null`, and neither term mentions the mode.
//
// The MAP already had this right — "single mode is a policy, not a different
// mechanism" — which is what settled the direction: the docs were wrong, and no
// behaviour needed to move.
//
// These tests pin the corrected claims. If either behaviour is ever changed on
// purpose, one of them reddens and the doc-comment beside it is the other half
// of that change.

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
  required SelectionMode selectionMode,
  Set<String> selectedRows = const {},
  void Function(bool)? onSelectAll,
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
          isSelectable: true,
          selectionMode: selectionMode,
          selectedRows: selectedRows,
          onRowSelectionChanged: (_, __) {},
          onSelectAll: onSelectAll,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The checked row checkboxes. The header's is drawn first and is dropped by
/// position; the total is asserted first so that assumption fails loudly.
int _checkedRows(WidgetTester tester, {required bool hasHeaderCheckbox}) =>
    tester
        .widgetList<FlutterCheckbox>(find.byType(FlutterCheckbox))
        .skip(hasHeaderCheckbox ? 1 : 0)
        .where((c) => c.value == true)
        .length;

void main() {
  group('single mode does not clamp the set', () {
    testWidgets('two selected rows in single mode both render selected',
        (tester) async {
      await _pump(
        tester,
        selectionMode: SelectionMode.single,
        selectedRows: const {'0', '1'},
      );

      // Three rows, no header checkbox (no `onSelectAll` was given).
      expect(find.byType(FlutterCheckbox), findsNWidgets(3));
      expect(_checkedRows(tester, hasHeaderCheckbox: false), 2,
          reason: 'the package clamped a set it does not own — selection is '
              'the caller\'s state in both modes');
    });

    testWidgets('and multiple mode renders the identical set identically',
        (tester) async {
      // The side condition. Without it, a package that rendered *nothing*
      // selected would also pass the test above by another route.
      await _pump(
        tester,
        selectionMode: SelectionMode.multiple,
        selectedRows: const {'0', '1'},
      );

      expect(find.byType(FlutterCheckbox), findsNWidgets(3));
      expect(_checkedRows(tester, hasHeaderCheckbox: false), 2);
    });
  });

  group('select-all does not consult the mode', () {
    testWidgets('a single-mode table still draws a working select-all',
        (tester) async {
      final calls = <bool>[];

      await _pump(
        tester,
        selectionMode: SelectionMode.single,
        onSelectAll: calls.add,
      );

      // Header plus three rows: the select-all is drawn in single mode.
      expect(find.byType(FlutterCheckbox), findsNWidgets(4));

      await tester.tap(find.byType(FlutterCheckbox).first);
      await tester.pumpAndSettle();

      expect(calls, [true],
          reason: 'the header checkbox is drawn in single mode but inert, '
              'which is neither of the two documented behaviours');
    });

    testWidgets('withholding onSelectAll is what removes it', (tester) async {
      await _pump(tester, selectionMode: SelectionMode.single);

      // Three rows and no header checkbox: `showSelectAllCheckbox` defaults to
      // true, so the null callback is the term that removed it.
      expect(find.byType(FlutterCheckbox), findsNWidgets(3));
    });
  });
}
