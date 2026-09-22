import 'package:example/app/recipe_catalog.dart';
import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_presets.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:example/recipes/smooth_wheel_recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The smooth wheel recipe #184 adds, and the playground knobs beside it.
//
// The package pins the motion itself in `test/smooth_wheel_scroll_test.dart`:
// that a notch animates, and that the header and scrollbars follow on every
// frame. This file asserts only what the example writes — which `WheelMotion`
// each setting produces, and that it reaches the table. The variants' fields
// are read through the upstream package, a dev dependency here, because the
// barrel re-exports `WheelMotion` alone.

FlutterTablePlus<Employee> _table(WidgetTester tester) =>
    tester.widget<FlutterTablePlus<Employee>>(
        find.byType(FlutterTablePlus<Employee>));

Recipe _recipe(String featureId) =>
    recipeCatalog.firstWhere((r) => r.featureId == featureId);

void main() {
  final base = applyPreset(const PlaygroundSettings(), presetById('bare'));

  group('the settings build the motion', () {
    test('bare shows the table default, a 400ms spring with no bounce', () {
      final motion = base.wheelMotion;
      expect(motion, isA<SpringWheelMotion>());
      motion as SpringWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 400));
      expect(motion.bounce, 0.0);
    });

    test('off is no motion', () {
      expect(base.copyWith(wheelMotionKind: WheelMotionKind.off).wheelMotion,
          isNull);
    });

    test('spring reads duration and bounce', () {
      final motion = base
          .copyWith(
            wheelMotionKind: WheelMotionKind.spring,
            wheelDurationMs: 250,
            wheelBounce: 0.3,
          )
          .wheelMotion as SpringWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 250));
      expect(motion.bounce, 0.3);
    });

    test('curve reads duration and curve', () {
      final motion = base
          .copyWith(
            wheelMotionKind: WheelMotionKind.curve,
            wheelDurationMs: 600,
            wheelCurve: WheelCurveOption.easeInOut,
          )
          .wheelMotion as CurveWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 600));
      expect(motion.curve, Curves.easeInOut);
    });

    test('lerp reads the time constant', () {
      final motion = base
          .copyWith(
            wheelMotionKind: WheelMotionKind.lerp,
            wheelTimeConstantMs: 90,
          )
          .wheelMotion as LerpWheelMotion;
      expect(motion.timeConstant, const Duration(milliseconds: 90));
    });
  });

  group('the catalogue', () {
    test('hands the recipe what the settings build', () {
      final recipe = _recipe('smoothWheel');
      SmoothWheelRecipe built(PlaygroundSettings s) =>
          recipe.build(s) as SmoothWheelRecipe;

      expect(
          built(base.copyWith(wheelMotionKind: WheelMotionKind.off))
              .wheelMotion,
          isNull);
      expect(
          built(base.copyWith(
                  wheelMotionKind: WheelMotionKind.lerp,
                  wheelTimeConstantMs: 90))
              .wheelMotion,
          isA<LerpWheelMotion>().having((m) => m.timeConstant, 'timeConstant',
              const Duration(milliseconds: 90)));
    });

    test('the knobs are the kind and its four parameters', () {
      expect(_recipe('smoothWheel').knobIds, [
        'wheelMotionKind',
        'wheelDurationMs',
        'wheelBounce',
        'wheelCurve',
        'wheelTimeConstantMs',
      ]);
    });
  });

  group('the recipe', () {
    Future<void> pump(WidgetTester tester, Widget recipe,
        {Brightness brightness = Brightness.light}) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(brightness),
        home: Scaffold(body: recipe),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('left alone, runs the table default', (tester) async {
      await pump(tester, const SmoothWheelRecipe());
      expect(_table(tester).wheelMotion, isA<SpringWheelMotion>());
    });

    testWidgets('hands its motion to the table, null included',
        (tester) async {
      const motion = WheelMotion.lerp();
      await pump(tester, const SmoothWheelRecipe(wheelMotion: motion));
      expect(_table(tester).wheelMotion, same(motion));

      await pump(tester, const SmoothWheelRecipe(wheelMotion: null));
      expect(_table(tester).wheelMotion, isNull);
    });

    testWidgets('follows the app brightness', (tester) async {
      // #101's defect: a demo table wearing no theme drew white in a dark app.
      await pump(tester, const SmoothWheelRecipe());
      final light = _table(tester).theme.bodyTheme.backgroundColor;

      await pump(tester, const SmoothWheelRecipe(),
          brightness: Brightness.dark);
      expect(_table(tester).theme.bodyTheme.backgroundColor, isNot(light));
    });
  });

  testWidgets('the playground Motion knob reaches the table', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
    await tester.pumpAndSettle();
    expect(_table(tester).wheelMotion, isA<SpringWheelMotion>(),
        reason: 'bare leaves the table default on');

    await tester.tap(find.text(featureById('smoothWheel').title));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<WheelMotionKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(WheelMotionKind.lerp.label).last);
    await tester.pumpAndSettle();

    expect(_table(tester).wheelMotion, isA<LerpWheelMotion>());
  });
}
