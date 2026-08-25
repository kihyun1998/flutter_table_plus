/// The colours the example's tables wear.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// The colours the demo's table wears, in one brightness.
///
/// The demo used to paint the table blue in eleven places. Nothing chose that
/// blue — the package's own defaults are already near-neutral (a `#F5F5F5`
/// header on `#E0E0E0` rules over a white body), and the blues were laid over
/// them. Once the app chrome went achromatic the table held the only colour on
/// screen, which made an inherited colour into a claim. So it is neutral, and
/// deliberately so.
///
/// **Neutral is the default, not the ceiling.** Every colour here is a theme
/// field a consumer sets, and several are settings the playground already
/// exposes. Showing them neutral says what the package looks like out of the
/// box; the knobs are where a reader finds out it can be anything.
///
/// Interaction states are neutral too — selection is a band of value, not of
/// hue. That is the expensive part of an achromatic table: with no colour to
/// carry state, the bands have to be far enough apart in lightness to be
/// unmistakable, which is why [selectedBand] sits well clear of [altBand]
/// rather than a shade away from it.
///
/// The one exemption is the editing markers, which stay amber. An editing cell
/// is a transient state a reader has to notice — the same argument that keeps
/// `error` red in the app chrome.
class TablePalette {
  const TablePalette({
    required this.headerBand,
    required this.headerLine,
    required this.rule,
    required this.headerInk,
    required this.sortIcon,
    required this.sortIconIdle,
    required this.surface,
    required this.altBand,
    required this.ink,
    required this.mutedInk,
    required this.selectedBand,
  });

  final Color headerBand;
  final Color headerLine;
  final Color rule;
  final Color headerInk;
  final Color sortIcon;
  final Color sortIconIdle;
  final Color surface;
  final Color altBand;
  final Color ink;
  final Color mutedInk;
  final Color selectedBand;

  static const light = TablePalette(
    headerBand: Color(0xFFF1F1F1),
    headerLine: Color(0xFFD8D8D8),
    rule: Color(0xFFE0E0E0),
    headerInk: Color(0xFF1F1F1F),
    sortIcon: Color(0xFF3D3D3D),
    sortIconIdle: Color(0xFFAFAFAF),
    surface: Color(0xFFFFFFFF),
    altBand: Color(0xFFF7F7F7),
    ink: Color(0xFF1A1A1A),
    mutedInk: Color(0xFF8A8A8A),
    selectedBand: Color(0xFFDCDCDC),
  );

  static const dark = TablePalette(
    headerBand: Color(0xFF1E1E1E),
    headerLine: Color(0xFF343434),
    rule: Color(0xFF2C2C2C),
    headerInk: Color(0xFFEDEDED),
    sortIcon: Color(0xFFCFCFCF),
    sortIconIdle: Color(0xFF5F5F5F),
    surface: Color(0xFF141414),
    altBand: Color(0xFF1B1B1B),
    ink: Color(0xFFE6E6E6),
    mutedInk: Color(0xFF7E7E7E),
    selectedBand: Color(0xFF383838),
  );

  /// The palette for [brightness].
  static TablePalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// A neutral table theme for a demo that has no settings panel behind it.
///
/// The playground assembles its own theme, because sixty-odd settings feed into
/// it. Everything else in this example — the viewport lab today, the recipes
/// after it — wants the same colours without the machinery, and reaching into
/// the playground for them is precisely the dependency a recipe is forbidden to
/// have. So the palette lives here, and both sides read it.
TablePlusTheme demoTableTheme(Brightness brightness) {
  final p = TablePalette.of(brightness);

  return TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      backgroundColor: p.headerBand,
      textStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.headerInk,
      ),
      bottomBorder: TablePlusHeaderBorderTheme(show: true, color: p.rule),
      verticalDivider: TablePlusHeaderDividerTheme(show: true, color: p.rule),
    ),
    bodyTheme: TablePlusBodyTheme(
      backgroundColor: p.surface,
      alternateRowColor: p.altBand,
      textStyle: TextStyle(fontSize: 13, color: p.ink),
      dimRowTextStyle: TextStyle(fontSize: 13, color: p.mutedInk),
      selectedRowColor: p.selectedBand,
      dividerColor: p.rule,
      showHorizontalDividers: true,
    ),
  );
}
