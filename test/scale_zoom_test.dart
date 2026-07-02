import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for the scale feature: scaled rendering, Ctrl+wheel ->
// onScaleChanged, and scroll blocking while the scale modifier is held.

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
  double scale = 1.0,
  ValueChanged<double>? onScaleChanged,
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
          scale: scale,
          onScaleChanged: onScaleChanged,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _rowSpacing(WidgetTester tester) =>
    tester.getCenter(find.text('R1')).dy - tester.getCenter(find.text('R0')).dy;

Future<void> _ctrlWheel(WidgetTester tester, double dy) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  final loc =
      tester.getCenter(find.byType(FlutterTablePlus<Map<String, dynamic>>));
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(loc));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}

void main() {
  testWidgets('rendering at scale 2.0 doubles the row height', (tester) async {
    await _pump(tester, scale: 1.0);
    final at1 = _rowSpacing(tester);

    await _pump(tester, scale: 2.0);
    final at2 = _rowSpacing(tester);

    expect(at2, closeTo(at1 * 2, 0.5));
  });

  testWidgets('Ctrl+wheel up requests a larger scale (scale + step)',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      double? requested;
      await _pump(tester, scale: 1.0, onScaleChanged: (s) => requested = s);
      await _ctrlWheel(tester, -50); // wheel up (dy < 0) -> zoom in
      expect(requested, closeTo(1.05, 1e-9)); // scaleStep default 0.05
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Ctrl+wheel down requests a smaller scale (scale - step)',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      double? requested;
      await _pump(tester, scale: 1.0, onScaleChanged: (s) => requested = s);
      await _ctrlWheel(tester, 50); // wheel down (dy > 0) -> zoom out
      expect(requested, closeTo(0.95, 1e-9));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Ctrl+wheel zooms instead of scrolling; a plain wheel scrolls',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _pump(tester, onScaleChanged: (_) {}, rows: 40); // scrollable

      // A mid-viewport row that stays visible through a small scroll.
      final start = tester.getCenter(find.text('R5')).dy;

      // Ctrl+wheel is consumed for zoom -> the body must NOT scroll.
      await _ctrlWheel(tester, 100);
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('R5')).dy, start,
          reason: 'Ctrl+wheel zooms, it does not scroll');

      // A plain wheel (no modifier) scrolls the body.
      final loc =
          tester.getCenter(find.byType(FlutterTablePlus<Map<String, dynamic>>));
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(loc));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 100)));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('R5')).dy, lessThan(start),
          reason: 'a plain wheel scrolls');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
