import 'package:flutter/widgets.dart';
import 'package:flutter_table_plus/src/widgets/drag_selection_controller.dart';
import 'package:flutter_table_plus/src/widgets/row_locator.dart';
import 'package:flutter_test/flutter_test.dart';

/// A deterministic [RowLocator] for unit tests: uniform [rowHeight], rows
/// `0..rowCount-1` stacked from Y=0. Y below 0 or past the last row is "empty"
/// (returns null), mirroring the real body's out-of-range signal.
class _FakeRowLocator implements RowLocator {
  _FakeRowLocator({required this.rowHeight, required this.rowCount});

  final double rowHeight;
  final int rowCount;

  @override
  int? indexAt(double localY) {
    if (localY < 0) return null;
    final idx = (localY / rowHeight).floor();
    if (idx >= rowCount) return null;
    return idx;
  }

  @override
  Set<String> idsBetween(int a, int b) {
    final lo = a < b ? a : b;
    final hi = a < b ? b : a;
    return {for (int i = lo; i <= hi; i++) '$i'};
  }
}

/// Y coordinate at the vertical center of [row] for a 40px row height.
double _rowCenterY(int row) => row * 40.0 + 20.0;

void main() {
  group('DragSelectionController — selection range', () {
    test('drag from row 0 to row 3 emits the inclusive id range on end', () {
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 8);
      final ends = <Set<String>>[];

      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => 0,
        horizontalOffset: () => 0,
        onEnd: (ids) => ends.add(Set.of(ids)),
      );

      final start = Offset(50, _rowCenterY(0));
      final end = Offset(50, _rowCenterY(3));

      controller.down(
          local: start, global: start, viewport: const Size(400, 300));
      controller.move(local: end, global: end);
      controller.up();

      expect(ends, isNotEmpty,
          reason: 'onEnd should fire after a real drag across rows');
      expect(ends.last, equals(<String>{'0', '1', '2', '3'}));
    });

    test(
        'drag started in empty space, then returned to empty space, clears the '
        'selection', () {
      // 3 rows (y: 0..120). Below 120 is empty space.
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 3);
      final updates = <Set<String>>[];

      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => 0,
        horizontalOffset: () => 0,
        onUpdate: (ids) => updates.add(Set.of(ids)),
      );

      const down = Offset(50, 200); // empty area below the 3 rows
      const intoData = Offset(50, 20); // row 0, threshold crossed (200→20)
      const backToEmpty = Offset(50, 200); // empty area again

      controller.down(
          local: down, global: down, viewport: const Size(400, 300));
      controller.move(local: intoData, global: intoData);
      controller.move(local: backToEmpty, global: backToEmpty);

      expect(updates, isNotEmpty);
      expect(updates.last, isEmpty,
          reason: 'returning into the empty area below the data releases the '
              'sticky selection that began from empty space');
    });

    test(
        'drag started in empty space, moved up past the top, keeps the sticky '
        'selection (header area, absolute Y < 0)', () {
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 3);
      final updates = <Set<String>>[];

      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => 0,
        horizontalOffset: () => 0,
        onUpdate: (ids) => updates.add(Set.of(ids)),
      );

      const down = Offset(50, 200); // empty below data
      const intoData = Offset(50, 20); // row 0, anchor set here
      const aboveTop = Offset(50, -20); // header area: absolute Y < 0

      controller.down(
          local: down, global: down, viewport: const Size(400, 300));
      controller.move(local: intoData, global: intoData);
      controller.move(local: aboveTop, global: aboveTop);

      expect(updates.last, equals(<String>{'0'}),
          reason: 'moving above the data into the header preserves the last '
              'valid range instead of clearing it');
    });

    test('cancel ends the drag without emitting onEnd', () {
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 8);
      final ends = <Set<String>>[];

      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => 0,
        horizontalOffset: () => 0,
        onEnd: (ids) => ends.add(Set.of(ids)),
      );

      final start = Offset(50, _rowCenterY(0));
      final mid = Offset(50, _rowCenterY(3));

      controller.down(
          local: start, global: start, viewport: const Size(400, 300));
      controller.move(local: mid, global: mid);
      controller.cancel();

      expect(ends, isEmpty, reason: 'a cancelled drag must not commit a range');
    });
  });

  group('DragSelectionController — geometry', () {
    test(
        'rubber band rect stays anchored to the drag origin as the view scrolls',
        () {
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 20);
      double vOffset = 0;
      double hOffset = 0;

      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => vOffset,
        horizontalOffset: () => hOffset,
      );

      const down = Offset(100, 100);
      const current = Offset(200, 180); // dy delta 80 crosses the threshold

      controller.down(
          local: down, global: down, viewport: const Size(400, 300));
      controller.move(local: current, global: current);

      // The view scrolls down 50 and right 30 while the pointer is held still.
      vOffset = 50;
      hOffset = 30;

      // Origin slides opposite to the scroll delta so it stays pinned to the
      // content cell where the drag began: (100-30, 100-50) = (70, 50).
      expect(controller.rubberBandRect(),
          equals(const Rect.fromLTRB(70, 50, 200, 180)));
    });

    test('rubber band rect is null before the drag threshold is crossed', () {
      final locator = _FakeRowLocator(rowHeight: 40, rowCount: 20);
      final controller = DragSelectionController(
        locator: () => locator,
        verticalOffset: () => 0,
        horizontalOffset: () => 0,
      );

      const down = Offset(100, 100);
      controller.down(
          local: down, global: down, viewport: const Size(400, 300));
      controller.move(
          local: const Offset(102, 104), global: const Offset(102, 104));

      expect(controller.rubberBandRect(), isNull);
    });
  });

  group('DragSelectionController — auto-scroll axis math', () {
    test('no scroll when the pointer is outside both edge zones', () {
      expect(
        DragSelectionController.axisScrollDelta(
          localPos: 150,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        0,
      );
    });

    test('leading edge scrolls backward, scaled by proximity', () {
      // (40 - 10) / 40 = 0.75 → -10 * 0.75 = -7.5
      expect(
        DragSelectionController.axisScrollDelta(
          localPos: 10,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        -7.5,
      );
    });

    test('trailing edge scrolls forward, scaled by proximity', () {
      // (295 - (300 - 40)) / 40 = 0.875 → 10 * 0.875 = 8.75
      expect(
        DragSelectionController.axisScrollDelta(
          localPos: 295,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        8.75,
      );
    });

    test('proximity past the edge exceeds maxSpeed when unclamped', () {
      // localPos -20 → (40 - (-20)) / 40 = 1.5 → -10 * 1.5 = -15
      expect(
        DragSelectionController.axisScrollDelta(
          localPos: -20,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        -15,
      );
    });

    test('clampProximity caps the speed at maxSpeed', () {
      expect(
        DragSelectionController.axisScrollDelta(
          localPos: -20,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: true,
        ),
        -10,
      );
    });
  });
}
