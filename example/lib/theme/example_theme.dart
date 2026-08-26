/// The example app's own theme — the chrome around the table, not the table.
///
/// Two things live here and they are deliberately kept apart:
///
/// * **This file** themes the *application*: the app bar, the sidebar, the
///   cards and the controls the reader operates.
/// * **`TablePlusTheme`** themes the *package*, and the playground builds it
///   from its settings.
///
/// **The chrome carries no hue at all.** That is the decision, and it is made
/// for the demo's purpose rather than for taste: with an achromatic chrome, the
/// only colour anywhere on screen is the one the table is wearing — so "this
/// colour is something you set" needs no caption. A chrome with an accent of
/// its own would put two colours on screen and lose that.
///
/// The cost is that state has nowhere to go but value: a switch, a selected
/// sidebar row and a slider all express themselves through lightness alone.
/// That is why `accent` here is near-black on light and near-white on dark —
/// the strongest contrast available without reaching for a hue.
///
/// Semantic colour is exempt. `error` stays red, because a failure that reads
/// as a shade of grey is not a failure anyone notices.
///
/// [exampleTheme] is a pure function of [Brightness], which is what lets
/// `test/example_theme_test.dart` assert on it without pumping a widget.
library;

import 'package:flutter/material.dart';

/// Pretendard ships with this example already, as a font the table can be told
/// to use. Borrowing it for the chrome adds no dependency and no asset, and it
/// carries Korean text — which the demo data contains.
const exampleChromeFont = 'Pretendard';

// Flutter derives the scheme; this file only says which one.
//
// `ThemeData.light()` on its own is **not** neutral — Material 3's baseline
// scheme is a violet, `#6750A4` on light and `#D0BCFF` on dark. And the variant
// named `neutral` is not neutral either: seeded from black it comes out with a
// pink cast, `#6F595E`. Measured, not assumed.
//
// `monochrome` seeded from black is the one that is actually achromatic —
// `#000000` primary on a `#F9F9F9` surface, greys the whole way down, and
// `error` still red because a semantic colour is not decoration.
//
// Deriving rather than hand-picking matters for a reason that is easy to miss:
// a `ColorScheme` carries over thirty roles, and a widget this file never
// styles still reads from them. Hand-written values cover the roles someone
// thought of; a derived scheme covers the ones they did not.
const _seed = Colors.black;

ColorScheme _scheme(Brightness brightness) => ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    );

/// The application theme for [brightness].
///
/// Pure: no `BuildContext`, no widget state, no ambient lookups. Both
/// brightnesses are built the same way from the same shape, so neither can grow
/// a treatment the other silently lacks.
///
/// Colour comes from [_scheme]. What is set below is everything Material 3's
/// defaults get wrong for a demo shell and nothing else: the app bar's tint and
/// scroll elevation, cards that want a hairline instead of a shadow, and
/// controls sized for a settings panel rather than a phone.
ThemeData exampleTheme(Brightness brightness) {
  final scheme = _scheme(brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: exampleChromeFont,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      titleTextStyle: TextStyle(
        fontFamily: exampleChromeFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      space: 1,
      thickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      titleTextStyle: TextStyle(
        fontFamily: exampleChromeFont,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: exampleChromeFont,
        fontSize: 13,
        color: scheme.secondary,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: exampleChromeFont, fontSize: 13),
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      thumbColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.surfaceContainerHighest,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

/// Which theme the app is showing, and the ability to change it.
///
/// A [ChangeNotifier] rather than a `setState` in `MyApp`, so that a control
/// deep in a page can cycle the mode without every page in between having to
/// carry a callback for it.
class ExampleThemeController extends ChangeNotifier {
  ExampleThemeController([this._mode = ThemeMode.system]);

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  set mode(ThemeMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  /// system → light → dark → system.
  ///
  /// A cycle rather than a toggle: with only two states there is no way back to
  /// following the operating system once you have left it.
  void cycle() {
    mode = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}

/// Publishes the [ExampleThemeController] to the pages beneath it.
class ExampleThemeScope extends InheritedNotifier<ExampleThemeController> {
  const ExampleThemeScope({
    super.key,
    required ExampleThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The controller above [context], or null when there is none.
  ///
  /// Nullable on purpose. Every page in this example must build without the
  /// scope: the test suite pumps pages directly, and a reader lifting a page
  /// out to look at it should not have to bring the app's theme plumbing
  /// along. A page asks for the control and does without it if it is not
  /// there — it never requires it.
  static ExampleThemeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExampleThemeScope>()?.notifier;
}
