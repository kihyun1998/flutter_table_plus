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
          hasWidgetTooltip: false,
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
          hasWidgetTooltip: false,
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
          hasWidgetTooltip: false,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: never,
        ),
        isTrue,
      );
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.always,
          hasWidgetTooltip: false,
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
          hasWidgetTooltip: false,
          isEllipsis: true,
          textIsEmpty: false,
          willOverflow: () => true,
        ),
        isTrue,
      );
      expect(
        TooltipResolver.shouldShow(
          behavior: TooltipBehavior.onlyTextOverflow,
          hasWidgetTooltip: false,
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
          hasWidgetTooltip: false,
          isEllipsis: false,
          textIsEmpty: false,
          willOverflow: never, // must not be called
        ),
        isFalse,
      );
    });
  });

  group('TooltipResolver.shouldShow (widget tooltip)', () {
    bool never() => throw StateError('willOverflow must not be evaluated');

    // A widget tooltip draws content of its own, so the text gates — ellipsis
    // and emptiness — say nothing about whether it should appear.
    bool show(TooltipBehavior behavior) => TooltipResolver.shouldShow(
          behavior: behavior,
          hasWidgetTooltip: true,
          isEllipsis: false,
          textIsEmpty: true,
          willOverflow: never,
        );

    test('shows even when the text is neither ellipsized nor present', () {
      expect(show(TooltipBehavior.always), isTrue);
    });

    test('onlyTextOverflow shows it too — overflow is undefined for a widget',
        () {
      expect(show(TooltipBehavior.onlyTextOverflow), isTrue);
    });

    test('behavior never still suppresses it', () {
      expect(show(TooltipBehavior.never), isFalse);
    });
  });
}
