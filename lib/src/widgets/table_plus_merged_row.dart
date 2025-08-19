import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_table_plus.dart'
    show TablePlusSelectionTheme, LastRowBorderBehavior;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import '../utils/text_overflow_detector.dart';
import 'custom_ink_well.dart';
import 'table_plus_row_widget.dart';

/// A merged table row widget that combines multiple data rows into one visual row.
class TablePlusMergedRow extends TablePlusRowWidget {
  const TablePlusMergedRow({
    super.key,
    required this.mergeGroup,
    required this.allData,
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
    required this.rowIdKey,
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onMergedCellChanged,
    this.onMergedRowExpandToggle,
    this.calculatedHeight,
    this.needsVerticalScroll = false,
  });

  final MergedRowGroup mergeGroup;
  final List<Map<String, dynamic>> allData;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  final String rowIdKey;
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
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;
  final void Function(String groupId)? onMergedRowExpandToggle;
  @override
  final double? calculatedHeight;

  /// Whether the table needs vertical scrolling.
  /// Used to determine if the last row should have a bottom border.
  final bool needsVerticalScroll;

  // Implementation of TablePlusRowWidget abstract methods
  @override
  int get effectiveRowCount => 1; // Visually appears as one row

  @override
  List<int> get originalDataIndices {
    // Convert rowKeys back to indices for compatibility
    return mergeGroup.rowKeys
        .map((rowKey) =>
            allData.indexWhere((row) => row[rowIdKey]?.toString() == rowKey))
        .where((index) => index != -1)
        .toList();
  }

  /// Handle row tap for selection.
  void _handleRowTap() {
    if (isEditable) return;
    if (!isSelectable) return;

    // For both single and multiple selection modes, toggle the selection
    onRowSelectionChanged(mergeGroup.groupId);
  }

  /// Get the data for a specific row key within the merge group.
  Map<String, dynamic>? _getRowData(String rowKey) {
    return mergeGroup.getRowData(allData, rowKey, rowIdKey);
  }

