import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_table_plus/src/widgets/cells/editable_text_field.dart';

/// A single table cell widget.
class TablePlusCell extends StatefulWidget {
  const TablePlusCell({
    super.key,
    required this.rowIndex,
    required this.column,
    required this.rowData,
    required this.width,
    required this.theme,
    required this.isEditable,
    required this.editableTheme,
    required this.tooltipTheme,
    required this.isCellEditing,
    required this.isSelected,
    this.cellController,
    this.onCellTap,
    this.onStopEditing,
    this.calculatedHeight,
  });

  final int rowIndex;
  final TablePlusColumn column;
  final Map<String, dynamic> rowData;
  final double width;
  final TablePlusBodyTheme theme;
  final bool isEditable;
  final TablePlusEditableTheme editableTheme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool isCellEditing;
  final bool isSelected;
  final TextEditingController? cellController;
  final VoidCallback? onCellTap;
  final void Function({required bool save})? onStopEditing;
  final double? calculatedHeight;

  @override
  State<TablePlusCell> createState() => _TablePlusCellState();
}

class _TablePlusCellState extends State<TablePlusCell> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(TablePlusCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Focus the text field when editing starts
    if (!oldWidget.isCellEditing && widget.isCellEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle focus changes - stop editing when focus is lost
  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.isCellEditing) {
      widget.onStopEditing?.call(save: true);
    }
  }

  /// Handle key presses in the text field
  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Enter key - save and stop editing
        widget.onStopEditing?.call(save: true);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        // Escape key - cancel and stop editing
        widget.onStopEditing?.call(save: false);
        return true;
      }
    }
    return false;
  }

  /// Extract the display value for this cell.
  String _getCellDisplayValue() {
    final value = widget.rowData[widget.column.key];
    if (value == null) return '';
    return value.toString();
  }

  /// Build the editing text field
  Widget _buildEditingTextField() {
    return EditableTextField(
      column: widget.column,
      theme: widget.editableTheme,
      controller: widget.cellController,
      focusNode: _focusNode,
      autofocus: false, // We handle focus manually in didUpdateWidget
      alignment: widget.column.alignment,
      onStopEditing: widget.onStopEditing,
      onKeyEvent: _handleKeyPress,
    );
  }

  /// Build the regular cell content
  Widget _buildRegularCell() {
    // Use custom cell builder if provided
    if (widget.column.cellBuilder != null) {
      return Align(
        alignment: widget.column.alignment,
        child: widget.column.cellBuilder!(context, widget.rowData),
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    Widget textWidget = Text(
      displayValue,
      style: widget.theme.getEffectiveTextStyle(widget.isSelected),
      overflow: widget.column.textOverflow,
      textAlign: widget.column.textAlign,
    );

    // Add tooltip based on tooltip behavior and priority
    if (_shouldShowTooltip(displayValue, textWidget)) {
      // Priority: tooltipBuilder > tooltipFormatter > default
      if (widget.column.tooltipBuilder != null) {
        // Use custom widget tooltip
        textWidget = CustomTooltipWrapper(
          content: widget.column.tooltipBuilder!(context, widget.rowData),
          theme: widget.tooltipTheme,
          child: textWidget,
        );
      } else {
        // Use text-based tooltip (existing behavior)
        final tooltipMessage = widget.column.tooltipFormatter != null
            ? widget.column.tooltipFormatter!(widget.rowData)
            : displayValue;

        textWidget = Tooltip(
          message: tooltipMessage,
          textStyle: widget.tooltipTheme.textStyle,
          decoration: widget.tooltipTheme.decoration,
          padding: widget.tooltipTheme.padding,
          margin: widget.tooltipTheme.margin,
          waitDuration: widget.tooltipTheme.waitDuration,
          showDuration: widget.tooltipTheme.showDuration,
          preferBelow: widget.tooltipTheme.preferBelow,
          child: textWidget,
        );
      }
    }

    return Align(
      alignment: widget.column.alignment,
      child: textWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this cell can be edited
    final canEdit = widget.isEditable && widget.column.editable;

    // For editing cells, we don't need special background/border as TextField handles it
    Color backgroundColor = Colors.transparent;
    BoxBorder? border;

    // Only apply cell-level styling when not editing
    if (!widget.isCellEditing) {
      // Apply normal vertical divider if needed
      if (widget.theme.showVerticalDividers) {
        border = Border(
          right: BorderSide(
            color: widget.theme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        );
      }
    }

    Widget cellContent = Container(
      width: widget.width,
      height: widget.calculatedHeight ?? widget.theme.rowHeight,
      padding: widget.isCellEditing
          ? widget.editableTheme
              .cellContainerPadding // Use editable theme's container padding
          : widget.theme.padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
      ),
      child:
          widget.isCellEditing ? _buildEditingTextField() : _buildRegularCell(),
    );

    // Wrap with GestureDetector for cell editing if applicable
    if (canEdit && !widget.isCellEditing && widget.onCellTap != null) {
      return GestureDetector(
        onTap: widget.onCellTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: cellContent,
        ),
      );
    }

    return cellContent;
  }

  /// Determines whether a tooltip should be shown based on the column's tooltip behavior.
  bool _shouldShowTooltip(String displayValue, Widget textWidget) {
    // Basic checks - tooltip must be enabled and text must not be empty
    if (!widget.tooltipTheme.enabled || displayValue.isEmpty) {
      return false;
    }

    switch (widget.column.tooltipBehavior) {
      case TooltipBehavior.never:
        return false;

      case TooltipBehavior.always:
        return widget.column.textOverflow == TextOverflow.ellipsis;

      case TooltipBehavior.onlyTextOverflow:
        // Only show tooltip if text actually overflows
        if (widget.column.textOverflow != TextOverflow.ellipsis) {
          return false;
        }

        // Calculate available width for the cell content
        final padding = widget.theme.padding;
        final availableWidth = widget.width - padding.horizontal;

        // Use TextOverflowDetector to check if text would overflow
        return TextOverflowDetector.willTextOverflowInContext(
          context: context,
          text: displayValue,
          maxWidth: availableWidth,
          style: widget.theme.getEffectiveTextStyle(widget.isSelected),
        );
    }
  }
}
