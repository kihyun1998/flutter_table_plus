import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_table_plus.dart' show TablePlusSelectionTheme;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
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
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onMergedCellChanged,
    this.calculatedHeight,
  });

  final MergedRowGroup mergeGroup;
  final List<Map<String, dynamic>> allData;
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
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;
  @override
  final double? calculatedHeight;

  // Implementation of TablePlusRowWidget abstract methods
  @override
  int get effectiveRowCount => 1; // Visually appears as one row

  @override
  List<int> get originalDataIndices => mergeGroup.originalIndices;

  /// Handle row tap for selection.
  void _handleRowTap() {
    if (isEditable) return;
    if (!isSelectable) return;

    if (selectionMode == SelectionMode.single) {
      if (!isSelected) {
        onRowSelectionChanged(mergeGroup.groupId);
      }
    } else {
      onRowSelectionChanged(mergeGroup.groupId);
    }
  }

  /// Get the data for a specific row index within the merge group.
  Map<String, dynamic> _getRowData(int originalIndex) {
    return allData[originalIndex];
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
      return _buildMergedCell(context, column, width);
    } else {
      return _buildStackedCells(context, column, width);
    }
  }

  /// Build a merged cell that spans multiple rows.
  Widget _buildMergedCell(
      BuildContext context, TablePlusColumn column, double? width) {
    final mergedContent = mergeGroup.getMergedContent(column.key);
    final spanningRowIndex = mergeGroup.getSpanningRowIndex(column.key);
    final spanningDataIndex = mergeGroup.originalIndices[spanningRowIndex];
    final rowData = _getRowData(spanningDataIndex);

    // Calculate height for merged cell (height of all merged rows combined)
    final singleRowHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = singleRowHeight * mergeGroup.rowCount;

    // Check if this merged cell is editable
    final isCellEditable = isEditable &&
        column.editable &&
        mergeGroup.isMergedCellEditable(column.key);
    final isCurrentlyEditing = isCellEditable &&
        isCellEditing?.call(spanningDataIndex, column.key) == true;

    Widget content;

    if (mergedContent != null) {
      // Custom merged content - not editable
      content = mergedContent;
    } else if (isCurrentlyEditing) {
      // Editing mode for merged cell
      content = _buildMergedCellEditingTextField(
          context, column, spanningDataIndex, rowData, mergedHeight);
    } else if (column.cellBuilder != null) {
      // Custom cell builder
      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: column.cellBuilder!(context, rowData),
      );
    } else {
      // Default text content
      content = Container(
        alignment: column.alignment,
        padding: theme.padding,
        child: Text(
          rowData[column.key]?.toString() ?? '',
          style: theme.textStyle,
          textAlign: column.textAlign,
          overflow: column.textOverflow,
        ),
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

    return SizedBox(
      width: double.infinity,
      height: mergedHeight,
      // padding: theme.padding ??
      //     const EdgeInsets.all(8), // Use theme padding like regular cells
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
  Widget _buildStackedCells(
      BuildContext context, TablePlusColumn column, double? width) {
    final singleRowHeight = calculatedHeight ?? theme.rowHeight;
    final totalHeight = singleRowHeight * mergeGroup.rowCount;

    return SizedBox(
      width: width,
      height: totalHeight,
      child: Column(
        children: mergeGroup.originalIndices.asMap().entries.map((entry) {
          final index = entry.key;
          final originalIndex = entry.value;
          final rowData = _getRowData(originalIndex);
          final isLastRow = index == mergeGroup.originalIndices.length - 1;

          // Check if this individual cell is editable
          final isCellEditable = isEditable && column.editable;
          final isCurrentlyEditing = isCellEditable &&
              isCellEditing?.call(originalIndex, column.key) == true;

          Widget content;

          if (isCurrentlyEditing) {
            // Editing mode for individual cell
            content = _buildStackedCellEditingTextField(
                context, column, originalIndex, rowData, singleRowHeight);
          } else if (column.cellBuilder != null) {
            content = Container(
              alignment: column.alignment,
              padding: theme.padding,
              child: column.cellBuilder!(context, rowData),
            );
          } else {
            content = Container(
              alignment: column.alignment,
              padding: theme.padding,
              child: Text(
                rowData[column.key]?.toString() ?? '',
                style: theme.textStyle,
                textAlign: column.textAlign,
                overflow: column.textOverflow,
              ),
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
                  bottom: !isLastRow && theme.showHorizontalDividers
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
                                color:
                                    theme.dividerColor.withValues(alpha: 0.5),
                                width: 1,
                              )
                            : BorderSide.none,
                        bottom: !isLastRow && theme.showHorizontalDividers
                            ? BorderSide(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.3),
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
        }).toList(),
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

    return SizedBox(
      width: double.infinity,
      height: cellHeight,
      // padding: theme.padding ?? EdgeInsets.all(8), // Use theme padding like regular cells
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

  /// Build selection cell for merged row.
  Widget? _buildSelectionCell() {
    if (!isSelectable) return null;

    final selectionColumn = columns.firstWhere(
      (col) => col.key == '__selection__',
      orElse: () => throw StateError('Selection column not found'),
    );
    final width = columnWidths.isNotEmpty ? columnWidths[0] : 50.0;
    final singleRowHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = singleRowHeight * mergeGroup.rowCount;

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
    final singleRowHeight = calculatedHeight ?? theme.rowHeight;
    final mergedHeight = singleRowHeight * mergeGroup.rowCount;

    Widget rowContent = Container(
      height: mergedHeight,
      decoration: BoxDecoration(
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
