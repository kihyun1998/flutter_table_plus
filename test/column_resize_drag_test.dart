import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget coverage for the actual drag-to-resize interaction (distinct from the
// resize auto-scroll test and the static clamp-via-handle-position test):
// dragging a resize handle changes the column width and fires onColumnResized
// once on release with the clamped logical width.

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  b.addColumn(
    'c0',
    TablePlusColumn<Map<String, dynamic>>(
      key: 'c0',
      label: 'C0',
      order: 0,
      valueAccessor: (r) => r['c0'],
      width: 200,
      minWidth: 80,
      maxWidth: 300,
    ),
  );
  for (final k in ['c1', 'c2']) {
    b.addColumn(
      k,
      TablePlusColumn<Map<String, dynamic>>(
        key: k,
        label: k.toUpperCase(),
        order: 0,
        valueAccessor: (r) => r[k],
        width: 200,
      ),
    );
  }
  return b.build();
}

/// Drags `c0`'s handle by [dx] **screen** pixels and returns every width the
/// table reported.
///
/// [dx] is screen space on purpose: that is what a pointer moves, and at a
/// scale other than 1.0 it is not the same distance the column travels. What
/// comes back is logical, so a caller converts one and not the other.
///
/// [viewport] has to hold the handle. It sits at the column's right edge in
/// *rendered* pixels, so at scale 2.0 a 300px viewport puts it off screen and
/// the drag never starts.
/// Two columns, neither declaring a bound, so both take the defaults:
/// `minWidth: 50` and `maxWidth: null`.
Map<String, TablePlusColumn<Map<String, dynamic>>> _unboundedColumns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  for (final k in ['c0', 'c1']) {
    b.addColumn(
      k,
      TablePlusColumn<Map<String, dynamic>>(
        key: k,
        label: k.toUpperCase(),
        order: 0,
        valueAccessor: (r) => r[k],
        width: 200,
      ),
    );
  }
  return b.build();
}

Future<List<double>> _dragResize(
  WidgetTester tester,
  double dx, {
  double scale = 1.0,
  double viewport = 300,
  Map<String, TablePlusColumn<Map<String, dynamic>>>? columns,
}) async {
  final resized = <double>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        // 600 logical of content in a viewport narrower than that -> columns
        // keep their preferred widths (no proportional redistribution); c0
        // renders at 200 * scale.
        body: Center(
          child: SizedBox(
            width: viewport,
            height: 300,
            child: FlutterTablePlus<Map<String, dynamic>>(
              columns: columns ?? _columns(),
              data: const [
                {'id': '1', 'c0': 'a', 'c1': 'b', 'c2': 'c'}
              ],
              rowId: (r) => r['id'] as String,
              resizable: true,
              scale: scale,
              onColumnResized: (_, width) => resized.add(width),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.drag(find.byKey(const ValueKey('resize_c0')), Offset(dx, 0));
  await tester.pumpAndSettle();
  return resized;
}

void main() {
  testWidgets('dragging right widens the column and fires onColumnResized once',
      (tester) async {
    final resized = await _dragResize(tester, 40);

    expect(resized.length, 1);
    expect(resized.single, greaterThan(200)); // widened from 200
    expect(resized.single, lessThanOrEqualTo(240)); // at most +40
  });

  testWidgets('dragging past maxWidth clamps to maxWidth', (tester) async {
    final resized = await _dragResize(tester, 500);

    expect(resized.length, 1);
    expect(resized.single, 300); // clamped to maxWidth
  });

  testWidgets('dragging past minWidth clamps to minWidth', (tester) async {
    final resized = await _dragResize(tester, -500);

    expect(resized.length, 1);
    expect(resized.single, 80); // clamped to minWidth
  });

  group('the declared bounds mean the same logical numbers at any scale', () {
    // c0 declares width 200, minWidth 80, maxWidth 300 — all logical, because
    // that is the only space a caller can write them in. At scale 2.0 it
    // renders 400 wide and one screen pixel is half a logical one, so these
    // three assertions are the same three above with the conversion done.

    testWidgets('dragging past maxWidth clamps to maxWidth at scale 2.0',
        (tester) async {
      final resized = await _dragResize(tester, 500, scale: 2.0, viewport: 600);

      expect(resized.length, 1);
      expect(resized.single, 300);
    });

    testWidgets('dragging past minWidth clamps to minWidth at scale 2.0',
        (tester) async {
      final resized =
          await _dragResize(tester, -500, scale: 2.0, viewport: 600);

      expect(resized.length, 1);
      expect(resized.single, 80);
    });

    testWidgets('touching the handle does not jump the column at scale 2.0',
        (tester) async {
      // 40 screen px, of which the first `kDragSlopDefault` (20) is spent
      // getting the gesture recognized and never reaches the handle. The
      // remaining 20 screen px are 10 logical ones: 200 -> 210, nowhere near
      // either bound.
      //
      // This is the assertion that fails loudest when the bounds are read in
      // the wrong space — a column already past a halved ceiling snaps to it
      // the moment the handle moves at all, so the number it lands on is the
      // ceiling rather than anything to do with the drag.
      final resized = await _dragResize(tester, 40, scale: 2.0, viewport: 600);

      expect(resized.length, 1);
      expect(resized.single, closeTo(210, 0.001));
    });

    testWidgets('a column that declares no maxWidth still has no ceiling',
        (tester) async {
      // These columns declare neither bound, so they take the defaults:
      // minWidth 50 and maxWidth null. The null is a separate branch of the
      // conversion and nothing else in this file enters it — without this test, turning that branch
      // into a finite number leaves the suite green while every unbounded
      // column collapses the moment its handle moves. Measured 2026-08-26:
      // rewriting it as `(maxWidth ?? 0) * scale` passed all six other tests.
      //
      final resized = await _dragResize(
        tester,
        100,
        scale: 2.0,
        viewport: 600,
        columns: _unboundedColumns(),
      );

      expect(resized.length, 1);
      // 100 screen px less the 20px slop is 80, which is 40 logical: 200 -> 240.
      expect(resized.single, closeTo(240, 0.001));
    });
  });
}
