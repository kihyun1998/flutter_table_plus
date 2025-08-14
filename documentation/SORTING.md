# Feature Guide: Sorting

`FlutterTablePlus` provides a flexible sorting mechanism that allows users to sort columns by clicking on their headers. The sorting state is managed externally by your application logic, giving you full control over how the data is sorted.

## 1. Making a Column Sortable

To enable sorting for a specific column, set the `sortable` property to `true` in its `TablePlusColumn` definition.

```dart
final columns = TableColumnsBuilder()
  .addColumn(
    'name',
    const TablePlusColumn(
      key: 'name',
      label: 'Name',
      order: 0,
      sortable: true, // Enable sorting for this column
    ),
  )
  .build();
```

When a column is sortable, a sort icon will appear in the header, and clicking it will trigger the `onSort` callback.

## 2. Handling the `onSort` Callback

The `FlutterTablePlus` widget does not sort the data internally. Instead, it notifies you of the user's intent via the `onSort` callback. You are responsible for managing the sorting state and providing the sorted data back to the table.

Your `onSort` callback will receive:
- `columnKey`: The `key` of the column that was clicked.
- `direction`: The *next* `SortDirection` the table should cycle to. By default, the cycle is `ascending` -> `descending` -> `none`, but this can be customized (see **Section 4**).

### State Management

You need to store the current sort state in your widget's state (e.g., using `useState` in a `HookWidget`, `setState` in a `StatefulWidget`, or a Riverpod Notifier).

- `sortColumnKey` (String?): The key of the currently sorted column.
- `sortDirection` (SortDirection): The current direction of the sort.

### Implementation Steps

1.  **Provide State to Table**: Pass your `sortColumnKey` and `sortDirection` state variables to the `FlutterTablePlus` widget.
2.  **Implement `onSort`**: In the callback, update your state with the new key and direction.
3.  **Sort Your Data**: Create a separate, memoized function or provider (like in the Riverpod guide) to sort your data based on the current sort state. Provide this sorted list to the `data` property of the table.

### Example with `StatefulWidget`

```dart
class SortableTablePage extends StatefulWidget {
  const SortableTablePage({super.key, required this.originalData});
  final List<Map<String, dynamic>> originalData;

  @override
  State<SortableTablePage> createState() => _SortableTablePageState();
}

class _SortableTablePageState extends State<SortableTablePage> {
  // 1. Store sort state
  String? _sortColumnKey;
  SortDirection _sortDirection = SortDirection.none;
  late List<Map<String, dynamic>> _sortedData;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.originalData);
  }

  // 3. Sort the data based on the current state
  void _sortData() {
    if (_sortColumnKey == null || _sortDirection == SortDirection.none) {
      _sortedData = List.from(widget.originalData);
      return;
    }

    _sortedData.sort((a, b) {
      final aValue = a[_sortColumnKey!];
      final bValue = b[_sortColumnKey!];
      
      // Implement your comparison logic here
      final comparison = (aValue ?? '').toString().compareTo((bValue ?? '').toString());
      
      return _sortDirection == SortDirection.ascending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: /* your columns */,
      data: _sortedData, // Provide the sorted data
      sortColumnKey: _sortColumnKey,
      sortDirection: _sortDirection,
      onSort: (columnKey, direction) {
        // 2. Update state in the callback
        setState(() {
          _sortColumnKey = direction == SortDirection.none ? null : columnKey;
          _sortDirection = direction;
          _sortData(); // Re-sort the data
        });
      },
    );
  }
}
```

## 3. Customizing Sort Icons

You can customize the icons for each sort state using the `TablePlusHeaderTheme`.

```dart
FlutterTablePlus(
  // ... other properties
  theme: const TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      sortIcons: SortIcons(
        ascending: Icon(Icons.arrow_upward, size: 14, color: Colors.blue),
        descending: Icon(Icons.arrow_downward, size: 14, color: Colors.blue),
        unsorted: Icon(Icons.unfold_more, size: 14, color: Colors.grey),
      ),
      sortedColumnBackgroundColor: Colors.blue.withValues(alpha: 0.1),
    ),
  ),
);
```

