import 'package:example/gallery/gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// `portable_seam_test.dart` proves the panes import nothing from this app. That
// is a weaker claim than it sounds: a pane can be free of an import and still be
// unusable by anyone else — reading a global it happens to reach, assuming a
// spec shaped like this one's, needing an extras slot it was never given.
//
// This file is the other half. Nothing below names a single type from this
// example: no PlaygroundSettings, no settingsSpec, no registry. If the panes can
// be driven by a host built from scratch here, they can be driven by the next
// package's, and the port is *sufficient* rather than merely present.
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
  _FakeHost({Map<String, bool>? switches})
      : switches = switches ?? {'stripesOn': false, 'glowOn': true};

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

    test('search reads the spec and the labels through the port', () {
      final matches = searchFeatures('stripe', _FakeHost());

      expect(matches.map((m) => m.feature.id), ['stripes']);
      expect(matches.single.matchedLabels, ['Label for stripeWidth']);
      expect(matches.single.isOn, isFalse);
    });
  });
}
