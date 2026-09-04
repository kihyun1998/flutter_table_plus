import 'package:flutter/material.dart';

/// Enum for controlling when to show bottom border on the last row.
enum LastRowBorderBehavior {
  /// Never show bottom border on the last row (default, current behavior).
  never,

  /// Always show bottom border on the last row.
  always,

  /// Smart behavior: show bottom border only when there's no vertical scroll.
  /// When the table content fits within the viewport, shows the border for a clean finish.
  /// When vertical scrolling is needed, hides the border since more content is available.
  smart,
}

/// Theme configuration for the table body.
class TablePlusBodyTheme {
  /// Creates a [TablePlusBodyTheme] with the specified styling properties.
  const TablePlusBodyTheme({
    this.rowHeight = 48.0,
    this.backgroundColor = Colors.white,
    this.alternateRowColor,
    this.summaryRowBackgroundColor,
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    // Selection styling
    this.selectedRowColor = const Color(0xFFE3F2FD),
    this.selectedRowTextStyle,
    // Dim row styling
    this.dimRowColor,
    this.dimRowTextStyle,
    this.dimRowHoverColor,
    this.dimRowSplashColor,
    this.dimRowHighlightColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.dividerColor = const Color(0xFFE0E0E0),
    this.dividerThickness = 1.0,
    this.verticalDividerColor,
    this.verticalDividerThickness,
    this.memberDividerColor,
    this.emptyStateTextStyle,
    this.mergedRowCountTextStyle,
    this.showVerticalDividers = true,
    this.showHorizontalDividers = true,
    this.lastRowBorderBehavior = LastRowBorderBehavior.never,
    // Row interaction properties
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.selectedRowHoverColor,
    this.selectedRowSplashColor,
    this.selectedRowHighlightColor,
    this.doubleClickTime = const Duration(milliseconds: 500),
  });

  /// The height of each data row.
  final double rowHeight;

  /// The background color of rows.
  final Color backgroundColor;

  /// The alternate row color for striped tables.
  /// If null, all rows will use [backgroundColor].
  final Color? alternateRowColor;

  /// The background color for summary rows in merged row groups.
  /// If null, will use [backgroundColor] with alpha 0.2.
  final Color? summaryRowBackgroundColor;

  /// The text style for body cells.
  final TextStyle textStyle;

  /// The background color for selected rows.
  final Color selectedRowColor;

  /// The text style for selected rows.
  /// If null, the default [textStyle] will be used.
  final TextStyle? selectedRowTextStyle;

  /// The background color for dim rows.
  /// Dim rows are rows that meet a certain condition (determined by isDimRow callback).
  /// If null, dim rows will use normal row colors.
  final Color? dimRowColor;

  /// The text style for dim rows.
  /// If null, the default [textStyle] will be used.
  final TextStyle? dimRowTextStyle;

  /// The hover color for dim rows.
  /// If null, uses the default [hoverColor].
  final Color? dimRowHoverColor;

  /// The splash color for dim rows.
  /// If null, uses the default [splashColor].
  final Color? dimRowSplashColor;

  /// The highlight color for dim rows.
  /// If null, uses the default [highlightColor].
  final Color? dimRowHighlightColor;

  /// The padding inside body cells.
  final EdgeInsets padding;

  /// The color of row dividers.
  final Color dividerColor;

  /// The thickness of row dividers.
  final double dividerThickness;

  /// The color of the vertical divider between two columns.
  ///
  /// If null, [dividerColor] at alpha 0.5. The default is the *derivation*
  /// rather than the colour it currently produces, so a caller who changes
  /// [dividerColor] keeps the hierarchy between the three lines this package
  /// draws without restating any of it. Set this to take the column rule off
  /// that derivation entirely (#171).
  final Color? verticalDividerColor;

  /// The width of the vertical divider between two columns.
  ///
  /// If null, `0.5`. Deliberately **not** [dividerThickness] — those are two
  /// different lines today, and defaulting one to the other would change what
  /// every existing caller renders. The header's half of this same rule reads
  /// `headerTheme.verticalDivider.thickness`, which defaults to `1.0`, so the
  /// column line is discontinuous at the header/body seam until someone
  /// chooses which width it should be. This field is what makes that choice
  /// possible to make and to undo (#171).
  final double? verticalDividerThickness;

