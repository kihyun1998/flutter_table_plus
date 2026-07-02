import 'package:fake_async/fake_async.dart';
import 'package:flutter_table_plus/src/widgets/tap_counter.dart';
import 'package:flutter_test/flutter_test.dart';

// The tap-timing FSM, driven under fakeAsync so the double-tap window is exact.

const _timeout = Duration(milliseconds: 300);

void main() {
  test('with no double-tap handler, every tap is an immediate single tap', () {
    fakeAsync((async) {
      var taps = 0;
      final c = TapCounter();
      c.handleTap(doubleTapTimeout: _timeout, onTap: () => taps++);
      c.handleTap(doubleTapTimeout: _timeout, onTap: () => taps++);
      expect(taps, 2);
      async.elapse(const Duration(seconds: 1));
      c.dispose();
    });
  });

  test('a single tap fires onTap immediately, never onDoubleTap', () {
    fakeAsync((async) {
      var taps = 0, doubles = 0;
      final c = TapCounter();
      c.handleTap(
        doubleTapTimeout: _timeout,
        onTap: () => taps++,
        onDoubleTap: () => doubles++,
      );
      expect(taps, 1);
      expect(doubles, 0);
      async.elapse(_timeout + const Duration(milliseconds: 1)); // window closes
      expect(doubles, 0);
      c.dispose();
    });
  });

  test('two taps within the window make a double tap', () {
    fakeAsync((async) {
      var taps = 0, doubles = 0;
      final c = TapCounter();
      void tap() => c.handleTap(
            doubleTapTimeout: _timeout,
            onTap: () => taps++,
            onDoubleTap: () => doubles++,
          );
      tap();
      async.elapse(const Duration(milliseconds: 100));
      tap();
      expect(taps, 1); // onTap only on the first click
      expect(doubles, 1);
      c.dispose();
    });
  });

  test('a second tap after the window is another single tap, not a double', () {
    fakeAsync((async) {
      var taps = 0, doubles = 0;
      final c = TapCounter();
      void tap() => c.handleTap(
            doubleTapTimeout: _timeout,
            onTap: () => taps++,
            onDoubleTap: () => doubles++,
          );
      tap();
      async.elapse(_timeout + const Duration(milliseconds: 1)); // count resets
      tap();
      expect(taps, 2);
      expect(doubles, 0);
      c.dispose();
    });
  });

  test('a triple tap is a double followed by a single', () {
    fakeAsync((async) {
      var taps = 0, doubles = 0;
      final c = TapCounter();
      void tap() => c.handleTap(
            doubleTapTimeout: _timeout,
            onTap: () => taps++,
            onDoubleTap: () => doubles++,
          );
      tap(); // 1st -> onTap
      tap(); // 2nd -> onDoubleTap (resets)
      tap(); // 3rd -> onTap again
      expect(taps, 2);
      expect(doubles, 1);
      c.dispose();
    });
  });
}
