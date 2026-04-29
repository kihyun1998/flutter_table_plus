import 'package:flutter/material.dart';

/// Theme configuration for the drag-selection rubber band rectangle.
///
/// The rubber band is the translucent rectangle drawn from the pointer-down
/// position to the current pointer position while a drag selection is in
/// progress (Finder/Explorer-style marquee). It is purely a visual cue —
/// row selection logic is independent of this theme.
class TablePlusDragSelectionTheme {
  /// Creates a [TablePlusDragSelectionTheme] with the specified styling.
  const TablePlusDragSelectionTheme({
    this.show = true,
    this.fillColor = const Color(0x33448AFF),
    this.borderColor = const Color(0xFF448AFF),
    this.borderWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
  });

  /// Whether to render the rubber band rectangle during drag selection.
  ///
  /// When `false`, drag selection still works but no visual rectangle is
  /// drawn. Defaults to `true`.
  final bool show;

  /// The fill color of the rubber band rectangle.
  ///
  /// Default is `0x33448AFF` (~20% alpha blue accent), matching macOS
  /// Finder / Windows Explorer marquee conventions.
  final Color fillColor;

  /// The border color of the rubber band rectangle.
  final Color borderColor;

  /// The border width of the rubber band rectangle.
  final double borderWidth;

  /// The border radius of the rubber band rectangle.
  ///
  /// Defaults to [BorderRadius.zero] for a sharp-cornered marquee, matching
  /// OS conventions. Override for a softer look.
  final BorderRadius borderRadius;

  /// Returns a new [TablePlusDragSelectionTheme] with dimensional values
  /// scaled by [factor].
  ///
  /// Scales: [borderWidth].
  /// Does NOT scale: colors, [borderRadius] (typically already small),
  /// the [show] flag.
  TablePlusDragSelectionTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return copyWith(borderWidth: borderWidth * factor);
  }

  /// Creates a copy of this theme with the given fields replaced.
  TablePlusDragSelectionTheme copyWith({
    bool? show,
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
  }) {
    return TablePlusDragSelectionTheme(
      show: show ?? this.show,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
