import 'package:flutter/material.dart';

/// Enum for controlling when to show bottom border on the last row.
enum LastRowBorderBehavior {
  /// Never show bottom border on the last row (default, current behavior).
  never,

  /// Always show bottom border on the last row.
  always,

  /// Smart behavior: show bottom border only when there's no vertical scroll.
  /// When the table content fits within the viewport, shows the border for a clean finish.
  /// When vertical scrolling is needed, hides the border since more content is available.
  smart,
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
    this.showVerticalDividers = true,
    this.showHorizontalDividers = true,
    this.lastRowBorderBehavior = LastRowBorderBehavior.never,
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

  /// Whether to show vertical dividers between columns.
  final bool showVerticalDividers;

  /// Whether to show horizontal dividers between rows.
  final bool showHorizontalDividers;

  /// Controls when to show bottom border on the last row.
  ///
  /// - [LastRowBorderBehavior.never]: Never show bottom border on last row (default)
  /// - [LastRowBorderBehavior.always]: Always show bottom border on last row
  /// - [LastRowBorderBehavior.smart]: Show border only when no vertical scroll
  final LastRowBorderBehavior lastRowBorderBehavior;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
    bool? showVerticalDividers,
    bool? showHorizontalDividers,
    LastRowBorderBehavior? lastRowBorderBehavior,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showHorizontalDividers:
          showHorizontalDividers ?? this.showHorizontalDividers,
      lastRowBorderBehavior:
          lastRowBorderBehavior ?? this.lastRowBorderBehavior,
    );
  }
}
