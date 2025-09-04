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
    this.customWrapper = const CustomTooltipWrapperTheme(),
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

  /// Configuration for CustomTooltipWrapper positioning and behavior.
  ///
  /// This contains settings specific to widget-based tooltips created with
  /// tooltipBuilder. Basic text tooltips only use the main theme properties.
  final CustomTooltipWrapperTheme customWrapper;

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
    CustomTooltipWrapperTheme? customWrapper,
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
      customWrapper: customWrapper ?? this.customWrapper,
    );
  }
}

/// Theme configuration specifically for CustomTooltipWrapper positioning and behavior.
///
/// This class contains settings that are only relevant for widget-based tooltips
/// created with tooltipBuilder. Basic text tooltips use only the main
/// TablePlusTooltipTheme properties.
class CustomTooltipWrapperTheme {
  /// Creates a [CustomTooltipWrapperTheme] with the specified positioning properties.
  const CustomTooltipWrapperTheme({
    this.maxWidth = 300.0,
    this.spacingPadding = 8.0,
    this.horizontalPadding = 8.0,
    this.minSpace = 100.0,
    this.minScrollHeight = 80.0,
    this.estimatedHeight = 150.0,
  });

  /// Maximum width constraint for the tooltip content.
  ///
  /// This limits how wide the tooltip can be, forcing content to wrap or scroll
  /// if it exceeds this width. Defaults to 300.0 pixels.
  final double maxWidth;

  /// Spacing padding between the tooltip and the target widget.
  ///
  /// This controls the gap between the tooltip and the element that triggered it.
  /// Used for both above and below positioning. Defaults to 8.0 pixels.
  final double spacingPadding;

  /// Horizontal padding from screen edges when positioning the tooltip.
  ///
  /// This ensures the tooltip doesn't touch the screen edges and provides
  /// visual breathing room. Defaults to 8.0 pixels.
  final double horizontalPadding;

  /// Minimum space required to show a tooltip without intelligent positioning.
  ///
  /// If available space is less than this value, the tooltip may switch to
  /// the opposite side for better visibility. Defaults to 100.0 pixels.
  final double minSpace;

  /// Minimum height required for meaningful scrolling when content overflows.
  ///
  /// If available space is less than this value, the tooltip may switch sides
  /// to provide better scrolling experience. Defaults to 80.0 pixels.
  final double minScrollHeight;

  /// Estimated height of tooltip content for overflow calculations.
  ///
  /// This value is used to determine if content will likely overflow before
  /// positioning the tooltip. A more sophisticated implementation could
  /// dynamically calculate this based on content. Defaults to 150.0 pixels.
  final double estimatedHeight;

  /// Creates a copy of this theme with the given fields replaced with new values.
  CustomTooltipWrapperTheme copyWith({
    double? maxWidth,
    double? spacingPadding,
    double? horizontalPadding,
    double? minSpace,
    double? minScrollHeight,
    double? estimatedHeight,
  }) {
    return CustomTooltipWrapperTheme(
      maxWidth: maxWidth ?? this.maxWidth,
      spacingPadding: spacingPadding ?? this.spacingPadding,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      minSpace: minSpace ?? this.minSpace,
      minScrollHeight: minScrollHeight ?? this.minScrollHeight,
      estimatedHeight: estimatedHeight ?? this.estimatedHeight,
    );
  }
}
