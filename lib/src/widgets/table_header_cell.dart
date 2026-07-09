import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/theme/checkbox_theme.dart';
import '../models/theme/header_theme.dart';
import '../models/theme/tooltip_theme.dart' show TablePlusTooltipTheme;
import '../models/tooltip_behavior.dart';
import '../utils/text_overflow_detector.dart';
import 'flutter_tooltip_plus.dart';

/// A single header cell widget.
class HeaderCell extends StatelessWidget {
  const HeaderCell({
    super.key,
    required this.column,
    required this.width,
    required this.theme,
    required this.tooltipTheme,
    required this.isSorted,
    required this.sortDirection,
    required this.isReordering,
    this.onSortClick,
    this.showDivider = true,
  });

  final TablePlusColumn<dynamic> column;
  final double width;
  final TablePlusHeaderTheme theme;
  final TablePlusTooltipTheme tooltipTheme;
  final bool isSorted;
  final SortDirection sortDirection;
  final bool isReordering;
  final VoidCallback? onSortClick;

  /// Whether to show the vertical divider on the right edge.
  /// Set to `false` for drag feedback to avoid rendering the divider on the floating cell.
  final bool showDivider;

  /// Get the sort icon widget for current state
  Widget? _getSortIcon() {
    if (!column.sortable || onSortClick == null) return null;

    switch (sortDirection) {
      case SortDirection.ascending:
        return theme.sortIcons.ascending;
      case SortDirection.descending:
        return theme.sortIcons.descending;
      case SortDirection.none:
        return theme.sortIcons.unsorted;
    }
  }

  /// Get the background color for this header cell
  Color _getBackgroundColor() {
    if (isSorted && theme.sortedColumnBackgroundColor != null) {
      return theme.sortedColumnBackgroundColor!;
    }
    return theme.backgroundColor;
  }

  /// Get the text style for this header cell
  TextStyle _getTextStyle() {
    if (isSorted && theme.sortedColumnTextStyle != null) {
      return theme.sortedColumnTextStyle!;
    }
    return theme.textStyle;
  }

  /// Determines whether a tooltip should be shown based on the column's header tooltip behavior.
  bool _shouldShowTooltip(BuildContext context, String label) {
    if (!tooltipTheme.enabled || label.isEmpty) {
      return false;
    }

    if (isReordering) {
      return false;
    }

    switch (column.headerTooltipBehavior) {
      case TooltipBehavior.never:
        return false;

      case TooltipBehavior.always:
        return true;

      case TooltipBehavior.onlyTextOverflow:
        final padding = theme.padding;
        final sortIconArea = _getSortIcon() != null
            ? theme.sortIconSpacing + theme.sortIconWidth
            : 0.0;
        final availableWidth = width - padding.horizontal - sortIconArea;

        return TextOverflowDetector.willTextOverflowInContext(
          context: context,
          text: label,
          maxWidth: availableWidth,
          style: theme.textStyle,
        );
    }
  }

  /// Build header text widget with optional tooltip
  Widget _buildHeaderText(BuildContext context, TextStyle textStyle) {
    Widget textWidget = Text(
      column.label,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
      textAlign: column.textAlign,
    );

    if (_shouldShowTooltip(context, column.label)) {
      try {
        textWidget = FlutterTooltipPlus(
          message: column.label,
          anchor: tooltipTheme.anchor,
          theme: tooltipTheme,
          child: textWidget,
        );
      } catch (e) {
        // Ignore tooltip creation errors during reordering
      }
    }

    return textWidget;
  }

  /// Build decoration for individual header cell
  Decoration _buildCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    return BoxDecoration(
      color: _getBackgroundColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortIcon = _getSortIcon();
    final textStyle = _getTextStyle();

    Widget content = Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: _buildCellDecoration(),
      child: Align(
        alignment: column.alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Column label
            Flexible(
              child: _buildHeaderText(context, textStyle),
            ),

            // Sort icon (FittedBox scales custom icons to match sortIconWidth)
            if (sortIcon != null) ...[
              SizedBox(width: theme.sortIconSpacing),
              SizedBox(
                width: theme.sortIconWidth,
                child: FittedBox(child: sortIcon),
              ),
            ],
          ],
        ),
      ),
    );

    // Overlay vertical divider with indent support
    final divider = theme.verticalDivider;
    if (showDivider && divider.show) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: 0,
            top: divider.indent,
            bottom: divider.endIndent,
            child: SizedBox(
              width: divider.thickness,
              child: ColoredBox(color: divider.color),
            ),
          ),
        ],
      );
    }

    // Wrap with GestureDetector for sortable columns
    if (column.sortable && onSortClick != null) {
      return GestureDetector(
        onTap: onSortClick,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// A header cell with select-all checkbox.
class SelectionHeaderCell extends StatelessWidget {
  const SelectionHeaderCell({
    super.key,
    required this.width,
    required this.theme,
    required this.selectAllState,
    required this.onSelectAll,
    required this.selectedRows,
    required this.checkboxTheme,
    this.showSelectAllCheckbox = true,
  });

  final double width;
  final TablePlusHeaderTheme theme;
  final bool? selectAllState;
  final void Function(bool selectAll)? onSelectAll;
  final Set<String> selectedRows;
  final TablePlusCheckboxTheme checkboxTheme;
  final bool showSelectAllCheckbox;

  /// Build decoration for selection header cell
  Decoration _buildSelectionCellDecoration() {
    final customCellDecoration = theme.cellDecoration;

    if (customCellDecoration != null) {
      return customCellDecoration;
    }

    return BoxDecoration(
      color: theme.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: theme.height,
      // No horizontal padding: the select-all checkbox is centered, so padding
      // only shrank its room and a narrow selection column would clip it (#4).
      decoration: _buildSelectionCellDecoration(),
      child: showSelectAllCheckbox && onSelectAll != null
          // Transparent Material: FlutterCheckbox's internal InkWell needs a
          // Material ancestor so the table works without a Scaffold (#3).
          ? Center(
              child: Material(
                type: MaterialType.transparency,
                child: checkboxTheme.buildCheckbox(
                  value: selectAllState,
                  tristate: true,
                  onChanged: (value) {
                    final shouldSelectAll = selectedRows.isEmpty;
                    onSelectAll!(shouldSelectAll);
                  },
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    // Overlay vertical divider with indent support
    final divider = theme.verticalDivider;
    if (divider.show) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: 0,
            top: divider.indent,
            bottom: divider.endIndent,
            child: SizedBox(
              width: divider.thickness,
              child: ColoredBox(color: divider.color),
            ),
          ),
        ],
      );
    }

    return content;
  }
}
