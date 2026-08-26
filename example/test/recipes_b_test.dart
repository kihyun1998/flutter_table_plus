import 'package:example/demo_data/demo_data.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/recipes/column_reorder_recipe.dart';
import 'package:example/recipes/column_resize_recipe.dart';
import 'package:example/recipes/zoom_recipe.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:example/theme/example_theme.dart';
import 'package:example/theme/table_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The three recipes #106 adds, and only what belongs to them.
//
// The package pins its own half already — `test/column_resize_drag_test.dart`
// holds the drag-to-callback path and `test/scale_zoom_test.dart` holds
// Ctrl+wheel and the 0.05 step. Re-asserting either here would mean fighting
// this app's fixtures for a fact that is proven with better ones. What is not
// proven anywhere else is the part each recipe *writes*: the renumbering a
// reorder needs, the width loop a resize needs, and the clamp the package
// deliberately leaves to the caller.

Future<void> _pump(
  WidgetTester tester,
  Widget recipe, {
  Brightness brightness = Brightness.light,
  Size size = const Size(1000, 900),
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

/// The column keys in the order the table draws them.
List<String> _displayOrder(WidgetTester tester) {
  final columns = _table(tester).columns.values.where((c) => c.visible).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return columns.map((c) => c.key).toList();
}

/// A header drag, in enough steps that the `DragTarget` under the pointer sees
/// it. A single jump can start the `Draggable` and land past every target.
Future<void> _dragHeader(
  WidgetTester tester,
  String from,
  String to,
) async {
  final start = tester.getCenter(find.text(from));
  final end = tester.getCenter(find.text(to));
  final gesture = await tester.startGesture(start);
  final step = (end - start) / 8;
  for (var i = 0; i < 8; i++) {
    await gesture.moveBy(step);
    await tester.pump();
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

/// A resize drag on the boundary the header keys by column.
Future<void> _dragBoundary(
  WidgetTester tester,
  String columnKey,
  double dx,
) async {
  final handle = find.byKey(ValueKey('resize_$columnKey'));
  expect(handle, findsOneWidget,
      reason: 'no resize handle for $columnKey — resizable is off, or the '
          'package stopped keying them this way');

  final gesture = await tester.startGesture(tester.getCenter(handle));
  for (var i = 0; i < 8; i++) {
    await gesture.moveBy(Offset(dx / 8, 0));
    await tester.pump();
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _ctrlWheel(WidgetTester tester, double dy) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  final loc = tester.getCenter(find.byType(FlutterTablePlus<Employee>));
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(loc));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

/// Runs [body] with the platform pinned, and unpins it before the framework
/// checks its debug invariants — which happens at the end of the test body, not
/// in `tearDown`, so a `setUp`/`tearDown` pair fails every test in the group.
Future<void> _onWindows(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Recipe _recipe(String featureId) =>
    recipeCatalog.firstWhere((r) => r.featureId == featureId);

void main() {
  group('the catalogue feeds each knob to its own parameter', () {
    // A translation table is exactly where a line gets copied and the field on
    // the right never renamed. Every shell test in the suite stays green with
    // `handleIndent: settings.resizeHandleEndIndent` sitting in the middle.
    const base = PlaygroundSettings();

    test('column reorder', () {
      final recipe = _recipe('columnReorder');
      final off = recipe.build(
              base.copyWith(columnReorderEnabled: !base.columnReorderEnabled))
          as ColumnReorderRecipe;
      expect(off.reorderEnabled,
          isNot((recipe.build(base) as ColumnReorderRecipe).reorderEnabled));
      expect(recipe.knobIds, ['columnReorderEnabled']);
    });

    test('resizing, all seven of them', () {
      final recipe = _recipe('resizing');
      ColumnResizeRecipe built(PlaygroundSettings s) =>
          recipe.build(s) as ColumnResizeRecipe;

      expect(built(base.copyWith(resizableEnabled: !base.resizableEnabled))
          .resizable, isNot(built(base).resizable));
      expect(built(base.copyWith(columnMinWidth: base.columnMinWidth + 10))
          .columnMinWidth, built(base).columnMinWidth + 10);
      expect(built(base.copyWith(stretchLastColumn: !base.stretchLastColumn))
          .stretchLastColumn, isNot(built(base).stretchLastColumn));
      expect(built(base.copyWith(resizeHandleWidth: base.resizeHandleWidth + 1))
          .handleWidth, built(base).handleWidth + 1);
      expect(
          built(base.copyWith(
                  resizeHandleThickness: base.resizeHandleThickness + 1))
              .handleThickness,
          built(base).handleThickness + 1);
      // The two inset knobs share a type, a default and adjacent lines, which
      // is the whole reason they are checked separately.
      expect(
          built(base.copyWith(resizeHandleIndent: base.resizeHandleIndent + 3))
              .handleIndent,
          built(base).handleIndent + 3);
      expect(
          built(base.copyWith(
                  resizeHandleEndIndent: base.resizeHandleEndIndent + 5))
              .handleEndIndent,
          built(base).handleEndIndent + 5);

      expect(recipe.knobIds, [
        'resizableEnabled',
        'columnMinWidth',
        'stretchLastColumn',
        'resizeHandleWidth',
        'resizeHandleThickness',
        'resizeHandleIndent',
        'resizeHandleEndIndent',
      ]);
    });

    test('zoom, which owns options and no switch', () {
      final recipe = _recipe('zoom');
      ZoomRecipe built(PlaygroundSettings s) => recipe.build(s) as ZoomRecipe;

      expect(built(base.copyWith(scale: base.scale + 0.5)).scale,
          built(base).scale + 0.5);
      expect(
          built(base.copyWith(blockModifierScroll: !base.blockModifierScroll))
              .blockModifierScroll,
          isNot(built(base).blockModifierScroll));

      // `Recipe.knobIds` prepends the feature's switch when it has one. Zoom
      // has none, so this is the case that would break a `knobIds` written to
      // assume there always is one.
      expect(featureById('zoom').switchId, isNull);
      expect(recipe.knobIds, ['scale', 'blockModifierScroll']);
    });
  });

  group('reordering rewrites order, which is what the table reads', () {
    testWidgets('a header dropped on another takes its place', (tester) async {
      await _pump(tester, const ColumnReorderRecipe());
      expect(_displayOrder(tester),
          ['name', 'department', 'position', 'salary']);

      await _dragHeader(tester, 'Name', 'Position');

      expect(_displayOrder(tester),
          ['department', 'position', 'name', 'salary'],
          reason: 'the drop did not move the column, or moved it by a '
              'different arithmetic than remove-then-insert');
    });

    testWidgets('and the new numbering is one the builder would accept',
        (tester) async {
      // `TableColumnsBuilder` throws on orders that are not unique and
      // consecutive from 1 — it reserves 0 and below, and the table's own
      // synthetic selection column sits at -1. A renumbering from 0 renders
      // correctly and collides the first time the set goes back through the
      // builder, which is a failure nothing on screen would show.
      await _pump(tester, const ColumnReorderRecipe());
      await _dragHeader(tester, 'Salary', 'Name');

      final orders = _table(tester).columns.values.map((c) => c.order).toList()
        ..sort();
      expect(orders, [1, 2, 3, 4],
          reason: 'orders are not consecutive from 1, so this set cannot go '
              'back through TableColumnsBuilder');
    });

    testWidgets('the drop target past the last column is reachable',
        (tester) async {
      // It only exists in the space the columns leave over, and
      // `TablePlusColumn.width` is a preference — flexible columns share the
      // room in proportion to it and fill the viewport exactly, which leaves
      // the trailing target zero pixels wide. Measured 2026-08-26: with the
      // columns unpinned it sat at Rect.fromLTRB(1500, 35, 1500, 90). Pinning
      // them with `maxWidth == width` is what gives it a body.
      await _pump(tester, const ColumnReorderRecipe(),
          size: const Size(1500, 900));

      final targets = find.byType(DragTarget<int>);
      final trailing = tester.getRect(targets.at(targets.evaluate().length - 1));
      expect(trailing.width, greaterThan(100),
          reason: 'the trailing drop target has no width, so a column can be '
              'dragged past the last one and nothing accepts it');

      // And it does what it says.
      final start = tester.getCenter(find.text('Name'));
      final gesture = await tester.startGesture(start);
      final end = trailing.center;
      final step = (end - start) / 8;
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(step);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(_displayOrder(tester).last, 'name',
          reason: 'dropping past the last column did not send it to the end');
    });

    testWidgets('with the knob off, dragging a header does nothing',
        (tester) async {
      // The side condition. Wiring `onColumnReorder` unconditionally passes
      // both tests above and leaves the switch inert.
      await _pump(tester, const ColumnReorderRecipe(reorderEnabled: false));
      final before = _displayOrder(tester);

      await _dragHeader(tester, 'Name', 'Position');

      expect(_displayOrder(tester), before);
      expect(_table(tester).onColumnReorder, isNull,
          reason: 'the callback is what arms the drag; there is no second '
              'flag, so withholding it is the whole of "off"');
    });
  });

  group('a resized width is yours, in logical pixels', () {
    testWidgets('the same drag reports the same width at any scale',
        (tester) async {
      // The interaction the ticket cites. The claim is not "a stored number
      // sits still" — nothing rewrites it, so that would pass on a recipe that
      // ignored `scale` completely. The claim is that the *conversion* happens:
      // a drag of 50 logical pixels reports the same width whether those 50
      // logical pixels were 50 on screen or 62.5.
      //
      // Narrow on purpose: these columns total 650px and width resolution
      // expands them proportionally to fill anything wider, which would make
      // the handle start from a width the scale did not produce.
      Future<String?> resizeAt(double factor, double screenDx) async {
        // Empty the tree first. Pumping the same widget type at the same
        // position keeps the old `State`, so the second measurement would
        // start from the first one's stored width and the two would differ
        // for a reason that has nothing to do with scale.
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, const ColumnResizeRecipe(),
            size: const Size(600, 900));
        if (factor != 1.0) {
          await tester.tap(find.text('${factor}x'));
          await tester.pumpAndSettle();
        }
        await _dragBoundary(tester, 'name', screenDx);
        final reported = find.textContaining('name ');
        expect(reported, findsOneWidget,
            reason: 'the strip never reported a width at ${factor}x');
        return tester.widget<Text>(reported).data;
      }

      final atOne = await resizeAt(1.0, 50);
      final atQuarter = await resizeAt(1.25, 62.5);

      expect(atQuarter, atOne,
          reason: 'the same drag in logical pixels reported two different '
              'widths, so the number handed back is screen pixels wearing a '
              'logical label');
    });

    testWidgets('while the column itself does move', (tester) async {
      // The other half. Without it the test above passes on a recipe that
      // ignores `scale` altogether, and "survives a change of zoom" would be
      // true because nothing changed.
      //
      // Narrow on purpose. These columns total 650px, and width resolution
      // expands them proportionally to fill anything wider — so in a 1000px
      // viewport the table fills the width at *every* scale and a zoom moves
      // the boundaries by the few pixels the text padding gains. Measured:
      // `Department` sat at x=277.5 at both 1.0 and 1.25. The scale is only
      // observable in a viewport the columns already overflow.
      await _pump(tester, const ColumnResizeRecipe(),
          size: const Size(600, 900));
      final before = tester.getTopLeft(find.text('Department')).dx;

      await tester.tap(find.text('1.25x'));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('Department')).dx,
          closeTo(before * 1.25, 1.0),
          reason: 'the table did not render at the new scale');
    });

    testWidgets('the width survives a rebuild, which is what storing it buys',
        (tester) async {
      // `initialResizedWidths` reads as start-up state. It is not: the table
      // adopts the map whenever it changes by value, and that is the only
      // reason handing the callback's result straight back works.
      await _pump(tester, const ColumnResizeRecipe());
      await _dragBoundary(tester, 'name', 60);
      final moved = tester.getTopLeft(find.text('Department')).dx;

      // Any knob change rebuilds the recipe with new parameters.
      await _pump(tester, const ColumnResizeRecipe(handleWidth: 12));
      await tester.pumpAndSettle();

      expect(_table(tester).initialResizedWidths, isNotNull);
      expect(moved, isNot(closeTo(170, 1.0)),
          reason: 'the drag never moved the boundary, so this proves nothing');
    });

    testWidgets('with the knob off there is no handle to find', (tester) async {
      await _pump(tester, const ColumnResizeRecipe(resizable: false));
      expect(find.byKey(const ValueKey('resize_name')), findsNothing);
    });
  });

  group('the resize handle is a colour this app chose', () {
    // It draws only on hover or drag, so an invisible one and an absent one
    // look identical — which is how it went unnoticed until #106 rendered it.
    test('and not the header hairline it would otherwise inherit', () {
      for (final brightness in Brightness.values) {
        final theme = demoTableTheme(brightness);
        expect(theme.headerTheme.resizeHandle.color, isNotNull,
            reason: 'unset, the handle falls back to the vertical divider');
        expect(theme.headerTheme.resizeHandle.color,
            isNot(theme.headerTheme.verticalDivider.color),
            reason: 'the handle is the divider colour, so hovering a boundary '
                'shows nothing that was not already there');
      }
    });

    testWidgets('and reshaping it in the recipe keeps that colour',
        (tester) async {
      // #50's failure class in a new place: building a fresh
      // `TablePlusResizeHandleTheme` for the four knob fields would keep those
      // four and silently drop `color`. The object stays valid, nothing throws.
      await _pump(tester, const ColumnResizeRecipe(handleWidth: 14));

      final applied = _table(tester).theme.headerTheme.resizeHandle;
      expect(applied.width, 14, reason: 'the knob did not reach the theme');
      expect(applied.color, demoTableTheme(Brightness.light)
          .headerTheme.resizeHandle.color,
          reason: 'the recipe rebuilt the sub-theme instead of copying it');
    });
  });

  group('zoom is clamped by the recipe, not by the package', () {
    testWidgets('Ctrl+wheel moves the factor the recipe holds', (tester) async {
      await _pump(tester, const ZoomRecipe());
      expect(find.text('scale 1.00x'), findsOneWidget);

      await _ctrlWheel(tester, -50); // wheel up

      expect(find.text('scale 1.05x'), findsOneWidget,
          reason: 'the wheel reached onScaleChanged but the recipe did not '
              'keep the value, or did not render it');
    });

    testWidgets('and wheeling past the ceiling stops at it', (tester) async {
      // The package asserts only that the factor is above zero. Everything
      // else is the caller's, so this clamp is the recipe's own code and the
      // reason it is not optional: without it the same gesture continues past
      // any range the app can render.
      await _pump(tester, const ZoomRecipe(scale: 2.9));

      for (var i = 0; i < 10; i++) {
        await _ctrlWheel(tester, -50);
      }

      expect(find.text('scale 3.00x'), findsOneWidget,
          reason: 'ten ticks of 0.05 from 2.9 went past 3.0 — the clamp is '
              'missing or is not applied to the wheel path');
    });

    testWidgets('and wheeling past the floor stops there too', (tester) async {
      await _pump(tester, const ZoomRecipe(scale: 0.6));

      for (var i = 0; i < 10; i++) {
        await _ctrlWheel(tester, 50);
      }

      expect(find.text('scale 0.50x'), findsOneWidget);
    });

    testWidgets('the knob overrides the wheel, and only when it moves',
        (tester) async {
      // `didUpdateWidget` has to compare against the *old widget*, not against
      // the recipe's own factor. Comparing against `_scale` would look correct
      // and would undo every wheel tick the next time any other setting
      // changed.
      await _pump(tester, const ZoomRecipe());
      await _ctrlWheel(tester, -50);
      expect(find.text('scale 1.05x'), findsOneWidget);

      // A different knob, same scale.
      await _pump(tester, const ZoomRecipe(blockModifierScroll: false));
      expect(find.text('scale 1.05x'), findsOneWidget,
          reason: 'an unrelated knob reset the zoom');

      await _pump(tester, const ZoomRecipe(scale: 2.0));
      expect(find.text('scale 2.00x'), findsOneWidget,
          reason: 'the scale knob moved and the recipe ignored it');
    });

    testWidgets('the flag reaches the table, and says so on screen',
        (tester) async {
      await _onWindows(() async {
        await _pump(tester, const ZoomRecipe(blockModifierScroll: false));

        expect(_table(tester).blockModifierScroll, isFalse);
        expect(find.textContaining('zooms and scrolls at once'), findsOneWidget);
      });
    });
  });

  group('the three of them are still recipes', () {
    testWidgets('each follows the app brightness', (tester) async {
      // #101's defect: a demo table wearing no theme drew white in a dark app.
      for (final build in [
        () => const ColumnReorderRecipe(),
        () => const ColumnResizeRecipe(),
        () => const ZoomRecipe(),
      ]) {
        await _pump(tester, build(), brightness: Brightness.light);
        final light = _table(tester).theme.bodyTheme.backgroundColor;

        await _pump(tester, build(), brightness: Brightness.dark);
        expect(_table(tester).theme.bodyTheme.backgroundColor, isNot(light));
      }
    });
  });
}
