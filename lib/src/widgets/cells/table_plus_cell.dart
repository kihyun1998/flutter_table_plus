import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/edit_key_action.dart';
import 'package:flutter_table_plus/src/utils/overflow_cache.dart';
import 'package:flutter_table_plus/src/utils/text_overflow_detector.dart';
import 'package:flutter_table_plus/src/utils/tooltip_resolver.dart';
import 'package:flutter_table_plus/src/widgets/cells/editable_text_field.dart';
import 'package:flutter_table_plus/src/widgets/tooltip_wrapper.dart';

/// A single table cell widget.
class TablePlusCell<T> extends StatefulWidget {
  const TablePlusCell({
    super.key,
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
    this.cellController,
    this.onCellTap,
    this.onStopEditing,
    this.calculatedHeight,
    this.isDim = false,
    this.bottomSide,
  });

  final int rowIndex;
  final TablePlusColumn<T> column;
  final T rowData;
  final double width;
  final TablePlusBodyTheme theme;
  final bool isEditable;
  final TablePlusEditableTheme editableTheme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool isCellEditing;
  final bool isSelected;
  final TextEditingController? cellController;
  final VoidCallback? onCellTap;
  final void Function({required bool save})? onStopEditing;
  final double? calculatedHeight;
  final bool isDim;

  /// An extra side this cell draws below itself, on top of the vertical
  /// divider it always draws.
  ///
  /// The caller supplies it because only the caller knows whether one is
  /// wanted: a plain row's cells need none — the row's own decoration carries
  /// the divider beneath them — while a merged group's member cells need one,
  /// because a member is not a row and no row decoration reaches between two of
  /// them. Drawing a side is this cell's mechanism; *which* sides is knowledge
  /// one level up (#155).
  final BorderSide? bottomSide;

  @override
  State<TablePlusCell<T>> createState() => _TablePlusCellState<T>();
}

class _TablePlusCellState<T> extends State<TablePlusCell<T>> {
  // Created lazily — only an editing cell needs a focus node, so non-editable
  // tables (and non-editable columns) never allocate one. That saves an object
  // + listener per visible cell as rows scroll into the viewport.
  FocusNode? _focusNode;

  // Cached overflow detection result
  final OverflowCache _overflowCache = OverflowCache();

  /// Lazily create the focus node (with its blur listener) on first use.
  FocusNode _ensureFocusNode() =>
      _focusNode ??= (FocusNode()..addListener(_onFocusChange));

