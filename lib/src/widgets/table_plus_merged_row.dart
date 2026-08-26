import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_table_plus.dart' show HoverButtonPosition;
import '../models/merged_row_group.dart';
import '../models/table_column.dart';
import '../models/theme/body_theme.dart' show TablePlusBodyTheme;
import '../models/theme/checkbox_theme.dart';
import '../models/theme/editable_theme.dart' show TablePlusEditableTheme;
import '../models/theme/hover_button_theme.dart' show TablePlusHoverButtonTheme;
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../utils/column_width_access.dart';
import '../utils/edit_key_action.dart';
import '../utils/tooltip_resolver.dart';
import 'row_decoration.dart';
import '../utils/text_overflow_detector.dart';
import 'cells/editable_text_field.dart';
import 'tooltip_wrapper.dart';
import 'table_plus_row_widget.dart';

/// A merged table row widget that combines multiple data rows into one visual row.
class TablePlusMergedRow<T> extends TablePlusRowWidget<T> {
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
    required this.onRowSelectionChanged,
    this.onCheckboxChanged,
    required this.isEditable,
    required this.editableTheme,
    required this.tooltipTheme,
    required this.rowId,
    this.isCellEditing,
    this.getCellController,
    this.onCellTap,
    this.onStopEditing,
    this.onRowDoubleTap,
    this.onRowSecondaryTapDown,
    this.onMergedCellChanged,
    this.calculatedHeight,
    this.individualHeights,
    this.needsVerticalScroll = false,
    this.hoverButtonBuilder,
    this.hoverButtonPosition = HoverButtonPosition.right,
    this.hoverButtonTheme,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
    this.isDim = false,
  });

  @override
  State<TablePlusMergedRow<T>> createState() => _TablePlusMergedRowState<T>();

  final MergedRowGroup<T> mergeGroup;
  final List<T> allData;
  final List<TablePlusColumn<T>> columns;
  final List<double> columnWidths;
  @override
  final TablePlusBodyTheme theme;
  final String Function(T) rowId;
  @override
  final Color backgroundColor;
  @override
  final bool isLastRow;
  @override
  final bool isSelectable;
  final SelectionMode selectionMode;
  @override
  final bool isSelected;
  @override
  final void Function(String rowId) onRowSelectionChanged;
  final void Function(String rowId)? onCheckboxChanged;
  @override
  final bool isEditable;
  final TablePlusEditableTheme editableTheme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool Function(int rowIndex, String columnKey)? isCellEditing;
  final TextEditingController? Function(int rowIndex, String columnKey)?
      getCellController;
  final void Function(int rowIndex, String columnKey)? onCellTap;
  final void Function({required bool save})? onStopEditing;
  @override
  final void Function(String rowId)? onRowDoubleTap;
  @override
  final void Function(String rowId, TapDownDetails details, RenderBox renderBox,
      bool isSelected)? onRowSecondaryTapDown;
  final void Function(String groupId, String columnKey, dynamic newValue)?
      onMergedCellChanged;
  @override
  final double? calculatedHeight;

  /// Individual heights for each row in the merge group.
  final List<double>? individualHeights;

  /// Whether the table needs vertical scrolling.
  final bool needsVerticalScroll;

  /// Builder function for creating custom hover buttons.
  @override
  final Widget? Function(String rowId, T rowData)? hoverButtonBuilder;

  /// The position where hover buttons should be displayed.
  @override
  final HoverButtonPosition hoverButtonPosition;

  /// Theme configuration for hover buttons.
  @override
  final TablePlusHoverButtonTheme? hoverButtonTheme;
  final TablePlusCheckboxTheme checkboxTheme;

  /// Whether this row is a dim row.
  @override
  final bool isDim;

  // Implementation of TablePlusRowWidget abstract methods
  @override
  String? get selectionId => mergeGroup.groupId;

  @override
  int get effectiveRowCount => 1; // Visually appears as one row

  @override
  List<int> get originalDataIndices {
    // Convert rowKeys back to indices for compatibility
    return mergeGroup.rowKeys
        .map((rowKey) => allData.indexWhere((row) => rowId(row) == rowKey))
        .where((index) => index != -1)
        .toList();
  }
}

