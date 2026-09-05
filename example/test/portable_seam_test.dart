import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// `lib/recipes/` is the pasteable zone and `test/recipe_seam_test.dart` holds it
// to an import allow-list. This file names a second zone with a different claim.
//
// The **portable zone** is `lib/gallery/`: the chrome that demonstrates a
// package without knowing which package it is. A menu, a destination model, a
// viewport frame, a device wall, a source pane, the app's own theme. None of it
// mentions tables, and none of it should — the same shell around a different
// package's recipes is the whole reason this code is shaped the way it is, and
// the directory is laid out as the package it is going to be.
//
// Before this rule existed, `lib/preview/` was already clean and `lib/shell/`
// was not: a page that knows nothing about recipes imported eleven of them,
// plus two scenarios and the playground. Neither fact was visible. Nothing
// stated the property, nothing checked it, and both halves compiled — the shape
// `docs/map/invariant/no-signal-on-failure.md` exists to name. A zone that is
// clean because nobody happened to dirty it is not a zone.
//
// The rules are deliberately **not** hand-written lists of allowed spellings.
// `'viewport_spec.dart'`, `'../preview/device_wall.dart'` and
// `'package:example/gallery/gallery.dart'` are three spellings of the same
// question — does this import leave the zone — and enumerating the forms is the
// shape `docs/map/invariant/no-hand-enumeration.md` warns about. Every import is
// resolved to a path under `lib/` and the answer follows from where it lands.
//
// Prior art for reading source rather than asking the compiler:
// `settings_spec_test.dart`, `recipe_seam_test.dart`. Dart has no reflection.

/// The zone, relative to `lib/`.
const _zone = 'gallery';

/// The zone's public entry point. Everything else under it is private to it.
const _barrel = 'gallery/gallery.dart';

/// Where the zone keeps its implementation.
const _zoneInternals = 'gallery/src/';

/// Import prefixes that leave the repository and are therefore always fine.
///
/// Flutter is the floor the zone is written against. `dart:` is the language.
/// Anything else outside the tree — including `package:flutter_table_plus/` —
/// is the thing this test exists to catch, so the list is exactly two entries
/// and grows only with a dependency the zone genuinely needs.
const _allowedExternal = ['dart:', 'package:flutter/'];

List<File> _dartFilesUnder(String dir) => Directory('lib/$dir')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

List<File> _dartFilesOutside(String dir) => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .where((f) => !f.path.contains('lib/$dir/'))
    .toList();

List<String> _importsOf(File file) =>
    RegExp(r"^import\s+'([^']+)'", multiLine: true)
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();

/// Where an import lands, expressed as a path under `lib/`, or null when it
/// leaves the repository entirely.
///
/// The spellings collapse here: `package:example/gallery/gallery.dart` and a
/// relative `../gallery/gallery.dart` both resolve to `gallery/gallery.dart`,
/// which is what makes these rules questions about location rather than about
/// how somebody chose to write the import.
String? _resolveWithinLib(String import, File from) {
  if (import.startsWith('package:example/')) {
    return import.substring('package:example/'.length);
  }
  if (import.startsWith('package:') || import.startsWith('dart:')) return null;

  // Relative: resolve against the importing file's own directory, then express
  // the result relative to `lib/`.
  //
  // The file is made **absolute** first. A relative `from.path` resolves to a
  // relative target with no leading separator, and the `/lib/` needle below then
  // matches nothing — which reports every same-directory import as leaving the
  // package. That was the first result this test produced, and it was red for a
  // reason that had nothing to do with the property being asserted.
  final fromDir = from.absolute.uri.resolve('.');
  final target = fromDir.resolve(import).path;
  final libIndex = target.indexOf('/lib/');
  return libIndex < 0 ? null : target.substring(libIndex + '/lib/'.length);
}

