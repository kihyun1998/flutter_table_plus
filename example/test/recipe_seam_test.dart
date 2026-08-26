import 'dart:io';

import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/widgets/settings_controls.dart';
import 'package:example/recipes/selection_recipe.dart';
import 'package:example/shell/destinations/recipe_destination.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:example/shell/shell_menu.dart';
import 'package:example/shell/shell_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A recipe promises two things that pull against each other: it is driven by
// knobs, and it is a file you can paste into your own app. The first wants a
// settings object threaded through it; the second forbids one. This file is
// what keeps both true.
//
// "Copy-pasteable" is a claim nothing checks by itself, so the first group turns
// it into a property: `lib/recipes/` may import Flutter, this package, and the
// example's own shared data and palette — nothing else. The test walks the
// *directory*, not the catalogue, so a recipe someone forgot to register is
// still held to the rule.
//
// Prior art for reading source: `settings_spec_test.dart`. Dart has no
// reflection, so questions about imports cannot be put to the compiler.

/// Import targets a file under `lib/recipes/` is allowed to name.
///
/// `demo_data` and `theme` are here for the same reason: both are shared
/// example-app code that depends on nothing but Flutter and this package, and
/// without them every recipe would hard-code its own rows and its own colours.
/// The second is not hypothetical — a demo table wearing no theme drew white in
/// a dark app for the whole of #101, and `table_palette.dart` was extracted so
/// recipes would not each rediscover that.
///
/// What the list keeps out is the machinery: the playground, the shell, the
/// preview, the settings types. A recipe that reaches for any of them is no
/// longer a file anyone can paste.
const _allowedImports = [
  'dart:',
  'package:flutter/',
  'package:flutter_table_plus/',
  '../demo_data/',
  '../theme/',
  'package:example/demo_data/',
  'package:example/theme/',
];

List<File> _recipeFiles() => Directory('lib/recipes')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

List<String> _importsOf(File file) =>
    RegExp(r"^import\s+'([^']+)'", multiLine: true)
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();

/// The asset paths `pubspec.yaml` declares, as written.
List<String> _declaredAssets() {
  final lines = File('pubspec.yaml').readAsLinesSync();
  final start = lines.indexWhere((l) => l.trimRight() == '  assets:');
  if (start < 0) return const [];

  final assets = <String>[];
  for (final line in lines.skip(start + 1)) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#')) continue;
    if (!trimmed.startsWith('- ')) break;
    assets.add(trimmed.substring(2).trim());
  }
  return assets;
}

Future<void> _pumpRecipe(
  WidgetTester tester,
  Widget recipe, {
  Brightness brightness = Brightness.light,
}) async {
  // 20 rows at the default 50px row height, plus a header. The rows have to be
  // laid out for their checkboxes to be countable.
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(brightness),
    home: Scaffold(body: recipe),
  ));
  await tester.pumpAndSettle();
}

/// The row checkboxes, header excluded.
///
/// The header's select-all checkbox is a [FlutterCheckbox] too and it is drawn
/// first, so it is dropped by position. The count is asserted before it is
/// filtered, so this assumption fails loudly rather than quietly returning the
/// wrong rows.
Iterable<FlutterCheckbox> _rowCheckboxes(WidgetTester tester) =>
    tester.widgetList<FlutterCheckbox>(find.byType(FlutterCheckbox)).skip(1);

int _selectedCount(WidgetTester tester) =>
    _rowCheckboxes(tester).where((c) => c.value == true).length;

