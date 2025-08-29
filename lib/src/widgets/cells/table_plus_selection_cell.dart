import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../models/theme/checkbox_theme.dart';

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
    this.checkboxTheme = const TablePlusCheckboxTheme(),
  });

  final double width;
  final String? rowId;
  final bool isSelected;
  final TablePlusBodyTheme theme;
  final TablePlusSelectionTheme selectionTheme;
  final void Function(String rowId) onSelectionChanged;
  final double? calculatedHeight;
  final TablePlusCheckboxTheme checkboxTheme;

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
          width: selectionTheme.getEffectiveCheckboxSize(checkboxTheme),
          height: selectionTheme.getEffectiveCheckboxSize(checkboxTheme),
          child: Checkbox(
            value: isSelected,
            onChanged:
                rowId != null ? (value) => onSelectionChanged(rowId!) : null,
            // Use deprecated properties if available, otherwise fall back to checkboxTheme
            activeColor:
                selectionTheme.getEffectiveCheckboxActiveColor(checkboxTheme),
            hoverColor:
                selectionTheme.getEffectiveCheckboxHoverColor(checkboxTheme),
            focusColor:
                selectionTheme.getEffectiveCheckboxFocusColor(checkboxTheme),
            fillColor:
                selectionTheme.getEffectiveCheckboxFillColor(checkboxTheme),
            checkColor: checkboxTheme.checkColor,
            side: selectionTheme.getEffectiveCheckboxSide(checkboxTheme),
            shape: checkboxTheme.shape,
            mouseCursor: checkboxTheme.mouseCursor,
            materialTapTargetSize: checkboxTheme.materialTapTargetSize ??
                MaterialTapTargetSize.shrinkWrap,
            visualDensity: checkboxTheme.visualDensity ?? VisualDensity.compact,
            splashRadius: checkboxTheme.splashRadius,
            overlayColor: checkboxTheme.overlayColor,
          ),
        ),
      ),
    );
  }
}
