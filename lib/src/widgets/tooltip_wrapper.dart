import 'package:flutter/widgets.dart';

import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import 'flutter_tooltip_plus.dart';

/// Wraps [child] in a [FlutterTooltipPlus] when [shouldShow], resolving the
/// tooltip content by the shared priority: `tooltipBuilder` (widget) >
/// `tooltipFormatter` (string) > [fallbackMessage] (the displayed text).
///
/// Shared by the normal cell and the merged cell, which previously inlined the
/// same builder/formatter/message ladder. Returns [child] unchanged when no
/// tooltip should show — including when the resolved message is empty and the
/// theme would hide it anyway. That last case looks like a tooltip nobody would
/// miss, but a tooltip suppresses its ancestors the moment the pointer enters
/// it, and it does so before deciding it has nothing to draw. Wrapping [child]
/// in one would take the row card down with it and put nothing in its place.
/// The header has always guarded this way (an empty label gets no tooltip); the
/// message the cell resolves is only known after [tooltipFormatter] runs.
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

  final message = (tooltipFormatter != null && data != null)
      ? tooltipFormatter(data)
      : fallbackMessage;
  if (message.isEmpty && theme.hideOnEmptyMessage) return child;

  return FlutterTooltipPlus(
    message: message,
    theme: theme,
    child: child,
  );
}
