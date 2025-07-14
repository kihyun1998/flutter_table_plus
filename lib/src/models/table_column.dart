import 'package:flutter/material.dart';

/// Defines a column in the table with its properties and behavior.
class TablePlusColumn {
  /// Creates a [TablePlusColumn] with the specified properties.
  const TablePlusColumn({
    required this.key,
    required this.label,
    required this.order,
    this.width = 100.0,
    this.minWidth = 50.0,
    this.maxWidth,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.left,
    this.sortable = false,
    this.visible = true,
    this.cellBuilder,
  });

  /// The unique identifier for this column.
  /// This key is used to extract data from Map entries.
  final String key;

  /// The display label for the column header.
  final String label;

  /// The order position of this column in the table.
  /// Columns are sorted by this value in ascending order.
  /// Selection column uses order: -1 to appear first.
  final int order;

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

  /// Whether this column is visible in the table.
  final bool visible;

  /// Optional custom cell builder for this column.
  /// If provided, this will be used instead of the default cell rendering.
  /// The function receives the row data and should return a Widget.
  final Widget Function(BuildContext context, Map<String, dynamic> rowData)?
      cellBuilder;

  /// Creates a copy of this column with the given fields replaced with new values.
  TablePlusColumn copyWith({
    String? key,
    String? label,
    int? order,
    double? width,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    TextAlign? textAlign,
    bool? sortable,
    bool? visible,
    Widget Function(BuildContext context, Map<String, dynamic> rowData)?
        cellBuilder,
  }) {
    return TablePlusColumn(
      key: key ?? this.key,
      label: label ?? this.label,
      order: order ?? this.order,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      alignment: alignment ?? this.alignment,
      textAlign: textAlign ?? this.textAlign,
      sortable: sortable ?? this.sortable,
      visible: visible ?? this.visible,
      cellBuilder: cellBuilder ?? this.cellBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TablePlusColumn &&
        other.key == key &&
        other.label == label &&
        other.order == order &&
        other.width == width &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.alignment == alignment &&
        other.textAlign == textAlign &&
        other.sortable == sortable &&
        other.visible == visible;
  }

  @override
  int get hashCode {
    return Object.hash(
      key,
      label,
      order,
      width,
      minWidth,
      maxWidth,
      alignment,
      textAlign,
      sortable,
      visible,
    );
  }

  @override
  String toString() {
    return 'TableColumn(key: $key, label: $label, order: $order, width: $width, visible: $visible)';
  }
}
