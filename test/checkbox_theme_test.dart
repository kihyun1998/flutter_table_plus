import 'package:flutter/material.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';
import 'package:flutter_table_plus/src/models/theme/checkbox_theme.dart';
import 'package:flutter_test/flutter_test.dart';

// Pure-logic coverage for TablePlusCheckboxTheme: the colored() factory, the
// field-preserving copyWith, dimension scaling, and buildCheckbox wiring.

void main() {
  group('colored factory', () {
    test('applies the colors and size to the checkbox style', () {
      final theme = TablePlusCheckboxTheme.colored(
        activeColor: const Color(0xFF00FF00),
        checkColor: const Color(0xFFFFFFFF),
        borderColor: const Color(0xFF000000),
        size: 24,
      );
      expect(theme.style.activeColor, const Color(0xFF00FF00));
      expect(theme.style.checkColor, const Color(0xFFFFFFFF));
      expect(theme.style.borderColor, const Color(0xFF000000));
      expect(theme.style.size, 24);
    });

    test('carries through the layout flags', () {
      final theme = TablePlusCheckboxTheme.colored(
        showCheckboxColumn: false,
        showSelectAllCheckbox: false,
        showRowCheckbox: false,
        cellTapTogglesCheckbox: true,
        checkboxColumnWidth: 80,
      );
      expect(theme.showCheckboxColumn, isFalse);
      expect(theme.showSelectAllCheckbox, isFalse);
      expect(theme.showRowCheckbox, isFalse);
      expect(theme.cellTapTogglesCheckbox, isTrue);
      expect(theme.checkboxColumnWidth, 80);
    });
  });

  group('copyWith', () {
    test('replaces only the named field', () {
      const theme = TablePlusCheckboxTheme(checkboxColumnWidth: 60);
      final copy = theme.copyWith(checkboxColumnWidth: 90);
      expect(copy.checkboxColumnWidth, 90);
      expect(copy.showCheckboxColumn, isTrue); // preserved default
    });
  });

  group('scaledBy', () {
    test('scales the column width and the style scale', () {
      const theme = TablePlusCheckboxTheme(checkboxColumnWidth: 60);
      final scaled = theme.scaledBy(2.0);
      expect(scaled.checkboxColumnWidth, 120.0);
      expect(scaled.style.scale, theme.style.scale * 2.0);
    });

    test('returns the same instance for a factor of 1.0', () {
      const theme = TablePlusCheckboxTheme();
      expect(identical(theme.scaledBy(1.0), theme), isTrue);
    });
  });

  group('buildCheckbox', () {
    test('is disabled when onChanged is null', () {
      final widget = const TablePlusCheckboxTheme()
          .buildCheckbox(value: true, onChanged: null) as FlutterCheckbox;
      expect(widget.enabled, isFalse);
      expect(widget.value, isTrue);
    });

    test('is enabled and can be tristate when a handler is given', () {
      final widget = const TablePlusCheckboxTheme().buildCheckbox(
        value: null,
        onChanged: (_) {},
        tristate: true,
      ) as FlutterCheckbox;
      expect(widget.enabled, isTrue);
      expect(widget.tristate, isTrue);
    });
  });
}
