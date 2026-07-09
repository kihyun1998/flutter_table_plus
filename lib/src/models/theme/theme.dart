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
    this.hoverButtonTheme = const TablePlusHoverButtonTheme(),
    this.dragSelectionTheme = const TablePlusDragSelectionTheme(),
  });

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

  /// Theme configuration for hover buttons.
  final TablePlusHoverButtonTheme hoverButtonTheme;

  /// Theme configuration for the drag-selection rubber band rectangle.
  final TablePlusDragSelectionTheme dragSelectionTheme;

  /// Returns a new [TablePlusTheme] with all dimensional values scaled by [factor].
  ///
  /// Delegates to each sub-theme's `scaledBy` method.
  /// Tooltip theme is NOT scaled (renders in overlay, outside table viewport).
  TablePlusTheme scaledBy(double factor) {
    if (factor == 1.0) return this;
    return TablePlusTheme(
      headerTheme: headerTheme.scaledBy(factor),
      bodyTheme: bodyTheme.scaledBy(factor),
      scrollbarTheme: scrollbarTheme,
      checkboxTheme: checkboxTheme.scaledBy(factor),
      editableTheme: editableTheme.scaledBy(factor),
      tooltipTheme: tooltipTheme,
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
      hoverButtonTheme: hoverButtonTheme ?? this.hoverButtonTheme,
      dragSelectionTheme: dragSelectionTheme ?? this.dragSelectionTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
}
