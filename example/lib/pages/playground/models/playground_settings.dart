import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// A pickable value for the body theme's ink colors (splash / hover /
/// highlight).
///
/// [themeDefault] passes `null` through, which is what makes the table fall
/// back to the framework's own ink colors — on a white row those are faint
/// enough to look like nothing is happening at all, so the loud presets exist
/// to tell "no ink" apart from "ink you cannot see".
enum InkColorOption {
  themeDefault('Theme default', null),
  none('None (transparent)', Colors.transparent),
  red('Red', Color(0x80F44336)),
  blue('Blue', Color(0x803F51B5)),
  green('Green', Color(0x804CAF50)),
  black('Black', Color(0x40000000));

  const InkColorOption(this.label, this.color);

  final String label;
  final Color? color;
}

/// Playground settings configuration
/// Where header tooltips anchor, as the settings panel offers it.
///
/// [followCells] passes `null` through, leaving `TablePlusTheme
/// .headerTooltipTheme` unset so the table falls back to `tooltipTheme`. It is
/// the default because a playground that never walks the fallback would not
/// show it working. The other two hand the header a theme of its own, which is
/// the only way to anchor a header differently from the cells beneath it.
enum HeaderTooltipAnchor { followCells, child, pointer }

class PlaygroundSettings {
  // Data settings
  final int rowCount;

  // Style settings
  final double columnMinWidth;
  final double rowHeight;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  // Feature toggles
  final bool sortingEnabled;
  final bool selectionEnabled;
  final SelectionMode selectionMode;
  final bool editingEnabled;
  final bool mergedRowsEnabled;
  final bool columnReorderEnabled;
  final bool resizableEnabled;
  final bool stretchLastColumn;
  final double resizeHandleWidth;
  final bool showAlternateRows;
  final bool showDividers;

  /// Show a rich card while hovering anywhere on a row.
  final bool rowCardTooltip;
  final InkColorOption splashColor;
  final InkColorOption hoverColor;
  final InkColorOption highlightColor;
  final bool dynamicRowHeight;
  final bool dimInactiveRows;
  final bool showCheckboxColumn;
  final double checkboxTapTargetSize;
  final bool selectAllEnabled;
  final bool dragSelectionEnabled;
  final bool cellTapTogglesCheckbox;
  final bool showRowCheckbox;
  final SortCycleOrder sortCycleOrder;
  final TooltipBehavior tooltipBehavior;
  final TooltipBehavior headerTooltipBehavior;
  final bool tooltipEnabled;
  final int tooltipWaitDurationMs;
  final bool showTooltipFormatter;
  final bool showTooltipBuilder;
  final TooltipDirection tooltipDirection;
  final TooltipAlignment tooltipAlignment;
  final bool tooltipShowArrow;
  final double tooltipOffset;

  /// Where cell tooltips are anchored.
  final TooltipAnchor tooltipAnchor;

  /// Where header tooltips are anchored.
  final HeaderTooltipAnchor headerTooltipAnchor;

  // Font settings
  final String fontFamily;

  // Header border/divider settings
  final bool headerTopBorderShow;
  final double headerTopBorderThickness;
  final bool headerBottomBorderShow;
  final double headerBottomBorderThickness;
  final bool headerVerticalDividerShow;
  final double headerVerticalDividerThickness;
  final double headerVerticalDividerIndent;
  final double headerVerticalDividerEndIndent;

  // Sort icon settings
  final double sortIconWidth;

  // Resize handle settings
  final double resizeHandleThickness;
  final double resizeHandleIndent;
  final double resizeHandleEndIndent;

  // Scale / zoom
  final double scale;
  final bool blockModifierScroll;

