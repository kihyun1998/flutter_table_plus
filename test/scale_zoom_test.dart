import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for the scale feature: scaled rendering, Ctrl+wheel ->
// onScaleChanged, and scroll blocking while the scale modifier is held.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns(double width) => {
  'name': TablePlusColumn<Map<String, dynamic>>(
    key: 'name',
    label: 'Name',
    order: 0,
    valueAccessor: (r) => r['name'],
    width: width,
  ),
};

Future<void> _pump(
  WidgetTester tester, {
  double scale = 1.0,
  ValueChanged<double>? onScaleChanged,
  int rows = 3,
  double columnWidth = 200,
  bool? blockModifierScroll,
  WheelMotion? wheelMotion = const WheelMotion.spring(),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FlutterTablePlus<Map<String, dynamic>>(
          columns: _columns(columnWidth),
          data: [
            for (int i = 0; i < rows; i++) {'id': '$i', 'name': 'R$i'},
          ],
          rowId: (r) => r['id'] as String,
          scale: scale,
          onScaleChanged: onScaleChanged,
          blockModifierScroll: blockModifierScroll,
          wheelMotion: wheelMotion,
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
  final loc = tester.getCenter(
    find.byType(FlutterTablePlus<Map<String, dynamic>>),
  );
  final pointer = TestPointer(tester.nextPointer, PointerDeviceKind.mouse);
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

  testWidgets('Ctrl+wheel up requests a larger scale (scale + step)', (
    tester,
  ) async {
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

  testWidgets('Ctrl+wheel down requests a smaller scale (scale - step)', (
    tester,
  ) async {
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

  testWidgets('Ctrl+tilt requests nothing, and scrolls only if not blocked', (
    tester,
  ) async {
    for (final (block, moved) in <(bool, double)>[(true, 0), (false, 60)]) {
      final requested = <double>[];
      await _pump(
        tester,
        rows: 200,
        columnWidth: 3000,
        wheelMotion: null,
        blockModifierScroll: block,
        onScaleChanged: requested.add,
      );
      final body = find.byType(FlutterTablePlus<Map<String, dynamic>>);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(tester.getCenter(body)));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendEventToBinding(pointer.scroll(const Offset(60, 0)));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(requested, isEmpty);
      expect(
        tester
            .stateList<ScrollableState>(find.byType(Scrollable))
            .firstWhere((s) => s.position.axis == Axis.horizontal)
            .position
            .pixels,
        moved,
      );
      await tester.pumpWidget(const SizedBox());
    }
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('Ctrl+wheel zooms instead of scrolling; a plain wheel scrolls', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _pump(tester, onScaleChanged: (_) {}, rows: 40); // scrollable

      // A mid-viewport row that stays visible through a small scroll.
      final start = tester.getCenter(find.text('R5')).dy;

      // Ctrl+wheel is consumed for zoom -> the body must NOT scroll.
      await _ctrlWheel(tester, 100);
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('R5')).dy,
        start,
        reason: 'Ctrl+wheel zooms, it does not scroll',
      );

      // A plain wheel (no modifier) scrolls the body.
      final loc = tester.getCenter(
        find.byType(FlutterTablePlus<Map<String, dynamic>>),
      );
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(loc));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 100)));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('R5')).dy,
        lessThan(start),
        reason: 'a plain wheel scrolls',
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  group('the offsets across a scale change', () {
    final windows = TargetPlatformVariant.only(TargetPlatform.windows);

    List<ScrollPosition> positions(WidgetTester tester, Axis axis) => tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .map((s) => s.position)
        .where((p) => p.axis == axis)
        .toList();

    Future<void> wheel(
      WidgetTester tester,
      double dy, {
      bool shift = false,
    }) async {
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(
          tester.getCenter(find.byType(FlutterTablePlus<Map<String, dynamic>>)),
        ),
      );
      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
    }

    void expectOffset(WidgetTester tester, Axis axis, double offset) {
      expect(
        positions(tester, axis).map((p) => p.pixels),
        everyElement(moreOrLessEquals(offset)),
      );
    }

    testWidgets('a Ctrl+wheel the caller ignored leaves nothing behind', (
      tester,
    ) async {
      void ignore(double _) {}
      Future<void> pump(double scale) => _pump(
        tester,
        scale: scale,
        onScaleChanged: ignore,
        rows: 200,
        columnWidth: 3000,
      );
      await pump(1.0);
      await _ctrlWheel(tester, -60);
      await wheel(tester, 600);
      await wheel(tester, 300, shift: true);
      expectOffset(tester, Axis.vertical, 600);
      expectOffset(tester, Axis.horizontal, 300);

      await pump(1.5);

      expectOffset(tester, Axis.vertical, 900);
      expectOffset(tester, Axis.horizontal, 450);
    }, variant: windows);

    testWidgets('a Ctrl+wheel the caller applied keeps the place', (
      tester,
    ) async {
      double? requested;
      await _pump(
        tester,
        onScaleChanged: (s) => requested = s,
        rows: 200,
        columnWidth: 3000,
      );
      await wheel(tester, 600);
      await wheel(tester, 300, shift: true);

      await _ctrlWheel(tester, -60);
      expect(requested, 1.05);
      expectOffset(tester, Axis.vertical, 600);
      await _pump(
        tester,
        scale: requested!,
        onScaleChanged: (s) => requested = s,
        rows: 200,
        columnWidth: 3000,
      );

      expectOffset(tester, Axis.vertical, 630);
      expectOffset(tester, Axis.horizontal, 315);
    }, variant: windows);

    testWidgets('a scale applied late takes the offset of that moment', (
      tester,
    ) async {
      void ignore(double _) {}
      await _pump(tester, onScaleChanged: ignore, rows: 200);
      await _ctrlWheel(tester, -60);
      await wheel(tester, 600);

      await _pump(tester, scale: 1.05, onScaleChanged: ignore, rows: 200);

      expectOffset(tester, Axis.vertical, 630);
    }, variant: windows);

    testWidgets(
      'Ctrl+Shift+wheel over the horizontal scrollbar moves nothing',
      (tester) async {
        final requested = <double>[];
        await _pump(
          tester,
          onScaleChanged: requested.add,
          rows: 200,
          columnWidth: 3000,
        );
        await wheel(tester, 300, shift: true);
        final strip = find.descendant(
          of: find.byType(Scrollbar),
          matching: find.byWidgetPredicate(
            (w) =>
                w is SingleChildScrollView &&
                w.scrollDirection == Axis.horizontal,
          ),
        );

        final pointer = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(pointer.hover(tester.getCenter(strip)));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(requested, hasLength(1));
        expectOffset(tester, Axis.horizontal, 300);
      },
      variant: windows,
    );

    testWidgets('a scale down from the end stays at the end', (tester) async {
      await _pump(tester, rows: 200);
      await wheel(tester, 1000000);
      final end = positions(tester, Axis.vertical).first;
      expect(end.pixels, end.maxScrollExtent);
      final atOne = end.pixels;

      await _pump(tester, scale: 0.5, rows: 200);

      final after = positions(tester, Axis.vertical);
      expect(
        after.first.maxScrollExtent,
        lessThan(atOne * 0.5),
        reason: 'the ratio alone has to land past the new end',
      );
      expectOffset(tester, Axis.vertical, after.first.maxScrollExtent);
    }, variant: windows);
  });

  group('blockModifierScroll', () {
    final windows = TargetPlatformVariant.only(TargetPlatform.windows);

    double offset(WidgetTester tester, Axis axis) => tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((s) => s.position.axis == axis)
        .position
        .pixels;

    Finder strip(Axis axis) => find.descendant(
      of: find.byType(Scrollbar),
      matching: find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == axis,
      ),
    );

    Future<void> ctrlWheelAt(
      WidgetTester tester,
      Offset at, {
      bool shift = false,
    }) async {
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(at));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
    }

    // The flag and the callback, and what one Ctrl+wheel over the body and one
    // Ctrl+Shift+wheel over it should do: requests sent, then each axis.
    for (final (block, callback, requests, moved)
        in <(bool?, bool, int, double)>[
          (null, true, 2, 0),
          (null, false, 0, 60),
          (true, true, 2, 0),
          (true, false, 0, 0),
          (false, true, 0, 60),
          (false, false, 0, 60),
        ]) {
      final name = 'flag $block, ${callback ? 'a' : 'no'} callback';

      testWidgets('$name, over the body', (tester) async {
        var sent = 0;
        await _pump(
          tester,
          rows: 200,
          columnWidth: 3000,
          wheelMotion: null,
          blockModifierScroll: block,
          onScaleChanged: callback ? (_) => sent++ : null,
        );
        final body = tester.getCenter(
          find.byType(FlutterTablePlus<Map<String, dynamic>>),
        );

        await ctrlWheelAt(tester, body);
        expect(offset(tester, Axis.vertical), moved);
        await ctrlWheelAt(tester, body, shift: true);
        expect(offset(tester, Axis.horizontal), moved);
        expect(sent, requests);
      }, variant: windows);

      testWidgets('$name, over the vertical scrollbar', (tester) async {
        var sent = 0;
        await _pump(
          tester,
          rows: 200,
          columnWidth: 3000,
          wheelMotion: null,
          blockModifierScroll: block,
          onScaleChanged: callback ? (_) => sent++ : null,
        );

        await ctrlWheelAt(tester, tester.getCenter(strip(Axis.vertical)));

        expect(offset(tester, Axis.vertical), moved);
        expect(sent, requests ~/ 2);
      }, variant: windows);
    }

    for (final (block, moved) in <(bool, double)>[(true, 0), (false, 60)]) {
      testWidgets(
        'flag $block, Ctrl+Shift+wheel over the horizontal scrollbar',
        (tester) async {
          var sent = 0;
          await _pump(
            tester,
            rows: 200,
            columnWidth: 3000,
            wheelMotion: null,
            blockModifierScroll: block,
            onScaleChanged: (_) => sent++,
          );

          await ctrlWheelAt(
            tester,
            tester.getCenter(strip(Axis.horizontal)),
            shift: true,
          );

          expect(offset(tester, Axis.horizontal), moved);
          expect(sent, block ? 1 : 0);
        },
        variant: windows,
      );
    }

    for (final (name, block, callback, tableMoved, pageMoved)
        in <(String, bool, bool, double, double)>[
          ('a table that blocks leaves it to the page', true, false, 0, 60),
          ('a table that scrolls keeps it', false, true, 60, 0),
        ]) {
      testWidgets('inside a page, $name', (tester) async {
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
                      height: 300,
                      child: FlutterTablePlus<Map<String, dynamic>>(
                        columns: _columns(200),
                        data: [
                          for (int i = 0; i < 200; i++)
                            {'id': '$i', 'name': 'R$i'},
                        ],
                        rowId: (r) => r['id'] as String,
                        wheelMotion: null,
                        blockModifierScroll: block,
                        onScaleChanged: callback ? (_) {} : null,
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

        await ctrlWheelAt(
          tester,
          tester.getCenter(find.byType(FlutterTablePlus<Map<String, dynamic>>)),
        );

        expect(page.offset, pageMoved);
        final table = tester
            .stateList<ScrollableState>(
              find.descendant(
                of: find.byType(FlutterTablePlus<Map<String, dynamic>>),
                matching: find.byType(Scrollable),
              ),
            )
            .firstWhere((s) => s.position.axis == Axis.vertical);
        expect(table.position.pixels, tableMoved);
      }, variant: windows);
    }
  });
}
