import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart';

import '../models/theme/tooltip_theme.dart';

/// A unified tooltip wrapper widget for Flutter Table Plus.
///
/// This widget wraps [JustTooltip] and applies [TablePlusTooltipTheme]
/// configuration. It supports both text-based tooltips (via [message]) and
/// rich widget tooltips (via [tooltipBuilder]).
///
/// Example usage with text:
/// ```dart
/// FlutterTooltipPlus(
///   message: 'This is a tooltip',
///   theme: tooltipTheme,
///   child: Text('Hover me'),
/// )
/// ```
///
/// Example usage with custom widget:
/// ```dart
/// FlutterTooltipPlus(
///   tooltipBuilder: (context) => MyCustomWidget(),
///   theme: tooltipTheme,
///   child: Text('Hover me'),
/// )
/// ```
class FlutterTooltipPlus extends StatelessWidget {
  /// Creates a [FlutterTooltipPlus] with a text message.
  const FlutterTooltipPlus({
    super.key,
    this.message,
    this.tooltipBuilder,
    required this.theme,
    required this.child,
  });

  /// The text to display in the tooltip.
  /// Either [message] or [tooltipBuilder] should be provided.
  final String? message;

  /// A builder for custom widget content in the tooltip.
  /// Either [message] or [tooltipBuilder] should be provided.
  final WidgetBuilder? tooltipBuilder;

  /// The tooltip theme configuration to apply.
  final TablePlusTooltipTheme theme;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return JustTooltip(
      message: message,
      tooltipBuilder: tooltipBuilder,
      theme: theme.toJustTooltipTheme(),
      direction: theme.direction,
      alignment: theme.alignment,
      offset: theme.offset,
      crossAxisOffset: theme.crossAxisOffset,
      screenMargin: theme.screenMargin,
      enableTap: theme.enableTap,
      enableHover: theme.enableHover,
      interactive: theme.interactive,
      waitDuration: theme.waitDuration,
      showDuration: theme.showDuration,
      animation: theme.animation,
      animationCurve: theme.animationCurve,
      fadeBegin: theme.fadeBegin,
      scaleBegin: theme.scaleBegin,
      slideOffset: theme.slideOffset,
      rotationBegin: theme.rotationBegin,
      animationDuration: theme.animationDuration,
      hideOnEmptyMessage: theme.hideOnEmptyMessage,
      child: child,
    );
  }
}