void main() {
  group('lib/gallery is the portable zone', () {
    test('no file in the zone imports anything outside it', () {
      final offences = <String>[];

      for (final file in _dartFilesUnder(_zone)) {
        for (final import in _importsOf(file)) {
          if (_allowedExternal.any(import.startsWith)) continue;

          final landing = _resolveWithinLib(import, file);
          if (landing == null) {
            offences.add('${file.path}: $import  (outside this package)');
          } else if (!landing.startsWith('$_zone/')) {
            offences.add('${file.path}: $import  (lands in lib/$landing)');
          }
        }
      }

      expect(
        offences,
        isEmpty,
        reason: 'The portable zone must carry to another package unchanged.\n'
            'Each line below is an import that ties it to this one:\n'
            '  ${offences.join('\n  ')}',
      );
    });

    test('nothing outside the zone reaches past its barrel', () {
      // The half the compiler will never object to. `lib/gallery/src/...`
      // resolves perfectly well from `lib/app/` today — and is precisely what
      // stops resolving on the day this directory becomes a package, because a
      // package's `src/` is private by convention and nothing else.
      //
      // Same shape as the main package's barrel row in
      // `docs/map/invariant/tree-rule.md`: a symbol is exported there or it is
      // not public. Here the consequence is one step further out — an import
      // that is legal now and impossible later.
      final offences = <String>[];

      for (final file in _dartFilesOutside(_zone)) {
        for (final import in _importsOf(file)) {
          final landing = _resolveWithinLib(import, file);
          if (landing == null) continue;
          if (landing.startsWith(_zoneInternals)) {
            offences.add('${file.path}: $import');
          }
        }
      }

      expect(
        offences,
        isEmpty,
        reason: 'Outside the zone, only lib/$_barrel may be imported.\n'
            'These reach into its internals instead:\n'
            '  ${offences.join('\n  ')}',
      );
    });

    test('the barrel and the zone name the same set of files', () {
      // A file the barrel forgets stays reachable inside this app through its
      // `src/` path, so the omission is invisible until extraction — at which
      // point it is simply missing from the package. Checked against the tree
      // rather than against a list kept by hand, in both directions.
      final exported = RegExp(r"^export '([^']+)'", multiLine: true)
          .allMatches(File('lib/$_barrel').readAsStringSync())
          .map((m) => '$_zone/${m.group(1)!}')
          .toSet();

      final present = _dartFilesUnder(_zone)
          .map((f) => f.path.substring('lib/'.length))
          .where((p) => p != _barrel)
          .toSet();

      expect(
        present.difference(exported),
        isEmpty,
        reason: 'In the zone but not exported — these vanish from the package.',
      );
      expect(
        exported.difference(present),
        isEmpty,
        reason: 'Exported by the barrel but not present in the zone.',
      );
    });

    test('every import line in the zone is actually read', () {
      // The rules above are filters over whatever `_importsOf` returns, so a
      // regex that matched nothing would report no offences and pass. Nothing
      // else here can tell "clean" from "not looked at".
      //
      // The single-quote form is what `dart format` produces and what
      // `recipe_seam_test.dart` already relies on; this asserts that assumption
      // rather than inheriting it, so a file written with double quotes, or a
      // conditional import, fails here instead of disappearing from the rule.
      for (final file in _dartFilesUnder(_zone)) {
        final lines =
            file.readAsLinesSync().where((l) => l.startsWith('import ')).length;
        expect(
          _importsOf(file),
          hasLength(lines),
          reason: '${file.path} has $lines import lines but the rule parsed '
              '${_importsOf(file).length} of them — the unparsed ones are '
              'exempt from the zone check without saying so.',
        );
      }
    });

    test('the zone is not empty, and neither is any area in it', () {
      // A rule that walks nothing passes, so this is what would catch a rename
      // that emptied the zone and turned every rule above green by removing its
      // subject.
      //
      // The areas are read from the tree rather than listed here. A list would
      // be a second roster to keep in step — the shape
      // `docs/map/invariant/no-hand-enumeration.md` warns about — and it went
      // stale the first time an area was added: this test named three while the
      // zone had five.
      expect(_dartFilesUnder(_zone), isNotEmpty, reason: 'The zone is empty.');

      final areas = Directory('lib/$_zoneInternals')
          .listSync()
          .whereType<Directory>()
          .toList();
      expect(areas, isNotEmpty, reason: 'lib/$_zoneInternals has no areas.');

      for (final area in areas) {
        expect(
          area
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')),
          isNotEmpty,
          reason: '${area.path} is an area of the zone but holds no Dart '
              'files — a move left it behind.',
        );
      }
    });
  });
}
