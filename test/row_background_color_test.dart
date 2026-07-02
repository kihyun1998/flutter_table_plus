import 'package:flutter/widgets.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/row_background_color.dart';
import 'package:flutter_test/flutter_test.dart';

// Row background precedence: selected(&selectable) > dim > alternate(odd) > bg.

const _bg = Color(0xFF000001);
const _selected = Color(0xFF000002);
const _dim = Color(0xFF000003);
const _alt = Color(0xFF000004);

const _theme = TablePlusBodyTheme(
  backgroundColor: _bg,
  selectedRowColor: _selected,
  dimRowColor: _dim,
  alternateRowColor: _alt,
);

Color color({
  TablePlusBodyTheme theme = _theme,
  int index = 0,
  bool isSelected = false,
  bool isDim = false,
  bool isSelectable = true,
}) {
  return rowBackgroundColor(
    theme: theme,
    index: index,
    isSelected: isSelected,
    isDim: isDim,
    isSelectable: isSelectable,
  );
}

void main() {
  group('rowBackgroundColor', () {
    test('selected + selectable wins', () {
      expect(color(isSelected: true), _selected);
    });

    test('selected but not selectable does not apply the selected color', () {
      // index 0 (even), not dim -> falls through to background.
      expect(color(isSelected: true, isSelectable: false), _bg);
    });

    test('dim uses dimRowColor', () {
      expect(color(isDim: true), _dim);
    });

    test('dim falls back to the background when dimRowColor is unset', () {
      const noDim = TablePlusBodyTheme(backgroundColor: _bg);
      expect(color(theme: noDim, isDim: true), _bg);
    });

    test('alternate color on odd rows only', () {
      expect(color(index: 1), _alt);
      expect(color(index: 2), _bg);
    });

    test('selected beats dim and alternate', () {
      expect(color(isSelected: true, isDim: true, index: 1), _selected);
    });

    test('dim beats alternate', () {
      expect(color(isDim: true, index: 1), _dim);
    });

    test('plain even row is the background', () {
      expect(color(index: 0), _bg);
    });
  });
}