## 4. Customizing the Sort Cycle

By default, clicking a sortable header cycles through `ascending`, `descending`, and `none`. You can customize this behavior using the `sortCycle` property.

`sortCycle` accepts a `List<SortDirection>` that defines the exact order of states to cycle through.

### Example: Two-State Sorting (Ascending -> Descending)

If you want to disable the `none` (unsorted) state and only toggle between ascending and descending, provide a custom list.

```dart
FlutterTablePlus(
  // ... other properties
  sortCycle: const [
    SortDirection.ascending,
    SortDirection.descending,
  ],
  onSort: (columnKey, direction) {
    // The `direction` will now only be `ascending` or `descending`.
    // The `none` state will never be triggered.
  },
);
```

### Example: Custom Order

You can define any order you need.

```dart
FlutterTablePlus(
  // ... other properties
  sortCycle: const [
    SortDirection.descending, // Start with descending
    SortDirection.ascending,
  ],
);
```

## 5. Disabling Sorting Completely

You can disable sorting functionality in two different ways, depending on your needs:

### Method 1: Column-Level Disabling (`sortable: false`)

Set `sortable: false` on individual columns to prevent sorting for those specific columns while keeping the `onSort` callback active for other sortable columns.

```dart
final columns = TableColumnsBuilder()
  .addColumn(
    'id',
    const TablePlusColumn(
      key: 'id',
      label: 'ID',
      order: 0,
      sortable: false, // This column won't show sort icons or respond to clicks
    ),
  )
  .addColumn(
    'name',
    const TablePlusColumn(
      key: 'name',
      label: 'Name',
      order: 0,
      sortable: true, // This column will still be sortable
    ),
  )
  .build();
```

### Method 2: Global Disabling (`onSort: null`)

Set `onSort: null` to completely disable sorting for the entire table. This will:
- Hide all sort icons from sortable columns
- Disable click handlers on all column headers
- Remove visual sorting affordances entirely

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  sortColumnKey: _sortColumnKey,
  sortDirection: _sortDirection,
  onSort: null, // Completely disables sorting - no icons will be shown
);
```

**Key Differences:**

| Feature | `sortable: false` | `onSort: null` |
|---------|-------------------|----------------|
| Sort icons | Hidden for specific columns | Hidden for all columns |
| Click handling | Disabled for specific columns | Disabled for all columns |
| Other sortable columns | Still functional | All disabled |
| Use case | Selective column control | Complete feature removal |

### When to Use Each Method

- **Use `sortable: false`** when you want to disable sorting for specific columns (like ID columns, action columns, etc.) while keeping sorting available for other columns.

- **Use `onSort: null`** when you want to completely remove the sorting feature from your table, perhaps based on user permissions or application state.

```dart
// Example: Conditional sorting based on user permissions
FlutterTablePlus(
  columns: columns,
  data: data,
  onSort: userCanSort ? _handleSort : null, // Dynamically enable/disable
);
```

## 6. Sorting with Merged Rows

When using sorting in a table that contains merged rows, it's important to understand how they interact.

- **Group Integrity**: When you sort a column, the rows within a `MergedRowGroup` will always be moved together. The entire group is treated as a single block for sorting purposes.
- **Dynamic Merged Groups**: For correct behavior, it is **highly recommended** to dynamically generate the `mergedGroups` list based on the *currently sorted* data. If your `mergedGroups` are static, they will not reflect the new data order after a sort, leading to incorrect rendering.
- **Implementation**:
    1.  In your `onSort` callback, first sort your `data` list.
    2.  After sorting, generate a new `mergedGroups` list based on the new order of the `data`.
    3.  Pass both the sorted `data` and the new `mergedGroups` to `setState` to rebuild the table.

For a detailed implementation of this approach, see the `sortable_example.dart` file in the example project. It provides a comprehensive example of how to handle sorting logic while preserving merged group integrity.
