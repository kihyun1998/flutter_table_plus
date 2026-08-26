import 'package:example/preview/preview_frame.dart';
import 'package:example/preview/preview_stage.dart';
import 'package:example/preview/viewport_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The frame shrinks a viewport into the room it has, so a reader sees all of a
// desktop layout at once instead of a 1:1 slice of one.
//
// The last group is why this file exists at all. #101 refused to scale, on the
// grounds that a transform above the table put drag selection's viewport-local
// coordinate frame in question — and recorded, correctly, that this was not
// proven. It was measured afterwards and it was wrong: `Transform` applies the
// inverse to hit testing, so `event.localPosition` arrives already in the child's
// untransformed frame. The evidence that had looked damning was a test whose own
// arithmetic mixed scaled screen coordinates with unscaled logical ones.
//
// That measurement is here rather than in a comment, because it is the thing the
// whole fit mode rests on.

const double _rowHeight = 40;
const double _headerHeight = 40;

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  for (final key in ['a', 'b', 'c']) {
    b.addColumn(
      key,
      TablePlusColumn<Map<String, dynamic>>(
        key: key,
        label: key,
        order: 0,
        width: 200,
        valueAccessor: (r) => r[key],
      ),
    );
  }
  return b.build();
}

List<Map<String, dynamic>> _rows(int n) => List.generate(
      n,
      (i) => {'id': '$i', 'a': 'a$i', 'b': 'b$i', 'c': 'c$i'},
    );

void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// The on-screen size of the stage, which is the viewport size times whatever
/// factor the frame chose.
///
/// `getRect`, not `getSize`. Inside a `FittedBox` the stage still *lays out* at
/// its full viewport size — that is the whole point, the child is unaware it is
/// being shrunk — and only its screen rect carries the factor. Reaching for
/// `getSize` here mixes local and screen space, which is the same arithmetic
/// error that made #101 believe scaling broke the drag frame.
Size _renderedStageSize(WidgetTester tester) =>
    tester.getRect(find.byType(PreviewStage)).size;

