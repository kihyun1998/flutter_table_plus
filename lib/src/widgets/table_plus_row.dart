import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_cell.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_selection_cell.dart';
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
    this.onCheckboxChanged,
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
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.hoverButtonTheme,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
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
  final void Function(String rowId)? onCheckboxChanged;
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
  final Widget? Function(String rowId, Map<String, dynamic> rowData)?
      hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  final HoverButtonPosition hoverButtonPosition;

  /// Theme configuration for hover buttons.
  final TablePlusHoverButtonTheme? hoverButtonTheme;
  final TablePlusCheckboxTheme checkboxTheme;

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
        color:
            (widget.isSelectable && !widget.isEditable && widget.rowId != null)
                ? Colors.transparent
                : widget.backgroundColor,
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
            return TablePlusSelectionCell(
              width: width,
              rowId: widget.rowId,
              isSelected: widget.isSelected,
              theme: widget.theme,
              selectionTheme: widget.selectionTheme,
              checkboxTheme: widget.checkboxTheme,
              onSelectionChanged:
                  widget.onCheckboxChanged ?? widget.onRowSelectionChanged,
              calculatedHeight: widget.calculatedHeight,
            );
          }

          return TablePlusCell(
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

    // Create hover buttons using builder or theme
    Widget? hoverButtons;
    if (_isHovered && widget.rowId != null) {
      Widget? buttonWidget;

      // Priority: custom builder > theme-based default
      if (widget.hoverButtonBuilder != null) {
        buttonWidget =
            widget.hoverButtonBuilder!(widget.rowId!, widget.rowData);
      }

      if (buttonWidget != null) {
        // Position the buttons based on hoverButtonPosition
        switch (widget.hoverButtonPosition) {
          case HoverButtonPosition.left:
            hoverButtons = Positioned(
              left: widget.hoverButtonTheme?.horizontalOffset ?? 8.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: buttonWidget,
              ),
            );
            break;
          case HoverButtonPosition.center:
            hoverButtons = Positioned.fill(
              child: Center(
                child: buttonWidget,
              ),
            );
            break;
          case HoverButtonPosition.right:
            hoverButtons = Positioned(
              right: widget.hoverButtonTheme?.horizontalOffset ?? 8.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: buttonWidget,
              ),
            );
            break;
        }
      }
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
        hoverColor: widget.theme.getEffectiveHoverColor(widget.isSelected),
        splashColor: widget.theme.getEffectiveSplashColor(widget.isSelected),
        highlightColor:
            widget.theme.getEffectiveHighlightColor(widget.isSelected),
        child: hoveredContent,
      );
    }

    return hoveredContent;
  }
}