  /// Determines whether to show a bottom border for the merged row.
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
        return !needsVerticalScroll;
    }
  }

  /// Handle merged cell value change.
  void _handleMergedCellValueChange(
      String columnKey, int dataIndex, String? newValue) {
    if (onMergedCellChanged != null &&
        mergeGroup.shouldMergeColumn(columnKey)) {
      onMergedCellChanged!(mergeGroup.groupId, columnKey, newValue);
    }
  }

  /// Build a cell for the merged row.
  Widget _buildCell(
      BuildContext context, int columnIndex, TablePlusColumn column) {
    final width =
        columnWidths.isNotEmpty ? columnWidths[columnIndex] : column.width;

    // Check if this column should be merged
    if (mergeGroup.shouldMergeColumn(column.key)) {
      return _buildMergedCell(context, column, width, columnIndex);
    } else {
      return _buildStackedCells(context, column, width, columnIndex);
    }
  }

  /// Build a merged cell that spans multiple rows.
  Widget _buildMergedCell(BuildContext context, TablePlusColumn column,
      double? width, int columnIndex) {
    final mergedContent = mergeGroup.getMergedContent(column.key);
    final spanningRowKey = mergeGroup.getSpanningRowKey(column.key);
    final rowData = _getRowData(spanningRowKey);

    // Calculate height for merged cell
    // calculatedHeight already considers merged group heights, so we use it directly for the total group height
    final groupHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = groupHeight * mergeGroup.effectiveRowCount;

    // Check if this merged cell is editable
    final isCellEditable = isEditable &&
        column.editable &&
        mergeGroup.isMergedCellEditable(column.key);
    final spanningDataIndex = allData
        .indexWhere((row) => row[rowIdKey]?.toString() == spanningRowKey);
    final isCurrentlyEditing = isCellEditable &&
        spanningDataIndex != -1 &&
        isCellEditing?.call(spanningDataIndex, column.key) == true;

    Widget content;

    if (mergedContent != null) {
      // Custom merged content - not editable
      content = mergedContent;
    } else if (isCurrentlyEditing) {
      // Editing mode for merged cell
      content = _buildMergedCellEditingTextField(
          context, column, spanningDataIndex, rowData ?? {}, mergedHeight);
    } else if (column.cellBuilder != null) {
      // Custom cell builder
      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: Align(
          alignment: column.alignment,
          child: column.cellBuilder!(context, rowData ?? {}),
        ),
      );
    } else {
      // Default text content
      final displayValue = (rowData ?? {})[column.key]?.toString() ?? '';
      Widget textWidget = Text(
        displayValue,
        style: selectionTheme.getEffectiveTextStyle(
          isSelected,
          theme.textStyle,
        ),
        textAlign: column.textAlign,
        overflow: column.textOverflow,
      );

      // Wrap with tooltip if needed
      textWidget = _wrapWithTooltip(
          textWidget, displayValue, column, width ?? column.width);

      // Add expand/collapse icon if this is the first merged column and expandable
      Widget cellContent = textWidget;
      if (mergeGroup.isExpandable && columnIndex == 0) {
        cellContent = Row(
          children: [
            GestureDetector(
              onTap: () => onMergedRowExpandToggle?.call(mergeGroup.groupId),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    mergeGroup.isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: theme.textStyle.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Expanded(child: textWidget),
          ],
        );
      }

      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: cellContent,
      );
    }

    // Wrap with gesture detector for editing if applicable
    if (isCellEditable && !isCurrentlyEditing && onCellTap != null) {
      content = GestureDetector(
        onTap: () => onCellTap!(spanningDataIndex, column.key),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: width,
            height: mergedHeight,
            decoration: BoxDecoration(
              border: theme.showVerticalDividers
                  ? Border(
                      right: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    )
                  : null,
              color: Colors.transparent,
            ),
            child: content,
          ),
        ),
      );
    } else {
      content = Container(
        width: width,
        height: mergedHeight,
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
        child: content,
      );
    }

    return content;
  }

  /// Build editing text field for merged cell.
  Widget _buildMergedCellEditingTextField(
    BuildContext context,
    TablePlusColumn column,
    int dataIndex,
    Map<String, dynamic> rowData,
    double mergedHeight,
  ) {
    final controller = getCellController?.call(dataIndex, column.key);
    final theme = editableTheme;

    return Container(
      width: double.infinity,
      height: mergedHeight,
      padding:
          theme.cellContainerPadding, // Use editable theme's container padding
      child: Align(
        alignment:
            column.alignment, // Follow column alignment like regular cells
        child: Focus(
          onFocusChange: (hasFocus) {
            // Auto-save when focus is lost (like regular cells)
            if (!hasFocus) {
              _handleMergedCellValueChange(
                  column.key, dataIndex, controller?.text);
              onStopEditing?.call(save: true);
            }
          },
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _handleMergedCellValueChange(
                      column.key, dataIndex, controller?.text);
                  onStopEditing?.call(save: true);
                } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                  onStopEditing?.call(save: false);
                }
              }
            },
            child: TextField(
              autofocus: true,
              controller: controller,
              style: theme.editingTextStyle,
              textAlign: column.textAlign,
              textAlignVertical: theme.textAlignVertical, // Use theme alignment
              cursorColor: theme.cursorColor,
              decoration: InputDecoration(
                hintText: column.hintText,
                hintStyle: theme.hintStyle,
                contentPadding: theme.textFieldPadding,
                isDense: theme.isDense,
                filled: theme.filled,
                fillColor: theme.fillColor ?? theme.editingCellColor,
                // Use the same border configuration as regular cells
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
              onSubmitted: (_) {
                _handleMergedCellValueChange(
                    column.key, dataIndex, controller?.text);
                onStopEditing?.call(save: true);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Build stacked cells for non-merged columns.
  Widget _buildStackedCells(BuildContext context, TablePlusColumn column,
      double? width, int columnIndex) {
    final groupHeight = calculatedHeight ?? theme.rowHeight;
    final totalHeight = groupHeight * mergeGroup.effectiveRowCount;

    // Build all cells including summary row
    final List<Widget> cells = [];

    // Regular row cells
    for (final entry in mergeGroup.rowKeys.asMap().entries) {
      final rowIndex = entry.key;
      final rowKey = entry.value;
      final rowData = _getRowData(rowKey);
      cells.add(_buildStackedRowCell(context, column, rowKey, rowData,
          groupHeight, rowIndex, columnIndex));
    }

    // Add summary row if expandable and expanded
    if (mergeGroup.isExpandable && mergeGroup.isExpanded) {
      cells.add(_buildSummaryRowCell(context, column, groupHeight));
    }

    return SizedBox(
      width: width,
      height: totalHeight,
      child: Column(
        children: cells,
      ),
    );
  }

  /// Build a single stacked row cell.
  Widget _buildStackedRowCell(
      BuildContext context,
      TablePlusColumn column,
      String rowKey,
      Map<String, dynamic>? rowData,
      double groupHeight,
      int rowIndex,
      int columnIndex) {
    // Check if this individual cell is editable
    final isCellEditable = isEditable && column.editable;
    final originalIndex =
        allData.indexWhere((row) => row[rowIdKey]?.toString() == rowKey);
    final isCurrentlyEditing = isCellEditable &&
        originalIndex != -1 &&
        isCellEditing?.call(originalIndex, column.key) == true;

    Widget content;

    if (isCurrentlyEditing) {
      // Editing mode for individual cell
      content = _buildStackedCellEditingTextField(
          context, column, originalIndex, rowData ?? {}, groupHeight);
    } else if (column.cellBuilder != null) {
      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: Align(
          alignment: column.alignment,
          child: column.cellBuilder!(context, rowData ?? {}),
        ),
      );
    } else {
      final displayValue = (rowData ?? {})[column.key]?.toString() ?? '';
      Widget textWidget = Text(
        displayValue,
        style: selectionTheme.getEffectiveTextStyle(
          isSelected,
          theme.textStyle,
        ),
        textAlign: column.textAlign,
        overflow: column.textOverflow,
      );

      // Wrap with tooltip if needed
      textWidget =
          _wrapWithTooltip(textWidget, displayValue, column, groupHeight);

      // Add expand/collapse icon if this is the first row and first column and expandable
      Widget cellContent = textWidget;
      if (mergeGroup.isExpandable && rowIndex == 0 && columnIndex == 0) {
        cellContent = Row(
          children: [
            GestureDetector(
              onTap: () => onMergedRowExpandToggle?.call(mergeGroup.groupId),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    mergeGroup.isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: theme.textStyle.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Expanded(child: textWidget),
          ],
        );
      }

      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: cellContent,
      );
    }

    Widget cellContainer = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: theme.showVerticalDividers
                ? BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : BorderSide.none,
            bottom: _shouldShowBottomBorder(isLastRow, theme)
                ? BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );

    // Wrap with gesture detector for editing if applicable
    if (isCellEditable && !isCurrentlyEditing && onCellTap != null) {
      cellContainer = Expanded(
        child: GestureDetector(
          onTap: () => onCellTap!(originalIndex, column.key),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: theme.showVerticalDividers
                      ? BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          width: 1,
                        )
                      : BorderSide.none,
                  bottom: _shouldShowBottomBorder(isLastRow, theme)
                      ? BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
              ),
              child: content,
            ),
          ),
        ),
      );
    }

    return cellContainer;
  }

  /// Build a summary row cell.
  Widget _buildSummaryRowCell(
      BuildContext context, TablePlusColumn column, double groupHeight) {
    Widget content;

    if (mergeGroup.hasSummaryData(column.key)) {
      final summaryData = mergeGroup.getSummaryData(column.key);
      final displayValue = summaryData?.toString() ?? '';

      Widget textWidget = Text(
        displayValue,
        style: selectionTheme.getEffectiveTextStyle(
          isSelected,
          theme.textStyle.copyWith(
            fontWeight: FontWeight.w600, // Make summary text slightly bolder
            color: theme.textStyle.color?.withValues(alpha: 0.8),
          ),
        ),
        textAlign: column.textAlign,
        overflow: column.textOverflow,
      );

      // Wrap with tooltip if needed
      textWidget =
          _wrapWithTooltip(textWidget, displayValue, column, groupHeight);

      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: textWidget,
      );
    } else {
      // Empty cell for columns without summary data
      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.summaryRowBackgroundColor ?? 
              theme.backgroundColor.withValues(alpha: 0.2), // Summary row background color
          border: Border(
            right: theme.showVerticalDividers
                ? BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : BorderSide.none,
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
            bottom: _shouldShowBottomBorder(isLastRow, theme)
                ? BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }

  /// Build editing text field for individual stacked cell.
  Widget _buildStackedCellEditingTextField(
    BuildContext context,
    TablePlusColumn column,
    int dataIndex,
    Map<String, dynamic> rowData,
    double cellHeight,
  ) {
    final controller = getCellController?.call(dataIndex, column.key);
    final theme = editableTheme;

    return Container(
      width: double.infinity,
      height: cellHeight,
      padding:
          theme.cellContainerPadding, // Use editable theme's container padding
      child: Align(
        alignment:
            column.alignment, // Follow column alignment like regular cells
        child: Focus(
          onFocusChange: (hasFocus) {
            // Auto-save when focus is lost (like regular cells)
            if (!hasFocus) {
              onStopEditing?.call(save: true);
            }
          },
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  onStopEditing?.call(save: true);
                } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                  onStopEditing?.call(save: false);
                }
              }
            },
            child: TextField(
              autofocus: true,
              controller: controller,
              style: theme.editingTextStyle,
              textAlign: column.textAlign,
              textAlignVertical: theme.textAlignVertical, // Use theme alignment
              cursorColor: theme.cursorColor,
              decoration: InputDecoration(
                hintText: column.hintText,
                hintStyle: theme.hintStyle,
                contentPadding: theme.textFieldPadding,
                isDense: theme.isDense,
                filled: theme.filled,
                fillColor: theme.fillColor ?? theme.editingCellColor,
                // Use the same border configuration as regular cells
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
              onSubmitted: (_) {
                // For stacked cells, this is a regular cell change, not a merged cell change
                onStopEditing?.call(save: true);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Determines whether a tooltip should be shown based on the column's tooltip behavior.
  bool _shouldShowTooltip(
      String displayValue, TablePlusColumn column, double maxWidth) {
    // Basic checks - tooltip must be enabled and text must not be empty
    if (!tooltipTheme.enabled || displayValue.isEmpty) {
      return false;
    }

    switch (column.tooltipBehavior) {
      case TooltipBehavior.never:
        return false;

      case TooltipBehavior.always:
        return column.textOverflow == TextOverflow.ellipsis;

      case TooltipBehavior.onOverflowOnly:
        // Only show tooltip if text overflow is ellipsis AND text actually overflows
        if (column.textOverflow != TextOverflow.ellipsis) {
          return false;
        }

        // Account for padding that might be applied to the cell content
        final cellPadding = theme.padding;
        final paddingWidth = cellPadding.horizontal;
        final maxTextWidth = maxWidth - paddingWidth;

        if (maxTextWidth <= 0) {
          return true; // If no space available, consider it overflow
        }

        // Use effective text style that considers selection state
        final effectiveTextStyle = selectionTheme.getEffectiveTextStyle(
          isSelected,
          theme.textStyle,
        );

        return TextOverflowDetector.willTextOverflow(
          text: displayValue,
          style: effectiveTextStyle,
          maxWidth: maxTextWidth,
          textAlign: column.textAlign,
        );
    }
  }

  /// Wraps a text widget with tooltip if needed.
  Widget _wrapWithTooltip(Widget textWidget, String displayValue,
      TablePlusColumn column, double maxWidth) {
    if (_shouldShowTooltip(displayValue, column, maxWidth)) {
      return Tooltip(
        message: displayValue,
        textStyle: tooltipTheme.textStyle,
        decoration: tooltipTheme.decoration,
        padding: tooltipTheme.padding,
        margin: tooltipTheme.margin,
        waitDuration: tooltipTheme.waitDuration,
        showDuration: tooltipTheme.showDuration,
        preferBelow: tooltipTheme.preferBelow,
        child: textWidget,
      );
    }
    return textWidget;
  }

  /// Build selection cell for merged row.
  Widget? _buildSelectionCell() {
    if (!isSelectable) return null;

    final width = columnWidths.isNotEmpty ? columnWidths[0] : 50.0;
    final groupHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = groupHeight * mergeGroup.effectiveRowCount;

    return Container(
      width: width,
      height: mergedHeight,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: selectionTheme.checkboxSize,
              height: selectionTheme.checkboxSize,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => onRowSelectionChanged(mergeGroup.groupId),
                activeColor: selectionTheme.checkboxColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (mergeGroup.rowCount > 1) ...[
              const SizedBox(height: 4),
              Text(
                '${mergeGroup.rowCount} rows',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = groupHeight * mergeGroup.effectiveRowCount;

    Widget rowContent = Container(
      height: mergedHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: _shouldShowBottomBorder(isLastRow, theme)
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          // Selection cell (if selectable)
          if (isSelectable) _buildSelectionCell()!,
          // Regular cells
          ...List.generate(
            columns.where((col) => col.key != '__selection__').length,
            (index) {
              final nonSelectionColumns =
                  columns.where((col) => col.key != '__selection__').toList();
              final column = nonSelectionColumns[index];
              final columnIndex = isSelectable ? index + 1 : index;
              return _buildCell(context, columnIndex, column);
            },
          ),
        ],
      ),
    );

    // Wrap with CustomInkWell for row selection if selectable and not editable
    if (isSelectable && !isEditable) {
      return CustomInkWell(
        key: ValueKey(mergeGroup.groupId),
        onTap: _handleRowTap,
        onDoubleTap: () => onRowDoubleTap?.call(mergeGroup.groupId),
        onSecondaryTap: () => onRowSecondaryTap?.call(mergeGroup.groupId),
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
