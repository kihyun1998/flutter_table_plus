import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_table_plus/src/utils/tooltip_resolver.dart';
import 'package:flutter_table_plus/src/widgets/cells/editable_text_field.dart';
import 'package:flutter_table_plus/src/widgets/tooltip_wrapper.dart';

/// A single table cell widget.
class TablePlusCell<T> extends StatefulWidget {
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
    this.isDim = false,
  });

  final int rowIndex;
  final TablePlusColumn<T> column;
  final T rowData;
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
  final bool isDim;

  @override
  State<TablePlusCell<T>> createState() => _TablePlusCellState<T>();
}

class _TablePlusCellState<T> extends State<TablePlusCell<T>> {
  late FocusNode _focusNode;

  // Cached overflow detection result
  bool? _cachedOverflow;
  String _cachedOverflowText = '';
  double _cachedOverflowWidth = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(TablePlusCell<T> oldWidget) {
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
    final value = widget.column.valueAccessor(widget.rowData);
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
    // Use custom cell builder if provided (statefulCellBuilder takes precedence)
    final customCell = widget.column.buildCustomCell(
      context,
      widget.rowData,
      widget.isSelected,
      widget.isDim,
    );
    if (customCell != null) {
      return Align(
        alignment: widget.column.alignment,
        child: customCell,
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    Widget textWidget = Text(
      displayValue,
      style:
          widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
      overflow: widget.column.textOverflow,
      textAlign: widget.column.textAlign,
    );

    textWidget = wrapWithTooltip<T>(
      shouldShow: _shouldShowTooltip(displayValue, textWidget),
      child: textWidget,
      theme: widget.tooltipTheme,
      tooltipBuilder: widget.column.tooltipBuilder,
      tooltipFormatter: widget.column.tooltipFormatter,
      rowData: widget.rowData,
      fallbackMessage: displayValue,
    );

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
      border = widget.theme.verticalDividerBorder;
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
    if (!widget.tooltipTheme.enabled) return false;
    return TooltipResolver.shouldShow(
      behavior: widget.column.tooltipBehavior,
      isEllipsis: widget.column.textOverflow == TextOverflow.ellipsis,
      textIsEmpty: displayValue.isEmpty,
      willOverflow: () => _willTextOverflowCached(displayValue),
    );
  }

  /// Whether [displayValue] overflows the cell, memoized on (text, width) so a
  /// rebuild with unchanged inputs skips re-measuring.
  bool _willTextOverflowCached(String displayValue) {
    final availableWidth = widget.width - widget.theme.padding.horizontal;
    if (_cachedOverflow != null &&
        _cachedOverflowText == displayValue &&
        _cachedOverflowWidth == availableWidth) {
      return _cachedOverflow!;
    }
    final result = TextOverflowDetector.willTextOverflowInContext(
      context: context,
      text: displayValue,
      maxWidth: availableWidth,
      style:
          widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
    );
    _cachedOverflowText = displayValue;
    _cachedOverflowWidth = availableWidth;
    _cachedOverflow = result;
    return result;
  }
}
