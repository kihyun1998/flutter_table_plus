import 'package:example/preview/preview_stage.dart';
import 'package:example/preview/viewport_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The stage claims a table inside it behaves like a genuinely narrow table.
// That claim has two halves and they fail differently.
//
// The layout half is cheap: `flutter_table_plus` resolves its widths from its
// own constraints, so a `SizedBox` settles it. The reporting half is the one
// that fails silently — consumer code inside the frame is entitled to branch on
// `MediaQuery.of(context).size`, and a preview that hands it the host window's
// width makes that branch take the wrong arm with nothing on screen looking
// wrong. Asserting only one of the two is the bug these tests exist to prevent.
//
// The last group is the reason this ticket exists at all. `docs/map/invariant/
// viewport-local-frame.md` says a frame violation "reproduces only when the
// horizontal scroll is non-zero, which is why it survives a manual check on a
// table narrow enough to fit". A phone-width preview is the first place this
// example ever enters that condition, and the package's own drag suite never
// does — `jumpTo` appears zero times in both of its drag test files.

const double _rowHeight = 40;
const double _headerHeight = 40;

/// Columns totalling 600px, so a 390-wide viewport must clip and scroll while a
/// 1440-wide one has room to spare.
Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  for (final (key, width) in [
    ('name', 200.0),
    ('department', 200.0),
    ('position', 200.0),
  ]) {
    b.addColumn(
      key,
      TablePlusColumn<Map<String, dynamic>>(
        key: key,
        label: key,
        order: 0,
        width: width,
        valueAccessor: (r) => r[key],
      ),
    );
  }
  return b.build();
}

List<Map<String, dynamic>> _rows(int n) => List.generate(
      n,
      (i) => {
        'id': '$i',
        'name': 'n$i',
        'department': 'd$i',
        'position': 'p$i',
      },
    );

