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
    required this.onSelectionChanged,
    this.calculatedHeight,
    this.checkboxTheme = const TablePlusCheckboxTheme(),
  });

  final double width;
  final String? rowId;
  final bool isSelected;
  final TablePlusBodyTheme theme;
  final void Function(String rowId) onSelectionChanged;
  final double? calculatedHeight;
  final TablePlusCheckboxTheme checkboxTheme;

  @override
  Widget build(BuildContext context) {
    final checkbox = SizedBox(
      width: checkboxTheme.tapTargetSize ?? checkboxTheme.size,
      height: checkboxTheme.tapTargetSize ?? checkboxTheme.size,
      child: Checkbox(
        value: isSelected,
        onChanged: rowId != null ? (value) => onSelectionChanged(rowId!) : null,
        activeColor: checkboxTheme.fillColor?.resolve({WidgetState.selected}),
        hoverColor: checkboxTheme.hoverColor,
        focusColor: checkboxTheme.focusColor,
        fillColor: checkboxTheme.fillColor,
        checkColor: checkboxTheme.checkColor,
        side: checkboxTheme.side,
        shape: checkboxTheme.shape,
        mouseCursor: checkboxTheme.mouseCursor,
        materialTapTargetSize: checkboxTheme.materialTapTargetSize ??
            MaterialTapTargetSize.shrinkWrap,
        visualDensity: checkboxTheme.visualDensity ?? VisualDensity.compact,
        splashRadius: checkboxTheme.splashRadius,
        overlayColor: checkboxTheme.overlayColor,
      ),
    );

    Widget content = Padding(
      padding: theme.padding,
      child: Center(child: checkbox),
    );

    if (checkboxTheme.cellTapTogglesCheckbox) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: rowId != null ? () => onSelectionChanged(rowId!) : null,
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: calculatedHeight ?? theme.rowHeight,
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
}
