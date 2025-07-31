import 'package:flutter/material.dart';

import 'table_column.dart';

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

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
    TablePlusSelectionTheme? selectionTheme,
    TablePlusEditableTheme? editableTheme,
    TablePlusTooltipTheme? tooltipTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      selectionTheme: selectionTheme ?? this.selectionTheme,
      editableTheme: editableTheme ?? this.editableTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
    );
  }

  /// Default table theme.
  static const TablePlusTheme defaultTheme = TablePlusTheme();
}

/// Theme configuration for the table header.
class TablePlusHeaderTheme {
  /// Creates a [TablePlusHeaderTheme] with the specified styling properties.
  const TablePlusHeaderTheme({
    this.height = 56.0,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decoration,
    this.showVerticalDividers = true,
    this.showBottomDivider = true,
    this.dividerColor = const Color(0xFFE0E0E0),
    this.dividerThickness = 1.0,
    // Sort-related styling
    this.sortedColumnBackgroundColor,
    this.sortedColumnTextStyle,
    this.sortIcons = SortIcons.defaultIcons,
    this.sortIconSpacing = 4.0,
  });

  /// The height of the header row.
  final double height;

  /// The background color of the header.
  final Color backgroundColor;

  /// The text style for header labels.
  final TextStyle textStyle;

  /// The padding inside header cells.
  final EdgeInsets padding;

  /// Optional decoration for the header.
  final Decoration? decoration;

  /// Whether to show vertical dividers between header columns.
  final bool showVerticalDividers;

  /// Whether to show bottom divider below header.
  final bool showBottomDivider;

  /// The color of header dividers.
  final Color dividerColor;

  /// The thickness of header dividers.
  final double dividerThickness;

  /// Background color for columns that are currently sorted.
  /// If null, uses [backgroundColor] for all columns.
  final Color? sortedColumnBackgroundColor;

  /// Text style for columns that are currently sorted.
  /// If null, uses [textStyle] for all columns.
  final TextStyle? sortedColumnTextStyle;

  /// Icons to display for different sort states.
  final SortIcons sortIcons;

  /// Spacing between the column label and sort icon.
  final double sortIconSpacing;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderTheme copyWith({
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Decoration? decoration,
    bool? showVerticalDividers,
    bool? showBottomDivider,
    Color? dividerColor,
    double? dividerThickness,
    Color? sortedColumnBackgroundColor,
    TextStyle? sortedColumnTextStyle,
    SortIcons? sortIcons,
    double? sortIconSpacing,
  }) {
    return TablePlusHeaderTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showBottomDivider: showBottomDivider ?? this.showBottomDivider,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      sortedColumnBackgroundColor:
          sortedColumnBackgroundColor ?? this.sortedColumnBackgroundColor,
      sortedColumnTextStyle:
          sortedColumnTextStyle ?? this.sortedColumnTextStyle,
      sortIcons: sortIcons ?? this.sortIcons,
      sortIconSpacing: sortIconSpacing ?? this.sortIconSpacing,
    );
  }
}

/// Theme configuration for the table body.
class TablePlusBodyTheme {
  /// Creates a [TablePlusBodyTheme] with the specified styling properties.
  const TablePlusBodyTheme({
    this.rowHeight = 48.0,
    this.backgroundColor = Colors.white,
    this.alternateRowColor,
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.dividerColor = const Color(0xFFE0E0E0),
    this.dividerThickness = 1.0,
    this.showVerticalDividers = true,
    this.showHorizontalDividers = true,
  });

  /// The height of each data row.
  final double rowHeight;

  /// The background color of rows.
  final Color backgroundColor;

  /// The alternate row color for striped tables.
  /// If null, all rows will use [backgroundColor].
  final Color? alternateRowColor;

  /// The text style for body cells.
  final TextStyle textStyle;

  /// The padding inside body cells.
  final EdgeInsets padding;

  /// The color of row dividers.
  final Color dividerColor;

  /// The thickness of row dividers.
  final double dividerThickness;

  /// Whether to show vertical dividers between columns.
  final bool showVerticalDividers;

  /// Whether to show horizontal dividers between rows.
  final bool showHorizontalDividers;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
    bool? showVerticalDividers,
    bool? showHorizontalDividers,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      showHorizontalDividers:
          showHorizontalDividers ?? this.showHorizontalDividers,
    );
  }
}

