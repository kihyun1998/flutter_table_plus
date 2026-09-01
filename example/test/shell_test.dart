import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/preview/preview_stage.dart';
import 'package:example/preview/viewport_spec.dart';
import 'package:example/shell/destinations/employee_demo.dart';
import 'package:example/shell/shell_destination.dart';
import 'package:example/shell/shell_menu.dart';
import 'package:example/shell/shell_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The shell is a menu, a stage and a knob region. What is asserted here is the
// division between them, because that is what the rest of the series depends on:
// a destination supplies a stage and some knobs, and the shell knows nothing
// else about it.
//
// The load-bearing one is the last group. The playground is **pointed at**, not
// absorbed — it is a full page with its own app bar and its own three panes, and
// embedding it would mean taking it apart. An earlier draft of #102 asked for
// exactly that, which is how this series nearly ended up rewriting the one thing
// it was supposed to leave alone.

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _narrow(WidgetTester tester) {
  // Under ShellPage.narrowBreakpoint, so the folded layout is what builds.
  tester.view.physicalSize = const Size(700, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpShell(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(brightness),
    home: const ShellPage(),
  ));
  await tester.pumpAndSettle();
}

/// The menu label of the scenario that refuses the Device Wall.
const _largeScenario = 'A hundred thousand rows';

/// The spec the single stage is showing.
///
/// **Outside wall mode only.** The Device Wall draws three `PreviewStage`s, and
/// `tester.widget` throws on more than one match — so a wall-mode test observes
/// by the frame labels instead (see "carries the wall as a fourth mode").
ViewportSpec _stageSpec(WidgetTester tester) =>
    tester.widget<PreviewStage>(find.byType(PreviewStage)).spec;

FlutterTablePlus<Employee> _table(WidgetTester tester) =>
    tester.widget<FlutterTablePlus<Employee>>(
        find.byType(FlutterTablePlus<Employee>));

