import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The anchor decides what a tooltip is positioned against: its child's rect, or
// the pointer. Only the public library is imported here — naming TooltipAnchor
// at all is the assertion that the package re-exports it.
//
// Telling the two anchors apart needs a child whose centre is far from the
// cursor. A text tooltip's hover target is the Text itself, so the text must be
// long enough to ellipsize and fill a wide column; otherwise its rect is narrow
// and both anchors land in the same place.

const _long = 'a value long enough that it cannot possibly fit inside the '
    'column and must therefore be truncated with an ellipsis';
const _longHeader = 'a column heading long enough to be truncated as well, '
    'and distinct from the value beneath it';
const _full = 'FULL';

Future<void> _hoverAt(WidgetTester tester, Offset location) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();

  await mouse.moveTo(location);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

TablePlusColumn<Map<String, dynamic>> _col(
  String key, {
  required double width,
  String? label,
  int order = 0,
  TooltipBehavior behavior = TooltipBehavior.never,
  TooltipBehavior headerBehavior = TooltipBehavior.never,
}) {
  return TablePlusColumn<Map<String, dynamic>>(
    key: key,
    label: label ?? key,
    order: order,
    valueAccessor: (r) => r[key],
    width: width,
    maxWidth: width,
    tooltipBehavior: behavior,
    headerTooltipBehavior: headerBehavior,
    tooltipFormatter: (_) => _full,
  );
}

/// The header tooltip repeats the column's label, so two `Text`s carry the same
/// string once it opens. [before] is the label's rect from before the hover;
/// whichever rect differs from it is the tooltip's.
Rect _tooltipRectFor(WidgetTester tester, String label, Rect before) {
  final found = find.text(label);
  expect(found, findsNWidgets(2), reason: 'the header label and its tooltip');

  final rects = [tester.getRect(found.at(0)), tester.getRect(found.at(1))];
  final tip = rects.firstWhere((r) => r != before,
      orElse: () => fail('the tooltip rect coincides with the header label'));
  return tip;
}

Widget _table({
  required TablePlusTheme theme,
  Map<String, TablePlusColumn<Map<String, dynamic>>>? columns,
}) {
  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        columns: columns ??
            {
              'note': _col('note',
                  width: 600, behavior: TooltipBehavior.onlyTextOverflow),
              'name': _col('name', width: 400),
            },
        data: const [
          {'id': '1', 'name': 'A', 'note': _long},
        ],
        rowId: (r) => r['id'] as String,
        theme: theme,
      ),
    ),
  );
}

void main() {
  testWidgets('a cell text tooltip anchors at the pointer when asked',
      (tester) async {
    await tester.pumpWidget(_table(
      theme: const TablePlusTheme(
        tooltipTheme: TablePlusTooltipTheme(anchor: TooltipAnchor.pointer),
      ),
    ));

    final text = tester.getRect(find.text(_long));
    final pointer = Offset(text.left + 40, text.center.dy);
    await _hoverAt(tester, pointer);

    expect(find.text(_full), findsOneWidget);
    final tip = tester.getRect(find.text(_full));
    expect(
      (tip.center.dx - pointer.dx).abs(),
      lessThan(80),
      reason: 'the tooltip should sit beside the cursor, not at the centre of '
          'the ellipsized Text (x≈${text.center.dx.round()})',
    );
  });

  testWidgets('a header tooltip anchors at the pointer when asked',
      (tester) async {
    // A header tooltip's message is the label itself, so a label long enough to
    // ellipsize also makes a tooltip wide enough to hit screenMargin and get
    // clamped — which would hide the anchor's effect. Widen the view and put
    // the column well clear of both edges so nothing clamps.
    tester.view.physicalSize = const Size(2000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_table(
      theme: const TablePlusTheme(
        tooltipTheme: TablePlusTooltipTheme(anchor: TooltipAnchor.pointer),
      ),
      columns: {
        'name': _col('name', width: 800, order: 1),
        'note': _col('note',
            width: 600,
            order: 2,
            label: _longHeader,
            headerBehavior: TooltipBehavior.always),
      },
    ));

    final header = tester.getRect(find.text(_longHeader));
    final pointer = Offset(header.left + 40, header.center.dy);
    await _hoverAt(tester, pointer);

    final tip = _tooltipRectFor(tester, _longHeader, header);
    expect(
      (tip.center.dx - pointer.dx).abs(),
      lessThan(80),
      reason: 'the tooltip should sit beside the cursor, not at the centre of '
          'the header label (x≈${header.center.dx.round()})',
    );
  });
}
