import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/theme/divider_theme.dart' show TablePlusDividerTheme;
import 'table_plus_frozen_cells.dart';
import 'table_plus_scrollable_cells.dart';
import 'table_plus_row_widget.dart';

/// A unified row widget that handles both frozen and scrollable columns in a single row.
/// 
/// This widget replaces the dual ListView approach with a single row that contains
/// both frozen (left) and scrollable (right) parts, improving performance significantly.
class TablePlusUnifiedRow extends TablePlusRowWidget {
  /// Creates a [TablePlusUnifiedRow] with the specified configuration.
  const TablePlusUnifiedRow({
    super.key,
    required this.frozenColumns,
    required this.scrollableColumns,
    required this.frozenColumnWidths,
    required this.scrollableColumnWidths,
    required this.rowData,
    required this.rowIndex,
    required this.theme,
    required this.dividerTheme,
    required this.horizontalScrollController,
    required this.rowIdKey,
    this.mergedGroup,
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.onRowSelectionChanged,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.isEditable = false,
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onMergedCellChanged,
    this.calculateRowHeight,
  });

  /// The list of frozen columns to render.
  final List<TablePlusColumn> frozenColumns;

  /// The list of scrollable columns to render.
  final List<TablePlusColumn> scrollableColumns;

  /// The calculated widths for each frozen column.
  final List<double> frozenColumnWidths;

  /// The calculated widths for each scrollable column.
  final List<double> scrollableColumnWidths;

  /// The data for this row.
  final Map<String, dynamic> rowData;

  /// The index of this row in the data list.
  final int rowIndex;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The theme configuration for the divider between frozen and scrollable areas.
  final TablePlusDividerTheme dividerTheme;

  /// The horizontal scroll controller for the scrollable area.
  final ScrollController horizontalScrollController;

  /// The key used to extract row IDs from row data.
  final String rowIdKey;

  /// The merged group this row belongs to, if any.
  final MergedRowGroup? mergedGroup;

  /// Whether the table supports row selection.
  final bool isSelectable;

  /// The selection mode for the table.
  final SelectionMode selectionMode;

  /// The set of currently selected row IDs.
  final Set<String> selectedRows;

  /// The theme configuration for selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when a row's selection state changes.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked.
  final void Function(String rowId)? onRowSecondaryTap;

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

  /// Callback when a merged cell value is changed.
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;

  /// Callback to calculate the height of this row.
  final double? Function(int rowIndex, Map<String, dynamic> rowData)?
      calculateRowHeight;

  /// Extract the row ID from row data.
  String? get _rowId => rowData[rowIdKey]?.toString();

  /// Check if this row is currently selected.
  bool get _isSelected => _rowId != null && selectedRows.contains(_rowId);

  /// Get the background color for this row.
  Color _getRowColor() {
    // Selected rows get selection color
    if (_isSelected && isSelectable) {
      return selectionTheme.selectedRowColor;
    }

    // Alternate row colors
    if (theme.alternateRowColor != null && rowIndex.isOdd) {
      return theme.alternateRowColor!;
    }

    return theme.backgroundColor;
  }

  /// Get the height for this row.
  double _getRowHeight() {
    return calculateRowHeight?.call(rowIndex, rowData) ?? theme.rowHeight;
  }

  // Implementation of TablePlusRowWidget abstract methods
  @override
  int get effectiveRowCount => 1;

  @override
  List<int> get originalDataIndices => [rowIndex];

  @override
  Color get backgroundColor => _getRowColor();

  @override
  bool get isLastRow => false; // This will be determined by the parent

  @override
  double? get calculatedHeight => _getRowHeight();

  @override
  Widget build(BuildContext context) {
    // Handle merged rows
    if (mergedGroup != null) {
      // For merged rows, we need to create a custom merged row implementation
      // For now, we'll use regular row rendering since TablePlusMergedRow has different API
      // TODO: Implement proper merged row support in unified approach
    }

    final backgroundColor = _getRowColor();
    final rowHeight = _getRowHeight();

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          // Frozen area (left side)
          if (frozenColumns.isNotEmpty) ...[
            TablePlusFrozenCells(
              frozenColumns: frozenColumns,
              rowData: rowData,
              rowIndex: rowIndex,
              columnWidths: frozenColumnWidths,
              theme: theme,
              rowIdKey: rowIdKey,
              isSelectable: isSelectable,
              selectionMode: selectionMode,
              selectedRows: selectedRows,
              selectionTheme: selectionTheme,
              onRowSelectionChanged: onRowSelectionChanged,
              onRowDoubleTap: onRowDoubleTap,
              onRowSecondaryTap: onRowSecondaryTap,
              isEditable: isEditable,
              editableTheme: editableTheme,
              tooltipTheme: tooltipTheme,
              isCellEditing: isCellEditing,
              getCellController: getCellController,
              onCellTap: onCellTap,
              onStopEditing: onStopEditing,
              backgroundColor: backgroundColor,
            ),

            // Divider between frozen and scrollable areas
            if (scrollableColumns.isNotEmpty)
              Container(
                width: dividerTheme.thickness,
                height: rowHeight,
                margin: EdgeInsets.only(
                  top: dividerTheme.indent,
                  bottom: dividerTheme.endIndent,
                ),
                color: dividerTheme.getEffectiveColor(),
              ),
          ],

          // Scrollable area (right side)
          if (scrollableColumns.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: TablePlusScrollableCells(
                  scrollableColumns: scrollableColumns,
                  rowData: rowData,
                  rowIndex: rowIndex,
                  columnWidths: scrollableColumnWidths,
                  theme: theme,
                  rowIdKey: rowIdKey,
                  isEditable: isEditable,
                  editableTheme: editableTheme,
                  tooltipTheme: tooltipTheme,
                  isCellEditing: isCellEditing,
                  getCellController: getCellController,
                  onCellTap: onCellTap,
                  onStopEditing: onStopEditing,
                  onRowDoubleTap: onRowDoubleTap,
                  onRowSecondaryTap: onRowSecondaryTap,
                  backgroundColor: backgroundColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

}