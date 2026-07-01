import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// copyWith / scaledBy coverage for the remaining theme classes. scaledBy has a
// consistent contract across the family: multiply dimensional values by the
// factor, leave colors/flags/durations alone, and return the same instance for
// factor 1.0. Expected values are hand-derived from documented defaults.

void main() {
  group('TablePlusHeaderTheme', () {
    const theme = TablePlusHeaderTheme();

    test('scaledBy scales dimensions but not colors/borders', () {
      final s = theme.scaledBy(2.0);
      expect(s.height, 112); // 56 * 2
      expect(s.textStyle.fontSize, 28); // 14 * 2
      expect(s.padding, const EdgeInsets.symmetric(horizontal: 32));
      expect(s.sortIconSpacing, 8); // 4 * 2
      expect(s.sortIconWidth, 32); // 16 * 2
      expect(s.resizeHandle.width, 16); // 8 * 2
      expect(s.backgroundColor, theme.backgroundColor);
      expect(s.bottomBorder.thickness, theme.bottomBorder.thickness);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces only the named field', () {
      final c = theme.copyWith(height: 80);
      expect(c.height, 80);
      expect(c.backgroundColor, theme.backgroundColor);
    });
  });

  group('header sub-theme copyWith', () {
    test('border / divider / resize handle preserve unspecified fields', () {
      const border = TablePlusHeaderBorderTheme();
      expect(border.copyWith(show: false).show, isFalse);
      expect(border.copyWith(show: false).color, border.color);

      const divider = TablePlusHeaderDividerTheme();
      expect(divider.copyWith(indent: 5).indent, 5);
      expect(divider.copyWith(indent: 5).thickness, divider.thickness);

      const handle = TablePlusResizeHandleTheme();
      expect(handle.copyWith(width: 20).width, 20);
      expect(handle.copyWith(width: 20).thickness, handle.thickness);
    });
  });

  group('TablePlusEditableTheme', () {
    const theme = TablePlusEditableTheme();

    test('scaledBy scales font, border width, and paddings only', () {
      final s = theme.scaledBy(2.0);
      expect(s.editingTextStyle.fontSize, 28); // 14 * 2
      expect(s.editingBorderWidth, 4); // 2 * 2
      expect(s.textFieldPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      expect(s.cellContainerPadding, const EdgeInsets.all(16));
      expect(s.editingCellColor, theme.editingCellColor);
      expect(s.editingBorderRadius, theme.editingBorderRadius);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('TablePlusDragSelectionTheme', () {
    const theme = TablePlusDragSelectionTheme();

    test('scaledBy scales only the border width', () {
      final s = theme.scaledBy(3.0);
      expect(s.borderWidth, 3); // 1 * 3
      expect(s.fillColor, theme.fillColor);
      expect(s.borderColor, theme.borderColor);
      expect(s.show, theme.show);
      expect(s.borderRadius, theme.borderRadius);
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces only the named field', () {
      expect(theme.copyWith(show: false).show, isFalse);
      expect(theme.copyWith(show: false).fillColor, theme.fillColor);
    });
  });

  group('TablePlusScrollbarTheme', () {
    test('scaledBy scales trackWidth and leaves null thickness/radius null',
        () {
      const theme = TablePlusScrollbarTheme();
      final s = theme.scaledBy(2.0);
      expect(s.trackWidth, 24); // 12 * 2
      expect(s.thickness, isNull);
      expect(s.radius, isNull);
      expect(s.thumbColor, theme.thumbColor);
      expect(s.opacity, theme.opacity);
    });

    test('scaledBy scales explicit thickness and radius', () {
      const theme = TablePlusScrollbarTheme(thickness: 6, radius: 4);
      final s = theme.scaledBy(2.0);
      expect(s.thickness, 12);
      expect(s.radius, 8);
    });

    test('scaledBy(1.0) returns the same instance', () {
      const theme = TablePlusScrollbarTheme();
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('TablePlusHoverButtonTheme', () {
    const theme = TablePlusHoverButtonTheme();

    test('scaledBy scales the horizontal offset', () {
      expect(theme.scaledBy(2.0).horizontalOffset, 16); // 8 * 2
    });

    test('scaledBy(1.0) returns the same instance', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });

    test('copyWith replaces the offset', () {
      expect(theme.copyWith(horizontalOffset: 20).horizontalOffset, 20);
    });
  });

  group('TablePlusTooltipTheme', () {
    const theme = TablePlusTooltipTheme();

    test('copyWith replaces only the named field', () {
      final c = theme.copyWith(enabled: false);
      expect(c.enabled, isFalse);
      expect(c.backgroundColor, theme.backgroundColor);
      expect(c.hideOnEmptyMessage, theme.hideOnEmptyMessage);
    });
  });
}
