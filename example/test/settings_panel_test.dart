import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/widgets/performance_monitor.dart';
import 'package:example/pages/playground/widgets/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A characterisation test, written before the panel is split across files. It
// exists to notice a control going missing during a move that is meant to
// change nothing.
//
// The counts are derived from the call sites in the source, not copied from a
// test run. They cover every control at once without naming any of it, which is
// the point: naming 68 controls would rewrite the panel in test form, and the
// names are exactly what a later navigability pass is free to change.

const _sectionTitles = [
  'Data Settings',
  'Style Settings',
  'Header Border / Divider',
  'Feature Toggles',
  'Tooltip Settings',
];

/// Only 'Data Settings' starts expanded, and a collapsed [ExpansionTile] does
/// not build its children — so nothing can be counted until each section is
/// opened.
Future<void> _expandEverySection(WidgetTester tester) async {
  for (final title in _sectionTitles) {
    final tile = find.ancestor(
      of: find.text(title),
      matching: find.byType(ExpansionTile),
    );
    if (tester.widget<ExpansionTile>(tile).initiallyExpanded) continue;

    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }
}

Widget _panel({PlaygroundSettings settings = const PlaygroundSettings()}) {
  return MaterialApp(
    home: Scaffold(
      // The test font draws every glyph as a square of the font size, so the
      // panel's labels measure far wider here than on screen and burst a dozen
      // of its fixed-width rows. This test counts controls; it does not judge
      // layout. Shrink the text until the labels fit and the counting can
      // proceed. (Those rows are fragile under a real accessibility text scale
      // too — a separate concern from moving them between files.)
      body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
        child: SettingsPanel(
          settings: settings,
          performanceMetrics: PerformanceMetrics(
            rowCount: 0,
            lastUpdate: DateTime.fromMillisecondsSinceEpoch(0),
          ),
          onSettingsChanged: (_) {},
          onGenerateData: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('every section is rendered', (tester) async {
    await tester.pumpWidget(_panel());

    for (final title in _sectionTitles) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  testWidgets('every control is rendered', (tester) async {
    await tester.pumpWidget(_panel());
    await _expandEverySection(tester);

    expect(find.byType(Switch), findsNWidgets(25));
    expect(
        find.byWidgetPredicate((w) => w is DropdownButton), findsNWidgets(12));
    expect(find.byType(Slider), findsNWidgets(20));
  });

  testWidgets('the tooltip anchors are reachable', (tester) async {
    await tester.pumpWidget(_panel());
    await _expandEverySection(tester);

    expect(find.text('Cell Anchor'), findsOneWidget);
    expect(find.text('Header Anchor'), findsOneWidget);
  });
}
