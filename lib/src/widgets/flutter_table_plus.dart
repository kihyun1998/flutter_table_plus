import 'dart:math';

import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';
import 'synced_scroll_controllers.dart';
import 'table_body.dart';
import 'table_header.dart';

/// A highly customizable and efficient table widget for Flutter.
///
/// This widget provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
class FlutterTablePlus extends StatefulWidget {
  /// Creates a [FlutterTablePlus] with the specified configuration.
  const FlutterTablePlus({
    super.key,
    required this.columns,
    required this.data,
    this.theme,
  });

  /// The list of columns to display in the table.
  final List<TablePlusColumn> columns;

  /// The data to display in the table.
  /// Each map represents a row, with keys corresponding to column keys.
  final List<Map<String, dynamic>> data;

  /// The theme configuration for the table.
  /// If not provided, [TablePlusTheme.defaultTheme] will be used.
  final TablePlusTheme? theme;

  @override
  State<FlutterTablePlus> createState() => _FlutterTablePlusState();
}

class _FlutterTablePlusState extends State<FlutterTablePlus> {
  bool _isHovered = false;

  /// Get the current theme, using default if not provided.
  TablePlusTheme get _currentTheme =>
      widget.theme ?? TablePlusTheme.defaultTheme;

  /// Get only visible columns.
  List<TablePlusColumn> get _visibleColumns =>
      widget.columns.where((col) => col.visible).toList();

  /// Calculate the total height of all data rows.
  double _calculateTotalDataHeight() {
    return widget.data.length * _currentTheme.bodyTheme.rowHeight;
  }

  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths(double totalWidth) {
    final visibleColumns = _visibleColumns;
    if (visibleColumns.isEmpty) return [];

    // Calculate total preferred width
    final double totalPreferredWidth = visibleColumns.fold(
      0.0,
      (sum, col) => sum + col.width,
    );

    // Calculate total minimum width
    final double totalMinWidth = visibleColumns.fold(
      0.0,
      (sum, col) => sum + col.minWidth,
    );

    List<double> widths = [];

    if (totalPreferredWidth <= totalWidth) {
      // If preferred widths fit, distribute extra space proportionally
      final double extraSpace = totalWidth - totalPreferredWidth;
      final double totalWeight = visibleColumns.length.toDouble();

      for (int i = 0; i < visibleColumns.length; i++) {
        final column = visibleColumns[i];
        final double extraWidth = extraSpace / totalWeight;
        double finalWidth = column.width + extraWidth;

        // Respect maximum width if specified
        if (column.maxWidth != null && finalWidth > column.maxWidth!) {
          finalWidth = column.maxWidth!;
        }

        widths.add(finalWidth);
      }
    } else if (totalMinWidth <= totalWidth) {
      // Scale down proportionally but respect minimum widths
      final double scale = totalWidth / totalPreferredWidth;

      for (int i = 0; i < visibleColumns.length; i++) {
        final column = visibleColumns[i];
        final double scaledWidth = column.width * scale;
        final double finalWidth = scaledWidth.clamp(
            column.minWidth, column.maxWidth ?? double.infinity);
        widths.add(finalWidth);
      }
    } else {
      // Use minimum widths (table will be wider than available space)
      widths = visibleColumns.map((col) => col.minWidth).toList();
    }

    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final visibleColumns = _visibleColumns;
    final theme = _currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Calculate minimum table width
        final double minTableWidth = visibleColumns.fold(
          0.0,
          (sum, col) => sum + col.minWidth,
        );

        // Calculate preferred table width
        final double preferredTableWidth = visibleColumns.fold(
          0.0,
          (sum, col) => sum + col.width,
        );

        // Actual content width: use preferred width, but ensure it's not smaller than minimum
        final double contentWidth = max(
          max(minTableWidth, preferredTableWidth),
          availableWidth,
        );

        // Calculate column widths for the actual content width
        final List<double> columnWidths = _calculateColumnWidths(contentWidth);

        // Calculate table data height
        final double tableDataHeight = _calculateTotalDataHeight();

        // Total content height for scrollbar calculation
        final double totalContentHeight =
            theme.headerTheme.height + tableDataHeight;

        return SyncedScrollControllers(
          builder: (
            context,
            verticalScrollController,
            verticalScrollbarController,
            horizontalScrollController,
            horizontalScrollbarController,
          ) {
            // Determine if scrolling is needed
            final bool needsVerticalScroll =
                totalContentHeight > availableHeight;
            final bool needsHorizontalScroll = contentWidth > availableWidth;

            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: ScrollConfiguration(
                // Hide default Flutter scrollbars
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: Stack(
                  children: [
                    // Main table area (header + data integrated)
                    SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          children: [
                            // Table Header
                            TablePlusHeader(
                              columns: visibleColumns,
                              totalWidth: contentWidth,
                              theme: theme.headerTheme,
                            ),

                            // Table Data
                            Expanded(
                              child: TablePlusBody(
                                columns: visibleColumns,
                                data: widget.data,
                                columnWidths: columnWidths,
                                theme: theme.bodyTheme,
                                verticalController: verticalScrollController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Scrollbar (right overlay) - starts below header
                    if (theme.scrollbarTheme.showVertical &&
                        needsVerticalScroll)
                      Positioned(
                        top: theme.headerTheme.height,
                        right: 0,
                        bottom: (theme.scrollbarTheme.showHorizontal &&
                                needsHorizontalScroll)
                            ? theme.scrollbarTheme.width
                            : 0,
                        child: AnimatedOpacity(
                          opacity: theme.scrollbarTheme.hoverOnly
                              ? (_isHovered
                                  ? theme.scrollbarTheme.opacity
                                  : 0.0)
                              : theme.scrollbarTheme.opacity,
                          duration: theme.scrollbarTheme.animationDuration,
                          child: Container(
                            width: theme.scrollbarTheme.width,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.width / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.color,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.width / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.width - 4,
                                  ),
                                ),
                              ),
                              child: Scrollbar(
                                controller: verticalScrollbarController,
                                thumbVisibility: true,
                                trackVisibility: false,
                                child: SingleChildScrollView(
                                  controller: verticalScrollbarController,
                                  scrollDirection: Axis.vertical,
                                  child: SizedBox(
                                    height: tableDataHeight,
                                    width: theme.scrollbarTheme.width,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Horizontal Scrollbar (bottom overlay) - full width
                    if (theme.scrollbarTheme.showHorizontal &&
                        needsHorizontalScroll)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: theme.scrollbarTheme.hoverOnly
                              ? (_isHovered
                                  ? theme.scrollbarTheme.opacity
                                  : 0.0)
                              : theme.scrollbarTheme.opacity,
                          duration: theme.scrollbarTheme.animationDuration,
                          child: Container(
                            height: theme.scrollbarTheme.width,
                            decoration: BoxDecoration(
                              color: theme.scrollbarTheme.trackColor,
                              borderRadius: BorderRadius.circular(
                                theme.scrollbarTheme.width / 2,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    theme.scrollbarTheme.color,
                                  ),
                                  trackColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  radius: Radius.circular(
                                      theme.scrollbarTheme.width / 2),
                                  thickness: WidgetStateProperty.all(
                                    theme.scrollbarTheme.width - 4,
                                  ),
                                ),
                              ),
                              child: Scrollbar(
                                controller: horizontalScrollbarController,
                                thumbVisibility: true,
                                trackVisibility: false,
                                child: SingleChildScrollView(
                                  controller: horizontalScrollbarController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: contentWidth,
                                    height: theme.scrollbarTheme.width,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
