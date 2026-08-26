import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/preview/preview_frame.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:example/shell/shell_page.dart';
import 'package:example/shell/source_pane.dart';
import 'package:example/theme/example_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The Code pane shows the recipe's real bytes, read from the bundle at runtime.
// Everything here exists to keep "real bytes" from decaying into "a string that
// used to match".
//
// The measured facts this rests on, from a throwaway probe rather than from
// reading the code:
//
//   * the asset key is the path exactly as `pubspec.yaml` writes it —
//     `lib/recipes/selection_recipe.dart`, no transformation;
//   * `rootBundle.loadString` resolves it under `flutter test`, which bundles
//     into `build/unit_test_assets`;
//   * the *directory* form `- lib/recipes/` is what registers it, so a recipe
//     added later needs no pubspec edit.
//
// One trap worth naming, because its symptom is indistinguishable from a real
// defect: a stale `build/unit_test_assets` serves an AssetManifest from before
// the pubspec change, so a correctly declared asset reports "Unable to load
// asset". `rm -rf build/unit_test_assets .dart_tool/flutter_build` tells the two
// apart. This cost a wrong conclusion once already.

/// A bundle that fails, so the failure path can be driven.
///
/// Without this the error branch is unreachable in a test, and an error branch
/// nobody exercises is how a pane comes to render empty on failure — which
/// looks exactly like a file with nothing in it.
class _BrokenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('Unable to load asset: "$key".');
}

/// A bundle serving one string, for asserting on content that is not the real
/// file — so a test cannot pass by accident on whatever the real file happens
/// to contain today.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.contents);

  final String contents;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(contents.codeUnits));
}

Future<void> _pumpPane(
  WidgetTester tester, {
  required String path,
  AssetBundle? bundle,
  Size surface = const Size(900, 700),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(Brightness.light),
    home: Scaffold(body: SourcePane(assetPath: path, bundle: bundle)),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpShell(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(Brightness.light),
    home: const ShellPage(),
  ));
  await tester.pumpAndSettle();
}

Future<void> _openSelection(WidgetTester tester) async {
  await tester.tap(find.text(featureById('selection').title));
  await tester.pumpAndSettle();
}

