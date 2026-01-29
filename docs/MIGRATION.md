# Migration Guide

Migrating from Flutter Table Plus v1.x to v2.x.

---

## Overview

Version 2.0 introduces **type-safe generics** to replace the previous `Map<String, dynamic>` approach. This provides:

- ✅ Compile-time type checking
- ✅ IDE autocompletion for your data model
- ✅ No more string-based key lookups
- ✅ Cleaner, more maintainable code

---

## Breaking Changes Summary

| v1.x | v2.x |
|------|------|
| `FlutterTablePlus(...)` | `FlutterTablePlus<YourModel>(...)` |
| `data: List<Map<String, dynamic>>` | `data: List<YourModel>` |
| `rowIdKey: 'id'` | `rowId: (row) => row.id` |
| `dimRowKey: 'isActive'` | `isDimRow: (row) => !row.isActive` |
| `TablePlusColumn(key: 'name', ...)` | `TablePlusColumn(valueAccessor: (row) => row.name, ...)` |
| `onCellChanged: (rowId, columnKey, newValue)` | `onCellChanged: (row, columnKey, rowIndex, oldValue, newValue)` |

---

## Step-by-Step Migration

### 1. Create Your Data Model

**Before (v1.x):**
```dart
final data = [
  {'id': '1', 'name': 'John', 'email': 'john@example.com', 'age': 28},
  {'id': '2', 'name': 'Jane', 'email': 'jane@example.com', 'age': 34},
];
```

**After (v2.x):**
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

  User copyWith({String? name, String? email, int? age}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }
}

final data = [
  User(id: '1', name: 'John', email: 'john@example.com', age: 28),
  User(id: '2', name: 'Jane', email: 'jane@example.com', age: 34),
];
```

---

### 2. Update Column Definitions

**Before (v1.x):**
```dart
final columns = {
  'name': TablePlusColumn(
    key: 'name',
    label: 'Name',
    order: 1,
    width: 150,
    sortable: true,
  ),
  'email': TablePlusColumn(
    key: 'email',
    label: 'Email',
    order: 2,
    width: 200,
  ),
};
```

**After (v2.x):**
```dart
final columns = {
  'name': TablePlusColumn<User>(
    key: 'name',
    label: 'Name',
    order: 1,
    width: 150,
    valueAccessor: (user) => user.name,  // NEW: Extract value from model
    sortable: true,
  ),
  'email': TablePlusColumn<User>(
    key: 'email',
    label: 'Email',
    order: 2,
    width: 200,
    valueAccessor: (user) => user.email,  // NEW
  ),
};

// Or use TableColumnsBuilder
final builder = TableColumnsBuilder<User>()
  ..addColumn('name', TablePlusColumn(
    key: 'name',
    label: 'Name',
    order: 1,
    valueAccessor: (user) => user.name,
  ))
  ..addColumn('email', TablePlusColumn(
    key: 'email',
    label: 'Email',
    order: 2,
    valueAccessor: (user) => user.email,
  ));

