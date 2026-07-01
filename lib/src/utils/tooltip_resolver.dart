import '../models/tooltip_behavior.dart';

/// Centralizes the "should a body cell show a tooltip?" decision that was
/// duplicated (and had already diverged on caching) between the normal cell and
/// the merged cell.
///
/// The decision is pure; the overflow measurement is injected as a lazy
/// [willOverflow] callback so each caller keeps control of *how* it measures
/// (the normal cell caches the result, the merged cell measures directly), and
/// so the measurement is skipped entirely when the behavior can't need it.
class TooltipResolver {
  const TooltipResolver._();

  /// Whether a body cell with the given [behavior] should show a tooltip.
  ///
  /// Tooltips only apply to ellipsized text ([isEllipsis]); empty text never
  /// shows one. [willOverflow] is evaluated only for
  /// [TooltipBehavior.onlyTextOverflow] on ellipsized text.
  static bool shouldShow({
    required TooltipBehavior behavior,
    required bool isEllipsis,
    required bool textIsEmpty,
    required bool Function() willOverflow,
  }) {
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
