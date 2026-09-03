import 'text_overflow_detector.dart';

/// A single-slot memo for the "does this text overflow?" measurement, keyed on
/// the [TextMeasurement] the answer was computed from.
///
/// Text-overflow measurement (via `TextPainter`) is comparatively expensive, so
/// a cell caches the last result and reuses it while the measurement is
/// unchanged. Extracted from the cell's three loose cache fields into one
/// object so the cache-hit / invalidate-on-change logic is unit-testable.
///
/// **The key is the measurement itself, deliberately.** It used to be the
/// `(text, width)` pair, which is a hand-written list of *some* of the inputs
/// the answer depends on — so a style change, or a change to the OS text-size
/// setting, left a wrong answer in place for as long as the cell stayed alive.
/// Keying on the value the measurement consumes means the two cannot list
/// different things, because there is only one list.
class OverflowCache {
  TextMeasurement? _key;
  bool? _result;

  /// Returns the cached result when [measurement] matches the last call;
  /// otherwise calls [measure], stores, and returns its result.
  bool resolve(TextMeasurement measurement, bool Function() measure) {
    if (_result != null && _key == measurement) {
      return _result!;
    }
    final result = measure();
    _key = measurement;
    _result = result;
    return result;
  }
}
