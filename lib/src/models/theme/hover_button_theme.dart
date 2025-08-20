import 'package:flutter/material.dart';

/// Theme configuration for hover buttons in table rows.
class TablePlusHoverButtonTheme {
  /// Creates a [TablePlusHoverButtonTheme] with the specified styling properties.
  const TablePlusHoverButtonTheme({
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.boxShadow = const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.iconSize = 16.0,
    this.iconColor,
    this.spacing = 4.0,
    this.horizontalOffset = 8.0,
    this.showOnHover = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.elevation = 0.0,
    this.editIconData = Icons.edit,
    this.deleteIconData = Icons.delete,
    this.editIconColor,
    this.deleteIconColor,
    this.opacity = 0.9,
  });

  /// The background color of the hover button container.
  final Color backgroundColor;

  /// The border color of the hover button container.
  /// If null, no border is displayed.
  final Color? borderColor;

  /// The border radius of the hover button container.
  final BorderRadius borderRadius;

  /// The box shadow for the hover button container.
  /// Set to empty list to disable shadows.
  final List<BoxShadow> boxShadow;

  /// The padding inside the hover button container.
  final EdgeInsetsGeometry padding;

  /// The size of the icons in hover buttons.
  final double iconSize;

  /// The default color for icons in hover buttons.
  /// If null, uses the theme's icon color.
  final Color? iconColor;

  /// The spacing between hover buttons.
  final double spacing;

  /// The horizontal offset from the row edge for left/right positioned buttons.
  /// This controls how far the buttons are positioned from the left or right edge of the row.
  final double horizontalOffset;

  /// Whether to show hover buttons only on row hover.
  /// If false, buttons are always visible.
  final bool showOnHover;

  /// The duration of hover button show/hide animations.
  final Duration animationDuration;

  /// The elevation of the hover button container.
  /// Uses Material elevation if greater than 0.
  final double elevation;

  /// The icon data for the default edit button.
  final IconData editIconData;

  /// The icon data for the default delete button.
  final IconData deleteIconData;

  /// The color for the edit icon.
  /// If null, uses [iconColor] or theme default.
  final Color? editIconColor;

  /// The color for the delete icon.
  /// If null, uses [iconColor] or theme default.
  final Color? deleteIconColor;

  /// The opacity of the hover button container.
  final double opacity;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHoverButtonTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    Color? iconColor,
    double? spacing,
    double? horizontalOffset,
    bool? showOnHover,
    Duration? animationDuration,
    double? elevation,
    IconData? editIconData,
    IconData? deleteIconData,
    Color? editIconColor,
    Color? deleteIconColor,
    double? opacity,
  }) {
    return TablePlusHoverButtonTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      spacing: spacing ?? this.spacing,
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
      showOnHover: showOnHover ?? this.showOnHover,
      animationDuration: animationDuration ?? this.animationDuration,
      elevation: elevation ?? this.elevation,
      editIconData: editIconData ?? this.editIconData,
      deleteIconData: deleteIconData ?? this.deleteIconData,
      editIconColor: editIconColor ?? this.editIconColor,
      deleteIconColor: deleteIconColor ?? this.deleteIconColor,
      opacity: opacity ?? this.opacity,
    );
  }

  /// Gets the effective icon color for a specific button type.
  Color? getEffectiveIconColor(String buttonType, BuildContext context) {
    switch (buttonType.toLowerCase()) {
      case 'edit':
        return editIconColor ?? iconColor ?? Theme.of(context).iconTheme.color;
      case 'delete':
        return deleteIconColor ??
            iconColor ??
            Theme.of(context).iconTheme.color;
      default:
        return iconColor ?? Theme.of(context).iconTheme.color;
    }
  }

  /// Gets the effective icon data for a specific button type.
  IconData getEffectiveIconData(String buttonType) {
    switch (buttonType.toLowerCase()) {
      case 'edit':
        return editIconData;
      case 'delete':
        return deleteIconData;
      default:
        return Icons.more_horiz;
    }
  }

  /// Default hover button theme.
  static const TablePlusHoverButtonTheme defaultTheme =
      TablePlusHoverButtonTheme();
}
