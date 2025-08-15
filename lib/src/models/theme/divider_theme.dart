import 'package:flutter/material.dart';

/// Theme configuration for the frozen column divider.
class TablePlusDividerTheme {
  /// Creates a [TablePlusDividerTheme] with the specified styling properties.
  const TablePlusDividerTheme({
    this.color,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  /// The color of the divider.
  /// If null, uses [Colors.grey.shade300] as default.
  final Color? color;

  /// The thickness of the divider.
  final double thickness;

  /// The amount of empty space to the leading edge of the divider.
  final double indent;

  /// The amount of empty space to the trailing edge of the divider.
  final double endIndent;

  /// Gets the effective color for the divider.
  Color getEffectiveColor() {
    return color ?? Colors.grey.shade300;
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusDividerTheme copyWith({
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent,
  }) {
    return TablePlusDividerTheme(
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TablePlusDividerTheme &&
        other.color == color &&
        other.thickness == thickness &&
        other.indent == indent &&
        other.endIndent == endIndent;
  }

  @override
  int get hashCode {
    return Object.hash(color, thickness, indent, endIndent);
  }
}
