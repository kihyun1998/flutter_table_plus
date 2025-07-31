import 'package:flutter/material.dart';

/// Theme configuration for row selection.
class TablePlusSelectionTheme {
  /// Creates a [TablePlusSelectionTheme] with the specified styling properties.
  const TablePlusSelectionTheme({
    this.selectedRowColor = const Color(0xFFE3F2FD),
    this.checkboxColor = const Color(0xFF2196F3),
    this.checkboxSize = 18.0,
    this.showCheckboxColumn = true,
    this.showSelectAllCheckbox = true,
    this.checkboxColumnWidth = 60.0,
    this.enableRowInteractionEffects = true,
    this.rowHoverColor,
    this.rowSplashColor,
    this.rowHighlightColor,
    this.selectedRowHoverColor,
    this.selectedRowSplashColor,
    this.selectedRowHighlightColor,
  });

  /// The background color for selected rows.
  final Color selectedRowColor;

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

  /// Whether to enable row interaction effects (hover, splash, highlight).
  /// When false, all row interaction effects are disabled.
  final bool enableRowInteractionEffects;

  /// The hover color for unselected rows.
  /// If null, automatically generated from background color with opacity.
  /// Use Colors.transparent to disable hover effect.
  final Color? rowHoverColor;

  /// The splash color for unselected rows.
  /// If null, automatically generated from background color with opacity.
  /// Use Colors.transparent to disable splash effect.
  final Color? rowSplashColor;

  /// The highlight color for unselected rows.
  /// If null, automatically generated from background color with opacity.
  /// Use Colors.transparent to disable highlight effect.
  final Color? rowHighlightColor;

  /// The hover color for selected rows.
  /// If null, automatically generated from selectedRowColor with opacity.
  /// Use Colors.transparent to disable hover effect for selected rows.
  final Color? selectedRowHoverColor;

  /// The splash color for selected rows.
  /// If null, automatically generated from selectedRowColor with opacity.
  /// Use Colors.transparent to disable splash effect for selected rows.
  final Color? selectedRowSplashColor;

  /// The highlight color for selected rows.
  /// If null, automatically generated from selectedRowColor with opacity.
  /// Use Colors.transparent to disable highlight effect for selected rows.
  final Color? selectedRowHighlightColor;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusSelectionTheme copyWith({
    Color? selectedRowColor,
    Color? checkboxColor,
    double? checkboxSize,
    bool? showCheckboxColumn,
    bool? showSelectAllCheckbox,
    double? checkboxColumnWidth,
    bool? enableRowInteractionEffects,
    Color? rowHoverColor,
    Color? rowSplashColor,
    Color? rowHighlightColor,
    Color? selectedRowHoverColor,
    Color? selectedRowSplashColor,
    Color? selectedRowHighlightColor,
  }) {
    return TablePlusSelectionTheme(
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      checkboxColor: checkboxColor ?? this.checkboxColor,
      checkboxSize: checkboxSize ?? this.checkboxSize,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      showSelectAllCheckbox:
          showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
      enableRowInteractionEffects:
          enableRowInteractionEffects ?? this.enableRowInteractionEffects,
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

  /// Gets the effective hover color for rows based on selection state and theme settings.
  Color? getEffectiveHoverColor(bool isSelected, Color backgroundColor) {
    if (!enableRowInteractionEffects) return Colors.transparent;

    if (isSelected) {
      if (selectedRowHoverColor == Colors.transparent)
        return Colors.transparent;
      return selectedRowHoverColor ?? selectedRowColor.withOpacity(0.15);
    } else {
      if (rowHoverColor == Colors.transparent) return Colors.transparent;
      return rowHoverColor ?? backgroundColor.withOpacity(0.10);
    }
  }

  /// Gets the effective splash color for rows based on selection state and theme settings.
  Color? getEffectiveSplashColor(bool isSelected, Color backgroundColor) {
    if (!enableRowInteractionEffects) return Colors.transparent;

    if (isSelected) {
      if (selectedRowSplashColor == Colors.transparent)
        return Colors.transparent;
      return selectedRowSplashColor ?? selectedRowColor.withOpacity(0.25);
    } else {
      if (rowSplashColor == Colors.transparent) return Colors.transparent;
      return rowSplashColor ?? backgroundColor.withOpacity(0.20);
    }
  }

  /// Gets the effective highlight color for rows based on selection state and theme settings.
  Color? getEffectiveHighlightColor(bool isSelected, Color backgroundColor) {
    if (!enableRowInteractionEffects) return Colors.transparent;

    if (isSelected) {
      if (selectedRowHighlightColor == Colors.transparent)
        return Colors.transparent;
      return selectedRowHighlightColor ?? selectedRowColor.withOpacity(0.20);
    } else {
      if (rowHighlightColor == Colors.transparent) return Colors.transparent;
      return rowHighlightColor ?? backgroundColor.withOpacity(0.15);
    }
  }
}
