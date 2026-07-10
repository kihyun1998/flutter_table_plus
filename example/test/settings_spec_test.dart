import 'dart:io';

import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:flutter_test/flutter_test.dart';

// The description of the playground's settings is data, and these tests are
// what keep it true. A map written in prose would be stale within a month; this
// one goes red the moment it stops matching the class it describes.
//
// What a machine can check: that every field is described exactly once, that
// every id points at something, that no interaction is asserted without a
// citation. What it cannot check is whether the citation *says* what the
// interaction claims. That is a reviewer's job, and #76 says so.

/// The `final` fields declared on `PlaygroundSettings`, read from its source.
///
/// Dart has no reflection, so this question cannot be put to the compiler.
Set<String> _settingsFields() {
  final source = File(
    'lib/pages/playground/models/playground_settings.dart',
  ).readAsStringSync();
  final body = source.substring(source.indexOf('class PlaygroundSettings'));
  return RegExp(r'^  final [\w<>?,\s]+ (\w+);', multiLine: true)
      .allMatches(body)
      .map((m) => m.group(1)!)
      .toSet();
}

Iterable<SettingFeature> get _features =>
    settingsSpec.expand((group) => group.features);

/// Every id the spec claims is a settings field: a feature's own switch, and
/// the options that only mean something once that switch is on.
List<String> _describedFields() => [
      for (final f in _features) ...[
        if (f.switchId != null) f.switchId!,
        ...f.options,
      ],
    ];

void main() {
  test('the spec describes every settings field exactly once', () {
    final described = _describedFields();
    final fields = _settingsFields();

    expect(fields, hasLength(58),
        reason: 'the source reader still finds the fields it used to');

    final duplicated =
        described.where((id) => described.where((o) => o == id).length > 1);
    expect(duplicated, isEmpty, reason: 'a field described twice');

    expect(described.toSet().difference(fields), isEmpty,
        reason: 'the spec describes a field that does not exist');
    expect(fields.difference(described.toSet()), isEmpty,
        reason: 'a field nobody described — add it to the spec');
  });

  test('every interaction names a feature that exists', () {
    final featureIds = _features.map((f) => f.id).toSet();

    for (final f in _features) {
      for (final i in f.interactions) {
        expect(featureIds, contains(i.otherFeatureId),
            reason: '${f.id} claims to interact with ${i.otherFeatureId}');
        expect(i.otherFeatureId, isNot(f.id),
            reason: '${f.id} interacts with itself');
      }
    }
  });

  test('no interaction is asserted without a citation', () {
    for (final f in _features) {
      for (final i in f.interactions) {
        expect(i.effect.trim(), isNotEmpty, reason: '${f.id} → what happens?');
        expect(i.evidence.trim(), isNotEmpty,
            reason: '${f.id} → ${i.otherFeatureId} cites nothing');
      }
    }
  });

  test('feature and group ids are unique', () {
    final groupIds = settingsSpec.map((g) => g.id).toList();
    expect(groupIds.toSet().length, groupIds.length);

    final featureIds = _features.map((f) => f.id).toList();
    expect(featureIds.toSet().length, featureIds.length);
  });
}