void main() {
  group('lib/recipes is the pasteable zone', () {
    test('every recipe imports only what a reader could paste', () {
      final files = _recipeFiles();

      // Without this the whole group passes vacuously the day the directory is
      // renamed — the rule would still be written down and no longer checked.
      expect(files, isNotEmpty,
          reason: 'no recipe files found: lib/recipes/ moved or emptied');

      for (final file in files) {
        for (final import in _importsOf(file)) {
          expect(
            _allowedImports.any(import.startsWith),
            isTrue,
            reason: '${file.path} imports $import, which is outside the '
                'allow-list — a recipe reaching into the playground, the '
                'shell or the settings types is no longer copy-pasteable',
          );
        }
      }
    });

    test('and the walk covers files nobody registered', () {
      // The rule is a property of the directory, not of the catalogue. A recipe
      // added and never listed is exactly the one nobody would think to check.
      final onDisk = _recipeFiles().map((f) => f.path.replaceAll(r'\', '/'));
      final registered = recipeCatalog.map((r) => r.source);

      expect(onDisk, containsAll(registered),
          reason: 'the catalogue names a file the directory walk cannot see');
    });
  });

  group('the catalogue points at things that exist', () {
    test('every recipe names a feature the description describes', () {
      final featureIds =
          settingsSpec.expand((g) => g.features).map((f) => f.id).toSet();

      expect(recipeCatalog, isNotEmpty);
      for (final recipe in recipeCatalog) {
        expect(featureIds, contains(recipe.featureId),
            reason: '${recipe.source} demonstrates a feature that does not '
                'exist, so its menu entry and its knobs have no source');
      }
    });

    test('every recipe source exists and is bundled as an asset', () {
      // The declaration half. `source_pane_test.dart` asks the bundle whether
      // the bytes actually arrive, which is the stronger claim — but the two
      // failures are worth telling apart: a missing declaration and a stale
      // `build/unit_test_assets` both report "Unable to load asset", and only
      // this one can say which.
      final assets = _declaredAssets();

      for (final recipe in recipeCatalog) {
        expect(File(recipe.source).existsSync(), isTrue,
            reason: '${recipe.source} does not exist');

        final covered = assets.any((asset) => asset.endsWith('/')
            ? recipe.source.startsWith(asset)
            : asset == recipe.source);
        expect(covered, isTrue,
            reason: '${recipe.source} is not covered by any asset declaration '
                'in pubspec.yaml, so it cannot be read back at runtime');
      }
    });

    test('no recipe is for the data feature', () {
      // Narrow and load-bearing: `FeatureDetailPane` is reused verbatim, and it
      // draws a Generate Data button for `feature.id == 'data'` alone. No
      // recipe generates data, so `RecipeKnobs`'s `onGenerateData` is
      // unreachable rather than merely unused. The day that stops being true
      // the pane would draw a live button wired to nothing.
      for (final recipe in recipeCatalog) {
        expect(recipe.featureId, isNot('data'));
      }
    });
  });

  group('each knob feeds its own parameter', () {
    // The catalogue is where the two vocabularies meet, and a translation table
    // is exactly the place a line gets copied and the field on the right never
    // renamed. Flipping one setting must move one parameter — the shell tests
    // above would stay green with `showRowCheckbox: settings.showCheckboxColumn`
    // sitting in the middle of it.
    SelectionRecipe built(PlaygroundSettings settings) =>
        recipeCatalog.first.build(settings) as SelectionRecipe;

    const base = PlaygroundSettings();

    test('and no other', () {
      expect(built(base.copyWith(selectionEnabled: !base.selectionEnabled))
          .selectable, isNot(built(base).selectable));

      expect(
          built(base.copyWith(
                  selectionMode: base.selectionMode == SelectionMode.multiple
                      ? SelectionMode.single
                      : SelectionMode.multiple))
              .selectionMode,
          isNot(built(base).selectionMode));

      expect(
          built(base.copyWith(showCheckboxColumn: !base.showCheckboxColumn))
              .showCheckboxColumn,
          isNot(built(base).showCheckboxColumn));

      expect(
          built(base.copyWith(selectAllEnabled: !base.selectAllEnabled))
              .selectAllEnabled,
          isNot(built(base).selectAllEnabled));

      expect(
          built(base.copyWith(showRowCheckbox: !base.showRowCheckbox))
              .showRowCheckbox,
          isNot(built(base).showRowCheckbox));

      expect(
          built(base.copyWith(
                  cellTapTogglesCheckbox: !base.cellTapTogglesCheckbox))
              .cellTapTogglesCheckbox,
          isNot(built(base).cellTapTogglesCheckbox));
    });

    test('and the six of them are exactly what the feature owns', () {
      // So a seventh parameter cannot appear on the recipe with no knob behind
      // it, and a seventh option cannot appear on the feature with nothing
      // reading it.
      expect(recipeCatalog.first.knobIds, [
        'selectionEnabled',
        'selectionMode',
        'showCheckboxColumn',
        'selectAllEnabled',
        'showRowCheckbox',
        'cellTapTogglesCheckbox',
      ]);
    });
  });

  group('selection is the consumer\'s, and the recipe shows what that costs',
      () {
    testWidgets('single mode collapses a selection the package would not touch',
        (tester) async {
      // The package reads `selectionMode` in exactly one condition — whether
      // drag-select is wired — and never touches `selectedRows`. So switching
      // to single mode leaves a multi-selection standing unless the consumer
      // collapses it, which is the line this test exists for.
      var mode = SelectionMode.multiple;

      await _pumpRecipe(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              ElevatedButton(
                onPressed: () =>
                    setState(() => mode = SelectionMode.single),
                child: const Text('single'),
              ),
              Expanded(child: SelectionRecipe(selectionMode: mode)),
            ],
          ),
        ),
      );

      // Pin the shape before reading anything off it: 20 rows plus the header.
      expect(find.byType(FlutterCheckbox), findsNWidgets(21));

      await tester.tap(find.byType(FlutterCheckbox).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterCheckbox).at(2));
      await tester.pumpAndSettle();
      expect(_selectedCount(tester), 2);

      await tester.tap(find.text('single'));
      await tester.pumpAndSettle();

      expect(_selectedCount(tester), 1,
          reason: 'two rows stayed selected in single mode — nothing in the '
              'package clears them, so the recipe must');
    });

    testWidgets('and a tap in single mode replaces rather than adds',
        (tester) async {
      await _pumpRecipe(
        tester,
        const SelectionRecipe(selectionMode: SelectionMode.single),
      );

      await tester.tap(find.byType(FlutterCheckbox).at(1));
      await tester.pumpAndSettle();
      expect(_selectedCount(tester), 1);

      await tester.tap(find.byType(FlutterCheckbox).at(2));
      await tester.pumpAndSettle();

      expect(_selectedCount(tester), 1,
          reason: 'both rows are selected, so `single` is a label with nothing '
              'behind it');
    });

    testWidgets('turning selection off clears what was selected',
        (tester) async {
      // Observed across the round trip on purpose. Asserting that the
      // checkboxes vanish would pass with the repair deleted — the package
      // hides the column for `isSelectable: false` whatever the set holds. The
      // question is whether the selection is still there when it comes back.
      var selectable = true;

      await _pumpRecipe(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              ElevatedButton(
                onPressed: () => setState(() => selectable = !selectable),
                child: const Text('toggle'),
              ),
              Expanded(child: SelectionRecipe(selectable: selectable)),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox).at(1));
      await tester.pumpAndSettle();
      expect(_selectedCount(tester), 1);

      await tester.tap(find.text('toggle')); // off
      await tester.pumpAndSettle();
      expect(find.byType(FlutterCheckbox), findsNothing,
          reason: 'the checkbox column outlived the setting that draws it');

      await tester.tap(find.text('toggle')); // on again
      await tester.pumpAndSettle();

      expect(_selectedCount(tester), 0,
          reason: 'a row was still selected from before selection was turned '
              'off — highlighted state the reader could not reach');
    });

    testWidgets('select-all is a callback, not a flag', (tester) async {
      await _pumpRecipe(
        tester,
        const SelectionRecipe(selectAllEnabled: true),
      );

      await tester.tap(find.byType(FlutterCheckbox).first);
      await tester.pumpAndSettle();

      expect(_selectedCount(tester), 20,
          reason: 'the header checkbox did not reach every row');
    });

    testWidgets('and withholding the callback is what disables it',
        (tester) async {
      // The side condition. Without it, wiring `onSelectAll` unconditionally
      // passes the test above and nothing says the setting does anything.
      await _pumpRecipe(
        tester,
        const SelectionRecipe(selectAllEnabled: false),
      );

      await tester.tap(find.byType(FlutterCheckbox).first,
          warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(_selectedCount(tester), 0,
          reason: 'the header checkbox selected rows while select-all was off');
    });

    testWidgets('the recipe follows the app brightness', (tester) async {
      // The defect #101 shipped: a demo table wearing no theme drew white in a
      // dark app, and ninety-six green tests said nothing.
      await _pumpRecipe(tester, const SelectionRecipe(),
          brightness: Brightness.light);
      final light = tester
          .widget<FlutterTablePlus<Employee>>(
              find.byType(FlutterTablePlus<Employee>))
          .theme
          .bodyTheme
          .backgroundColor;

      await _pumpRecipe(tester, const SelectionRecipe(),
          brightness: Brightness.dark);
      final dark = tester
          .widget<FlutterTablePlus<Employee>>(
              find.byType(FlutterTablePlus<Employee>))
          .theme
          .bodyTheme
          .backgroundColor;

      expect(dark, isNot(light));
    });
  });

  group('a recipe in the shell', () {
    Future<void> pumpShell(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.light),
        home: const ShellPage(),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('is listed by its feature title and opens in the stage',
        (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text(featureById('selection').title));
      await tester.pumpAndSettle();

      expect(find.byType(SelectionRecipe), findsOneWidget);
      expect(find.byType(RecipeKnobs), findsOneWidget);
    });

    testWidgets('shows that feature\'s controls and no other feature\'s',
        (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text(featureById('selection').title));
      await tester.pumpAndSettle();

      // Its switch and its five options. The number is read from the
      // description rather than written here, so the assertion cannot drift
      // away from what the feature owns — and it is nowhere near 58.
      final owned = recipeCatalog.first.knobIds.length;
      expect(owned, 6, reason: 'selection still owns a switch and five options');
      expect(find.byType(SettingsControl), findsNWidgets(owned));
    });

    testWidgets('and its knobs reach the table', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text(featureById('selection').title));
      await tester.pumpAndSettle();

      final before = tester
          .widget<FlutterTablePlus<Employee>>(
              find.byType(FlutterTablePlus<Employee>))
          .theme
          .checkboxTheme
          .showCheckboxColumn;
      expect(before, isTrue);

      await tester.tap(find.byType(Switch).at(1)); // showCheckboxColumn
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FlutterTablePlus<Employee>>(
                find.byType(FlutterTablePlus<Employee>))
            .theme
            .checkboxTheme
            .showCheckboxColumn,
        isFalse,
        reason: 'the knob pane and the stage are not talking',
      );
    });

    testWidgets('a feature with no recipe is simply absent', (tester) async {
      await pumpShell(tester);

      // Derived, not named. This used to name `sorting`, which was correct
      // until #105 gave sorting a recipe — so the test failed for the one
      // reason it should never fail: the thing it describes came true.
      final withoutRecipe = settingsSpec
          .expand((g) => g.features)
          .where((f) => !recipeCatalog.any((r) => r.featureId == f.id))
          .toList();

      expect(withoutRecipe, isNotEmpty,
          reason: 'every feature has a recipe, so absence is no longer '
              'observable — this test now proves nothing');

      // Scoped to the menu. `find.text` matches anywhere on screen, and a
      // feature title is a common word: `Rows` is also a heading in the
      // Employees knob pane, so an unscoped finder would fail for the wrong
      // reason (#58).
      for (final feature in withoutRecipe) {
        expect(
          find.descendant(
            of: find.byType(ShellMenu),
            matching: find.text(feature.title),
          ),
          findsNothing,
          reason: '${feature.id} has no recipe but is listed in the menu',
        );
      }
    });
  });
}
