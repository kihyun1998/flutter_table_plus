# Dynamic Row Heights with TextOverflow.visible

This document explains how to support `TextOverflow.visible` with dynamic row heights in Flutter Table Plus using the `calculateRowHeight` callback.

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [TableRowHeightCalculator Utility](#tablerowheightcalculator-utility)
4. [Manual Height Calculation](#manual-height-calculation)
5. [Best Practices](#best-practices)
6. [Performance Considerations](#performance-considerations)
7. [Example Implementation](#example-implementation)

---

## Overview

Since v1.13.1, Flutter Table Plus supports external row height calculation through the `calculateRowHeight` callback. This allows you to use `TextOverflow.visible` while maintaining proper scrollbar behavior and performance.

### Why External Calculation?

The previous automatic dynamic height feature was removed in v1.13.0 due to:
- Performance issues with large datasets
- Scroll position loss during rebuilds
- Complexity in state management

The new approach gives you full control over height calculation while maintaining excellent performance.

## Quick Start

### 1. Set up columns with TextOverflow.visible

```dart
final columns = [
  TablePlusColumn(
    key: 'description',
    label: 'Description',
    width: 300,
    textOverflow: TextOverflow.visible, // Enable text wrapping
  ),
  // ... other columns
];
```

### 2. Use the helper utility

```dart
FlutterTablePlus(
  columns: Map.fromEntries(columns.map((col) => MapEntry(col.key, col))),
  data: data,
  // Add dynamic height calculation
  calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
    columns: columns,
    columnWidths: columnWidths, // Your calculated column widths
    defaultTextStyle: TextStyle(fontSize: 14),
    minHeight: 48.0,
  ),
)
```

### 3. Get column widths

```dart
// You can get these from your layout calculation or use fixed widths
List<double> columnWidths = columns.map((col) => col.width).toList();
```

## TableRowHeightCalculator Utility

The `TableRowHeightCalculator` class provides convenient methods for height calculation.

### createHeightCalculator()

Creates a ready-to-use callback function:

```dart
static double? Function(int, Map<String, dynamic>) createHeightCalculator({
  required List<TablePlusColumn> columns,
  required List<double> columnWidths,
  required TextStyle defaultTextStyle,
  double minHeight = 48.0,
})
```

### calculateRowHeight()

Calculates height for a specific row:

```dart
static double calculateRowHeight({
  required Map<String, dynamic> rowData,
  required List<TablePlusColumn> columns,
  required List<double> columnWidths,
  required TextStyle defaultTextStyle,
  double minHeight = 48.0,
})
```

### calculateTextHeight()

Calculates height for individual text content:

```dart
static double calculateTextHeight({
  required String text,
  required TextStyle textStyle,
  required double maxWidth,
  TextAlign textAlign = TextAlign.start,
  double minHeight = 48.0,
})
```

## Manual Height Calculation

For advanced use cases, you can implement your own calculation:

```dart
double? calculateMyRowHeight(int rowIndex, Map<String, dynamic> rowData) {
  // Your custom logic here
  final description = rowData['description']?.toString() ?? '';
  
  if (description.length > 100) {
    return 120.0; // Tall row for long descriptions
  } else if (description.length > 50) {
    return 80.0;  // Medium row
  }
  
  return null; // Use default height from theme
}

FlutterTablePlus(
  // ...
  calculateRowHeight: calculateMyRowHeight,
)
```

## Best Practices

### 1. Performance Optimization

```dart
// Cache calculated heights if data doesn't change often
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Map<String, double> _heightCache = {};
  
  double? _calculateRowHeight(int rowIndex, Map<String, dynamic> rowData) {
    final key = rowData['id']?.toString();
    if (key != null && _heightCache.containsKey(key)) {
      return _heightCache[key];
    }
    
    final height = TableRowHeightCalculator.calculateRowHeight(
      rowData: rowData,
      columns: columns,
      columnWidths: columnWidths,
      defaultTextStyle: textStyle,
    );
    
    if (key != null) {
      _heightCache[key] = height;
    }
    
    return height;
  }
}
```

### 2. Responsive Column Widths

```dart
class ResponsiveTableHeight extends StatefulWidget {
  @override
  State<ResponsiveTableHeight> createState() => _ResponsiveTableHeightState();
}

class _ResponsiveTableHeightState extends State<ResponsiveTableHeight> {
  List<double> columnWidths = [];
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate column widths based on available space
        final totalWidth = constraints.maxWidth - 32; // Account for padding
        columnWidths = _calculateColumnWidths(totalWidth);
        
        return FlutterTablePlus(
          // ...
          calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
            columns: columns,
            columnWidths: columnWidths,
            defaultTextStyle: textStyle,
          ),
        );
      },
    );
  }
}
```

### 3. Selective Dynamic Heights

Only apply dynamic heights to columns that need it:

```dart
final columns = [
  TablePlusColumn(
    key: 'id',
    label: 'ID',
    textOverflow: TextOverflow.ellipsis, // Fixed height
  ),
  TablePlusColumn(
    key: 'description',
    label: 'Description',
    textOverflow: TextOverflow.visible, // Dynamic height
  ),
];
```

## Performance Considerations

### ✅ Do

- Use the utility class for standard cases
- Cache height calculations when possible
- Only apply `TextOverflow.visible` to columns that need it
- Test with your actual data size

### ❌ Don't

- Perform expensive calculations in the height callback
- Use with extremely large datasets (1000+ rows) without optimization
- Recalculate heights unnecessarily
- Apply to all columns if not needed

### Performance Tips

```dart
// Good: Efficient calculation
double? calculateHeight(int rowIndex, Map<String, dynamic> rowData) {
  // Quick check for short content
  final description = rowData['description']?.toString() ?? '';
  if (description.length < 50) {
    return null; // Use default height
  }
  
  // Only calculate for longer content
  return TableRowHeightCalculator.calculateTextHeight(
    text: description,
    textStyle: textStyle,
    maxWidth: descriptionColumnWidth,
  );
}

// Better: With caching
final Map<String, double> heightCache = {};

double? calculateHeightWithCache(int rowIndex, Map<String, dynamic> rowData) {
  final id = rowData['id']?.toString();
  if (id != null && heightCache.containsKey(id)) {
    return heightCache[id];
  }
  
  final height = calculateHeight(rowIndex, rowData);
  if (id != null && height != null) {
    heightCache[id] = height;
  }
  
  return height;
}
```

## Example Implementation

Here's a complete working example:

```dart
class DynamicHeightExample extends StatefulWidget {
  @override
  State<DynamicHeightExample> createState() => _DynamicHeightExampleState();
}

class _DynamicHeightExampleState extends State<DynamicHeightExample> {
  final List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'name': 'John',
      'description': 'Short description.',
    },
    {
      'id': '2',
      'name': 'Jane',
      'description': 'This is a much longer description that will wrap to multiple lines when TextOverflow.visible is used.',
    },
  ];

  late List<TablePlusColumn> columns;
  late List<double> columnWidths;

  @override
  void initState() {
    super.initState();
    
    columns = [
      TablePlusColumn(
        key: 'id',
        label: 'ID',
        width: 80,
        textOverflow: TextOverflow.ellipsis,
      ),
      TablePlusColumn(
        key: 'name',
        label: 'Name',
        width: 120,
        textOverflow: TextOverflow.ellipsis,
      ),
      TablePlusColumn(
        key: 'description',
        label: 'Description',
        width: 300,
        textOverflow: TextOverflow.visible, // Enable wrapping
      ),
    ];

    columnWidths = columns.map((col) => col.width).toList();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14);

    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Height Example')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: FlutterTablePlus(
          columns: Map.fromEntries(
            columns.map((col) => MapEntry(col.key, col)),
          ),
          data: data,
          calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
            columns: columns,
            columnWidths: columnWidths,
            defaultTextStyle: textStyle,
            minHeight: 48.0,
          ),
          theme: TablePlusTheme(
            bodyTheme: TablePlusBodyTheme(
              rowHeight: 48, // Fallback height
              textStyle: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues

1. **Heights not calculating**: Ensure `textOverflow: TextOverflow.visible` is set on the columns you want to expand.

2. **Performance issues**: Check if you're calculating heights for all columns instead of just the ones that need it.

3. **Scrollbar incorrect**: Make sure you're passing the callback to `FlutterTablePlus.calculateRowHeight`.

4. **Heights too small**: Verify your `columnWidths` array matches your actual column widths.

### Debug Tips

```dart
// Add logging to see what's happening
double? debugCalculateHeight(int rowIndex, Map<String, dynamic> rowData) {
  final height = TableRowHeightCalculator.calculateRowHeight(
    rowData: rowData,
    columns: columns,
    columnWidths: columnWidths,
    defaultTextStyle: textStyle,
  );
  
  print('Row $rowIndex: calculated height = $height');
  return height;
}
```

---

For more examples, see the Dynamic Height Example in the example application.