  /// The color of the divider between two members *inside* one merged group.
  ///
  /// If null, [dividerColor] at alpha 0.3 — one step lighter than the column
  /// divider's 0.5 and two lighter than a row boundary's full alpha, which is
  /// the hierarchy the package draws by default.
  ///
  /// There is no matching width field, and its absence is the rule rather than
  /// an omission: a member separator is a horizontal rule and already follows
  /// [dividerThickness] like every other one. Adding a width here would undo
  /// what #155 fixed.
  final Color? memberDividerColor;

  /// The text style for the placeholder shown when `data` is empty.
  ///
  /// If null, [textStyle] in grey and italic — derived, so it follows a scaled
  /// or recoloured body without being restated.
  final TextStyle? emptyStateTextStyle;

  /// The text style for the "N rows" caption under a merged group's checkbox.
  ///
  /// If null, a 10px grey caption. Unlike [emptyStateTextStyle] this default is
  /// **not** derived from [textStyle] — 10 is a caption size, not a scaled body
  /// size — which is why [scaledBy] has to materialise it rather than skip it.
  final TextStyle? mergedRowCountTextStyle;

  /// Whether to show vertical dividers between columns.
  final bool showVerticalDividers;

  /// Whether to show horizontal dividers between rows.
  final bool showHorizontalDividers;

  /// Controls when to show bottom border on the last row.
  ///
  /// - [LastRowBorderBehavior.never]: Never show bottom border on last row (default)
  /// - [LastRowBorderBehavior.always]: Always show bottom border on last row
  /// - [LastRowBorderBehavior.smart]: Show border only when no vertical scroll
  final LastRowBorderBehavior lastRowBorderBehavior;

  /// The hover color for unselected rows.
  /// If null, the default framework hover effect is used.
  /// Use Colors.transparent to disable the hover effect.
  final Color? hoverColor;

  /// The splash color for unselected rows.
  /// If null, the default framework splash effect is used.
  /// Use Colors.transparent to disable the splash effect.
  final Color? splashColor;

  /// The highlight color for unselected rows.
  /// If null, the default framework highlight effect is used.
  /// Use Colors.transparent to disable the highlight effect.
  final Color? highlightColor;

  /// The hover color for selected rows.
  /// If null, the default framework hover effect is used.
  /// Use Colors.transparent to disable the hover effect for selected rows.
  final Color? selectedRowHoverColor;

  /// The splash color for selected rows.
  /// If null, the default framework splash effect is used.
  /// Use Colors.transparent to disable the splash effect for selected rows.
  final Color? selectedRowSplashColor;

  /// The highlight color for selected rows.
  /// If null, the default framework highlight effect is used.
  /// Use Colors.transparent to disable the highlight effect for selected rows.
  final Color? selectedRowHighlightColor;

  /// The maximum duration between two taps for them to be considered a double-tap.
  /// Defaults to 500 milliseconds.
  final Duration doubleClickTime;

  /// Whether a bottom border should be shown for a row.
  ///
  /// Takes into account the row position and [lastRowBorderBehavior] setting.
  /// [needsVerticalScroll] is only used when behavior is [LastRowBorderBehavior.smart].
  bool shouldShowBottomBorder({
    required bool isLastRow,
    required bool needsVerticalScroll,
  }) {
    if (!showHorizontalDividers) return false;
    if (!isLastRow) return true;

    switch (lastRowBorderBehavior) {
      case LastRowBorderBehavior.never:
        return false;
      case LastRowBorderBehavior.always:
        return true;
      case LastRowBorderBehavior.smart:
        return !needsVerticalScroll;
    }
  }

  /// The right [BorderSide] for vertical column dividers between cells.
  ///
  /// Returns [BorderSide.none] when [showVerticalDividers] is false.
  /// Used to compose [Border] objects that include other sides (e.g. bottom).
  BorderSide get verticalDividerSide => showVerticalDividers
      ? BorderSide(
          color: verticalDividerColor ?? dividerColor.withValues(alpha: 0.5),
          width: verticalDividerThickness ?? 0.5,
        )
      : BorderSide.none;

