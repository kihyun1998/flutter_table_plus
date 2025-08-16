import 'package:flutter/material.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/theme/divider_theme.dart' show TablePlusDividerTheme;
import 'table_plus_row_widget.dart';
import 'table_plus_unified_row.dart';

/// A widget that renders the data rows of the table using a unified row approach.
/// 
/// This widget uses a single ListView with unified rows that handle both frozen
/// and scrollable columns, replacing the previous dual ListView approach for
/// better performance.
class TablePlusBody extends StatelessWidget {
  /// Creates a [TablePlusBody] with the specified configuration.
  const TablePlusBody({
    super.key,
    required this.frozenColumns,
    required this.scrollableColumns,
    required this.frozenColumnWidths,
    required this.scrollableColumnWidths,
    required this.data,
    required this.theme,
    required this.dividerTheme,
    required this.verticalController,
    required this.horizontalScrollController,
    this.mergedGroups = const [],
    this.rowIdKey = 'id',
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

  /// The list of frozen columns for the table.
  final List<TablePlusColumn> frozenColumns;

  /// The list of scrollable columns for the table.
  final List<TablePlusColumn> scrollableColumns;

  /// The calculated widths for each frozen column.
  final List<double> frozenColumnWidths;

  /// The calculated widths for each scrollable column.
  final List<double> scrollableColumnWidths;

  /// The data to display in the table rows.
  final List<Map<String, dynamic>> data;

  /// List of merged row groups.
  final List<MergedRowGroup> mergedGroups;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The theme configuration for the divider between frozen and scrollable areas.
  final TablePlusDividerTheme dividerTheme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

  /// The scroll controller for horizontal scrolling of the scrollable area.
  final ScrollController horizontalScrollController;

  /// The key used to extract row IDs from row data.
  /// Defaults to 'id'. Each row must have a unique value for this key when using selection features.
  final String rowIdKey;

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

  /// Callback to calculate the height of a specific row.
  final double? Function(int rowIndex, Map<String, dynamic> rowData)?
      calculateRowHeight;


  /// Find the merged group that contains the specified row index.
  MergedRowGroup? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= data.length) return null;
    final rowData = data[rowIndex];
    final rowKey = rowData[rowIdKey]?.toString();
    if (rowKey == null) return null;

    for (final group in mergedGroups) {
      if (group.rowKeys.contains(rowKey)) {
        return group;
      }
    }
    return null;
  }

  /// Get the list of indices that should actually be rendered.
  /// This excludes rows that are part of merge groups (except the first row of each group).
  List<int> _getRenderableIndices() {
    List<int> renderableIndices = [];
    Set<int> processedIndices = {};

    for (int i = 0; i < data.length; i++) {
      if (processedIndices.contains(i)) continue;

      final mergeGroup = _getMergedGroupForRow(i);
      if (mergeGroup != null) {
        // Add only the first row of the merge group
        final firstRowKey = mergeGroup.rowKeys.first;
        final firstRowIndex =
            data.indexWhere((row) => row[rowIdKey]?.toString() == firstRowKey);
        if (firstRowIndex == i) {
          renderableIndices.add(i);
        }
        // Mark all rows in this group as processed
        for (final rowKey in mergeGroup.rowKeys) {
          final rowIndex =
              data.indexWhere((row) => row[rowIdKey]?.toString() == rowKey);
          if (rowIndex != -1) {
            processedIndices.add(rowIndex);
          }
        }
      } else {
        // Regular row - add it
        renderableIndices.add(i);
        processedIndices.add(i);
      }
    }

    return renderableIndices;
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

    final renderableIndices = _getRenderableIndices();

    return ListView.builder(
      controller: verticalController,
      physics: const ClampingScrollPhysics(),
      itemCount: renderableIndices.length,
      itemBuilder: (context, index) {
        final actualIndex = renderableIndices[index];
        return _buildRowWidget(actualIndex, index); // Pass rendering index
      },
    );
  }


  /// Build a unified row widget for the given index.
  /// This method creates a single row that handles both frozen and scrollable columns.
  /// [index] - Original data index
  /// [renderIndex] - Rendering order index (for alternateRowColor)
  TablePlusRowWidget _buildRowWidget(int index, int renderIndex) {
    // Check if this index is part of a merged group
    final mergeGroup = _getMergedGroupForRow(index);
    final rowData = data[index];

    return TablePlusUnifiedRow(
      frozenColumns: frozenColumns,
      scrollableColumns: scrollableColumns,
      frozenColumnWidths: frozenColumnWidths,
      scrollableColumnWidths: scrollableColumnWidths,
      rowData: rowData,
      rowIndex: renderIndex, // Use render index for alternating colors
      theme: theme,
      dividerTheme: dividerTheme,
      horizontalScrollController: horizontalScrollController,
      rowIdKey: rowIdKey,
      mergedGroup: mergeGroup,
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
      onMergedCellChanged: onMergedCellChanged,
      calculateRowHeight: calculateRowHeight,
    );
  }
}