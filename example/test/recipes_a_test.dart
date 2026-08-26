import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/recipes/cell_editing_recipe.dart';
import 'package:example/recipes/drag_selection_recipe.dart';
import 'package:example/recipes/selection_recipe.dart';
import 'package:example/recipes/sorting_recipe.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:example/theme/table_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Sorting, drag selection and cell editing.
//
// The ticket is explicit that feature *behaviour* is the package suite's job,
// not this one's — so what is asserted here is only what a recipe can get wrong
// on its own. Each of the three has exactly one such thing, and each is a line
// of consumer code the package cannot write:
//
//   sorting   — the table hands you the next direction and sorts nothing. You
//               keep the original list, or `SortDirection.none` has nowhere to
//               go back to.
//   dragging  — four terms must hold at once or no handler is attached, and
//               three of them are invisible on screen.
//   editing   — `onCellChanged` reports. Skip the write-back and the cell snaps
//               to its old value, which looks exactly like a package bug.
//
// Plus the thing #112 predicted would land here: two sub-themes the demo never
// set, both shipping blue.

const _rows = 20;

Future<void> _pump(WidgetTester tester, Widget recipe,
    {Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(body: recipe),
  ));
  await tester.pumpAndSettle();
}

FlutterTablePlus<Employee> _table(WidgetTester tester) =>
    tester.widget<FlutterTablePlus<Employee>>(
        find.byType(FlutterTablePlus<Employee>));

/// The rows in the order they are on screen, read off the widget rather than
/// the render tree — the recipe owns the list, and the list is the claim.
List<Employee> _data(WidgetTester tester) => _table(tester).data;

