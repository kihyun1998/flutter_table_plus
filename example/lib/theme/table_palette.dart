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
/// The one exemption is the editing markers ([editingCell], [editingLine],
/// [editingCursor]), which stay amber. An editing cell is a transient state a
/// reader has to notice — the same argument that keeps `error` red in the app
/// chrome. That sentence stood here for two tickets while the class carried no
/// editing colours at all, which made it a rationale for a decision nothing
/// implemented; the fields arrived with the cell-editing recipe (#105).
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
    required this.dragBand,
    required this.dragBandEdge,
    required this.editingCell,
    required this.editingLine,
    required this.editingCursor,
    required this.checkboxFill,
    required this.checkboxTick,
    required this.checkboxEdge,
    required this.resizeGrip,
    required this.scrollTrack,
    required this.scrollThumb,
    required this.tooltipBand,
    required this.tooltipInk,
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

  /// The rubber band drag-select draws, and its edge.
  ///
  /// The package defaults these to `#33448AFF` / `#448AFF` — a blue nothing in
  /// this app chose. It is invisible until a table is both selectable and
  /// dragged, which is why it survived the sweep that took the other blues out
  /// (#110): no demo rendered it.
  final Color dragBand;
  final Color dragBandEdge;

  /// The selection checkbox: the box when checked, the tick inside it, and the
  /// outline when it is not.
  ///
  /// **These are load-bearing, not decorative.** `flutter_checkbox` resolves
  /// `activeColor` from `ColorScheme.primary` but hard-codes `checkColor` to
  /// `Colors.white`, and this app's dark scheme has `primary == #FFFFFF` — so
  /// leaving them unset draws a white tick on a white box and the checkmark
  /// disappears. Measured 2026-08-26. That is an upstream asymmetry (one term
  /// of a pair follows the theme, the other does not) and it is raised there;
  /// setting them here is what any consumer with a non-default scheme has to do
  /// anyway, which is why this is policy rather than a workaround.
  final Color checkboxFill;
  final Color checkboxTick;
  final Color checkboxEdge;

  /// The resize handle's indicator line.
  ///
  /// **Its default is not a colour, it is an inheritance**: unset, the handle
  /// falls back to `headerTheme.verticalDivider.color` — the hairline between
  /// two header cells. A divider is chosen to be barely there, and the handle
  /// is an affordance that has to be seen the moment the pointer finds it, so
  /// the fallback is the one colour on the header guaranteed to be wrong for
  /// it. The handle only draws on hover or drag, which is exactly why nothing
  /// noticed: an invisible affordance and an absent one look identical.
  final Color resizeGrip;

  /// The editing markers, and the one place this palette is not achromatic.
  ///
  /// A cell that is open for editing is a *transient* state with a keystroke's
  /// worth of consequence behind it, so it is the one thing here allowed to
  /// shout. Neutral would be correct and useless.
  final Color editingCell;
  final Color editingLine;
  final Color editingCursor;

  /// The scrollbar's own two colours.
  ///
  /// The package defaults them to a light `#E0E0E0` track and a `#757575`
  /// thumb, which cannot know the brightness the consumer is drawing in — a
  /// dark table gets a bright track. Deciding them here is the demo doing what
  /// any consumer has to do.
  final Color scrollTrack;
  final Color scrollThumb;

  /// The tooltip bubble, and the text on it.
  ///
  /// **A tooltip is the one surface that is deliberately not the table's.** It
  /// is drawn over the page rather than in it, so it inverts: near-ink on paper
  /// in the light theme, near-paper on ink in the dark one. That is the same
  /// reason a tooltip is dark in a light app everywhere else — it has to read
  /// as *above* the surface, and matching the surface is how it stops doing so.
  ///
  /// The package's default is a fixed `#616161` with white text, which cannot
  /// know which brightness it is being drawn in. It is legible in both, which
  /// is exactly why nothing forced the decision until a recipe drew one.
  final Color tooltipBand;
  final Color tooltipInk;

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
    scrollTrack: Color(0xFFEDEDED),
    scrollThumb: Color(0xFF9A9A9A),
    dragBand: Color(0x22000000),
    dragBandEdge: Color(0xFF6B6B6B),
    editingCell: Color(0xFFFFF3D6),
    editingLine: Color(0xFFB8860B),
    editingCursor: Color(0xFFB8860B),
    checkboxFill: Color(0xFF1A1A1A),
    checkboxTick: Color(0xFFFFFFFF),
    checkboxEdge: Color(0xFF9A9A9A),
    resizeGrip: Color(0xFF4A4A4A),
    tooltipBand: Color(0xFF2B2B2B),
    tooltipInk: Color(0xFFF2F2F2),
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
    scrollTrack: Color(0xFF232323),
    scrollThumb: Color(0xFF5E5E5E),
    dragBand: Color(0x33FFFFFF),
    dragBandEdge: Color(0xFFA6A6A6),
    editingCell: Color(0xFF3A2F14),
    editingLine: Color(0xFFD9A93A),
    editingCursor: Color(0xFFD9A93A),
    checkboxFill: Color(0xFFE6E6E6),
    checkboxTick: Color(0xFF141414),
    checkboxEdge: Color(0xFF6E6E6E),
    resizeGrip: Color(0xFFC4C4C4),
    tooltipBand: Color(0xFFE8E8E8),
    tooltipInk: Color(0xFF1A1A1A),
  );

  /// The palette for [brightness].
  static TablePalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// A neutral table theme for a demo that has no settings panel behind it.