final columns = builder.build();
```

---

### 3. Update FlutterTablePlus Widget

**Before (v1.x):**
```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  rowIdKey: 'id',  // String-based key
)
```

**After (v2.x):**
```dart
FlutterTablePlus<User>(  // Add generic type
  columns: columns,
  data: data,
  rowId: (user) => user.id,  // Function-based accessor
)
```

---

### 4. Update Dim Row Logic

**Before (v1.x):**
```dart
FlutterTablePlus(
  dimRowKey: 'isActive',
  invertDimRow: true,  // Dim when isActive is false
)
```

**After (v2.x):**
```dart
FlutterTablePlus<User>(
  isDimRow: (user) => !user.isActive,  // Direct boolean function
)
```

---

### 5. Update Cell Changed Callback

**Before (v1.x):**
```dart
onCellChanged: (String rowId, String columnKey, dynamic newValue) {
  final index = data.indexWhere((row) => row['id'] == rowId);
  if (index != -1) {
    setState(() {
      data[index][columnKey] = newValue;
    });
  }
}
```

**After (v2.x):**
```dart
onCellChanged: (User row, String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
  setState(() {
    switch (columnKey) {
      case 'name':
        data[rowIndex] = row.copyWith(name: newValue as String);
        break;
      case 'email':
        data[rowIndex] = row.copyWith(email: newValue as String);
        break;
      case 'age':
        data[rowIndex] = row.copyWith(age: int.parse(newValue.toString()));
        break;
    }
  });
}
```

---

### 6. Update CellBuilder

**Before (v1.x):**
```dart
TablePlusColumn(
  key: 'salary',
  label: 'Salary',
  cellBuilder: (context, rowData) {
    return Text('\$${rowData['salary']}');
  },
)
```

**After (v2.x):**
```dart
TablePlusColumn<User>(
  key: 'salary',
  label: 'Salary',
  valueAccessor: (user) => user.salary,
  cellBuilder: (context, user) {  // Typed parameter
    return Text('\$${user.salary}');
  },
)
```

---

### 7. Update Tooltip Functions

**Before (v1.x):**
```dart
TablePlusColumn(
  tooltipFormatter: (rowData) => 'Name: ${rowData['name']}',
  tooltipBuilder: (context, rowData) => Text(rowData['name']),
)
```

**After (v2.x):**
```dart
TablePlusColumn<User>(
  tooltipFormatter: (user) => 'Name: ${user.name}',  // Typed
  tooltipBuilder: (context, user) => Text(user.name),  // Typed
)
```

---

### 8. Update Merged Row Groups

**Before (v1.x):**
```dart
MergedRowGroup(
  groupId: 'group-1',
  rowKeys: ['1', '2', '3'],
  mergeConfig: {...},
)
```

**After (v2.x):**
```dart
MergedRowGroup<User>(  // Add generic type
  groupId: 'group-1',
  rowKeys: ['1', '2', '3'],
  mergeConfig: {...},
)
```

---

### 9. Update Hover Button Builder

**Before (v1.x):**
```dart
hoverButtonBuilder: (context, rowData) {
  return IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => editRow(rowData['id']),
  );
}
```

**After (v2.x):**
```dart
hoverButtonBuilder: (String rowId, User user) {  // New signature
  return IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => editRow(user),
  );
}
```

---

### 10. Update Calculate Row Height

**Before (v1.x):**
```dart
calculateRowHeight: (int rowIndex, Map<String, dynamic> rowData) {
  return rowData['description'].length > 100 ? 80.0 : null;
}
```

**After (v2.x):**
```dart
calculateRowHeight: (int rowIndex, User user) {
  return user.description.length > 100 ? 80.0 : null;
}
```

---

## Quick Reference: Callback Signatures

### v1.x → v2.x

```dart
// Selection
onRowSelectionChanged: (String rowId, bool isSelected)  // Same
onCheckboxChanged: (String rowId, bool isSelected)      // Same
onSelectAll: (bool selectAll)                           // Same

// Sorting
onSort: (String columnKey, SortDirection direction)     // Same

// Editing
onCellChanged: (String rowId, String columnKey, dynamic newValue)
  ↓
onCellChanged: (T row, String columnKey, int rowIndex, dynamic oldValue, dynamic newValue)

// Merged Rows
onMergedCellChanged: (String groupId, String columnKey, dynamic newValue)  // Same

// Context Menu
onRowSecondaryTapDown: (String rowId, TapDownDetails, RenderBox, bool isSelected)  // Same

// Hover Buttons
hoverButtonBuilder: (BuildContext context, Map<String, dynamic> rowData)
  ↓
hoverButtonBuilder: (String rowId, T rowData)

// Row Height
calculateRowHeight: (int rowIndex, Map<String, dynamic> rowData)
  ↓
calculateRowHeight: (int rowIndex, T rowData)
```

---

## Benefits of Migration

1. **Type Safety**: Catch errors at compile time instead of runtime
2. **Autocompletion**: IDE suggests available properties
3. **Refactoring**: Rename properties across your codebase safely
4. **Documentation**: Types serve as documentation
5. **Performance**: No string lookups at runtime

---

## Need Help?

If you encounter issues during migration, please [open an issue](https://github.com/kihyun1998/flutter_table_plus/issues) on GitHub.
