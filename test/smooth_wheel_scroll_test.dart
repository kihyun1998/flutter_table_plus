import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for `wheelMotion`: plain mouse wheel scrolling of the body,
// with and without smoothing, and the header and scrollbars following it on
// every frame.

const Duration _frame = Duration(milliseconds: 16);

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final builder = TableColumnsBuilder<Map<String, dynamic>>();
  for (int i = 0; i < 8; i++) {
    builder.addColumn(
      'c$i',
      TablePlusColumn<Map<String, dynamic>>(
        key: 'c$i',
        label: 'C$i',
        order: 0,
        valueAccessor: (r) => r['c$i'],
        width: 150,
      ),
    );
  }
  return builder.build();
}

final List<Map<String, dynamic>> _rows = [
  for (int i = 0; i < 100; i++)
    {'id': '$i', for (int j = 0; j < 8; j++) 'c$j': 'r${i}c$j'},
];

final GlobalKey _tableKey = GlobalKey();

/// A 400x300 table of 100 rows by 8 columns, so both axes scroll.
Future<void> _pump(
  WidgetTester tester, {
  WheelMotion? wheelMotion,
  ValueChanged<double>? onScaleChanged,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: FlutterTablePlus<Map<String, dynamic>>(
              key: _tableKey,
              columns: _columns(),
              data: _rows,
              rowId: (r) => r['id'] as String,
              wheelMotion: wheelMotion,
              onScaleChanged: onScaleChanged,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Every scroll offset on [axis]: the body, and the header and scrollbar that
/// follow it.
List<double> _offsets(WidgetTester tester, Axis axis) => tester
    .stateList<ScrollableState>(find.byType(Scrollable))
    .where((s) => s.position.hasPixels && s.position.axis == axis)
    .map((s) => s.position.pixels)
    .toList();

Future<void> _wheel(
  WidgetTester tester,
  double dy, {
  bool shift = false,
}) async {
  final mouse = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(
    mouse.hover(tester.getCenter(find.byKey(_tableKey))),
  );
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendEventToBinding(mouse.scroll(Offset(0, dy)));
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
}

/// Pumps frames until [axis] stops moving, asserting on each one that every
/// offset on it agrees. Returns the offset after each frame.
Future<List<double>> _followFrames(WidgetTester tester, Axis axis) async {
  final seen = <double>[];
  for (int i = 0; i < 60; i++) {
    await tester.pump(_frame);
    final offsets = _offsets(tester, axis);
    expect(
      offsets.toSet(),
      hasLength(1),
      reason:
          'frame $i: every $axis scrollable should share one offset, '
          'got $offsets',
    );
    seen.add(offsets.first);
    if (seen.length > 2 && seen[seen.length - 2] == seen.last) break;
  }
  return seen;
}

void main() {
  group('wheelMotion: null', () {
    testWidgets('a wheel notch moves the body at once', (tester) async {
      await _pump(tester);
      await _wheel(tester, 120);

      expect(_offsets(tester, Axis.vertical), everyElement(120.0));
    });
  });

  group('wheelMotion: spring', () {
    testWidgets('a wheel notch animates the body, scrollbar in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 120);

      expect(
        _offsets(tester, Axis.vertical),
        everyElement(0.0),
        reason: 'nothing moves before the first frame',
      );
      final seen = await _followFrames(tester, Axis.vertical);
      expect(
        seen,
        anyElement(inExclusiveRange(0.0, 120.0)),
        reason: 'some frame is part of the way there',
      );
      expect(seen.last, 120.0);
    });

    testWidgets('Shift+wheel animates the body, header in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 120, shift: true);

      final seen = await _followFrames(tester, Axis.horizontal);
      expect(seen, anyElement(inExclusiveRange(0.0, 120.0)));
      expect(seen.last, 120.0);
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    });

    testWidgets('notches during the motion add to its target', (tester) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      for (int i = 0; i < 3; i++) {
        await _wheel(tester, 60);
        await tester.pump(_frame);
      }

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen.last, 180.0);
    });

    testWidgets('Ctrl+wheel still changes scale without scrolling', (
      tester,
    ) async {
      final scales = <double>[];
      await _pump(
        tester,
        wheelMotion: const WheelMotion.spring(),
        onScaleChanged: scales.add,
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await _wheel(tester, 120);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(scales, isNotEmpty);
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    });
  });

  group('changing wheelMotion', () {
    testWidgets('applies from the next notch and keeps the offset', (
      tester,
    ) async {
      await _pump(tester);
      await _wheel(tester, 120);
      expect(_offsets(tester, Axis.vertical), everyElement(120.0));

      await _pump(tester, wheelMotion: const WheelMotion.spring());
      expect(
        _offsets(tester, Axis.vertical),
        everyElement(120.0),
        reason: 'turning it on must not reset the scroll position',
      );
      await _wheel(tester, 120);
      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen, anyElement(inExclusiveRange(120.0, 240.0)));
      expect(seen.last, 240.0);

      await _pump(tester);
      await _wheel(tester, 120);
      expect(
        _offsets(tester, Axis.vertical),
        everyElement(360.0),
        reason: 'turning it off again jumps at once',
      );
    });
  });

  group('inside a page that scrolls too', () {
    // The body's vertical Scrollable sits inside its horizontal one, so a
    // notch it cannot use has to skip that axis on the way to the page.
    testWidgets('a notch the motion cannot use reaches the page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final page = ScrollController();
      addTearDown(page.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: page,
              child: Column(
                children: [
                  SizedBox(
                    width: 400,
                    height: 300,
                    child: FlutterTablePlus<Map<String, dynamic>>(
                      key: _tableKey,
                      columns: _columns(),
                      data: _rows.take(12).toList(),
                      rowId: (r) => r['id'] as String,
                      wheelMotion: const WheelMotion.spring(),
                    ),
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final body = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .firstWhere(
            (p) => p.axis == Axis.vertical && p.maxScrollExtent < 1000,
          );
      await _wheel(tester, body.maxScrollExtent);
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(
        body.pixels,
        inExclusiveRange(0.0, body.maxScrollExtent),
        reason: 'the second notch has to arrive while the motion runs',
      );

      await _wheel(tester, 60);
      await tester.pumpAndSettle();

      expect(body.pixels, body.maxScrollExtent);
      expect(page.offset, 60.0);
    });
  });
}
