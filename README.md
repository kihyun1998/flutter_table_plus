# Flutter Table Plus

A highly customizable and efficient table widget for Flutter. It provides a rich set of features including synchronized scrolling, sorting, selection, and advanced theming, making it easy to display complex data sets.

---

## Features

- **Synchronized Scrolling**: Header and body scroll horizontally in perfect sync.
- **Advanced Theming**: Customize headers, rows, scrollbars, and selection styles with `TablePlusTheme`.
- **Column Sorting**: Supports multi-state sorting (ascending, descending, none).
- **Row Selection**: Enable single or multi-row selection with checkboxes.
- **Column Reordering**: Easily reorder columns with drag-and-drop.
- **Custom Cell Widgets**: Render any widget inside a cell using `cellBuilder` for maximum flexibility.
- **Safe Column Management**: Use `TableColumnsBuilder` to define columns and manage their order without conflicts.

## Demo

*(Here you can add a GIF or a screenshot of the table in action)*

`![Flutter Table Plus Demo](https://raw.githubusercontent.com/kihyun1998/flutter_table_plus/main/art/demo.gif)`

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_table_plus: ^1.0.0
```

Then, run `flutter pub get` in your terminal.

## Basic Usage

Here's a simple example of how to create a table.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class BasicTablePage extends StatelessWidget {
  const BasicTablePage({super.key});

  // 1. Define your columns using the builder
  final Map<String, TablePlusColumn> columns = const TableColumnsBuilder()
      .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0, width: 80))
      .addColumn('name', TablePlusColumn(key: 'name', label: 'Name', order: 0, width: 150))
      .addColumn('department', TablePlusColumn(key: 'department', label: 'Department', order: 0, width: 200))
      .build();

  // 2. Prepare your data as a List of Maps
  final List<Map<String, dynamic>> data = const [
    {'id': 1, 'name': 'John Doe', 'department': 'Engineering'},
    {'id': 2, 'name': 'Jane Smith', 'department': 'Marketing'},
    {'id': 3, 'name': 'Peter Jones', 'department': 'Sales'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Table Example')),
      body: FlutterTablePlus(
        columns: columns,
        data: data,
        theme: const TablePlusTheme(
          headerTheme: TablePlusHeaderTheme(height: 48),
          bodyTheme: TablePlusBodyTheme(rowHeight: 48),
        ),
      ),
    );
  }
}
```

## Detailed Documentation

For more advanced use cases and detailed guides, please refer to our documentation:

- **State Management**
  - [Integrating with Riverpod (Code Generator)](documentation/RIVERPOD_GENERATOR_GUIDE.md)

- **Feature Guides**
  - [Sorting](documentation/SORTING.md)
  - [Row Selection](documentation/SELECTION.md)
  - [Theming and Styling](documentation/THEMING.md)
  - [Advanced Column Settings](documentation/ADVANCED_COLUMNS.md)