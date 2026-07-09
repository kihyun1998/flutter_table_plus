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
      anchor: theme.anchor,
      theme: theme,
      child: child,
    );
  }

  final message = (tooltipFormatter != null && data != null)
      ? tooltipFormatter(data)
      : fallbackMessage;
  return FlutterTooltipPlus(
    message: message,
    anchor: theme.anchor,
    theme: theme,
    child: child,
  );
}
