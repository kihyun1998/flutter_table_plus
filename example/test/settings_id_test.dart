import 'dart:io';

import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/widgets/performance_monitor.dart';
import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:example/pages/playground/widgets/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A control's label is prose: it repeats, and a redesign is free to change it.
// Its id is the handle the panel holds onto — one per settings field.
//
// Dart has no reflection, so "this id names a real field" cannot be asked of
// the compiler. It is asked of the source instead: the second test reads the
// settings class and compares its fields to the ids the panel renders.

const _sectionTitles = [
  'Data',
  'Interaction',
  'Content',
  'Appearance',
];

Future<void> _expandEverySection(WidgetTester tester) async {
  for (final title in _sectionTitles) {
    final section = find.ancestor(
      of: find.text(title),
      matching: find.byType(SettingsSection),
    );
    final collapsed =
        find.descendant(of: section, matching: find.byIcon(Icons.expand_more));
    if (collapsed.evaluate().isEmpty) continue;

    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }
}

Widget _panel() {
  return MaterialApp(
    home: Scaffold(
      body: SettingsPanel(
        settings: const PlaygroundSettings(),
        performanceMetrics: PerformanceMetrics(
          rowCount: 0,
          lastUpdate: DateTime.fromMillisecondsSinceEpoch(0),
        ),
        onSettingsChanged: (_) {},
        onGenerateData: () {},
      ),
    ),
  );
}

List<String> _renderedIds(WidgetTester tester) => tester
    .widgetList<SettingsControl>(find.byType(SettingsControl))
    .map((c) => c.id)
    .toList();

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
    await tester.pumpWidget(_panel());
    await _expandEverySection(tester);

    final ids = _renderedIds(tester);
    expect(ids, isNotEmpty);
    expect(ids.where((id) => id.isEmpty), isEmpty, reason: 'no blank ids');
    expect(ids.toSet().length, ids.length, reason: 'ids are unique');
  });

  testWidgets('every id names a field of PlaygroundSettings', (tester) async {
    await tester.pumpWidget(_panel());
    await _expandEverySection(tester);

    final fields = _settingsFields();
    expect(fields, hasLength(58),
        reason: 'the source reader still finds the fields it used to');

    expect(_renderedIds(tester).toSet().difference(fields), isEmpty,
        reason: 'an id that names nothing is a typo waiting to be believed');
  });
}
