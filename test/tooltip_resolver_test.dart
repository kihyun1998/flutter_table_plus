import 'package:flutter_table_plus/src/models/tooltip_behavior.dart';
import 'package:flutter_table_plus/src/utils/tooltip_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TooltipResolver.shouldShow (cell/body policy)', () {
    bool never() => throw StateError('willOverflow must not be evaluated');

    test('empty text never shows a tooltip', () {
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.always,
          isEllipsis: true,
          textIsEmpty: true,
          willOverflow: never,
        ),
        isFalse,
      );
    });

    test('behavior never shows nothing', () {
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.never,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: never,
        ),
        isFalse,
      );
    });

    test('always shows only when the text is ellipsized', () {
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.always,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: never,
        ),
        isTrue,
      );
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.always,
          isEllipsis: false,
          textIsEmpty: false,
          willOverflow: never,
        ),
        isFalse,
      );
    });

    test('onlyTextOverflow requires ellipsis and actual overflow', () {
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.onlyTextOverflow,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: () => true,
        ),
        isTrue,
      );
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.onlyTextOverflow,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: () => false,
        ),
        isFalse,
      );
    });

    test('onlyTextOverflow skips the overflow measurement when not ellipsized',
        () {
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.onlyTextOverflow,
          isEllipsis: false,
          textIsEmpty: false,
          willOverflow: never, // must not be called
        ),
        isFalse,
      );
    });
  });
}