  /// A right-only [Border] for vertical column dividers, or null when disabled.
  ///
  /// Convenience getter for the common case where only the right border is
  /// needed (most regular and merged cells).
  Border? get verticalDividerBorder =>
      showVerticalDividers ? Border(right: verticalDividerSide) : null;

  /// The [BorderSide] separating two members *inside* one merged group.
  ///
  /// Distinct from the group's own outer border, which [rowDecoration] draws
  /// from [dividerThickness] at full [dividerColor] — this is the line between
  /// two members of that group, and a member is not a row, so no row decoration
  /// can draw it. The alpha matches what the merged row already used; only the
  /// width moves, from a hardcoded `1` to the theme's own thickness (#155).
  ///
  /// Unconditional, and the condition lives at the one call site. Whether a
  /// member draws at all is answered by `_memberBottomSide` in
  /// `table_plus_merged_row.dart` — *is another cell following me inside this
  /// group*, and is `showHorizontalDividers` on. Re-checking either here would
  /// be a second guard over the same condition, and a doubled guard is one no
  /// test can pin: mutating away either half leaves the other covering for it.
  /// Measured, on the pass that tried to pin it.
  ///
  /// It is deliberately **not** [shouldShowBottomBorder], which asks whether a
  /// *row* is the table's last. That question governs this group's own outer
  /// edge through [rowDecoration] and nothing inside it (#157).
  BorderSide get memberDividerSide => BorderSide(
        color: memberDividerColor ?? dividerColor.withValues(alpha: 0.3),
        width: dividerThickness,
      );

  /// The resolved style for the empty-data placeholder.
  ///
  /// Resolution lives here rather than at the call site because the fallback is
  /// the thing being made reachable: written into `table_body.dart` it was a
  /// `Colors.grey.shade600` no caller could name (#171).
  TextStyle get effectiveEmptyStateTextStyle =>
      emptyStateTextStyle ??
      textStyle.copyWith(
        color: const Color(0xFF757575), // Colors.grey.shade600
        fontStyle: FontStyle.italic,
      );

