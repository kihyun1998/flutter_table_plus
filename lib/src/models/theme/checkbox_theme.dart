import 'package:flutter/widgets.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';

/// Theme configuration for table checkboxes.
///
/// This class provides styling options for checkboxes used in table selection
/// functionality, powered by the [FlutterCheckbox] package for crisp
/// CustomPainter rendering, smooth animations, and hover ring support.
class TablePlusCheckboxTheme {
  /// Creates a [TablePlusCheckboxTheme] with the specified styling properties.
  ///
  /// The [style] parameter controls all visual aspects of the checkbox
  /// (colors, shape, size, animations) via [CheckboxStyle].
  const TablePlusCheckboxTheme({
    this.style = const CheckboxStyle(size: 18),
    this.mouseCursor,
    this.showCheckboxColumn = true,
    this.showSelectAllCheckbox = true,
    this.checkboxColumnWidth = 60.0,
    this.cellTapTogglesCheckbox = false,
    this.showRowCheckbox = true,
  });

  /// The visual styling configuration for checkboxes.
  ///
  /// Controls colors, shape, size, border, hover ring, and animations.
  /// See [CheckboxStyle] for all available options.
  ///
  /// Example:
  /// ```dart
  /// style: CheckboxStyle(
  ///   size: 20,
  ///   activeColor: Colors.blue,
  ///   checkColor: Colors.white,
  ///   borderColor: Colors.grey,
  ///   shape: CheckboxShape.circle,
  ///   hoverRingPadding: 4,
  /// )
  /// ```
  final CheckboxStyle style;

  /// The cursor to display when hovering over the checkbox.
  /// If null, uses the default system cursor.
  final MouseCursor? mouseCursor;

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

  /// Whether to show checkboxes in individual row cells.
  ///
  /// When false, the checkbox column still appears (with the header select-all
  /// checkbox if [showSelectAllCheckbox] is true), but individual rows will not
  /// display checkboxes. Row selection is done via row tap only.
  ///
  /// Defaults to true.
  final bool showRowCheckbox;

  /// Returns a new [TablePlusCheckboxTheme] with dimensional values scaled by [factor].
  ///
  /// Uses [CheckboxStyle.scale] to uniformly scale the checkbox rendering.
  /// Also scales [checkboxColumnWidth] for consistent table layout.
  TablePlusCheckboxTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return copyWith(
      style: CheckboxStyle(
        shape: style.shape,
        size: style.size,
        scale: style.scale * factor,
        activeColor: style.activeColor,
        checkColor: style.checkColor,
        borderColor: style.borderColor,
        inactiveColor: style.inactiveColor,
        borderWidth: style.borderWidth,
        borderRadius: style.borderRadius,
        checkStrokeWidth: style.checkStrokeWidth,
        hoverRingPadding: style.hoverRingPadding,
        hoverRingShape: style.hoverRingShape,
        hoverRingBorderRadius: style.hoverRingBorderRadius,
        animationDuration: style.animationDuration,
        animationCurve: style.animationCurve,
        morphDuration: style.morphDuration,
        morphCurve: style.morphCurve,
      ),
      checkboxColumnWidth: checkboxColumnWidth * factor,
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  TablePlusCheckboxTheme copyWith({
    CheckboxStyle? style,
    MouseCursor? mouseCursor,
    bool? showCheckboxColumn,
    bool? showSelectAllCheckbox,
    double? checkboxColumnWidth,
    bool? cellTapTogglesCheckbox,
    bool? showRowCheckbox,
  }) {
    return TablePlusCheckboxTheme(
      style: style ?? this.style,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      showSelectAllCheckbox:
          showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
      cellTapTogglesCheckbox:
          cellTapTogglesCheckbox ?? this.cellTapTogglesCheckbox,
      showRowCheckbox: showRowCheckbox ?? this.showRowCheckbox,
    );
  }

  /// Builds a [FlutterCheckbox] widget with all theme properties applied.
  ///
  /// This eliminates the need to manually pass every theme property at each
  /// call site. Use [tristate] for the select-all header checkbox.
  Widget buildCheckbox({
    required bool? value,
    required ValueChanged<bool?>? onChanged,
    bool tristate = false,
  }) {
    return FlutterCheckbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
      style: style,
      enabled: onChanged != null,
      mouseCursor: mouseCursor,
    );
  }

  /// Creates a checkbox theme with the specified primary color.
  ///
  /// This factory constructor provides a convenient way to create a
  /// consistently styled checkbox theme with minimal configuration.
  factory TablePlusCheckboxTheme.colored({
    Color? activeColor,
    Color? checkColor,
    Color? borderColor,
    double size = 18,
    bool showCheckboxColumn = true,
    bool showSelectAllCheckbox = true,
    double checkboxColumnWidth = 60.0,
    bool cellTapTogglesCheckbox = false,
    bool showRowCheckbox = true,
  }) {
    return TablePlusCheckboxTheme(
      style: CheckboxStyle(
        size: size,
        activeColor: activeColor,
        checkColor: checkColor,
        borderColor: borderColor,
      ),
      showCheckboxColumn: showCheckboxColumn,
      showSelectAllCheckbox: showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth,
      cellTapTogglesCheckbox: cellTapTogglesCheckbox,
      showRowCheckbox: showRowCheckbox,
    );
  }
}
