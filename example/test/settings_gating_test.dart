import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/widgets/performance_monitor.dart';
import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:example/pages/playground/widgets/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// An option belongs to a feature, and means nothing while that feature is off.
// So it is not there — until someone searches for it, and then it appears
// unavailable rather than absent. A search that finds nothing cannot tell you
// whether the setting does not exist or merely cannot be used.
//
// The row card is off by default, and its wait duration is its option. Before
// the description said so, that slider sat under the tooltip toggle and was
// adjustable while the card it belonged to was not even drawn.

const _cardWait = 'Row Card Wait';
const _cardFeature = 'Row card';

Widget _panel(PlaygroundSettings settings) {
  return MaterialApp(
    home: Scaffold(
      body: SettingsPanel(
        settings: settings,
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

Future<void> _openContent(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Content'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Content'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an option is absent while its feature is off', (tester) async {
    await tester.pumpWidget(_panel(const PlaygroundSettings()));
    await _openContent(tester);

    expect(find.text('Row Card Tooltip'), findsOneWidget,
        reason: 'the feature switch itself is always there');
    expect(find.text(_cardWait), findsNothing);
  });

  testWidgets('turning the feature on brings its option back', (tester) async {
    await tester.pumpWidget(
      _panel(const PlaygroundSettings(rowCardTooltip: true)),
    );
    await _openContent(tester);

    expect(find.text(_cardWait), findsOneWidget);
  });

  testWidgets('a search finds an option whose feature is off, and says so',
      (tester) async {
    await tester.pumpWidget(_panel(const PlaygroundSettings()));

    await tester.enterText(find.byType(TextField), 'row card wait');
    await tester.pumpAndSettle();

    expect(find.text(_cardWait), findsOneWidget,
        reason: 'absent is not the same as non-existent');
    expect(find.textContaining(_cardFeature), findsWidgets,
        reason: 'the search must say which feature would enable it');
  });

  testWidgets('an option surfaced by search cannot be changed', (tester) async {
    await tester.pumpWidget(_panel(const PlaygroundSettings()));

    await tester.enterText(find.byType(TextField), 'row card wait');
    await tester.pumpAndSettle();

    final control = find.ancestor(
      of: find.text(_cardWait),
      matching: find.byType(SettingsControl),
    );
    expect(
      find.descendant(of: control, matching: find.byType(IgnorePointer)),
      findsWidgets,
      reason: 'unavailable, not merely styled to look it',
    );
  });
}
