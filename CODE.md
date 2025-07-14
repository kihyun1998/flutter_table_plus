# flutter_table_plus
## Project Structure

```
flutter_table_plus/
├── example/
    ├── lib/
    │   └── main.dart
    └── pubspec.yaml
├── lib/
    ├── src/
    │   ├── models/
    │   │   ├── table_column.dart
    │   │   └── table_theme.dart
    │   └── widgets/
    │   │   ├── flutter_table_plus.dart
    │   │   ├── synced_scroll_controllers.dart
    │   │   ├── table_body.dart
    │   │   └── table_header.dart
    └── flutter_table_plus.dart
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml
```

## CHANGELOG.md
```md
## 0.0.1

* TODO: Describe initial release.

```
## LICENSE
```
TODO: Add your license here.

```
## example/lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Table Plus Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TableExamplePage(),
    );
  }
}

class TableExamplePage extends StatefulWidget {
  const TableExamplePage({super.key});

  @override
  State<TableExamplePage> createState() => _TableExamplePageState();
}

class _TableExamplePageState extends State<TableExamplePage> {
  // Sample data for the table
  final List<Map<String, dynamic>> _sampleData = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'age': 28,
      'department': 'Engineering',
      'salary': 75000,
      'active': true,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'age': 32,
      'department': 'Marketing',
      'salary': 68000,
      'active': true,
    },
    {
      'id': 3,
      'name': 'Bob Johnson',
      'email': 'bob.johnson@example.com',
      'age': 45,
      'department': 'Sales',
      'salary': 82000,
      'active': false,
    },
    {
      'id': 4,
      'name': 'Alice Brown',
      'email': 'alice.brown@example.com',
      'age': 29,
      'department': 'Engineering',
      'salary': 79000,
      'active': true,
    },
    {
      'id': 5,
      'name': 'Charlie Wilson',
      'email': 'charlie.wilson@example.com',
      'age': 38,
      'department': 'HR',
      'salary': 65000,
      'active': true,
    },
    {
      'id': 6,
      'name': 'Diana Davis',
      'email': 'diana.davis@example.com',
      'age': 31,
      'department': 'Finance',
      'salary': 72000,
      'active': true,
    },
    {
      'id': 7,
      'name': 'Eva Garcia',
      'email': 'eva.garcia@example.com',
      'age': 26,
      'department': 'Design',
      'salary': 63000,
      'active': false,
    },
    {
      'id': 8,
      'name': 'Frank Miller',
      'email': 'frank.miller@example.com',
      'age': 42,
      'department': 'Operations',
      'salary': 71000,
      'active': true,
    },
  ];

  // Define table columns
  final List<TablePlusColumn> _columns = [
    const TablePlusColumn(
      key: 'id',
      label: 'ID',
      width: 60,
      minWidth: 50,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
    ),
    const TablePlusColumn(
      key: 'name',
      label: 'Full Name',
      width: 150,
      minWidth: 120,
    ),
    const TablePlusColumn(
      key: 'email',
      label: 'Email Address',
      width: 200,
      minWidth: 150,
    ),
    const TablePlusColumn(
      key: 'age',
      label: 'Age',
      width: 60,
      minWidth: 50,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
    ),
    const TablePlusColumn(
      key: 'department',
      label: 'Department',
      width: 120,
      minWidth: 100,
    ),
    TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      width: 100,
      minWidth: 80,
      textAlign: TextAlign.right,
      alignment: Alignment.centerRight,
      cellBuilder: (context, rowData) {
        final salary = rowData['salary'] as int?;
        return Text(
          salary != null
              ? '\$${salary.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}'
              : '',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        );
      },
    ),
    TablePlusColumn(
      key: 'active',
      label: 'Status',
      width: 80,
      minWidth: 70,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
      cellBuilder: (context, rowData) {
        final isActive = rowData['active'] as bool? ?? false;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Table Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Directory',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${_sampleData.length} employees',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FlutterTablePlus(
                    columns: _columns,
                    data: _sampleData,
                    theme: const TablePlusTheme(
                      headerTheme: TablePlusHeaderTheme(
                        height: 48,
                        backgroundColor: Color(0xFFF8F9FA),
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF495057),
                        ),
                      ),
                      bodyTheme: TablePlusBodyTheme(
                        rowHeight: 56,
                        alternateRowColor: Color(0xFFFAFAFA),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF212529),
                        ),
                      ),
                      scrollbarTheme: TablePlusScrollbarTheme(
                        hoverOnly: true,
                        opacity: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features demonstrated:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('• Column width management'),
            const Text('• Custom cell builders (Salary, Status)'),
            const Text('• Alternating row colors'),
            const Text('• Synchronized scrolling'),
            const Text('• Responsive layout'),
          ],
        ),
      ),
    );
  }
}

