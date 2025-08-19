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

- **Dynamic Row Heights**: Support for `TextOverflow.visible` with external height calculation via `calculateRowHeight` callback and `TableRowHeightCalculator` utility.
- **Dynamic Scrollbar Visibility**: Scrollbars are now dynamically shown or hidden based on content overflow, providing a cleaner UI when not needed.
- **Synchronized Scrolling**: Header and body scroll horizontally in perfect sync.
- **Advanced Theming**: Deeply customize headers, rows, and scrollbars. Use `decoration` for advanced header styling, fine-tune row interaction effects, and control the last row's bottom border with `lastRowBorderBehavior`.
- **Flexible Data Handling**: Use the `rowIdKey` property to specify a custom unique identifier for your rows, removing the need for a mandatory `'id'` key.
- **Column Sorting**: Supports multi-state sorting (ascending, descending, none) with a configurable sort cycle.
- **Merged Rows**: Visually group and merge multiple data rows into a single unit for specific columns, supporting custom content, selection, and editing within merged cells.
- **Expandable Summary Rows**: Add collapsible summary rows to merged groups that can display calculated totals, counts, or any custom aggregated data.
- **Row Selection & Editing**: Enable row selection and cell editing simultaneously, now fully compatible with merged rows. Supports double-tap and secondary-tap events on rows.
- **Frozen Columns**: Pin important columns to the left side with an optional visual divider between frozen and scrollable areas.
- **Column Reordering**: Easily reorder columns with drag-and-drop.
- **Column Visibility**: Dynamically show or hide individual columns.
- **Smart Text Handling**: Control text overflow (`ellipsis`, `clip`, `visible`). Tooltips for both **cells and headers** can be configured to appear always, only when text overflows, or never, giving you precise control over user feedback.
- **Custom Cell Widgets**: Render any widget inside a cell using `cellBuilder` for maximum flexibility.
- **Conditional Feature Control**: Dynamically enable/disable features like sorting and column reordering based on user permissions or application state.
- **Code Refinements**: Removed deprecated code and updated to the latest syntax for improved maintainability and performance.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_table_plus: ^1.14.2
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
    final columns = [
      TablePlusColumn(key: 'id', label: 'ID', width: 80),
      TablePlusColumn(key: 'name', label: 'Name', width: 150),
      TablePlusColumn(key: 'email', label: 'Email', width: 200),
    ];

    // 2. Prepare your data (each map must have a unique ID)
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
        rowIdKey: 'id', // Specify the key for unique row IDs
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
  columns: [TablePlusColumn(key: 'name', label: 'Name', sortable: true)],
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

### ☑️ Row Selection

Enable row selection with checkboxes. Supports both **single** and **multiple** selection modes.

```dart
FlutterTablePlus(
  isSelectable: true,
  rowIdKey: 'user_uuid', // Use your custom ID key
  selectedRows: _selectedRows,
  onRowSelectionChanged: (rowId, isSelected) {
    setState(() {
      isSelected ? _selectedRows.add(rowId) : _selectedRows.remove(rowId);
    });
  },
)
```

### 🎨 Advanced Theming

Customize every aspect of the table appearance. Leave interaction colors `null` to use the default framework effects.

```dart
FlutterTablePlus(
  theme: TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        border: Border(bottom: BorderSide(color: Colors.blue.shade300, width: 2)),
      ),
    ),
    bodyTheme: TablePlusBodyTheme(
      rowHeight: 48,
      alternateRowColor: Colors.grey.shade50,
    ),
    selectionTheme: TablePlusSelectionTheme(
      selectedRowColor: Colors.blue.withValues(alpha: 0.2),
      rowHoverColor: Colors.blue.withValues(alpha: 0.05), // Custom hover color
      rowSplashColor: null, // Use default splash effect
      selectedRowSplashColor: Colors.transparent, // Disable splash for selected rows
    ),
  ),
)
```

### 🔄 Column Reordering

Enable drag-and-drop column reordering:

```dart
FlutterTablePlus(
  onColumnReorder: (oldIndex, newIndex) {
    setState(() {
      // Reorder your columns list here
      final column = _columns.removeAt(oldIndex);
      _columns.insert(newIndex, column);
    });
  },
)
```

### 📏 Dynamic Row Heights

Support `TextOverflow.visible` with proper height calculation:

```dart
final columns = [
  TablePlusColumn(
    key: 'description',
    label: 'Description',
    width: 300,
    textOverflow: TextOverflow.visible, // Enable text wrapping
  ),
];

FlutterTablePlus(
  columns: Map.fromEntries(columns.map((col) => MapEntry(col.key, col))),
  data: data,
  // Add dynamic height calculation
  calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
    columns: columns,
    columnWidths: columns.map((col) => col.width).toList(),
    defaultTextStyle: TextStyle(fontSize: 14),
    minHeight: 48.0,
  ),
)
```


## Conditional Feature Control

You can dynamically enable or disable features based on your application's needs:

```dart
FlutterTablePlus(
  // Enable features based on user permissions
  onSort: userCanSort ? _handleSort : null,
  onColumnReorder: userCanReorderColumns ? _handleColumnReorder : null,
  isSelectable: userCanSelectRows,
  isEditable: userCanEditCells,
);
```

## Performance & Compatibility

- **Efficient Rendering**: Built on top of Flutter's high-performance rendering pipeline.
- **Large Dataset Support**: Handles tables with hundreds of rows efficiently using `ListView.builder`.
- **Platform Compatibility**: Runs on Android, iOS, Web, Windows, macOS, and Linux.
- **Dependencies**: No external package dependencies.

## Documentation

For more advanced use cases and detailed guides, please refer to our documentation:

- **State Management**
  - [Integrating with Riverpod (Code Generator)](documentation/RIVERPOD_GENERATOR_GUIDE.md)

- **Feature Guides**
  - [Dynamic Row Heights](documentation/DYNAMIC_HEIGHT.md)
  - [Handling Empty State](documentation/EMPTY_STATE.md)
  - [Cell Editing](documentation/EDITING.md)
  - [Sorting](documentation/SORTING.md)
  - [Row Selection](documentation/SELECTION.md)
  - [Theming and Styling](documentation/THEMING.md)
  - [Advanced Column Settings](documentation/ADVANCED_COLUMNS.md)
  - [Merged Rows](documentation/MERGED_ROWS.md)