void main() {
  group('every recipe in this batch stands up alone', () {
    // The ticket's smoke criterion: renders with default settings and no shell.
    for (final entry in <String, Widget>{
      'sorting': const SortingRecipe(),
      'drag selection': const DragSelectionRecipe(),
      'cell editing': const CellEditingRecipe(),
    }.entries) {
      testWidgets('${entry.key} pumps and draws a table', (tester) async {
        await _pump(tester, entry.value);

        expect(tester.takeException(), isNull);
        expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
        expect(_data(tester), hasLength(_rows));
      });

      testWidgets('${entry.key} follows the app brightness', (tester) async {
        // #101's defect: a demo table wearing no theme drew white in a dark app
        // while ninety-six tests stayed green.
        await _pump(tester, entry.value);
        final light = _table(tester).theme.bodyTheme.backgroundColor;

        await _pump(tester, entry.value, brightness: Brightness.dark);
        final dark = _table(tester).theme.bodyTheme.backgroundColor;

        expect(dark, isNot(light));
      });
    }
  });

  group('sorting is a request, and none is a real state', () {
    testWidgets('a click reorders, and a third click restores the original',
        (tester) async {
      await _pump(tester, const SortingRecipe());

      final original = List.of(_data(tester));
      expect(original, hasLength(_rows));

      // Ascending.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      final asc = _data(tester).map((e) => e.name).toList();
      expect(asc, equals(List.of(asc)..sort()),
          reason: 'the recipe did not sort — the table does not do it for you');

      // Descending.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(_data(tester).map((e) => e.name).toList(),
          equals(asc.reversed.toList()));

      // Back to unsorted. This is the assertion the second list exists for:
      // without keeping the original order there is nothing to return to, and
      // `SortDirection.none` would have to mean "leave it descending".
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(_data(tester).map((e) => e.id).toList(),
          equals(original.map((e) => e.id).toList()),
          reason: 'the third click did not restore the arrival order');
    });

    testWidgets('and the header state is handed back down', (tester) async {
      // Otherwise the arrow freezes on the first click while the rows keep
      // moving — a disagreement between the header and the body that no
      // exception reports.
      await _pump(tester, const SortingRecipe());
      expect(_table(tester).sortColumnKey, isNull);
      expect(_table(tester).sortDirection, SortDirection.none);

      await tester.tap(find.text('Department'));
      await tester.pumpAndSettle();

      expect(_table(tester).sortColumnKey, 'department');
      expect(_table(tester).sortDirection, SortDirection.ascending);
    });

    testWidgets('a column without the flag is not sortable', (tester) async {
      // `sortable` is per column, so a table offers sorting where it means
      // something and refuses it where it does not.
      await _pump(tester, const SortingRecipe());

      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();

      expect(_table(tester).sortColumnKey, isNull,
          reason: 'a column with sortable: false accepted a sort');
    });

    testWidgets('and withholding onSort is what makes headers inert',
        (tester) async {
      await _pump(tester, const SortingRecipe(sortable: false));

      expect(_table(tester).onSort, isNull);

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      expect(_table(tester).sortColumnKey, isNull);
    });
  });

  group('drag selection wires on four terms, not one', () {
    testWidgets('all four hold by default and a drag selects', (tester) async {
      await _pump(tester, const DragSelectionRecipe());

      final table = _table(tester);
      expect(table.enableDragSelection, isTrue);
      expect(table.isSelectable, isTrue);
      expect(table.selectionMode, SelectionMode.multiple);
      expect(table.onDragSelectionUpdate, isNotNull,
          reason: 'the term everybody forgets — without it no handler is '
              'attached at all, silently');
    });

    testWidgets('and the strip says so, because three of them are invisible',
        (tester) async {
      await _pump(tester, const DragSelectionRecipe());
      expect(find.text('drag is wired'), findsOneWidget);

      await _pump(tester, const DragSelectionRecipe(dragSelection: false));
      expect(find.text('drag does nothing'), findsOneWidget,
          reason: 'the knob is off and the table looks completely normal, '
              'which is the whole reason this strip exists');
      expect(find.textContaining('✗ enableDragSelection'), findsOneWidget);
    });

    testWidgets('the update callback replaces rather than adds',
        (tester) async {
      // It fires continuously and carries the whole covered set. Adding would
      // make the band unable to shrink — rows would stay selected after the
      // pointer moved back off them.
      await _pump(tester, const DragSelectionRecipe());

      _table(tester).onDragSelectionUpdate!({'a', 'b', 'c'});
      await tester.pumpAndSettle();
      expect(_table(tester).selectedRows, {'a', 'b', 'c'});

      _table(tester).onDragSelectionUpdate!({'a'});
      await tester.pumpAndSettle();
      expect(_table(tester).selectedRows, {'a'},
          reason: 'the set grew instead of being replaced, so a shrinking '
              'band can never deselect');
    });

    testWidgets('and end fires once, separately from update', (tester) async {
      await _pump(tester, const DragSelectionRecipe());
      expect(find.textContaining('0 drags completed'), findsOneWidget);

      _table(tester).onDragSelectionUpdate!({'a', 'b'});
      await tester.pumpAndSettle();
      expect(find.textContaining('0 drags completed'), findsOneWidget,
          reason: 'update counted as a completed drag — the two callbacks are '
              'not interchangeable');

      _table(tester).onDragSelectionEnd!({'a', 'b'});
      await tester.pumpAndSettle();
      expect(find.textContaining('1 drags completed'), findsOneWidget);
    });
  });

  group('a commit reports; the recipe writes back', () {
    testWidgets('an edit reaches the list', (tester) async {
      await _pump(tester, const CellEditingRecipe());

      final before = _data(tester);
      final row = before[3];

      _table(tester).onCellChanged!(row, 'name', 3, row.name, 'Renamed');
      await tester.pumpAndSettle();

      expect(_data(tester)[3].name, 'Renamed',
          reason: 'without the write-back the cell snaps to its old value, '
              'which looks exactly like a package bug');
      // And nothing else moved.
      expect(_data(tester), hasLength(_rows));
      expect(_data(tester)[3].id, row.id);
      expect(_data(tester)[2].name, before[2].name);
    });

    testWidgets('an int column parses, and a bad number keeps the old value',
        (tester) async {
      await _pump(tester, const CellEditingRecipe());
      final row = _data(tester)[1];

      _table(tester).onCellChanged!(row, 'salary', 1, row.salary, '123456');
      await tester.pumpAndSettle();
      expect(_data(tester)[1].salary, 123456);

      _table(tester).onCellChanged!(
          _data(tester)[1], 'salary', 1, 123456, 'not a number');
      await tester.pumpAndSettle();
      expect(_data(tester)[1].salary, 123456,
          reason: 'an unparseable salary overwrote a good one');
    });

    testWidgets('a read-only column has no editable flag', (tester) async {
      // Editing is per column, not a mode.
      await _pump(tester, const CellEditingRecipe());
      final columns = _table(tester).columns;

      expect(columns['name']!.editable, isTrue);
      expect(columns['email']!.editable, isFalse,
          reason: 'the read-only column became editable, so the flag is not '
              'what decides it');
    });

    testWidgets('and the table-level switch gates all of them', (tester) async {
      await _pump(tester, const CellEditingRecipe(editable: false));
      expect(_table(tester).isEditable, isFalse);
      // The column flags are untouched: the table opens the door, the column
      // decides whether to walk through it.
      expect(_table(tester).columns['name']!.editable, isTrue);
    });
  });

  group('the two sub-themes #112 predicted would land here', () {
    // "On the day #105 lands, an achromatic example app draws a #448AFF rubber
    // band and a #2196F3 edit border." It would have.
    test('are set by the demo theme, in both brightnesses', () {
      for (final brightness in Brightness.values) {
        final theme = demoTableTheme(brightness);

        expect(theme.dragSelectionTheme.borderColor,
            isNot(const Color(0xFF448AFF)),
            reason: 'the package default blue rubber band survived into an '
                'achromatic app ($brightness)');
        expect(theme.dragSelectionTheme.fillColor,
            isNot(const Color(0x33448AFF)));
        expect(theme.editableTheme.editingBorderColor,
            isNot(const Color(0xFF2196F3)),
            reason: 'the package default blue edit border survived ($brightness)');
        expect(theme.editableTheme.cursorColor, isNot(const Color(0xFF2196F3)));
      }
    });

    test('the checkbox tick is not the same colour as the box', () {
      // Measured 2026-08-26: `flutter_checkbox` resolves `activeColor` from
      // `ColorScheme.primary` but hard-codes `checkColor` to `Colors.white`.
      // This app's dark scheme has `primary == #FFFFFF`, so leaving the style
      // unset draws a white tick on a white box and the checkmark vanishes.
      // Ordinary themes hide this — it only surfaces when `primary` is white.
      for (final brightness in Brightness.values) {
        final style = demoTableTheme(brightness).checkboxTheme.style;

        expect(style.activeColor, isNotNull,
            reason: 'unset falls through to ColorScheme.primary ($brightness)');
        expect(style.checkColor, isNotNull,
            reason: 'unset falls through to a hard-coded white ($brightness)');
        expect(style.checkColor, isNot(style.activeColor),
            reason: 'the tick is the same colour as the box it sits in '
                '($brightness) — invisible');
      }
    });

    testWidgets('and a recipe that reshapes the checkbox keeps that style',
        (tester) async {
      // #50's failure class, in a new place. Building a fresh
      // `TablePlusCheckboxTheme` to set three flags keeps those three and
      // silently drops `style`, so the tick goes back to white-on-white in dark
      // mode with nothing going red. `copyWith` on the sub-theme is the fix,
      // and this is what notices if it is ever unwritten.
      await _pump(tester, const SelectionRecipe(), brightness: Brightness.dark);

      final applied = tester
          .widget<FlutterTablePlus<Employee>>(
              find.byType(FlutterTablePlus<Employee>))
          .theme
          .checkboxTheme;
      final palette = demoTableTheme(Brightness.dark).checkboxTheme;

      expect(applied.style.checkColor, palette.style.checkColor,
          reason: 'the recipe rebuilt the checkbox sub-theme and lost `style`');
      expect(applied.style.activeColor, palette.style.activeColor);
      // And the three flags it meant to set are still set.
      expect(applied.showCheckboxColumn, isTrue);
    });

    test('and the sort icons are coloured, unsorted included', () {
      // `SortIcons` holds widgets, so the only way to colour an arrow is to
      // rebuild the glyphs. The unsorted one ships `Colors.grey` hard-coded in
      // `table_column.dart` — outside the theme files, so outside #112's count.
      for (final brightness in Brightness.values) {
        final icons = demoTableTheme(brightness).headerTheme.sortIcons;
        final unsorted = icons.unsorted! as Icon;
        expect(unsorted.color, isNotNull);
        expect(unsorted.color, isNot(Colors.grey),
            reason: 'the package default grey survived ($brightness)');
        expect((icons.ascending as Icon).color, isNotNull);
      }
    });

    test('the palette has no field nobody reads', () {
      // Three fields sat here declared in both brightnesses and read by nobody
      // until this ticket: headerLine, sortIcon, sortIconIdle. They had been
      // written *for* sorting and never wired. Nothing in the analyzer notices
      // a dead field on a class the app constructs.
      final light = TablePalette.light;
      final dark = TablePalette.dark;
      final themes = [demoTableTheme(Brightness.light)];

      for (final colour in [
        light.headerLine,
        light.sortIcon,
        light.sortIconIdle,
        light.dragBand,
        light.dragBandEdge,
        light.editingCell,
        light.editingLine,
        light.editingCursor,
      ]) {
        expect(colour, isNotNull);
      }
      expect(dark.headerLine, isNot(light.headerLine));
      expect(themes.single.headerTheme.bottomBorder.color, light.headerLine,
          reason: 'headerLine is declared and still unread');
    });
  });

  group('the catalogue grew by three', () {
    test('and each names a feature that exists', () {
      final ids = recipeCatalog.map((r) => r.featureId).toList();
      expect(ids, containsAll(['selection', 'sorting', 'dragSelection', 'editing']));

      final featureIds =
          settingsSpec.expand((g) => g.features).map((f) => f.id).toSet();
      for (final recipe in recipeCatalog) {
        expect(featureIds, contains(recipe.featureId));
      }
    });

    test('and each knob set is small, with one enumerated exception', () {
      // The point of the whole shell: a feature's controls, not sixty.
      //
      // `tooltips` is over the bound and is named here rather than the bound
      // being raised to fit it. Its twelve are twelve independent theme fields
      // — when, where, how long, which anchor, which direction, which
      // alignment, arrow, offset, and two content overrides — and there is no
      // smaller honest set: dropping one would mean a knob the playground has
      // and the recipe silently does not. Naming it keeps a ninth knob on any
      // *other* recipe a failure, which is what the bound is for.
      const exceptions = {'tooltips': 12};

      for (final recipe in recipeCatalog) {
        final allowed = exceptions[recipe.featureId] ?? 8;
        expect(recipe.knobIds.length, lessThanOrEqualTo(allowed),
            reason: '${recipe.featureId} owns ${recipe.knobIds.length} knobs, '
                'over its allowance of $allowed');
      }

      // And an exception that stops being one is a stale exception: it would
      // sit here forever, quietly permitting a bound nothing needs.
      for (final entry in exceptions.entries) {
        final recipe =
            recipeCatalog.where((r) => r.featureId == entry.key).firstOrNull;
        expect(recipe, isNotNull,
            reason: '${entry.key} is exempted and has no recipe');
        expect(recipe!.knobIds.length, greaterThan(8),
            reason: '${entry.key} no longer needs its exemption — it owns '
                '${recipe.knobIds.length} knobs, which the plain bound allows');
      }
    });
  });
}
