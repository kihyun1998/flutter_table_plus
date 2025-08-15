import 'body_theme.dart' show TablePlusBodyTheme;
import 'divider_theme.dart' show TablePlusDividerTheme;
import 'editable_theme.dart' show TablePlusEditableTheme;
import 'header_theme.dart' show TablePlusHeaderTheme;
import 'scrollbar_theme.dart' show TablePlusScrollbarTheme;
import 'selection_theme.dart' show TablePlusSelectionTheme;
import 'tooltip_theme.dart' show TablePlusTooltipTheme;

/// Theme configuration for the table components.
class TablePlusTheme {
  /// Creates a [TablePlusTheme] with the specified styling properties.
  const TablePlusTheme({
    this.headerTheme = const TablePlusHeaderTheme(),
    this.bodyTheme = const TablePlusBodyTheme(),
    this.scrollbarTheme = const TablePlusScrollbarTheme(),
    this.selectionTheme = const TablePlusSelectionTheme(),
    this.editableTheme = const TablePlusEditableTheme(),
    this.tooltipTheme = const TablePlusTooltipTheme(),
    this.dividerTheme = const TablePlusDividerTheme(),
  });

  /// Theme configuration for the table header.
  final TablePlusHeaderTheme headerTheme;

  /// Theme configuration for the table body.
  final TablePlusBodyTheme bodyTheme;

  /// Theme configuration for the scrollbars.
  final TablePlusScrollbarTheme scrollbarTheme;

  /// Theme configuration for row selection.
  final TablePlusSelectionTheme selectionTheme;

  /// Theme configuration for cell editing.
  final TablePlusEditableTheme editableTheme;

  /// Theme configuration for cell tooltips.
  final TablePlusTooltipTheme tooltipTheme;

  /// Theme configuration for the frozen column divider.
  final TablePlusDividerTheme dividerTheme;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
    TablePlusSelectionTheme? selectionTheme,
    TablePlusEditableTheme? editableTheme,
    TablePlusTooltipTheme? tooltipTheme,
    TablePlusDividerTheme? dividerTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      selectionTheme: selectionTheme ?? this.selectionTheme,
      editableTheme: editableTheme ?? this.editableTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
      dividerTheme: dividerTheme ?? this.dividerTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
}
