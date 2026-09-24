import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Every colour-bearing field in the theme models, and what
// `TablePlusTheme.fromColorScheme` does with it. The factory names the colours
// it sets, so a colour field added later keeps its light default inside a dark
// table and nothing fails. This test is what fails: a field it has not heard of
// has to be put in one of the two sets below, which means deciding it.

/// Set by `fromColorScheme` from a `ColorScheme` role.
const _derived = {
  'TablePlusBodyTheme.backgroundColor',
  'TablePlusBodyTheme.textStyle',
  'TablePlusBodyTheme.selectedRowColor',
  'TablePlusBodyTheme.selectedRowTextStyle',
  'TablePlusBodyTheme.dividerColor',
  'TablePlusHeaderTheme.backgroundColor',
  'TablePlusHeaderTheme.textStyle',
  'TablePlusHeaderBorderTheme.color',
  'TablePlusHeaderDividerTheme.color',
  'TablePlusEditableTheme.editingCellColor',
  'TablePlusEditableTheme.editingTextStyle',
  'TablePlusEditableTheme.editingBorderColor',
  'TablePlusEditableTheme.cursorColor',
  'TablePlusEditableTheme.errorBorderColor',
  'TablePlusEditableTheme.focusedErrorBorderColor',
  'TablePlusDragSelectionTheme.fillColor',
  'TablePlusDragSelectionTheme.borderColor',
  'TablePlusScrollbarTheme.thumbColor',
  'TablePlusScrollbarTheme.trackColor',
  'TablePlusTooltipTheme.backgroundColor',
  'TablePlusTooltipTheme.textStyle',
};

/// Left null by `fromColorScheme`: off by default, or resolved from a field in
/// [_derived] or from the ambient Material theme where it is drawn.
const _leftNull = {
  'TablePlusBodyTheme.alternateRowColor',
  'TablePlusBodyTheme.summaryRowBackgroundColor',
  'TablePlusBodyTheme.dimRowColor',
  'TablePlusBodyTheme.dimRowTextStyle',
  'TablePlusBodyTheme.dimRowHoverColor',
  'TablePlusBodyTheme.dimRowSplashColor',
  'TablePlusBodyTheme.dimRowHighlightColor',
  'TablePlusBodyTheme.verticalDividerColor',
  'TablePlusBodyTheme.memberDividerColor',
  // Falls back to a literal #757575, not to a field in _derived.
  'TablePlusBodyTheme.emptyStateTextStyle',
  // Falls back to a literal #757575, not to a field in _derived.
  'TablePlusBodyTheme.mergedRowCountTextStyle',
  'TablePlusBodyTheme.hoverColor',
  'TablePlusBodyTheme.splashColor',
  'TablePlusBodyTheme.highlightColor',
  'TablePlusBodyTheme.selectedRowHoverColor',
  'TablePlusBodyTheme.selectedRowSplashColor',
  'TablePlusBodyTheme.selectedRowHighlightColor',
  'TablePlusHeaderTheme.sortedColumnBackgroundColor',
  'TablePlusHeaderTheme.sortedColumnTextStyle',
  'TablePlusResizeHandleTheme.color',
  'TablePlusEditableTheme.hintStyle',
  'TablePlusEditableTheme.focusedBorderColor',
  'TablePlusEditableTheme.enabledBorderColor',
  'TablePlusEditableTheme.fillColor',
  'TablePlusTooltipTheme.borderColor',
};

/// `Class.field` for every `final Color` / `final TextStyle` field declared in
/// [source], nullable or not.
Set<String> _colourFields(String source) {
  final found = <String>{};
  String? owner;
  for (final line in source.split('\n')) {
    final cls = RegExp(r'^class (\w+)').firstMatch(line);
    if (cls != null) owner = cls.group(1);
    final field = RegExp(
      r'^  final (?:Color|TextStyle)\??\s+(\w+);',
    ).firstMatch(line);
    if (field != null && owner != null) found.add('$owner.${field.group(1)}');
  }
  return found;
}

void main() {
  test('every theme colour has been decided for fromColorScheme', () {
    final dir = Directory('lib/src/models/theme');
    expect(dir.existsSync(), isTrue, reason: 'theme models moved: ${dir.path}');

    final found = <String>{
      for (final f in dir.listSync().whereType<File>())
        if (f.path.endsWith('.dart')) ..._colourFields(f.readAsStringSync()),
    };
    expect(
      found,
      isNotEmpty,
      reason:
          'the field regex matched nothing — the sources were reformatted and '
          'this tripwire is now blind, which is worse than a failure',
    );

    expect(
      _derived.intersection(_leftNull),
      isEmpty,
      reason: 'a field cannot be both derived and left null',
    );
    expect(
      found,
      {..._derived, ..._leftNull},
      reason:
          'a colour field was added or removed. Decide whether '
          'TablePlusTheme.fromColorScheme derives it from a ColorScheme role '
          '(add it there and to _derived) or leaves it null (add it to '
          '_leftNull, and say why its fallback still suits any scheme).',
    );
  });
}
