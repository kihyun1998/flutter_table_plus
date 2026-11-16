import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A scrollbar thumb dragged past the end stops the scrollbar at the body's
// end and the drag goes on, on every platform and under an app's bouncing
// physics. A fling on the thumb goes as far as the platform's own physics
// takes it. The thumb and the track take a pointer on Android too, whatever
// the app's scrollbar theme says, and the track takes a click on iOS too.

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

/// A 400x300 table of 100 rows by 8 columns, so both axes scroll.
///
/// [scrollBehavior] is the app's, and [scrollbarTheme] a [ScrollbarTheme]
/// around the table.
Future<void> _pump(
  WidgetTester tester, {
  ScrollBehavior? scrollBehavior,
  ScrollbarThemeData? scrollbarTheme,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final table = FlutterTablePlus<Map<String, dynamic>>(
    columns: _columns(),
    data: _rows,
    rowId: (r) => r['id'] as String,
    wheelMotion: null,
  );
  await tester.pumpWidget(
    MaterialApp(
      scrollBehavior: scrollBehavior,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: scrollbarTheme == null
                ? table
                : ScrollbarTheme(data: scrollbarTheme, child: table),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A scrollbar strip's thumb: the [RawScrollbar] a Material [Scrollbar]
/// builds off iOS, and a [RawScrollbar] on iOS.
final Finder _thumbs = find.byWidgetPredicate((w) => w is RawScrollbar);

/// The scroll view a scrollbar strip on [axis] is drawn on.
Finder _strip(Axis axis) => find.descendant(
  of: _thumbs,
  matching: find.byWidgetPredicate(
    (w) => w is SingleChildScrollView && w.scrollDirection == axis,
  ),
);

ScrollPosition _stripPosition(WidgetTester tester, Axis axis) => tester
    .state<ScrollableState>(
      find.descendant(of: _strip(axis), matching: find.byType(Scrollable)),
    )
    .position;

/// The body's position on [axis]: neither a scrollbar strip's nor the
/// header's, which takes no input.
ScrollPosition _bodyPosition(WidgetTester tester, Axis axis) {
  final strips = find.descendant(
    of: _thumbs,
    matching: find.byType(Scrollable),
  );
  final stripPositions = tester
      .stateList<ScrollableState>(strips)
      .map((s) => s.position)
      .toSet();
  return tester
      .stateList<ScrollableState>(find.byType(Scrollable))
      .map((s) => s.position)
      .firstWhere(
        (p) =>
            p.axis == axis &&
            !stripPositions.contains(p) &&
            p.physics is! NeverScrollableScrollPhysics,
      );
}

/// A point on the thumb of the strip on [axis] while the strip is at 0.
Offset _thumb(WidgetTester tester, Axis axis) =>
    tester.getTopLeft(_strip(axis)) +
    (axis == Axis.vertical ? const Offset(7, 8) : const Offset(8, 7));

Offset _along(Axis axis, double distance) =>
    axis == Axis.vertical ? Offset(0, distance) : Offset(distance, 0);

/// Drags the thumb of the strip on [axis] past the end, back past the start,
/// and past the end again, checking the scrollbar against the body each step.
Future<void> _dragPastBothEnds(
  WidgetTester tester,
  Axis axis, {
  ScrollBehavior? scrollBehavior,
}) async {
  await _pump(tester, scrollBehavior: scrollBehavior);
  final strip = _stripPosition(tester, axis);
  final body = _bodyPosition(tester, axis);
  final gesture = await tester.startGesture(
    _thumb(tester, axis),
    kind: PointerDeviceKind.mouse,
  );
  // Long enough for the press a Cupertino thumb waits for.
  await tester.pump(const Duration(milliseconds: 300));

  int atEnd = 0;
  for (int step = 1; step <= 60; step++) {
    await gesture.moveBy(_along(axis, 10));
    await tester.pump();
    expect(strip.activity, isA<DragScrollActivity>(), reason: 'at $step');
    expect(strip.pixels, body.pixels, reason: 'at $step');
    expect(
      strip.pixels,
      lessThanOrEqualTo(body.maxScrollExtent),
      reason: 'at $step',
    );
    if (body.pixels == body.maxScrollExtent) atEnd++;
  }
  expect(atEnd, greaterThanOrEqualTo(5));

  // Back to near the start of the track: the thumb moves the body again
  // at once.
  await gesture.moveBy(_along(axis, -590));
  await tester.pump();
  expect(body.pixels, lessThan(body.maxScrollExtent));
  expect(strip.pixels, body.pixels);

  // Past the start, the scrollbar stops at the start as well.
  for (int step = 1; step <= 10; step++) {
    await gesture.moveBy(_along(axis, -10));
    await tester.pump();
    expect(strip.activity, isA<DragScrollActivity>(), reason: 'at $step');
    expect(strip.pixels, body.pixels, reason: 'at $step');
    expect(strip.pixels, greaterThanOrEqualTo(0), reason: 'at $step');
  }
  expect(body.pixels, 0);

  await gesture.moveBy(_along(axis, 700));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
  expect(body.pixels, body.maxScrollExtent);
  expect(strip.pixels, body.maxScrollExtent);
}

void main() {
  for (final axis in Axis.values) {
    testWidgets(
      'a $axis thumb drag past the end stops the scrollbar at the '
      "body's end and the drag goes on",
      (tester) async {
        await _dragPastBothEnds(tester, axis);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.android,
        TargetPlatform.windows,
      }),
    );

    testWidgets('under an app\'s bouncing physics, a $axis thumb drag past the '
        "end stops the scrollbar at the body's end", (tester) async {
      await _dragPastBothEnds(
        tester,
        axis,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const BouncingScrollPhysics(),
        ),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets(
      'a click on the $axis track pages the body',
      (tester) async {
        await _pump(tester);
        final strip = _stripPosition(tester, axis);
        final body = _bodyPosition(tester, axis);
        await tester.tapAt(
          tester.getBottomRight(_strip(axis)) - const Offset(5, 5),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(body.pixels, greaterThan(0));
        expect(strip.pixels, body.pixels);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.android,
        TargetPlatform.windows,
      }),
    );

    testWidgets(
      'the $axis thumb takes a drag though the app\'s scrollbar '
      'theme turns gestures off',
      (tester) async {
        await _pump(
          tester,
          scrollbarTheme: const ScrollbarThemeData(interactive: false),
        );
        final strip = _stripPosition(tester, axis);
        final body = _bodyPosition(tester, axis);
        final gesture = await tester.startGesture(
          // The app's theme sets the thumb's size and margin, so this is a
          // point on the thumb under Android's and the desktop's defaults.
          tester.getTopLeft(_strip(axis)) +
              (axis == Axis.vertical
                  ? const Offset(9.5, 8)
                  : const Offset(8, 9.5)),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await gesture.moveBy(_along(axis, 30));
        await tester.pump();
        expect(body.pixels, greaterThan(0));
        expect(strip.pixels, body.pixels);
        await gesture.up();
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.windows,
      }),
    );

    testWidgets('a $axis thumb flung toward the end on iOS stops the '
        "scrollbar at the body's end", (tester) async {
      await _pump(tester);
      final strip = _stripPosition(tester, axis);
      final body = _bodyPosition(tester, axis);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.down(_thumb(tester, axis), timeStamp: Duration.zero);
      await tester.pump(const Duration(milliseconds: 300));
      for (int i = 1; i <= 5; i++) {
        await gesture.moveBy(
          _along(axis, axis == Axis.vertical ? 30 : 60),
          timeStamp: Duration(milliseconds: 300 + 8 * i),
        );
        await tester.pump();
      }
      await gesture.up(timeStamp: const Duration(milliseconds: 348));
      await tester.pump();
      expect(strip.activity, isA<BallisticScrollActivity>());

      for (int frame = 0; frame < 1000; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(strip.pixels, lessThanOrEqualTo(body.maxScrollExtent));
        expect(strip.pixels, body.pixels);
        if (strip.activity is! BallisticScrollActivity) break;
      }
      expect(strip.activity, isA<IdleScrollActivity>());
      expect(body.pixels, body.maxScrollExtent);
      expect(strip.pixels, body.maxScrollExtent);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('a $axis thumb flung on Android carries the body on', (
      tester,
    ) async {
      await _pump(tester);
      final strip = _stripPosition(tester, axis);
      final body = _bodyPosition(tester, axis);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.down(_thumb(tester, axis), timeStamp: Duration.zero);
      await tester.pump(const Duration(milliseconds: 300));
      for (int i = 1; i <= 5; i++) {
        await gesture.moveBy(
          _along(axis, 4),
          timeStamp: Duration(milliseconds: 300 + 8 * i),
        );
        await tester.pump();
      }
      final released = strip.pixels;
      expect(released, greaterThan(0));
      await gesture.up(timeStamp: const Duration(milliseconds: 348));
      await tester.pumpAndSettle();
      expect(strip.pixels, greaterThan(released));
      expect(body.pixels, strip.pixels);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('a $axis thumb flung on iOS goes as far as the platform\'s '
        'physics takes it', (tester) async {
      await _pump(tester);
      final strip = _stripPosition(tester, axis);
      final body = _bodyPosition(tester, axis);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.down(_thumb(tester, axis), timeStamp: Duration.zero);
      await tester.pump(const Duration(milliseconds: 300));
      final tracker = VelocityTracker.withKind(PointerDeviceKind.mouse);
      for (int i = 1; i <= 5; i++) {
        final time = Duration(milliseconds: 300 + 8 * i);
        await gesture.moveBy(_along(axis, 4), timeStamp: time);
        tracker.addPosition(time, _along(axis, 4.0 * i));
        await tester.pump();
      }
      final released = strip.copyWith();
      final pointerVelocity = tracker.getVelocity().pixelsPerSecond;
      await gesture.up(timeStamp: const Duration(milliseconds: 348));

      // The scroll view's own physics on this platform, given the velocity
      // the thumb was released at, as the scrollbar hands it on.
      final platformPhysics = ScrollConfiguration.of(
        tester.element(_strip(axis)),
      ).getScrollPhysics(tester.element(_strip(axis)));
      final simulation = platformPhysics.createBallisticSimulation(
        released,
        axis == Axis.vertical ? pointerVelocity.dy : pointerVelocity.dx,
      )!;
      // The activity ends in the first frame the simulation is done by, so
      // with 16 ms frames it ends within 16 ms of that moment.
      double doneAt = 0;
      while (!simulation.isDone(doneAt)) {
        doneAt += 0.001;
      }
      final earliest = simulation.x(doneAt);
      final latest = simulation.x(doneAt + 0.016);
      expect(earliest, greaterThan(released.pixels + 100));
      expect(latest, lessThan(released.maxScrollExtent));

      for (int frame = 0; frame < 1000; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (strip.activity is! BallisticScrollActivity) break;
      }
      expect(strip.activity, isA<IdleScrollActivity>());
      expect(strip.pixels, inInclusiveRange(earliest - 0.01, latest + 0.01));
      expect(body.pixels, strip.pixels);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  }
}
