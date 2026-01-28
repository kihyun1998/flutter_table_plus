import 'package:flutter/material.dart';

import 'tooltip_behavior.dart';

/// Enum representing the sorting state of a column.
enum SortDirection {
  /// No sorting applied to this column.
  none,

  /// Column is sorted in ascending order (A-Z, 1-9).
  ascending,

  /// Column is sorted in descending order (Z-A, 9-1).
  descending,
}

/// Enum representing the sorting cycle order.
enum SortCycleOrder {
  /// Ascending first: none -> ascending -> descending -> none
  ascendingFirst,

  /// Descending first: none -> descending -> ascending -> none
  descendingFirst,
}

/// Enum representing the selection mode for table rows.
enum SelectionMode {
  /// Multiple rows can be selected simultaneously.
  /// Shows checkboxes and select-all functionality.
  multiple,

  /// Only one row can be selected at a time.
  /// Previous selection is automatically cleared when a new row is selected.
  single,
}

/// Callback type for when a cell value is changed in editable mode.
///
/// [row]: The row object that was edited.
/// [columnKey]: The key of the column that was edited.
/// [rowIndex]: The index of the row that was edited.
/// [oldValue]: The previous value of the cell.
/// [newValue]: The new value of the cell.
typedef CellChangedCallback<T> = void Function(
  T row,
  String columnKey,
  int rowIndex,
  dynamic oldValue,
  dynamic newValue,
);

/// Configuration for sort icons in table headers.
class SortIcons {
  /// Creates a [SortIcons] with the specified icon widgets.
  const SortIcons({
    required this.ascending,
    required this.descending,
    this.unsorted,
  });

  /// The icon to display when column is sorted in ascending order.
  final Widget ascending;

  /// The icon to display when column is sorted in descending order.
  final Widget descending;

  /// The icon to display when column is not sorted.
  /// If null, no icon will be shown for unsorted columns.
  final Widget? unsorted;

  /// Default sort icons using Material Design icons.
  static const SortIcons defaultIcons = SortIcons(
    ascending: Icon(Icons.arrow_upward, size: 16),
    descending: Icon(Icons.arrow_downward, size: 16),
    unsorted: Icon(Icons.unfold_more, size: 16, color: Colors.grey),
  );

  /// Simple sort icons without unsorted state.
  static const SortIcons simple = SortIcons(
    ascending: Icon(Icons.arrow_upward, size: 16),
    descending: Icon(Icons.arrow_downward, size: 16),
  );
}

/// Defines a column in the table with its properties and behavior.
///
/// The type parameter [T] represents the type of row data objects.
/// Use [valueAccessor] to extract the display value from a row object.
class TablePlusColumn<T> {
  /// Creates a [TablePlusColumn] with the specified properties.
  const TablePlusColumn({
    required this.key,
    required this.label,
    required this.order,
    required this.valueAccessor,
    this.width = 100.0,
    this.minWidth = 50.0,
    this.maxWidth,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.left,
    this.sortable = false,
    this.editable = false,
    this.visible = true,
    this.cellBuilder,
    this.tooltipFormatter,
    this.tooltipBuilder,
    this.hintText,
    this.textOverflow = TextOverflow.ellipsis,
    this.tooltipBehavior = TooltipBehavior.always,
    this.headerTooltipBehavior = TooltipBehavior.always,
  });

  /// The unique identifier for this column.
  final String key;

  /// The display label for the column header.
  final String label;

  /// The order position of this column in the table.
  /// Columns are sorted by this value in ascending order.
  /// Selection column uses order: -1 to appear first.
  final int order;

  /// Function to extract the display value from a row object.
  final dynamic Function(T row) valueAccessor;

  /// The preferred width of the column in pixels.
  final double width;

  /// The minimum width of the column in pixels.
  final double minWidth;

  /// The maximum width of the column in pixels.
  /// If null, the column can grow indefinitely.
  final double? maxWidth;

  /// The alignment of content within the column cells.
  final Alignment alignment;

