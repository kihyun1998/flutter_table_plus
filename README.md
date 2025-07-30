# Flutter Table Plus

[![pub version](https://img.shields.io/pub/v/flutter_table_plus.svg)](https://pub.dev/packages/flutter_table_plus)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kihyun1998/flutter_table_plus/blob/main/LICENSE)
![Flutter platforms](https://img.shields.io/badge/platform-flutter%20%7C%20android%20%7C%20ios%20%7C%20linux%20%7C%20macos%20%7C%20windows%20%7C%20web-blue)
[![style: flutter lint](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
[![github stars](https://img.shields.io/github/stars/kihyun1998/flutter_table_plus.svg?style=social)](https://github.com/kihyun1998/flutter_table_plus)

A highly customizable and efficient table widget for Flutter. It provides a rich set of features including synchronized scrolling, sorting, selection, and advanced theming, making it easy to display complex data sets.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Features with Examples](#key-features-with-examples)
- [Conditional Feature Control](#conditional-feature-control)
- [Performance & Compatibility](#performance--compatibility)
- [Documentation](#documentation)

---

## Features

- **Synchronized Scrolling**: Header and body scroll horizontally in perfect sync.
- **Advanced Theming**: Customize headers, rows, scrollbars, and selection styles with `TablePlusTheme`.
- **Column Sorting**: Supports multi-state sorting (ascending, descending, none) with a **configurable sort cycle**. Set `onSort: null` to completely hide sort icons and disable sorting.
- **Row Selection & Editing**: Enable row selection and cell editing **simultaneously** for flexible data interaction. Also supports **double-tap** and **secondary-tap** events on rows.
- **Column Reordering**: Easily reorder columns with drag-and-drop. Set `onColumnReorder: null` to completely disable drag-and-drop functionality.
- **Custom Cell Widgets**: Render any widget inside a cell using `cellBuilder` for maximum flexibility.
- **Safe Column Management**: Use `TableColumnsBuilder` to define columns and manage their order without conflicts.
- **Conditional Feature Control**: Dynamically enable/disable features like sorting and column reordering based on user permissions or application state.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_table_plus: ^1.4.0
```

Then, run `flutter pub get` in your terminal.

## Quick Start

Get up and running with a basic table in just a few lines:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class QuickStartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Define your columns
    final columns = TableColumnsBuilder()
        .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0, width: 80))
        .addColumn('name', TablePlusColumn(key: 'name', label: 'Name', order: 0, width: 150))
        .addColumn('email', TablePlusColumn(key: 'email', label: 'Email', order: 0, width: 200))
        .build();

    // 2. Prepare your data
    final data = [
      {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
      {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com'},
      {'id': 3, 'name': 'Bob Johnson', 'email': 'bob@example.com'},
    ];

    // 3. Create the table
    return Scaffold(
      appBar: AppBar(title: Text('My Table')),
      body: FlutterTablePlus(
        columns: columns,
        data: data,
      ),
    );
  }
}
```

That's it! You now have a fully functional table with synchronized scrolling and responsive column widths.

## Key Features with Examples

### 🎯 Column Sorting

Enable sorting with just a few properties:

```dart
FlutterTablePlus(
  columns: TableColumnsBuilder()
    .addColumn('name', TablePlusColumn(
      key: 'name', 
      label: 'Name', 
      sortable: true, // Enable sorting
    ))
    .build(),
  data: data,
  sortColumnKey: _sortColumnKey,
  sortDirection: _sortDirection,
  onSort: (columnKey, direction) {
    setState(() {
      _sortColumnKey = columnKey;
      _sortDirection = direction;
      // Sort your data here
    });
  },
)
```

### ✏️ Cell Editing

Make any column editable:

```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  editable: true,
  hintText: 'Enter name',
)

// In your FlutterTablePlus:
FlutterTablePlus(
  isEditable: true,
  onCellChanged: (columnKey, rowIndex, oldValue, newValue) {
    // Handle cell changes
    print('$columnKey changed from $oldValue to $newValue');
  },
)
```

### ☑️ Row Selection

Enable row selection with checkboxes:

```dart
FlutterTablePlus(
  isSelectable: true,
  selectedRows: _selectedRows,
  onRowSelectionChanged: (rowId, isSelected) {
    setState(() {
      if (isSelected) {
        _selectedRows.add(rowId);
      } else {
        _selectedRows.remove(rowId);
      }
    });
  },
  onSelectAll: (selectAll) {
    setState(() {
      _selectedRows = selectAll ? getAllRowIds() : <String>{};
    });
  },
)
```

### 🎨 Custom Cell Widgets

Render any widget in cells using `cellBuilder`:

```dart
TablePlusColumn(
  key: 'salary',
  label: 'Salary',
  cellBuilder: (context, rowData) {
    final salary = rowData['salary'] as int;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: salary > 50000 ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '\$${salary.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
          (m) => '${m[1]},'
        )}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  },
)
```

### 🔄 Column Reordering

Enable drag-and-drop column reordering:

```dart
FlutterTablePlus(
  onColumnReorder: (oldIndex, newIndex) {
    setState(() {
      // Reorder your columns
      _reorderColumns(oldIndex, newIndex);
    });
  },
)
```

### 🎨 Advanced Theming

Customize every aspect of the table appearance:

```dart
FlutterTablePlus(
  theme: TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      height: 56,
      backgroundColor: Colors.blue.shade50,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    bodyTheme: TablePlusBodyTheme(
      rowHeight: 48,
      alternatingRowColors: [Colors.white, Colors.grey.shade50],
    ),
    selectionTheme: TablePlusSelectionTheme(
      checkboxColor: Colors.blue,
      selectedRowColor: Colors.blue.shade50,
    ),
  ),
)
```

## Conditional Feature Control

You can dynamically enable or disable features based on your application's needs:

### Disable Sorting Completely

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  onSort: null, // Hides all sort icons and disables sorting
);
```

### Disable Column Reordering

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  onColumnReorder: null, // Disables drag-and-drop column reordering
);
```

### Dynamic Feature Control

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  // Enable features based on user permissions
  onSort: userCanSort ? _handleSort : null,
  onColumnReorder: userCanReorderColumns ? _handleColumnReorder : null,
  isSelectable: userCanSelectRows,
  isEditable: userCanEditCells,
);
```

## Performance & Compatibility

### 🚀 Performance

- **Efficient Rendering**: Uses Flutter's built-in widgets with optimized rendering
- **Large Dataset Support**: Handles tables with hundreds of rows efficiently
- **Memory Management**: Automatic disposal of scroll controllers and other resources
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Synchronized Scrolling**: High-performance horizontal scrolling synchronization between header and body

### 📱 Platform Compatibility

**Supported Platforms:**
- ✅ **Android** (API 16+)
- ✅ **iOS** (iOS 9.0+)  
- ✅ **Web** (All modern browsers)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

### 🔧 Requirements

- **Flutter**: `>=3.0.0`
- **Dart**: `>=3.0.0`
- **Minimum Dependencies**: Only depends on Flutter SDK (no external packages)

### 📊 Recommended Usage

| Data Size | Performance | Recommendation |
|-----------|-------------|----------------|
| < 100 rows | Excellent | Perfect for all features |
| 100-500 rows | Very Good | All features work smoothly |
| 500-1000 rows | Good | Consider pagination for better UX |
| 1000+ rows | Fair | Implement virtual scrolling or pagination |

### 🎯 Best Practices

- **Data Management**: Keep row data lean - move complex objects to separate state management
- **Column Width**: Use `minWidth` and `maxWidth` constraints for responsive behavior
- **Memory**: Implement proper disposal in `StatefulWidget`s using table features
- **Performance**: Use `cellBuilder` sparingly for complex widgets; prefer simple text when possible

```dart
// ✅ Good - Simple and efficient
TablePlusColumn(key: 'name', label: 'Name')

// ⚠️ Use carefully - Can impact performance with many rows
TablePlusColumn(
  key: 'complex', 
  label: 'Complex',
  cellBuilder: (context, rowData) => ComplexWidget(data: rowData),
)
```

## Documentation

For more advanced use cases and detailed guides, please refer to our documentation:

- **State Management**
  - [Integrating with Riverpod (Code Generator)](documentation/RIVERPOD_GENERATOR_GUIDE.md)

- **Feature Guides**
  - [Cell Editing](documentation/EDITING.md)
  - [Sorting](documentation/SORTING.md)
  - [Row Selection](documentation/SELECTION.md)
  - [Theming and Styling](documentation/THEMING.md)
  - [Advanced Column Settings](documentation/ADVANCED_COLUMNS.md)