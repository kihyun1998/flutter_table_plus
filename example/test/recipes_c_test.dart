import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/recipes/dynamic_row_height_recipe.dart';
import 'package:example/recipes/merged_rows_recipe.dart';
import 'package:example/recipes/row_card_recipe.dart';
import 'package:example/recipes/tooltips_recipe.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/shell/destinations/recipe_destination.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:example/shell/shell_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:example/theme/table_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The four recipes #107 adds, and only what belongs to them.
//
// The package pins its own half already: `test/row_tooltip_test.dart` holds the
// card's gating, `test/merged_row_render_test.dart` holds what a merged group
// draws, and `test/table_calculators_test.dart` holds the height measurement.
// Re-asserting any of those here would mean fighting this app's fixtures for a
// fact proven with better ones — and the demo's own font makes every glyph a
// square, so a pixel measured here is not the one on screen.
//
// What is *not* proven anywhere else is the part each recipe writes: the
// three-way header-anchor translation, the `copyWith` that keeps a row card's
// bubble from resetting to package defaults, the group ids the merged recipe
// mints, and the promise that the height callback is the same object twice.

Future<void> _pump(
  WidgetTester tester,
  Widget recipe, {
  Brightness brightness = Brightness.light,
  Size size = const Size(1100, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(brightness),
    home: Scaffold(body: recipe),
  ));
  await tester.pumpAndSettle();
}

FlutterTablePlus<Employee> _table(WidgetTester tester) =>
    tester.widget<FlutterTablePlus<Employee>>(
        find.byType(FlutterTablePlus<Employee>));

/// The row cards on screen.
///
/// Identified by the anchor rather than by counting every tooltip: the package
/// passes `TooltipAnchor.pointer` explicitly when it wraps a *row* and leaves
/// it null for a cell, so this separates the two without knowing anything about
/// which columns the recipe silenced.
Iterable<FlutterTooltipPlus> _rowCards(WidgetTester tester) => tester
    .widgetList<FlutterTooltipPlus>(find.byType(FlutterTooltipPlus))
    .where((t) => t.anchor == TooltipAnchor.pointer);

Recipe _recipe(String featureId) =>
    recipeCatalog.firstWhere((r) => r.featureId == featureId);

