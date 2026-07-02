import 'dart:async';

/// The single-vs-double tap timing state machine.
///
/// Pure extraction of [CustomInkWell]'s tap logic so the timing — which is only
/// observable by pumping a widget and advancing real time — can be unit-tested
/// under `fakeAsync`. It owns just the transient state (click count + the
/// double-tap timer); the callbacks and timeout are passed in per tap so they
/// stay live with the host widget's current values.
///
/// Behavior: with no [onDoubleTap], every tap is an immediate single tap. With
/// one, the first tap fires [onTap] immediately and arms a timer; a second tap
/// before it elapses fires [onDoubleTap]; otherwise the count resets and the
/// next tap is a fresh single tap.
class TapCounter {
  int _clickCount = 0;
  Timer? _timer;

  void handleTap({
    required Duration doubleTapTimeout,
    void Function()? onTap,
    void Function()? onDoubleTap,
  }) {
    if (onDoubleTap == null) {
      // No double-tap handler — every tap is a plain single tap.
      onTap?.call();
      return;
    }

    _clickCount++;

    if (_clickCount == 1) {
      // First click — fire immediately (no delay), then arm the timer.
      onTap?.call();
      _timer = Timer(doubleTapTimeout, () => _clickCount = 0);
    } else if (_clickCount == 2) {
      // Second click within the window — it's a double tap.
      _timer?.cancel();
      onDoubleTap.call();
      _clickCount = 0;
    }
  }

  void dispose() => _timer?.cancel();
}