```
## example/pubspec.yaml
```yaml
name: example
description: "A new Flutter project."
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: ^3.6.1


dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_table_plus:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```
## lib/flutter_table_plus.dart
```dart
/// A highly customizable and efficient table widget for Flutter.
///
/// This library provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
library;

// Models
export 'src/models/table_column.dart';
export 'src/models/table_theme.dart';
// Main widget
export 'src/widgets/flutter_table_plus.dart';

```
## lib/src/models/table_column.dart
```dart
import 'package:flutter/material.dart';

/// Defines a column in the table with its properties and behavior.
class TablePlusColumn {
  /// Creates a [TablePlusColumn] with the specified properties.
  const TablePlusColumn({
    required this.key,
    required this.label,
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
    return 'TableColumn(key: $key, label: $label, width: $width, visible: $visible)';
  }
}

```
## lib/src/models/table_theme.dart
```dart
import 'package:flutter/material.dart';

/// Theme configuration for the table components.
class TablePlusTheme {
  /// Creates a [TablePlusTheme] with the specified styling properties.
  const TablePlusTheme({
    this.headerTheme = const TablePlusHeaderTheme(),
    this.bodyTheme = const TablePlusBodyTheme(),
    this.scrollbarTheme = const TablePlusScrollbarTheme(),
  });

  /// Theme configuration for the table header.
  final TablePlusHeaderTheme headerTheme;

  /// Theme configuration for the table body.
  final TablePlusBodyTheme bodyTheme;

