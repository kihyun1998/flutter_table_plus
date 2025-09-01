import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/widgets/table_plus_row.dart';

import '../../flutter_table_plus.dart'
    show HoverButtonPosition, TablePlusHoverButtonTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/checkbox_theme.dart';
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import 'table_plus_merged_row.dart';
import 'table_plus_row_widget.dart';

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
    this.mergedGroups = const [],
    this.rowIdKey = 'id',
    this.isSelectable = false,
    this.selectionMode = SelectionMode.multiple,
    this.selectedRows = const <String>{},
    this.onRowSelectionChanged,
    this.onCheckboxChanged,
    this.onRowDoubleTap,
    this.onRowSecondaryTapDown,
    this.isEditable = false,
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onMergedCellChanged,
    this.onMergedRowExpandToggle,
    this.calculateRowHeight,
    this.needsVerticalScroll = false,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.hoverButtonTheme,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
  });

  /// The list of columns for the table.
  final List<TablePlusColumn> columns;

  /// The data to display in the table rows.
  final List<Map<String, dynamic>> data;

  /// The calculated width for each column.
  final List<double> columnWidths;

  /// List of merged row groups.
  final List<MergedRowGroup> mergedGroups;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

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

  /// Callback when a row's selection state changes via row click.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when a row's selection state changes via checkbox click.
  /// If not provided, falls back to [onRowSelectionChanged].
  final void Function(String rowId, bool isSelected)? onCheckboxChanged;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked (or long-pressed on touch devices).
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox, bool isSelected)?
      onRowSecondaryTapDown;

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

  /// Callback when a merged row group's expand/collapse state should be toggled.
  final void Function(String groupId)? onMergedRowExpandToggle;

  /// Callback to calculate the height of a specific row.
  /// Provides row index and row data, and should return the height for that row.
  /// If null, uses the fixed row height from the theme.
  final double? Function(int rowIndex, Map<String, dynamic> rowData)?
      calculateRowHeight;

  /// Builder function to create custom hover buttons for each row.
  ///
  /// Called when a row is hovered, providing the row ID and row data.
  /// Should return a Widget to display as an overlay on the row.
  /// If null, no hover buttons will be displayed.
  final Widget? Function(String rowId, Map<String, dynamic> rowData)?
      hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  final HoverButtonPosition hoverButtonPosition;

  /// Theme configuration for hover buttons.
  final TablePlusHoverButtonTheme? hoverButtonTheme;

  /// Theme configuration for checkboxes.
  final TablePlusCheckboxTheme checkboxTheme;

  /// Whether the table needs vertical scrolling.
  /// Used to determine if the last row should have a bottom border based on
  /// the [TablePlusBodyTheme.lastRowBorderBehavior] setting.
  final bool needsVerticalScroll;

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index, bool isSelected) {
    // Selected rows get selection color
    if (isSelected && isSelectable) {
      return theme.selectedRowColor;
    }

    // Alternate row colors
    if (theme.alternateRowColor != null && index.isOdd) {
      return theme.alternateRowColor!;
    }

    return theme.backgroundColor;
  }

  /// Extract the row ID from row data.
  String? _getRowId(Map<String, dynamic> rowData) {
    return rowData[rowIdKey]?.toString();
  }

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

  /// Handle row selection toggle via row click.
  /// For merged groups, this handles both group IDs and individual row IDs.
  void _handleRowSelectionToggle(String rowId) {
    if (onRowSelectionChanged == null) return;

    final isCurrentlySelected = selectedRows.contains(rowId);

    // Check if this rowId represents a merged group
    final mergeGroup = _getMergedGroupById(rowId);

    if (mergeGroup != null) {
      // This is a merged group selection
      _handleMergedGroupSelectionToggle(mergeGroup, isCurrentlySelected);
    } else {
      // This is a regular row selection
      _handleRegularRowSelectionToggle(rowId, isCurrentlySelected);
    }
  }

  /// Handle checkbox selection toggle.
  /// For merged groups, this handles both group IDs and individual row IDs.
  void _handleCheckboxToggle(String rowId) {
    // Use onCheckboxChanged if available, otherwise fall back to onRowSelectionChanged
    final callback = onCheckboxChanged ?? onRowSelectionChanged;
    if (callback == null) return;

    final isCurrentlySelected = selectedRows.contains(rowId);

    // Check if this rowId represents a merged group
    final mergeGroup = _getMergedGroupById(rowId);

    if (mergeGroup != null) {
      // This is a merged group selection
      callback(mergeGroup.groupId, !isCurrentlySelected);
    } else {
      // This is a regular row selection
      callback(rowId, !isCurrentlySelected);
    }
  }

  /// Handle selection toggle for merged groups.
  void _handleMergedGroupSelectionToggle(
      MergedRowGroup mergeGroup, bool isCurrentlySelected) {
    // For both single and multiple selection modes, toggle the selection
    onRowSelectionChanged!(mergeGroup.groupId, !isCurrentlySelected);
  }

  /// Handle selection toggle for regular rows.
  void _handleRegularRowSelectionToggle(
      String rowId, bool isCurrentlySelected) {
    if (selectionMode == SelectionMode.single) {
      // For single selection mode, toggle the selection
      // If already selected, deselect it; if not selected, select it
      onRowSelectionChanged!(rowId, !isCurrentlySelected);
    } else {
      // For multiple selection mode, toggle the selection
      onRowSelectionChanged!(rowId, !isCurrentlySelected);
    }
  }

  /// Find merged group by group ID.
  MergedRowGroup? _getMergedGroupById(String groupId) {
    for (final group in mergedGroups) {
      if (group.groupId == groupId) {
        return group;
      }
    }
    return null;
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

  /// Calculate the height for a specific row.
  double? _calculateRowHeight(int index) {
    if (calculateRowHeight == null || index >= data.length) return null;
    return calculateRowHeight!(index, data[index]);
  }

  /// Build a row widget for the given index.
  /// This method can be overridden or extended to support different row types.
  /// [index] - Original data index
  /// [renderIndex] - Rendering order index (for alternateRowColor)
  TablePlusRowWidget _buildRowWidget(int index, int renderIndex) {
    // Check if this index is part of a merged group
    final mergeGroup = _getMergedGroupForRow(index);

    if (mergeGroup != null) {
      final firstRowKey = mergeGroup.rowKeys.first;
      final firstRowIndex =
          data.indexWhere((row) => row[rowIdKey]?.toString() == firstRowKey);
      if (firstRowIndex == index) {
        // This is the first row in a merge group - create a merged row
        final isSelected = selectedRows.contains(mergeGroup.groupId);

        // Calculate merged row height and individual heights
        double? mergedHeight;
        List<double>? individualHeights;
        if (calculateRowHeight != null) {
          final heights = <double>[];
          double totalHeight = 0;

          // Calculate height for each row in the group
          for (final rowKey in mergeGroup.rowKeys) {
            final rowIndex =
                data.indexWhere((row) => row[rowIdKey]?.toString() == rowKey);
            if (rowIndex != -1) {
              final height = calculateRowHeight!(rowIndex, data[rowIndex]);
              if (height != null) {
                heights.add(height);
                totalHeight += height;
              } else {
                heights.add(theme.rowHeight);
                totalHeight += theme.rowHeight;
              }
            } else {
              heights.add(theme.rowHeight);
              totalHeight += theme.rowHeight;
            }
          }

          // Add summary row height if expandable and expanded
          if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
            heights.add(theme.rowHeight); // Summary row uses default height
            totalHeight += theme.rowHeight;
          }

          individualHeights = heights;
          mergedHeight = totalHeight;
        }

        return TablePlusMergedRow(
          mergeGroup: mergeGroup,
          allData: data,
          columns: columns,
          columnWidths: columnWidths,
          theme: theme,
          backgroundColor: _getRowColor(renderIndex, isSelected),
          isLastRow: (() {
            final lastRowKey = mergeGroup.rowKeys.last;
            final lastRowIndex = data
                .indexWhere((row) => row[rowIdKey]?.toString() == lastRowKey);
            return lastRowIndex == data.length - 1;
          })(),
          isSelectable: isSelectable,
          selectionMode: selectionMode,
          isSelected: isSelected,
          checkboxTheme: checkboxTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
          onCheckboxChanged: _handleCheckboxToggle,
          isEditable: isEditable,
          editableTheme: editableTheme,
          tooltipTheme: tooltipTheme,
          rowIdKey: rowIdKey,
          isCellEditing: isCellEditing,
          getCellController: getCellController,
          onCellTap: onCellTap,
          onStopEditing: onStopEditing,
          onRowDoubleTap: onRowDoubleTap,
          onRowSecondaryTapDown: onRowSecondaryTapDown,
          onMergedCellChanged: onMergedCellChanged,
          onMergedRowExpandToggle: onMergedRowExpandToggle,
          calculatedHeight: mergedHeight,
          individualHeights: individualHeights,
          needsVerticalScroll: needsVerticalScroll,
          hoverButtonBuilder: hoverButtonBuilder,
          hoverButtonPosition: hoverButtonPosition,
          hoverButtonTheme: hoverButtonTheme,
        );
      }
    }

    // This is a normal row (not part of any merge group)
    final rowData = data[index];
    final rowId = _getRowId(rowData);
    final isSelected = rowId != null && selectedRows.contains(rowId);
    final calculatedHeight = _calculateRowHeight(index);

    return TablePlusRow(
      rowIndex: index,
      rowData: rowData,
      rowId: rowId,
      columns: columns,
      columnWidths: columnWidths,
      theme: theme,
      backgroundColor: _getRowColor(renderIndex, isSelected),
      isLastRow: index == data.length - 1,
      isSelectable: isSelectable,
      selectionMode: selectionMode,
      isSelected: isSelected,
      checkboxTheme: checkboxTheme,
      onRowSelectionChanged: _handleRowSelectionToggle,
      onCheckboxChanged: _handleCheckboxToggle,
      onRowDoubleTap: onRowDoubleTap,
      onRowSecondaryTapDown: onRowSecondaryTapDown,
      isEditable: isEditable,
      editableTheme: editableTheme,
      tooltipTheme: tooltipTheme,
      isCellEditing: isCellEditing,
      getCellController: getCellController,
      onCellTap: onCellTap,
      onStopEditing: onStopEditing,
      calculatedHeight: calculatedHeight,
      needsVerticalScroll: needsVerticalScroll,
      hoverButtonBuilder: hoverButtonBuilder,
      hoverButtonPosition: hoverButtonPosition,
      hoverButtonTheme: hoverButtonTheme,
    );
  }
}