Future<void> _pumpFrame(
  WidgetTester tester, {
  required ViewportSpec spec,
  required bool fit,
  required Size surface,
  Widget? child,
}) async {
  _surface(tester, surface);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: PreviewFrame(
        spec: spec,
        fit: fit,
        child: child ?? const SizedBox.expand(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('fitting', () {
    testWidgets('shrinks a viewport wider than the room it has',
        (tester) async {
      await _pumpFrame(
        tester,
        spec: ViewportSpec.desktop, // 1440 x 900
        fit: true,
        surface: const Size(800, 700),
      );

      final rendered = _renderedStageSize(tester);
      expect(rendered.width, lessThan(ViewportSpec.desktop.width),
          reason: 'the frame drew 1440 logical pixels into 800 without '
              'shrinking, which is the clipped slice fit mode replaces');

      // The whole viewport is on screen, aspect intact.
      expect(
          rendered.width / rendered.height,
          closeTo(
              ViewportSpec.desktop.width / ViewportSpec.desktop.height, 0.01));
      expect(rendered.width, lessThanOrEqualTo(800));
    });

    testWidgets('leaves a viewport that already fits alone', (tester) async {
      await _pumpFrame(
        tester,
        spec: ViewportSpec.mobile, // 390 x 844
        fit: true,
        surface: const Size(1400, 1200),
      );

      // Never scales up: a phone blown up to fill a desktop pane shows something
      // no phone shows.
      expect(_renderedStageSize(tester), ViewportSpec.mobile.size);
    });

    testWidgets('says which factor it used', (tester) async {
      await _pumpFrame(
        tester,
        spec: ViewportSpec.desktop,
        fit: true,
        surface: const Size(800, 700),
      );

      // A shrunken preview is otherwise indistinguishable from a small table.
      expect(find.textContaining('1440 × 900'), findsOneWidget);
      expect(find.textContaining('×', skipOffstage: false), findsWidgets);
      expect(find.textContaining('1:1'), findsNothing);
    });

    testWidgets('1:1 keeps real pixels and does not shrink', (tester) async {
      await _pumpFrame(
        tester,
        spec: ViewportSpec.desktop,
        fit: false,
        surface: const Size(800, 700),
      );

      expect(_renderedStageSize(tester), ViewportSpec.desktop.size);
      expect(find.textContaining('1:1'), findsOneWidget);
    });
  });

  group('interaction survives the scale', () {
    testWidgets('a drag inside a shrunken frame selects the rows it crosses',
        (tester) async {
      // Promoted from the throwaway probe that settled this. Rendered at roughly
      // half size, a drag from row 0 to row 2 must still select rows 0..2 — the
      // pointer positions are in screen space and the table's own frame is not.
      final ends = <Set<String>>[];
      final tableKey = GlobalKey();

      await _pumpFrame(
        tester,
        spec: ViewportSpec.mobile, // 390 x 844
        fit: true,
        surface: const Size(300, 500),
        child: FlutterTablePlus<Map<String, dynamic>>(
          key: tableKey,
          columns: _columns(),
          data: _rows(8),
          rowId: (r) => r['id'] as String,
          isSelectable: true,
          selectionMode: SelectionMode.multiple,
          enableDragSelection: true,
          theme: const TablePlusTheme(
            bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
            headerTheme: TablePlusHeaderTheme(height: _headerHeight),
          ),
          onDragSelectionUpdate: (ids) {},
          onDragSelectionEnd: (ids) => ends.add(Set.of(ids)),
        ),
      );

      final rect = tester.getRect(find.byKey(tableKey));
      final scale = rect.width / ViewportSpec.mobile.width;
      expect(scale, lessThan(1),
          reason: 'nothing was scaled, so this proves nothing about scaling');

      // Row offsets are logical; the rect is screen space. Mixing the two is the
      // arithmetic error that made #101 believe scaling broke the frame.
      Offset at(double row) =>
          rect.topLeft +
          Offset(60 * scale, (_headerHeight + row * _rowHeight) * scale);

      final gesture = await tester.startGesture(at(0.5));
      await tester.pump();
      await gesture.moveTo(at(2.5));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(ends, hasLength(1));
      expect(ends.single, {'0', '1', '2'},
          reason:
              'the drag landed on different rows once the frame was scaled');
    });
  });

  group('an overlay belongs to the viewport it opens in', () {
    // `Draggable` puts its feedback in the nearest `Overlay`, and `just_tooltip`
    // does the same with its tooltip — including reading that overlay's render
    // box to place itself. With no overlay inside the frame, "nearest" is the
    // app's root one, which sits *above* the `FittedBox`. The frame then draws
    // the table at 0.47x and the thing dragged out of it at 1:1, roughly twice
    // the size of the row it came from, floating over the whole window.
    testWidgets('a drag feedback is drawn at the scale of its own frame',
        (tester) async {
      _surface(tester, const Size(700, 500));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PreviewFrame(
            spec: ViewportSpec.desktop,
            child: Center(
              child: Draggable<int>(
                data: 1,
                feedback: SizedBox(
                  key: ValueKey('feedback'),
                  width: 200,
                  height: 100,
                  child: ColoredBox(color: Color(0xFF000000)),
                ),
                // Coloured, not bare: a `SizedBox` with no child is invisible
                // to hit testing, so the pointer would go straight past the
                // `Draggable` and no drag would start.
                child: SizedBox(
                  key: ValueKey('source'),
                  width: 200,
                  height: 100,
                  child: ColoredBox(color: Color(0xFF888888)),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final source = tester.getRect(find.byKey(const ValueKey('source')));
      // The premise: this frame really is shrunk. Without it the test passes
      // at 1:1 and says nothing.
      expect(source.width, lessThan(190),
          reason: 'the frame did not scale, so there is nothing to escape');

      final gesture = await tester.startGesture(source.center);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(12, 0));
        await tester.pump();
      }

      final feedback = tester.getRect(find.byKey(const ValueKey('feedback')));
      expect(feedback.width, closeTo(source.width, 0.5),
          reason: 'the feedback is drawn at a different scale from the frame '
              'it was dragged out of — it went to an overlay above the '
              'FittedBox');
      expect(feedback.height, closeTo(source.height, 0.5));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('because the overlay it lands in is inside the frame',
        (tester) async {
      // The structural half, and the one that names the fix. In the broken
      // state the feedback is a child of the app's root overlay, so it is not
      // a descendant of the frame at all — a scale assertion alone would leave
      // someone free to "fix" it by scaling the feedback by hand.
      _surface(tester, const Size(700, 500));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PreviewFrame(
            spec: ViewportSpec.desktop,
            child: Center(
              child: Draggable<int>(
                data: 1,
                feedback: SizedBox(
                  key: ValueKey('feedback'),
                  width: 200,
                  height: 100,
                  child: ColoredBox(color: Color(0xFF000000)),
                ),
                child: SizedBox(
                  key: ValueKey('source'),
                  width: 200,
                  height: 100,
                  child: ColoredBox(color: Color(0xFF888888)),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final source = tester.getRect(find.byKey(const ValueKey('source')));
      final gesture = await tester.startGesture(source.center);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(12, 0));
        await tester.pump();
      }

      expect(
        find.descendant(
          of: find.byType(PreviewStage),
          matching: find.byKey(const ValueKey('feedback')),
        ),
        findsOneWidget,
        reason: 'the feedback went to an overlay outside the stage',
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
