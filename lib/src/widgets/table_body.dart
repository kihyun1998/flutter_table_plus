import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import '../utils/text_height_calculator.dart';
import '../utils/text_overflow_detector.dart';
import 'custom_ink_well.dart';
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
    this.rowHeightMode = RowHeightMode.uniform,
    this.minRowHeight = 48.0,
    this.onRowHeightsCalculated,
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
  final TablePlusSelectionTheme selectionTheme;

  /// Callback when a row's selection state changes.
  final void Function(String rowId, bool isSelected)? onRowSelectionChanged;

  /// Callback when a row is double-tapped.
  final void Function(String rowId)? onRowDoubleTap;

  /// Callback when a row is right-clicked (or long-pressed on touch devices).
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

  /// The row height calculation mode for the table.
  final RowHeightMode rowHeightMode;

  /// The minimum height for table rows.
  final double minRowHeight;

  /// Callback when row heights are calculated for dynamic height mode.
  final void Function(Map<int, double> heights)? onRowHeightsCalculated;

  /// Check if dynamic heights should be calculated based on TextOverflow.visible columns.
  bool _shouldCalculateDynamicHeights() {
    return TextHeightCalculator.hasVisibleOverflowColumns(
      {for (int i = 0; i < columns.length; i++) columns[i].key: columns[i]},
    );
  }

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

  /// Handle row selection toggle.
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

  /// Handle selection toggle for merged groups.
  void _handleMergedGroupSelectionToggle(
      MergedRowGroup mergeGroup, bool isCurrentlySelected) {
    if (selectionMode == SelectionMode.single) {
      if (!isCurrentlySelected) {
        // Select the entire merged group
        onRowSelectionChanged!(mergeGroup.groupId, true);
      } else {
        // Deselect the merged group
        onRowSelectionChanged!(mergeGroup.groupId, false);
      }
    } else {
      // For multiple selection mode, toggle the entire merged group
      onRowSelectionChanged!(mergeGroup.groupId, !isCurrentlySelected);
    }
  }

  /// Handle selection toggle for regular rows.
  void _handleRegularRowSelectionToggle(
      String rowId, bool isCurrentlySelected) {
    if (selectionMode == SelectionMode.single) {
      // For single selection mode, always try to select the row
      // The parent widget should handle clearing other selections
      if (!isCurrentlySelected) {
        onRowSelectionChanged!(rowId, true);
      } else {
        // Allow deselecting in single mode
        onRowSelectionChanged!(rowId, false);
      }
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

    // Calculate row heights if needed (considering merged groups)
    final Map<int, double> rowHeights = _shouldCalculateDynamicHeights()
        ? TextHeightCalculator.calculateMergedRowHeights(
            data: data,
            columns: {
              for (int i = 0; i < columns.length; i++)
                columns[i].key: columns[i]
            },
            mergedGroups: mergedGroups,
            bodyTextStyle: theme.textStyle,
            bodyPadding: theme.padding,
            mode: rowHeightMode,
            rowIdKey: rowIdKey,
            minRowHeight: minRowHeight,
          )
        : {};

    // Notify parent about calculated heights
    if (onRowHeightsCalculated != null && rowHeights.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onRowHeightsCalculated!(rowHeights);
      });
    }

    final renderableIndices = _getRenderableIndices();

    return ListView.builder(
      controller: verticalController,
      physics: const ClampingScrollPhysics(),
      itemCount: renderableIndices.length,
      itemBuilder: (context, index) {
        final actualIndex = renderableIndices[index];
        return _buildRowWidget(
            actualIndex, rowHeights, index); // Pass rendering index
      },
    );
  }

  /// Build a row widget for the given index.
  /// This method can be overridden or extended to support different row types.
  /// [index] - Original data index
  /// [rowHeights] - Calculated row heights
  /// [renderIndex] - Rendering order index (for alternateRowColor)
  TablePlusRowWidget _buildRowWidget(
      int index, Map<int, double> rowHeights, int renderIndex) {
    // Check if this index is part of a merged group
    final mergeGroup = _getMergedGroupForRow(index);

    if (mergeGroup != null) {
      final firstRowKey = mergeGroup.rowKeys.first;
      final firstRowIndex =
          data.indexWhere((row) => row[rowIdKey]?.toString() == firstRowKey);
      if (firstRowIndex == index) {
        // This is the first row in a merge group - create a merged row
        final isSelected = selectedRows.contains(mergeGroup.groupId);

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
          selectionTheme: selectionTheme,
          onRowSelectionChanged: _handleRowSelectionToggle,
          isEditable: isEditable,
          editableTheme: editableTheme,
          tooltipTheme: tooltipTheme,
          rowIdKey: rowIdKey,
          isCellEditing: isCellEditing,
          getCellController: getCellController,
          onCellTap: onCellTap,
          onStopEditing: onStopEditing,
          onRowDoubleTap: onRowDoubleTap,
          onRowSecondaryTap: onRowSecondaryTap,
          onMergedCellChanged: onMergedCellChanged,
          calculatedHeight: rowHeights.isNotEmpty ? rowHeights[index] : null,
        );
      }
    }

    // This is a normal row (not part of any merge group)
    final rowData = data[index];
    final rowId = _getRowId(rowData);
    final isSelected = rowId != null && selectedRows.contains(rowId);

    return _TablePlusRow(
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
      selectionTheme: selectionTheme,
      onRowSelectionChanged: _handleRowSelectionToggle,
      onRowDoubleTap: onRowDoubleTap,
      onRowSecondaryTap: onRowSecondaryTap,
      isEditable: isEditable,
      editableTheme: editableTheme,
      tooltipTheme: tooltipTheme,
      isCellEditing: isCellEditing,
      getCellController: getCellController,
      onCellTap: onCellTap,
      onStopEditing: onStopEditing,
      calculatedHeight: rowHeights.isNotEmpty ? rowHeights[index] : null,
    );
  }
}

