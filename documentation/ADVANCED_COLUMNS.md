# Feature Guide: Advanced Column Settings

Beyond basic text display, `TablePlusColumn` offers powerful options to control column width and render custom widgets within cells.

## 1. Custom Cell Rendering with `cellBuilder`

The `cellBuilder` property allows you to break free from simple text and render any widget you want inside a table cell. This is perfect for formatting data, showing images, adding buttons, or displaying custom status badges.

`cellBuilder` is a function that provides the `BuildContext` and the `rowData` (the `Map<String, dynamic>` for the current row) and must return a `Widget`.

### Example 1: Formatting a Salary

Instead of just showing `75000`, you can format it as a currency string and apply a custom style.

```dart
.addColumn(
  'salary',
  TablePlusColumn(
    key: 'salary',
    label: 'Salary',
    order: 0,
    cellBuilder: (context, rowData) {
      final salary = rowData['salary'] as int? ?? 0;
      final formattedSalary = '\$${salary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
      
      return Text(
        formattedSalary,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    },
  ),
)
```

### Example 2: Displaying a Status Badge

Based on a boolean `active` flag, you can display a colorful status badge.

```dart
.addColumn(
  'active',
  TablePlusColumn(
    key: 'active',
    label: 'Status',
    order: 0,
    alignment: Alignment.center, // Center the badge in the cell
    cellBuilder: (context, rowData) {
      final bool isActive = rowData['active'] as bool? ?? false;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: isActive ? Colors.green.shade800 : Colors.red.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    },
  ),
)
```

## 2. Controlling Column Width

You have fine-grained control over column widths using three properties:

- `width`: The **preferred** width of the column. The table will try to respect this width if there is enough horizontal space.
- `minWidth`: The **minimum** width the column can shrink to. This is a hard constraint.
- `maxWidth`: The **maximum** width the column can expand to. This is useful to prevent one column from taking up too much space.

### How Widths are Calculated

- **If total preferred width fits:** Any extra space is distributed proportionally among all columns.
- **If total preferred width exceeds available space:** Columns are scaled down proportionally, but never smaller than their `minWidth`.
- **If total minimum width exceeds available space:** The table will overflow horizontally, and a scrollbar will appear.

### Example

```dart
.addColumn(
  'id',
  const TablePlusColumn(
    key: 'id',
    label: 'ID',
    order: 0,
    width: 60,      // Small preferred width
    minWidth: 50,   // Cannot get smaller than 50px
    maxWidth: 80,   // Cannot get larger than 80px
    alignment: Alignment.center,
  ),
)
.addColumn(
  'description',
  const TablePlusColumn(
    key: 'description',
    label: 'Description',
    order: 0,
    width: 300,     // Give this column more space initially
    minWidth: 150,  // But allow it to shrink if needed
  ),
)
```

By combining `cellBuilder` and width constraints, you can build complex and responsive data tables that are tailored to your specific needs.

## 4. Column Reordering

`FlutterTablePlus` supports drag-and-drop column reordering, allowing users to rearrange columns by dragging column headers. This feature is managed externally by your application's state.

### Enabling Column Reordering

To enable column reordering, provide an `onColumnReorder` callback to the `FlutterTablePlus` widget:

```dart
FlutterTablePlus(
  columns: _columns,
  data: data,
  onColumnReorder: (int oldIndex, int newIndex) {
    // Handle the column reorder
    _handleColumnReorder(oldIndex, newIndex);
  },
);
```

### Implementing Column Reorder Logic

The `onColumnReorder` callback provides:
- `oldIndex`: The original position of the dragged column
- `newIndex`: The target position where the column should be moved

You need to update your column order and rebuild the widget with the new order:

```dart
void _handleColumnReorder(int oldIndex, int newIndex) {
  setState(() {
    // Convert Map to List for reordering
    final columnEntries = _columns.entries.toList();
    
    // Adjust newIndex if dragging down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Perform the reorder
    final entry = columnEntries.removeAt(oldIndex);
    columnEntries.insert(newIndex, entry);
    
    // Rebuild the map with new order values
    _columns = <String, TablePlusColumn>{};
    for (int i = 0; i < columnEntries.length; i++) {
      final key = columnEntries[i].key;
      final column = columnEntries[i].value;
      _columns[key] = column.copyWith(order: i + 1);
    }
  });
}
```

### Using TableColumnsBuilder for Easier Management

When using `TableColumnsBuilder`, you can reorder more easily by rebuilding the columns:

```dart
void _handleColumnReorder(int oldIndex, int newIndex) {
  setState(() {
    final columnKeys = _getOrderedColumnKeys(); // Get current order
    
    // Adjust newIndex if dragging down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Reorder the keys
    final key = columnKeys.removeAt(oldIndex);
    columnKeys.insert(newIndex, key);
    
    // Rebuild columns with new order
    final builder = TableColumnsBuilder();
    for (final key in columnKeys) {
      builder.addColumn(key, _originalColumns[key]!);
    }
    _columns = builder.build();
  });
}
```

### Disabling Column Reordering

You can disable column reordering in two ways:

#### Method 1: Remove the Callback (`onColumnReorder: null`)

Set `onColumnReorder: null` to completely disable column reordering. This will:
- Remove drag handles from column headers
- Disable drag-and-drop functionality entirely
- Remove visual drag affordances

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  onColumnReorder: null, // Completely disables column reordering
);
```

#### Method 2: Conditional Reordering

Enable or disable reordering based on application state:

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  onColumnReorder: userCanReorderColumns ? _handleColumnReorder : null,
);
```

### Important Notes

- **Selection Column**: The selection column (when `isSelectable: true`) is never reorderable and will always remain in the first position.
- **Performance**: Column reordering rebuilds the entire table. For large datasets, consider implementing optimizations in your state management.
- **Persistence**: Column order changes are not automatically persisted. You need to save and restore the column order in your application's storage if needed.

### Example: Complete Column Reordering Implementation

```dart
class ReorderableTablePage extends StatefulWidget {
  @override
  State<ReorderableTablePage> createState() => _ReorderableTablePageState();
}

class _ReorderableTablePageState extends State<ReorderableTablePage> {
  late Map<String, TablePlusColumn> _columns;
  
  @override
  void initState() {
    super.initState();
    _initializeColumns();
  }
  
  void _initializeColumns() {
    _columns = TableColumnsBuilder()
      .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', order: 0))
      .addColumn('name', TablePlusColumn(key: 'name', label: 'Name', order: 0))
      .addColumn('email', TablePlusColumn(key: 'email', label: 'Email', order: 0))
      .build();
  }
  
  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // Get ordered column entries
      final entries = _columns.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));
      
      // Adjust newIndex for drag behavior
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // Reorder entries
      final entry = entries.removeAt(oldIndex);
      entries.insert(newIndex, entry);
      
      // Rebuild map with new order
      _columns = <String, TablePlusColumn>{};
      for (int i = 0; i < entries.length; i++) {
        final key = entries[i].key;
        final column = entries[i].value;
        _columns[key] = column.copyWith(order: i + 1);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterTablePlus(
        columns: _columns,
        data: myData,
        onColumnReorder: _handleColumnReorder,
      ),
    );
  }
}
```
