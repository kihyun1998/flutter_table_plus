import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// A tripwire, not a behaviour test.
//
// `TablePlusCheckboxTheme.scaledBy` derives a `CheckboxStyle` — a type this
// package does not own — and #116 is what happened when it did that by hand:
// `flutter_checkbox` 0.3.0 added five fields and this package's list, complete
// since 0.2.0, silently began resetting them to their defaults at any scale but
// 1.0. `copyWith` closes that failure class for good.
//
// What `copyWith` does NOT close is the other half: a **dimensional** field
// added upstream will be carried through faithfully and never scaled, which is
// wrong in a different direction and just as quiet. `shadows`, added in 0.3.2,
// happens to be safe — upstream's own changelog says it is not scaled, like
// `borderWidth` and `borderRadius`. The next one may not come with that
// sentence.
//
// So this test fails when the field set moves, and its failure means "go read
// the new field and decide whether the factor applies to it". It asserts
// nothing about behaviour and is expected to be edited, not fixed.
//
// It reads the resolved package rather than the sibling working tree, because
// what ships is what `pubspec.lock` resolves. There is no reflection in
// Flutter, and neither `CheckboxStyle` nor `TablePlusResizeHandleTheme`
// implements `==` or `toString`, so the source text is the only place the field
// set exists at test time.
const _known = <String>{
  'shape',
  'size',
  'scale',
  'activeColor',
  'checkColor',
  'borderColor',
  'inactiveColor',
  'borderWidth',
  'borderRadius',
  'checkStrokeWidth',
  'checkScale',
  'hoverRingPadding',
  'hoverRingShape',
  'hoverRingBorderRadius',
  'hoverColor',
  'focusColor',
  'splashColor',
  'disabledOpacity',
  'animationDuration',
  'animationCurve',
  'morphDuration',
  'morphCurve',
};

void main() {
  test('CheckboxStyle has not grown a field this package has not considered',
      () {
    final config = File('.dart_tool/package_config.json');
    expect(config.existsSync(), isTrue,
        reason: 'no package_config.json — run `flutter pub get` first. '
            'Without it this test cannot see the resolved package and would '
            'pass for the wrong reason.');

    final packages =
        (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List;
    final entry = packages.firstWhere(
      (p) => (p as Map)['name'] == 'flutter_checkbox',
      orElse: () => null,
    );
    expect(entry, isNotNull, reason: 'flutter_checkbox is not resolved');

    final root = Uri.parse((entry as Map)['rootUri'] as String);
    final dir = root.isAbsolute
        ? root.toFilePath()
        : File.fromUri(config.uri.resolveUri(root)).path;
    final source = File('$dir/lib/src/style/checkbox_style.dart');
    expect(source.existsSync(), isTrue,
        reason: 'CheckboxStyle moved: ${source.path}. That is itself the '
            'signal this test exists for.');

    // `final <type> <name>;` at one indent level — the class's declared fields.
    final found = RegExp(r'^  final [\w<>?,\s]+ (\w+);', multiLine: true)
        .allMatches(source.readAsStringSync())
        .map((m) => m.group(1)!)
        .toSet();

    expect(found, isNotEmpty,
        reason: 'the field regex matched nothing — the upstream file was '
            'reformatted and this tripwire is now blind, which is worse than '
            'a failure');

    expect(
      found,
      _known,
      reason: 'the resolved CheckboxStyle no longer matches the field set this '
          'package was written against.\n'
          'added:   ${found.difference(_known)}\n'
          'removed: ${_known.difference(found)}\n'
          '`scaledBy` uses copyWith, so an added field is carried rather than '
          'dropped — but if it is DIMENSIONAL it now travels unscaled. Decide '
          'which, then update the set above.',
    );
  });
}