void main() {
  group('every recipe\'s source is actually loadable', () {
    // This is #103's asset test, upgraded. That one read `pubspec.yaml` as text
    // and asked whether a declaration covered the path — which is satisfied by a
    // declaration that does not bundle anything. This asks the bundle.
    testWidgets('and is the file it claims to be', (tester) async {
      expect(recipeCatalog, isNotEmpty);

      for (final recipe in recipeCatalog) {
        late final String source;
        try {
          source = await rootBundle.loadString(recipe.source);
        } catch (e) {
          fail('${recipe.source} is declared but not loadable: $e\n'
              'Either pubspec.yaml does not cover it, or build/ is stale — '
              'rm -rf build/unit_test_assets .dart_tool/flutter_build');
        }

        expect(source, isNotEmpty, reason: '${recipe.source} loaded as empty');

        // Not just "some bytes arrived": the bytes are this recipe's. A bundle
        // serving the wrong file, or a truncated one, passes a length check.
        final className = recipe.source
            .split('/')
            .last
            .replaceAll('.dart', '')
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join();
        expect(source, contains('class $className'),
            reason: '${recipe.source} does not contain `class $className` — '
                'the bundle served something else');
      }
    });
  });

  group('the pane renders the bytes it was given', () {
    testWidgets('and says which file they came from', (tester) async {
      await _pumpPane(
        tester,
        path: 'lib/recipes/selection_recipe.dart',
        bundle: _FakeBundle('class Sentinel {}'),
      );

      expect(find.textContaining('class Sentinel'), findsOneWidget);
      // The path is evidence, not decoration: without it the pane is a block of
      // code that could have come from anywhere.
      expect(find.text('lib/recipes/selection_recipe.dart'), findsOneWidget);
    });

    testWidgets('and re-reads when the path changes', (tester) async {
      // Otherwise switching recipes leaves the previous one's source on screen
      // under the new one's path — the exact disagreement this pane exists to
      // make impossible.
      await _pumpPane(tester, path: 'a.dart', bundle: _FakeBundle('AAA'));
      expect(find.textContaining('AAA'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.light),
        home: Scaffold(
          body: SourcePane(
            assetPath: 'b.dart',
            bundle: _FakeBundle('BBB'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('BBB'), findsOneWidget);
      expect(find.textContaining('AAA'), findsNothing);
      expect(find.text('b.dart'), findsOneWidget);
    });

    testWidgets('long source scrolls inside its own region', (tester) async {
      final long = List.generate(400, (i) => 'line $i').join('\n');
      await _pumpPane(
        tester,
        path: 'long.dart',
        bundle: _FakeBundle(long),
        surface: const Size(600, 400),
      );

      expect(tester.takeException(), isNull,
          reason: 'the pane overflowed instead of scrolling');

      // `SelectableText` renders the whole file as one `EditableText`, so a text
      // finder cannot see scroll position — it finds line 0 whether or not line
      // 0 is on screen. The scroll offset is the only honest observable.
      // `SelectableText` builds an `EditableText`, which has a vertical
      // `Scrollable` of its own nested inside this one — so the pane's is the
      // outermost, not the only one.
      ScrollableState vertical() => tester
          .stateList<ScrollableState>(find.byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down))
          .first;

      expect(vertical().position.maxScrollExtent, greaterThan(0),
          reason: 'nothing to scroll, so the rest of this proves nothing');
      expect(vertical().position.pixels, 0);

      await tester.drag(find.byType(SourcePane), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(vertical().position.pixels, greaterThan(0),
          reason: 'the region did not scroll');

      // And the shell around it did not move instead.
      expect(tester.getTopLeft(find.byType(SourcePane)).dy, 0);
    });

    testWidgets('an unreadable asset is drawn, not swallowed', (tester) async {
      // A pane that renders nothing on failure is indistinguishable from one
      // that loaded an empty file, which is the failure the ticket names.
      await _pumpPane(
        tester,
        path: 'lib/recipes/missing.dart',
        bundle: _BrokenBundle(),
      );

      expect(find.textContaining('Could not read'), findsOneWidget);
      expect(find.textContaining('lib/recipes/missing.dart'), findsWidgets);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('the Preview / Code control in the shell', () {
    testWidgets('is absent for a destination with no source', (tester) async {
      await _pumpShell(tester);

      // Opens on Employees, which is assembled from several widgets and is not
      // one file. Offering a Code tab there would have to pick one and call it
      // the source.
      expect(find.text('Code'), findsNothing);
      expect(find.byType(PreviewFrame), findsOneWidget);
    });

    testWidgets('appears for a recipe and switches the region', (tester) async {
      await _pumpShell(tester);
      await _openSelection(tester);

      expect(find.text('Code'), findsOneWidget);
      expect(find.byType(SourcePane), findsNothing);

      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();

      expect(find.byType(SourcePane), findsOneWidget);
      expect(find.text('lib/recipes/selection_recipe.dart'), findsOneWidget);
    });

    testWidgets('and Code replaces the frame rather than sitting inside it',
        (tester) async {
      // Load-bearing. A `SourcePane` inside `PreviewFrame` would be scaled to
      // whatever factor fits 1440px into the pane and then clipped to the
      // viewport — unreadable, and an answer to a question nobody asked. Source
      // has no viewport.
      await _pumpShell(tester);
      await _openSelection(tester);

      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();

      expect(find.byType(PreviewFrame), findsNothing,
          reason: 'the code is being rendered inside a scaled viewport');
    });

    testWidgets('and the viewport controls go with it', (tester) async {
      // They would otherwise claim the code is being rendered at 390px.
      await _pumpShell(tester);
      await _openSelection(tester);

      expect(find.text('Fit'), findsOneWidget);

      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();

      expect(find.text('Fit'), findsNothing);
      expect(find.byTooltip('Mobile'), findsNothing);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.text('Fit'), findsOneWidget,
          reason: 'they did not come back — Code is one-way');
    });

    testWidgets('and the shell hands the pane that recipe path',
        (tester) async {
      // The end-to-end claim — *the recipe's bytes are on screen* — is asserted
      // in three pieces rather than one, because the fourth piece is not
      // observable here.
      //
      //   * the asset loads and contains this recipe    -> the first group,
      //     against the real `rootBundle`;
      //   * the pane renders the bytes it is handed     -> the second group,
      //     against an injected bundle;
      //   * the shell hands it the right path           -> this test.
      //
      // What is missing is the two halves running together against the real
      // bundle, and it is missing for a harness reason, not a product one:
      // `rootBundle.loadString` is real file I/O, and a Future started inside
      // the widget tree under `AutomatedTestWidgetsFlutterBinding`'s fake-async
      // zone does not complete — `pumpAndSettle`, an extra `pump`, `runAsync`
      // and clearing the bundle cache were all measured and none deliver it.
      // The same test passes when it is the only one in the process, which
      // makes it worse than useless: green by run order.
      //
      // So the composition is checked here and the joint is checked by a human.
      // That is what the ticket's visual criterion is for.
      await _pumpShell(tester);
      await _openSelection(tester);

      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();

      final pane = tester.widget<SourcePane>(find.byType(SourcePane));
      expect(pane.assetPath, recipeCatalog.first.source);
      expect(pane.assetPath, 'lib/recipes/selection_recipe.dart');
      // No injected bundle: in the app it reads the real one.
      expect(pane.bundle, isNull);
    });
  });

  group('the code is drawn in a monospace face', () {
    // Not a preference. The pane's own rule is that a line is a line — it
    // scrolls horizontally rather than wrapping — and indentation only lines up
    // into columns when every glyph is the same width.
    //
    // The trap this pins is that `fontFamilyFallback` alone does nothing here.
    // Flutter resolves `fontFamily` first and consults the fallback list only
    // for glyphs that family lacks, and a `TextStyle` with `inherit: true` —
    // the default — merges the ambient `DefaultTextStyle`, which carries
    // `ThemeData.fontFamily`. So a style that names only fallbacks renders in
    // the chrome font, and the fallback list is never reached except by the
    // handful of characters Pretendard's subset is missing.
    //
    // Asserted on the resolved style rather than on `SourcePane`'s own
    // `TextStyle`: the merge is the thing that was wrong, so a test that reads
    // the unmerged style would have passed throughout.

    testWidgets('the source body, not the chrome font', (tester) async {
      await _pumpPane(
        tester,
        path: 'lib/recipes/selection_recipe.dart',
        bundle: _FakeBundle('class Sentinel {}'),
      );

      final editable = tester.widget<EditableText>(find.byType(EditableText));

      expect(editable.style.fontFamily, SourcePane.monoFamily);
      expect(editable.style.fontFamilyFallback, SourcePane.monoFallback);
      // The side condition is the whole point: the family that used to win.
      expect(editable.style.fontFamily, isNot(exampleChromeFont));
    });

    testWidgets('and the path header too', (tester) async {
      // Its own instance of the same bug, one screen away from the one above
      // and easy to fix in isolation.
      await _pumpPane(
        tester,
        path: 'lib/recipes/selection_recipe.dart',
        bundle: _FakeBundle('class Sentinel {}'),
      );

      final header = tester.widget<RichText>(
        find.descendant(
          of: find.text('lib/recipes/selection_recipe.dart'),
          matching: find.byType(RichText),
        ),
      );

      expect(header.text.style?.fontFamily, SourcePane.monoFamily);
      expect(header.text.style?.fontFamilyFallback, SourcePane.monoFallback);
      expect(header.text.style?.fontFamily, isNot(exampleChromeFont));
    });

    test('the family is not also the first fallback', () {
      // Naming it twice would read as belt-and-braces and is the shape that
      // hides the bug: `monoFallback.first` looking like the family is exactly
      // why nobody noticed the family was never set.
      expect(SourcePane.monoFallback, isNot(contains(SourcePane.monoFamily)));
      expect(SourcePane.monoFallback.last, 'monospace');
    });
  });
}
