import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// #136. `FlutterTablePlus` reads `data` and `mergedGroups` as one snapshot,
// invalidated on each list's **object identity**. So a caller who mutates
// either list in place gets a table that renders the new contents while every
// derived cache — the id→index maps, the renderable-index list, the row heights
// and the drag hit-test geometry — still describes the previous snapshot.
//
// This app taught that mutation on four surfaces before #132, and did it itself
// on three more. Both are fixed; this stops them coming back, because nothing
// else can:
//
//   * `flutter analyze` has no opinion about `list.sort()`;
//   * the widget tests render the new contents correctly, since rendering reads
//     `data` live — the divergence is only in what the *callbacks* report and
//     what the *heights* were measured at;
//   * and the playground was, until #136, immune anyway: its `mergedGroups: []`
//     ternary allocated a fresh list on every build, so every cache was rebuilt
//     every build and the in-place edits below could never be observed. A test
//     that only pumped the app would have proved nothing.
//
// **What this cannot see**, stated because a source scan always has a boundary:
// it matches spellings, not semantics. A helper that mutates the list one call
// away, a mutation written through a differently-named local, or a list handed
// to `data:` under a name the patterns below do not know about all pass. It is
// a tripwire, not a proof — it says *go and look*, and the doc-comments on
// `FlutterTablePlus.data` / `.rowId` / `.mergedGroups` are the actual rule.

/// The fields this app passes to `data:` and `mergedGroups:`, by the names the
/// sources give them. A new page that names its list something else is outside
/// this scan — which is the boundary above, made concrete.
const _listNames = ['_data', '_rows', '_mergedGroups', '_groups'];

/// Method calls that mutate a `List` in place. Deliberately not exhaustive over
/// `List`'s API: these are the four this repository has actually shipped or
/// documented, and an unfamiliar one is what the doc-comments are for.
const _mutators = ['sort', 'removeWhere', 'insert', 'clear'];

void main() {
  group('the example does not mutate a snapshot list in place', () {
    final sources = _dartSources(Directory('lib'));

    test('scans a non-empty set of sources', () {
      // A scan over nothing passes every assertion below, which is the one way
      // this file could look like a guard while being none.
      expect(sources, isNotEmpty);
      expect(sources.length, greaterThan(20),
          reason: 'far fewer files than example/lib holds — the scan is '
              'looking in the wrong place');
    });

    test('no in-place mutator call on a list handed to the table', () {
      final hits = <String>[];
      for (final entry in sources.entries) {
        final lines = entry.value.split('\n');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          for (final name in _listNames) {
            for (final m in _mutators) {
              if (line.contains('$name.$m(')) {
                hits.add('${entry.key}:${i + 1}  $name.$m(');
              }
            }
          }
        }
      }
      expect(hits, isEmpty,
          reason: 'mutating in place holds the list identity, so the table '
              'never re-derives. Build a new list instead:\n'
              '  _rows = List.of(_rows)..sort(...)\n'
              '  _rows = _rows.where((r) => r.id != id).toList()\n'
              'Found:\n${hits.join('\n')}');
    });

    test('no in-place element replacement on a list handed to the table', () {
      final hits = <String>[];
      final pattern = RegExp(r'(_data|_rows|_mergedGroups|_groups)\[[^\]]+\]\s*=');
      for (final entry in sources.entries) {
        final lines = entry.value.split('\n');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          if (pattern.hasMatch(line)) {
            hits.add('${entry.key}:${i + 1}  ${line.trim()}');
          }
        }
      }
      expect(hits, isEmpty,
          reason: 'replacing an element in place renders the new value and '
              'keeps the cached row height, so a table whose heights depend on '
              'cell content keeps the pre-edit layout. Build a new list:\n'
              '  _rows = List.of(_rows)..[index] = updated;\n'
              'Found:\n${hits.join('\n')}');
    });

    test('the playground does not allocate its group list in a ternary arm',
        () {
      final page = sources.entries
          .firstWhere((e) => e.key.endsWith('playground_page.dart'))
          .value;
      // A bare `[]` here is a fresh object every build, so every cache is
      // dropped every build. It is the accident that used to hide the two
      // cases above, which is why it is asserted rather than left to taste.
      expect(page.contains('mergedGroups: _settings.mergedRowsEnabled\n'), isTrue,
          reason: 'the mergedGroups argument moved — re-read this assertion '
              'rather than deleting it');
      expect(RegExp(r'mergedGroups:[^;]*:\s*\[\]').hasMatch(page), isFalse,
          reason: 'a bare `[]` is not const, so it is a new object on every '
              'build and invalidates every cache on every build. Use '
              '`const <MergedRowGroup<Employee>>[]`');
    });
  });
}

/// Every `.dart` file under [dir], keyed by a path relative to `example/`.
///
/// Normalised to LF: these files are CRLF on disk, and every assertion above
/// splits on a newline or matches one literally.
Map<String, String> _dartSources(Directory dir) {
  final out = <String, String>{};
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    out[entity.path.replaceAll(r'\', '/')] =
        entity.readAsStringSync().replaceAll('\r\n', '\n');
  }
  return out;
}
