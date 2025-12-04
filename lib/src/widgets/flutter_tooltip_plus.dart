import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/models/theme/tooltip_theme.dart';

/// A wrapper widget that provides consistent tooltip functionality across
/// the Flutter Table Plus package.
///
/// This widget centralizes tooltip logic and applies [TablePlusTooltipTheme]
/// configuration to Flutter's standard [Tooltip] widget. It ensures all
/// tooltips in the table (cells, headers, merged rows) have consistent
/// styling and behavior.
///
/// Example usage:
/// ```dart
/// FlutterTooltipPlus(
///   message: 'This is a tooltip',
///   theme: tooltipTheme,
///   child: Text('Hover me'),
/// )
/// ```
class FlutterTooltipPlus extends StatelessWidget {
  /// Creates a [FlutterTooltipPlus] with the specified message and theme.
  const FlutterTooltipPlus({
    super.key,
    required this.message,
    required this.theme,
    required this.child,
  });

  /// The text to display in the tooltip.
  final String message;

  /// The tooltip theme configuration to apply.
  final TablePlusTooltipTheme theme;

  /// The widget below this widget in the tree.
  ///
  /// The tooltip will be displayed when this widget is hovered over.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textStyle: theme.textStyle,
      decoration: theme.decoration,
      padding: theme.padding,
      margin: theme.margin,
      waitDuration: theme.waitDuration,
      showDuration: theme.showDuration,
      preferBelow: theme.preferBelow,
      verticalOffset: theme.verticalOffset,
      child: child,
    );
  }
}
