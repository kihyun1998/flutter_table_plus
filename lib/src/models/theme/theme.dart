import 'package:flutter/material.dart' show ColorScheme;

import 'body_theme.dart' show TablePlusBodyTheme;
import 'checkbox_theme.dart' show TablePlusCheckboxTheme;
import 'drag_selection_theme.dart' show TablePlusDragSelectionTheme;
import 'editable_theme.dart' show TablePlusEditableTheme;
import 'header_theme.dart' show TablePlusHeaderTheme;
import 'hover_button_theme.dart' show TablePlusHoverButtonTheme;
import 'scrollbar_theme.dart' show TablePlusScrollbarTheme;
import 'tooltip_theme.dart' show TablePlusTooltipTheme;

/// Theme configuration for the table components.
class TablePlusTheme {
  /// Creates a [TablePlusTheme] with the specified styling properties.
  const TablePlusTheme({
    this.headerTheme = const TablePlusHeaderTheme(),
    this.bodyTheme = const TablePlusBodyTheme(),
    this.scrollbarTheme = const TablePlusScrollbarTheme(),
    this.checkboxTheme = const TablePlusCheckboxTheme(),
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.rowTooltipTheme,
    this.headerTooltipTheme,
    this.hoverButtonTheme = const TablePlusHoverButtonTheme(),
    this.dragSelectionTheme = const TablePlusDragSelectionTheme(),
  });

  /// Creates a [TablePlusTheme] whose colours are derived from [scheme].
  ///
  /// Every colour the table draws takes a role of [scheme]; every size,
  /// padding, thickness and flag is the default constructor's. Colours whose
  /// default is `null` stay `null`, so they keep deriving from the ones set
  /// here. The checkbox follows [scheme], not the ambient theme.
  ///
  /// The selected row's [TablePlusBodyTheme.selectedRowTextStyle] replaces the
  /// body text style rather than merging over it, so a later change to
  /// [TablePlusBodyTheme.textStyle] has to be made to it as well.
  ///
  /// See `docs/THEMING.md` for the role each colour takes.
  factory TablePlusTheme.fromColorScheme(ColorScheme scheme) {
    const base = TablePlusTheme();
    final body = base.bodyTheme;
    final header = base.headerTheme;
    final editable = base.editableTheme;
    final tooltip = base.tooltipTheme;
    final checkbox = base.checkboxTheme;
    return base.copyWith(
      dragSelectionTheme: base.dragSelectionTheme.copyWith(
        borderColor: scheme.primary,
        fillColor: scheme.primary.withAlpha(0x33),
      ),
      scrollbarTheme: base.scrollbarTheme.copyWith(
        thumbColor: scheme.onSurfaceVariant,
        trackColor: scheme.surfaceContainerHighest,
      ),
      tooltipTheme: tooltip.copyWith(
        backgroundColor: scheme.inverseSurface,
        textStyle: tooltip.textStyle.copyWith(color: scheme.onInverseSurface),
      ),
      checkboxTheme: checkbox.copyWith(
        style: checkbox.style.copyWith(
          activeColor: scheme.primary,
          checkColor: scheme.onPrimary,
          borderColor: scheme.outline,
        ),
      ),
      editableTheme: editable.copyWith(
        editingCellColor: scheme.primaryContainer,
        editingTextStyle: editable.editingTextStyle.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        editingBorderColor: scheme.primary,
        cursorColor: scheme.primary,
        errorBorderColor: scheme.error,
        focusedErrorBorderColor: scheme.error,
      ),
      headerTheme: header.copyWith(
        backgroundColor: scheme.surfaceContainerHigh,
        textStyle: header.textStyle.copyWith(color: scheme.onSurface),
        topBorder: header.topBorder.copyWith(color: scheme.outlineVariant),
        bottomBorder: header.bottomBorder.copyWith(
          color: scheme.outlineVariant,
        ),
        verticalDivider: header.verticalDivider.copyWith(
          color: scheme.outlineVariant,
        ),
      ),
      bodyTheme: body.copyWith(
        backgroundColor: scheme.surface,
        textStyle: body.textStyle.copyWith(color: scheme.onSurface),
        selectedRowColor: scheme.secondaryContainer,
        selectedRowTextStyle: body.textStyle.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        dividerColor: scheme.outlineVariant,
      ),
    );
  }

  /// Theme configuration for the table header.
  final TablePlusHeaderTheme headerTheme;

  /// Theme configuration for the table body.
  final TablePlusBodyTheme bodyTheme;

  /// Theme configuration for the scrollbars.
  final TablePlusScrollbarTheme scrollbarTheme;

  /// Theme configuration for checkboxes.
  final TablePlusCheckboxTheme checkboxTheme;

  /// Theme configuration for cell editing.
  final TablePlusEditableTheme editableTheme;

  /// Theme configuration for cell tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// Theme configuration for the row tooltip built by `rowTooltipBuilder`.
  ///
  /// Falls back to [tooltipTheme] when null. A row tooltip usually draws its
  /// own surface, so it wants `padding: EdgeInsets.zero`, a transparent
  /// `backgroundColor` and no elevation — settings that would ruin the plain
  /// text tooltips governed by [tooltipTheme].
  final TablePlusTooltipTheme? rowTooltipTheme;

  /// Theme configuration for header tooltips.
  ///
  /// Falls back to [tooltipTheme] when null, so header and cell tooltips look
  /// alike unless you say otherwise. Set this to style them apart — most often
  /// to give the header a different [TablePlusTooltipTheme.anchor], since a
  /// header label and a data cell rarely want the same one.
  final TablePlusTooltipTheme? headerTooltipTheme;

  /// Theme configuration for hover buttons.
  final TablePlusHoverButtonTheme hoverButtonTheme;

  /// Theme configuration for the drag-selection rubber band rectangle.
  final TablePlusDragSelectionTheme dragSelectionTheme;

  /// Returns a new [TablePlusTheme] with all dimensional values scaled by
  /// [factor], by delegating to each dimensional sub-theme's `scaledBy`.
  ///
  /// Names only the sub-themes it scales, and leans on [copyWith] to carry the
  /// rest. The scrollbar and the three tooltip themes render in an overlay,
  /// outside the table viewport, so they are not scaled — and because they are
  /// never named here, a new one cannot be dropped by forgetting to list it.
  TablePlusTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return copyWith(
      headerTheme: headerTheme.scaledBy(factor),
      bodyTheme: bodyTheme.scaledBy(factor),
      checkboxTheme: checkboxTheme.scaledBy(factor),
      editableTheme: editableTheme.scaledBy(factor),
      hoverButtonTheme: hoverButtonTheme.scaledBy(factor),
      dragSelectionTheme: dragSelectionTheme.scaledBy(factor),
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
    TablePlusCheckboxTheme? checkboxTheme,
    TablePlusEditableTheme? editableTheme,
    TablePlusTooltipTheme? tooltipTheme,
    TablePlusTooltipTheme? rowTooltipTheme,
    TablePlusTooltipTheme? headerTooltipTheme,
    TablePlusHoverButtonTheme? hoverButtonTheme,
    TablePlusDragSelectionTheme? dragSelectionTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      checkboxTheme: checkboxTheme ?? this.checkboxTheme,
      editableTheme: editableTheme ?? this.editableTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
      rowTooltipTheme: rowTooltipTheme ?? this.rowTooltipTheme,
      headerTooltipTheme: headerTooltipTheme ?? this.headerTooltipTheme,
      hoverButtonTheme: hoverButtonTheme ?? this.hoverButtonTheme,
      dragSelectionTheme: dragSelectionTheme ?? this.dragSelectionTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
}
