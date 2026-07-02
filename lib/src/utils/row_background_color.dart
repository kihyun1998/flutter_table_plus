import 'package:flutter/widgets.dart';

import '../models/theme/body_theme.dart' show TablePlusBodyTheme;

/// The background color for a data row, by precedence.
///
/// Pure extraction of the body's row-color rule so the precedence is
/// unit-testable:
/// 1. **selected** (only when [isSelectable]) → [TablePlusBodyTheme.selectedRowColor]
/// 2. **dim** → [TablePlusBodyTheme.dimRowColor] (or the background when unset)
/// 3. **alternate** on odd [index] → [TablePlusBodyTheme.alternateRowColor]
/// 4. otherwise → [TablePlusBodyTheme.backgroundColor]
Color rowBackgroundColor({
  required TablePlusBodyTheme theme,
  required int index,
  required bool isSelected,
  required bool isDim,
  required bool isSelectable,
}) {
  if (isSelected && isSelectable) {
    return theme.selectedRowColor;
  }

  if (isDim) {
    return theme.dimRowColor ?? theme.backgroundColor;
  }

  if (theme.alternateRowColor != null && index.isOdd) {
    return theme.alternateRowColor!;
  }

  return theme.backgroundColor;
}
