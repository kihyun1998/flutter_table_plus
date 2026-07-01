import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/models/theme/body_theme.dart';
import 'package:flutter_test/flutter_test.dart';

// Pure-logic coverage for TablePlusBodyTheme: the border decision, the
// selected > dim > normal effective-color/style priority, scaling, and
// copyWith. Expected values are hand-derived literals, independent of the
// implementation.

void main() {
  group('shouldShowBottomBorder', () {
    test('is false for every row when horizontal dividers are disabled', () {
      const theme = TablePlusBodyTheme(showHorizontalDividers: false);
      expect(
        theme.shouldShowBottomBorder(
            isLastRow: false, needsVerticalScroll: false),
        isFalse,
      );
      expect(
        theme.shouldShowBottomBorder(
            isLastRow: true, needsVerticalScroll: false),
        isFalse,
      );
    });

    test('a non-last row always shows its bottom border', () {
      const theme = TablePlusBodyTheme(
        lastRowBorderBehavior: LastRowBorderBehavior.never,
      );
      expect(
        theme.shouldShowBottomBorder(
            isLastRow: false, needsVerticalScroll: true),
        isTrue,
      );
    });

    test('the last row honors never vs always', () {
      const never = TablePlusBodyTheme(
        lastRowBorderBehavior: LastRowBorderBehavior.never,
      );
      const always = TablePlusBodyTheme(
        lastRowBorderBehavior: LastRowBorderBehavior.always,
      );
      expect(
        never.shouldShowBottomBorder(
            isLastRow: true, needsVerticalScroll: false),
        isFalse,
      );
      expect(
        always.shouldShowBottomBorder(
            isLastRow: true, needsVerticalScroll: false),
        isTrue,
      );
    });

    test('smart shows the last border only when there is no vertical scroll',
        () {
      const smart = TablePlusBodyTheme(
        lastRowBorderBehavior: LastRowBorderBehavior.smart,
      );
      expect(
        smart.shouldShowBottomBorder(
            isLastRow: true, needsVerticalScroll: false),
        isTrue,
      );
      expect(
        smart.shouldShowBottomBorder(
            isLastRow: true, needsVerticalScroll: true),
        isFalse,
      );
    });
  });

  group('effective interaction colors (selected > dim > normal)', () {
    const normal = Color(0xFF111111);
    const dim = Color(0xFF222222);
    const selected = Color(0xFF333333);

    const full = TablePlusBodyTheme(
      hoverColor: normal,
      dimRowHoverColor: dim,
      selectedRowHoverColor: selected,
      splashColor: normal,
      dimRowSplashColor: dim,
      selectedRowSplashColor: selected,
      highlightColor: normal,
      dimRowHighlightColor: dim,
      selectedRowHighlightColor: selected,
    );

    test('hover: selected wins over dim, dim over normal', () {
      expect(full.getEffectiveHoverColor(true, false), selected);
      expect(full.getEffectiveHoverColor(true, true), selected);
      expect(full.getEffectiveHoverColor(false, true), dim);
      expect(full.getEffectiveHoverColor(false, false), normal);
    });

    test('splash follows the same priority', () {
      expect(full.getEffectiveSplashColor(true, true), selected);
      expect(full.getEffectiveSplashColor(false, true), dim);
      expect(full.getEffectiveSplashColor(false, false), normal);
    });

    test('highlight follows the same priority', () {
      expect(full.getEffectiveHighlightColor(true, true), selected);
      expect(full.getEffectiveHighlightColor(false, true), dim);
      expect(full.getEffectiveHighlightColor(false, false), normal);
    });

    test('selected/dim fall back to the base color when their own is null', () {
      const base = TablePlusBodyTheme(hoverColor: normal);
      expect(base.getEffectiveHoverColor(true, false), normal);
      expect(base.getEffectiveHoverColor(false, true), normal);
    });

    test('returns null when no color is configured (framework default)', () {
      const bare = TablePlusBodyTheme();
      expect(bare.getEffectiveHoverColor(true, true), isNull);
      expect(bare.getEffectiveSplashColor(false, false), isNull);
    });
  });

  group('getEffectiveTextStyle', () {
    const base = TextStyle(fontSize: 14);
    const selStyle = TextStyle(fontSize: 20);
    const dimStyle = TextStyle(fontSize: 10);

    const theme = TablePlusBodyTheme(
      textStyle: base,
      selectedRowTextStyle: selStyle,
      dimRowTextStyle: dimStyle,
    );

    test('selected wins over dim, dim over normal', () {
      expect(theme.getEffectiveTextStyle(true, false), selStyle);
      expect(theme.getEffectiveTextStyle(true, true), selStyle);
      expect(theme.getEffectiveTextStyle(false, true), dimStyle);
      expect(theme.getEffectiveTextStyle(false, false), base);
    });

    test('falls back to base when the state-specific style is null', () {
      const noOverrides = TablePlusBodyTheme(textStyle: base);
      expect(noOverrides.getEffectiveTextStyle(true, false), base);
      expect(noOverrides.getEffectiveTextStyle(false, true), base);
    });
  });

  group('scaledBy', () {
    const theme = TablePlusBodyTheme(
      rowHeight: 48,
      textStyle: TextStyle(fontSize: 14),
      padding: EdgeInsets.symmetric(horizontal: 16),
      dividerThickness: 1.0,
      dividerColor: Color(0xFF0000FF),
      showVerticalDividers: true,
    );

    test('scales rowHeight, font size, and padding by the factor', () {
      final scaled = theme.scaledBy(2.0);
      expect(scaled.rowHeight, 96);
      expect(scaled.textStyle.fontSize, 28);
      expect(scaled.padding, const EdgeInsets.symmetric(horizontal: 32));
    });

    test('leaves colors, thickness, and flags untouched', () {
      final scaled = theme.scaledBy(2.0);
      expect(scaled.dividerThickness, 1.0);
      expect(scaled.dividerColor, const Color(0xFF0000FF));
      expect(scaled.showVerticalDividers, isTrue);
    });

    test('returns the same instance for a factor of 1.0', () {
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('copyWith and divider getters', () {
    test('copyWith replaces only the named field', () {
      const theme = TablePlusBodyTheme(
        rowHeight: 48,
        backgroundColor: Color(0xFFFFFFFF),
      );
      final copy = theme.copyWith(rowHeight: 100);
      expect(copy.rowHeight, 100);
      expect(copy.backgroundColor, const Color(0xFFFFFFFF));
    });

    test('vertical divider getters reflect showVerticalDividers', () {
      const on = TablePlusBodyTheme(showVerticalDividers: true);
      const off = TablePlusBodyTheme(showVerticalDividers: false);

      expect(off.verticalDividerSide, BorderSide.none);
      expect(off.verticalDividerBorder, isNull);

      expect(on.verticalDividerSide.width, 0.5);
      expect(on.verticalDividerBorder, isNotNull);
      expect(on.verticalDividerBorder!.right.width, 0.5);
    });
  });
}
