import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_test/flutter_test.dart';

// TextOverflowDetector.willTextOverflow decides whether a single line of text
// would be truncated in the available width. The boundary cases (empty text,
// non-positive width) are deterministic; the fits-vs-overflows cases are
// asserted relationally so they don't depend on exact font metrics.

const _style = TextStyle(fontSize: 14);

bool _overflows(
  String text,
  double maxWidth, {
  TextScaler scaler = TextScaler.noScaling,
  TextStyle style = _style,
}) {
  return TextOverflowDetector.willTextOverflow(TextMeasurement(
    text: text,
    style: style,
    maxWidth: maxWidth,
    textScaler: scaler,
  ));
}

/// The width [text] needs on one unbounded line — measured, never written as a
/// literal. The widget-test font is a square per glyph, so any number written
/// by hand here would be measuring that font and not the screen.
double _needs(String text, {TextScaler scaler = TextScaler.noScaling}) {
  final p = TextPainter(
    text: TextSpan(text: text, style: _style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout(maxWidth: double.infinity);
  final w = p.width;
  p.dispose();
  return w;
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

  // A tripwire, not a guard. `willTextOverflow` used to return
  // `didExceedMaxLines || textWidth > maxWidth`, and the second disjunct was
  // unreachable: under the default `TextWidthBasis.parent` the painter's
  // reported width is the content width clamped into the range it was laid out
  // in, so it can never exceed `maxWidth`. Removing dead code cannot be proved
  // by a test that reddens — nothing could reach it — so the premise that made
  // it dead is asserted instead. If a Flutter release changes it, this fails and
  // someone re-reads that removal.
  test('a laid-out painter never reports a width above the one it was given',
      () {
    for (final w in [1.0, 10.0, 50.0, 500.0]) {
      final p = TextPainter(
        text: const TextSpan(
            text: 'a string far wider than any of these', style: _style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w);
      expect(p.size.width, lessThanOrEqualTo(w), reason: 'at maxWidth $w');
      p.dispose();
    }
  });

  group('the text scaler participates in the measurement', () {
    const text = 'Scaled';

    // A test written at TextScaler.noScaling cannot fail for this: the default
    // is the value at which the defect is invisible. The width is derived from
    // a painter here rather than written down, and it is chosen to be exactly
    // enough at 1.0 — so the same string at 1.25 must not fit.
    test('a string that fits unscaled does not fit at 1.25', () {
      final width = _needs(text);

      expect(_overflows(text, width), isFalse);
      expect(
        _overflows(text, width, scaler: const TextScaler.linear(1.25)),
        isTrue,
      );
    });

    test('the scaled string needs more room than the unscaled one', () {
      expect(
        _needs(text, scaler: const TextScaler.linear(1.25)),
        greaterThan(_needs(text)),
      );
    });
  });
}