  const PlaygroundSettings({
    this.rowCount = 100,
    this.columnMinWidth = 50.0,
    this.rowHeight = 50.0,
    this.fontSize = 14.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 12.0,
    this.sortingEnabled = true,
    this.selectionEnabled = true,
    this.selectionMode = SelectionMode.multiple,
    this.editingEnabled = true,
    this.mergedRowsEnabled = false,
    this.columnReorderEnabled = true,
    this.resizableEnabled = true,
    this.stretchLastColumn = false,
    this.resizeHandleWidth = 8.0,
    this.showAlternateRows = true,
    this.showDividers = true,
    this.rowCardTooltip = false,
    this.splashColor = InkColorOption.themeDefault,
    this.hoverColor = InkColorOption.themeDefault,
    this.highlightColor = InkColorOption.themeDefault,
    this.dynamicRowHeight = false,
    this.dimInactiveRows = false,
    this.showCheckboxColumn = true,
    this.checkboxTapTargetSize = 18.0,
    this.selectAllEnabled = true,
    this.dragSelectionEnabled = false,
    this.cellTapTogglesCheckbox = false,
    this.showRowCheckbox = true,
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.tooltipBehavior = TooltipBehavior.always,
    this.headerTooltipBehavior = TooltipBehavior.always,
    this.tooltipEnabled = true,
    this.tooltipWaitDurationMs = 500,
    this.showTooltipFormatter = false,
    this.showTooltipBuilder = false,
    this.tooltipDirection = TooltipDirection.bottom,
    this.tooltipAlignment = TooltipAlignment.center,
    this.tooltipShowArrow = false,
    this.tooltipOffset = 8.0,
    this.tooltipAnchor = TooltipAnchor.child,
    this.headerTooltipAnchor = HeaderTooltipAnchor.followCells,
    this.fontFamily = 'default',
    this.headerTopBorderShow = true,
    this.headerTopBorderThickness = 2.0,
    this.headerBottomBorderShow = true,
    this.headerBottomBorderThickness = 1.0,
    this.headerVerticalDividerShow = true,
    this.headerVerticalDividerThickness = 1.0,
    this.headerVerticalDividerIndent = 0.0,
    this.headerVerticalDividerEndIndent = 0.0,
    this.sortIconWidth = 14.0,
    this.resizeHandleThickness = 2.0,
    this.resizeHandleIndent = 0.0,
    this.resizeHandleEndIndent = 0.0,
    this.scale = 1.0,
    this.blockModifierScroll = true,
  });