  /// The text alignment for text content in the column cells.
  final TextAlign textAlign;

  /// Whether this column can be sorted.
  final bool sortable;

  /// Whether this column can be edited when the table is in editable mode.
  /// When true, cells in this column will become editable text fields when clicked.
  final bool editable;

  /// Whether this column is visible in the table.
  final bool visible;

  /// Optional custom cell builder for this column.
  /// If provided, this will be used instead of the default cell rendering.
  /// The function receives the build context and row data object.
  ///
  /// Note: If [editable] is true and [cellBuilder] is provided,
  /// the cell will not be editable unless the custom builder handles editing.
  final Widget Function(BuildContext context, T rowData)? cellBuilder;

  /// Optional custom tooltip formatter for this column.
  /// If provided, this will be used to generate custom tooltip text based on row data.
  /// The function receives the row data object and should return a String for the tooltip.
  /// If null, the default behavior will use the cell's display value.
  final String Function(T rowData)? tooltipFormatter;

  /// Optional custom tooltip widget builder for rich content tooltips.
  /// Takes precedence over [tooltipFormatter] when both are provided.
  /// The function receives the build context and row data object, returning a custom Widget.
  final Widget Function(BuildContext context, T rowData)? tooltipBuilder;

  /// Optional hint text to display in the TextField when editing a cell.
  final String? hintText;

  /// How text overflow should be handled in this column's cells.
  final TextOverflow textOverflow;

  /// Controls when tooltips should be displayed for this column's cells.
  ///
  /// - [TooltipBehavior.always]: Show tooltip when textOverflow is ellipsis (default)
  /// - [TooltipBehavior.never]: Never show tooltip
  /// - [TooltipBehavior.onlyTextOverflow]: Show tooltip only when text actually overflows
  ///
  /// Note: For overflow-based tooltips, use cellBuilder to implement custom tooltip logic.
  final TooltipBehavior tooltipBehavior;

  /// Controls when tooltips should be displayed for this column's header.
  ///
  /// - [TooltipBehavior.always]: Show tooltip when textOverflow is ellipsis (default)
  /// - [TooltipBehavior.never]: Never show tooltip
  /// - [TooltipBehavior.onlyTextOverflow]: Show tooltip only when text actually overflows
  ///
  /// Note: For overflow-based tooltips, use custom header widgets with cellBuilder.
  final TooltipBehavior headerTooltipBehavior;

  /// Creates a copy of this column with the given fields replaced with new values.
  TablePlusColumn<T> copyWith({
    String? key,
    String? label,
    int? order,
    dynamic Function(T row)? valueAccessor,
    double? width,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    TextAlign? textAlign,
    bool? sortable,
    bool? editable,
    bool? visible,
    Widget Function(BuildContext context, T rowData)? cellBuilder,
    String Function(T rowData)? tooltipFormatter,
    Widget Function(BuildContext context, T rowData)? tooltipBuilder,
    String? hintText,
    TextOverflow? textOverflow,
    TooltipBehavior? tooltipBehavior,
    TooltipBehavior? headerTooltipBehavior,
  }) {
    return TablePlusColumn<T>(
      key: key ?? this.key,
      label: label ?? this.label,
      order: order ?? this.order,
      valueAccessor: valueAccessor ?? this.valueAccessor,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      alignment: alignment ?? this.alignment,
      textAlign: textAlign ?? this.textAlign,
      sortable: sortable ?? this.sortable,
      editable: editable ?? this.editable,
      visible: visible ?? this.visible,
      cellBuilder: cellBuilder ?? this.cellBuilder,
      tooltipFormatter: tooltipFormatter ?? this.tooltipFormatter,
      tooltipBuilder: tooltipBuilder ?? this.tooltipBuilder,
      hintText: hintText ?? this.hintText,
      textOverflow: textOverflow ?? this.textOverflow,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      headerTooltipBehavior:
          headerTooltipBehavior ?? this.headerTooltipBehavior,
    );
  }
}
