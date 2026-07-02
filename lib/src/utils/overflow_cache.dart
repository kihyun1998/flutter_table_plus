/// A single-slot memo for the "does this text overflow?" measurement, keyed on
/// the `(text, width)` pair.
///
/// Text-overflow measurement (via `TextPainter`) is comparatively expensive, so
/// a cell caches the last result and reuses it while the text and available
/// width are unchanged. Extracted from the cell's three loose cache fields into
/// one object so the cache-hit / invalidate-on-change logic is unit-testable.
class OverflowCache {
  String? _text;
  double? _width;
  bool? _result;

  /// Returns the cached result when [text] and [width] match the last call;
  /// otherwise calls [measure], stores, and returns its result.
  bool resolve(String text, double width, bool Function() measure) {
    if (_result != null && _text == text && _width == width) {
      return _result!;
    }
    final result = measure();
    _text = text;
    _width = width;
    _result = result;
    return result;
  }
}
