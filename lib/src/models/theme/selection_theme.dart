import 'package:flutter/material.dart';

import 'checkbox_theme.dart';

/// Theme configuration for row selection.
class TablePlusSelectionTheme {
  /// Creates a [TablePlusSelectionTheme] with the specified styling properties.
  const TablePlusSelectionTheme({
    this.selectedRowColor = const Color(0xFFE3F2FD),
    this.selectedRowTextStyle,
    // Deprecated checkbox properties (nullable for backward compatibility)
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxColor,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxHoverColor,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxFocusColor,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxFillColor,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxSide,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxSize,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.showCheckboxColumn,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.showSelectAllCheckbox,
    @Deprecated(
        'Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
    this.checkboxColumnWidth,
    // Row styling
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

  // Deprecated checkbox properties - Use TablePlusCheckboxTheme instead
  /// The color of the selection checkboxes when active (checked).
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.fillColor] instead.
  /// This property will be removed in v1.16.0.
  /// If null, falls back to TablePlusCheckboxTheme.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final Color? checkboxColor;

  /// The color of the checkbox when it's hovered over.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.hoverColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final Color? checkboxHoverColor;

  /// The color of the checkbox when it's focused.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.focusColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final Color? checkboxFocusColor;

  /// The fill color of the checkbox.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.fillColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final Color? checkboxFillColor;

  /// The border side of the checkbox.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.side] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final BorderSide? checkboxSide;

  /// The size of the selection checkboxes.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.size] instead.
  /// This property will be removed in v1.16.0.
  /// If null, falls back to TablePlusCheckboxTheme.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final double? checkboxSize;

  /// Whether to show the checkbox column.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.showCheckboxColumn] instead.
  /// This property will be removed in v1.16.0.
  /// If null, falls back to TablePlusCheckboxTheme.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final bool? showCheckboxColumn;

  /// Whether to show the select-all checkbox in the header.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.showSelectAllCheckbox] instead.
  /// This property will be removed in v1.16.0.
  /// If null, falls back to TablePlusCheckboxTheme.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final bool? showSelectAllCheckbox;

  /// The width of the checkbox column.
  ///
  /// **DEPRECATED**: Use [TablePlusCheckboxTheme.checkboxColumnWidth] instead.
  /// This property will be removed in v1.16.0.
  /// If null, falls back to TablePlusCheckboxTheme.
  @Deprecated('Use TablePlusCheckboxTheme instead. Will be removed in v1.16.0')
  final double? checkboxColumnWidth;

  /// The hover color for unselected rows.
  /// If null, the default framework hover effect is used.
  /// Use Colors.transparent to disable the hover effect.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.hoverColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.hoverColor instead. Will be removed in v1.16.0')
  final Color? rowHoverColor;

  /// The splash color for unselected rows.
  /// If null, the default framework splash effect is used.
  /// Use Colors.transparent to disable the splash effect.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.splashColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.splashColor instead. Will be removed in v1.16.0')
  final Color? rowSplashColor;

  /// The highlight color for unselected rows.
  /// If null, the default framework highlight effect is used.
  /// Use Colors.transparent to disable the highlight effect.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.highlightColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.highlightColor instead. Will be removed in v1.16.0')
  final Color? rowHighlightColor;

  /// The hover color for selected rows.
  /// If null, the default framework hover effect is used.
  /// Use Colors.transparent to disable the hover effect for selected rows.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.selectedRowHoverColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.selectedRowHoverColor instead. Will be removed in v1.16.0')
  final Color? selectedRowHoverColor;

  /// The splash color for selected rows.
  /// If null, the default framework splash effect is used.
  /// Use Colors.transparent to disable the splash effect for selected rows.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.selectedRowSplashColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.selectedRowSplashColor instead. Will be removed in v1.16.0')
  final Color? selectedRowSplashColor;

  /// The highlight color for selected rows.
  /// If null, the default framework highlight effect is used.
  /// Use Colors.transparent to disable the highlight effect for selected rows.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.selectedRowHighlightColor] instead.
  /// This property will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.selectedRowHighlightColor instead. Will be removed in v1.16.0')
  final Color? selectedRowHighlightColor;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusSelectionTheme copyWith({
    Color? selectedRowColor,
    TextStyle? selectedRowTextStyle,
    Color? checkboxColor,
    Color? checkboxHoverColor,
    Color? checkboxFocusColor,
    Color? checkboxFillColor,
    BorderSide? checkboxSide,
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
      checkboxHoverColor: checkboxHoverColor ?? this.checkboxHoverColor,
      checkboxFocusColor: checkboxFocusColor ?? this.checkboxFocusColor,
      checkboxFillColor: checkboxFillColor ?? this.checkboxFillColor,
      checkboxSide: checkboxSide ?? this.checkboxSide,
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
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.getEffectiveHoverColor] instead.
  /// This method will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.getEffectiveHoverColor instead. Will be removed in v1.16.0')
  Color? getEffectiveHoverColor(bool isSelected, Color backgroundColor) {
    if (isSelected) {
      return selectedRowHoverColor;
    } else {
      return rowHoverColor;
    }
  }

  /// Gets the effective splash color for rows based on selection state.
  /// Returns null to use the default framework effect if no color is specified.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.getEffectiveSplashColor] instead.
  /// This method will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.getEffectiveSplashColor instead. Will be removed in v1.16.0')
  Color? getEffectiveSplashColor(bool isSelected, Color backgroundColor) {
    if (isSelected) {
      return selectedRowSplashColor;
    } else {
      return rowSplashColor;
    }
  }

  /// Gets the effective highlight color for rows based on selection state.
  /// Returns null to use the default framework effect if no color is specified.
  ///
  /// **DEPRECATED**: Use [TablePlusBodyTheme.getEffectiveHighlightColor] instead.
  /// This method will be removed in v1.16.0.
  @Deprecated(
      'Use TablePlusBodyTheme.getEffectiveHighlightColor instead. Will be removed in v1.16.0')
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

  // Fallback methods for backward compatibility
  /// Gets the effective checkbox size, falling back to checkboxTheme if deprecated property is null.
  double getEffectiveCheckboxSize(TablePlusCheckboxTheme checkboxTheme) {
    return checkboxSize ?? checkboxTheme.size;
  }

  /// Gets the effective checkbox column visibility, falling back to checkboxTheme if deprecated property is null.
  bool getEffectiveShowCheckboxColumn(TablePlusCheckboxTheme checkboxTheme) {
    return showCheckboxColumn ?? checkboxTheme.showCheckboxColumn;
  }

  /// Gets the effective select-all checkbox visibility, falling back to checkboxTheme if deprecated property is null.
  bool getEffectiveShowSelectAllCheckbox(TablePlusCheckboxTheme checkboxTheme) {
    return showSelectAllCheckbox ?? checkboxTheme.showSelectAllCheckbox;
  }

  /// Gets the effective checkbox column width, falling back to checkboxTheme if deprecated property is null.
  double getEffectiveCheckboxColumnWidth(TablePlusCheckboxTheme checkboxTheme) {
    return checkboxColumnWidth ?? checkboxTheme.checkboxColumnWidth;
  }

  /// Gets the effective checkbox active color, falling back to checkboxTheme if deprecated property is null.
  Color? getEffectiveCheckboxActiveColor(TablePlusCheckboxTheme checkboxTheme) {
    if (checkboxColor != null) return checkboxColor;
    // Try to extract from fillColor WidgetStateProperty if available
    if (checkboxTheme.fillColor != null) {
      return checkboxTheme.fillColor!.resolve({WidgetState.selected});
    }
    return null;
  }

  /// Gets the effective checkbox hover color, falling back to checkboxTheme if deprecated property is null.
  Color? getEffectiveCheckboxHoverColor(TablePlusCheckboxTheme checkboxTheme) {
    return checkboxHoverColor ?? checkboxTheme.hoverColor;
  }

  /// Gets the effective checkbox focus color, falling back to checkboxTheme if deprecated property is null.
  Color? getEffectiveCheckboxFocusColor(TablePlusCheckboxTheme checkboxTheme) {
    return checkboxFocusColor ?? checkboxTheme.focusColor;
  }

  /// Gets the effective checkbox fill color, falling back to checkboxTheme if deprecated property is null.
  WidgetStateProperty<Color?>? getEffectiveCheckboxFillColor(
      TablePlusCheckboxTheme checkboxTheme) {
    if (checkboxFillColor != null) {
      return WidgetStateProperty.all(checkboxFillColor);
    }
    return checkboxTheme.fillColor;
  }

  /// Gets the effective checkbox side, falling back to checkboxTheme if deprecated property is null.
  BorderSide? getEffectiveCheckboxSide(TablePlusCheckboxTheme checkboxTheme) {
    return checkboxSide ?? checkboxTheme.side;
  }
}
