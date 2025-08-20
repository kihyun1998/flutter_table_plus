import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row_widget.dart';

/// A single table row widget.
class TablePlusRow extends TablePlusRowWidget {
  const TablePlusRow({
    super.key,
    required this.rowIndex,
    required this.rowData,
    required this.rowId,
    required this.columns,
    required this.columnWidths,
    required this.theme,
    required this.backgroundColor,
    required this.isLastRow,
    required this.isSelectable,
    required this.selectionMode,
    required this.isSelected,
    required this.selectionTheme,
    required this.onRowSelectionChanged,
    required this.isEditable,
    required this.editableTheme,
    required this.tooltipTheme,
    required this.isCellEditing,
    required this.getCellController,
    required this.onCellTap,
    required this.onStopEditing,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.calculatedHeight,
    this.needsVerticalScroll = false,
    this.hoverButtonBuilder,
  });

  final int rowIndex;
  final Map<String, dynamic> rowData;
  final String? rowId;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  @override
  final Color backgroundColor;
  @override
  final bool isLastRow;
  final bool isSelectable;
  final SelectionMode selectionMode;
  final bool isSelected;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onRowSelectionChanged;
  final bool isEditable;
  final TablePlusEditableTheme editableTheme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool Function(int rowIndex, String columnKey)? isCellEditing;
  final TextEditingController? Function(int rowIndex, String columnKey)?
      getCellController;
  final void Function(int rowIndex, String columnKey)? onCellTap;
  final void Function({required bool save})? onStopEditing;
  final void Function(String rowId)? onRowDoubleTap;
  final void Function(String rowId)? onRowSecondaryTap;
  @override
  final double? calculatedHeight;
  final bool needsVerticalScroll;

  /// Builder function to create custom hover buttons for this row.
  final Widget Function(String rowId, Map<String, dynamic> rowData)?
      hoverButtonBuilder;

  // Implementation of TablePlusRowWidget abstract methods
  @override
  int get effectiveRowCount => 1;

  @override
  List<int> get originalDataIndices => [rowIndex];

  @override
  State<TablePlusRow> createState() => _TablePlusRowState();
}

class _TablePlusRowState extends State<TablePlusRow> {
  bool _isHovered = false;

  /// Determines whether to show a bottom border for this row.
  ///
  /// Takes into account the row position (last vs non-last) and the theme's
  /// [LastRowBorderBehavior] setting to decide if a border should be shown.
  bool _shouldShowBottomBorder(bool isLastRow, TablePlusBodyTheme theme) {
    // Don't show any borders if horizontal dividers are disabled
    if (!theme.showHorizontalDividers) return false;

    // Always show border for non-last rows
    if (!isLastRow) return true;

    // For last row, check the border behavior setting
    switch (theme.lastRowBorderBehavior) {
      case LastRowBorderBehavior.never:
        return false;
      case LastRowBorderBehavior.always:
        return true;
      case LastRowBorderBehavior.smart:
        // Show border only when there's no vertical scroll
        return !widget.needsVerticalScroll;
    }
  }

