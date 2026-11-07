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

/// Stands for an argument left out, as opposed to one passed as `null`.
const Object _omitted = Object();

/// A 400x300 table of 100 rows by 8 columns, so both axes scroll.
///
/// [wheelMotion] left out builds the table without the argument, so its
/// default is what runs.
Future<void> _pump(
  WidgetTester tester, {
  Object? wheelMotion = _omitted,
  ValueChanged<double>? onScaleChanged,
  List<Map<String, dynamic>>? data,
  Widget? noDataWidget,
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
            child: identical(wheelMotion, _omitted)
                ? FlutterTablePlus<Map<String, dynamic>>(
                    key: _tableKey,
                    columns: _columns(),
                    data: data ?? _rows,
                    rowId: (r) => r['id'] as String,
                    onScaleChanged: onScaleChanged,
                    noDataWidget: noDataWidget,
                  )
                : FlutterTablePlus<Map<String, dynamic>>(
                    key: _tableKey,
                    columns: _columns(),
                    data: data ?? _rows,
                    rowId: (r) => r['id'] as String,
                    wheelMotion: wheelMotion as WheelMotion?,
                    onScaleChanged: onScaleChanged,
                    noDataWidget: noDataWidget,
                  ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Every scroll offset on [axis] in the table: the body, and the header and
/// scrollbar that follow it.
List<double> _offsets(WidgetTester tester, Axis axis) => tester
    .stateList<ScrollableState>(
      find.descendant(
        of: find.byKey(_tableKey),
        matching: find.byType(Scrollable),
      ),
    )
    .where((s) => s.position.hasPixels && s.position.axis == axis)
    .map((s) => s.position.pixels)
    .toList();

/// The body's position on [axis], which no scrollbar strip draws on.
ScrollPosition _bodyPosition(WidgetTester tester, Axis axis) {
  final strips = find.descendant(
    of: find.byType(Scrollbar),
    matching: find.byType(Scrollable),
  );
  final stripPositions = tester
      .stateList<ScrollableState>(strips)
      .map((s) => s.position)
      .toSet();
  return tester
      .stateList<ScrollableState>(find.byType(Scrollable))
      .map((s) => s.position)
      .firstWhere((p) => p.axis == axis && !stripPositions.contains(p));
}

/// The scroll view a scrollbar strip on [axis] is drawn on.
Finder _strip(Axis axis) => find.descendant(
  of: find.byType(Scrollbar),
  matching: find.byWidgetPredicate(
    (w) => w is SingleChildScrollView && w.scrollDirection == axis,
  ),
);

/// A 400x300 table of one column, so only the vertical axis scrolls, for a
/// page to hold.
Widget _pageTable({
  TablePlusTheme theme = const TablePlusTheme(),
  double scale = 1.0,
  double? Function(int, Map<String, dynamic>)? calculateRowHeight,
}) => SizedBox(
  width: 400,
  height: 300,
  child: FlutterTablePlus<Map<String, dynamic>>(
    key: _tableKey,
    columns: {'c0': _columns()['c0']!},
    data: _rows,
    rowId: (r) => r['id'] as String,
    theme: theme,
    scale: scale,
    calculateRowHeight: calculateRowHeight,
    wheelMotion: const WheelMotion.spring(),
  ),
);

/// Sends a wheel event at [at], the middle of the table when left out.
Future<void> _wheel(
  WidgetTester tester,
  double dy, {
  bool shift = false,
  Offset? at,
}) async {
  final mouse = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(
    mouse.hover(at ?? tester.getCenter(find.byKey(_tableKey))),
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
  group('wheelMotion left out', () {
    testWidgets('a wheel notch animates the body by default', (tester) async {
      await _pump(tester);
      await _wheel(tester, 120);

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen, anyElement(inExclusiveRange(0.0, 120.0)));
      expect(seen.last, 120.0);
    });
  });

  group('wheelMotion: null', () {
    testWidgets('a wheel notch moves the body at once', (tester) async {
      await _pump(tester, wheelMotion: null);
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

  group('over a scrollbar', () {
    testWidgets('a wheel notch animates the body, scrollbar in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));

      expect(
        _offsets(tester, Axis.vertical),
        everyElement(0.0),
        reason: 'nothing moves before the first frame',
      );
      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen, anyElement(inExclusiveRange(0.0, 60.0)));
      expect(seen.last, 60.0);
    });

    testWidgets('a wheel notch over the thumb animates the body too', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(
        tester,
        60,
        at: tester.getTopLeft(_strip(Axis.vertical)) + const Offset(6, 3),
      );

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen, anyElement(inExclusiveRange(0.0, 60.0)));
      expect(seen.last, 60.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

    testWidgets('Shift+wheel animates the body, header in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(
        tester,
        60,
        shift: true,
        at: tester.getCenter(_strip(Axis.horizontal)),
      );

      final seen = await _followFrames(tester, Axis.horizontal);
      expect(seen, anyElement(inExclusiveRange(0.0, 60.0)));
      expect(seen.last, 60.0);
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    });

    testWidgets('with no motion, a wheel notch moves the body at once', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));

      expect(_offsets(tester, Axis.vertical), everyElement(60.0));
    });

    testWidgets('notches during the motion add to its target', (tester) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      final strip = tester.getCenter(_strip(Axis.vertical));
      await _wheel(tester, 60, at: strip);
      await tester.pump(_frame);
      await tester.pump(_frame);
      await _wheel(tester, 60, at: strip);

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen.last, 120.0);
    });

    testWidgets('a notch over the body adds to a motion from the scrollbar', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 120, at: tester.getCenter(_strip(Axis.vertical)));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(
        _offsets(tester, Axis.vertical),
        everyElement(inExclusiveRange(0.0, 120.0)),
        reason: 'the second notch has to arrive while the motion runs',
      );
      await _wheel(tester, 60);

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen.last, 180.0);
    });

    testWidgets('a notch over the scrollbar adds to a motion from the body', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 120);
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(
        _offsets(tester, Axis.vertical),
        everyElement(inExclusiveRange(0.0, 120.0)),
        reason: 'the second notch has to arrive while the motion runs',
      );
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));

      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen.last, 180.0);
    });

    testWidgets('Ctrl+wheel changes scale without scrolling', (tester) async {
      final scales = <double>[];
      await _pump(
        tester,
        wheelMotion: const WheelMotion.spring(),
        onScaleChanged: scales.add,
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(scales, hasLength(1));
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    });

    testWidgets('a wheel past the end brings the body to its own end', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 100000, at: tester.getCenter(_strip(Axis.vertical)));
      await tester.pumpAndSettle();

      final body = _bodyPosition(tester, Axis.vertical);
      expect(body.pixels, body.maxScrollExtent);
    });

    testWidgets(
      'dragging the thumb still moves the body at once, and only then',
      (tester) async {
        await _pump(tester, wheelMotion: const WheelMotion.spring());
        final thumb = await tester.startGesture(
          tester.getTopLeft(_strip(Axis.vertical)) + const Offset(6, 3),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        await thumb.moveBy(const Offset(0, 30));
        await tester.pump();

        final moved = _offsets(tester, Axis.vertical);
        expect(moved.toSet(), hasLength(1));
        expect(moved.first, greaterThan(0.0));

        for (int i = 0; i < 5; i++) {
          await tester.pump(_frame);
          expect(_offsets(tester, Axis.vertical), moved);
        }
        await thumb.up();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.windows),
    );

    testWidgets('changing wheelMotion applies and keeps the offset', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));
      expect(_offsets(tester, Axis.vertical), everyElement(60.0));

      await _pump(tester, wheelMotion: const WheelMotion.spring());
      expect(_offsets(tester, Axis.vertical), everyElement(60.0));
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));
      final seen = await _followFrames(tester, Axis.vertical);
      expect(seen, anyElement(inExclusiveRange(60.0, 120.0)));
      expect(seen.last, 120.0);

      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));
      expect(_offsets(tester, Axis.vertical), everyElement(180.0));
    });

    testWidgets(
      'an empty table with a placeholder still takes Shift+wheel',
      (tester) async {
        await _pump(
          tester,
          wheelMotion: null,
          data: const [],
          noDataWidget: const Text('none'),
        );
        await _wheel(
          tester,
          60,
          shift: true,
          at: tester.getCenter(_strip(Axis.horizontal)),
        );

        expect(_offsets(tester, Axis.horizontal), everyElement(60.0));
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.windows,
      }),
    );
  });

  group('on the desktop, over a scrollbar', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.windows);

    // The track is 232 high, and a click pages by 80% of it.
    const double page = 185.6;

    Future<void> clickTrack(WidgetTester tester) async {
      final click = await tester.startGesture(
        tester.getTopLeft(_strip(Axis.vertical)) + const Offset(6, 150),
        kind: PointerDeviceKind.mouse,
      );
      await click.up();
    }

    testWidgets('a track click after a wheel to the end stays in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      final strip = tester.getCenter(_strip(Axis.vertical));
      await _wheel(tester, 100000, at: strip);
      await tester.pumpAndSettle();
      final end = _offsets(tester, Axis.vertical);
      expect(end.toSet(), hasLength(1));

      await clickTrack(tester);
      await tester.pumpAndSettle();
      final clicked = _offsets(tester, Axis.vertical);
      expect(clicked.toSet(), hasLength(1));
      expect(clicked.first, moreOrLessEquals(end.first - page));

      await _wheel(tester, 60, at: strip);
      await tester.pumpAndSettle();
      final notched = _offsets(tester, Axis.vertical);
      expect(notched.toSet(), hasLength(1));
      expect(notched.first, moreOrLessEquals(clicked.first + 60));
    }, variant: desktop);

    testWidgets('notches near the end reach the end, scrollbar in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      final strip = tester.getCenter(_strip(Axis.vertical));
      await _wheel(tester, 100000, at: strip);
      await tester.pumpAndSettle();
      final end = _offsets(tester, Axis.vertical).first;
      await _wheel(tester, -68, at: strip);
      await tester.pumpAndSettle();

      await _wheel(tester, 60, at: strip);
      await tester.pumpAndSettle();
      expect(_offsets(tester, Axis.vertical), everyElement(end - 8));
      await _wheel(tester, 60, at: strip);
      await tester.pumpAndSettle();
      expect(_offsets(tester, Axis.vertical), everyElement(end));
    }, variant: desktop);

    testWidgets('a track click stops a motion and takes effect', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 300, at: tester.getCenter(_strip(Axis.vertical)));
      await tester.pump(_frame);
      expect(
        _offsets(tester, Axis.vertical),
        everyElement(0.0),
        reason: 'the click has to arrive before the motion has moved',
      );

      await clickTrack(tester);
      await tester.pumpAndSettle();

      final offsets = _offsets(tester, Axis.vertical);
      expect(offsets.toSet(), hasLength(1));
      expect(offsets.first, moreOrLessEquals(page));
    }, variant: desktop);

    testWidgets('a notch during a track animation is not lost', (tester) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await clickTrack(tester);
      await tester.pump(_frame);
      await tester.pump(_frame);
      final before = _offsets(tester, Axis.vertical);
      expect(
        before,
        everyElement(inExclusiveRange(0.0, page)),
        reason: 'the notch has to arrive during the track animation',
      );

      await _wheel(tester, 60, at: tester.getCenter(_strip(Axis.vertical)));
      await tester.pumpAndSettle();

      final offsets = _offsets(tester, Axis.vertical);
      expect(offsets.toSet(), hasLength(1));
      expect(offsets.first, moreOrLessEquals(before.first + 60));
    }, variant: desktop);

    testWidgets('pressing the thumb stops a motion, and a drag then takes', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 300);
      for (int i = 0; i < 3; i++) {
        await tester.pump(_frame);
      }
      final thumb = await tester.startGesture(
        tester.getTopLeft(_strip(Axis.vertical)) + const Offset(6, 3),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(_frame);
      final held = _offsets(tester, Axis.vertical);
      expect(held.first, inExclusiveRange(0.0, 300.0));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(_offsets(tester, Axis.vertical), held);

      await thumb.moveBy(const Offset(0, 30));
      await tester.pump(_frame);
      final dragged = _offsets(tester, Axis.vertical);
      expect(dragged.toSet(), hasLength(1));
      expect(dragged.first, greaterThan(held.first));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(_offsets(tester, Axis.vertical), dragged);
      await thumb.up();
    }, variant: desktop);

    testWidgets('a tilt wheel over the horizontal scrollbar animates', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        mouse.hover(tester.getCenter(_strip(Axis.horizontal))),
      );
      await tester.sendEventToBinding(mouse.scroll(const Offset(60, 0)));

      final seen = await _followFrames(tester, Axis.horizontal);
      expect(seen, anyElement(inExclusiveRange(0.0, 60.0)));
      expect(seen.last, 60.0);
    }, variant: desktop);

    for (final (name, table) in <(String, Widget Function())>[
      (
        'a track border',
        () => _pageTable(
          theme: TablePlusTheme(
            scrollbarTheme: TablePlusScrollbarTheme(
              trackBorder: Border.all(width: 1),
            ),
          ),
        ),
      ),
      ('a fractional scale', () => _pageTable(scale: 1.1)),
      (
        'fractional row heights',
        () => _pageTable(calculateRowHeight: (_, _) => 33.3),
      ),
    ]) {
      testWidgets('with $name, a notch past the end goes to the page', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pageController = ScrollController();
        addTearDown(pageController.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: pageController,
                child: Column(
                  children: [table(), const SizedBox(height: 2000)],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await _wheel(tester, 1000000);
        await tester.pumpAndSettle();
        final strip = tester.getCenter(_strip(Axis.vertical));
        final seen = <double>[];
        for (int i = 0; i < 3; i++) {
          await _wheel(tester, 60, at: strip);
          await tester.pumpAndSettle();
          seen.add(pageController.offset);
        }

        expect(seen, [60.0, 120.0, 180.0]);
      }, variant: desktop);
    }
  });

  group('Shift+wheel over the horizontal scrollbar', () {
    final desktops = TargetPlatformVariant.only(TargetPlatform.windows);
    const everyDesktop = TargetPlatformVariant({
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    });

    Offset thumb(WidgetTester tester) =>
        tester.getTopLeft(_strip(Axis.horizontal)) + const Offset(3, 6);

    testWidgets('animates the body, header and scrollbar in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 60, shift: true, at: thumb(tester));

      final seen = await _followFrames(tester, Axis.horizontal);
      expect(seen, anyElement(inExclusiveRange(0.0, 60.0)));
      expect(seen.last, 60.0);
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    }, variant: everyDesktop);

    testWidgets('with no motion moves at once', (tester) async {
      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, shift: true, at: thumb(tester));

      expect(_offsets(tester, Axis.horizontal), everyElement(60.0));
    }, variant: desktops);

    testWidgets('where the scrollbar passes the wheel on, moves once', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, shift: true, at: thumb(tester));

      expect(_offsets(tester, Axis.horizontal), everyElement(60.0));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('adds to a motion from the body', (tester) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      await _wheel(tester, 120, shift: true);
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(
        _offsets(tester, Axis.horizontal),
        everyElement(inExclusiveRange(0.0, 120.0)),
        reason: 'the second notch has to arrive while the motion runs',
      );
      await _wheel(tester, 60, shift: true, at: thumb(tester));

      final seen = await _followFrames(tester, Axis.horizontal);
      expect(seen.last, 180.0);
    }, variant: desktops);

    testWidgets('moves further in right-to-left text', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: FlutterTablePlus<Map<String, dynamic>>(
                    key: _tableKey,
                    columns: _columns(),
                    data: _rows,
                    rowId: (r) => r['id'] as String,
                    wheelMotion: null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _wheel(tester, -60, shift: true);
      await tester.pump();
      expect(
        _offsets(tester, Axis.horizontal),
        everyElement(60.0),
        reason: 'the wheel over the body sets which way the scrollbar goes',
      );

      await _wheel(
        tester,
        -60,
        shift: true,
        at: tester.getCenter(_strip(Axis.horizontal)),
      );
      await tester.pump();
      expect(_offsets(tester, Axis.horizontal), everyElement(120.0));
    }, variant: desktops);

    testWidgets('moves nothing without the modifier', (tester) async {
      await _pump(tester, wheelMotion: null);
      await _wheel(tester, 60, at: thumb(tester));

      expect(_offsets(tester, Axis.horizontal), everyElement(0.0));
      expect(_offsets(tester, Axis.vertical), everyElement(0.0));
    }, variant: desktops);

    testWidgets('a trackpad scroll with the modifier moves nothing', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: null);
      final pad = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pad.hover(thumb(tester)));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(pad.scroll(const Offset(0, 60)));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(_offsets(tester, Axis.horizontal), everyElement(0.0));
    }, variant: desktops);

    testWidgets('moves nothing while the body refuses the modifier', (
      tester,
    ) async {
      final scales = <double>[];
      await _pump(
        tester,
        wheelMotion: const WheelMotion.spring(),
        onScaleChanged: scales.add,
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await _wheel(tester, 60, shift: true, at: thumb(tester));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(scales, hasLength(1));
      expect(_offsets(tester, Axis.horizontal), everyElement(0.0));
    }, variant: desktops);

    testWidgets('during a thumb drag throws nothing and keeps in step', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: const WheelMotion.spring());
      final at = thumb(tester);
      final drag = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await tester.pump(_frame);
      await drag.moveBy(const Offset(20, 0));
      await tester.pump(_frame);

      final mouse = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(at + const Offset(20, 0)));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 60)));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump(_frame);
      await drag.moveBy(const Offset(20, 0));
      await tester.pump(_frame);
      await drag.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(_offsets(tester, Axis.horizontal).toSet(), hasLength(1));
    }, variant: desktops);

    testWidgets('at the end goes to a horizontal page around the table', (
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
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 400,
                    height: 300,
                    child: FlutterTablePlus<Map<String, dynamic>>(
                      key: _tableKey,
                      columns: _columns(),
                      data: _rows,
                      rowId: (r) => r['id'] as String,
                      wheelMotion: const WheelMotion.spring(),
                    ),
                  ),
                  const SizedBox(width: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _wheel(tester, 100000, shift: true, at: thumb(tester));
      await tester.pumpAndSettle();
      expect(page.offset, 0.0, reason: 'the table takes it up to its end');
      final end = _offsets(tester, Axis.horizontal);
      expect(end.toSet(), hasLength(1));
      expect(end.first, greaterThan(0.0));

      await _wheel(tester, 60, shift: true, at: thumb(tester));
      await tester.pumpAndSettle();
      expect(page.offset, 60.0);
    }, variant: desktops);
  });

  testWidgets('the vertical scrollbar has as much to scroll as the body', (
    tester,
  ) async {
    await _pump(tester, wheelMotion: null);
    final content = tester.getSize(
      find
          .descendant(
            of: _strip(Axis.vertical),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    final body = _bodyPosition(tester, Axis.vertical);

    expect(content.height, body.maxScrollExtent + body.viewportDimension);
  });

  group('changing wheelMotion', () {
    testWidgets('applies from the next notch and keeps the offset', (
      tester,
    ) async {
      await _pump(tester, wheelMotion: null);
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

      await _pump(tester, wheelMotion: null);
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

    testWidgets('a notch over the scrollbar the motion cannot use too', (
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

      final strip = tester.getCenter(_strip(Axis.vertical));
      await _wheel(tester, 100000, at: strip);
      await tester.pump(_frame);
      await tester.pump(_frame);
      await _wheel(tester, 60, at: strip);
      await tester.pumpAndSettle();

      expect(page.offset, 60.0);
    });
  });
}