void main() {
  group('the catalogue feeds each knob to its own parameter', () {
    // A translation table is exactly where a line gets copied and the field on
    // the right never renamed. Every shell test in the suite stays green with
    // `headerBehavior: settings.tooltipBehavior` sitting in the middle of it.
    const base = PlaygroundSettings();

    test('tooltips, all twelve of them', () {
      final recipe = _recipe('tooltips');
      TooltipsRecipe built(PlaygroundSettings s) =>
          recipe.build(s) as TooltipsRecipe;

      expect(built(base.copyWith(tooltipEnabled: !base.tooltipEnabled)).enabled,
          isNot(built(base).enabled));

      // The two behaviours are the pair most likely to be crossed: same type,
      // adjacent lines, names one word apart.
      expect(
          built(base.copyWith(tooltipBehavior: TooltipBehavior.never)).behavior,
          TooltipBehavior.never);
      expect(
          built(base.copyWith(tooltipBehavior: TooltipBehavior.never))
              .headerBehavior,
          isNot(TooltipBehavior.never),
          reason: 'the cell behaviour reached the header parameter');
      expect(
          built(base.copyWith(
                  headerTooltipBehavior: TooltipBehavior.onlyTextOverflow))
              .headerBehavior,
          TooltipBehavior.onlyTextOverflow);

      expect(built(base.copyWith(tooltipWaitDurationMs: 1234)).waitDuration,
          const Duration(milliseconds: 1234));
      expect(built(base.copyWith(tooltipDirection: TooltipDirection.top)).direction,
          TooltipDirection.top);
      expect(
          built(base.copyWith(tooltipAlignment: TooltipAlignment.start))
              .alignment,
          TooltipAlignment.start);
      expect(built(base.copyWith(tooltipAnchor: TooltipAnchor.pointer)).anchor,
          TooltipAnchor.pointer);
      expect(
          built(base.copyWith(tooltipShowArrow: !base.tooltipShowArrow))
              .showArrow,
          isNot(built(base).showArrow));
      expect(built(base.copyWith(tooltipOffset: 21)).offset, 21);
      expect(
          built(base.copyWith(showTooltipFormatter: !base.showTooltipFormatter))
              .showFormatter,
          isNot(built(base).showFormatter));
      expect(
          built(base.copyWith(showTooltipBuilder: !base.showTooltipBuilder))
              .showBuilder,
          isNot(built(base).showBuilder));

      expect(recipe.knobIds, [
        'tooltipEnabled',
        'tooltipBehavior',
        'headerTooltipBehavior',
        'tooltipWaitDurationMs',
        'tooltipDirection',
        'tooltipAnchor',
        'headerTooltipAnchor',
        'tooltipAlignment',
        'tooltipShowArrow',
        'tooltipOffset',
        'showTooltipFormatter',
        'showTooltipBuilder',
      ]);
    });

    test('and the header anchor keeps its three arms distinct', () {
      // The one translation in the catalogue that is not a pass-through: a
      // three-valued settings enum becomes a nullable package enum, and null
      // is a *meaning* rather than an absence. Collapsing `followCells` into
      // `child` would look identical on screen while deleting the fallback.
      final recipe = _recipe('tooltips');
      TooltipAnchor? anchorFor(HeaderTooltipAnchor choice) =>
          (recipe.build(base.copyWith(headerTooltipAnchor: choice))
                  as TooltipsRecipe)
              .headerAnchor;

      expect(anchorFor(HeaderTooltipAnchor.followCells), isNull);
      expect(anchorFor(HeaderTooltipAnchor.child), TooltipAnchor.child);
      expect(anchorFor(HeaderTooltipAnchor.pointer), TooltipAnchor.pointer);
    });

    test('row card', () {
      final recipe = _recipe('rowCard');
      RowCardRecipe built(PlaygroundSettings s) =>
          recipe.build(s) as RowCardRecipe;

      expect(built(base.copyWith(rowCardTooltip: !base.rowCardTooltip)).enabled,
          isNot(built(base).enabled));
      expect(built(base.copyWith(rowCardWaitDurationMs: 950)).waitDuration,
          const Duration(milliseconds: 950));

      // The card's wait is its own setting, not the cell tooltip's. Reading
      // `tooltipWaitDurationMs` here would be invisible until someone changed
      // one of them.
      expect(built(base.copyWith(tooltipWaitDurationMs: 4321)).waitDuration,
          isNot(const Duration(milliseconds: 4321)));

      expect(recipe.knobIds, ['rowCardTooltip', 'rowCardWaitDurationMs']);
    });

    test('merged rows, and dynamic row heights', () {
      final merged = _recipe('mergedRows');
      expect(
          (merged.build(base.copyWith(
                  mergedRowsEnabled: !base.mergedRowsEnabled))
              as MergedRowsRecipe)
              .merged,
          isNot((merged.build(base) as MergedRowsRecipe).merged));
      expect(merged.knobIds, ['mergedRowsEnabled']);

      final heights = _recipe('dynamicRowHeight');
      expect(
          (heights.build(base.copyWith(dynamicRowHeight: !base.dynamicRowHeight))
              as DynamicRowHeightRecipe)
              .perRowHeight,
          isNot((heights.build(base) as DynamicRowHeightRecipe).perRowHeight));
      expect(heights.knobIds, ['dynamicRowHeight']);
    });
  });

  group('the tooltips recipe hands the table the theme it was asked for', () {
    testWidgets('every knob lands on the cell tooltip theme', (tester) async {
      await _pump(
        tester,
        const TooltipsRecipe(
          anchor: TooltipAnchor.pointer,
          direction: TooltipDirection.top,
          alignment: TooltipAlignment.end,
          showArrow: true,
          offset: 17,
          waitDuration: Duration(milliseconds: 123),
        ),
      );

      final tooltip = _table(tester).theme.tooltipTheme;
      expect(tooltip.anchor, TooltipAnchor.pointer);
      expect(tooltip.direction, TooltipDirection.top);
      expect(tooltip.alignment, TooltipAlignment.end);
      expect(tooltip.showArrow, isTrue);
      expect(tooltip.offset, 17);
      expect(tooltip.waitDuration, const Duration(milliseconds: 123));
    });

    testWidgets('including the one whose default hides it', (tester) async {
      // `enabled` defaults to true on `TablePlusTooltipTheme` and the shared
      // demo theme never sets it, so asserting `isTrue` here passes with the
      // wiring deleted. Only the off state can observe the knob.
      await _pump(tester, const TooltipsRecipe(enabled: false));

      expect(_table(tester).theme.tooltipTheme.enabled, isFalse,
          reason: 'the tooltipEnabled knob reaches the recipe field and stops '
              'there — it never arrives at the table');
    });

    testWidgets('and keeps the shared palette while doing it', (tester) async {
      // The regression guard, not the semantic one. Constructing a fresh
      // `TablePlusTooltipTheme` instead of `copyWith`-ing the shared one would
      // satisfy every assertion above and silently reset the other two dozen
      // fields to package defaults — the failure class #50 recorded, one
      // sub-theme down.
      await _pump(tester, const TooltipsRecipe(offset: 17));

      expect(_table(tester).theme.tooltipTheme.textStyle.color,
          TablePalette.light.tooltipInk,
          reason: 'the bubble went back to the package default, so the theme '
              'was rebuilt rather than copied');
    });

    testWidgets('and the bubble inverts with the app brightness',
        (tester) async {
      // `_pump` carried a `brightness` parameter no caller used, so the two
      // colours this ticket added to the dark palette were asserted nowhere.
      // A tooltip is drawn *over* the page, so the two grounds must not agree.
      await _pump(tester, const TooltipsRecipe(),
          brightness: Brightness.dark);

      final dark = _table(tester).theme.tooltipTheme;
      expect(dark.backgroundColor, TablePalette.dark.tooltipBand);
      expect(dark.textStyle.color, TablePalette.dark.tooltipInk);
      expect(dark.backgroundColor, isNot(TablePalette.light.tooltipBand));
    });

    testWidgets('the header theme is null while it follows the cells',
        (tester) async {
      await _pump(tester, const TooltipsRecipe(anchor: TooltipAnchor.pointer));

      expect(_table(tester).theme.headerTooltipTheme, isNull,
          reason: 'a copy of tooltipTheme looks the same on screen and is not '
              'the fallback the recipe claims to demonstrate');
    });

    testWidgets('and is its own theme, anchored apart, when it is not',
        (tester) async {
      await _pump(
        tester,
        const TooltipsRecipe(
          anchor: TooltipAnchor.pointer,
          headerAnchor: TooltipAnchor.child,
          offset: 17,
        ),
      );

      final theme = _table(tester).theme;
      expect(theme.headerTooltipTheme?.anchor, TooltipAnchor.child);
      expect(theme.tooltipTheme.anchor, TooltipAnchor.pointer);
      // Everything but the anchor is shared, which is the claim the recipe's
      // comment makes about the two themes.
      expect(theme.headerTooltipTheme?.offset, 17);
    });

    testWidgets('exactly one row has its tooltip turned off by an empty string',
        (tester) async {
      // "An empty formatter is how you turn one row's tooltip off" is a claim
      // about `isActive`, which the generator randomises — over six rows there
      // was a one-in-four chance of no inactive employee and no demonstration.
      // Pinned in the recipe, asserted here.
      await _pump(tester, const TooltipsRecipe(showFormatter: true));

      final table = _table(tester);
      final formatter = table.columns['position']!.tooltipFormatter!;
      final silenced = table.data.where((e) => formatter(e).isEmpty).toList();

      expect(silenced, hasLength(1),
          reason: 'no row returns an empty tooltip, so the escape hatch the '
              'recipe documents is not on screen');
      expect(formatter(table.data.firstWhere((e) => e.isActive)), isNotEmpty);
    });

    testWidgets('a widget tooltip wins over a formatter', (tester) async {
      await _pump(
        tester,
        const TooltipsRecipe(showFormatter: true, showBuilder: true),
      );

      final position = _table(tester).columns['position']!;
      expect(position.tooltipFormatter, isNotNull);
      expect(position.tooltipBuilder, isNotNull,
          reason: 'both are set, and the package resolves the builder first — '
              'the recipe demonstrates the precedence, not one side of it');
    });

    testWidgets('and the data is mixed, which is the only state that shows '
        'a gate', (tester) async {
      // Asserted structurally rather than in pixels. This suite's font draws
      // every glyph as a square of the font size, so a width measured here is
      // not the width on screen. What the recipe actually claims is a property
      // of the strings: some positions run well past a 210px column and some
      // sit well inside it.
      await _pump(tester, const TooltipsRecipe());

      final table = _table(tester);
      expect(table.columns['position']!.width, 210);

      final lengths = table.data.map((e) => e.position.length).toList();
      // Deliberately loose on both sides. A 210px column at fontSize 13 fits
      // about 13 characters in this suite's square test font and far more in
      // the app's real one, so no single number is "the" threshold — what the
      // recipe needs is entries that clear it under either reading.
      expect(lengths.reduce((a, b) => a < b ? a : b), lessThan(10),
          reason: 'nothing here fits, so onlyTextOverflow and always look '
              'identical and the recipe demonstrates nothing');
      expect(lengths.reduce((a, b) => a > b ? a : b), greaterThan(40),
          reason: 'nothing here is cut, so no tooltip has anything to add');
    });
  });

  group('the row card is the consumer\'s widget, and the bubble gets out of '
      'its way', () {
    testWidgets('the tooltip around it draws nothing of its own',
        (tester) async {
      await _pump(tester, const RowCardRecipe());

      final rowTooltip = _table(tester).theme.rowTooltipTheme!;
      expect(rowTooltip.backgroundColor, Colors.transparent);
      expect(rowTooltip.padding, EdgeInsets.zero);
      expect(rowTooltip.elevation, 0);
      expect(rowTooltip.showArrow, isFalse);
    });

    testWidgets('and it is copied from the shared theme, not rebuilt',
        (tester) async {
      // Same guard as the tooltips recipe's, and it matters more here: this
      // theme names five fields out of thirty-odd, so a fresh construction
      // loses the most.
      await _pump(tester, const RowCardRecipe());

      expect(_table(tester).theme.rowTooltipTheme?.textStyle.color,
          TablePalette.light.tooltipInk);
    });

    testWidgets('the columns that would cover it are silenced', (tester) async {
      // The recipe's longest paragraph says these three are what let the card
      // appear at all: a cell tooltip nests inside the row tooltip and the
      // innermost wins, and every column ellipsizes by default. Deleting all
      // three `never`s breaks the headline behaviour and left the whole suite
      // green before this test existed.
      await _pump(tester, const RowCardRecipe());

      final columns = _table(tester).columns;
      for (final key in ['name', 'department', 'salary']) {
        expect(columns[key]!.tooltipBehavior, TooltipBehavior.never,
            reason: '$key would draw a cell tooltip over the card');
      }
      // And the one left loud on purpose, so the collision is demonstrable.
      expect(columns['position']!.tooltipBehavior,
          TooltipBehavior.onlyTextOverflow);
    });

    testWidgets('and one position is long enough for the collision to fire',
        (tester) async {
      // The `position` column is left loud so a truncated value beats the card
      // — but the generator's longest job title is twenty-four characters and
      // fits, so the demonstration had nothing to point at. Pinned in the
      // recipe; asserted here, because a pin nothing checks can be un-pinned
      // silently.
      await _pump(tester, const RowCardRecipe());

      final longest = _table(tester)
          .data
          .map((e) => e.position.length)
          .reduce((a, b) => a > b ? a : b);
      expect(longest, greaterThan(40),
          reason: 'nothing here is cut, so the cell tooltip never wins and the '
              'collision the recipe exists to show cannot happen');
    });

    testWidgets('the knobs reach it', (tester) async {
      await _pump(
        tester,
        const RowCardRecipe(
          enabled: false,
          waitDuration: Duration(milliseconds: 321),
        ),
      );

      final rowTooltip = _table(tester).theme.rowTooltipTheme!;
      expect(rowTooltip.enabled, isFalse);
      expect(rowTooltip.waitDuration, const Duration(milliseconds: 321));
    });

    testWidgets('an inactive employee gets no card, and an active one does',
        (tester) async {
      // Through the builder the table was actually handed, rather than by
      // hovering: what is being pinned is the recipe's per-row decision, and
      // whether just_tooltip then draws it is the package's business.
      await _pump(tester, const RowCardRecipe());

      final table = _table(tester);
      final builder = table.rowTooltipBuilder!;
      final context = tester.element(find.byType(FlutterTablePlus<Employee>));

      final withCard = table.data.where((e) => e.isActive).toList();
      final without = table.data.where((e) => !e.isActive).toList();

      expect(without, hasLength(2),
          reason: 'the recipe pins two inactive rows so this claim has '
              'something to point at');
      expect(builder(context, withCard.first), isNotNull);
      for (final employee in without) {
        expect(builder(context, employee), isNull);
      }
    });

    testWidgets('merging four rows takes four cards away', (tester) async {
      await _pump(tester, const RowCardRecipe());

      final before = _rowCards(tester).length;
      expect(before, greaterThan(4),
          reason: 'no cards on screen, so the next assertion cannot fail for '
              'the reason it is written for');

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(_table(tester).mergedGroups, hasLength(1));
      expect(_rowCards(tester).length, before - 4,
          reason: 'the four rows became one merged row, which the package '
              'returns unwrapped — so exactly four cards should be gone');
    });
  });

  group('a merged group is one row for layout and several for data', () {
    testWidgets('selecting it reports the group id, once', (tester) async {
      await _pump(tester, const MergedRowsRecipe());

      expect(_table(tester).mergedGroups, hasLength(3));
      expect(find.textContaining('selectedRows:'), findsNothing);

      await tester.tap(find.text('Engineering'));
      await tester.pumpAndSettle();

      expect(find.text('selectedRows: dept_Engineering'), findsOneWidget,
          reason: 'three employee ids arrived instead of the one group id');
    });

    testWidgets('and with merging off the same click reports a row',
        (tester) async {
      // The other arm. Without it, a strip that printed a constant would pass
      // the test above.
      await _pump(tester, const MergedRowsRecipe(merged: false));

      expect(_table(tester).mergedGroups, isEmpty);

      final rowId = _table(tester).data.first.id;
      await tester.tap(find.text(_table(tester).data.first.name));
      await tester.pumpAndSettle();

      expect(find.text('selectedRows: $rowId'), findsOneWidget);
      expect(find.textContaining('dept_'), findsNothing);
    });

    testWidgets('the summary row is the caller\'s, and so is the control',
        (tester) async {
      await _pump(tester, const MergedRowsRecipe());

      expect(find.text('Total'), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
      // "Expanded" adds a row; it does not hide the members. This is the one
      // place the API's vocabulary misleads, so it is pinned rather than
      // described.
      expect(find.text('Engineering'), findsOneWidget,
          reason: 'the group heading vanished, so expanding collapsed the '
              'group rather than adding to it');

      await tester.tap(find.byIcon(Icons.expand_less).first);
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsNothing);
    });
  });

  group('a row is as tall as the recipe says, and the recipe says once', () {
    testWidgets('the callback is the same object across a rebuild',
        (tester) async {
      // The claim the recipe's comment makes, turned into something that can
      // fail. An inline `(i, row) => ...` is a new object every build, and the
      // table re-walks every row to re-total its height whenever this identity
      // changes — silently, and proportionally to the row count.
      await _pump(tester, const DynamicRowHeightRecipe());
      final first = _table(tester).calculateRowHeight;

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.dark),
        home: const Scaffold(body: DynamicRowHeightRecipe()),
      ));
      await tester.pumpAndSettle();

      expect(identical(_table(tester).calculateRowHeight, first), isTrue,
          reason: 'the height callback changed identity on a rebuild that did '
              'not change the heights');
    });

    testWidgets('it is withheld entirely when the knob is off', (tester) async {
      await _pump(tester, const DynamicRowHeightRecipe(perRowHeight: false));

      expect(_table(tester).calculateRowHeight, isNull,
          reason: 'returning the theme height from the callback is not the '
              'same as not having one — the table caches differently');
    });

    testWidgets('and the rows it produces are not all the same height',
        (tester) async {
      await _pump(tester, const DynamicRowHeightRecipe());

      final table = _table(tester);
      final heights = <double?>{
        for (final (index, row) in table.data.indexed)
          table.calculateRowHeight!(index, row),
      };

      expect(heights.length, greaterThan(1),
          reason: 'every row measured the same, so the notes are not wrapping '
              'and the recipe demonstrates a constant');
      // No `everyElement(isNotNull)` here: `calculateTextHeight` is declared
      // `static double`, so a null is unreachable and the assertion would be
      // the type system agreeing with itself.
    });

    testWidgets('it measures at the width the column actually gets',
        (tester) async {
      // `width` is a *preference*: a flexible column grows into whatever
      // surplus the viewport has, so a recipe that measures at its declared
      // width measures at a number the layout never used. Measured at two
      // viewports on purpose — one of them would pass by coincidence.
      const declared = 300.0;
      const padding = 32.0;

      for (final width in [1100.0, 1600.0]) {
        await _pump(tester, const DynamicRowHeightRecipe(),
            size: Size(width, 900));

        final notes = _table(tester).columns['notes']!;
        expect(notes.maxWidth, declared,
            reason: 'without a ceiling the column stretches past the width the '
                'height was measured at');

        final painted = tester
            .renderObject<RenderBox>(
                find.textContaining('joined the').first)
            .size
            .width;
        expect(painted, closeTo(declared - padding, 1.0),
            reason: 'at a ${width}px viewport the notes text was laid out at '
                '$painted, not the ${declared - padding} the row height was '
                'computed for');
      }
    });

    testWidgets('and the style it measured in is the style it draws in',
        (tester) async {
      // The claim the recipe calls quiet when broken: a height measured in one
      // style and rendered in another is wrong by whatever the two differ by,
      // and the text simply clips. Dropping the `bodyTheme` override left all
      // 218 tests green before this existed.
      await _pump(tester, const DynamicRowHeightRecipe());

      final drawn = _table(tester).theme.bodyTheme.textStyle;
      expect(drawn.fontSize, 13);
      expect(drawn.height, 1.35,
          reason: 'the line height the measurement used did not reach the cell');
      // Merged onto the shared style, not assigned over it. Assigning drops the
      // palette's ink and the row falls back to whatever DefaultTextStyle had —
      // a colour nothing in this app chose, and legible only by luck.
      expect(drawn.color, TablePalette.light.ink,
          reason: 'the body style was replaced rather than merged, so the '
              'palette ink is gone');
    });

    testWidgets('the wrapped column is told to wrap', (tester) async {
      // The other half of the same decision. Height without this is empty
      // space under one clipped line, which is what makes the feature look
      // broken rather than absent.
      await _pump(tester, const DynamicRowHeightRecipe());

      expect(_table(tester).columns['notes']!.textOverflow,
          TextOverflow.visible);
    });
  });

  group('and each of the four is reachable from the shell', () {
    // The seam test opens `selection` and stops there, so until now nothing
    // said a *new* recipe arrives in the menu at all. A recipe that is
    // registered, bundled, and unreachable passes every other test in the
    // suite.
    Future<void> openFromMenu(WidgetTester tester, String featureId) async {
      tester.view.physicalSize = const Size(1800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.light),
        home: const ShellPage(),
      ));
      await tester.pumpAndSettle();

      // Not `scrollUntilVisible`: the shell has several scrollables and the
      // helper insists on exactly one. At this size the menu fits, and a
      // recipe that has fallen off the bottom of a real menu is a layout
      // question the shell's own tests own.
      final entry = find.text(featureById(featureId).title);
      expect(entry, findsOneWidget,
          reason: 'the menu does not list it once — #58: find.text matches '
              'anywhere on screen, so more than one is as bad as none');
      await tester.tap(entry);
      await tester.pumpAndSettle();
    }

    testWidgets('tooltips', (tester) async {
      await openFromMenu(tester, 'tooltips');
      expect(find.byType(TooltipsRecipe), findsOneWidget);
      expect(find.byType(RecipeKnobs), findsOneWidget);
    });

    testWidgets('row card', (tester) async {
      await openFromMenu(tester, 'rowCard');
      expect(find.byType(RowCardRecipe), findsOneWidget);
    });

    testWidgets('merged rows', (tester) async {
      await openFromMenu(tester, 'mergedRows');
      expect(find.byType(MergedRowsRecipe), findsOneWidget);
    });

    testWidgets('dynamic row heights', (tester) async {
      await openFromMenu(tester, 'dynamicRowHeight');
      expect(find.byType(DynamicRowHeightRecipe), findsOneWidget);
    });
  });
}
