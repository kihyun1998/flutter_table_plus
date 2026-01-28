import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// A reusable editable text field component for table cells.
///
/// This component consolidates the common TextField implementation used across
/// different cell types (regular cells, merged cells, stacked cells) to reduce
/// code duplication and improve maintainability.
class EditableTextField extends StatelessWidget {
  const EditableTextField({
    super.key,
    required this.column,
    required this.theme,
    required this.onStopEditing,
    this.controller,
    this.focusNode,
    this.autofocus = true,
    this.alignment = Alignment.centerLeft,
    this.onKeyEvent,
  });

  /// The column configuration for this text field.
  final TablePlusColumn<dynamic> column;

  /// The theme configuration for editable cells.
  final TablePlusEditableTheme theme;

  /// Called when editing should stop.
  final void Function({required bool save})? onStopEditing;

  /// The text editing controller.
  final TextEditingController? controller;

  /// The focus node for this text field.
  final FocusNode? focusNode;

  /// Whether this text field should autofocus.
  final bool autofocus;

  /// The alignment for the text field content.
  final Alignment alignment;

  /// Called when key events occur.
  final bool Function(KeyEvent event)? onKeyEvent;

  /// Handle key presses in the text field.
  bool _handleKeyPress(KeyEvent event) {
    // Allow custom key handling first
    if (onKeyEvent?.call(event) == true) {
      return true;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Enter key - save and stop editing
        onStopEditing?.call(save: true);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        // Escape key - cancel and stop editing
        onStopEditing?.call(save: false);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: KeyboardListener(
        focusNode: FocusNode(), // Separate focus node for keyboard listener
        onKeyEvent: _handleKeyPress,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          style: theme.editingTextStyle,
          textAlign: column.textAlign,
          textAlignVertical: theme.textAlignVertical,
          cursorColor: theme.cursorColor,
          decoration: InputDecoration(
            hintText: column.hintText,
            hintStyle: theme.hintStyle,
            contentPadding: theme.textFieldPadding,
            isDense: theme.isDense,
            filled: theme.filled,
            fillColor: theme.fillColor ?? theme.editingCellColor,
            // Border configuration
            border: OutlineInputBorder(
              borderRadius: theme.borderRadius ?? theme.editingBorderRadius,
              borderSide: BorderSide(
                color: theme.enabledBorderColor ??
                    theme.editingBorderColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: theme.borderRadius ?? theme.editingBorderRadius,
              borderSide: BorderSide(
                color: theme.enabledBorderColor ??
                    theme.editingBorderColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: theme.borderRadius ?? theme.editingBorderRadius,
              borderSide: BorderSide(
                color: theme.focusedBorderColor ?? theme.editingBorderColor,
                width: theme.editingBorderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: theme.borderRadius ?? theme.editingBorderRadius,
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: theme.borderRadius ?? theme.editingBorderRadius,
              borderSide: BorderSide(
                color: Colors.red.shade600,
                width: theme.editingBorderWidth,
              ),
            ),
          ),
          onSubmitted: (_) => onStopEditing?.call(save: true),
        ),
      ),
    );
  }
}
