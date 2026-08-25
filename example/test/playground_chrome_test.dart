import 'package:example/pages/playground/playground_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The playground's own chrome — its preset bar, its panes, the box around the
// table — painted itself white and drew its rules in `Colors.grey.shade300`.
// That was invisible while the example had no dark theme. Once #100 gave it one,
// a dark app got a dark app bar above a bright white settings panel, and the
// whole suite stayed green through it.
//
// So this asserts the property rather than any particular widget: **in dark
// mode, nothing in the playground paints a light ground.** It names no pane and
// no colour of its own, so a redesign that moves the panes around keeps it
// passing, and a re-introduced literal turns it red wherever it lands.
//
// What it deliberately does not forbid: light-on-colour inside a *semantic*
// badge — the performance monitor's status pill and the percentage chip are
// white text on green/amber/red, which is correct in either theme. Those are
// `Icon`/`TextStyle` colours, not surfaces, so they are outside what this walks.

/// Every explicit ground colour painted by the **example's own** chrome, with
/// the widget that painted it.
///
/// Anything inside `FlutterTablePlus` is excluded on purpose. The package paints
/// grounds of its own from `TablePlusTheme`, and those are decided in
/// `demoTableTheme` and asserted in `example_theme_test.dart`; walking into them
/// here reported a package default as a playground defect. It reported a true
/// thing — the scrollbar track defaults to a light `#E0E0E0` whatever the
/// brightness — but this is not the test that owns it.
List<(String, Color)> _paintedGrounds(WidgetTester tester) {
  final found = <(String, Color)>[];
  bool ours(Element e) =>
      !e.debugGetCreatorChain(20).contains('FlutterTablePlus');

  for (final element in find.byType(Container).evaluate()) {
    if (!ours(element)) continue;
    final container = element.widget as Container;
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      found.add((element.debugGetCreatorChain(3), decoration.color!));
    }
    if (container.color != null) {
      found.add((element.debugGetCreatorChain(3), container.color!));
    }
  }
  for (final element in find.byType(DecoratedBox).evaluate()) {
    if (!ours(element)) continue;
    final decoration = (element.widget as DecoratedBox).decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      found.add((element.debugGetCreatorChain(3), decoration.color!));
    }
  }
  return found;
}

/// Perceived lightness, 0 (black) to 255 (white).
int _lightness(Color c) {
  final v = c.toARGB32();
  final r = (v >> 16) & 0xFF, g = (v >> 8) & 0xFF, b = v & 0xFF;
  return ((r * 299 + g * 587 + b * 114) / 1000).round();
}

/// Opacity, 0..255. A nearly transparent wash is not a ground.
int _alpha(Color c) => (c.toARGB32() >> 24) & 0xFF;

Future<void> _pumpPlayground(
  WidgetTester tester, {
  required Brightness brightness,
}) async {
  // The playground lays three panes side by side; a narrow surface would make
  // them overflow and the tree under test would be a broken one.
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // The app's own theme, not a bare `ThemeData(brightness: ...)`. Testing
  // against a theme the example never uses would report Material's defaults as
  // if they were this app's decisions — the chip grounds were exactly that.
  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(brightness),
    home: const PlaygroundPage(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('paints no light ground in dark mode', (tester) async {
    await _pumpPlayground(tester, brightness: Brightness.dark);

    final offenders = _paintedGrounds(tester)
        .where((e) => _alpha(e.$2) > 200 && _lightness(e.$2) > 180)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason: 'these paint a light ground while the app is dark:\n'
          '${offenders.map((e) => '  ${e.$2}  at ${e.$1}').join('\n')}',
    );
  });

  testWidgets('and the light theme is not simply the dark one', (tester) async {
    // The guard above passes trivially if the playground paints no grounds at
    // all. This one insists it does paint some, so an empty result is a real
    // absence of offenders rather than an absence of walking.
    await _pumpPlayground(tester, brightness: Brightness.light);

    final grounds = _paintedGrounds(tester);
    expect(grounds, isNotEmpty,
        reason: 'nothing painted a ground, so the dark check walked nothing');
    expect(
      grounds.where((e) => _alpha(e.$2) > 200 && _lightness(e.$2) > 180),
      isNotEmpty,
      reason: 'a light app painted no light ground either — the walk is not '
          'seeing what it thinks it is seeing',
    );
  });
}
