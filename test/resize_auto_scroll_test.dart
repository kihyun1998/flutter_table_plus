import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterization test for resize auto-scroll, which routes through the shared
// EdgeAutoScroller. Guards the _ResizeHandle wiring: holding a resize handle in
// the viewport's edge zone must keep scrolling the header while the pointer is
// held still (no further pointer events fire during pure auto-scroll).

Map<String, TablePlusColumn<Map<String, dynamic>>> _buildColumns({
  int count = 4,
  double width = 200,
}) {
  final builder = TableColumnsBuilder<Map<String, dynamic>>();
  for (int i = 0; i < count; i++) {
    final key = 'c$i';
    builder.addColumn(
      key,
      TablePlusColumn<Map<String, dynamic>>(
        key: key,
        label: 'C$i',
        order: 0,
        valueAccessor: (r) => r[key],
        width: width,
      ),
    );
  }
  return builder.build();
}

List<Map<String, dynamic>> _buildData(int rowCount, {int colCount = 4}) {
  return List.generate(rowCount, (i) {
    return {
      'id': '$i',
      for (int j = 0; j < colCount; j++) 'c$j': 'r${i}c$j',
    };
  });
}

Future<void> _pumpFrames(
  WidgetTester tester, {
  int frames = 60,
  Duration interval = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(interval);
  }
}

void main() {
  testWidgets(
      'holding a resize handle in the right edge zone auto-scrolls the header',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              // 4 * 200 = 800 content, 300 viewport -> ~500 of horizontal room.
              width: 300,
              height: 300,
              child: FlutterTablePlus<Map<String, dynamic>>(
                columns: _buildColumns(count: 4, width: 200),
                data: _buildData(3),
                rowId: (r) => r['id'] as String,
                resizable: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byKey(const ValueKey('resize_c0'));
    expect(handle, findsOneWidget);

    final handleCenter = tester.getCenter(handle);
    final tableRect =
        tester.getRect(find.byType(FlutterTablePlus<Map<String, dynamic>>));

    // 'C0' is the leftmost header label; horizontal scroll moves it left.
    final initialC0X = tester.getTopLeft(find.text('C0')).dx;

    final gesture = await tester.startGesture(handleCenter);
    await tester.pump();
    // Cross the drag slop so the horizontal-drag recognizer activates, then
    // hold inside the right edge zone (viewport right minus ~10px) at the
    // handle's vertical position (inside the header row).
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    final rightEdge = Offset(tableRect.right - 10, handleCenter.dy);
    await gesture.moveTo(rightEdge);
    await _pumpFrames(tester, frames: 60);
    final laterC0X = tester.getTopLeft(find.text('C0')).dx;
    await gesture.up();
    await tester.pump();

    expect(initialC0X - laterC0X, greaterThan(50),
        reason: 'resize auto-scroll should keep advancing the header while the '
            'handle is held inside the edge zone');
  });
}
