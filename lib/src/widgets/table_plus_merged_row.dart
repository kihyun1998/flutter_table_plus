import 'package:flutter/material.dart';

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
import 'cells/table_plus_cell.dart';
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
    this.memberHeights,
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
  /// Each present member's own measured height, keyed by its row key.
  ///
  /// Null when the caller supplies no `calculateRowHeight` — and then every
  /// member is `theme.rowHeight`, so dividing the total equally is correct and
  /// the layout below falls back to it. Non-null exactly when heights can
  /// differ, which is the only case the equal split got wrong (#121).
  ///
  /// Keyed rather than positional on purpose: pairing a height list against a
  /// cell list by index is correct only while the two loops skip the same keys.
  /// A map cannot silently drift out of step.
  ///
  /// The summary row is deliberately absent — it has no row key, and its height
  /// is `theme.rowHeight` by construction.
  final Map<String, double>? memberHeights;

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
  /// The row a hover button is handed for this group: its **first present
  /// member**.
  ///
  /// This read `rowKeys.first` unconditionally, so a group whose first key
  /// names a row `data` no longer holds silently lost its hover button — while
  /// `_buildStackedCells`, in this same class, already filtered to the members
  /// actually there.
  ///
  /// **First in `rowKeys` order, not the earliest by data index.** The two
  /// coincide whenever `rowKeys` is in `data` order, which is the documented
  /// shape; where they differ this follows the neighbour above rather than
  /// `TablePlusBodyState._mergedGroupAnchor`, because this widget holds no
  /// `RowLookup` and resolving data indices here would scan `allData` once per
  /// key to answer a question about which row a button represents.
  @override
  T? get hoverData {
    for (final rowKey in widget.mergeGroup.rowKeys) {
      final data = _getRowData(rowKey);
      if (data != null) return data;
    }
    return null;
  }

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

    // One cell per member that `data` actually holds. This walked `rowKeys`
    // unconditionally, so a group naming a row the caller no longer passes drew
    // an empty cell for it — and since #135 made the group's *height* count only
    // the present members, the cell count and the height it is divided into had
    // stopped agreeing. `_getRowData` returning null is the test, because that
    // is exactly what an unresolvable key produces.
    final present = [
      for (final entry in widget.mergeGroup.rowKeys.asMap().entries)
        if (_getRowData(entry.value) != null) entry,
    ];

    // The LAST cell in the column is left flexible and every earlier one gets
    // its measured height exactly. `_sizeMemberCell` says why: the group's
    // bottom border is taken out of the `Column`'s height and it sits at the
    // bottom, so the shortfall belongs to the cell next to it.
    //
    // "Which cell is last" is a property of the cell list, not a pairing of
    // heights to cells -- the heights are still addressed by row key, which is
    // the maintainer's call and is untouched here.
    final lastIsSummary = widget.mergeGroup.isExpanded;

    for (var i = 0; i < present.length; i++) {
      final rowIndex = present[i].key;
      final rowKey = present[i].value;
      final isFlexibleTail = !lastIsSummary && i == present.length - 1;
      // A summary cell, when there is one, follows the last member — so the
      // last member draws its separator and the summary does not.
      final hasFollowingCell = i < present.length - 1 || lastIsSummary;
      // The column's `width` is what a member measures its text against, which
      // is the axis the parameter it reaches is named for. It used to be the
      // group's tallest-member HEIGHT: a 200px column over a 48px group
      // measured against ~16px, so on `onlyTextOverflow` nearly every value
      // claimed overflow (#155). That tallest-member value has no reader left
      // at all now, so the derivation that produced it went with it.
      cells.add(_buildStackedRowCell(
          context,
          column,
          rowKey,
          _getRowData(rowKey),
          width,
          rowIndex,
          columnIndex,
          isFlexibleTail ? null : _memberHeight(rowKey),
          hasFollowingCell));
    }

    if (lastIsSummary) {
      cells.add(_buildSummaryRowCell(context, column, null));
    }

    return SizedBox(
      width: width,
      height: totalHeight,
      child: Column(
        children: cells,
      ),
    );
  }

  /// The height this member is drawn at, or `theme.rowHeight` when the map
  /// holds no entry for it.
  ///
  /// The fallback is not decoration. `memberHeights` is null-or-complete today
  /// -- the cell loop and the height loop skip on two different tests that #135
  /// made agree -- but if they ever drift, a missing key routed to the flexible
  /// branch would leave that member competing for a remainder that the fixed
  /// cells have already consumed: the row would not render short, it would
  /// **vanish**. That is the degradation #132/#137 named as the blocker on the
  /// by-value `rowId` compare, and `theme.rowHeight` is exactly what the body's
  /// own height loop substitutes in the same situation.
  double? _memberHeight(String rowKey) => widget.memberHeights == null
      ? null
      : (widget.memberHeights![rowKey] ?? widget.theme.rowHeight);

  /// A member cell is drawn at its own measured height; the **last** cell in the
  /// column is left flexible and takes what remains.
  ///
  /// `Expanded` is `Flexible(fit: FlexFit.tight)`, and a tight flex child is
  /// forced to the extent the division allocated -- `rendering/flex.dart`:
  /// `FlexFit.tight => minChildExtent = maxChildExtent`. Every member carried
  /// `flex: 1`, so the measured heights were computed, passed down, and had no
  /// effect: a 48/96/48 group drew three 64px members inside a correct 192px
  /// total (#121).
  ///
  /// **Why only the last cell is flexible.** The group's `Container` carries the
  /// row's bottom border in its `decoration`, and a `BoxDecoration` border
  /// consumes the child's space, so the `Column` receives the group's height
  /// *minus* `dividerThickness`. Fixed extents for every cell overflow by
  /// exactly that -- measured, 1.00px at the default.
  ///
  /// Spreading that shortfall proportionally was written first and is worse,
  /// which was measured rather than argued: it moves **every** member off the
  /// position its ungrouped twin occupies, by an amount that grows with
  /// `dividerThickness` and with the member's position. At `dividerThickness: 4`
  /// the third member of a 48/96/48 group lands 2.0px high. And the error is
  /// silent -- no overflow banner -- so the only thing that could have caught it
  /// was a test tolerance, which happened to equal the default thickness.
  ///
  /// The border sits at the bottom of the group, so the cell next to it absorbs
  /// it and every other member lands exactly where its ungrouped twin does.
  Widget _sizeMemberCell(Widget child, double? height) => height != null
      ? SizedBox(height: height, child: child)
      : Expanded(child: child);

  /// Build a single stacked row cell.
  ///
  /// A member of a merged group is an ordinary row for every purpose except
  /// that it has no row of its own, so it is drawn by the ordinary cell rather
  /// than by a second copy of it. That copy had drifted one decision at a time
  /// — it measured text overflow against a *height*, hardcoded two divider
  /// widths the theme owns, anchored a widget tooltip to the bare `Text` rather
  /// than to the cell, and kept a fifth inline copy of `editKeyAction` (#155).
  ///
  /// The one thing a member needs that a plain row's cell does not is a line
  /// beneath it: a member is not a row, so no row decoration reaches between
  /// two of them. That is [TablePlusCell.bottomSide], and it is the whole of
  /// the difference.
  ///
  /// **The gate on that side asks about this cell, not about the group.** It
  /// used to ask `shouldShowBottomBorder` — whether the *group* is the table's
  /// last row — and apply the answer to every member's line, which #155 named
  /// as a level error and carried unchanged because repairing it widened a
  /// change sized for the cell into one about what the row assembles. #157 was
  /// that change. See [_memberBottomSide] for the rule that replaced it and for
  /// the two opposite symptoms the substitution produced.
  Widget _buildStackedRowCell(
      BuildContext context,
      TablePlusColumn<T> column,
      String rowKey,
      T? rowData,
      double? width,
      int rowIndex,
      int columnIndex,
      double? memberHeight,
      bool hasFollowingCell) {
    final isCellEditable = widget.isEditable && column.editable;
    final originalIndex =
        widget.allData.indexWhere((row) => widget.rowId(row) == rowKey);
    final isCurrentlyEditing = isCellEditable &&
        originalIndex != -1 &&
        widget.isCellEditing?.call(originalIndex, column.key) == true;

    // `_buildStackedCells` filtered to the members `data` actually holds, so
    // this is unreachable; it exists for the type. It draws nothing rather than
    // composing a border, because a third copy of that composition inside the
    // change that exists to remove copies is the shape both adversarial passes
    // reached independently — and an unreachable copy is the worst kind, since
    // nothing can ever show it has drifted.
    if (rowData == null) {
      return _sizeMemberCell(SizedBox(width: width), memberHeight);
    }

    return _sizeMemberCell(
      TablePlusCell<T>(
        rowIndex: originalIndex,
        column: column,
        rowData: rowData,
        width: width ?? column.width,
        theme: widget.theme,
        isEditable: widget.isEditable,
        editableTheme: widget.editableTheme,
        tooltipTheme: widget.tooltipTheme,
        isCellEditing: isCurrentlyEditing,
        isSelected: widget.isSelected,
        isDim: widget.isDim,
        calculatedHeight: memberHeight,
        cellController:
            widget.getCellController?.call(originalIndex, column.key),
        onCellTap: (isCellEditable && widget.onCellTap != null)
            ? () => widget.onCellTap!(originalIndex, column.key)
            : null,
        onStopEditing: widget.onStopEditing,
        bottomSide: _memberBottomSide(hasFollowingCell: hasFollowingCell),
      ),
      memberHeight,
    );
  }

  /// The separator this cell draws beneath itself, or null when none is wanted.
  ///
  /// **Every boundary has exactly one owner, and that is the whole rule.** A
  /// group's *inner* boundaries belong to its members; its *outer* boundary
  /// belongs to the group's own [rowDecoration]. So a cell draws only when
  /// another cell follows it inside the group, and the last one leaves the edge
  /// to the decoration.
  ///
  /// **It deliberately does not ask [TablePlusBodyTheme.shouldShowBottomBorder]**,
  /// which answers a question about the *group* — is it the table's last row.
  /// Applying that answer to a member-level line was the level error #157 fixed,
  /// and one substitution produced two opposite symptoms: with the group not
  /// last the predicate returned true for every member including the last, whose
  /// line then stacked against the group's own border and drew the edge twice;
  /// with the group last the default `LastRowBorderBehavior.never` returned false
  /// for *every* member and the group rendered as one undivided block.
  ///
  /// `showHorizontalDividers` is still honoured, and is read here rather than
  /// inside [TablePlusBodyTheme.memberDividerSide]: a condition checked in two
  /// places is one no test can pin, because mutating away either half leaves the
  /// other covering for it — measured on the pass that tried.
  ///
  /// Single-homed across the member cell and the summary cell, which is what
  /// stops them drifting. The summary cell was not a caller when this was first
  /// written, and that omission left a hardcoded line against the members'
  /// themed one in the same column.
  BorderSide? _memberBottomSide({required bool hasFollowingCell}) =>
      widget.theme.showHorizontalDividers && hasFollowingCell
          ? widget.theme.memberDividerSide
          : null;

  /// Build a summary row cell.
  Widget _buildSummaryRowCell(
      BuildContext context, TablePlusColumn<T> column, double? memberHeight) {
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

    return _sizeMemberCell(
      Container(
        decoration: BoxDecoration(
          color: widget.theme.summaryRowBackgroundColor ??
              widget.theme.backgroundColor.withValues(alpha: 0.2),
          // Two of these three sides read the theme because the member cells
          // beside them now do. Leaving them as literals is what made the
          // members 0.5 and this cell 1.0 in the same column — a visible step
          // in the vertical rule at every expanded group's summary boundary,
          // introduced by the change that fixed the members. Both adversarial
          // passes reached it independently.
          //
          // `top` is gone, and its absence is the rule rather than an
          // omission. The boundary above this cell is the last member's, and
          // that member owns it — drawing here as well is what made the
          // boundary 4px + 0.5px at `dividerThickness: 4` where every other
          // member boundary drew 4px. It was hardcoded *and* ungated on top of
          // that, ignoring `showHorizontalDividers` where every other
          // horizontal side honours it (#157).
          //
          // `bottom` asks the same question every cell asks and gets `null`:
          // nothing follows a summary cell, so the group's outer edge belongs
          // to [rowDecoration]. Written as the call rather than as a literal
          // `none` so the rule has one home and not two.
          border: Border(
            right: widget.theme.verticalDividerSide,
            bottom:
                _memberBottomSide(hasFollowingCell: false) ?? BorderSide.none,
          ),
        ),
        child: content,
      ),
      memberHeight,
    );
  }

  /// How much of the spanning cell's declared width its own decoration takes
  /// away from the child.
  ///
  /// Read off the border rather than re-deriving its thickness, so the
  /// divider's width lives in one place and a change to it follows here.
  double _spanningDecorationInset(BuildContext context) =>
      BoxDecoration(border: widget.theme.verticalDividerBorder)
          .padding
          .resolve(Directionality.maybeOf(context) ?? TextDirection.ltr)
          .horizontal;

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
        // The spanning cell's box carries `verticalDividerBorder`, and a
        // Container folds a border's dimensions into the child's inset. #155
        // routed the *members* through the ordinary cell; this branch kept its
        // own copy of the measurement, so it needs its own subtraction.
        maxWidth: maxWidth -
            widget.theme.padding.horizontal -
            _spanningDecorationInset(context),
        style:
            widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
        textAlign: column.textAlign,
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
    // Gate on the COLUMN, exactly as the plain row does — not on
    // `isSelectable`. The selection column is injected only when
    // `isSelectable && checkboxTheme.showCheckboxColumn`, and
    // `showCheckboxColumn: false` is a documented, supported setting: "rows can
    // only be selected by tapping on the row itself".
    //
    // Gating on `isSelectable` alone built a cell no other row had, and sized
    // it from `columns.first` — which, with no selection column injected, is
    // the first DATA column. So the group was displaced by a whole column
    // rather than by a checkbox. Measured 2026-09-03, one 200px column in a
    // 600px viewport: a plain row's text at x=16, the group's at x=616. Off
    // the viewport entirely, so the group rendered blank (#155).
    final index =
        widget.columns.indexWhere((col) => col.key == '__selection__');
    if (index == -1) return null;

    final width = widget.columnWidths.widthAt(index, widget.columns[index]);
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
                      style: widget.theme.effectiveMergedRowCountTextStyle,
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
          if (_buildSelectionCell() case final selectionCell?) selectionCell,
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
