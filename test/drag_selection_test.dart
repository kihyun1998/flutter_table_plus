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
}) async {
  tester.view.physicalSize = const Size(_surfaceWidth, _surfaceHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final harness = _DragHarness();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: tableWidth,
            height: tableHeight,
            child: FlutterTablePlus<Map<String, dynamic>>(
              key: harness.tableKey,
              columns: _buildColumns(count: colCount, width: colWidth),
              data: _buildData(rowCount, colCount: colCount),
              rowId: (r) => r['id'] as String,
              isSelectable: true,
              enableDragSelection: true,
              mergedGroups: mergedGroups,
              theme: TablePlusTheme(
                bodyTheme: TablePlusBodyTheme(rowHeight: rowHeight),
                headerTheme: TablePlusHeaderTheme(height: headerHeight),
              ),
              onDragSelectionUpdate: (ids) => harness.updates.add(Set.of(ids)),
              onDragSelectionEnd: (ids) => harness.ends.add(Set.of(ids)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
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
}
