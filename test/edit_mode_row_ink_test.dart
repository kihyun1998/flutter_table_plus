import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Row ink is gated by which callbacks are wired, not by the colors passed in.
//
// Passing `splashColor: null` does NOT suppress a splash — InkWell resolves
// `widget.splashColor ?? Theme.of(context).splashColor`, so it silently swaps
// the caller's theme for the framework default. These tests pin the callback
// gate and the colour passthrough, and the selection-while-editing behavior
// that fixing the gate unlocked.

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

const _data = [
  {'id': '1', 'name': 'Alpha', 'tag': 'T1'},
  {'id': '2', 'name': 'Bravo', 'tag': 'T2'},
];

Future<void> _pump(
  WidgetTester tester, {
  bool isSelectable = true,
  bool isEditable = true,
  TablePlusTheme theme = const TablePlusTheme(),
  void Function(String id, bool isSelected)? onRowSelectionChanged,
  void Function(String id, TapDownDetails d, RenderBox box, bool sel)?
      onRowSecondaryTapDown,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(),
          data: _data,
          rowId: (r) => r['id'] as String,
          isSelectable: isSelectable,
          isEditable: isEditable,
          theme: theme,
          onCellChanged: (_, __, ___, ____, _____) {},
          onRowSelectionChanged: onRowSelectionChanged,
          onRowSecondaryTapDown: onRowSecondaryTapDown,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The row's own InkWell — not the checkbox's.
Finder _rowInkWell() => find
    .descendant(of: find.byType(CustomInkWell), matching: find.byType(InkWell))
    .first;

void main() {
  testWidgets('tapping a non-editable cell selects the row while editing',
      (tester) async {
    final selected = <String>[];
    await _pump(tester, onRowSelectionChanged: (id, _) => selected.add(id));

    await tester.tap(find.text('T2'));
    await tester.pumpAndSettle();

    expect(selected, ['2']);
  });

  testWidgets('tapping an editable cell edits it and does not select the row',
      (tester) async {
    final selected = <String>[];
    await _pump(tester, onRowSelectionChanged: (id, _) => selected.add(id));

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsOneWidget);
    expect(selected, isEmpty);
  });

  testWidgets('a row with only a secondary-tap handler wires no primary tap',
      (tester) async {
    // No selection and no double-tap handler: the ink layer exists only for the
    // right-click gesture, so InkWell must not look tappable — otherwise it
    // paints a splash for a left click that does nothing.
    await _pump(
      tester,
      isSelectable: false,
      onRowSecondaryTapDown: (_, __, ___, ____) {},
    );

    expect(tester.widget<InkWell>(_rowInkWell()).onTap, isNull);
  });

  testWidgets('the body theme ink colors reach the row InkWell while editing',
      (tester) async {
    const splash = Color(0x80FF0000);
    const hover = Color(0x8000FF00);
    const highlight = Color(0x800000FF);

    await _pump(
      tester,
      theme: const TablePlusTheme(
        bodyTheme: TablePlusBodyTheme(
          splashColor: splash,
          hoverColor: hover,
          highlightColor: highlight,
        ),
      ),
    );

    final ink = tester.widget<InkWell>(_rowInkWell());
    expect(ink.splashColor, splash);
    expect(ink.hoverColor, hover);
    expect(ink.highlightColor, highlight);
  });
}
