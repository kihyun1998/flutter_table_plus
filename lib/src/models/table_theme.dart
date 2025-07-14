import 'package:flutter/material.dart';

/// Theme configuration for the table components.
class TablePlusTheme {
  /// Creates a [TablePlusTheme] with the specified styling properties.
  const TablePlusTheme({
    this.headerTheme = const TablePlusHeaderTheme(),
    this.bodyTheme = const TablePlusBodyTheme(),
    this.scrollbarTheme = const TablePlusScrollbarTheme(),
  });

  /// Theme configuration for the table header.
  final TablePlusHeaderTheme headerTheme;

  /// Theme configuration for the table body.
  final TablePlusBodyTheme bodyTheme;

  /// Theme configuration for the scrollbars.
  final TablePlusScrollbarTheme scrollbarTheme;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
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
  });

  /// The height of the header row.
  final double height;

  /// The background color of the header.
  final Color backgroundColor;

  /// The text style for header labels.
  final TextStyle textStyle;

  /// The padding inside header cells.
  final EdgeInsets padding;

  /// Optional decoration for the header.
  final Decoration? decoration;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderTheme copyWith({
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Decoration? decoration,
  }) {
    return TablePlusHeaderTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
    );
  }
}

/// Theme configuration for the table body.
class TablePlusBodyTheme {
  /// Creates a [TablePlusBodyTheme] with the specified styling properties.
  const TablePlusBodyTheme({
    this.rowHeight = 48.0,
    this.backgroundColor = Colors.white,
    this.alternateRowColor,
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.dividerColor = const Color(0xFFE0E0E0),
    this.dividerThickness = 1.0,
  });

  /// The height of each data row.
  final double rowHeight;

  /// The background color of rows.
  final Color backgroundColor;

  /// The alternate row color for striped tables.
  /// If null, all rows will use [backgroundColor].
  final Color? alternateRowColor;

  /// The text style for body cells.
  final TextStyle textStyle;

  /// The padding inside body cells.
  final EdgeInsets padding;

  /// The color of row dividers.
  final Color dividerColor;

  /// The thickness of row dividers.
  final double dividerThickness;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
    );
  }
}

/// Theme configuration for scrollbars.
class TablePlusScrollbarTheme {
  /// Creates a [TablePlusScrollbarTheme] with the specified styling properties.
  const TablePlusScrollbarTheme({
    this.showVertical = true,
    this.showHorizontal = true,
    this.width = 12.0,
    this.color = const Color(0xFF757575),
    this.trackColor = const Color(0xFFE0E0E0),
    this.opacity = 1.0,
    this.hoverOnly = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Whether to show the vertical scrollbar.
  final bool showVertical;

  /// Whether to show the horizontal scrollbar.
  final bool showHorizontal;

  /// The width/thickness of the scrollbar.
  final double width;

  /// The color of the scrollbar thumb.
  final Color color;

  /// The color of the scrollbar track.
  final Color trackColor;

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
    double? width,
    Color? color,
    Color? trackColor,
    double? opacity,
    bool? hoverOnly,
    Duration? animationDuration,
  }) {
    return TablePlusScrollbarTheme(
      showVertical: showVertical ?? this.showVertical,
      showHorizontal: showHorizontal ?? this.showHorizontal,
      width: width ?? this.width,
      color: color ?? this.color,
      trackColor: trackColor ?? this.trackColor,
      opacity: opacity ?? this.opacity,
      hoverOnly: hoverOnly ?? this.hoverOnly,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
