import 'dart:io';

import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/widgets/feature_detail_pane.dart';
import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A control's label is prose: it repeats, and a redesign is free to change it.
// Its id is the handle the pane holds onto — one per settings field.
//
// Dart has no reflection, so "this id names a real field" cannot be asked of
// the compiler. It is asked of the source instead: the second test reads the
// settings class and compares its fields to the ids the panes render.
//
// This used to pump the old panel with default settings, which drew the options
// of every feature that happened to be on and hid the rest. It saw a subset and
// called it all. The detail pane draws an off feature's options too, so walking
// the twenty features reaches every id there is.

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _pane(SettingFeature feature) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 380,
        child: FeatureDetailPane(
          settings: const PlaygroundSettings(),
          feature: feature,
          onSettingsChanged: (_) {},
          onGenerateData: () {},
        ),
      ),
    ),
  );
}

/// Every id the panes draw, across all twenty features.
Future<List<String>> _renderedIds(WidgetTester tester) async {
  final ids = <String>[];
  for (final feature in settingsSpec.expand((g) => g.features)) {
    await tester.pumpWidget(_pane(feature));
    ids.addAll(
      tester
          .widgetList<SettingsControl>(find.byType(SettingsControl))
          .map((c) => c.id),
    );
  }
  return ids;
}

/// The `final` fields declared on [PlaygroundSettings], read from its source.
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

void main() {
  testWidgets('every control carries a distinct id', (tester) async {
    _tallView(tester);

    final ids = await _renderedIds(tester);
    expect(ids, isNotEmpty);
    expect(ids.where((id) => id.isEmpty), isEmpty, reason: 'no blank ids');
    expect(ids.toSet().length, ids.length,
        reason: 'an id drawn twice means two features claim one setting');
  });

  testWidgets('every field of PlaygroundSettings has exactly one control',
      (tester) async {
    _tallView(tester);

    final fields = _settingsFields();
    expect(fields, hasLength(58),
        reason: 'the source reader still finds the fields it used to');

    final ids = (await _renderedIds(tester)).toSet();
    expect(ids.difference(fields), isEmpty,
        reason: 'an id that names nothing is a typo waiting to be believed');
    expect(fields.difference(ids), isEmpty,
        reason: 'a field no pane draws is a setting nobody can reach');
  });
}
