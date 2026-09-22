import 'package:example/app/recipe_catalog.dart';
import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_presets.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/recipes/smooth_wheel_recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The smooth wheel recipe #184 adds, and the playground switch beside it.
//
// The package pins the motion itself in `test/smooth_wheel_scroll_test.dart`:
// that a notch animates, and that the header and scrollbars follow on every
// frame. This file asserts only what the example writes — which `WheelMotion`
// each setting produces, and that it reaches the table.

FlutterTablePlus<Employee> _table(WidgetTester tester) =>
    tester.widget<FlutterTablePlus<Employee>>(
        find.byType(FlutterTablePlus<Employee>));

Recipe _recipe(String featureId) =>
    recipeCatalog.firstWhere((r) => r.featureId == featureId);

/// The motion's type by name. `WheelMotion` is the only name the barrel
/// re-exports, so the variants are told apart the way a reader would see them.
String? _kind(WheelMotion? motion) => motion?.runtimeType.toString();

void main() {
  final base = applyPreset(const PlaygroundSettings(), presetById('bare'));

  group('the catalogue wires the smooth wheel settings', () {
    test('off means no motion, whatever kind is picked', () {
      final recipe = _recipe('smoothWheel');
      SmoothWheelRecipe built(PlaygroundSettings s) =>
          recipe.build(s) as SmoothWheelRecipe;

      for (final kind in WheelMotionKind.values) {
        expect(
          built(base.copyWith(smoothWheelEnabled: false, wheelMotionKind: kind))
              .wheelMotion,
          isNull,
          reason: kind.name,
        );
      }
    });

    test('on, each kind is its own motion', () {
      final recipe = _recipe('smoothWheel');
      String? kindOf(WheelMotionKind kind) => _kind((recipe.build(
                  base.copyWith(smoothWheelEnabled: true, wheelMotionKind: kind))
              as SmoothWheelRecipe)
          .wheelMotion);

      expect(kindOf(WheelMotionKind.spring), 'SpringWheelMotion');
      expect(kindOf(WheelMotionKind.curve), 'CurveWheelMotion');
      expect(kindOf(WheelMotionKind.lerp), 'LerpWheelMotion');
    });

    test('the knobs are the switch and the kind', () {
      expect(_recipe('smoothWheel').knobIds,
          ['smoothWheelEnabled', 'wheelMotionKind']);
    });
  });

  group('the recipe', () {
    Future<void> pump(WidgetTester tester, Brightness brightness,
        {WheelMotion? motion}) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(brightness),
        home: Scaffold(body: SmoothWheelRecipe(wheelMotion: motion)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('hands its motion to the table', (tester) async {
      const motion = WheelMotion.lerp();
      await pump(tester, Brightness.light, motion: motion);
      expect(_table(tester).wheelMotion, same(motion));

      await pump(tester, Brightness.light);
      expect(_table(tester).wheelMotion, isNull);
    });

    testWidgets('follows the app brightness', (tester) async {
      // #101's defect: a demo table wearing no theme drew white in a dark app.
      await pump(tester, Brightness.light);
      final light = _table(tester).theme.bodyTheme.backgroundColor;

      await pump(tester, Brightness.dark);
      expect(_table(tester).theme.bodyTheme.backgroundColor, isNot(light));
    });
  });

  testWidgets('the playground switch reaches the table', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
    await tester.pumpAndSettle();
    expect(_table(tester).wheelMotion, isNull, reason: 'the playground opens bare');

    await tester.tap(find.byKey(const ValueKey('feature-dot-smoothWheel')));
    await tester.pumpAndSettle();

    expect(_kind(_table(tester).wheelMotion), 'SpringWheelMotion');
  });
}
