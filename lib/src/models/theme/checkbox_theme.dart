import 'package:flutter/material.dart';

/// Theme configuration for table checkboxes.
///
/// This class provides comprehensive styling options for checkboxes used in
/// table selection functionality, supporting both the latest Flutter Material 3
/// design system with WidgetStateProperty and legacy single-color properties.
class TablePlusCheckboxTheme {
  /// Creates a [TablePlusCheckboxTheme] with the specified styling properties.
  const TablePlusCheckboxTheme({
    // WidgetStateProperty-based styling (recommended)
    this.fillColor,
    this.overlayColor,

    // Traditional single-color properties
    this.checkColor,
    this.focusColor,
    this.hoverColor,

    // Shape and behavior
    this.side,
    this.shape,
    this.mouseCursor,
    this.materialTapTargetSize,
    this.visualDensity,
    this.splashRadius,

    // Table-specific properties
    this.size = 18.0,
    this.tapTargetSize,
    this.showCheckboxColumn = true,
    this.showSelectAllCheckbox = true,
    this.checkboxColumnWidth = 60.0,
    this.cellTapTogglesCheckbox = false,
  });

  // WidgetStateProperty-based styling properties

  /// The fill color of the checkbox using WidgetStateProperty.
  ///
  /// This provides state-aware styling for the checkbox background/fill color
  /// in different interaction states (pressed, hovered, focused, selected, etc.).
  ///
  /// Example:
  /// ```dart
  /// fillColor: WidgetStateProperty.resolveWith((states) {
  ///   if (states.contains(WidgetState.selected)) {
  ///     return Colors.blue;
  ///   }
  ///   if (states.contains(WidgetState.hovered)) {
  ///     return Colors.blue.withValues(alpha: 0.8);
  ///   }
  ///   return Colors.grey;
  /// })
  /// ```
  final WidgetStateProperty<Color?>? fillColor;

  /// The overlay color of the checkbox using WidgetStateProperty.
  ///
  /// This controls the color of the checkbox overlay (ripple effect) in different
  /// interaction states (hovered, pressed, focused).
  final WidgetStateProperty<Color?>? overlayColor;

  // Traditional single-color properties

  /// The color of the check mark/icon inside the checkbox.
  /// If null, uses the default Material check color.
  final Color? checkColor;

  /// The color of the checkbox when it receives keyboard focus.
  /// If null, uses the default Material focus color.
  final Color? focusColor;

  /// The color of the checkbox when it's hovered over with a mouse.
  /// If null, uses the default Material hover color.
  final Color? hoverColor;

  // Shape and behavior properties

  /// The border side of the checkbox.
  ///
  /// Use this to control border color and width.
  /// If null, uses the default Material border styling.
  final BorderSide? side;

  /// The shape of the checkbox.
  ///
  /// If null, uses the default Material checkbox shape (rounded rectangle).
  final OutlinedBorder? shape;

  /// The cursor to display when hovering over the checkbox.
  /// If null, uses the default system cursor.
  final MouseCursor? mouseCursor;

  /// Configures the minimum size of the checkbox touch target.
  ///
  /// If null, defaults to the Material Design guidelines.
  /// Use [MaterialTapTargetSize.shrinkWrap] for more compact layouts.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Defines how compact the checkbox's layout will be.
  ///
  /// Use [VisualDensity.compact] for tighter spacing in dense layouts.
  final VisualDensity? visualDensity;

  /// The splash radius of the checkbox ripple effect.
  ///
  /// If null, uses the default Material splash radius.
  final double? splashRadius;

  // Table-specific properties

  /// The size (width and height) of the checkbox in logical pixels.
  final double size;

  /// The size (width and height) of the checkbox tap/hover target area.
  ///
  /// When set, the checkbox hit-test area expands to this size while the
  /// visual checkbox remains at [size]. This makes the checkbox easier to
  /// click without changing its visual appearance.
  ///
  /// If null, defaults to [size] (tap target matches visual size).
  final double? tapTargetSize;

  /// Whether to show the checkbox column in the table.
  ///
  /// If false, rows can only be selected by tapping on the row itself.
  final bool showCheckboxColumn;

  /// Whether to show the select-all checkbox in the table header.
  ///
  /// If false, only individual row selection is available.
  /// Automatically disabled for single selection mode.
  final bool showSelectAllCheckbox;

  /// The width of the checkbox column in logical pixels.
  ///
  /// This determines how much horizontal space is allocated for the
  /// selection checkbox column.
  final double checkboxColumnWidth;

  /// Whether tapping anywhere in the selection column cell toggles the checkbox.
  ///
  /// When true, the entire selection column cell becomes tappable and triggers
  /// the checkbox callback (multi-select). This prevents accidental single-select
  /// when the user taps near the checkbox but misses it slightly.
  ///
  /// When false (default), only the checkbox itself handles taps. Tapping the
  /// cell area outside the checkbox falls through to the row tap handler.
  final bool cellTapTogglesCheckbox;

  /// Creates a copy of this theme with the given fields replaced by new values.
  TablePlusCheckboxTheme copyWith({
    WidgetStateProperty<Color?>? fillColor,
    WidgetStateProperty<Color?>? overlayColor,
    Color? checkColor,
    Color? focusColor,
    Color? hoverColor,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? mouseCursor,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    double? splashRadius,
    double? size,
    double? tapTargetSize,
    bool? showCheckboxColumn,
    bool? showSelectAllCheckbox,
    double? checkboxColumnWidth,
    bool? cellTapTogglesCheckbox,
  }) {
    return TablePlusCheckboxTheme(
      fillColor: fillColor ?? this.fillColor,
      overlayColor: overlayColor ?? this.overlayColor,
      checkColor: checkColor ?? this.checkColor,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      side: side ?? this.side,
      shape: shape ?? this.shape,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      materialTapTargetSize:
          materialTapTargetSize ?? this.materialTapTargetSize,
      visualDensity: visualDensity ?? this.visualDensity,
      splashRadius: splashRadius ?? this.splashRadius,
      size: size ?? this.size,
      tapTargetSize: tapTargetSize ?? this.tapTargetSize,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      showSelectAllCheckbox:
          showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
      cellTapTogglesCheckbox:
          cellTapTogglesCheckbox ?? this.cellTapTogglesCheckbox,
    );
  }

  /// Creates a Material 3 compliant checkbox theme with state-aware colors.
  ///
  /// This factory constructor provides a modern checkbox theme that follows
  /// Material 3 design guidelines with proper state handling.
  factory TablePlusCheckboxTheme.material3({
    Color primaryColor = Colors.blue,
    double size = 18.0,
    double? tapTargetSize,
    bool showCheckboxColumn = true,
    bool showSelectAllCheckbox = true,
    double checkboxColumnWidth = 60.0,
    bool cellTapTogglesCheckbox = false,
  }) {
    return TablePlusCheckboxTheme(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return primaryColor.withValues(alpha: 0.38);
          }
          return primaryColor;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return primaryColor.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return primaryColor.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
      checkColor: Colors.white,
      size: size,
      tapTargetSize: tapTargetSize,
      showCheckboxColumn: showCheckboxColumn,
      showSelectAllCheckbox: showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      cellTapTogglesCheckbox: cellTapTogglesCheckbox,
    );
  }
}