  @override
  void didUpdateWidget(TablePlusCell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Focus the text field when editing starts
    if (!oldWidget.isCellEditing && widget.isCellEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureFocusNode().requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  /// Handle focus changes - stop editing when focus is lost
  void _onFocusChange() {
    final node = _focusNode;
    if (node != null && !node.hasFocus && widget.isCellEditing) {
      widget.onStopEditing?.call(save: true);
    }
  }

  /// Handle key presses in the text field
  bool _handleKeyPress(KeyEvent event) {
    switch (editKeyAction(event)) {
      case EditKeyAction.save:
        widget.onStopEditing?.call(save: true);
        return true;
      case EditKeyAction.cancel:
        widget.onStopEditing?.call(save: false);
        return true;
      case EditKeyAction.none:
        return false;
    }
  }

  /// Extract the display value for this cell.
  String _getCellDisplayValue() {
    final value = widget.column.valueAccessor(widget.rowData);
    if (value == null) return '';
    return value.toString();
  }

  /// Build the editing text field
  Widget _buildEditingTextField() {
    return EditableTextField(
      column: widget.column,
      theme: widget.editableTheme,
      controller: widget.cellController,
      focusNode: _ensureFocusNode(),
      autofocus: false, // We handle focus manually in didUpdateWidget
      alignment: widget.column.alignment,
      onStopEditing: widget.onStopEditing,
      onKeyEvent: _handleKeyPress,
    );
  }

  /// Build the regular cell content
  Widget _buildRegularCell() {
    // Use custom cell builder if provided (statefulCellBuilder takes precedence)
    final customCell = widget.column.buildCustomCell(
      context,
      widget.rowData,
      widget.isSelected,
      widget.isDim,
    );
    if (customCell != null) {
      // A custom cell renders no text of ours, so it can only ever carry a
      // widget tooltip — and that tooltip takes the whole cell.
      return _wrapWithTooltip(
        shouldShow: _shouldShowTooltip('', customCell),
        child: Align(
          alignment: widget.column.alignment,
          child: customCell,
        ),
        fallbackMessage: '',
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    Widget textWidget = Text(
      displayValue,
      style:
          widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
      overflow: widget.column.textOverflow,
      textAlign: widget.column.textAlign,
    );

    final shouldShow = _shouldShowTooltip(displayValue, textWidget);
    final hasWidgetTooltip = widget.column.tooltipBuilder != null;

    // A *text* tooltip belongs to the glyphs — you hover the truncated text to
    // read the rest of it. A *widget* tooltip has nothing to do with them, so
    // it takes the whole cell: an empty cell's Text is zero-wide, and a short
    // one leaves most of the cell unhoverable.
    if (!hasWidgetTooltip) {
      textWidget = _wrapWithTooltip(
        shouldShow: shouldShow,
        child: textWidget,
        fallbackMessage: displayValue,
      );
    }

    final aligned = Align(
      alignment: widget.column.alignment,
      child: textWidget,
    );
    if (!hasWidgetTooltip) return aligned;

    return _wrapWithTooltip(
      shouldShow: shouldShow,
      child: aligned,
      fallbackMessage: displayValue,
    );
  }

  /// The sides this cell draws: its own vertical divider, plus whatever the
  /// caller asked for below it.
  ///
  /// `null` rather than an all-[BorderStyle.none] [Border] when there is
  /// nothing to draw, because a border with no visible side still reports a
  /// [Border.dimensions] of zero *and* replaces a `null` decoration in every
  /// widget-tree assertion that looks for one. Same painted result, different
  /// thing to read back.
  BoxBorder? _composeBorder() {
    final right = widget.theme.verticalDividerSide;
    final bottom = widget.bottomSide ?? BorderSide.none;
    if (right.style == BorderStyle.none && bottom.style == BorderStyle.none) {
      return null;
    }
    return Border(right: right, bottom: bottom);
  }

  Widget _wrapWithTooltip({
    required bool shouldShow,
    required Widget child,
    required String fallbackMessage,
  }) {
    return wrapWithTooltip<T>(
      shouldShow: shouldShow,
      child: child,
      theme: widget.tooltipTheme,
      tooltipBuilder: widget.column.tooltipBuilder,
      tooltipFormatter: widget.column.tooltipFormatter,
      rowData: widget.rowData,
      fallbackMessage: fallbackMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this cell can be edited
    final canEdit = widget.isEditable && widget.column.editable;

    Color backgroundColor = Colors.transparent;

    // The divider stays while the cell is being edited. It used to be dropped
    // — `if (!isCellEditing) border = ...` — which is the maintainer's call to
    // reverse (2026-09-03) and the divergent behaviour of the two: pluto_grid
    // branches its cell decoration on *which cell is current*, never on whether
    // it is editing, and lets the editor draw no border of its own so the
    // container's survives. Flutter's own `DataTable` puts no decoration on a
    // cell at all, so it never has to choose (#155).
    final BoxBorder? border = _composeBorder();

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
    if (!widget.tooltipTheme.enabled) return false;
    return TooltipResolver.shouldShow(
      behavior: widget.column.tooltipBehavior,
      hasWidgetTooltip: widget.column.tooltipBuilder != null,
      isEllipsis: widget.column.textOverflow == TextOverflow.ellipsis,
      textIsEmpty: displayValue.isEmpty,
      willOverflow: () => _willTextOverflowCached(displayValue),
    );
  }

  /// Whether [displayValue] overflows the cell, memoized on (text, width) so a
  /// rebuild with unchanged inputs skips re-measuring.
  bool _willTextOverflowCached(String displayValue) {
    final availableWidth = widget.width - widget.theme.padding.horizontal;
    return _overflowCache.resolve(
      displayValue,
      availableWidth,
      () => TextOverflowDetector.willTextOverflowInContext(
        context: context,
        text: displayValue,
        maxWidth: availableWidth,
        style:
            widget.theme.getEffectiveTextStyle(widget.isSelected, widget.isDim),
      ),
    );
  }
}
