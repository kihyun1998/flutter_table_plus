import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_selection_cell.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression for #3: the table's checkboxes must render AND respond without a
// Material ancestor (e.g. a desktop app that doesn't use Material / Scaffold).
//
// MaterialApp WITHOUT a Scaffold provides Directionality / MediaQuery /
// DefaultTextStyle but NOT a Material widget — exactly the reporter's setup.
//
// Rendering alone is a weak guarantee: InkWell only looks up `Material.of` when
// it paints ink — on tap (`_createSplash`) and on hover/focus/press
// (`updateHighlight`). A checkbox with no Material ancestor therefore builds
// fine and only throws when someone touches it. These tests touch it.

Widget _table({
  void Function(String rowId, bool isSelected)? onRowSelectionChanged,
  bool cellTapTogglesCheckbox = false,
}) {
  return FlutterTablePlus<Map<String, dynamic>>(
    columns: {
      'name': TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 0,
        valueAccessor: (r) => r['name'],
        width: 200,
      ),
    },
    data: const [
      {'id': '1', 'name': 'A'}
    ],
    rowId: (r) => r['id'] as String,
    isSelectable: true,
    // Keep the header's select-all out of the tree so the only FlutterCheckbox
    // is the row's. The header cell owns its own Material and is not the
    // subject here.
    theme: TablePlusTheme(
      checkboxTheme: TablePlusCheckboxTheme(
        showSelectAllCheckbox: false,
        cellTapTogglesCheckbox: cellTapTogglesCheckbox,
      ),
    ),
    onRowSelectionChanged: onRowSelectionChanged ?? (_, __) {},
    onSelectAll: (_) {},
  );
}

void main() {
  testWidgets('checkboxes render without a Material ancestor', (tester) async {
    // No Scaffold -> no Material ancestor.
    await tester.pumpWidget(MaterialApp(home: _table()));

    expect(
      tester.takeException(),
      isNull,
      reason: 'the table must not require a Material ancestor for its '
          'checkboxes (#3)',
    );
  });

  testWidgets('tapping a row checkbox selects the row, with no Scaffold',
      (tester) async {
    final toggled = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: _table(onRowSelectionChanged: (id, _) => toggled.add(id)),
      ),
    );

    await tester.tap(find.byType(FlutterCheckbox));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'the checkbox splash needs a Material ancestor (#3)',
    );
    expect(toggled, ['1']);
  });

  testWidgets(
      'tapping the selection cell toggles the checkbox, with no Scaffold',
      (tester) async {
    final toggled = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: _table(
          cellTapTogglesCheckbox: true,
          onRowSelectionChanged: (id, _) => toggled.add(id),
        ),
      ),
    );

    // Just inside the cell's left edge — clear of the centred checkbox, so the
    // cell's own InkWell handles the tap rather than the checkbox's.
    final cell = tester.getRect(find.byType(TablePlusSelectionCell));
    await tester.tapAt(Offset(cell.left + 2, cell.center.dy));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: "the cell-tap InkWell's splash needs a Material ancestor (#3)",
    );
    expect(toggled, ['1']);
  });

  testWidgets('hovering a row checkbox does not throw, with no Scaffold',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: _table()));

    // Hover resolves `Material.of` through `updateHighlight`, a different code
    // path from the tap splash.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await tester.pump();

    await mouse.moveTo(tester.getCenter(find.byType(FlutterCheckbox)));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'the checkbox hover highlight needs a Material ancestor (#3)',
    );
  });
}
