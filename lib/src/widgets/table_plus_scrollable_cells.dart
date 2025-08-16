import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import 'custom_ink_well.dart';

/// A widget that renders scrollable column cells for a single row.
/// 
/// This widget is responsible for rendering only the scrollable columns of a row,
/// which can be scrolled horizontally.
class TablePlusScrollableCells extends StatelessWidget {
  /// Creates a [TablePlusScrollableCells] with the specified configuration.
  const TablePlusScrollableCells({
    super.key,
    required this.scrollableColumns,
    required this.rowData,
    required this.rowIndex,
    required this.columnWidths,
    required this.theme,
    required this.rowIdKey,
    this.isEditable = false,
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.backgroundColor,
  });

  /// The list of scrollable columns to render.
  final List<TablePlusColumn> scrollableColumns;

  /// The data for this row.
  final Map<String, dynamic> rowData;

  /// The index of this row in the data list.
  final int rowIndex;

  /// The calculated widths for each scrollable column.
  final List<double> columnWidths;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The key used to extract row IDs from row data.
  final String rowIdKey;

  /// Whether the table supports cell editing.
  final bool isEditable;

  /// The theme configuration for editing.
  final TablePlusEditableTheme editableTheme;

  /// The theme configuration for tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// Function to check if a cell is currently being edited.
  final bool Function(int rowIndex, String columnKey)? isCellEditing;

  /// Function to get the TextEditingController for a cell.
  final TextEditingController? Function(int rowIndex, String columnKey)?
      getCellController;

  /// Callback when a cell is tapped for editing.
  final void Function(int rowIndex, String columnKey)? onCellTap;

  /// Callback to stop current editing.
  final void Function({required bool save})? onStopEditing;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked.
  final void Function(String rowId)? onRowSecondaryTap;

  /// The background color for this row.
  final Color? backgroundColor;

  /// Extract the row ID from row data.
  String? get _rowId => rowData[rowIdKey]?.toString();

  @override
  Widget build(BuildContext context) {
    if (scrollableColumns.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total width needed for scrollable content
    final totalWidth = columnWidths.fold(0.0, (sum, width) => sum + width);

    return Container(
      color: backgroundColor,
      child: SizedBox(
        width: totalWidth,
        child: Row(
          children: scrollableColumns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            final width = index < columnWidths.length ? columnWidths[index] : column.width;

            return _buildCell(context, column, width);
          }).toList(),
        ),
      ),
    );
  }

  /// Build a single cell for the given column.
  Widget _buildCell(BuildContext context, TablePlusColumn column, double width) {
    final cellValue = rowData[column.key];
    final isEditing = isCellEditing?.call(rowIndex, column.key) ?? false;

    return SizedBox(
      width: width,
      height: theme.rowHeight,
      child: Container(
        alignment: column.alignment,
        padding: theme.padding,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: theme.dividerColor,
              width: theme.dividerThickness,
            ),
            bottom: BorderSide(
              color: theme.dividerColor,
              width: theme.dividerThickness,
            ),
          ),
        ),
        child: _buildCellContent(context, column, cellValue, isEditing),
      ),
    );
  }

  /// Build the content of a cell.
  Widget _buildCellContent(BuildContext context, TablePlusColumn column, dynamic cellValue, bool isEditing) {
    // Handle editing mode
    if (isEditing && isEditable && column.editable) {
      final controller = getCellController?.call(rowIndex, column.key);
      return _buildEditingCell(column, controller);
    }

    // Handle custom cell builder
    if (column.cellBuilder != null) {
      return column.cellBuilder!(context, rowData);
    }

    // Handle regular text cell
    return _buildTextCell(column, cellValue);
  }

  /// Build an editing cell with TextField.
  Widget _buildEditingCell(TablePlusColumn column, TextEditingController? controller) {
    return TextField(
      controller: controller,
      style: editableTheme.editingTextStyle,
      textAlign: column.textAlign,
      decoration: InputDecoration(
        hintText: column.hintText,
        hintStyle: editableTheme.hintStyle,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onTap: () => onStopEditing?.call(save: false),
      onSubmitted: (_) => onStopEditing?.call(save: true),
    );
  }

  /// Build a regular text cell.
  Widget _buildTextCell(TablePlusColumn column, dynamic cellValue) {
    final displayValue = cellValue?.toString() ?? '';

    return CustomInkWell(
      onTap: () {
        if (isEditable && column.editable) {
          onCellTap?.call(rowIndex, column.key);
        }
      },
      onDoubleTap: () {
        final rowId = _rowId;
        if (rowId != null) {
          onRowDoubleTap?.call(rowId);
        }
      },
      onSecondaryTap: () {
        final rowId = _rowId;
        if (rowId != null) {
          onRowSecondaryTap?.call(rowId);
        }
      },
      child: Align(
        alignment: column.alignment,
        child: _buildTextWithTooltip(column, displayValue),
      ),
    );
  }

  /// Build text with optional tooltip.
  Widget _buildTextWithTooltip(TablePlusColumn column, String displayValue) {
    final textWidget = Text(
      displayValue,
      style: theme.textStyle,
      textAlign: column.textAlign,
      overflow: column.textOverflow,
      maxLines: 1,
    );

    // Handle tooltip behavior
    if (column.tooltipBehavior == TooltipBehavior.never) {
      return textWidget;
    }

    if (column.tooltipBehavior == TooltipBehavior.always) {
      return Tooltip(
        message: displayValue,
        textStyle: tooltipTheme.textStyle,
        decoration: tooltipTheme.decoration,
        child: textWidget,
      );
    }

    // TooltipBehavior.onOverflowOnly
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: displayValue,
          style: theme.textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines ||
            textPainter.size.width > constraints.maxWidth;

        if (isOverflowing) {
          return Tooltip(
            message: displayValue,
            textStyle: tooltipTheme.textStyle,
            decoration: tooltipTheme.decoration,
            child: textWidget,
          );
        }

        return textWidget;
      },
    );
  }
}