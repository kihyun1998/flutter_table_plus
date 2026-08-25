import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/viewport_lab/viewport_lab_page.dart';
import 'package:example/preview/preview_stage.dart';
import 'package:example/preview/viewport_spec.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The page is the thin part; `preview_stage_test.dart` holds the claims that
// matter. What is pinned here is that the route exists, that switching viewport
// reaches the stage, and that the page builds with no app around it — the
// property #100 established and every page in this example now depends on.

void _surface(WidgetTester tester) {
  // Tall enough for a 1440x900 stage plus the app bar and the control row;
  // anything smaller and the stage is clipped, which would make every
  // assertion below an assertion about a clipped widget.
  tester.view.physicalSize = const Size(1800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

ViewportSpec _stageSpec(WidgetTester tester) =>
    tester.widget<PreviewStage>(find.byType(PreviewStage)).spec;

void main() {
  testWidgets('opens on desktop and renders one stage', (tester) async {
    _surface(tester);
    await tester.pumpWidget(const MaterialApp(home: ViewportLabPage()));
    await tester.pumpAndSettle();

    expect(find.byType(PreviewStage), findsOneWidget);
    expect(_stageSpec(tester), ViewportSpec.desktop,
        reason: 'the reader should start at the width they are already using');
  });

  testWidgets('choosing a viewport reaches the stage', (tester) async {
    _surface(tester);
    await tester.pumpWidget(const MaterialApp(home: ViewportLabPage()));
    await tester.pumpAndSettle();

    // Observed at the screen: the segment carries the label the spec promises,
    // so this survives the bar being rebuilt out of different widgets.
    await tester.tap(find.text(ViewportSpec.mobile.label));
    await tester.pumpAndSettle();

    expect(_stageSpec(tester), ViewportSpec.mobile);

    await tester.tap(find.text(ViewportSpec.tablet.label));
    await tester.pumpAndSettle();

    expect(_stageSpec(tester), ViewportSpec.tablet);
  });

  testWidgets('builds with no ExampleThemeScope above it', (tester) async {
    // Not incidental. The suite pumps pages directly, and the recipes this
    // page is a rehearsal for must be liftable out of the example entirely.
    _surface(tester);
    await tester.pumpWidget(const MaterialApp(home: ViewportLabPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(IconButton), findsNothing,
        reason: 'the theme control drew itself without a scope to read');
  });

  testWidgets('the table wears the demo theme and follows the app brightness',
      (tester) async {
    // This is here because the first draft of this page shipped without a
    // `theme:` at all. Nothing errored and every other test stayed green — the
    // table simply fell back to the package's light defaults, so a dark app
    // drew a white table. A defect visible only in one theme, and only to
    // someone looking.
    _surface(tester);

    Future<Color?> bodyGroundIn(Brightness brightness) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const ViewportLabPage(),
      ));
      await tester.pumpAndSettle();
      return tester
          .widget<FlutterTablePlus<Employee>>(
              find.byType(FlutterTablePlus<Employee>))
          .theme
          .bodyTheme
          .backgroundColor;
    }

    final light = await bodyGroundIn(Brightness.light);
    final dark = await bodyGroundIn(Brightness.dark);

    expect(light, isNotNull);
    expect(dark, isNotNull);
    expect(dark, isNot(light),
        reason: 'the table drew the same ground in both themes, which is what '
            'happens when no theme is passed at all');
  });
}
