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
      borderRadius: borderRadius ?? this.borderRadius,
      fillColor: fillColor ?? this.fillColor,
      filled: filled ?? this.filled,
      isDense: isDense ?? this.isDense,
    );
  }
}
