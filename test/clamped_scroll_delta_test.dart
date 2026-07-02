import 'package:flutter_table_plus/src/utils/clamped_scroll_delta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clampedScrollDelta', () {
    test('applies the full delta when it stays within the extents', () {
      expect(
        clampedScrollDelta(pixels: 10, delta: 20, min: 0, max: 100),
        20,
      );
    });

    test('clamps the move at the max extent', () {
      // 90 + 50 -> 100, so only 10 is actually applied.
      expect(
        clampedScrollDelta(pixels: 90, delta: 50, min: 0, max: 100),
        10,
      );
    });

    test('clamps the move at the min extent', () {
      expect(
        clampedScrollDelta(pixels: 10, delta: -50, min: 0, max: 100),
        -10,
      );
    });

    test('returns 0 when already at the boundary (no room)', () {
      expect(
        clampedScrollDelta(pixels: 100, delta: 5, min: 0, max: 100),
        0,
      );
    });

    test('a move of exactly epsilon is a no-op', () {
      expect(
        clampedScrollDelta(pixels: 0, delta: 0.5, min: 0, max: 100),
        0,
      );
    });

    test('a move just above epsilon is applied', () {
      expect(
        clampedScrollDelta(pixels: 0, delta: 0.6, min: 0, max: 100),
        0.6,
      );
    });

    test('epsilon is configurable', () {
      expect(
        clampedScrollDelta(pixels: 0, delta: 3, min: 0, max: 100, epsilon: 5),
        0,
      );
    });
  });
}
