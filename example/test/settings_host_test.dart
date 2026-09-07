import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

// The panes import nothing from this app — that used to be proved here by
// `portable_seam_test.dart` walking `lib/gallery/`, and is now proved by the
// panes living in another package, where an import of this one would not
// resolve. Either way it is a weaker claim than it sounds: a pane can be free of
// an import and still be unusable by anyone else — reading a global it happens
// to reach, assuming a spec shaped like this one's, needing an extras slot it
// was never given.
//
// This file is the other half, and the extraction did not retire it — it turned
// it around. Nothing below names a single type from this example: no
// PlaygroundSettings, no settingsSpec, no registry. It was written to fail on
// the day the panes needed something the port does not carry, so that the
// failure did not arrive during the move. The move happened and it stayed green.
// What it watches now is the other direction: `SettingsHost` belongs to a
// dependency, so the change that breaks this is an upstream release narrowing
// the port under a version range with `example/lib` untouched.
//
// It is also the cheapest description of what a consumer has to write, which is
// why the fake is a plain class rather than a mock.

/// Two groups, three features, one switch, one option. Small on purpose: a fake
/// that mirrors this app's spec would be testing this app's spec.
const _spec = [
  SettingGroup(
    id: 'shape',
    title: 'Shape',
    features: [
      SettingFeature(
        id: 'stripes',
        title: 'Stripes',
        switchId: 'stripesOn',
        options: ['stripeWidth'],
      ),
      SettingFeature(id: 'always', title: 'Always Live'),
    ],
  ),
  SettingGroup(
    id: 'other',
    title: 'Other',
    features: [
      SettingFeature(id: 'glow', title: 'Glow', switchId: 'glowOn'),
    ],
  ),
];

class _FakeHost extends SettingsHost {
  _FakeHost({Map<String, bool>? switches, this.withPresets = true})
      : switches = switches ?? {'stripesOn': false, 'glowOn': true};

  final bool withPresets;
  final List<String> applied = [];
  String? active = 'loud';

  @override
  List<PresetSummary> get presets => withPresets
      ? const [
          PresetSummary(id: 'loud', title: 'Loud', lookFor: 'Everything on.'),
          PresetSummary(id: 'quiet', title: 'Quiet', lookFor: 'Nothing on.'),
        ]
      : const [];

  @override
  String? get activePresetId => active;

  @override
  void applyPreset(String presetId) {
    applied.add(presetId);
    active = presetId;
  }

  final Map<String, bool> switches;
  final List<String> writes = [];

  @override
  List<SettingGroup> get spec => _spec;

  @override
  bool isOn(String switchId) => switches[switchId]!;

  @override
  void setSwitch(String switchId, bool on) {
    writes.add('$switchId=$on');
    switches[switchId] = on;
  }

  @override
  SettingsControl control(String settingId) => SettingsControl(
        id: settingId,
        label: 'Label for $settingId',
        child: Text('control:$settingId'),
      );
}

/// Overrides only what the port leaves abstract.
///
/// The optional members have defaults, and a fake that overrides them cannot
/// exercise those defaults — which is what a consumer who implements the
/// minimum actually gets. `_FakeHost` overrides `presets`, so without this
/// class the empty default was asserted nowhere and a port that started
/// offering phantom presets would not have reddened anything.
class _MinimalHost extends SettingsHost {
  @override
  List<SettingGroup> get spec => _spec;
  @override
  bool isOn(String switchId) => false;
  @override
  void setSwitch(String switchId, bool on) {}
  @override
  SettingsControl control(String settingId) =>
      SettingsControl(id: settingId, label: settingId, child: const SizedBox());
}

Widget _list(_FakeHost host, {String? selected}) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 220,
          child: FeatureListPane(
            host: host,
            selectedFeatureId: selected,
            onFeatureSelected: (_) {},
          ),
        ),
      ),
    );

Widget _detail(_FakeHost host, SettingFeature feature) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 380,
          child: FeatureDetailPane(host: host, feature: feature),
        ),
      ),
    );