class _TablePlusMergedRowState<T>
    extends TablePlusRowStateBase<TablePlusMergedRow<T>, T> {
  @override
  T? get hoverData => _getRowData(widget.mergeGroup.rowKeys.first);

  /// Get the data for a specific row key within the merge group.
  T? _getRowData(String rowKey) {
    return widget.mergeGroup.getRowData(widget.allData, rowKey, widget.rowId);
  }

  /// Get the correct width for a column based on its key.
  double _getColumnWidth(TablePlusColumn<T> column) {
    final actualIndex =
        widget.columns.indexWhere((col) => col.key == column.key);
    return widget.columnWidths.widthAt(actualIndex, column);
  }

  /// Handle merged cell value change.
  void _handleMergedCellValueChange(
      String columnKey, int dataIndex, String? newValue) {
    if (widget.onMergedCellChanged != null &&
        widget.mergeGroup.shouldMergeColumn(columnKey)) {
      widget.onMergedCellChanged!(
          widget.mergeGroup.groupId, columnKey, newValue);
    }
  }

  /// Build a cell for the merged row.
  Widget _buildCell(
      BuildContext context, int columnIndex, TablePlusColumn<T> column) {
    final width = _getColumnWidth(column);

    if (widget.mergeGroup.shouldMergeColumn(column.key)) {
      return _buildMergedCell(context, column, width, columnIndex);
    } else {
      return _buildStackedCells(context, column, width, columnIndex);
    }
  }

  /// Build a merged cell that spans multiple rows.
  Widget _buildMergedCell(BuildContext context, TablePlusColumn<T> column,
      double? width, int columnIndex) {
    final mergedContent = widget.mergeGroup.getMergedContent(column.key);
    final spanningRowKey = widget.mergeGroup.getSpanningRowKey(column.key);
    final rowData = _getRowData(spanningRowKey);

    final mergedHeight = widget.calculatedHeight ??
        (widget.theme.rowHeight * widget.mergeGroup.effectiveRowCount);

    final isCellEditable = widget.isEditable &&
        column.editable &&
        widget.mergeGroup.isMergedCellEditable(column.key);
    final spanningDataIndex =
        widget.allData.indexWhere((row) => widget.rowId(row) == spanningRowKey);
    final isCurrentlyEditing = isCellEditable &&
        spanningDataIndex != -1 &&
        widget.isCellEditing?.call(spanningDataIndex, column.key) == true;

    Widget content;

    if (mergedContent != null) {
      content = mergedContent;
    } else if (isCurrentlyEditing) {
      content = _buildMergedCellEditingTextField(
          context, column, spanningDataIndex, rowData, mergedHeight);
    } else if (column.hasCustomCellBuilder && rowData != null) {
      // A custom cell renders no text of ours, so it can only ever carry a
      // widget tooltip — and that tooltip takes the whole cell.
      content = _wrapWithTooltip(
        context,
        Container(
          alignment: column.alignment,
          padding: widget.theme.padding,
          child: Align(
            alignment: column.alignment,
            child: column.buildCustomCell(
                context, rowData, widget.isSelected, widget.isDim),
          ),
        ),
        '',
        column,
        column.width,
        rowData,
      );
    } else {
      final displayValue = rowData != null
          ? (column.valueAccessor(rowData)?.toString() ?? '')
          : '';
      Widget textWidget = Text(
        displayValue,
        style:
            widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
        textAlign: column.textAlign,
        overflow: column.textOverflow,
      );

      textWidget = _wrapWithTooltip(context, textWidget, displayValue, column,
          width ?? column.width, rowData);

      Widget cellContent = textWidget;

      content = Container(
        alignment: column.alignment,
        padding: widget.theme.padding,
        child: cellContent,
      );
    }

    if (isCellEditable && !isCurrentlyEditing && widget.onCellTap != null) {
      content = GestureDetector(
        onTap: () => widget.onCellTap!(spanningDataIndex, column.key),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: width,
            height: mergedHeight,
            decoration: BoxDecoration(
              border: widget.theme.verticalDividerBorder,
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
          border: widget.theme.verticalDividerBorder,
        ),
        child: content,
      );
    }

    return content;
  }

  /// Build editing text field for merged cell.
  Widget _buildMergedCellEditingTextField(
    BuildContext context,
    TablePlusColumn<T> column,
    int dataIndex,
    T? rowData,
    double mergedHeight,
  ) {
    final controller = widget.getCellController?.call(dataIndex, column.key);
    final theme = widget.editableTheme;

    return Container(
      width: double.infinity,
      height: mergedHeight,
      padding: theme.cellContainerPadding,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _handleMergedCellValueChange(
                column.key, dataIndex, controller?.text);
            widget.onStopEditing?.call(save: true);
          }
        },
        child: EditableTextField(
          column: column,
          theme: theme,
          controller: controller,
          autofocus: true,
          alignment: column.alignment,
          onKeyEvent: (event) {
            switch (editKeyAction(event)) {
              case EditKeyAction.save:
                _handleMergedCellValueChange(
                    column.key, dataIndex, controller?.text);
                widget.onStopEditing?.call(save: true);
                return true;
              case EditKeyAction.cancel:
                widget.onStopEditing?.call(save: false);
                return true;
              case EditKeyAction.none:
                return false;
            }
          },
          onStopEditing: null,
        ),
      ),
    );
  }

  /// Build stacked cells for non-merged columns.
  Widget _buildStackedCells(BuildContext context, TablePlusColumn<T> column,
      double? width, int columnIndex) {
    final totalHeight = widget.calculatedHeight ??
        (widget.theme.rowHeight * widget.mergeGroup.effectiveRowCount);

    final List<Widget> cells = [];

    final maxHeight =
        widget.individualHeights?.reduce((a, b) => a > b ? a : b) ??
            widget.theme.rowHeight;

    for (final entry in widget.mergeGroup.rowKeys.asMap().entries) {
      final rowIndex = entry.key;
      final rowKey = entry.value;
      final rowData = _getRowData(rowKey);
      cells.add(_buildStackedRowCell(
          context, column, rowKey, rowData, maxHeight, rowIndex, columnIndex));
    }

    if (widget.mergeGroup.isExpanded) {
      cells.add(_buildSummaryRowCell(context, column, maxHeight));
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
      TablePlusColumn<T> column,
      String rowKey,
      T? rowData,
      double groupHeight,
      int rowIndex,
      int columnIndex) {
    final isCellEditable = widget.isEditable && column.editable;
    final originalIndex =
        widget.allData.indexWhere((row) => widget.rowId(row) == rowKey);
    final isCurrentlyEditing = isCellEditable &&
        originalIndex != -1 &&
        widget.isCellEditing?.call(originalIndex, column.key) == true;

    Widget content;

    if (isCurrentlyEditing) {
      content = _buildStackedCellEditingTextField(
          context, column, originalIndex, rowData, groupHeight);
    } else if (column.hasCustomCellBuilder && rowData != null) {
      // A custom cell renders no text of ours, so it can only ever carry a
      // widget tooltip — and that tooltip takes the whole cell.
      content = _wrapWithTooltip(
        context,
        Container(
          alignment: column.alignment,
          padding: widget.theme.padding,
          child: Align(
            alignment: column.alignment,
            child: column.buildCustomCell(
                context, rowData, widget.isSelected, widget.isDim),
          ),
        ),
        '',
        column,
        column.width,
        rowData,
      );
    } else {
      final displayValue = rowData != null
          ? (column.valueAccessor(rowData)?.toString() ?? '')
          : '';
      Widget textWidget = Text(
        displayValue,
        style:
            widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
        textAlign: column.textAlign,
        overflow: column.textOverflow,
      );

      textWidget = _wrapWithTooltip(
          context, textWidget, displayValue, column, groupHeight, rowData);

      Widget cellContent = textWidget;

      content = Container(
        alignment: column.alignment,
        padding: widget.theme.padding,
        child: cellContent,
      );
    }

    Widget cellContainer = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: widget.theme.showVerticalDividers
                ? BorderSide(
                    color: widget.theme.dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : BorderSide.none,
            bottom: widget.theme.shouldShowBottomBorder(
                    isLastRow: widget.isLastRow,
                    needsVerticalScroll: widget.needsVerticalScroll)
                ? BorderSide(
                    color: widget.theme.dividerColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );

    if (isCellEditable && !isCurrentlyEditing && widget.onCellTap != null) {
      cellContainer = Expanded(
        child: GestureDetector(
          onTap: () => widget.onCellTap!(originalIndex, column.key),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: widget.theme.showVerticalDividers
                      ? BorderSide(
                          color:
                              widget.theme.dividerColor.withValues(alpha: 0.5),
                          width: 1,
                        )
                      : BorderSide.none,
                  bottom: widget.theme.shouldShowBottomBorder(
                          isLastRow: widget.isLastRow,
                          needsVerticalScroll: widget.needsVerticalScroll)
                      ? BorderSide(
                          color:
                              widget.theme.dividerColor.withValues(alpha: 0.3),
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
      BuildContext context, TablePlusColumn<T> column, double groupHeight) {
    Widget content;

    final summaryWidget = widget.mergeGroup.summaryBuilder?.call(column.key);
    if (summaryWidget != null) {
      content = Container(
        alignment: column.alignment,
        padding: widget.theme.padding,
        child: summaryWidget,
      );
    } else {
      content = Container(
        alignment: column.alignment,
        padding: widget.theme.padding,
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.summaryRowBackgroundColor ??
              widget.theme.backgroundColor.withValues(alpha: 0.2),
          border: Border(
            right: widget.theme.showVerticalDividers
                ? BorderSide(
                    color: widget.theme.dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                : BorderSide.none,
            top: BorderSide(
              color: widget.theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
            bottom: widget.theme.shouldShowBottomBorder(
                    isLastRow: widget.isLastRow,
                    needsVerticalScroll: widget.needsVerticalScroll)
                ? BorderSide(
                    color: widget.theme.dividerColor.withValues(alpha: 0.3),
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
    TablePlusColumn<T> column,
    int dataIndex,
    T? rowData,
    double cellHeight,
  ) {
    final controller = widget.getCellController?.call(dataIndex, column.key);
    final theme = widget.editableTheme;

    return Container(
      width: double.infinity,
      height: cellHeight,
      padding: theme.cellContainerPadding,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            widget.onStopEditing?.call(save: true);
          }
        },
        child: EditableTextField(
          column: column,
          theme: theme,
          controller: controller,
          autofocus: true,
          alignment: column.alignment,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                widget.onStopEditing?.call(save: true);
                return true;
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                widget.onStopEditing?.call(save: false);
                return true;
              }
            }
            return false;
          },
          onStopEditing: null,
        ),
      ),
    );
  }

  /// Determines whether a tooltip should be shown.
  bool _shouldShowTooltip(
      String displayValue, TablePlusColumn<T> column, double maxWidth) {
    if (!widget.tooltipTheme.enabled) return false;
    return TooltipResolver.shouldShow(
      behavior: column.tooltipBehavior,
      hasWidgetTooltip: column.tooltipBuilder != null,
      isEllipsis: column.textOverflow == TextOverflow.ellipsis,
      textIsEmpty: displayValue.isEmpty,
      willOverflow: () => TextOverflowDetector.willTextOverflowInContext(
        context: context,
        text: displayValue,
        maxWidth: maxWidth - widget.theme.padding.horizontal,
        style:
            widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
      ),
    );
  }

  /// Wraps a text widget with tooltip if needed.
  Widget _wrapWithTooltip(
    BuildContext context,
    Widget textWidget,
    String displayValue,
    TablePlusColumn<T> column,
    double maxWidth,
    T? rowData,
  ) {
    return wrapWithTooltip<T>(
      shouldShow: _shouldShowTooltip(displayValue, column, maxWidth),
      child: textWidget,
      theme: widget.tooltipTheme,
      tooltipBuilder: column.tooltipBuilder,
      tooltipFormatter: column.tooltipFormatter,
      rowData: rowData,
      fallbackMessage: displayValue,
    );
  }

  /// Build selection cell for merged row.
  Widget? _buildSelectionCell() {
    if (!widget.isSelectable) return null;

    // The selection column is injected at index 0 when selectable.
    final width = widget.columnWidths.widthAt(0, widget.columns.first);
    final mergedHeight = widget.calculatedHeight ??
        (widget.theme.rowHeight * widget.mergeGroup.effectiveRowCount);

    return Container(
      width: width,
      height: mergedHeight,
      decoration: BoxDecoration(
        border: widget.theme.verticalDividerBorder,
      ),
      child: widget.checkboxTheme.showRowCheckbox
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.checkboxTheme.buildCheckbox(
                    value: widget.isSelected,
                    onChanged: (value) => (widget.onCheckboxChanged ??
                        widget
                            .onRowSelectionChanged)(widget.mergeGroup.groupId),
                  ),
                  if (widget.mergeGroup.rowCount > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.mergeGroup.rowCount} rows',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget buildRowContent(BuildContext context) {
    final mergedHeight = widget.calculatedHeight ??
        (widget.theme.rowHeight * widget.mergeGroup.effectiveRowCount);

    return Container(
      height: mergedHeight,
      decoration: rowDecoration(
        selectionTransparent: widget.enableSelectionInk,
        backgroundColor: widget.backgroundColor,
        theme: widget.theme,
        isLastRow: widget.isLastRow,
        needsVerticalScroll: widget.needsVerticalScroll,
      ),
      child: Row(
        children: [
          if (widget.isSelectable) _buildSelectionCell()!,
          ...() {
            final nonSelectionColumns = widget.columns
                .where((col) => col.key != '__selection__')
                .toList();
            return List.generate(
              nonSelectionColumns.length,
              (index) {
                final column = nonSelectionColumns[index];
                return _buildCell(context, index, column);
              },
            );
          }(),
        ],
      ),
    );
  }
}