/// A single table row widget.
class _TablePlusRow extends TablePlusRowWidget {
  const _TablePlusRow({
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

  // Implementation of TablePlusRowWidget abstract methods
  @override
  int get effectiveRowCount => 1;

  @override
  List<int> get originalDataIndices => [rowIndex];

  /// Handle row tap for selection.
  /// Only works when not in editable mode.
  void _handleRowTap() {
    if (isEditable) return; // No row selection in editable mode
    if (!isSelectable || rowId == null) return;

    if (selectionMode == SelectionMode.single) {
      // For single selection mode, always select this row
      // The parent should handle clearing other selections
      if (!isSelected) {
        onRowSelectionChanged(rowId!);
      }
    } else {
      // For multiple selection mode, toggle the selection
      onRowSelectionChanged(rowId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget rowContent = Container(
      height: calculatedHeight ?? theme.rowHeight,
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
              calculatedHeight: calculatedHeight,
            );
          }

          return _TablePlusCell(
            rowIndex: rowIndex,
            column: column,
            rowData: rowData,
            width: width,
            theme: theme,
            isEditable: isEditable,
            editableTheme: editableTheme,
            tooltipTheme: tooltipTheme,
            isCellEditing: isCellEditing?.call(rowIndex, column.key) ?? false,
            isSelected: isSelected,
            selectionTheme: selectionTheme,
            cellController: getCellController?.call(rowIndex, column.key),
            onCellTap: onCellTap != null
                ? () => onCellTap!(rowIndex, column.key)
                : null,
            onStopEditing: onStopEditing,
            calculatedHeight: calculatedHeight,
          );
        }),
      ),
    );

    // Wrap with CustomInkWell for row selection if selectable and not editable
    if (isSelectable && !isEditable && rowId != null) {
      return CustomInkWell(
        key: ValueKey(rowId),
        onTap: _handleRowTap,
        onDoubleTap: () {
          onRowDoubleTap?.call(rowId!); // Pass rowId to the callback
        },
        onSecondaryTap: () {
          onRowSecondaryTap?.call(rowId!); // Pass rowId to the callback
        },
        backgroundColor: backgroundColor,
        hoverColor:
            selectionTheme.getEffectiveHoverColor(isSelected, backgroundColor),
        splashColor:
            selectionTheme.getEffectiveSplashColor(isSelected, backgroundColor),
        highlightColor: selectionTheme.getEffectiveHighlightColor(
            isSelected, backgroundColor),
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
