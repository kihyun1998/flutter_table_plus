import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart';

/// Theme configuration for cell tooltips.
///
/// This theme integrates with the `just_tooltip` package, providing a unified
/// configuration for both text-based and widget-based tooltips throughout the table.
///
/// Properties are divided into:
/// - **Visual styling** (mapped to [JustTooltipTheme]): `backgroundColor`, `borderRadius`,
///   `padding`, `elevation`, `boxShadow`, `borderColor`, `borderWidth`, `textStyle`,
///   `showArrow`, `arrowBaseWidth`, `arrowLength`, `arrowPositionRatio`
/// - **Layout & behavior** (passed to [JustTooltip] widget): `direction`, `alignment`,
///   `offset`, `crossAxisOffset`, `screenMargin`, `enableTap`, `enableHover`,
///   `interactive`, `waitDuration`, `showDuration`, `animation`, `animationCurve`,
///   `fadeBegin`, `scaleBegin`, `slideOffset`, `rotationBegin`, `animationDuration`
/// - **Toggle** : `enabled`, `hideOnEmptyMessage`
class TablePlusTooltipTheme {
  /// Creates a [TablePlusTooltipTheme] with the specified styling properties.
  const TablePlusTooltipTheme({
    // Toggle
    this.enabled = true,
    this.hideOnEmptyMessage = true,
    // Visual (JustTooltipTheme)
    this.backgroundColor = const Color(0xFF616161),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.elevation = 4.0,
    this.boxShadow,
    this.borderColor,
    this.borderWidth = 0.0,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.showArrow = false,
    this.arrowBaseWidth = 12.0,
    this.arrowLength = 6.0,
    this.arrowPositionRatio = 0.25,
    // Layout & behavior
    this.anchor = TooltipAnchor.child,
    this.direction = TooltipDirection.bottom,
    this.alignment = TooltipAlignment.center,
    this.offset = 8.0,
    this.crossAxisOffset = 0.0,
    this.screenMargin = 8.0,
    this.enableTap = false,
    this.enableHover = true,
    this.interactive = true,
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration,
    this.animation = TooltipAnimation.fade,
    this.animationCurve,
    this.fadeBegin = 0.0,
    this.scaleBegin = 0.0,
    this.slideOffset = 0.3,
    this.rotationBegin = -0.05,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  // ── Toggle ──────────────────────────────────────────────────────────

  /// Whether tooltips are enabled globally.
  /// If false, no tooltips will be shown regardless of column settings.
  final bool enabled;

  /// Whether to suppress the tooltip when the message is empty.
  final bool hideOnEmptyMessage;

  // ── Visual (mapped to JustTooltipTheme) ─────────────────────────────

  /// The background color of the tooltip.
  final Color backgroundColor;

  /// The border radius of the tooltip.
  final BorderRadius borderRadius;

  /// The padding inside the tooltip.
  final EdgeInsets padding;

  /// The shadow elevation of the tooltip.
  final double elevation;

  /// Optional custom box shadows for the tooltip.
  final List<BoxShadow>? boxShadow;

  /// Optional border color of the tooltip.
  final Color? borderColor;

  /// The border width of the tooltip.
  final double borderWidth;

  /// The text style for tooltip content.
  final TextStyle textStyle;

  /// Whether to show an arrow indicator pointing to the target widget.
  final bool showArrow;

  /// The base width of the arrow.
  final double arrowBaseWidth;

  /// The length (protrusion) of the arrow.
  final double arrowLength;

  /// The position ratio of the arrow along the tooltip edge (0.0 to 1.0).
  final double arrowPositionRatio;

  // ── Layout & behavior (passed to JustTooltip widget) ────────────────

  /// What the tooltip is positioned against.
  ///
  /// [TooltipAnchor.child] (the default) places the tooltip beside the rect of
  /// the widget it wraps. [TooltipAnchor.pointer] leaves the hover region alone
  /// and places the tooltip beside the cursor instead — useful when the hovered
  /// widget is much wider than the neighbourhood the user is pointing at, such
  /// as a long ellipsized cell.
  ///
  /// This governs cell and header tooltips. Row tooltips built by
  /// `rowTooltipBuilder` always use [TooltipAnchor.pointer] and ignore this
  /// field: a row is as wide as the table's content, so anchoring to it would
  /// aim at a point that may be off screen.
  ///
  /// Note that header and cell tooltips currently share a single
  /// `TablePlusTheme.tooltipTheme`, so their anchors cannot be set separately.
  ///
  /// See also [alignment], whose meaning depends on this field.
  final TooltipAnchor anchor;

  /// The direction (side) where the tooltip appears relative to the child.
  final TooltipDirection direction;

  /// The cross-axis alignment of the tooltip relative to the child.
  ///
  /// Available values: [TooltipAlignment.start], [TooltipAlignment.center],
  /// [TooltipAlignment.end], [TooltipAlignment.startTargetCenter],
  /// [TooltipAlignment.endTargetCenter].
  ///
  /// The `startTargetCenter` and `endTargetCenter` alignments position the
  /// arrow to dynamically point toward the center of the target widget.
  ///
  /// Under [TooltipAnchor.pointer] this field changes meaning. A point has no
  /// edges to align against, so the alignment instead selects which of the
  /// tooltip's *own* edges lands on the cursor.
  final TooltipAlignment alignment;

  /// The gap between the child widget and the tooltip.
  final double offset;

  /// The cross-axis shift of the tooltip.
  final double crossAxisOffset;

  /// The minimum distance from the viewport edge.
  final double screenMargin;

  /// Whether to show the tooltip on tap.
  final bool enableTap;

  /// Whether to show the tooltip on hover.
  final bool enableHover;

  /// Whether the tooltip stays visible when the mouse is over the tooltip itself.
  final bool interactive;

  /// The length of time that a pointer must hover over a tooltip's widget
  /// before the tooltip will be shown.
  final Duration waitDuration;

  /// The length of time that the tooltip will be shown after activation.
  /// If null, the tooltip stays visible until the pointer leaves.
  final Duration? showDuration;

  /// The type of animation when showing/hiding the tooltip.
  final TooltipAnimation animation;

  /// The curve for the tooltip animation.
  final Curve? animationCurve;

  /// The starting opacity for fade animations.
  final double fadeBegin;

  /// The starting scale for scale animations.
  final double scaleBegin;

  /// The slide distance ratio for slide animations.
  final double slideOffset;

  /// The starting rotation for rotation animations.
  final double rotationBegin;

  /// The duration of the tooltip animation.
  final Duration animationDuration;

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Converts visual properties to a [JustTooltipTheme] instance.
  JustTooltipTheme toJustTooltipTheme() {
    return JustTooltipTheme(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      elevation: elevation,
      boxShadow: boxShadow,
      borderColor: borderColor,
      borderWidth: borderWidth,
      textStyle: textStyle,
      showArrow: showArrow,
      arrowBaseWidth: arrowBaseWidth,
      arrowLength: arrowLength,
      arrowPositionRatio: arrowPositionRatio,
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTooltipTheme copyWith({
    bool? enabled,
    bool? hideOnEmptyMessage,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? elevation,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    double? borderWidth,
    TextStyle? textStyle,
    bool? showArrow,
    double? arrowBaseWidth,
    double? arrowLength,
    double? arrowPositionRatio,
    TooltipAnchor? anchor,
    TooltipDirection? direction,
    TooltipAlignment? alignment,
    double? offset,
    double? crossAxisOffset,
    double? screenMargin,
    bool? enableTap,
    bool? enableHover,
    bool? interactive,
    Duration? waitDuration,
    Duration? showDuration,
    TooltipAnimation? animation,
    Curve? animationCurve,
    double? fadeBegin,
    double? scaleBegin,
    double? slideOffset,
    double? rotationBegin,
    Duration? animationDuration,
  }) {
    return TablePlusTooltipTheme(
      enabled: enabled ?? this.enabled,
      hideOnEmptyMessage: hideOnEmptyMessage ?? this.hideOnEmptyMessage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      boxShadow: boxShadow ?? this.boxShadow,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      textStyle: textStyle ?? this.textStyle,
      showArrow: showArrow ?? this.showArrow,
      arrowBaseWidth: arrowBaseWidth ?? this.arrowBaseWidth,
      arrowLength: arrowLength ?? this.arrowLength,
      arrowPositionRatio: arrowPositionRatio ?? this.arrowPositionRatio,
      anchor: anchor ?? this.anchor,
      direction: direction ?? this.direction,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      screenMargin: screenMargin ?? this.screenMargin,
      enableTap: enableTap ?? this.enableTap,
      enableHover: enableHover ?? this.enableHover,
      interactive: interactive ?? this.interactive,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      animation: animation ?? this.animation,
      animationCurve: animationCurve ?? this.animationCurve,
      fadeBegin: fadeBegin ?? this.fadeBegin,
      scaleBegin: scaleBegin ?? this.scaleBegin,
      slideOffset: slideOffset ?? this.slideOffset,
      rotationBegin: rotationBegin ?? this.rotationBegin,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
