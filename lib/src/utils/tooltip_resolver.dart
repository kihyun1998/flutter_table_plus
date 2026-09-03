import '../models/tooltip_behavior.dart';

/// Centralizes the "should a body cell show a tooltip?" decision that was
/// duplicated (and had already diverged on caching) between the ordinary cell
/// and the merged row's own cells.
///
/// The decision is pure; the overflow measurement is injected as a lazy
/// [willOverflow] callback so each caller keeps control of *how* it measures,
/// and so the measurement is skipped entirely when the behavior can't need it.
///
/// Since #155 a group's *member* cells are ordinary cells and measure through
/// that widget's cache like any other row. The one uncached caller left is the
/// merged row's *spanning* cell, which has no per-cell state to cache in.
class TooltipResolver {
  const TooltipResolver._();

  /// Whether a body cell with the given [behavior] should show a tooltip.
  ///
  /// A cell with a widget tooltip ([hasWidgetTooltip]) draws content of its
  /// own, unrelated to the cell's text, so the text gates do not apply to it:
  /// only [TooltipBehavior.never] suppresses it. "Text overflow" is undefined
  /// for builder content, so [TooltipBehavior.onlyTextOverflow] shows it too.
  ///
  /// For a *text* tooltip the gates stand: it only applies to ellipsized text
  /// ([isEllipsis]), and empty text never shows one. [willOverflow] is
  /// evaluated only for [TooltipBehavior.onlyTextOverflow] on ellipsized text.
  static bool shouldShow({
    required TooltipBehavior behavior,
    required bool hasWidgetTooltip,
    required bool isEllipsis,
    required bool textIsEmpty,
    required bool Function() willOverflow,
  }) {
    if (behavior == TooltipBehavior.never) return false;
    if (hasWidgetTooltip) return true;
    if (textIsEmpty) return false;
    switch (behavior) {
      case TooltipBehavior.never:
        return false;
      case TooltipBehavior.always:
        return isEllipsis;
      case TooltipBehavior.onlyTextOverflow:
        return isEllipsis && willOverflow();
    }
  }
}
