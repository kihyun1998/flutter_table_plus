import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

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

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index) {
    if (theme.alternateRowColor != null && index.isOdd) {
      return theme.alternateRowColor!;
    }
    return theme.backgroundColor;
  }

  /// Extract the display value for a cell.
  String _getCellDisplayValue(
      Map<String, dynamic> rowData, TablePlusColumn column) {
    final value = rowData[column.key];
    if (value == null) return '';
    return value.toString();
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

        return _TableRow(
          rowData: rowData,
          columns: columns,
          columnWidths: columnWidths,
          theme: theme,
          backgroundColor: _getRowColor(index),
          isLastRow: index == data.length - 1,
        );
      },
    );
  }
}

/// A single table row widget.
class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.rowData,
    required this.columns,
    required this.columnWidths,
    required this.theme,
    required this.backgroundColor,
    required this.isLastRow,
  });

  final Map<String, dynamic> rowData;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  final Color backgroundColor;
  final bool isLastRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.rowHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: !isLastRow
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

          return _TableCell(
            column: column,
            rowData: rowData,
            width: width,
            theme: theme,
          );
        }),
      ),
    );
  }
}

/// A single table cell widget.
class _TableCell extends StatelessWidget {
  const _TableCell({
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
          border: Border(
            right: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
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
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
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