///
/// The playground assembles its own theme, because sixty-odd settings feed into
/// it. Everything else in this example — the recipes, the scenarios, the shell's
/// own demos — wants the same colours without the machinery, and reaching into
/// the playground for them is precisely the dependency a recipe is forbidden to
/// have. So the palette lives here, and both sides read it.
///
/// **Three sub-themes are still at package defaults**, and they are named
/// rather than counted: `hoverButtonTheme`, `rowTooltipTheme` and
/// `headerTooltipTheme`. A count says nothing about which one grew a reason to
/// be decided, and it was wrong here for two tickets — it read "five" while six
/// of the ten were set. Naming them means the next addition is visible in the
/// diff instead of arithmetic nobody re-runs.
///
/// Each is left for a reason rather than by omission. `hoverButtonTheme` is
/// unset because no recipe draws hover buttons yet. `headerTooltipTheme` is
/// unset *deliberately and permanently*: null is what makes the header fall
/// back to `tooltipTheme`, and the tooltips recipe exists partly to walk that
/// fallback. `rowTooltipTheme` is unset because a row card needs a transparent,
/// unpadded bubble and nothing else does — the row-card recipe overrides it
/// locally rather than making every table here pay for it.
///
/// That is the measurement behind #112: nothing here can be derived from the
/// app's `ColorScheme`, so every colour below is a decision this demo makes by
/// hand, and the ones it has no reason to make yet stay default. Three stopped
/// being safe to leave the moment a demo rendered them — drag selection and
/// cell editing at #105 (`#448AFF`, `#2196F3`, blues #110's sweep never saw
/// because no demo drew them), and the tooltip bubble at #107.
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
      bottomBorder: TablePlusHeaderBorderTheme(show: true, color: p.headerLine),
      verticalDivider: TablePlusHeaderDividerTheme(show: true, color: p.rule),
      // `SortIcons` holds widgets, not colours, so the only way to colour a
      // sort arrow is to rebuild the glyphs. The unsorted one is the reason:
      // its package default hard-codes `Colors.grey`, which reads as an active
      // state next to a neutral header rather than as "sortable, not sorted".
      resizeHandle: TablePlusResizeHandleTheme(color: p.resizeGrip),
      sortIcons: SortIcons(
        ascending: Icon(Icons.arrow_upward, size: 16, color: p.sortIcon),
        descending: Icon(Icons.arrow_downward, size: 16, color: p.sortIcon),
        unsorted: Icon(Icons.unfold_more, size: 16, color: p.sortIconIdle),
      ),
    ),
    checkboxTheme: TablePlusCheckboxTheme(
      style: CheckboxStyle(
        size: 18,
        activeColor: p.checkboxFill,
        checkColor: p.checkboxTick,
        borderColor: p.checkboxEdge,
      ),
    ),
    dragSelectionTheme: TablePlusDragSelectionTheme(
      fillColor: p.dragBand,
      borderColor: p.dragBandEdge,
    ),
    editableTheme: TablePlusEditableTheme(
      editingCellColor: p.editingCell,
      editingBorderColor: p.editingLine,
      cursorColor: p.editingCursor,
      editingTextStyle: TextStyle(fontSize: 13, color: p.ink),
    ),
    scrollbarTheme: TablePlusScrollbarTheme(
      trackColor: p.scrollTrack,
      thumbColor: p.scrollThumb,
    ),
    // The header tooltip theme stays null on purpose: that is what makes the
    // header fall back to this one. Handing it a copy would look identical and
    // mean something else.
    tooltipTheme: TablePlusTooltipTheme(
      backgroundColor: p.tooltipBand,
      textStyle: TextStyle(fontSize: 12, color: p.tooltipInk),
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
