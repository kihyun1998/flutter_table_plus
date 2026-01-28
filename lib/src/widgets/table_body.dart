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
class TablePlusBody extends StatefulWidget {
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
    this.dimRowKey,
    this.invertDimRow = false,
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
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;

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

  /// The key in rowData that determines if a row should be dimmed.
  /// The value at this key must be a boolean.
  final String? dimRowKey;

  /// Whether to invert the dim row logic.
  final bool invertDimRow;

  @override
  State<TablePlusBody> createState() => _TablePlusBodyState();
}

class _TablePlusBodyState extends State<TablePlusBody> {
  /// Cached renderable indices — recomputed only when data or mergedGroups change.
  /// Null when no merged groups exist (use data indices directly).
  List<int>? _cachedRenderableIndices;

  /// Cached lookup: rowKey → MergedRowGroup for O(1) access.
  Map<String, MergedRowGroup> _rowKeyToGroup = const {};

  /// Cached lookup: rowKey → data index for O(1) access.
  Map<String, int> _rowKeyToIndex = const {};

  /// Cached row heights — avoids repeated calculateRowHeight calls.
  /// Invalidated together with other caches when data changes.
  Map<int, double> _cachedRowHeights = const {};

  @override
  void initState() {
    super.initState();
    _rebuildCaches();
  }

