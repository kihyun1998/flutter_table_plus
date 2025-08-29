import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// A selection cell with checkbox.
class TablePlusSelectionCell extends StatelessWidget {
  const TablePlusSelectionCell({
    super.key,
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
            hoverColor: selectionTheme.checkboxHoverColor,
            focusColor: selectionTheme.checkboxFocusColor,
            fillColor: selectionTheme.checkboxFillColor != null
                ? WidgetStateProperty.all(selectionTheme.checkboxFillColor!)
                : null,
            side: selectionTheme.checkboxSide,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
