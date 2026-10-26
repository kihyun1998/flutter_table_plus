import 'package:flutter/widgets.dart';

import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import 'flutter_tooltip_plus.dart';

/// Wraps [child] in a [FlutterTooltipPlus] when [shouldShow], resolving the
/// tooltip content by the shared priority: `tooltipBuilder` (widget) >
/// `tooltipFormatter` (string) > [fallbackMessage] (the displayed text).
///
/// Shared by the normal cell and the merged cell, which previously inlined the
/// same builder/formatter/message ladder. Returns [child] unchanged when no
/// tooltip should show.
///
/// An empty resolved message is *not* one of those cases, though it was until
/// just_tooltip 0.4.4. A tooltip claims its ancestors the moment the pointer
/// enters it, so one built over an empty message used to take a
/// `rowTooltipBuilder` card down and then decline to draw, leaving the cell
/// showing nothing; the wrap had to be skipped here to prevent it. 0.4.4 gates
/// that claim on having something to draw, so an empty-message tooltip is now
/// inert — built, silent, and harmless to the card. Under 0.4.3 this function
/// would reissue that bug; the `^0.5.1` floor keeps it out.
///
/// A tooltip showing [fallbackMessage] repeats the text [child] already shows,
/// so it is excluded from semantics. One from `tooltipFormatter` or
/// `tooltipBuilder` is not.
Widget wrapWithTooltip<T>({
  required bool shouldShow,
  required Widget child,
  required TablePlusTooltipTheme theme,
  required Widget Function(BuildContext context, T rowData)? tooltipBuilder,
  required String Function(T rowData)? tooltipFormatter,
  required T? rowData,
  required String fallbackMessage,
}) {
  if (!shouldShow) return child;

  final data = rowData;
  if (tooltipBuilder != null && data != null) {
    return FlutterTooltipPlus(
      tooltipBuilder: (context) => tooltipBuilder(context, data),
      theme: theme,
      child: child,
    );
  }

  final formatted = (tooltipFormatter != null && data != null)
      ? tooltipFormatter(data)
      : null;

  return FlutterTooltipPlus(
    message: formatted ?? fallbackMessage,
    excludeFromSemantics: formatted == null,
    theme: theme,
    child: child,
  );
}
