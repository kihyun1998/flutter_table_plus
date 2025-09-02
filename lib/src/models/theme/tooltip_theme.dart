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
    this.exitDuration = const Duration(milliseconds: 100),
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

  /// The length of time that a pointer must hover over a tooltip's widget
  /// before the tooltip will be shown.
  /// 
  /// Defaults to 500 milliseconds.
  final Duration waitDuration;

  /// The length of time that the tooltip will be shown after a tap or long press
  /// is released (touch devices only). This property does not affect mouse hover.
  /// 
  /// For mouse hover tooltips, the tooltip remains visible as long as the mouse
  /// is over the target widget and disappears based on [exitDuration].
  /// 
  /// Defaults to 2 seconds.
  final Duration showDuration;

  /// The length of time that a pointer must have stopped hovering over a
  /// tooltip's widget before the tooltip will be hidden.
  /// 
  /// This controls how quickly the tooltip disappears when the mouse exits
  /// the target widget area.
  /// 
  /// Defaults to 100 milliseconds.
  final Duration exitDuration;

  /// Whether to prefer showing the tooltip below the widget.
  /// 
  /// If true, the tooltip will be positioned below the widget when possible.
  /// If false, the tooltip will be positioned above the widget when possible.
  /// The actual position may vary based on available screen space.
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
    Duration? exitDuration,
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
      exitDuration: exitDuration ?? this.exitDuration,
      preferBelow: preferBelow ?? this.preferBelow,
    );
  }
}
