import 'package:flutter_table_plus/src/utils/overflow_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverflowCache', () {
    test('measures on the first call and returns the result', () {
      final cache = OverflowCache();
      var calls = 0;
      final r = cache.resolve('hello', 100, () {
        calls++;
        return true;
      });
      expect(r, isTrue);
      expect(calls, 1);
    });

    test('reuses the cached result for the same (text, width)', () {
      final cache = OverflowCache();
      var calls = 0;
      bool run() => cache.resolve('hello', 100, () {
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
      cache.resolve('a', 100, () {
        calls++;
        return false;
      });
      cache.resolve('b', 100, () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    test('re-measures when the width changes', () {
      final cache = OverflowCache();
      var calls = 0;
      cache.resolve('a', 100, () {
        calls++;
        return false;
      });
      cache.resolve('a', 120, () {
        calls++;
        return true;
      });
      expect(calls, 2);
    });

    test('a cached false result is still reused (not treated as empty)', () {
      final cache = OverflowCache();
      var calls = 0;
      bool run() => cache.resolve('a', 100, () {
            calls++;
            return false;
          });
      expect(run(), isFalse);
      expect(run(), isFalse);
      expect(calls, 1);
    });
  });
}