  /// Theme configuration for the scrollbars.
  final TablePlusScrollbarTheme scrollbarTheme;

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusTheme copyWith({
    TablePlusHeaderTheme? headerTheme,
    TablePlusBodyTheme? bodyTheme,
    TablePlusScrollbarTheme? scrollbarTheme,
  }) {
    return TablePlusTheme(
      headerTheme: headerTheme ?? this.headerTheme,
      bodyTheme: bodyTheme ?? this.bodyTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
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

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusHeaderTheme copyWith({
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Decoration? decoration,
  }) {
    return TablePlusHeaderTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
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

  /// Creates a copy of this theme with the given fields replaced with new values.
  TablePlusBodyTheme copyWith({
    double? rowHeight,
    Color? backgroundColor,
    Color? alternateRowColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    Color? dividerColor,
    double? dividerThickness,
  }) {
    return TablePlusBodyTheme(
      rowHeight: rowHeight ?? this.rowHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      alternateRowColor: alternateRowColor ?? this.alternateRowColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
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

```
## lib/src/widgets/flutter_table_plus.dart
```dart
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

```
## lib/src/widgets/synced_scroll_controllers.dart
```dart
import 'package:flutter/material.dart';

/// A widget that synchronizes multiple [ScrollController]s.
///
/// This is particularly useful for scenarios where different scrollable widgets
/// (e.g., a main content area and its corresponding scrollbar) need to scroll
/// in unison. It manages both vertical and horizontal scroll synchronization.
class SyncedScrollControllers extends StatefulWidget {
  /// Creates a [SyncedScrollControllers] instance.
  ///
  /// The [builder] function is required and provides the synchronized scroll
  /// controllers to its child widgets.
  ///
  /// [scrollController]: An optional external [ScrollController] for the main vertical scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [verticalScrollbarController]: An optional external [ScrollController] for the vertical scrollbar.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollController]: An optional external [ScrollController] for the main horizontal scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollbarController]: An optional external [ScrollController] for the horizontal scrollbar.
  ///   If not provided, an internal controller will be created.
  ///
  /// The `builder` function provides the following controllers:
  /// - `verticalDataController`: The primary controller for vertical scrolling of data.
  /// - `verticalScrollbarController`: The controller for the vertical scrollbar.
  /// - `horizontalMainController`: The primary controller for horizontal scrolling (shared by header and data).
  /// - `horizontalScrollbarController`: The controller for the horizontal scrollbar.
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollbarController,
    this.horizontalScrollController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  /// A builder function that provides the synchronized [ScrollController]s.
  ///
  /// [context]: The build context.
  /// [verticalDataController]: The primary controller for vertical scrolling of data.
  /// [verticalScrollbarController]: The controller for the vertical scrollbar.
  /// [horizontalMainController]: The primary controller for horizontal scrolling (shared by header and data).
  /// [horizontalScrollbarController]: The controller for the horizontal scrollbar.
  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController,
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // 메인 수직 (ListView 용)
  late ScrollController _sc12; // 수직 스크롤바
  ScrollController? _sc21; // 메인 수평 (헤더 & 데이터 공통)
  late ScrollController _sc22; // 수평 스크롤바

  // 각 컨트롤러에 대한 리스너들을 명확하게 관리하기 위한 Map
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인, ListView 용)
    _sc11 = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (메인, 헤더와 데이터 영역의 가로 스크롤 공통)
    _sc21 = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _sc12 = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc11!.hasClients && _sc11!.positions.isNotEmpty
              ? _sc11!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _sc22 = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _sc11?.dispose();
    if (widget.horizontalScrollController == null) _sc21?.dispose();
    if (widget.verticalScrollbarController == null) _sc12.dispose();
    if (widget.horizontalScrollbarController == null) _sc22.dispose();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    // 마스터 컨트롤러에 리스너 추가
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _sc11!,
        _sc12,
        _sc21!,
        _sc22,
      );
}

```
## lib/src/widgets/table_body.dart
```dart
import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

/// A widget that renders the data rows of the table.
class TablePlusBody extends StatelessWidget {
  /// Creates a [TablePlusBody] with the specified configuration.
  const TablePlusBody({
    super.key,
    required this.columns,
    required this.data,
    required this.columnWidths,
    required this.theme,
    required this.verticalController,
  });

  /// The list of columns for the table.
  final List<TablePlusColumn> columns;

  /// The data to display in the table rows.
  final List<Map<String, dynamic>> data;

  /// The calculated width for each column.
  final List<double> columnWidths;

  /// The theme configuration for the table body.
  final TablePlusBodyTheme theme;

  /// The scroll controller for vertical scrolling.
  final ScrollController verticalController;

  /// Get the background color for a row at the given index.
  Color _getRowColor(int index) {
    if (theme.alternateRowColor != null && index.isOdd) {
      return theme.alternateRowColor!;
    }
    return theme.backgroundColor;
  }

  /// Extract the display value for a cell.
  String _getCellDisplayValue(
      Map<String, dynamic> rowData, TablePlusColumn column) {
    final value = rowData[column.key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: theme.rowHeight * 3, // Show some height even when empty
        decoration: BoxDecoration(
          color: theme.backgroundColor,
        ),
        child: Center(
          child: Text(
            'No data available',
            style: theme.textStyle.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: verticalController,
      physics: const ClampingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final rowData = data[index];

        return _TablePlusRow(
          rowData: rowData,
          columns: columns,
          columnWidths: columnWidths,
          theme: theme,
          backgroundColor: _getRowColor(index),
          isLastRow: index == data.length - 1,
        );
      },
    );
  }
}

/// A single table row widget.
class _TablePlusRow extends StatelessWidget {
  const _TablePlusRow({
    required this.rowData,
    required this.columns,
    required this.columnWidths,
    required this.theme,
    required this.backgroundColor,
    required this.isLastRow,
  });

  final Map<String, dynamic> rowData;
  final List<TablePlusColumn> columns;
  final List<double> columnWidths;
  final TablePlusBodyTheme theme;
  final Color backgroundColor;
  final bool isLastRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.rowHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: !isLastRow
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: theme.dividerThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width =
              columnWidths.isNotEmpty ? columnWidths[index] : column.width;

          return _TablePlusCell(
            column: column,
            rowData: rowData,
            width: width,
            theme: theme,
          );
        }),
      ),
    );
  }
}

/// A single table cell widget.
class _TablePlusCell extends StatelessWidget {
  const _TablePlusCell({
    required this.column,
    required this.rowData,
    required this.width,
    required this.theme,
  });

