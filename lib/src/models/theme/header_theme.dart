import 'package:flutter/material.dart';

import '../../../flutter_table_plus.dart' show SortIcons;

/// Theme configuration for a horizontal border (top or bottom) in the header.
class TablePlusHeaderBorderTheme {
  /// Creates a [TablePlusHeaderBorderTheme] with the specified styling properties.
  const TablePlusHeaderBorderTheme({
    this.show = true,
    this.color = const Color(0xFFE0E0E0),
    this.thickness = 1.0,
  });

  /// Whether this border is visible.
  final bool show;

  /// The color of this border.
  final Color color;

  /// The thickness of this border.
  final double thickness;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderBorderTheme copyWith({
    bool? show,
    Color? color,
    double? thickness,
  }) {
    return TablePlusHeaderBorderTheme(
      show: show ?? this.show,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
    );
  }
}

/// Theme configuration for the vertical divider between header columns.
///
/// Supports [indent] and [endIndent] to control the top and bottom insets
/// of the divider line, similar to Flutter's [VerticalDivider] widget.
class TablePlusHeaderDividerTheme {
  /// Creates a [TablePlusHeaderDividerTheme] with the specified styling properties.
  const TablePlusHeaderDividerTheme({
    this.show = true,
    this.color = const Color(0xFFE0E0E0),
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  /// Whether vertical dividers are visible between columns.
  final bool show;

  /// The color of the vertical divider.
  final Color color;

  /// The thickness of the vertical divider.
  final double thickness;

  /// The amount of empty space on top of the divider.
  final double indent;

  /// The amount of empty space below the divider.
  final double endIndent;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderDividerTheme copyWith({
    bool? show,
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent,
  }) {
    return TablePlusHeaderDividerTheme(
      show: show ?? this.show,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }
}

/// Theme configuration for the column resize handle in the header.
///
/// Controls the appearance of the drag-to-resize indicator shown at
/// column boundaries when [resizable] is enabled. The [width] defines
/// the invisible hit-test area, while [thickness], [color], [indent],
/// and [endIndent] control the visible indicator line.
class TablePlusResizeHandleTheme {
  /// Creates a [TablePlusResizeHandleTheme] with the specified styling properties.
  const TablePlusResizeHandleTheme({
    this.width = 8.0,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  /// The hit-test width of the resize handle area at the right edge of header cells.
  final double width;

  /// The color of the resize indicator line shown on hover/drag.
  /// If null, uses [TablePlusHeaderDividerTheme.color] from the header's
  /// [TablePlusHeaderTheme.verticalDivider].
  final Color? color;

  /// The thickness of the visible resize indicator line.
  final double thickness;

  /// The amount of empty space above the visible resize indicator line.
  final double indent;

  /// The amount of empty space below the visible resize indicator line.
  final double endIndent;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusResizeHandleTheme copyWith({
    double? width,
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent,
  }) {
    return TablePlusResizeHandleTheme(
      width: width ?? this.width,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }
}

/// Theme configuration for the table header.
class TablePlusHeaderTheme {
  /// Creates a [TablePlusHeaderTheme] with the specified styling properties.
  const TablePlusHeaderTheme({
    this.height = 56.0,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decoration,
    this.cellDecoration,
    this.topBorder = const TablePlusHeaderBorderTheme(show: false),
    this.bottomBorder = const TablePlusHeaderBorderTheme(),
    this.verticalDivider = const TablePlusHeaderDividerTheme(),
    // Sort-related styling
    this.sortedColumnBackgroundColor,
    this.sortedColumnTextStyle,
    this.sortIcons = SortIcons.defaultIcons,
    this.sortIconSpacing = 4.0,
    this.sortIconWidth = 16.0,
    // Resize handle styling
    this.resizeHandle = const TablePlusResizeHandleTheme(),
  });

  /// The height of the header row.
  final double height;

  /// The background color of the header.
  final Color backgroundColor;

  /// The text style for header labels.
  final TextStyle textStyle;

  /// The padding inside header cells.
  final EdgeInsets padding;

  /// Optional decoration for the entire header container.
  final Decoration? decoration;

  /// Optional decoration for individual header cells.
  final Decoration? cellDecoration;

  /// Theme for the top horizontal border of the header.
  ///
  /// Defaults to hidden (`show: false`).
  final TablePlusHeaderBorderTheme topBorder;

  /// Theme for the bottom horizontal border of the header.
  ///
  /// Defaults to visible (`show: true`).
  final TablePlusHeaderBorderTheme bottomBorder;

  /// Theme for the vertical dividers between header columns.
  ///
  /// Supports [TablePlusHeaderDividerTheme.indent] and
  /// [TablePlusHeaderDividerTheme.endIndent] for top/bottom insets.
  /// Defaults to visible (`show: true`).
  final TablePlusHeaderDividerTheme verticalDivider;

  /// Background color for columns that are currently sorted.
  /// If null, uses [backgroundColor] for all columns.
  final Color? sortedColumnBackgroundColor;

  /// Text style for columns that are currently sorted.
  /// If null, uses [textStyle] for all columns.
  final TextStyle? sortedColumnTextStyle;

  /// Icons to display for different sort states.
  final SortIcons sortIcons;

  /// Spacing between the column label and sort icon.
  final double sortIconSpacing;

  /// The width allocated for the sort icon widget.
  ///
  /// The sort icon is wrapped in a [SizedBox] of this width to ensure
  /// consistent layout and accurate tooltip overflow detection.
  /// Adjust this value when using custom sort icons with a different size.
  final double sortIconWidth;

  /// Theme for the column resize handle shown at column boundaries.
  ///
  /// Controls the hit-test area width and the visible indicator line styling.
  /// If [TablePlusResizeHandleTheme.color] is null, uses [verticalDivider.color].
  final TablePlusResizeHandleTheme resizeHandle;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderTheme copyWith({
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Decoration? decoration,
    Decoration? cellDecoration,
    TablePlusHeaderBorderTheme? topBorder,
    TablePlusHeaderBorderTheme? bottomBorder,
    TablePlusHeaderDividerTheme? verticalDivider,
    Color? sortedColumnBackgroundColor,
    TextStyle? sortedColumnTextStyle,
    SortIcons? sortIcons,
    double? sortIconSpacing,
    double? sortIconWidth,
    TablePlusResizeHandleTheme? resizeHandle,
  }) {
    return TablePlusHeaderTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      cellDecoration: cellDecoration ?? this.cellDecoration,
      topBorder: topBorder ?? this.topBorder,
      bottomBorder: bottomBorder ?? this.bottomBorder,
      verticalDivider: verticalDivider ?? this.verticalDivider,
      sortedColumnBackgroundColor:
          sortedColumnBackgroundColor ?? this.sortedColumnBackgroundColor,
      sortedColumnTextStyle:
          sortedColumnTextStyle ?? this.sortedColumnTextStyle,
      sortIcons: sortIcons ?? this.sortIcons,
      sortIconSpacing: sortIconSpacing ?? this.sortIconSpacing,
      sortIconWidth: sortIconWidth ?? this.sortIconWidth,
      resizeHandle: resizeHandle ?? this.resizeHandle,
    );
  }
}
