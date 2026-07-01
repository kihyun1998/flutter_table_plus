import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_test/flutter_test.dart';

// TextOverflowDetector.willTextOverflow decides whether a single line of text
// would be truncated in the available width. The boundary cases (empty text,
// non-positive width) are deterministic; the fits-vs-overflows cases are
// asserted relationally so they don't depend on exact font metrics.

const _style = TextStyle(fontSize: 14);

bool _overflows(String text, double maxWidth) {
  return TextOverflowDetector.willTextOverflow(
    text: text,
    style: _style,
    maxWidth: maxWidth,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('willTextOverflow', () {
    test('empty text never overflows', () {
      expect(_overflows('', 10), isFalse);
    });

    test('non-positive width never overflows (guarded)', () {
      expect(_overflows('anything', 0), isFalse);
      expect(_overflows('anything', -5), isFalse);
    });

    test('short text in a generous width fits', () {
      expect(_overflows('Hi', 1000), isFalse);
    });

    test('long text in a tiny width overflows', () {
      expect(
        _overflows('a very long sentence that cannot possibly fit', 10),
        isTrue,
      );
    });
  });
}