/// Theme configuration for scrollbars.
class TablePlusScrollbarTheme {
  /// Creates a [TablePlusScrollbarTheme] with the specified styling properties.
  const TablePlusScrollbarTheme({
    this.showVertical = true,
    this.showHorizontal = true,
    this.width = 12.0,
    this.color = const Color(0xFF757575),
    this.trackColor = const Color(0xFFE0E0E0),
    this.opacity = 1.0,
    this.hoverOnly = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Whether to show the vertical scrollbar.
  final bool showVertical;

  /// Whether to show the horizontal scrollbar.
  final bool showHorizontal;

  /// The width/thickness of the scrollbar.
  final double width;

  /// The color of the scrollbar thumb.
  final Color color;

  /// The color of the scrollbar track.
  final Color trackColor;

  /// The opacity of the scrollbar.
  final double opacity;

  /// Whether the scrollbar should only appear on hover.
  final bool hoverOnly;

  /// The animation duration for scrollbar appearance.
  final Duration animationDuration;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusScrollbarTheme copyWith({
    bool? showVertical,
    bool? showHorizontal,
    double? width,
    Color? color,
    Color? trackColor,
    double? opacity,
    bool? hoverOnly,
    Duration? animationDuration,
  }) {
    return TablePlusScrollbarTheme(
      showVertical: showVertical ?? this.showVertical,
      showHorizontal: showHorizontal ?? this.showHorizontal,
      width: width ?? this.width,
      color: color ?? this.color,
      trackColor: trackColor ?? this.trackColor,
      opacity: opacity ?? this.opacity,
      hoverOnly: hoverOnly ?? this.hoverOnly,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

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
      showSelectAllCheckbox: showSelectAllCheckbox ?? this.showSelectAllCheckbox,
      checkboxColumnWidth: checkboxColumnWidth ?? this.checkboxColumnWidth,
    );
  }
}

/// Theme configuration for cell editing.
class TablePlusEditableTheme {
  /// Creates a [TablePlusEditableTheme] with the specified styling properties.
  const TablePlusEditableTheme({
    this.editingCellColor = const Color(0xFFFFF9C4),
    this.editingTextStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
    this.hintStyle,
    this.editingBorderColor = const Color(0xFF2196F3),
    this.editingBorderWidth = 2.0,
    this.editingBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.textFieldPadding =
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.cursorColor = const Color(0xFF2196F3),
    this.textAlignVertical = TextAlignVertical.center,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.borderRadius,
    this.fillColor,
    this.filled = false,
    this.isDense = true,
  });

  /// The background color for cells that are currently being edited.
  final Color editingCellColor;

  /// The text style for text inside editing text fields.
  final TextStyle editingTextStyle;

  /// The text style for hint text in editing text fields.
  final TextStyle? hintStyle;

  /// The border color for cells that are currently being edited.
  final Color editingBorderColor;

  /// The border width for cells that are currently being edited.
  final double editingBorderWidth;

  /// The border radius for cells that are currently being edited.
  final BorderRadius editingBorderRadius;

  /// The padding inside the text field when editing.
  final EdgeInsets textFieldPadding;

  /// The cursor color in the text field.
  final Color cursorColor;

  /// The vertical alignment of text in the text field.
  final TextAlignVertical textAlignVertical;

  /// The border color when the text field is focused.
  /// If null, uses [editingBorderColor].
  final Color? focusedBorderColor;

  /// The border color when the text field is enabled but not focused.
  /// If null, uses a lighter version of [editingBorderColor].
  final Color? enabledBorderColor;

  /// The border radius for the text field decoration.
  /// If null, uses [editingBorderRadius].
  final BorderRadius? borderRadius;

  /// The fill color for the text field.
  /// If null, uses [editingCellColor].
  final Color? fillColor;

  /// Whether the text field should be filled with [fillColor].
  final bool filled;

  /// Whether the text field should use dense layout.
  final bool isDense;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusEditableTheme copyWith({
    Color? editingCellColor,
    TextStyle? editingTextStyle,
    TextStyle? hintStyle,
    Color? editingBorderColor,
    double? editingBorderWidth,
    BorderRadius? editingBorderRadius,
    EdgeInsets? textFieldPadding,
    Color? cursorColor,
    TextAlignVertical? textAlignVertical,
    Color? focusedBorderColor,
    Color? enabledBorderColor,
    BorderRadius? borderRadius,
    Color? fillColor,
    bool? filled,
    bool? isDense,
  }) {
    return TablePlusEditableTheme(
      editingCellColor: editingCellColor ?? this.editingCellColor,
      editingTextStyle: editingTextStyle ?? this.editingTextStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      editingBorderColor: editingBorderColor ?? this.editingBorderColor,
      editingBorderWidth: editingBorderWidth ?? this.editingBorderWidth,
      editingBorderRadius: editingBorderRadius ?? this.editingBorderRadius,
      textFieldPadding: textFieldPadding ?? this.textFieldPadding,
      cursorColor: cursorColor ?? this.cursorColor,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fillColor: fillColor ?? this.fillColor,
      filled: filled ?? this.filled,
      isDense: isDense ?? this.isDense,
    );
  }
}

/// Theme configuration for cell tooltips.
class TablePlusTooltipTheme {
  /// Creates a [TablePlusTooltipTheme] with the specified styling properties.
  const TablePlusTooltipTheme({
    this.enabled = true,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white,
    ),
    this.decoration = const BoxDecoration(
      color: Color(0xFF424242),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.margin = const EdgeInsets.all(0.0),
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 2),
    this.preferBelow = true,
  });

  /// Whether tooltips are enabled globally.
  /// If false, no tooltips will be shown regardless of column settings.
  final bool enabled;

  /// The text style for tooltip content.
  final TextStyle textStyle;

  /// The decoration for the tooltip background.
  final Decoration decoration;

  /// The padding inside the tooltip.
  final EdgeInsets padding;

  /// The margin around the tooltip.
  final EdgeInsets margin;

  /// The duration to wait before showing the tooltip after hover.
  final Duration waitDuration;

  /// The duration to show the tooltip.
  final Duration showDuration;

  /// Whether to prefer showing the tooltip below the widget.
  final bool preferBelow;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTooltipTheme copyWith({
    bool? enabled,
    TextStyle? textStyle,
    Decoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Duration? waitDuration,
    Duration? showDuration,
    bool? preferBelow,
  }) {
    return TablePlusTooltipTheme(
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      preferBelow: preferBelow ?? this.preferBelow,
    );
  }
}