void main() {
  group('the three regions', () {
    testWidgets('all three are present and hold real content', (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      expect(find.byType(ShellMenu), findsOneWidget);
      expect(find.byType(PreviewStage), findsOneWidget);

      // Not a placeholder: the knob region holds the open destination's own
      // controls, and they are wired to the table beside them.
      expect(find.byType(EmployeeDemoKnobs), findsOneWidget);
      expect(find.byType(EmployeeDemoTable), findsOneWidget);
    });

    testWidgets('a knob changes the table, not just itself', (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      expect(_table(tester).data, hasLength(24));

      await tester.tap(find.widgetWithText(ChoiceChip, '200'));
      await tester.pumpAndSettle();

      expect(_table(tester).data, hasLength(200),
          reason: 'the knob region and the stage are not talking');
    });

    testWidgets('turning selection off clears what was selected',
        (tester) async {
      // The state a naive model forgets: rows selected while selection was on
      // stay highlighted after it is turned off, with no control left to
      // unselect them.
      _wide(tester);
      await _pumpShell(tester);

      final demo = EmployeeDemo();
      addTearDown(demo.dispose);
      demo.toggle(demo.rows.first.id, true);
      expect(demo.selected, isNotEmpty);

      demo.selectable = false;
      expect(demo.selected, isEmpty);
      expect(demo.selectable, isFalse);
    });
  });

  group('the viewport control', () {
    testWidgets('changes the stage', (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      expect(_stageSpec(tester), ViewportSpec.desktop);

      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();

      expect(_stageSpec(tester), ViewportSpec.mobile);
    });

    testWidgets('and leaves the menu and the knob region their own size',
        (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      final menuBefore = tester.getSize(find.byType(ShellMenu));
      final knobsBefore = tester.getSize(find.byType(EmployeeDemoKnobs));

      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(ShellMenu)), menuBefore,
          reason: 'the menu shrank with the preview — the viewport control is '
              'meant to reach the stage and nothing else');
      expect(tester.getSize(find.byType(EmployeeDemoKnobs)), knobsBefore);
    });

    testWidgets('and carries the wall as a fourth mode', (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      // One frame to begin with: the wall is a mode you choose, not the
      // default.
      expect(find.textContaining('834 × 1112'), findsNothing);

      await tester.tap(find.byTooltip(ViewportBar.wallLabel));
      await tester.pumpAndSettle();

      for (final spec in ViewportSpec.values) {
        expect(
          find.textContaining('${spec.width.toInt()} × ${spec.height.toInt()}'),
          findsOneWidget,
          reason: '${spec.id} is missing from the wall',
        );
      }

      // The fit control goes with it. A wall column is whatever a third of the
      // stage region happens to be, so there is no real-pixel view to switch
      // to — and a control that can only make the view worse should not be on
      // screen.
      expect(find.text('Fit'), findsNothing);
      expect(find.text('1:1'), findsNothing);
    });

    testWidgets('and comes back out of it', (tester) async {
      // Additive in the direction that matters: choosing the wall is not a
      // one-way door, and the frame it returns to is the one it left.
      _wide(tester);
      await _pumpShell(tester);

      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();

      // Leave the fit control somewhere other than its default first. Without
      // this the assertion below cannot tell "preserved across the wall" from
      // "reset to the default", and setting `_fit = true` on every viewport
      // change would keep it green.
      await tester.tap(find.text('Fit'));
      await tester.pumpAndSettle();
      expect(find.text('1:1'), findsOneWidget);

      await tester.tap(find.byTooltip(ViewportBar.wallLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();

      expect(_stageSpec(tester), ViewportSpec.mobile);
      expect(find.text('1:1'), findsOneWidget,
          reason: 'the wall reset the fit control on the way through');
    });

    testWidgets('and does not offer it on a destination that refuses it',
        (tester) async {
      // The wall draws three tables over one state. The large-row-count
      // scenario is a single-table performance claim, so a frame rate measured
      // with the wall open is measuring the wall. #109.
      _wide(tester);
      await _pumpShell(tester);

      expect(find.byTooltip(ViewportBar.wallLabel), findsOneWidget);

      await tester.tap(find.text(_largeScenario));
      await tester.pumpAndSettle();

      expect(find.byTooltip(ViewportBar.wallLabel), findsNothing,
          reason: 'the wall is offered on a destination that refuses it');
    });

    testWidgets('and comes out of it when the destination chosen refuses it',
        (tester) async {
      // The one the exclusion actually turns on, and the one nothing reports.
      // `_viewportId` and the open destination are independent state: entering
      // the wall and then choosing a destination that refuses it leaves the
      // wall drawn with no segment to show it. Measured in the SDK source —
      // `SegmentedButton` asserts `segments.length > 0`,
      // `selected.length > 0 || emptySelectionAllowed` and
      // `selected.length < 2 || multiSelectionEnabled`, and **nothing** that
      // `selected` is a subset of `segments`; the highlight is decided
      // per-segment by `selected.contains(segment.value)`. So the invalid
      // state throws nothing, warns nothing, and simply draws a bar with
      // nothing selected over a wall that should not be there.
      _wide(tester);
      await _pumpShell(tester);

      await tester.tap(find.byTooltip(ViewportBar.wallLabel));
      await tester.pumpAndSettle();
      expect(find.byType(PreviewStage), findsNWidgets(3),
          reason: 'the wall did not open, so this proves nothing');

      await tester.tap(find.text(_largeScenario));
      await tester.pumpAndSettle();

      expect(find.byType(PreviewStage), findsOneWidget,
          reason: 'the wall survived a destination that refuses it');
      expect(find.byTooltip(ViewportBar.wallLabel), findsNothing);
    });

    testWidgets('and lands on the viewport it was in, not on a constant',
        (tester) async {
      // The asymmetry this closes: leaving the wall by picking a segment *is*
      // the reader's choice, so the voluntary path needs nothing. The forced
      // one had no choice to honour and used `desktop` — a constant
      // standing in for a decision, on the only path where the reader did not
      // ask to leave.
      _wide(tester);
      await _pumpShell(tester);

      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();
      expect(_stageSpec(tester), ViewportSpec.mobile);

      await tester.tap(find.byTooltip(ViewportBar.wallLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_largeScenario));
      await tester.pumpAndSettle();

      expect(_stageSpec(tester), ViewportSpec.mobile,
          reason: 'the forced exit dropped the reader on a viewport they had '
              'not chosen');
    });
  });

  group('the menu draws a category with nothing in it', () {
    testWidgets('and says so, which the shell can no longer show it doing',
        (tester) async {
      // Pumped directly rather than through `ShellPage`, and that is the whole
      // point of this test. Every `ShellCategory` has entries as of #109, so
      // the empty-state branch is unreachable from the app and a shell test
      // cannot reach it either. It is kept because the next category added is
      // added empty — exactly when it is needed, and exactly when nobody
      // would think to write it.
      _wide(tester);

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.light),
        home: Scaffold(
          body: ShellMenu(
            destinations: [
              StageDestination(
                id: 'only',
                label: 'The only one',
                category: ShellCategory.recipes,
                stage: (context) => const SizedBox.shrink(),
                knobs: (context) => const SizedBox.shrink(),
              ),
            ],
            selectedId: 'only',
            onSelected: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Two of the three categories have nothing in them, and each draws its
      // own line rather than one shared placeholder. Counted, not named.
      expect(find.text('nothing here yet'), findsNWidgets(2));
      expect(find.text('The only one'), findsOneWidget);
    });
  });

  group('the playground is pointed at, not absorbed', () {
    testWidgets('it is not built until it is chosen', (tester) async {
      // Narrower than it looks, and said plainly: this pins that opening the
      // shell does not build the playground, which would run its data
      // generation on every visit. It does *not* on its own prove the playground
      // is not embedded — embedding it as an unselected destination would keep
      // this green. The two tests below are the ones that catch that, measured
      // by turning the RouteDestination into a StageDestination.
      _wide(tester);
      await _pumpShell(tester);

      expect(find.byType(PlaygroundPage), findsNothing);
    });

    testWidgets('choosing it opens it on its own route', (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      await tester.tap(find.text('Every setting'));
      await tester.pumpAndSettle();

      expect(find.byType(PlaygroundPage), findsOneWidget);
      // Its own page, with its own app bar — not a pane inside the shell.
      expect(find.text('FlutterTablePlus Playground'), findsOneWidget);
      expect(find.byType(ShellMenu), findsNothing,
          reason: 'the shell is still on screen, so this was an embed');
    });

    testWidgets('and the shell is still there when it is closed',
        (tester) async {
      _wide(tester);
      await _pumpShell(tester);

      await tester.tap(find.text('Every setting'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ShellMenu), findsOneWidget);
      expect(find.byType(EmployeeDemoTable), findsOneWidget);
    });
  });

  group('narrow windows', () {
    testWidgets('fold to one region at a time rather than overflowing',
        (tester) async {
      _narrow(tester);
      await _pumpShell(tester);

      expect(tester.takeException(), isNull,
          reason: 'the shell overflowed instead of folding');

      // The menu is what the folded layout opens on; the stage is a tab away.
      expect(find.byType(ShellMenu), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Knobs'), findsOneWidget);
    });

    testWidgets('and the stage is reachable from there', (tester) async {
      _narrow(tester);
      await _pumpShell(tester);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.byType(PreviewStage), findsOneWidget);
    });

    testWidgets('and the wall is usable there, which is the surprising half',
        (tester) async {
      // The intuition is that three frames side by side must be worst in the
      // layout that folds *because* three regions do not fit side by side. It
      // is the other way round, measured 2026-09-01: folded at 700px each wall
      // column is 217px, while the wide layout at 1200px gives 200px — because
      // folding hands the stage the whole width instead of sharing it with the
      // menu and the 320px knob pane. So the wide layout is the narrow case.
      _narrow(tester);
      await _pumpShell(tester);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(ViewportBar.wallLabel));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      for (final spec in ViewportSpec.values) {
        expect(
          find.textContaining('${spec.width.toInt()} × ${spec.height.toInt()}'),
          findsOneWidget,
          reason: '${spec.id} did not survive the folded layout',
        );
      }
    });
  });

  testWidgets('builds with no ExampleThemeScope above it', (tester) async {
    // Every page in this example stays pumpable on its own; the recipes this
    // shell will host depend on it harder than the shell does.
    _wide(tester);
    await _pumpShell(tester);

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.brightness_auto_outlined), findsNothing,
        reason: 'the theme control drew itself without a scope to read');
  });

  testWidgets('the table follows the app brightness', (tester) async {
    _wide(tester);

    await _pumpShell(tester, brightness: Brightness.light);
    final light = _table(tester).theme.bodyTheme.backgroundColor;

    await _pumpShell(tester, brightness: Brightness.dark);
    final dark = _table(tester).theme.bodyTheme.backgroundColor;

    expect(dark, isNot(light),
        reason: 'a dark app drew a light table — the destination is not '
            'reading the brightness');
  });
}
