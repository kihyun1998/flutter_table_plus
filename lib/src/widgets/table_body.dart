import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';
import 'custom_ink_well.dart';

/// A widget that renders the data rows of the table.
class TablePlusBody extends StatelessWidget {
  /// Creates a [TablePlusBody] with the specified configuration.
  const TablePlusBody({
    super.key,
    required this.columns,
    required this.data,
    required this.columnWidths,
    required this.theme,
    required this.verticalController,
    this.isSelectable = false,
    this.selectedRows = const <String>{},
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onRowSelectionChanged,
  });

  /// The list of columns for the table.
  final List<TablePlusColumn> columns;

  /// The data to display in the table rows.
  final List<Map<String, dynamic>> data;

  /// The calculated width for each column.
  final List<double> columnWidths;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when a row's selection state changes.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index, bool isSelected) {
    // Selected rows get selection color
    if (isSelected && isSelectable) {
      return selectionTheme.selectedRowColor;
    }

    // Alternate row colors
    if (theme.alternateRowColor != null && index.isOdd) {
      return theme.alternateRowColor!;
    }

    return theme.backgroundColor;
  }

  /// Extract the row ID from row data.
  String? _getRowId(Map<String, dynamic> rowData) {
    return rowData['id']?.toString();
  }

  /// Handle row selection toggle.
  void _handleRowSelectionToggle(String rowId) {
    if (onRowSelectionChanged == null) return;

    final isCurrentlySelected = selectedRows.contains(rowId);
    onRowSelectionChanged!(rowId, !isCurrentlySelected);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: theme.rowHeight * 3, // Show some height even when empty
        decoration: BoxDecoration(
          color: theme.backgroundColor,
        ),
        child: Center(
          child: Text(
            'No data available',
            style: theme.textStyle.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: verticalController,
      physics: const ClampingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final rowData = data[index];
        final rowId = _getRowId(rowData);
        final isSelected = rowId != null && selectedRows.contains(rowId);

        return _TablePlusRow(
          rowData: rowData,
          rowId: rowId,
          columns: columns,
          columnWidths: columnWidths,
          theme: theme,
          backgroundColor: _getRowColor(index, isSelected),
          isLastRow: index == data.length - 1,
          isSelectable: isSelectable,
          isSelected: isSelected,
          selectionTheme: selectionTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
        );
      },
    );
  }
}

/// A single table row widget.
class _TablePlusRow extends StatelessWidget {
  const _TablePlusRow({
    required this.rowData,
    required this.rowId,
    required this.columns,
    required this.columnWidths,
    required this.theme,
    required this.backgroundColor,
    required this.isLastRow,
    required this.isSelectable,
    required this.isSelected,
    required this.selectionTheme,
    required this.onRowSelectionChanged,
  });

  final Map<String, dynamic> rowData;
  final String? rowId;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  final Color backgroundColor;
  final bool isLastRow;
  final bool isSelectable;
  final bool isSelected;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onRowSelectionChanged;

  /// Handle row tap for selection.
  void _handleRowTap() {
    if (!isSelectable || rowId == null) return;
    onRowSelectionChanged(rowId!);
  }

  @override
  Widget build(BuildContext context) {
    Widget rowContent = Container(
      height: theme.rowHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: (!isLastRow && theme.showHorizontalDividers)
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width =
              columnWidths.isNotEmpty ? columnWidths[index] : column.width;

          // Special handling for selection column
          if (isSelectable && column.key == '__selection__') {
            return _SelectionCell(
              width: width,
              rowId: rowId,
              isSelected: isSelected,
              theme: theme,
              selectionTheme: selectionTheme,
              onSelectionChanged: onRowSelectionChanged,
            );
          }

          return _TablePlusCell(
            column: column,
            rowData: rowData,
            width: width,
            theme: theme,
          );
        }),
      ),
    );

    // Wrap with CustomInkWell for row selection if selectable
    if (isSelectable && rowId != null) {
      return CustomInkWell(
        onTap: _handleRowTap,
        child: rowContent,
      );
    }

    return rowContent;
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
  });

  final double width;
  final String? rowId;
  final bool isSelected;
  final TablePlusBodyTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
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
class _TablePlusCell extends StatelessWidget {
  const _TablePlusCell({
    required this.column,
    required this.rowData,
    required this.width,
    required this.theme,
  });

  final TablePlusColumn column;
  final Map<String, dynamic> rowData;
  final double width;
  final TablePlusBodyTheme theme;

  /// Extract the display value for this cell.
  String _getCellDisplayValue() {
    final value = rowData[column.key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Use custom cell builder if provided
    if (column.cellBuilder != null) {
      return Container(
        width: width,
        height: theme.rowHeight,
        padding: theme.padding,
        decoration: BoxDecoration(
          border: theme.showVerticalDividers
              ? Border(
                  right: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Align(
          alignment: column.alignment,
          child: column.cellBuilder!(context, rowData),
        ),
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    return Container(
      width: width,
      height: theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: theme.showVerticalDividers
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Align(
        alignment: column.alignment,
        child: Text(
          displayValue,
          style: theme.textStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: column.textAlign,
        ),
      ),
    );
  }
}
