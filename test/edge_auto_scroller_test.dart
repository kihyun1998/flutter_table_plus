import 'package:fake_async/fake_async.dart';
import 'package:flutter_table_plus/src/widgets/edge_auto_scroller.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mutable scroll axis: applies a clamped delta and reports the amount it
/// actually moved (mirroring a ScrollPosition at its extents).
class _FakeAxis {
  _FakeAxis({required this.maxExtent});

  final double maxExtent;
  double offset = 0;

  double by(double delta) {
    final next = (offset + delta).clamp(0.0, maxExtent);
    final actual = next - offset;
    offset = next;
    return actual;
  }
}

void main() {
  group('EdgeAutoScroller.axisScrollDelta', () {
    test('no scroll outside both edge zones', () {
      expect(
        EdgeAutoScroller.axisScrollDelta(
          localPos: 150,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        0,
      );
    });

    test('leading edge scrolls backward scaled by proximity', () {
      // (40 - 10) / 40 = 0.75 -> -10 * 0.75 = -7.5
      expect(
        EdgeAutoScroller.axisScrollDelta(
          localPos: 10,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        -7.5,
      );
    });

    test('trailing edge scrolls forward scaled by proximity', () {
      // (295 - (300 - 40)) / 40 = 0.875 -> 10 * 0.875 = 8.75
      expect(
        EdgeAutoScroller.axisScrollDelta(
          localPos: 295,
          viewportExtent: 300,
          edgeZone: 40,
          maxSpeed: 10,
          clampProximity: false,
        ),
        8.75,
      );
    });

    test('clampProximity caps the speed at maxSpeed', () {
      expect(
        EdgeAutoScroller.axisScrollDelta(
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

  group('EdgeAutoScroller loop', () {
    test('holding in an edge zone scrolls repeatedly on a timer', () {
      fakeAsync((async) {
        final axis = _FakeAxis(maxExtent: 1000);
        var scrolledCallbacks = 0;
        final scroller = EdgeAutoScroller(
          edgeZone: 50,
          maxSpeed: 8,
          scrollBy: axis.by,
          onScrolled: (_) => scrolledCallbacks++,
        );

        // Pointer near the trailing edge of a 300-wide viewport.
        scroller.update(axisPos: 290, viewportExtent: 300);
        expect(axis.offset, 0, reason: 'no scroll until the timer ticks');

        async.elapse(const Duration(milliseconds: 16 * 4));

        expect(axis.offset, greaterThan(0));
        expect(scrolledCallbacks, greaterThan(0),
            reason: 'onScrolled fires for each tick that moved the view');

        scroller.dispose();
      });
    });

    test('leaving the edge zone stops the timer', () {
      fakeAsync((async) {
        final axis = _FakeAxis(maxExtent: 1000);
        final scroller = EdgeAutoScroller(
          edgeZone: 50,
          maxSpeed: 8,
          scrollBy: axis.by,
        );

        scroller.update(axisPos: 290, viewportExtent: 300);
        async.elapse(const Duration(milliseconds: 16 * 3));
        final moved = axis.offset;
        expect(moved, greaterThan(0));

        scroller.update(axisPos: 150, viewportExtent: 300); // out of the zone
        async.elapse(const Duration(milliseconds: 16 * 5));

        expect(axis.offset, moved,
            reason: 'no further scroll after leaving the zone');
        scroller.dispose();
      });
    });

    test('stops when the axis can no longer move (hit the extent)', () {
      fakeAsync((async) {
        final axis = _FakeAxis(maxExtent: 10); // almost no room
        final scroller = EdgeAutoScroller(
          edgeZone: 50,
          maxSpeed: 8,
          scrollBy: axis.by,
        );

        scroller.update(axisPos: 290, viewportExtent: 300);
        async.elapse(const Duration(milliseconds: 16 * 10));

        // Reached the extent; the timer must have stopped (fakeAsync would throw
        // on a leaked pending timer at the end of this callback otherwise).
        expect(axis.offset, 10);
      });
    });

    test('dispose cancels a running timer', () {
      fakeAsync((async) {
        final axis = _FakeAxis(maxExtent: 1000);
        final scroller = EdgeAutoScroller(
          edgeZone: 50,
          maxSpeed: 8,
          scrollBy: axis.by,
        );

        scroller.update(axisPos: 290, viewportExtent: 300);
        async.elapse(const Duration(milliseconds: 16 * 2));
        final moved = axis.offset;
        expect(moved, greaterThan(0));

        scroller.dispose();
        async.elapse(const Duration(milliseconds: 16 * 5));

        expect(axis.offset, moved, reason: 'no ticks after dispose');
      });
    });
  });
}
