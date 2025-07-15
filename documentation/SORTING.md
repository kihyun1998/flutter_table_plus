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
- `direction`: The *next* `SortDirection` the table should cycle to (`ascending` -> `descending` -> `none`).

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
      sortedColumnBackgroundColor: Colors.blue.withOpacity(0.1),
    ),
  ),
);
```