  /// The resolved style for a merged group's "N rows" caption.
  TextStyle get effectiveMergedRowCountTextStyle =>
      mergedRowCountTextStyle ??
      const TextStyle(
        fontSize: 10,
        color: Color(0xFF757575), // Colors.grey.shade600
      );

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    Color? summaryRowBackgroundColor,
    TextStyle? textStyle,
    Color? selectedRowColor,
    TextStyle? selectedRowTextStyle,
    Color? dimRowColor,
    TextStyle? dimRowTextStyle,
    Color? dimRowHoverColor,
    Color? dimRowSplashColor,
    Color? dimRowHighlightColor,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
    Color? verticalDividerColor,
    double? verticalDividerThickness,
    Color? memberDividerColor,
    TextStyle? emptyStateTextStyle,
    TextStyle? mergedRowCountTextStyle,
    bool? showVerticalDividers,
    bool? showHorizontalDividers,
    LastRowBorderBehavior? lastRowBorderBehavior,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
    Color? selectedRowHoverColor,
    Color? selectedRowSplashColor,
    Color? selectedRowHighlightColor,
    Duration? doubleClickTime,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      summaryRowBackgroundColor:
          summaryRowBackgroundColor ?? this.summaryRowBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      selectedRowTextStyle: selectedRowTextStyle ?? this.selectedRowTextStyle,
      dimRowColor: dimRowColor ?? this.dimRowColor,
      dimRowTextStyle: dimRowTextStyle ?? this.dimRowTextStyle,
      dimRowHoverColor: dimRowHoverColor ?? this.dimRowHoverColor,
      dimRowSplashColor: dimRowSplashColor ?? this.dimRowSplashColor,
      dimRowHighlightColor: dimRowHighlightColor ?? this.dimRowHighlightColor,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      verticalDividerColor: verticalDividerColor ?? this.verticalDividerColor,
      verticalDividerThickness:
          verticalDividerThickness ?? this.verticalDividerThickness,
      memberDividerColor: memberDividerColor ?? this.memberDividerColor,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      mergedRowCountTextStyle:
          mergedRowCountTextStyle ?? this.mergedRowCountTextStyle,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showHorizontalDividers:
          showHorizontalDividers ?? this.showHorizontalDividers,
      lastRowBorderBehavior:
          lastRowBorderBehavior ?? this.lastRowBorderBehavior,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      selectedRowHoverColor:
          selectedRowHoverColor ?? this.selectedRowHoverColor,
      selectedRowSplashColor:
          selectedRowSplashColor ?? this.selectedRowSplashColor,
      selectedRowHighlightColor:
          selectedRowHighlightColor ?? this.selectedRowHighlightColor,
      doubleClickTime: doubleClickTime ?? this.doubleClickTime,
    );
  }

  /// Gets the effective hover color for rows based on selection and dim state.
  /// Priority: selected > dim > normal
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveHoverColor(bool isSelected, bool isDim) {
    if (isSelected) {
      return selectedRowHoverColor ?? hoverColor;
    } else if (isDim) {
      return dimRowHoverColor ?? hoverColor;
    } else {
      return hoverColor;
    }
  }

  /// Gets the effective splash color for rows based on selection and dim state.
  /// Priority: selected > dim > normal
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveSplashColor(bool isSelected, bool isDim) {
    if (isSelected) {
      return selectedRowSplashColor ?? splashColor;
    } else if (isDim) {
      return dimRowSplashColor ?? splashColor;
    } else {
      return splashColor;
    }
  }

  /// Gets the effective highlight color for rows based on selection and dim state.
  /// Priority: selected > dim > normal
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveHighlightColor(bool isSelected, bool isDim) {
    if (isSelected) {
      return selectedRowHighlightColor ?? highlightColor;
    } else if (isDim) {
      return dimRowHighlightColor ?? highlightColor;
    } else {
      return highlightColor;
    }
  }

  /// Gets the effective text style for rows based on selection and dim state.
  /// Priority: selected > dim > normal
  /// Returns the appropriate text style based on row state.
  TextStyle getEffectiveTextStyle(bool isSelected, bool isDim) {
    if (isSelected && selectedRowTextStyle != null) {
      return selectedRowTextStyle!;
    } else if (isDim && dimRowTextStyle != null) {
      return dimRowTextStyle!;
    } else {
      return textStyle;
    }
  }

  /// Returns a new [TablePlusBodyTheme] with dimensional values scaled by [factor].
  ///
  /// Scales: rowHeight, every text style's fontSize, padding.
  /// Does NOT scale: colors, divider thickness, booleans, durations.
  TablePlusBodyTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return copyWith(
      rowHeight: rowHeight * factor,
      textStyle: textStyle.copyWith(
        fontSize: (textStyle.fontSize ?? 14) * factor,
      ),
      selectedRowTextStyle: selectedRowTextStyle?.copyWith(
        fontSize: (selectedRowTextStyle!.fontSize ?? 14) * factor,
      ),
      dimRowTextStyle: dimRowTextStyle?.copyWith(
        fontSize: (dimRowTextStyle!.fontSize ?? 14) * factor,
      ),
      // Null-safe, because an unset one needs no help: its default derives from
      // [textStyle], which this same call has already scaled. Materialising it
      // here would scale it twice.
      emptyStateTextStyle: emptyStateTextStyle?.copyWith(
        fontSize: (emptyStateTextStyle!.fontSize ?? 14) * factor,
      ),
      // And the opposite, for the opposite reason. A null here is not "nothing
      // to scale" — the default is a bare 10px caption deriving from no scaled
      // field, so skipping it leaves the caption at 10 while every other size
      // in the table doubles. Resolve first, then scale.
      mergedRowCountTextStyle: effectiveMergedRowCountTextStyle.copyWith(
        fontSize: (effectiveMergedRowCountTextStyle.fontSize ?? 10) * factor,
      ),
      padding: padding * factor,
    );
  }
}
