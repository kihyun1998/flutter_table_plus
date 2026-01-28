# Flutter Table Plus

[![pub version](https://img.shields.io/pub/v/flutter_table_plus.svg)](https://pub.dev/packages/flutter_table_plus)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kihyun1998/flutter_table_plus/blob/main/LICENSE)
![Flutter platforms](https://img.shields.io/badge/platform-flutter%20%7C%20android%20%7C%20ios%20%7C%20linux%20%7C%20macos%20%7C%20windows%20%7C%20web-blue)

A highly customizable Flutter table widget with rich features for displaying complex data.

---

## Features

- **Synchronized Scrolling** - Header and body scroll together seamlessly
- **Sorting** - Multi-state column sorting (ascending → descending → none)
- **Selection** - Single or multiple row selection with checkboxes
- **Editing** - Inline cell editing with auto-save
- **Column Reordering** - Drag-and-drop to reorder columns
- **Column Visibility** - Show/hide columns dynamically
- **Merged Rows** - Group multiple rows with custom content
- **Expandable Rows** - Collapsible summary rows for grouped data
- **Hover Buttons** - Action buttons that appear on row hover
- **Dynamic Heights** - Support for `TextOverflow.visible` with proper height calculation
- **Smart Tooltips** - Text or widget-based tooltips with intelligent positioning
- **Dim Rows** - Style inactive rows differently based on data
- **Advanced Theming** - Deep customization of every visual aspect
- **No Dependencies** - Pure Flutter implementation

## Installation

```yaml
dependencies:
  flutter_table_plus: ^1.17.2
```

## Quick Start

```dart
import 'package:flutter_table_plus/flutter_table_plus.dart';

FlutterTablePlus(
  columns: {
    'id': TablePlusColumn(key: 'id', label: 'ID', width: 80, order: 0),
    'name': TablePlusColumn(key: 'name', label: 'Name', width: 150, order: 1),
    'email': TablePlusColumn(key: 'email', label: 'Email', width: 200, order: 2),
  },
  data: [
    {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
    {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
  ],
)
```

## Core Features

### Sorting

```dart
FlutterTablePlus(
  columns: {
    'name': TablePlusColumn(
      key: 'name',
      label: 'Name',
      sortable: true, // Enable sorting for this column
      order: 0,
    ),
  },
  sortColumnKey: _sortColumn,
  sortDirection: _sortDirection,
  onSort: (columnKey, direction) {
    // Handle sorting logic
  },
)
```

### Selection

```dart
FlutterTablePlus(
  isSelectable: true,
  selectionMode: SelectionMode.multiple, // or SelectionMode.single
  selectedRows: _selectedRows,
  onRowSelectionChanged: (rowId, isSelected) {
    // Handle selection changes
  },
)
```

### Cell Editing

```dart
FlutterTablePlus(
  isEditable: true,
  columns: {
    'name': TablePlusColumn(
      key: 'name',
      label: 'Name',
      editable: true, // Enable editing for this column
      order: 0,
    ),
  },
  onCellChanged: (rowId, columnKey, newValue) {
    // Handle cell value changes
  },
)
```

### Column Reordering

```dart
FlutterTablePlus(
  onColumnReorder: (oldIndex, newIndex) {
    // Update column order
  },
)
```

### Dynamic Row Heights

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
    columns: columnsList,
    columnWidths: columnsList.map((col) => col.width).toList(),
    defaultTextStyle: TextStyle(fontSize: 14),
    minHeight: 48.0,
  ),
)
```

### Custom Tooltips

**Text-based:**
```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  tooltipFormatter: (rowData) => 'Employee: ${rowData['name']}\nDept: ${rowData['dept']}',
)
```

**Widget-based:**
```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  tooltipBuilder: (context, rowData) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Text(rowData['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          Text(rowData['email']),
        ],
      ),
    );
  },
)
```

### Merged Rows

```dart
FlutterTablePlus(
  data: data,
  mergedGroups: [
    MergedRowGroup(
      rowKeys: ['1', '2', '3'], // Row IDs to merge
      mergeCellConfigs: {
        'category': MergeCellConfig(content: 'Electronics'),
      },
    ),
  ],
)
```

### Hover Buttons

```dart
FlutterTablePlus(
  hoverButtonBuilder: (context, rowData) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () => _editRow(rowData),
    );
  },
  hoverButtonPosition: HoverButtonPosition.right,
)
```

### Dim Rows

```dart
FlutterTablePlus(
  dimRowKey: 'isActive', // Field name in rowData
  invertDimRow: true, // Dim when isActive is false
  theme: TablePlusTheme(
    bodyTheme: TablePlusBodyTheme(
      dimRowColor: Colors.grey.withOpacity(0.3),
      dimRowTextStyle: TextStyle(color: Colors.grey),
    ),
  ),
)
```

## Theming

```dart
FlutterTablePlus(
  theme: TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      height: 56,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
      decoration: BoxDecoration(color: Colors.blue.shade100),
    ),
    bodyTheme: TablePlusBodyTheme(
      rowHeight: 48,
      alternateRowColor: Colors.grey.shade50,
      selectedRowColor: Colors.blue.withOpacity(0.2),
      hoverColor: Colors.blue.withOpacity(0.05),
    ),
    tooltip: TablePlusTooltipTheme(
      verticalOffset: 16.0,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  ),
)
```

## Documentation

Detailed guides for advanced features:

- [Sorting](documentation/SORTING.md)
- [Selection](documentation/SELECTION.md)
- [Editing](documentation/EDITING.md)
- [Theming](documentation/THEMING.md)
- [Dynamic Heights](documentation/DYNAMIC_HEIGHT.md)
- [Tooltips](documentation/TOOLTIP_CUSTOMIZATION.md)
- [Merged Rows](documentation/MERGED_ROWS.md)
- [Hover Buttons](documentation/HOVER_BUTTONS.md)
- [Expandable Rows](documentation/EXPANDABLE_ROWS.md)
- [Advanced Columns](documentation/ADVANCED_COLUMNS.md)
- [Empty State](documentation/EMPTY_STATE.md)
- [Riverpod Integration](documentation/RIVERPOD_GENERATOR_GUIDE.md)

## License

MIT License - see [LICENSE](LICENSE) file for details.