  final TablePlusColumn column;
  final Map<String, dynamic> rowData;
  final double width;
  final TablePlusBodyTheme theme;

  /// Extract the display value for this cell.
  String _getCellDisplayValue() {
    final value = rowData[column.key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Use custom cell builder if provided
    if (column.cellBuilder != null) {
      return Container(
        width: width,
        height: theme.rowHeight,
        padding: theme.padding,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Align(
          alignment: column.alignment,
          child: column.cellBuilder!(context, rowData),
        ),
      );
    }

    // Default text cell
    final displayValue = _getCellDisplayValue();

    return Container(
      width: width,
      height: theme.rowHeight,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Align(
        alignment: column.alignment,
        child: Text(
          displayValue,
          style: theme.textStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: column.textAlign,
        ),
      ),
    );
  }
}

```
## lib/src/widgets/table_header.dart
```dart
import 'package:flutter/material.dart';

import '../models/table_column.dart';
import '../models/table_theme.dart';

/// A widget that renders the header row of the table.
class TablePlusHeader extends StatelessWidget {
  /// Creates a [TablePlusHeader] with the specified configuration.
  const TablePlusHeader({
    super.key,
    required this.columns,
    required this.totalWidth,
    required this.theme,
  });

  /// The list of columns to display in the header.
  final List<TablePlusColumn> columns;

  /// The total width available for the table.
  final double totalWidth;

  /// The theme configuration for the header.
  final TablePlusHeaderTheme theme;

  /// Calculate the actual width for each column based on available space.
  List<double> _calculateColumnWidths() {
    if (columns.isEmpty) return [];

    // Calculate total preferred width
    final double totalPreferredWidth = columns.fold(
      0.0,
      (sum, col) => sum + col.width,
    );

    // Calculate total minimum width
    final double totalMinWidth = columns.fold(
      0.0,
      (sum, col) => sum + col.minWidth,
    );

    List<double> widths = [];

    if (totalPreferredWidth <= totalWidth) {
      // If preferred widths fit, distribute extra space proportionally
      final double extraSpace = totalWidth - totalPreferredWidth;
      final double totalWeight = columns.length.toDouble();

      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
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

      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
        final double scaledWidth = column.width * scale;
        final double finalWidth = scaledWidth.clamp(
            column.minWidth, column.maxWidth ?? double.infinity);
        widths.add(finalWidth);
      }
    } else {
      // Use minimum widths (table will be wider than available space)
      widths = columns.map((col) => col.minWidth).toList();
    }

    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = _calculateColumnWidths();

    return Container(
      height: theme.height,
      width: totalWidth,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: theme.decoration != null
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width =
              columnWidths.isNotEmpty ? columnWidths[index] : column.width;

          return _HeaderCell(
            column: column,
            width: width,
            theme: theme,
          );
        }),
      ),
    );
  }
}

/// A single header cell widget.
class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.width,
    required this.theme,
  });

  final TablePlusColumn column;
  final double width;
  final TablePlusHeaderTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: theme.height,
      padding: theme.padding,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Align(
        alignment: column.alignment,
        child: Text(
          column.label,
          style: theme.textStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: column.textAlign,
        ),
      ),
    );
  }
}

```
## pubspec.yaml
```yaml
name: flutter_table_plus
description: "A new Flutter package project."
version: 0.0.1
homepage:

environment:
  sdk: ^3.6.1
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # To add assets to your package, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg
  #
  # For details regarding assets in packages, see
  # https://flutter.dev/to/asset-from-package
  #
  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # To add custom fonts to your package, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts in packages, see
  # https://flutter.dev/to/font-from-package

```