  @override
  void didUpdateWidget(covariant TablePlusBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.data, oldWidget.data) ||
        !identical(widget.mergedGroups, oldWidget.mergedGroups) ||
        widget.rowIdKey != oldWidget.rowIdKey) {
      _rebuildCaches();
    }
  }

  /// Rebuild all lookup caches. O(n + m*k) once, then O(1) per query.
  void _rebuildCaches() {
    final data = widget.data;
    final mergedGroups = widget.mergedGroups;
    final rowIdKey = widget.rowIdKey;

    // Build rowKey → index map: O(n)
    final rowKeyToIndex = <String, int>{};
    for (int i = 0; i < data.length; i++) {
      final key = data[i][rowIdKey]?.toString();
      if (key != null) {
        rowKeyToIndex[key] = i;
      }
    }

    // Build rowKey → group map: O(m*k)
    final rowKeyToGroup = <String, MergedRowGroup>{};
    for (final group in mergedGroups) {
      for (final rowKey in group.rowKeys) {
        rowKeyToGroup[rowKey] = group;
      }
    }

    // Build renderable indices only when merged groups exist
    if (mergedGroups.isEmpty) {
      _cachedRenderableIndices = null; // Skip — use data.length directly
    } else {
      final renderableIndices = <int>[];
      final processedIndices = <int>{};

      for (int i = 0; i < data.length; i++) {
        if (processedIndices.contains(i)) continue;

        final rowKey = data[i][rowIdKey]?.toString();
        final group = rowKey != null ? rowKeyToGroup[rowKey] : null;

        if (group != null) {
          final firstRowKey = group.rowKeys.first;
          final firstRowIndex = rowKeyToIndex[firstRowKey];
          if (firstRowIndex == i) {
            renderableIndices.add(i);
          }
          for (final gRowKey in group.rowKeys) {
            final idx = rowKeyToIndex[gRowKey];
            if (idx != null) {
              processedIndices.add(idx);
            }
          }
        } else {
          renderableIndices.add(i);
          processedIndices.add(i);
        }
      }

      _cachedRenderableIndices = renderableIndices;
    }

    _rowKeyToGroup = rowKeyToGroup;
    _rowKeyToIndex = rowKeyToIndex;
    _cachedRowHeights = {}; // Invalidate height cache when data changes
  }

  /// Check if a row should be dimmed based on dimRowKey.
  bool _isDimRow(Map<String, dynamic> rowData) {
    if (widget.dimRowKey == null) return false;

    final value = rowData[widget.dimRowKey];

    // Type check: must be bool
    if (value is! bool) {
      assert(
        false,
        'dimRowKey "${widget.dimRowKey}" value must be a bool, but got ${value.runtimeType}. '
        'Row data: $rowData',
      );
      return false;
    }

    // Apply inversion if needed
    return widget.invertDimRow ? !value : value;
  }

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index, bool isSelected, bool isDim) {
    // Selected rows get selection color (highest priority)
    if (isSelected && widget.isSelectable) {
      return widget.theme.selectedRowColor;
    }

    // Dim rows get dim color
    if (isDim) {
      return widget.theme.dimRowColor ?? widget.theme.backgroundColor;
    }

    // Alternate row colors
    if (widget.theme.alternateRowColor != null && index.isOdd) {
      return widget.theme.alternateRowColor!;
    }

    return widget.theme.backgroundColor;
  }

  /// Extract the row ID from row data.
  String? _getRowId(Map<String, dynamic> rowData) {
    return rowData[widget.rowIdKey]?.toString();
  }

  /// Find the merged group that contains the specified row index.
  /// Uses cached O(1) lookup instead of O(m) linear scan.
  MergedRowGroup? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= widget.data.length) return null;
    final rowData = widget.data[rowIndex];
    final rowKey = rowData[widget.rowIdKey]?.toString();
    if (rowKey == null) return null;
    return _rowKeyToGroup[rowKey];
  }

  /// Handle row selection toggle via row click.
  /// For merged groups, this handles both group IDs and individual row IDs.
  void _handleRowSelectionToggle(String rowId) {
    if (widget.onRowSelectionChanged == null) return;

    final isCurrentlySelected = widget.selectedRows.contains(rowId);

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
    final callback = widget.onCheckboxChanged ?? widget.onRowSelectionChanged;
    if (callback == null) return;

    final isCurrentlySelected = widget.selectedRows.contains(rowId);

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
    widget.onRowSelectionChanged!(mergeGroup.groupId, !isCurrentlySelected);
  }

  /// Handle selection toggle for regular rows.
  void _handleRegularRowSelectionToggle(
      String rowId, bool isCurrentlySelected) {
    if (widget.selectionMode == SelectionMode.single) {
      widget.onRowSelectionChanged!(rowId, !isCurrentlySelected);
    } else {
      widget.onRowSelectionChanged!(rowId, !isCurrentlySelected);
    }
  }

  /// Find merged group by group ID.
  MergedRowGroup? _getMergedGroupById(String groupId) {
    for (final group in widget.mergedGroups) {
      if (group.groupId == groupId) {
        return group;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: widget.theme.rowHeight * 3,
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
        ),
        child: Center(
          child: Text(
            'No data available',
            style: widget.theme.textStyle.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final indices = _cachedRenderableIndices;

    return ListView.builder(
      controller: widget.verticalController,
      physics: const ClampingScrollPhysics(),
      itemExtentBuilder: (int index, _) {
        final actualIndex = indices?[index] ?? index;
        final group = _getMergedGroupForRow(actualIndex);
        if (group != null) {
          return _getMergedGroupExtent(group);
        }
        return _calculateRowHeight(actualIndex) ?? widget.theme.rowHeight;
      },
      itemCount: indices?.length ?? widget.data.length,
      itemBuilder: (context, index) {
        final actualIndex = indices?[index] ?? index;
        return _buildRowWidget(actualIndex, index);
      },
    );
  }

  /// Calculate the total extent for a merged group (for itemExtentBuilder).
  double _getMergedGroupExtent(MergedRowGroup group) {
    double total = 0;
    for (final rowKey in group.rowKeys) {
      final rowIndex = _rowKeyToIndex[rowKey];
      if (rowIndex != null) {
        total += _calculateRowHeight(rowIndex) ?? widget.theme.rowHeight;
      } else {
        total += widget.theme.rowHeight;
      }
    }
    if (group.isExpandable && group.isExpanded) {
      total += widget.theme.rowHeight;
    }
    return total;
  }

  /// Calculate the height for a specific row, with caching.
  double? _calculateRowHeight(int index) {
    if (widget.calculateRowHeight == null || index >= widget.data.length) {
      return null;
    }
    final cached = _cachedRowHeights[index];
    if (cached != null) return cached;
    final height = widget.calculateRowHeight!(index, widget.data[index]);
    if (height != null) {
      _cachedRowHeights[index] = height;
    }
    return height;
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
      final firstRowIndex = _rowKeyToIndex[firstRowKey];
      if (firstRowIndex != null && firstRowIndex == index) {
        // This is the first row in a merge group - create a merged row
        final isSelected = widget.selectedRows.contains(mergeGroup.groupId);
        final firstRowData = widget.data[firstRowIndex];
        final isDimmed = _isDimRow(firstRowData);

        // Calculate merged row height and individual heights
        double? mergedHeight;
        List<double>? individualHeights;
        if (widget.calculateRowHeight != null) {
          final heights = <double>[];
          double totalHeight = 0;

          // Calculate height for each row in the group (using cache)
          for (final rowKey in mergeGroup.rowKeys) {
            final rowIndex = _rowKeyToIndex[rowKey];
            if (rowIndex != null) {
              final height = _calculateRowHeight(rowIndex);
              if (height != null) {
                heights.add(height);
                totalHeight += height;
              } else {
                heights.add(widget.theme.rowHeight);
                totalHeight += widget.theme.rowHeight;
              }
            } else {
              heights.add(widget.theme.rowHeight);
              totalHeight += widget.theme.rowHeight;
            }
          }

          // Add summary row height if expandable and expanded
          if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
            heights.add(widget.theme.rowHeight);
            totalHeight += widget.theme.rowHeight;
          }

          individualHeights = heights;
          mergedHeight = totalHeight;
        }

        // Check if last row using cached index lookup
        final lastRowKey = mergeGroup.rowKeys.last;
        final lastRowIndex = _rowKeyToIndex[lastRowKey];
        final isLastRow = lastRowIndex == widget.data.length - 1;

        return TablePlusMergedRow(
          mergeGroup: mergeGroup,
          allData: widget.data,
          columns: widget.columns,
          columnWidths: widget.columnWidths,
          theme: widget.theme,
          backgroundColor: _getRowColor(renderIndex, isSelected, isDimmed),
          isLastRow: isLastRow,
          isSelectable: widget.isSelectable,
          selectionMode: widget.selectionMode,
          isSelected: isSelected,
          checkboxTheme: widget.checkboxTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
          onCheckboxChanged: _handleCheckboxToggle,
          isEditable: widget.isEditable,
          editableTheme: widget.editableTheme,
          tooltipTheme: widget.tooltipTheme,
          rowIdKey: widget.rowIdKey,
          isCellEditing: widget.isCellEditing,
          getCellController: widget.getCellController,
          onCellTap: widget.onCellTap,
          onStopEditing: widget.onStopEditing,
          onRowDoubleTap: widget.onRowDoubleTap,
          onRowSecondaryTapDown: widget.onRowSecondaryTapDown,
          onMergedCellChanged: widget.onMergedCellChanged,
          onMergedRowExpandToggle: widget.onMergedRowExpandToggle,
          calculatedHeight: mergedHeight,
          individualHeights: individualHeights,
          needsVerticalScroll: widget.needsVerticalScroll,
          hoverButtonBuilder: widget.hoverButtonBuilder,
          hoverButtonPosition: widget.hoverButtonPosition,
          hoverButtonTheme: widget.hoverButtonTheme,
          isDim: isDimmed,
        );
      }
    }

    // This is a normal row (not part of any merge group)
    final rowData = widget.data[index];
    final rowId = _getRowId(rowData);
    final isSelected = rowId != null && widget.selectedRows.contains(rowId);
    final calculatedHeight = _calculateRowHeight(index);
    final isDimmed = _isDimRow(rowData);

    return TablePlusRow(
      rowIndex: index,
      rowData: rowData,
      rowId: rowId,
      columns: widget.columns,
      columnWidths: widget.columnWidths,
      theme: widget.theme,
      backgroundColor: _getRowColor(renderIndex, isSelected, isDimmed),
      isLastRow: index == widget.data.length - 1,
      isSelectable: widget.isSelectable,
      selectionMode: widget.selectionMode,
      isSelected: isSelected,
      checkboxTheme: widget.checkboxTheme,
      onRowSelectionChanged: _handleRowSelectionToggle,
      onCheckboxChanged: _handleCheckboxToggle,
      onRowDoubleTap: widget.onRowDoubleTap,
      onRowSecondaryTapDown: widget.onRowSecondaryTapDown,
      isEditable: widget.isEditable,
      editableTheme: widget.editableTheme,
      tooltipTheme: widget.tooltipTheme,
      isCellEditing: widget.isCellEditing,
      getCellController: widget.getCellController,
      onCellTap: widget.onCellTap,
      onStopEditing: widget.onStopEditing,
      calculatedHeight: calculatedHeight,
      needsVerticalScroll: widget.needsVerticalScroll,
      hoverButtonBuilder: widget.hoverButtonBuilder,
      hoverButtonPosition: widget.hoverButtonPosition,
      hoverButtonTheme: widget.hoverButtonTheme,
      isDim: isDimmed,
    );
  }
}
