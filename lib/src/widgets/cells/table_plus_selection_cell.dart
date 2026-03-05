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
    Widget content;

    if (checkboxTheme.showRowCheckbox) {
      content = Padding(
        padding: theme.padding,
        child: Center(
          child: checkboxTheme.buildCheckbox(
            value: isSelected,
            onChanged:
                rowId != null ? (value) => onSelectionChanged(rowId!) : null,
          ),
        ),
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
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      width: width,
      height: calculatedHeight ?? theme.rowHeight,
      decoration: BoxDecoration(
        border: theme.verticalDividerBorder,
      ),
      child: content,
    );
  }
}
