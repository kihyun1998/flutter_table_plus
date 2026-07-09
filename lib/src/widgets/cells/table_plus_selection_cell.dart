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
      // Center only — no horizontal body padding. The checkbox is already
      // centered, so padding never changed its position, only shrank the room
      // it had; a narrow selection column would then clip it away entirely (#4).
      //
      // Neither the checkbox's internal InkWell nor the cell-tap InkWell below
      // owns a Material. They paint onto the row's — CustomInkWell wraps the
      // whole row whenever the row is selectable, and this cell only renders
      // when it is. That row Material is what keeps the table working without a
      // Scaffold/Material of its own (#3).
      content = Center(
        child: checkboxTheme.buildCheckbox(
          value: isSelected,
          onChanged:
              rowId != null ? (value) => onSelectionChanged(rowId!) : null,
        ),
      );

      if (checkboxTheme.cellTapTogglesCheckbox) {
        content = InkWell(
          onTap: rowId != null ? () => onSelectionChanged(rowId!) : null,
          mouseCursor:
              rowId != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: content,
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