void main() {
  group('the panes run on a host that knows nothing about this app', () {
    testWidgets('the list draws the host\'s spec, groups and all', (t) async {
      await t.pumpWidget(_list(_FakeHost()));

      // Headings are upper-cased by the pane, so the spec's own casing is not
      // what reaches the screen.
      expect(find.text('SHAPE'), findsOneWidget);
      expect(find.text('OTHER'), findsOneWidget);
      for (final title in ['Stripes', 'Always Live', 'Glow']) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });

    testWidgets(
        'a dot writes back through the port, not through a settings '
        'object', (t) async {
      final host = _FakeHost();
      await t.pumpWidget(_list(host));

      await t.tap(find.byKey(const ValueKey('feature-dot-stripes')));
      await t.pump();

      expect(host.writes, ['stripesOn=true'],
          reason: 'the pane no longer builds the new settings itself');
    });

    testWidgets('a feature with no switch draws no dot', (t) async {
      await t.pumpWidget(_list(_FakeHost()));

      expect(find.byKey(const ValueKey('feature-dot-always')), findsNothing);
      expect(find.byKey(const ValueKey('feature-dot-glow')), findsOneWidget);
    });

    testWidgets('the detail pane draws the controls the host hands it',
        (t) async {
      await t.pumpWidget(_detail(_FakeHost(), _spec.first.features.first));

      expect(find.text('control:stripesOn'), findsOneWidget);
      expect(find.text('control:stripeWidth'), findsOneWidget);
    });

    testWidgets('a host with no extras gets none, and says nothing to get them',
        (t) async {
      // `_FakeHost` overrides neither extras hook. Before the port these were
      // two `if (feature.id == 'data')` branches inside the pane, so a second
      // app got this app's Generate button or nothing at all.
      await t.pumpWidget(_detail(_FakeHost(), _spec.first.features.first));

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.textContaining('Generate'), findsNothing);
    });

    testWidgets('the preset bar draws the host\'s presets and their guidance',
        (t) async {
      final host = _FakeHost();
      await t
          .pumpWidget(MaterialApp(home: Scaffold(body: PresetBar(host: host))));

      expect(find.text('Loud'), findsOneWidget);
      expect(find.text('Quiet'), findsOneWidget);
      // The line that makes a preset worth its name: not which switches it
      // turned on, but what to watch now that they are.
      expect(find.text('Everything on.'), findsOneWidget);
    });

    testWidgets('picking one is a command by id, not a settings object',
        (t) async {
      final host = _FakeHost();
      await t
          .pumpWidget(MaterialApp(home: Scaffold(body: PresetBar(host: host))));

      await t.tap(find.text('Quiet'));
      await t.pump();

      expect(host.applied, ['quiet'],
          reason: 'the bar no longer hands back something it had to construct');
    });

    testWidgets(
        'a host with no presets gets no bar, and says nothing to get it',
        (t) async {
      // `SettingsHost.presets` defaults to empty, the same way the extras hooks
      // do. A gallery around a package with no named combinations should draw
      // no chrome for them rather than an empty strip with a border.
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: PresetBar(host: _FakeHost(withPresets: false))),
      ));

      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets(
        'a host that overrides only the essentials offers nothing extra',
        (t) async {
      // The defaults, exercised. Everything optional on the port is opt-in, so
      // implementing the minimum must produce a panel with no preset bar, no
      // extras and no active preset — never a piece of chrome announcing a
      // capability the host never claimed.
      final host = _MinimalHost();

      expect(host.presets, isEmpty);
      expect(host.activePresetId, isNull);
      expect(() => host.applyPreset('anything'), returnsNormally);

      await t
          .pumpWidget(MaterialApp(home: Scaffold(body: PresetBar(host: host))));
      expect(find.byType(ChoiceChip), findsNothing);

      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 380,
            child: FeatureDetailPane(
              host: host,
              feature: _spec.first.features.first,
            ),
          ),
        ),
      ));
      expect(find.byType(ElevatedButton), findsNothing);
    });

    test('search reads the spec and the labels through the port', () {
      final matches = searchFeatures('stripe', _FakeHost());

      expect(matches.map((m) => m.feature.id), ['stripes']);
      expect(matches.single.matchedLabels, ['Label for stripeWidth']);
      expect(matches.single.isOn, isFalse);
    });
  });
}