  PlaygroundSettings copyWith({
    int? rowCount,
    double? columnMinWidth,
    double? rowHeight,
    double? fontSize,
    double? horizontalPadding,
    double? verticalPadding,
    bool? sortingEnabled,
    bool? selectionEnabled,
    SelectionMode? selectionMode,
    bool? editingEnabled,
    bool? mergedRowsEnabled,
    bool? columnReorderEnabled,
    bool? resizableEnabled,
    bool? stretchLastColumn,
    double? resizeHandleWidth,
    bool? showAlternateRows,
    bool? showDividers,
    bool? rowCardTooltip,
    InkColorOption? splashColor,
    InkColorOption? hoverColor,
    InkColorOption? highlightColor,
    bool? dynamicRowHeight,
    bool? dimInactiveRows,
    bool? showCheckboxColumn,
    double? checkboxTapTargetSize,
    bool? selectAllEnabled,
    bool? dragSelectionEnabled,
    bool? cellTapTogglesCheckbox,
    bool? showRowCheckbox,
    SortCycleOrder? sortCycleOrder,
    TooltipBehavior? tooltipBehavior,
    TooltipBehavior? headerTooltipBehavior,
    bool? tooltipEnabled,
    int? tooltipWaitDurationMs,
    bool? showTooltipFormatter,
    bool? showTooltipBuilder,
    TooltipDirection? tooltipDirection,
    TooltipAlignment? tooltipAlignment,
    TooltipAnchor? tooltipAnchor,
    HeaderTooltipAnchor? headerTooltipAnchor,
    bool? tooltipShowArrow,
    double? tooltipOffset,
    String? fontFamily,
    bool? headerTopBorderShow,
    double? headerTopBorderThickness,
    bool? headerBottomBorderShow,
    double? headerBottomBorderThickness,
    bool? headerVerticalDividerShow,
    double? headerVerticalDividerThickness,
    double? headerVerticalDividerIndent,
    double? headerVerticalDividerEndIndent,
    double? sortIconWidth,
    double? resizeHandleThickness,
    double? resizeHandleIndent,
    double? resizeHandleEndIndent,
    double? scale,
    bool? blockModifierScroll,
  }) {
    return PlaygroundSettings(
      rowCount: rowCount ?? this.rowCount,
      columnMinWidth: columnMinWidth ?? this.columnMinWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      fontSize: fontSize ?? this.fontSize,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      sortingEnabled: sortingEnabled ?? this.sortingEnabled,
      selectionEnabled: selectionEnabled ?? this.selectionEnabled,
      selectionMode: selectionMode ?? this.selectionMode,
      editingEnabled: editingEnabled ?? this.editingEnabled,
      mergedRowsEnabled: mergedRowsEnabled ?? this.mergedRowsEnabled,
      columnReorderEnabled: columnReorderEnabled ?? this.columnReorderEnabled,
      resizableEnabled: resizableEnabled ?? this.resizableEnabled,
      stretchLastColumn: stretchLastColumn ?? this.stretchLastColumn,
      resizeHandleWidth: resizeHandleWidth ?? this.resizeHandleWidth,
      showAlternateRows: showAlternateRows ?? this.showAlternateRows,
      showDividers: showDividers ?? this.showDividers,
      rowCardTooltip: rowCardTooltip ?? this.rowCardTooltip,
      splashColor: splashColor ?? this.splashColor,
      hoverColor: hoverColor ?? this.hoverColor,
      highlightColor: highlightColor ?? this.highlightColor,
      dynamicRowHeight: dynamicRowHeight ?? this.dynamicRowHeight,
      dimInactiveRows: dimInactiveRows ?? this.dimInactiveRows,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      checkboxTapTargetSize:
          checkboxTapTargetSize ?? this.checkboxTapTargetSize,
      selectAllEnabled: selectAllEnabled ?? this.selectAllEnabled,
      dragSelectionEnabled: dragSelectionEnabled ?? this.dragSelectionEnabled,
      cellTapTogglesCheckbox:
          cellTapTogglesCheckbox ?? this.cellTapTogglesCheckbox,
      showRowCheckbox: showRowCheckbox ?? this.showRowCheckbox,
      sortCycleOrder: sortCycleOrder ?? this.sortCycleOrder,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      headerTooltipBehavior:
          headerTooltipBehavior ?? this.headerTooltipBehavior,
      tooltipEnabled: tooltipEnabled ?? this.tooltipEnabled,
      tooltipWaitDurationMs:
          tooltipWaitDurationMs ?? this.tooltipWaitDurationMs,
      showTooltipFormatter: showTooltipFormatter ?? this.showTooltipFormatter,
      showTooltipBuilder: showTooltipBuilder ?? this.showTooltipBuilder,
      tooltipDirection: tooltipDirection ?? this.tooltipDirection,
      tooltipAlignment: tooltipAlignment ?? this.tooltipAlignment,
      tooltipAnchor: tooltipAnchor ?? this.tooltipAnchor,
      headerTooltipAnchor: headerTooltipAnchor ?? this.headerTooltipAnchor,
      tooltipShowArrow: tooltipShowArrow ?? this.tooltipShowArrow,
      tooltipOffset: tooltipOffset ?? this.tooltipOffset,
      fontFamily: fontFamily ?? this.fontFamily,
      headerTopBorderShow: headerTopBorderShow ?? this.headerTopBorderShow,
      headerTopBorderThickness:
          headerTopBorderThickness ?? this.headerTopBorderThickness,
      headerBottomBorderShow:
          headerBottomBorderShow ?? this.headerBottomBorderShow,
      headerBottomBorderThickness:
          headerBottomBorderThickness ?? this.headerBottomBorderThickness,
      headerVerticalDividerShow:
          headerVerticalDividerShow ?? this.headerVerticalDividerShow,
      headerVerticalDividerThickness:
          headerVerticalDividerThickness ?? this.headerVerticalDividerThickness,
      headerVerticalDividerIndent:
          headerVerticalDividerIndent ?? this.headerVerticalDividerIndent,
      headerVerticalDividerEndIndent:
          headerVerticalDividerEndIndent ?? this.headerVerticalDividerEndIndent,
      sortIconWidth: sortIconWidth ?? this.sortIconWidth,
      resizeHandleThickness:
          resizeHandleThickness ?? this.resizeHandleThickness,
      resizeHandleIndent: resizeHandleIndent ?? this.resizeHandleIndent,
      resizeHandleEndIndent:
          resizeHandleEndIndent ?? this.resizeHandleEndIndent,
      scale: scale ?? this.scale,
      blockModifierScroll: blockModifierScroll ?? this.blockModifierScroll,
    );
  }
}
