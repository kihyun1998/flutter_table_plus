import 'package:flutter/material.dart';

/// Theme configuration for row selection.
class TablePlusSelectionTheme {
  /// Creates a [TablePlusSelectionTheme] with the specified styling properties.
  const TablePlusSelectionTheme({
    this.selectedRowColor = const Color(0xFFE3F2FD),
    this.selectedRowTextStyle,
    this.checkboxColor = const Color(0xFF2196F3),
    this.checkboxSize = 18.0,
    this.showCheckboxColumn = true,
    this.showSelectAllCheckbox = true,
    this.checkboxColumnWidth = 60.0,
    this.rowHoverColor,
    this.rowSplashColor,
    this.rowHighlightColor,
    this.selectedRowHoverColor,
    this.selectedRowSplashColor,
    this.selectedRowHighlightColor,
  });

  /// The background color for selected rows.
  final Color selectedRowColor;

  /// The text style for selected rows.
  /// If null, the default body text style will be used.
  final TextStyle? selectedRowTextStyle;

  /// The color of the selection checkboxes.
  final Color checkboxColor;

  /// The size of the selection checkboxes.
  final double checkboxSize;

  /// Whether to show the checkbox column.
  /// If false, rows can only be selected by tapping.
  final bool showCheckboxColumn;

  /// Whether to show the select-all checkbox in the header.
  /// If false, only individual row selection is available.
  /// Automatically set to false for single selection mode.
  final bool showSelectAllCheckbox;

  /// The width of the checkbox column.
  final double checkboxColumnWidth;

  /// The hover color for unselected rows.
  /// If null, the default framework hover effect is used.
  /// Use Colors.transparent to disable the hover effect.
  final Color? rowHoverColor;

  /// The splash color for unselected rows.
  /// If null, the default framework splash effect is used.
  /// Use Colors.transparent to disable the splash effect.
  final Color? rowSplashColor;

  /// The highlight color for unselected rows.
  /// If null, the default framework highlight effect is used.
  /// Use Colors.transparent to disable the highlight effect.
  final Color? rowHighlightColor;

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

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusSelectionTheme copyWith({
    Color? selectedRowColor,
    TextStyle? selectedRowTextStyle,
    Color? checkboxColor,
    double? checkboxSize,
    bool? showCheckboxColumn,
    bool? showSelectAllCheckbox,
    double? checkboxColumnWidth,
    Color? rowHoverColor,
    Color? rowSplashColor,
    Color? rowHighlightColor,
    Color? selectedRowHoverColor,
    Color? selectedRowSplashColor,
    Color? selectedRowHighlightColor,
  }) {
    return TablePlusSelectionTheme(
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      selectedRowTextStyle: selectedRowTextStyle ?? this.selectedRowTextStyle,
      checkboxColor: checkboxColor ?? this.checkboxColor,
      checkboxSize: checkboxSize ?? this.checkboxSize,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      showSelectAllCheckbox:
          showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
      rowHoverColor: rowHoverColor ?? this.rowHoverColor,
      rowSplashColor: rowSplashColor ?? this.rowSplashColor,
      rowHighlightColor: rowHighlightColor ?? this.rowHighlightColor,
      selectedRowHoverColor:
          selectedRowHoverColor ?? this.selectedRowHoverColor,
      selectedRowSplashColor:
          selectedRowSplashColor ?? this.selectedRowSplashColor,
      selectedRowHighlightColor:
          selectedRowHighlightColor ?? this.selectedRowHighlightColor,
    );
  }

  /// Gets the effective hover color for rows based on selection state.
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveHoverColor(bool isSelected, Color backgroundColor) {
    if (isSelected) {
      return selectedRowHoverColor;
    } else {
      return rowHoverColor;
    }
  }

  /// Gets the effective splash color for rows based on selection state.
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveSplashColor(bool isSelected, Color backgroundColor) {
    if (isSelected) {
      return selectedRowSplashColor;
    } else {
      return rowSplashColor;
    }
  }

  /// Gets the effective highlight color for rows based on selection state.
  /// Returns null to use the default framework effect if no color is specified.
  Color? getEffectiveHighlightColor(bool isSelected, Color backgroundColor) {
    if (isSelected) {
      return selectedRowHighlightColor;
    } else {
      return rowHighlightColor;
    }
  }

  /// Gets the effective text style for rows based on selection state.
  /// Returns the selected row text style if available and row is selected,
  /// otherwise returns the default body text style.
  TextStyle getEffectiveTextStyle(bool isSelected, TextStyle defaultTextStyle) {
    if (isSelected && selectedRowTextStyle != null) {
      return selectedRowTextStyle!;
    } else {
      return defaultTextStyle;
    }
  }
}
