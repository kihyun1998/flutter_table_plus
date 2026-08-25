import 'dart:io';

import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:example/theme/theme_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Two themes live in this example and they are not the same thing. `exampleTheme`
// dresses the application; `buildPlaygroundTheme` builds the package's own
// `TablePlusTheme` from the settings. These tests assert the relationships that
// keep them apart and keep the dark variant whole.
//
// They assert no colour values. A visual revision is entitled to change every
// hex in the palette, and a test that pinned one would turn red for a redesign
// rather than for a defect. What is pinned is what a redesign must not break.

/// The sub-theme fields `TablePlusTheme` declares, read from the package source.
///
/// Dart has no reflection, so "does the builder still cover every sub-theme"
/// cannot be put to the compiler. It is put to the source instead — the same
/// move `settings_spec_test.dart` makes for the settings fields.
Set<String> _subThemeFields() {
  final source = File('../lib/src/models/theme/theme.dart').readAsStringSync();
  final body = source.substring(source.indexOf('class TablePlusTheme'));
  return RegExp(r'^  final TablePlus\w+ ?\??\s+(\w+);', multiLine: true)
      .allMatches(body)
      .map((m) => m.group(1)!)
      .toSet();
}

/// Settings deliberately off their defaults on every sub-theme the playground
/// actually configures.
///
/// A sub-theme dropped by the dark variant would come back as the package
/// default, and a default is indistinguishable from a correctly carried-through
/// default. Moving each of these off its default is what makes "it survived"
/// observable at all.
const _distinctive = PlaygroundSettings(
  rowCardTooltip: true,
  showCheckboxColumn: false,
  cellTapTogglesCheckbox: true,
  rowCardWaitDurationMs: 777,
  tooltipAnchor: TooltipAnchor.pointer,
  headerTooltipAnchor: HeaderTooltipAnchor.child,
);

