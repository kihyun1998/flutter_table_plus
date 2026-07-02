import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/row_decoration.dart';
import 'package:flutter_test/flutter_test.dart';

// rowDecoration is the shared background + bottom-border BoxDecoration for a
// row. It has two decisions: transparent-vs-background, and whether to draw the
// bottom divider (delegated to the tested shouldShowBottomBorder).

void main() {
  const theme = TablePlusBodyTheme(); // dividers on, last-row border: never
  const bg = Color(0xFF123456);

  BoxDecoration deco({
    bool selectionTransparent = false,
    bool isLastRow = false,
    bool needsVerticalScroll = false,
  }) {
    return rowDecoration(
      selectionTransparent: selectionTransparent,
      backgroundColor: bg,
      theme: theme,
      isLastRow: isLastRow,
      needsVerticalScroll: needsVerticalScroll,
    );
  }

  group('rowDecoration', () {
    test('uses the background color when not selection-transparent', () {
      expect(deco(selectionTransparent: false).color, bg);
    });

    test('is transparent when selection-transparent (ink shows through)', () {
      expect(deco(selectionTransparent: true).color, Colors.transparent);
    });

    test('draws a bottom border on a non-last row', () {
      final border = deco(isLastRow: false).border as Border;
      expect(border.bottom.color, theme.dividerColor);
      expect(border.bottom.width, theme.dividerThickness);
    });

    test('draws no border on the last row (default "never" behavior)', () {
      expect(deco(isLastRow: true).border, isNull);
    });
  });
}
