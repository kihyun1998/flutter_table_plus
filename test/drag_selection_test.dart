import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 0 — drag selection behavior baseline.
//
// These tests describe the *intended* drag-selection behavior. Some currently
// fail because of the horizontal-axis edge-detection bug being targeted by
// the upcoming refactor — that is by design. They will pass after the
// coordinate-model unification work in Phase 3 lands.

const double _rowHeight = 40;
const double _headerHeight = 40;
const double _columnWidth = 100;
const double _surfaceWidth = 800;
const double _surfaceHeight = 600;

/// Builds [count] columns named c0..c{count-1}, each [width] wide.
Map<String, TablePlusColumn<Map<String, dynamic>>> _buildColumns({
  int count = 4,
  double width = _columnWidth,
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

/// Builds [rowCount] rows. Each row has 'id' and c0..c{colCount-1} string cells.
List<Map<String, dynamic>> _buildData(int rowCount, {int colCount = 4}) {
  return List.generate(rowCount, (i) {
    return {
      'id': '$i',
      for (int j = 0; j < colCount; j++) 'c$j': 'r${i}c$j',
    };
  });
}

/// Captures drag-selection callback emissions for assertions.
class _DragHarness {
  final List<Set<String>> updates = [];
  final List<Set<String>> ends = [];
  final GlobalKey tableKey = GlobalKey();
}

/// Pumps a [FlutterTablePlus] inside a fixed-size SizedBox at the center of
/// an 800x600 surface, with predictable row/header heights and a callback
/// log. Returns the harness — call its lists to inspect emissions.
Future<_DragHarness> _pumpDragTable(
  WidgetTester tester, {
  required int rowCount,
  int colCount = 4,
  double colWidth = _columnWidth,
  double rowHeight = _rowHeight,
  double headerHeight = _headerHeight,
  double tableWidth = 400,
  double tableHeight = 300,
  List<MergedRowGroup<Map<String, dynamic>>> mergedGroups = const [],
  // --- re-pump support, for the geometry-staleness tests at the bottom ---
  //
  // Every caller above builds a fresh `data` list, and a fresh list makes
  // `!identical(widget.data, oldWidget.data)` true — which rebuilds every cache
  // on the way past. That is fine for a test that pumps once and is fatal for
  // one that pumps twice, because the thing under test only happens while the
  // list stays the same object. Passing `data` and `harness` back in is what
  // makes the second pump an *update* rather than a fresh mount.
  List<Map<String, dynamic>>? data,
  _DragHarness? harness,
  double? Function(int, Map<String, dynamic>)? calculateRowHeight,
  double scale = 1.0,
  // Identity, for the group at the bottom. Defaults to the plain `id` field so
  // every caller above is unaffected.
  String Function(Map<String, dynamic>)? rowId,
}) async {
  // `rowCount` is ignored entirely when `data` is supplied, so the two can
  // disagree in silence and a reader would believe the wrong one.
  assert(
      data == null || data.length == rowCount,
      'rowCount ($rowCount) is ignored because data was supplied '
      '(${data.length} rows) — keep them in agreement or drop one');
  tester.view.physicalSize = const Size(_surfaceWidth, _surfaceHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // A local, because a nullable *parameter* does not promote inside the
  // callback closures below.
  final h = harness ?? _DragHarness();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: tableWidth,
            height: tableHeight,
            child: FlutterTablePlus<Map<String, dynamic>>(
              key: h.tableKey,
              columns: _buildColumns(count: colCount, width: colWidth),
              data: data ?? _buildData(rowCount, colCount: colCount),
              rowId: rowId ?? (r) => r['id'] as String,
              isSelectable: true,
              enableDragSelection: true,
              mergedGroups: mergedGroups,
              calculateRowHeight: calculateRowHeight,
              scale: scale,
              theme: TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(rowHeight: rowHeight),
                headerTheme: TablePlusHeaderTheme(height: headerHeight),
              ),
              onDragSelectionUpdate: (ids) => h.updates.add(Set.of(ids)),
              onDragSelectionEnd: (ids) => h.ends.add(Set.of(ids)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return h;
}

/// Returns a screen-space Offset inside the body of the table at (x, row),
/// where x is body-local pixels from table left, and row is a fractional
/// row index (0.5 = middle of row 0). Header occupies the first
/// [_headerHeight] pixels of the table.
Offset _bodyPoint(
  WidgetTester tester,
  GlobalKey tableKey, {
  required double x,
  required double row,
}) {
  final r = tester.getRect(find.byKey(tableKey));
  return r.topLeft + Offset(x, _headerHeight + row * _rowHeight);
}

/// Pumps a sequence of frames simulating real time advance, which fires any
/// scheduled Timer.periodic ticks (auto-scroll uses 16ms periodic timer).
Future<void> _pumpFrames(
  WidgetTester tester, {
  int frames = 100,
  Duration interval = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(interval);
  }
}

void main() {
  group('Drag selection — basic flow', () {
    testWidgets('drag within data area selects rows in continuous range',
        (tester) async {
      final h = await _pumpDragTable(
        tester,
        rowCount: 8,
        tableHeight: 400, // header(40) + 8*40 = 360 < 400 — no vertical scroll
      );

      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      final end = _bodyPoint(tester, h.tableKey, x: 50, row: 3.5);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(end);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(h.ends, isNotEmpty,
          reason: 'onDragSelectionEnd should fire after a real drag');
      expect(h.ends.last, equals(<String>{'0', '1', '2', '3'}));
    });

    testWidgets('movement below activation threshold does not start a drag',
        (tester) async {
      final h = await _pumpDragTable(tester, rowCount: 5, tableHeight: 400);

      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 1.5);
      // Threshold is 8px; 4px is well below.
      final tinyEnd = start + const Offset(0, 4);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(tinyEnd);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(h.updates, isEmpty,
          reason: 'no drag-selection update fires below threshold');
      expect(h.ends, isEmpty,
          reason: 'no drag-selection end fires when drag never activates');
    });
  });

  group('Drag selection — sticky range at boundaries', () {
    testWidgets(
        'dragging from data into empty space below keeps selection sticky',
        (tester) async {
      // 3 rows, table tall enough to leave empty space below them.
      final h = await _pumpDragTable(
        tester,
        rowCount: 3,
        tableHeight: 300, // header(40) + 3*40 = 160; 140px empty below
      );

      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      // Step through row 2 to give the renderIndex tracker a valid sample
      // before crossing into empty space — gesture.moveTo does not
      // interpolate, so a direct jump skips intermediate rows.
      final lastRow = _bodyPoint(tester, h.tableKey, x: 50, row: 2.5);
      // y = headerHeight + 6.0 * rowHeight = 40 + 240 = 280 → well past row 2's
      // bottom (40 + 3*40 = 160 from table top), inside the empty area.
      final emptyBelow = _bodyPoint(tester, h.tableKey, x: 50, row: 6.0);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(lastRow);
      await tester.pump();
      await gesture.moveTo(emptyBelow);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(h.ends, isNotEmpty);
      expect(h.ends.last, equals(<String>{'0', '1', '2'}),
          reason: 'selection should stick to last valid row (2) when '
              'pointer leaves data area downward');
    });

    testWidgets('dragging upward into header area keeps selection sticky',
        (tester) async {
      final h = await _pumpDragTable(tester, rowCount: 5, tableHeight: 400);

      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 2.5);
      // Step through row 0 first (sticky tracker needs a valid sample) then
      // continue into header area where renderIndex returns null.
      final firstRow = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      final r = tester.getRect(find.byKey(h.tableKey));
      // y = 0.5 * rowHeight from table top = 20 → inside header area.
      final headerEnd = r.topLeft + const Offset(50, _headerHeight * 0.5);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(firstRow);
      await tester.pump();
      await gesture.moveTo(headerEnd);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(h.ends, isNotEmpty);
      expect(h.ends.last, equals(<String>{'0', '1', '2'}),
          reason: 'sticky behavior preserves the topmost reached row when '
              'pointer crosses into header');
    });
  });

  group('Drag selection — auto-scroll', () {
    testWidgets(
        'vertical auto-scroll extends selection beyond initial viewport',
        (tester) async {
      // Many rows, short viewport — only ~5 rows visible initially.
      final h = await _pumpDragTable(
        tester,
        rowCount: 50,
        tableHeight: 200, // header(40) + visible body(160) ≈ 4 rows visible
      );

      final r = tester.getRect(find.byKey(h.tableKey));
      // Start in row 0; move pointer to within bottom edge zone (last 40px).
      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      final bottomEdge = r.bottomLeft + const Offset(50, -10);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, frames: 100); // ~1.6s of auto-scroll
      await gesture.up();
      await tester.pump();

      expect(h.ends, isNotEmpty);
      // After auto-scrolling for ~1.6s at maxSpeed 10px/16ms ≈ up to ~600px,
      // many more rows than the initial ~4 should be in the selection.
      expect(h.ends.last.length, greaterThan(8),
          reason:
              'vertical auto-scroll should extend selection past initial viewport');
      expect(h.ends.last.contains('0'), isTrue);
    });

    testWidgets(
        'horizontal auto-scroll continues progressing while pointer is held at edge',
        (tester) async {
      // contentWidth = 4 * 250 = 1000; tableWidth = 400 → maxScrollExtent ≈ 600.
      final h = await _pumpDragTable(
        tester,
        rowCount: 5,
        colCount: 4,
        colWidth: 250,
        tableWidth: 400,
        tableHeight: 400,
      );

      final r = tester.getRect(find.byKey(h.tableKey));
      // Capture r0c0 X before drag — its movement reveals horizontal scroll.
      final initialR0C0X = tester.getTopLeft(find.text('r0c0')).dx;

      final start = _bodyPoint(tester, h.tableKey, x: 30, row: 1.5);
      // Hold pointer near right edge of viewport (within edge zone of 40px).
      final rightEdge = r.centerRight + const Offset(-20, 0);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(rightEdge);
      await _pumpFrames(tester, frames: 120);
      final laterR0C0X = tester.getTopLeft(find.text('r0c0')).dx;
      await gesture.up();
      await tester.pump();

      final scrolled = initialR0C0X - laterR0C0X;
      // With the fix, scrolled should be ~470px (approaching maxScrollExtent
      // 600). With the current bug, scrolled stops near ~20px because the
      // edge-detection viewportX drifts by hDelta.
      expect(scrolled, greaterThan(100),
          reason: 'horizontal auto-scroll must continue progressing while '
              'pointer is held inside the right edge zone — current code '
              'stops prematurely due to stale _bodyGlobalLeft');
    });

    testWidgets('simultaneous dual-axis auto-scroll progresses on both axes',
        (tester) async {
      final h = await _pumpDragTable(
        tester,
        rowCount: 50,
        colCount: 4,
        colWidth: 250,
        tableWidth: 400,
        tableHeight: 200,
      );

      final r = tester.getRect(find.byKey(h.tableKey));
      // Use header label (always mounted, never lazy-disposed) as the
      // horizontal-scroll witness. ListView lazy-unmounts off-screen rows so
      // r0c0 disappears once vertical auto-scroll passes it.
      final initialC0X = tester.getTopLeft(find.text('C0')).dx;

      final start = _bodyPoint(tester, h.tableKey, x: 30, row: 0.5);
      // Move into bottom-right corner edge zone (within 40px of both edges).
      final corner = r.bottomRight + const Offset(-15, -15);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(corner);
      await _pumpFrames(tester, frames: 120);
      final laterC0X = tester.getTopLeft(find.text('C0')).dx;
      await gesture.up();
      await tester.pump();

      final scrolledX = initialC0X - laterC0X;
      expect(scrolledX, greaterThan(100),
          reason: 'horizontal auto-scroll should progress in dual-axis drag');
      // Vertical progression: row 0 should have scrolled out of view far
      // enough that the lazy ListView disposed its widget. (Asserting an
      // exact visible row would be fragile because the unmount window
      // depends on viewport size and exact scroll position.)
      expect(find.text('r0c0'), findsNothing,
          reason: 'vertical auto-scroll should advance past the initial '
              'viewport in a dual-axis drag');
    });
  });

  group('Drag selection — merged groups', () {
    testWidgets(
        'dragging across a merged group adds the group ID, not individual rows',
        (tester) async {
      // 5 rows; merge rows 1..3 into one group.
      final mergedGroups = <MergedRowGroup<Map<String, dynamic>>>[
        const MergedRowGroup<Map<String, dynamic>>(
          groupId: 'g1',
          rowKeys: ['1', '2', '3'],
          mergeConfig: {},
        ),
      ];

      final h = await _pumpDragTable(
        tester,
        rowCount: 5,
        tableHeight: 400,
        mergedGroups: mergedGroups,
      );

      // Renderable rows (after merging) are: row 0, group g1, row 4.
      // That maps render-index 0 → row 0, 1 → group, 2 → row 4 in body.
      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      final end = _bodyPoint(tester, h.tableKey, x: 50, row: 4.5);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(end);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(h.ends, isNotEmpty);
      expect(h.ends.last, equals(<String>{'0', 'g1', '4'}),
          reason: 'merged group should appear as its groupId in the drag '
              'set, replacing the individual member row IDs');
    });
  });

  group('Drag selection — starting from a non-zero horizontal offset', () {
    // What this group pins, stated narrowly on purpose: a drag that *begins*
    // at a non-zero horizontal offset still maps Y to the same rows it would
    // have at zero. The auto-scroll tests above reach a non-zero offset during
    // a drag; beginning at one is a different entry, and it is the one a user
    // makes after scrolling sideways to find the column they care about.
    //
    // What it does **not** pin, despite what the horizontal offset in its name
    // suggests: the frame violation `docs/map/invariant/viewport-local-frame.md`
    // describes. Row lookup goes through `RowLocator.indexAt(double localY)` —
    // Y only. The horizontal coordinate never reaches it, so a frame that
    // drifted horizontally would select exactly these rows anyway and this
    // group would stay green through it.
    //
    // The horizontal coordinate is used by the **rubber band**, whose origin is
    // corrected by the offset scrolled *since the drag began* rather than by
    // the absolute offset. Those two answers are the same number for a drag
    // starting at zero and different for any other, which is what makes the
    // invariant's "reproduces only when the horizontal scroll is non-zero"
    // true of that site and not of this one. It is pinned where it belongs, in
    // `drag_selection_controller_test.dart` — 'rubber band origin is corrected
    // by the delta, not the offset', which is the only test in this repository
    // that reddens when that correction is replaced by the absolute offset.

    /// The body's own horizontal position — the one with somewhere to go.
    ///
    /// Selected by property rather than by index: the table builds several
    /// `Scrollable`s and their order is an implementation detail.
    ScrollPosition horizontalBody(WidgetTester tester) {
      return tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .firstWhere(
            (p) => p.axis == Axis.horizontal && p.maxScrollExtent > 0,
            orElse: () => throw StateError(
              'the table is not clipped horizontally, so this group is not '
              'testing what it claims to',
            ),
          );
    }

    testWidgets('selects the same rows it would have selected at offset zero',
        (tester) async {
      // contentWidth = 4 * 250 = 1000 against a 400 viewport, so there is 600px
      // of offset available to be wrong by.
      final h = await _pumpDragTable(
        tester,
        rowCount: 8,
        colCount: 4,
        colWidth: 250,
        tableWidth: 400,
        tableHeight: 400,
      );

      final pos = horizontalBody(tester);
      pos.jumpTo(pos.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(pos.pixels, greaterThan(0),
          reason: 'the scroll did not take, so this test proves nothing');

      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 0.5);
      final end = _bodyPoint(tester, h.tableKey, x: 50, row: 3.5);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(end);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(h.ends, hasLength(1));
      expect(h.ends.single, {'0', '1', '2', '3'},
          reason: 'a pre-existing horizontal offset changed which rows a '
              'vertical drag covers');
    });

    testWidgets('a drag confined to one row still selects exactly that row',
        (tester) async {
      // The side condition. The set above could be right by accident if the
      // drag had selected everything it crossed and more.
      final h = await _pumpDragTable(
        tester,
        rowCount: 8,
        colCount: 4,
        colWidth: 250,
        tableWidth: 400,
        tableHeight: 400,
      );

      final pos = horizontalBody(tester);
      pos.jumpTo(pos.maxScrollExtent);
      await tester.pumpAndSettle();

      // Inside row 2 the whole way, but genuinely moving: a press that never
      // moves resolves as a tap and emits no drag at all.
      final start = _bodyPoint(tester, h.tableKey, x: 50, row: 2.1);
      final end = _bodyPoint(tester, h.tableKey, x: 50, row: 2.9);

      final gesture = await tester.startGesture(start);
      await tester.pump();
      await gesture.moveTo(end);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(h.updates, isNotEmpty,
          reason: 'no drag was delivered, so the assertion below is vacuous');
      expect(h.ends.single, {'2'});
    });
  });

  group('Drag selection — hit-test geometry after a height change', () {
    // #128. `TablePlusBodyState` snapshots each row's height and id into a
    // `RowGeometry` and answers every `indexAt` / `idsBetween` from it. The
    // snapshot is built **lazily on the first drag query** and held until
    // something clears it — and until this group existed, nothing checked that
    // it ever was cleared: deleting the clear left all 405 tests green, because
    // every other drag test here runs on one uniform height and never re-pumps.
    //
    // Three things have to line up or the test proves nothing, and each one on
    // its own is enough to make it vacuous:
    //
    //   1. the data list is the **same object** across both pumps, or the
    //      structure branch rebuilds every cache and the measurement branch is
    //      never reached;
    //   2. a drag runs **before** the change, or the snapshot is still null
    //      afterwards and gets built fresh from the new heights — green with or
    //      without the invalidation;
    //   3. the two heights put the same pixel over **different rows**, or the
    //      stale answer and the fresh answer agree.
    //
    // Rendering is not the thing under test and never was: `itemExtentBuilder`
    // reads the heights live, so the rows are drawn correctly either way. What
    // goes stale is only what the pointer is resolved against, which is why
    // this is asserted on the ids the callback reports.

    /// The six rows both pumps share — **a value, not a function**.
    ///
    /// It was `List<...> sharedRows() => _buildData(6)`, and that was a trap: a
    /// docstring promising one object, in front of a helper that built a new
    /// one per call. Writing `data: sharedRows()` at the second pump — one
    /// token, and the name invites it — makes both tests pass with the
    /// production invalidation deleted. Measured, not argued. A `final` cannot
    /// be called twice, so the invariant is enforced by the language now rather
    /// than by whoever edits next.
    final sharedRows = _buildData(6);

    /// A point inside the body, `y` logical pixels below the body's **top**.
    ///
    /// The body top is measured, not assumed. `_bodyPoint` above adds the
    /// `_headerHeight` constant, which is right only at `scale: 1.0`: `scaledBy`
    /// scales `headerTheme.height` too, so at 2.0 the header draws at 80 and the
    /// constant is 40px short. Measured 2026-08-31 — the body's `ListView` sits
    /// 40px below the table at scale 1.0 and 80px below it at 2.0. With the
    /// constant, the scale test's priming drag ran from body-local 0 to 80 while
    /// its comment claimed 40 to 120, and got the right answer by coincidence:
    /// both pairs land on rows 0 and 1.
    Offset at(WidgetTester tester, GlobalKey key, double y) => Offset(
          tester.getRect(find.byKey(key)).left + 50,
          tester.getRect(find.byType(ListView)).top + y,
        );

    Future<void> dragFromTo(
      WidgetTester tester,
      Offset from,
      Offset to,
    ) async {
      final gesture = await tester.startGesture(from);
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pump();
    }

    testWidgets('a new calculateRowHeight re-resolves the pointer',
        (tester) async {
      final rows = sharedRows;

      // Tall rows first: 6 x 80 = 480, plus a 40px header, inside 560.
      final h = await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        tableHeight: 560,
        calculateRowHeight: (i, r) => 80,
      );

      // Load-bearing: builds the snapshot at 80px. Without it the snapshot is
      // still null after the second pump and the test cannot fail.
      await dragFromTo(
          tester, at(tester, h.tableKey, 40), at(tester, h.tableKey, 120));
      expect(h.ends, hasLength(1),
          reason: 'the priming drag did not emit, so the snapshot this test '
              'depends on was never built');
      expect(h.ends.last, equals(<String>{'0', '1'}),
          reason: 'the priming drag did not resolve against 80px rows');

      // Same list object, new height function — the measurement branch.
      await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        harness: h,
        tableHeight: 560,
        calculateRowHeight: (i, r) => 40,
      );

      // y=20 is row 0 and y=140 is row 3, at 40px. Against a stale 80px
      // snapshot the same two points are rows 0 and 1.
      await dragFromTo(
          tester, at(tester, h.tableKey, 20), at(tester, h.tableKey, 140));

      // The witness matters: a second drag that silently did not emit leaves
      // `ends.last` holding the priming drag's `{0, 1}` — the same value a
      // stale snapshot produces, so a red would not say which happened.
      expect(h.ends, hasLength(2), reason: 'the second drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1', '2', '3'}),
          reason: 'the pointer was resolved against the previous heights: the '
              'rows are drawn at 40px but the drag answered as if they were '
              'still 80px');
    });

    testWidgets('a new theme rowHeight re-resolves the pointer',
        (tester) async {
      // The third input, and the one that was in neither widget's list until
      // #128. It is also the most reachable: changing row height through the
      // theme needs no new list and no height callback at all — this repo's own
      // playground has a slider that does it.
      //
      // It is the most invisible, too. With no `calculateRowHeight` the body
      // takes the fixed-`itemExtent` path, which reads the theme live, so the
      // rows, the extent and the scroll are all correct. Only the pointer is
      // wrong.
      final rows = sharedRows;

      final h = await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        tableHeight: 560,
        rowHeight: 80,
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 40), at(tester, h.tableKey, 120));
      expect(h.ends, hasLength(1), reason: 'the priming drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1'}),
          reason: 'the priming drag did not resolve against 80px rows');

      await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        harness: h,
        tableHeight: 560,
        rowHeight: 40,
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 20), at(tester, h.tableKey, 140));

      expect(h.ends, hasLength(2), reason: 'the second drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1', '2', '3'}),
          reason: 'the pointer was resolved against the previous theme height');
    });

    testWidgets('a scale change re-resolves the pointer', (tester) async {
      // The other arm of the same branch, and the one that was never covered
      // even before #120: a cached height is stored already multiplied by
      // `scale`, so a zoom leaves the snapshot describing the previous zoom.
      final rows = sharedRows;

      // One function object, reused, so `calculateRowHeight` identity cannot be
      // what triggers the rebuild. Only `scale` differs between the pumps.
      double? height(int i, Map<String, dynamic> r) => 40;

      final h = await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        tableHeight: 560,
        calculateRowHeight: height,
        scale: 2.0,
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 40), at(tester, h.tableKey, 120));
      expect(h.ends, hasLength(1), reason: 'the priming drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1'}),
          reason: 'the priming drag did not resolve against 80px rows — at '
              'scale 2.0 a 40px height renders at 80');

      await _pumpDragTable(
        tester,
        rowCount: 6,
        data: rows,
        harness: h,
        tableHeight: 560,
        calculateRowHeight: height,
        scale: 1.0,
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 20), at(tester, h.tableKey, 140));

      expect(h.ends, hasLength(2), reason: 'the second drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1', '2', '3'}),
          reason: 'the pointer was resolved against the previous scale');
    });
  });

  group('Drag selection — a new snapshot refreshes what a pointer resolves to',
      () {
    // #132. `data` and `rowId` are one snapshot: every id-keyed derivation —
    // `RowLookup`, the renderable-index list, and the `ids` the geometry
    // answers `idsBetween` from — is built from the pair and dropped when the
    // *list* is a different object. `rowId` itself is never compared, and that
    // is a decision rather than an omission: it is required, every call site
    // writes an inline closure, and an inline closure is a new object on every
    // build even when it captures nothing (measured 2026-08-31) — so comparing
    // it would drop every cache on every build for every caller. The opposite
    // of `calculateRowHeight`, which is optional and so is usually the same
    // `null` twice running.
    //
    // What these two pin is therefore the **supported** path, not the stale
    // one. Asserting the stale answer would freeze a documented non-guarantee
    // into a test, and a later decision to guard `rowId` would read as a
    // regression. What must never break is that a new list *does* refresh.
    //
    // Both need the priming drag for the reason the group above documents: the
    // geometry is `_rowGeometry ??= _buildGeometry()`, so without a drag before
    // the change there is nothing cached to be stale and the test is vacuous
    // either way. Measured — with `_rowGeometry = null` deleted from
    // `_rebuildCaches`, both of these go red and the unprimed variants do not.

    Offset at(WidgetTester tester, GlobalKey key, double y) => Offset(
          tester.getRect(find.byKey(key)).left + 50,
          tester.getRect(find.byType(ListView)).top + y,
        );

    Future<void> dragFromTo(
      WidgetTester tester,
      Offset from,
      Offset to,
    ) async {
      final gesture = await tester.startGesture(from);
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pump();
    }

    testWidgets(
        'a new data list carries a new rowId into the hit-test geometry',
        (tester) async {
      final h = await _pumpDragTable(
        tester,
        rowCount: 6,
        tableHeight: 400,
        data: _buildData(6),
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 10), at(tester, h.tableKey, 130));
      expect(h.ends, hasLength(1), reason: 'the priming drag did not emit');
      expect(h.ends.last, equals(<String>{'0', '1', '2', '3'}));

      // A new list *and* a new id space — the supported way to change identity.
      await _pumpDragTable(
        tester,
        rowCount: 6,
        harness: h,
        tableHeight: 400,
        data: _buildData(6),
        rowId: (r) => 'X${r['id']}',
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 10), at(tester, h.tableKey, 130));

      expect(h.ends, hasLength(2), reason: 'the second drag did not emit');
      expect(h.ends.last, equals(<String>{'X0', 'X1', 'X2', 'X3'}),
          reason:
              'the geometry answered from the ids of the previous snapshot');
    });

    testWidgets('a new mergedGroups list changes what a pointer lands on',
        (tester) async {
      final rows = _buildData(6);

      final h = await _pumpDragTable(
        tester,
        rowCount: 6,
        tableHeight: 400,
        data: rows,
        mergedGroups: const [
          MergedRowGroup<Map<String, dynamic>>(
            groupId: 'g0',
            rowKeys: ['0', '1'],
            mergeConfig: {},
          ),
        ],
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 10), at(tester, h.tableKey, 100));
      expect(h.ends, hasLength(1), reason: 'the priming drag did not emit');
      expect(h.ends.last, equals(<String>{'g0', '2'}));

      // Expanding adds a summary row, so the group grows by one row's height
      // and the same 90px reach no longer gets past it. `rows` is deliberately
      // the same object: the group list alone is what changed.
      await _pumpDragTable(
        tester,
        rowCount: 6,
        harness: h,
        tableHeight: 400,
        data: rows,
        mergedGroups: const [
          MergedRowGroup<Map<String, dynamic>>(
            groupId: 'g0',
            rowKeys: ['0', '1'],
            mergeConfig: {},
            isExpanded: true,
          ),
        ],
      );

      await dragFromTo(
          tester, at(tester, h.tableKey, 10), at(tester, h.tableKey, 100));

      expect(h.ends, hasLength(2), reason: 'the second drag did not emit');
      expect(h.ends.last, equals(<String>{'g0'}),
          reason: 'the pointer was resolved against the collapsed extent');
    });
  });
}
