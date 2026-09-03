import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/utils/overflow_cache.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_test/flutter_test.dart';

const _style = TextStyle(fontSize: 14);

TextMeasurement _m(
  String text,
  double width, {
  TextStyle style = _style,
  TextScaler scaler = TextScaler.noScaling,
  TextDirection direction = TextDirection.ltr,
}) =>
    TextMeasurement(
      text: text,
      maxWidth: width,
      style: style,
      textScaler: scaler,
      textDirection: direction,
    );

void main() {
  group('OverflowCache', () {
    test('measures on the first call and returns the result', () {
      final cache = OverflowCache();
      var calls = 0;
      final r = cache.resolve(_m('hello', 100), () {
        calls++;
        return true;
      });
      expect(r, isTrue);
      expect(calls, 1);
    });

    test('reuses the cached result for the same measurement', () {
      final cache = OverflowCache();
      var calls = 0;
      bool run() => cache.resolve(_m('hello', 100), () {
            calls++;
            return true;
          });
      run();
      run();
      expect(calls, 1); // measured only once
    });

    test('re-measures when the text changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve(_m('a', 100), () {
        calls++;
        return false;
      });
      cache.resolve(_m('b', 100), () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    test('re-measures when the width changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve(_m('a', 100), () {
        calls++;
        return false;
      });
      cache.resolve(_m('a', 120), () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    // The two inputs the old `(text, width)` key could not see. A row that
    // becomes selected changes the style; an OS text-size change changes the
    // scaler. Neither moves the text or the width, so under the old key both
    // served the answer computed before the change, for as long as the cell
    // stayed alive.
    test('re-measures when the style changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve(_m('a', 100), () {
        calls++;
        return false;
      });
      cache.resolve(
        _m('a', 100,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        () {
          calls++;
          return true;
        },
      );
      expect(calls, 2);
    });

    test('re-measures when the text scaler changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve(_m('a', 100), () {
        calls++;
        return false;
      });
      cache.resolve(_m('a', 100, scaler: const TextScaler.linear(1.25)), () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    test('re-measures when the text direction changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve(_m('a', 100), () {
        calls++;
        return false;
      });
      cache.resolve(_m('a', 100, direction: TextDirection.rtl), () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    test('a cached false result is still reused (not treated as empty)', () {
      final cache = OverflowCache();
      var calls = 0;
      bool run() => cache.resolve(_m('a', 100), () {
            calls++;
            return false;
          });
      expect(run(), isFalse);
      expect(run(), isFalse);
      expect(calls, 1);
    });
  });
}
