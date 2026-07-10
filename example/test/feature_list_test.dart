import 'package:example/pages/playground/models/feature_switches.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_presets.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/pages/playground/widgets/feature_list_pane.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Sixty-eight controls stood in a column. The list shows twenty names instead,
// and answers two questions per row: is this on, and how much is inside it.
//
// Four of the twenty own no switch — Rows, Zoom, Rows and text, Row ink are
// headings over settings that are always live. A dot beside them would offer to
// turn off something that cannot be turned off.

/// The list is 1,088px tall with every entry built; a 600px test surface would
/// leave the last group unmounted and every assertion about it vacuously true.
void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _pane({
  PlaygroundSettings? settings,
  String? selected,
  ValueChanged<PlaygroundSettings>? onSettingsChanged,
  ValueChanged<String>? onFeatureSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 220,
        child: FeatureListPane(
          settings: settings ??
              applyPreset(const PlaygroundSettings(), presetById('bare')),
          selectedFeatureId: selected,
          onSettingsChanged: onSettingsChanged ?? (_) {},
          onFeatureSelected: onFeatureSelected ?? (_) {},
        ),
      ),
    ),
  );
}

Iterable<SettingFeature> get _features =>
    settingsSpec.expand((g) => g.features);

void main() {
  testWidgets('every feature appears, under its group', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane());

    for (final group in settingsSpec) {
      expect(find.text(group.title.toUpperCase()), findsOneWidget,
          reason: group.id);
    }
    for (final feature in _features) {
      expect(find.text(feature.title), findsOneWidget, reason: feature.id);
    }
  });

  testWidgets('an entry says how many options it holds', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane());

    // Selection owns five; drag selection owns none and says nothing.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('feature-selection')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('feature-dragSelection')),
        matching: find.byType(Text),
      ),
      findsOneWidget,
      reason: 'a feature with no options shows only its name',
    );
  });

  testWidgets('the dot turns a feature on', (tester) async {
    PlaygroundSettings? changed;
    _tallView(tester);
    await tester.pumpWidget(_pane(onSettingsChanged: (s) => changed = s));

    expect(
        featureSwitches['sortingEnabled']!
            .read(applyPreset(const PlaygroundSettings(), presetById('bare'))),
        isFalse);

    await tester.tap(find.byKey(const ValueKey('feature-dot-sorting')));
    await tester.pumpAndSettle();

    expect(changed, isNotNull);
    expect(featureSwitches['sortingEnabled']!.read(changed!), isTrue);
  });

  testWidgets('the name selects, and does not toggle', (tester) async {
    String? selected;
    PlaygroundSettings? changed;
    _tallView(tester);
    await tester.pumpWidget(_pane(
      onFeatureSelected: (id) => selected = id,
      onSettingsChanged: (s) => changed = s,
    ));

    await tester.tap(find.text('Sorting'));
    await tester.pumpAndSettle();

    expect(selected, 'sorting');
    expect(changed, isNull, reason: 'selecting is not enabling');
  });

  testWidgets('the selected entry is visibly selected', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane(selected: 'resizing'));

    final tile = tester.widget<ListTile>(
      find.descendant(
        of: find.byKey(const ValueKey('feature-resizing')),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.selected, isTrue);
  });

  testWidgets('a feature with no switch has no dot', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane());

    for (final feature in _features) {
      final dot = find.byKey(ValueKey('feature-dot-${feature.id}'));
      if (feature.switchId == null) {
        expect(dot, findsNothing, reason: '${feature.id} cannot be turned off');
      } else {
        expect(dot, findsOneWidget, reason: feature.id);
      }
    }
  });

  testWidgets('typing narrows the list, and says what matched', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane());

    await tester.enterText(find.byType(TextField), 'anchor');
    await tester.pumpAndSettle();

    expect(find.text('Tooltips'), findsOneWidget);
    expect(find.text('Cell Anchor'), findsOneWidget,
        reason: 'a reader sees where the setting lives before opening it');
    expect(find.text('Sorting'), findsNothing);
  });

  testWidgets('a setting is found while its feature is off, and says so',
      (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane());

    await tester.enterText(find.byType(TextField), 'row card wait');
    await tester.pumpAndSettle();

    expect(find.text('Row Card Wait'), findsOneWidget);
    expect(find.textContaining('Turn on'), findsOneWidget,
        reason: 'silence cannot say whether a setting is missing or unusable');
  });

  testWidgets('clearing the search restores the list, and keeps the selection',
      (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane(selected: 'sorting'));

    await tester.enterText(find.byType(TextField), 'anchor');
    await tester.pumpAndSettle();
    expect(find.text('Sorting'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    for (final feature in _features) {
      expect(find.text(feature.title), findsOneWidget, reason: feature.id);
    }
    // A search is a way of getting somewhere. Arriving is not undone by
    // clearing the query that led there.
    final tile = tester.widget<ListTile>(
      find.descendant(
        of: find.byKey(const ValueKey('feature-sorting')),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.selected, isTrue);
  });

  testWidgets('the dot changes the table, not just the callback',
      (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterCheckbox), findsNothing,
        reason: 'the playground opens bare');

    await tester.tap(find.byKey(const ValueKey('feature-dot-selection')));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterCheckbox), findsWidgets,
        reason: 'the checkbox column exists only while selection is on');
  });
}