  /// Handle row tap for selection.
  /// Only works when not in editable mode.
  void _handleRowTap() {
    if (widget.isEditable) return; // No row selection in editable mode
    if (!widget.isSelectable || widget.rowId == null) return;

    if (widget.selectionMode == SelectionMode.single) {
      // For single selection mode, toggle the selection
      // If already selected, deselect it; if not selected, select it
      widget.onRowSelectionChanged(widget.rowId!);
    } else {
      // For multiple selection mode, toggle the selection
      widget.onRowSelectionChanged(widget.rowId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget rowContent = Container(
      height: widget.calculatedHeight ?? widget.theme.rowHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: _shouldShowBottomBorder(widget.isLastRow, widget.theme)
            ? Border(
                bottom: BorderSide(
                  color: widget.theme.dividerColor,
                  width: widget.theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(widget.columns.length, (index) {
          final column = widget.columns[index];
          final width = widget.columnWidths.isNotEmpty
              ? widget.columnWidths[index]
              : column.width;

          // Special handling for selection column
          if (widget.isSelectable && column.key == '__selection__') {
            return _SelectionCell(
              width: width,
              rowId: widget.rowId,
              isSelected: widget.isSelected,
              theme: widget.theme,
              selectionTheme: widget.selectionTheme,
              onSelectionChanged: widget.onRowSelectionChanged,
              calculatedHeight: widget.calculatedHeight,
            );
          }

          return _TablePlusCell(
            rowIndex: widget.rowIndex,
            column: column,
            rowData: widget.rowData,
            width: width,
            theme: widget.theme,
            isEditable: widget.isEditable,
            editableTheme: widget.editableTheme,
            tooltipTheme: widget.tooltipTheme,
            isCellEditing:
                widget.isCellEditing?.call(widget.rowIndex, column.key) ??
                    false,
            isSelected: widget.isSelected,
            selectionTheme: widget.selectionTheme,
            cellController:
                widget.getCellController?.call(widget.rowIndex, column.key),
            onCellTap: widget.onCellTap != null
                ? () => widget.onCellTap!(widget.rowIndex, column.key)
                : null,
            onStopEditing: widget.onStopEditing,
            calculatedHeight: widget.calculatedHeight,
          );
        }),
      ),
    );

    // Create hover buttons using builder
    Widget? hoverButtons;
    if (_isHovered &&
        widget.rowId != null &&
        widget.hoverButtonBuilder != null) {
      final buttonWidget =
          widget.hoverButtonBuilder!(widget.rowId!, widget.rowData);
      hoverButtons = Positioned(
        right: 8,
        top: 0,
        bottom: 0,
        child: Center(
          child: buttonWidget,
        ),
      );
    }

    // Wrap with Stack for hover buttons
    Widget stackedContent = Stack(
      children: [
        rowContent,
        if (hoverButtons != null) hoverButtons,
      ],
    );

    // Wrap with MouseRegion for hover detection
    Widget hoveredContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: stackedContent,
    );

    // Wrap with CustomInkWell for row selection if selectable and not editable
    if (widget.isSelectable && !widget.isEditable && widget.rowId != null) {
      return CustomInkWell(
        key: ValueKey(widget.rowId),
        onTap: _handleRowTap,
        onDoubleTap: () {
          widget.onRowDoubleTap?.call(widget.rowId!);
        },
        onSecondaryTap: () {
          widget.onRowSecondaryTap?.call(widget.rowId!);
        },
        backgroundColor: widget.backgroundColor,
        hoverColor: widget.selectionTheme
            .getEffectiveHoverColor(widget.isSelected, widget.backgroundColor),
        splashColor: widget.selectionTheme
            .getEffectiveSplashColor(widget.isSelected, widget.backgroundColor),
        highlightColor: widget.selectionTheme.getEffectiveHighlightColor(
            widget.isSelected, widget.backgroundColor),
        child: hoveredContent,
      );
    }

    return hoveredContent;
  }
}

/// A selection cell with checkbox.
class _SelectionCell extends StatelessWidget {
  const _SelectionCell({
    required this.width,
    required this.rowId,
    required this.isSelected,
    required this.theme,
    required this.selectionTheme,
    required this.onSelectionChanged,
    this.calculatedHeight,
  });

  final double width;
  final String? rowId;
  final bool isSelected;
  final TablePlusBodyTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onSelectionChanged;
  final double? calculatedHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: calculatedHeight ?? theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: selectionTheme.checkboxSize,
          height: selectionTheme.checkboxSize,
          child: Checkbox(
            value: isSelected,
            onChanged:
                rowId != null ? (value) => onSelectionChanged(rowId!) : null,
            activeColor: selectionTheme.checkboxColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}

/// A single table cell widget.
class _TablePlusCell extends StatefulWidget {
  const _TablePlusCell({
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
    required this.selectionTheme,
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
  final TablePlusSelectionTheme selectionTheme;
  final TextEditingController? cellController;
  final VoidCallback? onCellTap;
  final void Function({required bool save})? onStopEditing;
  final double? calculatedHeight;

  @override
  State<_TablePlusCell> createState() => _TablePlusCellState();
}

class _TablePlusCellState extends State<_TablePlusCell> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_TablePlusCell oldWidget) {
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
    final theme = widget.editableTheme;

    return Align(
      alignment: widget.column.alignment, // 컬럼 정렬 설정에 맞춰 TextField 정렬
      child: KeyboardListener(
        focusNode: FocusNode(), // Separate focus node for keyboard listener
        onKeyEvent: _handleKeyPress,
        child: TextField(
          controller: widget.cellController,
          focusNode: _focusNode,
          style: theme.editingTextStyle,
          textAlign: widget.column.textAlign,
          textAlignVertical: theme.textAlignVertical,
          cursorColor: theme.cursorColor,
          decoration: InputDecoration(
            hintText: widget.column.hintText,
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
          onSubmitted: (_) => widget.onStopEditing?.call(save: true),
        ),
      ),
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
      style: widget.selectionTheme.getEffectiveTextStyle(
        widget.isSelected,
        widget.theme.textStyle,
      ),
      overflow: widget.column.textOverflow,
      textAlign: widget.column.textAlign,
    );

    // Add tooltip based on tooltip behavior
    if (_shouldShowTooltip(displayValue, textWidget)) {
      textWidget = Tooltip(
        message: displayValue,
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

      case TooltipBehavior.onOverflowOnly:
        // Only show tooltip if text overflow is ellipsis AND text actually overflows
        if (widget.column.textOverflow != TextOverflow.ellipsis) {
          return false;
        }

        // Use LayoutBuilder to get available width and check for overflow
        return _willTextOverflowInAvailableWidth(displayValue);
    }
  }

  /// Checks if text will overflow in the available width using LayoutBuilder context.
  /// This method is called within the build context where LayoutBuilder provides constraints.
  bool _willTextOverflowInAvailableWidth(String displayValue) {
    // We need to get the available width from the current context
    // Since we're in a table cell, we need to account for padding and margins

    // Get the render box to determine available width
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      // If we can't determine the size, fall back to always showing tooltip
      return true;
    }

    final availableWidth = renderObject.size.width;

    // Account for padding that might be applied to the cell content
    const double padding = 16.0; // Default padding used in table cells
    final maxTextWidth = availableWidth - padding;

    if (maxTextWidth <= 0) {
      return true; // If no space available, consider it overflow
    }

    // Get the text style applied to the text
    final textStyle = widget.selectionTheme.getEffectiveTextStyle(
      widget.isSelected,
      widget.theme.textStyle,
    );

    return TextOverflowDetector.willTextOverflow(
      text: displayValue,
      style: textStyle,
      maxWidth: maxTextWidth,
      textAlign: widget.column.textAlign,
    );
  }
}
