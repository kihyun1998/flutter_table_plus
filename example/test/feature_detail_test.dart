import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/pages/playground/widgets/feature_detail_pane.dart';
import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The old panel held all fifty-eight controls at once, and its test counted
// them without naming them: 25 switches, 12 dropdowns, 20 sliders. That is what
// let the rendering move underneath it in #74 without losing anything.
//
// A detail pane draws one feature, so those numbers stop meaning anything. The
// property survives the assertion: a feature shows exactly the controls the
// description gives it — its switch, and its options, and nothing else.

/// Tooltips owns eleven options; the pane is 380 wide and a scroll does not
/// lazily build, but the view must still be tall enough to lay them out.
void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _pane(
  SettingFeature feature, {
  PlaygroundSettings settings = const PlaygroundSettings(),
  ValueChanged<PlaygroundSettings>? onSettingsChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      // The pane is 380 wide on the page. Under the widget-test font every
      // glyph is a square of the font size, so a row that fits on screen can
      // still burst here — the width has to be real for that to be caught.
      body: SizedBox(
        width: 380,
        child: FeatureDetailPane(
          settings: settings,
          feature: feature,
          onSettingsChanged: onSettingsChanged ?? (_) {},
          onGenerateData: () {},
        ),
      ),
    ),
  );
}

Iterable<SettingFeature> get _features =>
    settingsSpec.expand((g) => g.features);

void main() {
  testWidgets('a feature shows exactly the controls it owns', (tester) async {
    _tallView(tester);

    for (final feature in _features) {
      await tester.pumpWidget(_pane(feature));

      // Its switch, if it has one, and each of its options. An option is drawn
      // whether or not the feature is on — off is not the same as absent.
      final owned = feature.options.length + (feature.switchId == null ? 0 : 1);
      expect(find.byType(SettingsControl), findsNWidgets(owned),
          reason: feature.id);
    }
  });

  testWidgets('no control was lost when the wall became a list',
      (tester) async {
    _tallView(tester);

    // The old panel counted 25 switches, 12 dropdowns, 20 sliders in one pump.
    // The pane holds one feature, so the same count is summed across the
    // twenty. A feature drawing its own controls is not the same as the
    // registry still drawing all of them; this is the net under that.
    //
    // The sliders are 21, not 20. The old count was of what a reader could
    // reach with the default settings, and the row card's wait duration was
    // behind a switch that starts off, so it was never drawn. Nothing is hidden
    // here, so the three numbers now sum to 58 — the number of fields on
    // PlaygroundSettings, which `settings_id_test.dart` pins independently.
    var switches = 0, dropdowns = 0, sliders = 0;
    for (final feature in _features) {
      await tester.pumpWidget(_pane(feature));
      switches += find.byType(Switch).evaluate().length;
      dropdowns +=
          find.byWidgetPredicate((w) => w is DropdownButton).evaluate().length;
      sliders += find.byType(Slider).evaluate().length;
    }

    expect(switches, 25, reason: '16 feature switches + 9 boolean options');
    expect(dropdowns, 12);
    expect(sliders, 21);
    expect(switches + dropdowns + sliders, 58, reason: 'one per field');
  });

  testWidgets('the tooltip anchors are reachable', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane(
      featureById('tooltips'),
      settings: const PlaygroundSettings(tooltipEnabled: true),
    ));

    expect(find.text('Cell Anchor'), findsOneWidget);
    expect(find.text('Header Anchor'), findsOneWidget);
  });

  testWidgets('the pane says which feature it is showing', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane(featureById('tooltips')));

    expect(find.text('Tooltips'), findsOneWidget);
  });

  testWidgets('a feature that is off can be opened, and says what to turn on',
      (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_pane(featureById('rowCard')));

    expect(find.text('Row Card Wait'), findsOneWidget,
        reason: 'absent and non-existent are different things');
    expect(find.text('Turn on Row card to use these'), findsOneWidget,
        reason: 'said once for the feature, not once per option');
  });

  testWidgets('an off feature keeps its switch, and loses its options',
      (tester) async {
    PlaygroundSettings? changed;
    _tallView(tester);
    await tester.pumpWidget(_pane(
      featureById('tooltips'),
      // Tooltips are on by default; this pane is about a feature that is not.
      settings: const PlaygroundSettings(tooltipEnabled: false),
      onSettingsChanged: (s) => changed = s,
    ));

    // The feature's own switch is drawn first, and is the way out of the state
    // the rest of the pane is in.
    final switches = find.byType(Switch);
    await tester.tap(switches.first);
    await tester.pumpAndSettle();
    expect(changed, isNotNull, reason: 'the switch is how you turn it on');
    expect(changed!.tooltipEnabled, isTrue);

    changed = null;
    await tester.tap(switches.at(1), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(changed, isNull,
        reason: 'unavailable, not merely styled to look it');
  });

  testWidgets('turning the feature on makes its options reachable',
      (tester) async {
    PlaygroundSettings? changed;
    _tallView(tester);
    await tester.pumpWidget(_pane(
      featureById('tooltips'),
      settings: const PlaygroundSettings(tooltipEnabled: true),
      onSettingsChanged: (s) => changed = s,
    ));

    expect(find.text('Turn on Tooltips to use these'), findsNothing);

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(changed, isNotNull);
  });

  testWidgets('a feature says which others it changes, and what happens',
      (tester) async {
    _tallView(tester);

    // Read from the description, not restated here: a wording this test copied
    // would agree with itself forever.
    for (final feature in _features.where((f) => f.interactions.isNotEmpty)) {
      await tester.pumpWidget(_pane(feature));

      for (final i in feature.interactions) {
        expect(find.text(featureById(i.otherFeatureId).title), findsOneWidget,
            reason: '${feature.id} → ${i.otherFeatureId}');
        expect(find.text(i.effect), findsOneWidget, reason: feature.id);
      }
    }
  });

  testWidgets('a feature with no recorded interaction shows none',
      (tester) async {
    _tallView(tester);

    final quiet = _features.firstWhere((f) => f.interactions.isEmpty);
    await tester.pumpWidget(_pane(quiet));

    expect(find.text('Affects'), findsNothing, reason: quiet.id);
  });

  testWidgets('picking a feature opens it, and its switch changes the table',
      (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterCheckbox), findsNothing,
        reason: 'the playground opens bare');

    await tester.tap(find.text('Selection'));
    await tester.pumpAndSettle();

    final paneSwitch = find.descendant(
      of: find.byType(FeatureDetailPane),
      matching: find.byType(Switch),
    );
    expect(paneSwitch, findsWidgets, reason: 'the feature opened');

    await tester.tap(paneSwitch.first);
    await tester.pumpAndSettle();

    expect(find.byType(FlutterCheckbox), findsWidgets,
        reason: 'the checkbox column exists only while selection is on');
  });
}
