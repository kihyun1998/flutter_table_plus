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

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusSelectionTheme copyWith({
    Color? selectedRowColor,
    Color? checkboxColor,
    double? checkboxSize,
    bool? showCheckboxColumn,
    bool? showSelectAllCheckbox,
    double? checkboxColumnWidth,
  }) {
    return TablePlusSelectionTheme(
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      checkboxColor: checkboxColor ?? this.checkboxColor,
      checkboxSize: checkboxSize ?? this.checkboxSize,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      showSelectAllCheckbox:
          showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
    );
  }
}
