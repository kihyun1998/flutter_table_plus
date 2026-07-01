import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_cell.dart';
import 'package:flutter_table_plus/src/widgets/cells/table_plus_selection_cell.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row_widget.dart';

import 'package:flutter_table_plus/src/utils/column_width_access.dart';
import 'package:flutter_table_plus/src/widgets/row_decoration.dart';

/// A single table row widget.
class TablePlusRow<T> extends TablePlusRowWidget<T> {
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
    this.onRowSecondaryTapDown,
    this.calculatedHeight,
    this.needsVerticalScroll = false,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.hoverButtonTheme,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
    this.isDim = false,
  });

  final int rowIndex;
  final T rowData;
  final String? rowId;
  final List<TablePlusColumn<T>> columns;
  final List<double> columnWidths;
  @override
  final TablePlusBodyTheme theme;
  @override
  final Color backgroundColor;
  @override
  final bool isLastRow;
  @override
  final bool isSelectable;
  final SelectionMode selectionMode;
  @override
  final bool isSelected;
  @override
  final void Function(String rowId) onRowSelectionChanged;
  final void Function(String rowId)? onCheckboxChanged;
  @override
  final bool isEditable;
  final TablePlusEditableTheme editableTheme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool Function(int rowIndex, String columnKey)? isCellEditing;
  final TextEditingController? Function(int rowIndex, String columnKey)?
      getCellController;
  final void Function(int rowIndex, String columnKey)? onCellTap;
  final void Function({required bool save})? onStopEditing;
  @override
  final void Function(String rowId)? onRowDoubleTap;
  @override
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;
  @override
  final double? calculatedHeight;
  final bool needsVerticalScroll;

  /// Builder function to create custom hover buttons for this row.
  @override
  final Widget? Function(String rowId, T rowData)? hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  @override
  final HoverButtonPosition hoverButtonPosition;

  /// Theme configuration for hover buttons.
  @override
  final TablePlusHoverButtonTheme? hoverButtonTheme;
  final TablePlusCheckboxTheme checkboxTheme;

  /// Whether this row is a dim row.
  @override
  final bool isDim;

  // Implementation of TablePlusRowWidget abstract methods
  @override
  String? get selectionId => rowId;

  @override
  int get effectiveRowCount => 1;

  @override
  List<int> get originalDataIndices => [rowIndex];

  @override
  State<TablePlusRow<T>> createState() => _TablePlusRowState<T>();
}

class _TablePlusRowState<T> extends TablePlusRowStateBase<TablePlusRow<T>, T> {
  @override
  T? get hoverData => widget.rowData;

  @override
  Widget buildRowContent(BuildContext context) {
    return Container(
      height: widget.calculatedHeight ?? widget.theme.rowHeight,
      decoration: rowDecoration(
        selectionTransparent: widget.enableSelectionInk,
        backgroundColor: widget.backgroundColor,
        theme: widget.theme,
        isLastRow: widget.isLastRow,
        needsVerticalScroll: widget.needsVerticalScroll,
      ),
      child: Row(
        children: List.generate(widget.columns.length, (index) {
          final column = widget.columns[index];
          final width = widget.columnWidths.widthAt(index, column);

          // Special handling for selection column
          if (widget.isSelectable && column.key == '__selection__') {
            return TablePlusSelectionCell(
              width: width,
              rowId: widget.rowId,
              isSelected: widget.isSelected,
              theme: widget.theme,
              checkboxTheme: widget.checkboxTheme,
              onSelectionChanged:
                  widget.onCheckboxChanged ?? widget.onRowSelectionChanged,
              calculatedHeight: widget.calculatedHeight,
            );
          }

          return TablePlusCell<T>(
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
            cellController:
                widget.getCellController?.call(widget.rowIndex, column.key),
            onCellTap: widget.onCellTap != null
                ? () => widget.onCellTap!(widget.rowIndex, column.key)
                : null,
            onStopEditing: widget.onStopEditing,
            calculatedHeight: widget.calculatedHeight,
            isDim: widget.isDim,
          );
        }),
      ),
    );
  }
}
