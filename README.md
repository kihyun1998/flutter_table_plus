# Flutter Table Plus

[![pub version](https://img.shields.io/pub/v/flutter_table_plus.svg)](https://pub.dev/packages/flutter_table_plus)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kihyun1998/flutter_table_plus/blob/main/LICENSE)
![Flutter platforms](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20linux%20%7C%20macos%20%7C%20windows%20%7C%20web-blue)

A highly customizable, type-safe Flutter table widget with synchronized scrolling, sorting, selection, editing, and more.

<p align="center">
  <img src="https://raw.githubusercontent.com/kihyun1998/flutter_table_plus/main/screenshots/demo.gif" alt="Flutter Table Plus Demo" width="800"/>
</p>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Type-Safe Generics** | Works with any data model `<T>` — no more `Map<String, dynamic>` |
| **Synchronized Scrolling** | Header and body scroll together seamlessly |
| **Sorting** | Multi-state column sorting (ascending ↔ descending ↔ none) |
| **Selection** | Single or multiple row selection with checkboxes |
| **Inline Editing** | Click-to-edit cells with auto-save |
| **Column Reordering** | Drag-and-drop columns |
| **Column Resizing** | Drag header edges to resize columns with min/max constraints |
| **Drag Selection** | Mouse drag to select row ranges with auto-scroll |
| **Merged Rows** | Group rows with custom merged content |
| **Hover Buttons** | Action buttons on row hover |
| **Dynamic Row Heights** | Support for variable height rows |
| **Smart Tooltips** | Text or widget-based tooltips |
| **Dim Rows** | Style inactive rows differently |
| **Deep Theming** | 8 nested theme classes for complete customization |
| **Zero Dependencies** | Pure Flutter implementation |

---

## 📦 Installation

```yaml
dependencies:
  flutter_table_plus: ^2.3.3
```

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Define Your Data Model

```dart
class User {
  final String id;
  final String name;
  final String email;
  final int age;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });
}
```

### 2. Create the Table

```dart
import 'package:flutter_table_plus/flutter_table_plus.dart';

final columns = TableColumnsBuilder<User>()
  ..addColumn('name', TablePlusColumn(
    key: 'name',
    label: 'Name',
    order: 1,
    width: 150,
    valueAccessor: (user) => user.name,
    sortable: true,
  ))
  ..addColumn('email', TablePlusColumn(
    key: 'email',
    label: 'Email',
    order: 2,
    width: 200,
    valueAccessor: (user) => user.email,
  ))
  ..addColumn('age', TablePlusColumn(
    key: 'age',
    label: 'Age',
    order: 3,
    width: 80,
    valueAccessor: (user) => user.age,
    sortable: true,
  ));

final users = [
  User(id: '1', name: 'John Doe', email: 'john@example.com', age: 28),
  User(id: '2', name: 'Jane Smith', email: 'jane@example.com', age: 34),
];

FlutterTablePlus<User>(
  columns: columns.build(),
  data: users,
  rowId: (user) => user.id,  // Unique identifier for each row

  // Sorting
  sortColumnKey: _sortColumn,
  sortDirection: _sortDirection,
  onSort: (columnKey, direction) {
    setState(() {
      _sortColumn = columnKey;
      _sortDirection = direction;
      // Sort your data here
    });
  },

  // Selection
  isSelectable: true,
  selectionMode: SelectionMode.multiple,
  selectedRows: _selectedRows,
  onRowSelectionChanged: (rowId, isSelected) {
    setState(() {
      isSelected ? _selectedRows.add(rowId) : _selectedRows.remove(rowId);
    });
  },
)
```

---

## 💡 Core Philosophy

Flutter Table Plus follows a **UI-only, data-agnostic** design:

- ✅ **You own your data** — The package never stores or mutates your data
- ✅ **Callback-driven** — All interactions flow through callbacks you control
- ✅ **State management agnostic** — Works with `setState`, Provider, Riverpod, Bloc, etc.
- ✅ **Maximum flexibility** — No assumptions about your data structure or business logic

```dart
// You handle sorting
onSort: (columnKey, direction) {
  // Sort your data however you want
  _myData.sort(...);
}

// You handle selection
onRowSelectionChanged: (rowId, isSelected) {
  // Update your selection state
  _selectedIds.add(rowId);
}

// You handle editing
onCellChanged: (row, columnKey, rowIndex, oldValue, newValue) {
  // Update your data model
  _myData[rowIndex] = row.copyWith(name: newValue);
}
```

---

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [Features Guide](docs/FEATURES.md) | Sorting, Selection, Editing, Merged Rows, Hover Buttons, and more |
| [Theming Guide](docs/THEMING.md) | Complete theming reference with all 8 theme classes |
| [Migration Guide](docs/MIGRATION.md) | Migrating from v1.x (`Map`) to v2.x (`Generic<T>`) |

---

## 🔗 Links

- [API Reference (pub.dev)](https://pub.dev/documentation/flutter_table_plus/latest/)
- [GitHub Repository](https://github.com/kihyun1998/flutter_table_plus)
- [Example App](https://github.com/kihyun1998/flutter_table_plus/tree/main/example)
- [Changelog](https://github.com/kihyun1998/flutter_table_plus/blob/main/CHANGELOG.md)

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
