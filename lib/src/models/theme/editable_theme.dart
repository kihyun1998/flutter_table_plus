import 'package:flutter/material.dart';

/// Theme configuration for cell editing.
class TablePlusEditableTheme {
  /// Creates a [TablePlusEditableTheme] with the specified styling properties.
  const TablePlusEditableTheme({
    this.editingCellColor = const Color(0xFFFFF9C4),
    this.editingTextStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    this.hintStyle,
    this.editingBorderColor = const Color(0xFF2196F3),
    this.editingBorderWidth = 2.0,
    this.editingBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.textFieldPadding =
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.cellContainerPadding = const EdgeInsets.all(8.0),
    this.cursorColor = const Color(0xFF2196F3),
    this.textAlignVertical = TextAlignVertical.center,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.enabledBorderWidth,
    this.errorBorderColor,
    this.focusedErrorBorderColor,
    this.errorBorderWidth,
    this.borderRadius,
    this.fillColor,
    this.filled = false,
    this.isDense = true,
  });

  /// The background color for cells that are currently being edited.
  final Color editingCellColor;

  /// The text style for text inside editing text fields.
  final TextStyle editingTextStyle;

  /// The text style for hint text in editing text fields.
  final TextStyle? hintStyle;

  /// The border color for cells that are currently being edited.
  final Color editingBorderColor;

  /// The border width for cells that are currently being edited.
  final double editingBorderWidth;

  /// The border radius for cells that are currently being edited.
  final BorderRadius editingBorderRadius;

  /// The padding inside the text field when editing.
  final EdgeInsets textFieldPadding;

  /// The padding for the container that wraps the text field during editing.
  /// This controls the space around the text field within the cell.
  final EdgeInsets cellContainerPadding;

  /// The cursor color in the text field.
  final Color cursorColor;

  /// The vertical alignment of text in the text field.
  final TextAlignVertical textAlignVertical;

  /// The border color when the text field is focused.
  /// If null, uses [editingBorderColor].
  final Color? focusedBorderColor;

  /// The border color when the text field is enabled but not focused.
  /// If null, uses a lighter version of [editingBorderColor].
  final Color? enabledBorderColor;

  /// The border width when the text field is enabled but not focused.
  ///
  /// If null, `1.0`. This is the half of the resting border that was not a
  /// field: its *colour* has been settable since the class was written, so
  /// raising [editingBorderWidth] thickened the focused border and left the
  /// resting one at a hairline with nothing to set (#171).
  final double? enabledBorderWidth;

  /// The border color when the cell's validator has rejected the value.
  ///
  /// If null, `Colors.red.shade400`. Before this field the package had no
  /// notion of an error colour at all — the word did not appear anywhere in
  /// `lib/src/models/theme/` — so an app whose palette has no red still got
  /// Material red on a validation failure, and [TablePlusTheme.scaledBy] could
  /// not reach it either (#171).
  final Color? errorBorderColor;

  /// The border color when a rejected cell also has focus.
  ///
  /// If null, `Colors.red.shade600` — a step darker than [errorBorderColor],
  /// the same relationship [focusedBorderColor] has to [enabledBorderColor].
  final Color? focusedErrorBorderColor;

  /// The border width when the cell's validator has rejected the value.
  ///
  /// If null, `1.0`. The *focused* error border reads [editingBorderWidth] and
  /// always has; this is the unfocused one.
  final double? errorBorderWidth;

  /// The border radius for the text field decoration.
  /// If null, uses [editingBorderRadius].
  final BorderRadius? borderRadius;

  /// The fill color for the text field.
  /// If null, uses [editingCellColor].
  final Color? fillColor;

  /// Whether the text field should be filled with [fillColor].
  final bool filled;

  /// Whether the text field should use dense layout.
  final bool isDense;

  /// The resolved border color for a cell whose validator has rejected the
  /// value.
  ///
  /// Resolution lives here rather than in `editable_text_field.dart` because
  /// the fallback is the thing being made reachable: written into the widget it
  /// was a `Colors.red.shade400` no caller could name.
  Color get effectiveErrorBorderColor =>
      errorBorderColor ?? const Color(0xFFEF5350); // Colors.red.shade400

  /// The resolved border color for a rejected cell that also has focus.
  Color get effectiveFocusedErrorBorderColor =>
      focusedErrorBorderColor ?? const Color(0xFFE53935); // Colors.red.shade600

  /// The resolved border width for an enabled, unfocused text field.
  double get effectiveEnabledBorderWidth => enabledBorderWidth ?? 1.0;

  /// The resolved border width for a rejected, unfocused text field.
  double get effectiveErrorBorderWidth => errorBorderWidth ?? 1.0;

  /// Returns a new [TablePlusEditableTheme] with dimensional values scaled by [factor].
  ///
  /// Scales: textStyle fontSize, hintStyle fontSize, padding, every border
  /// width.
  /// Does NOT scale: colors, border radius, booleans.
  TablePlusEditableTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return copyWith(
      editingTextStyle: editingTextStyle.copyWith(
        fontSize: (editingTextStyle.fontSize ?? 14) * factor,
      ),
      hintStyle: hintStyle?.copyWith(
        fontSize: (hintStyle!.fontSize ?? 14) * factor,
      ),
      editingBorderWidth: editingBorderWidth * factor,
      // Resolved before scaling, for the same reason the body theme resolves
      // its caption style: an unset width is `1.0`, not "nothing to scale", and
      // leaving it null kept the resting border at a hairline while
      // [editingBorderWidth] beside it doubled.
      enabledBorderWidth: effectiveEnabledBorderWidth * factor,
      errorBorderWidth: effectiveErrorBorderWidth * factor,
      textFieldPadding: textFieldPadding * factor,
      cellContainerPadding: cellContainerPadding * factor,
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusEditableTheme copyWith({
    Color? editingCellColor,
    TextStyle? editingTextStyle,
    TextStyle? hintStyle,
    Color? editingBorderColor,
    double? editingBorderWidth,
    BorderRadius? editingBorderRadius,
    EdgeInsets? textFieldPadding,
    EdgeInsets? cellContainerPadding,
    Color? cursorColor,
    TextAlignVertical? textAlignVertical,
    Color? focusedBorderColor,
    Color? enabledBorderColor,
    double? enabledBorderWidth,
    Color? errorBorderColor,
    Color? focusedErrorBorderColor,
    double? errorBorderWidth,
    BorderRadius? borderRadius,
    Color? fillColor,
    bool? filled,
    bool? isDense,
  }) {
    return TablePlusEditableTheme(
      editingCellColor: editingCellColor ?? this.editingCellColor,
      editingTextStyle: editingTextStyle ?? this.editingTextStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      editingBorderColor: editingBorderColor ?? this.editingBorderColor,
      editingBorderWidth: editingBorderWidth ?? this.editingBorderWidth,
      editingBorderRadius: editingBorderRadius ?? this.editingBorderRadius,
      textFieldPadding: textFieldPadding ?? this.textFieldPadding,
      cellContainerPadding: cellContainerPadding ?? this.cellContainerPadding,
      cursorColor: cursorColor ?? this.cursorColor,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
      enabledBorderWidth: enabledBorderWidth ?? this.enabledBorderWidth,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      focusedErrorBorderColor:
          focusedErrorBorderColor ?? this.focusedErrorBorderColor,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      fillColor: fillColor ?? this.fillColor,
      filled: filled ?? this.filled,
      isDense: isDense ?? this.isDense,
    );
  }
}