void main() {
  group('exampleTheme', () {
    test('each brightness produces a theme of that brightness', () {
      expect(exampleTheme(Brightness.light).brightness, Brightness.light);
      expect(exampleTheme(Brightness.dark).brightness, Brightness.dark);
    });

    test('the two are different themes, not one theme twice', () {
      final light = exampleTheme(Brightness.light);
      final dark = exampleTheme(Brightness.dark);

      expect(dark.colorScheme.surface, isNot(light.colorScheme.surface));
      expect(dark.colorScheme.onSurface, isNot(light.colorScheme.onSurface));
      expect(dark.scaffoldBackgroundColor, dark.colorScheme.surface);
      expect(light.scaffoldBackgroundColor, light.colorScheme.surface);
    });

    test('both brightnesses carry the same set of component treatments', () {
      // Neither may grow a treatment the other silently lacks: a dark theme
      // that forgot its app bar renders the light one's chrome on a dark ground.
      final light = exampleTheme(Brightness.light);
      final dark = exampleTheme(Brightness.dark);

      expect(light.appBarTheme.backgroundColor, isNotNull);
      expect(dark.appBarTheme.backgroundColor, isNotNull);
      expect(light.dividerTheme.color, isNotNull);
      expect(dark.dividerTheme.color, isNotNull);
      expect(light.listTileTheme.subtitleTextStyle, isNotNull);
      expect(dark.listTileTheme.subtitleTextStyle, isNotNull);
    });

    test('the chrome is achromatic, and error is exempt', () {
      // The regression this guards is quiet: swap the scheme for
      // `ThemeData.light()` and the app turns violet (#6750A4) without a single
      // test noticing. Material 3's variant named `neutral` is not neutral
      // either — seeded from black it comes out with a pink cast — so "we asked
      // for neutral" is not evidence. This asks the colours themselves.
      bool grey(Color c) {
        final v = c.toARGB32();
        final r = (v >> 16) & 0xFF, g = (v >> 8) & 0xFF, b = v & 0xFF;
        return r == g && g == b;
      }

      for (final brightness in Brightness.values) {
        final s = exampleTheme(brightness).colorScheme;

        expect(grey(s.primary), isTrue, reason: 'primary carries a hue');
        expect(grey(s.surface), isTrue, reason: 'surface carries a hue');
        expect(grey(s.onSurface), isTrue, reason: 'onSurface carries a hue');
        expect(grey(s.outlineVariant), isTrue, reason: 'rules carry a hue');

        // Semantic colour is not decoration. A failure that reads as a shade of
        // grey is a failure nobody notices.
        expect(grey(s.error), isFalse,
            reason: 'error went grey along with everything else');
      }
    });

    test('the chrome palette is not the table palette', () {
      // Both are achromatic now, so nothing but value separates the app's
      // chrome from the table sitting inside it. That makes this closer, not
      // less important: a chrome that lands on the same grey as the header
      // reads as one undifferentiated surface.
      for (final brightness in Brightness.values) {
        final chrome = exampleTheme(brightness);
        final table =
            buildPlaygroundTheme(_distinctive, brightness: brightness);

        expect(
          chrome.colorScheme.primary,
          isNot(table.headerTheme.backgroundColor),
          reason: 'the app chrome and the table header read as the same widget',
        );
      }
    });
  });

  group('buildPlaygroundTheme', () {
    test('defaults to light, so the existing callers keep their theme', () {
      expect(
        buildPlaygroundTheme(_distinctive).bodyTheme.backgroundColor,
        buildPlaygroundTheme(_distinctive, brightness: Brightness.light)
            .bodyTheme
            .backgroundColor,
      );
    });

    test('the dark palette actually moves the grounds and the inks', () {
      final light = buildPlaygroundTheme(_distinctive);
      final dark =
          buildPlaygroundTheme(_distinctive, brightness: Brightness.dark);

      expect(dark.bodyTheme.backgroundColor,
          isNot(light.bodyTheme.backgroundColor));
      expect(dark.headerTheme.backgroundColor,
          isNot(light.headerTheme.backgroundColor));
      expect(dark.bodyTheme.textStyle.color,
          isNot(light.bodyTheme.textStyle.color));
    });

    test('the dark variant carries every configured sub-theme through', () {
      // `rowTooltipTheme` went missing once because a variant was re-assembled
      // by hand-listing the sub-themes it knew about. There is no variant here
      // — one builder takes a palette — but this pins the property rather than
      // the implementation, so it keeps its meaning if the structure changes
      // again.
      //
      // Asserted on the settings rather than on object identity: the two themes
      // are separate builds, so identity would compare nothing, and these
      // sub-themes carry no `==`.
      final dark =
          buildPlaygroundTheme(_distinctive, brightness: Brightness.dark);

      expect(dark.checkboxTheme.showCheckboxColumn, isFalse);
      expect(dark.checkboxTheme.cellTapTogglesCheckbox, isTrue);
      expect(dark.tooltipTheme.anchor, TooltipAnchor.pointer);
      expect(dark.rowTooltipTheme, isNotNull);
      expect(dark.rowTooltipTheme!.waitDuration,
          const Duration(milliseconds: 777));
      expect(dark.rowTooltipTheme!.backgroundColor, Colors.transparent,
          reason: 'the card draws its own surface');
      expect(dark.headerTooltipTheme, isNotNull);
      expect(dark.headerTooltipTheme!.anchor, TooltipAnchor.child);
      expect(dark.editableTheme.editingBorderWidth,
          buildPlaygroundTheme(_distinctive).editableTheme.editingBorderWidth);
    });

    test('every sub-theme the package declares is accounted for above', () {
      // The previous test names the sub-themes it expects to arrive, and a list
      // of names cannot notice a tenth sub-theme being added to the package.
      // This one can: it reads them from the source and fails when the set
      // changes, which forces whoever added it to decide whether the demo's
      // theme should say anything about it.
      expect(
        _subThemeFields(),
        {
          'headerTheme', // painted from the palette
          'bodyTheme', // painted from the palette
          'scrollbarTheme',
          'checkboxTheme',
          'editableTheme',
          'tooltipTheme',
          'rowTooltipTheme',
          'headerTooltipTheme',
          'hoverButtonTheme',
          'dragSelectionTheme',
        },
        reason:
            'TablePlusTheme gained or lost a sub-theme — decide whether the '
            "playground's dark variant should change it, then update this set. "
            'The scrollbar, hover-button and drag-selection sub-themes are left '
            'at package defaults by the playground, so this set is the only '
            'thing guarding them.',
      );
    });
  });

  group('ExampleThemeController', () {
    test('opens following the system', () {
      expect(ExampleThemeController().mode, ThemeMode.system);
    });

    test('cycles system to light to dark and back', () {
      final controller = ExampleThemeController();

      controller.cycle();
      expect(controller.mode, ThemeMode.light);
      controller.cycle();
      expect(controller.mode, ThemeMode.dark);
      controller.cycle();
      expect(controller.mode, ThemeMode.system,
          reason: 'a two-state toggle would strand the reader off system');
    });

    test('notifies on a change and stays quiet on a no-op', () {
      final controller = ExampleThemeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.mode = ThemeMode.dark;
      expect(notifications, 1);

      controller.mode = ThemeMode.dark;
      expect(notifications, 1, reason: 'setting the mode it already has');
    });
  });

  group('ThemeModeButton', () {
    // The button is chrome the app hangs on a page, not something a page owns.
    // These pin the consequence: a page stays pumpable without the app around
    // it, which is what the rest of this suite depends on.

    testWidgets('draws nothing when no scope is above it', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          appBar: null,
          body: ThemeModeButton(),
        ),
      ));

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('cycles the mode when a scope is above it', (tester) async {
      final controller = ExampleThemeController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(ExampleThemeScope(
        controller: controller,
        child: const MaterialApp(
          home: Scaffold(body: ThemeModeButton()),
        ),
      ));

      expect(find.byType(IconButton), findsOneWidget);
      expect(controller.mode, ThemeMode.system);

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(controller.mode, ThemeMode.light);
    });
  });
}
