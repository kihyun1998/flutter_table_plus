import 'package:flutter/material.dart';

/// Theme configuration for scrollbars.
class TablePlusScrollbarTheme {
  /// Creates a [TablePlusScrollbarTheme] with the specified styling properties.
  const TablePlusScrollbarTheme({
    this.showVertical = true,
    this.showHorizontal = true,
    this.trackWidth = 12.0,
    this.thickness,
    this.radius,
    this.thumbColor = const Color(0xFF757575),
    this.trackColor = const Color(0xFFE0E0E0),
    this.trackBorder,
    this.opacity = 1.0,
    this.hoverOnly = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Whether to show the vertical scrollbar.
  final bool showVertical;

  /// Whether to show the horizontal scrollbar.
  final bool showHorizontal;

  /// The width of the scrollbar track.
  final double trackWidth;

  /// The thickness of the scrollbar thumb.
  /// If null, defaults to trackWidth * 0.7.
  final double? thickness;

  /// The radius of the scrollbar thumb and track corners.
  /// If null, defaults to trackWidth / 2.
  final double? radius;

  /// The color of the scrollbar thumb.
  final Color thumbColor;

  /// The color of the scrollbar track.
  final Color trackColor;

  /// The border of the scrollbar track.
  final Border? trackBorder;

  /// The opacity of the scrollbar.
  final double opacity;

  /// Whether the scrollbar should only appear on hover.
  final bool hoverOnly;

  /// The animation duration for scrollbar appearance.
  final Duration animationDuration;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusScrollbarTheme copyWith({
    bool? showVertical,
    bool? showHorizontal,
    double? trackWidth,
    double? thickness,
    double? radius,
    Color? thumbColor,
    Color? trackColor,
    Border? trackBorder,
    double? opacity,
    bool? hoverOnly,
    Duration? animationDuration,
  }) {
    return TablePlusScrollbarTheme(
      showVertical: showVertical ?? this.showVertical,
      showHorizontal: showHorizontal ?? this.showHorizontal,
      trackWidth: trackWidth ?? this.trackWidth,
      thickness: thickness ?? this.thickness,
      radius: radius ?? this.radius,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      trackBorder: trackBorder ?? this.trackBorder,
      opacity: opacity ?? this.opacity,
      hoverOnly: hoverOnly ?? this.hoverOnly,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