/// The stage's own size is what a viewport switch changes; the test surface has
/// to be big enough to hold the largest one asked for, or the widget is clipped
/// and every assertion about it is about a clipped widget.
void _surface(WidgetTester tester, {Size size = const Size(1600, 1200)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// The horizontal scroll position the table body actually uses.
///
/// Found by property rather than by index: the table builds several
/// `Scrollable`s and their order is an implementation detail, but only one is
/// horizontal with somewhere to go.
ScrollPosition _horizontalBodyPosition(WidgetTester tester) {
  final states = tester.stateList<ScrollableState>(find.byType(Scrollable));
  return states.map((s) => s.position).firstWhere(
        (p) => p.axis == Axis.horizontal && p.maxScrollExtent > 0,
        orElse: () => throw StateError(
          'no horizontal scrollable with anywhere to go — the table is not '
          'clipped, so this test is not measuring what it claims to',
        ),
      );
}

void main() {
  group('ViewportSpec', () {
    test('the named viewports carry the sizes their labels claim', () {
      expect(ViewportSpec.desktop.size, const Size(1440, 900));
      expect(ViewportSpec.tablet.size, const Size(834, 1112));
      expect(ViewportSpec.mobile.size, const Size(390, 844));

      for (final v in ViewportSpec.values) {
        expect(v.label, contains('${v.size.width.toInt()}'),
            reason: 'the label promises a width the spec does not carry');
        expect(v.label, contains('${v.size.height.toInt()}'));
      }
    });

    test('chrome is kept at the two wide viewports and dropped at the phone',
        () {
      expect(ViewportSpec.desktop.showsChrome, isTrue);
      expect(ViewportSpec.tablet.showsChrome, isTrue);
      expect(ViewportSpec.mobile.showsChrome, isFalse);
    });

    test('byId round-trips every value and refuses an unknown one', () {
      for (final v in ViewportSpec.values) {
        expect(ViewportSpec.byId(v.id), v);
      }
      expect(() => ViewportSpec.byId('watch'), throwsArgumentError);
    });
  });

  group('PreviewStage', () {
    testWidgets('lays the child out at the size AND reports that size',
        (tester) async {
      _surface(tester);

      late Size reported;
      final probe = Builder(builder: (context) {
        reported = MediaQuery.of(context).size;
        return const SizedBox.expand();
      });

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
        ),
      ));

      // Both halves. Either one alone passes while the stage is half-built.
      expect(tester.getSize(find.byWidget(probe)), const Size(390, 844),
          reason: 'the child was not laid out at the viewport size');
      expect(reported, const Size(390, 844),
          reason: 'the child was laid out narrow but told it had the window');
    });

    testWidgets('reports no insets rather than inheriting the host window\'s',
        (tester) async {
      _surface(tester);

      late MediaQueryData seen;
      final probe = Builder(builder: (context) {
        seen = MediaQuery.of(context);
        return const SizedBox.expand();
      });

      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1600, 1200),
            padding: EdgeInsets.only(top: 44, bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: Center(
            child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
          ),
        ),
      ));

      expect(seen.padding, EdgeInsets.zero);
      expect(seen.viewInsets, EdgeInsets.zero);
      expect(seen.viewPadding, EdgeInsets.zero);
    });

    testWidgets('carries the rest of the host data through', (tester) async {
      _surface(tester);

      late MediaQueryData seen;
      final probe = Builder(builder: (context) {
        seen = MediaQuery.of(context);
        return const SizedBox.expand();
      });

      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1600, 1200),
            textScaler: TextScaler.linear(1.3),
            platformBrightness: Brightness.dark,
          ),
          child: Center(
            child: PreviewStage(spec: ViewportSpec.mobile, child: probe),
          ),
        ),
      ));

      // The stage narrows a viewport; it is not a device simulator and must not
      // quietly discard what it was not asked about.
      expect(seen.textScaler, const TextScaler.linear(1.3));
      expect(seen.platformBrightness, Brightness.dark);
    });

    testWidgets('a table has room at desktop and is clipped at phone width',
        (tester) async {
      _surface(tester);

      Future<void> pump(ViewportSpec spec) async {
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: PreviewStage(
              spec: spec,
              child: FlutterTablePlus<Map<String, dynamic>>(
                columns: _columns(),
                data: _rows(6),
                rowId: (r) => r['id'] as String,
                theme: const TablePlusTheme(
                  bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
                  headerTheme: TablePlusHeaderTheme(height: _headerHeight),
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
      }

      await pump(ViewportSpec.desktop);
      final wide = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .where((p) => p.axis == Axis.horizontal)
          .map((p) => p.maxScrollExtent);
      expect(wide.every((e) => e == 0), isTrue,
          reason:
              '600px of columns in a 1440px viewport has nowhere to scroll');

      await pump(ViewportSpec.mobile);
      // The package does not reflow. A 600px table in a 390px viewport clips,
      // and the proof that it clipped is that there is now somewhere to scroll.
      expect(_horizontalBodyPosition(tester).maxScrollExtent, greaterThan(0));
    });
  });

  group('drag selection inside a narrow stage', () {
    // The condition the invariant names, entered on purpose.

    late List<Set<String>> updates;
    late List<Set<String>> ends;
    final tableKey = GlobalKey();

    Future<void> pumpNarrowTable(WidgetTester tester) async {
      _surface(tester);
      updates = [];
      ends = [];

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: PreviewStage(
            spec: ViewportSpec.mobile,
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
              // Not decoration: the table wires its drag handlers only when
              // `onDragSelectionUpdate != null` (with isSelectable and
              // multiple). Passing only `onDragSelectionEnd` leaves dragging
              // silently inert, which is what this suite caught on its first run.
              onDragSelectionUpdate: (ids) => updates.add(Set.of(ids)),
              onDragSelectionEnd: (ids) => ends.add(Set.of(ids)),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    /// A point inside row [row] of the body, [x] pixels from the stage's left.
    Offset bodyPoint(WidgetTester tester,
        {required double x, required double row}) {
      final r = tester.getRect(find.byKey(tableKey));
      return r.topLeft + Offset(x, _headerHeight + row * _rowHeight);
    }

    Future<void> dragRows(WidgetTester tester,
        {required double from, required double to}) async {
      final gesture =
          await tester.startGesture(bodyPoint(tester, x: 60, row: from));
      await tester.pump();
      await gesture.moveTo(bodyPoint(tester, x: 60, row: to));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('selects the rows under the pointer at offset zero',
        (tester) async {
      await pumpNarrowTable(tester);
      expect(_horizontalBodyPosition(tester).pixels, 0);

      await dragRows(tester, from: 0.5, to: 2.5);

      expect(ends, hasLength(1));
      expect(ends.single, {'0', '1', '2'});
    });

    testWidgets('selects the same rows once scrolled horizontally',
        (tester) async {
      await pumpNarrowTable(tester);

      // The whole point. A frame that drifts by the scroll offset is correct at
      // zero and wrong here, and nothing else in this repo's suites ever gets
      // here — the package's two drag test files contain no jumpTo at all.
      final pos = _horizontalBodyPosition(tester);
      pos.jumpTo(pos.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(pos.pixels, greaterThan(0),
          reason: 'the scroll did not take, so this test proves nothing');

      await dragRows(tester, from: 0.5, to: 2.5);

      expect(ends, hasLength(1));
      expect(ends.single, {'0', '1', '2'},
          reason: 'rows selected under a horizontal offset differ from the '
              'rows selected at zero — the drag coordinate frame drifted');
    });

    testWidgets('a horizontal offset does not leak into the vertical axis',
        (tester) async {
      // The side condition. The row set above could be right by accident if the
      // drag selected everything; this pins that it did not.
      await pumpNarrowTable(tester);

      final pos = _horizontalBodyPosition(tester);
      pos.jumpTo(pos.maxScrollExtent);
      await tester.pumpAndSettle();

      // Inside row 1 the whole way, but genuinely moving: a press that never
      // moves is a tap, resolves as one, and emits no drag at all — which is
      // how the first draft of this test managed to assert nothing.
      await dragRows(tester, from: 1.1, to: 1.9);

      expect(ends.single, {'1'},
          reason: 'a drag confined to one row selected more than one — a '
              'horizontal offset reached the vertical axis');
      expect(updates, isNotEmpty,
          reason: 'no drag was delivered, so the row set above proves nothing');
    });
  });

  group('switching viewport under a live scroll offset', () {
    // Enumerated before writing the stage, and the reason it is enumerated at
    // all: `SyncedScrollControllers` builds its controllers in `initState` and
    // deliberately does *not* recreate them when the parent rebuilds
    // (synced_scroll_controllers.dart, the comment at the top of
    // `didUpdateWidget`). So a viewport switch is a rebuild that changes the
    // extent underneath controllers that outlive it — the offset is state the
    // switch carries whether anyone meant it to or not.

    Future<void> pumpAt(WidgetTester tester, ViewportSpec spec) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: PreviewStage(
            spec: spec,
            child: FlutterTablePlus<Map<String, dynamic>>(
              columns: _columns(),
              data: _rows(6),
              rowId: (r) => r['id'] as String,
              theme: const TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
                headerTheme: TablePlusHeaderTheme(height: _headerHeight),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('a phone offset does not survive into a viewport with no room',
        (tester) async {
      _surface(tester);

      await pumpAt(tester, ViewportSpec.mobile);
      final scrolled = _horizontalBodyPosition(tester);
      scrolled.jumpTo(scrolled.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(scrolled.pixels, greaterThan(0),
          reason: 'nothing was carried, so the switch below proves nothing');

      await pumpAt(tester, ViewportSpec.desktop);

      expect(tester.takeException(), isNull);

      // 600px of columns in a 1440px viewport: every horizontal position must
      // be back at zero with nowhere to go. A retained offset would leave the
      // header and body describing different columns.
      final after = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .where((p) => p.axis == Axis.horizontal);
      expect(after, isNotEmpty);
      for (final p in after) {
        expect(p.maxScrollExtent, 0);
        expect(p.pixels, 0,
            reason: 'an offset outlived the extent that allowed it');
      }
    });

    testWidgets('and going back to the phone starts from zero', (tester) async {
      _surface(tester);

      await pumpAt(tester, ViewportSpec.mobile);
      final first = _horizontalBodyPosition(tester);
      first.jumpTo(first.maxScrollExtent);
      await tester.pumpAndSettle();

      await pumpAt(tester, ViewportSpec.desktop);
      await pumpAt(tester, ViewportSpec.mobile);

      expect(tester.takeException(), isNull);
      expect(_horizontalBodyPosition(tester).pixels, 0,
          reason: 'the phone came back already scrolled, which reads as a bug '
              'to anyone switching viewports to compare layouts');
    });
  });
}
