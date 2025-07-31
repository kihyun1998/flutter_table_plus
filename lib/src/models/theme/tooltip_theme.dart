import 'package:flutter/material.dart';

/// Theme configuration for cell tooltips.
class TablePlusTooltipTheme {
  /// Creates a [TablePlusTooltipTheme] with the specified styling properties.
  const TablePlusTooltipTheme({
    this.enabled = true,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white,
    ),
    this.decoration = const BoxDecoration(
      color: Color(0xFF424242),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.margin = const EdgeInsets.all(0.0),
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 2),
    this.preferBelow = true,
  });

  /// Whether tooltips are enabled globally.
  /// If false, no tooltips will be shown regardless of column settings.
  final bool enabled;

  /// The text style for tooltip content.
  final TextStyle textStyle;

  /// The decoration for the tooltip background.
  final Decoration decoration;

  /// The padding inside the tooltip.
  final EdgeInsets padding;

  /// The margin around the tooltip.
  final EdgeInsets margin;

  /// The duration to wait before showing the tooltip after hover.
  final Duration waitDuration;

  /// The duration to show the tooltip.
  final Duration showDuration;

  /// Whether to prefer showing the tooltip below the widget.
  final bool preferBelow;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTooltipTheme copyWith({
    bool? enabled,
    TextStyle? textStyle,
    Decoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Duration? waitDuration,
    Duration? showDuration,
    bool? preferBelow,
  }) {
    return TablePlusTooltipTheme(
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      preferBelow: preferBelow ?? this.preferBelow,
    );
  }
}
