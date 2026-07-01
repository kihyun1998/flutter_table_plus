import 'package:flutter/material.dart';

import '../models/theme/body_theme.dart' show TablePlusBodyTheme;

/// The shared background + bottom-border decoration for a table row.
///
/// Normal and merged rows built the same `BoxDecoration` (a background color
/// and an optional bottom divider). They differ only in when the background is
/// transparent (to let the selection ink show through), which the caller
/// passes via [selectionTransparent]; the row's own height and cells stay per
/// row type.
BoxDecoration rowDecoration({
  required bool selectionTransparent,
  required Color backgroundColor,
  required TablePlusBodyTheme theme,
  required bool isLastRow,
  required bool needsVerticalScroll,
}) {
  return BoxDecoration(
    color: selectionTransparent ? Colors.transparent : backgroundColor,
    border: theme.shouldShowBottomBorder(
      isLastRow: isLastRow,
      needsVerticalScroll: needsVerticalScroll,
    )
        ? Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: theme.dividerThickness,
            ),
          )
        : null,
  );
}
