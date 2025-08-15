# Feature Guide: Advanced Column Settings

Beyond basic text display, `TablePlusColumn` offers powerful options to control column width, text overflow, and render custom widgets within cells.

## 1. Custom Cell Rendering with `cellBuilder`

The `cellBuilder` property allows you to break free from simple text and render any widget you want inside a table cell. This is perfect for formatting data, showing images, adding buttons, or displaying custom status badges.

`cellBuilder` is a function that provides the `BuildContext` and the `rowData` (the `Map<String, dynamic>` for the current row) and must return a `Widget`.

### Example: Displaying a Status Badge

```dart
.addColumn(
  'active',
  TablePlusColumn(
    key: 'active',
    label: 'Status',
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

- `width`: The **preferred** width of the column.
- `minWidth`: The **minimum** width the column can shrink to.
- `maxWidth`: The **maximum** width the column can expand to.

### How Widths are Calculated

- **If total preferred width fits:** Any extra space is distributed proportionally among all columns.
- **If total preferred width exceeds available space:** Columns are scaled down proportionally, but never smaller than their `minWidth`.
- **If total minimum width exceeds available space:** The table will overflow horizontally, and a scrollbar will appear.

### Example

```dart
.addColumn(
  'description',
  const TablePlusColumn(
    key: 'description',
    label: 'Description',
    width: 300,     // Give this column more space initially
    minWidth: 150,  // But allow it to shrink if needed
  ),
)
```

## 3. Handling Text Overflow and Tooltips

When cell content is too long to fit, you can control its appearance and behavior with `textOverflow` and `tooltipBehavior`.

- `textOverflow`: A `TextOverflow` enum (`clip`, `fade`, `ellipsis`, `visible`). Defaults to `ellipsis`. Controls how text overflow is handled when content exceeds the available cell space.
- `tooltipBehavior`: A `TooltipBehavior` enum that gives you precise control over when tooltips appear for **cell content**.
  - `TooltipBehavior.always`: The tooltip is always available on hover if `textOverflow` is `ellipsis`.
  - `TooltipBehavior.onOverflowOnly`: The tooltip only appears if the text is actually truncated. This is useful for avoiding redundant tooltips.
  - `TooltipBehavior.never`: The tooltip is disabled for the column.
- `headerTooltipBehavior`: A `TooltipBehavior` enum that controls when tooltips appear for the **column header**. Defaults to `onOverflowOnly`.
- **(Deprecated)** `showTooltipOnOverflow`: A `bool` that was previously used to control tooltips. Use `tooltipBehavior` instead.

### Example: Precise Tooltip Control

```dart
.addColumn(
  'description',
  const TablePlusColumn(
    key: 'description',
    label: 'Description',
    width: 200,
    
    // Truncate long text with an ellipsis (...)
    textOverflow: TextOverflow.ellipsis, 
    
    // Only show the tooltip if the description text actually overflows.
    tooltipBehavior: TooltipBehavior.onOverflowOnly,
  ),
)
```

You can also customize the appearance of the tooltip via `TablePlusTheme`'s `tooltipTheme` property. See `THEMING.md` for more details.

## 4. Column Reordering

`FlutterTablePlus` supports drag-and-drop column reordering, allowing users to rearrange columns by dragging column headers. This feature is managed externally by your application's state.

### Enabling Column Reordering

To enable column reordering, provide an `onColumnReorder` callback to the `FlutterTablePlus` widget. If this callback is `null`, the feature is disabled.

```dart
FlutterTablePlus(
  columns: _columns,
  data: data,
  onColumnReorder: (int oldIndex, int newIndex) {
    // Handle the column reorder logic here
    _handleColumnReorder(oldIndex, newIndex);
  },
);
```

### Implementing the Reorder Logic

The `onColumnReorder` callback provides the `oldIndex` and `newIndex` of the columns involved in the drag operation. Your responsibility is to update your list of columns and trigger a rebuild.

Here is a complete example of how to manage the column list and implement the handler:

```dart
class ReorderableTableScreen extends StatefulWidget {
  const ReorderableTableScreen({super.key});

  @override
  State<ReorderableTableScreen> createState() => _ReorderableTableScreenState();
}

class _ReorderableTableScreenState extends State<ReorderableTableScreen> {
  // Store columns in a list to easily manage order
  late List<TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    // Define the initial column configuration
    _columns = [
      TablePlusColumn(key: 'id', label: 'ID', width: 80),
      TablePlusColumn(key: 'name', label: 'Product Name', width: 200),
      TablePlusColumn(key: 'stock', label: 'Stock', width: 100),
      TablePlusColumn(key: 'price', label: 'Price', width: 120),
    ];
  }

  void _handleColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      // The ReorderableListView that powers this feature has a quirk
      // where the newIndex needs adjustment if the item is moved downwards.
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // Remove the column from its old position and insert it at the new one
      final column = _columns.removeAt(oldIndex);
      _columns.insert(newIndex, column);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Column Reordering')),
      body: FlutterTablePlus(
        columns: _columns, // Provide the ordered list of columns
        data: yourData, // Your list of Map<String, dynamic>
        onColumnReorder: _handleColumnReorder,
      ),
    );
  }
}
```

### Important Notes

- **State Management**: The order of the columns is controlled entirely by your state (`_columns` in the example). You must store the columns in a way that preserves their order, such as a `List`.
- **Selection Column**: The selection checkbox column (when `isSelectable: true`) is fixed and not reorderable. It always stays at the beginning of the table.
- **Persistence**: The table does not automatically save the user's column order. If you need to persist the layout between sessions, you must save the column order to a local database or shared preferences and restore it when initializing your state.
```

## 5. Controlling Column Visibility

You can dynamically show or hide columns by setting the `visible` property on a `TablePlusColumn`. This is useful for creating responsive layouts or hiding sensitive information based on user permissions.

By default, all columns are visible (`visible: true`).

### How It Works

The `FlutterTablePlus` widget will filter out any columns where `visible` is set to `false` before rendering the table. This is handled automatically.

### Example: Hiding a Column

To hide a specific column, simply set its `visible` property to `false`.

```dart
.addColumn(
  'internal_id',
  const TablePlusColumn(
    key: 'internal_id',
    label: 'Internal ID',
    visible: false, // This column will not be displayed
  ),
)
```

### Example: Dynamic Visibility Based on State

You can control visibility dynamically based on your application's state. For instance, you can show or hide columns based on user roles or a toggle switch in the UI.

```dart
class DynamicColumnVisibilityScreen extends StatefulWidget {
  const DynamicColumnVisibilityScreen({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<DynamicColumnVisibilityScreen> createState() => _DynamicColumnVisibilityScreenState();
}

class _DynamicColumnVisibilityScreenState extends State<DynamicColumnVisibilityScreen> {
  late List<TablePlusColumn> _columns;

  @override
  void initState() {
    super.initState();
    // Define columns and control visibility based on a condition
    _columns = [
      TablePlusColumn(key: 'id', label: 'ID', width: 80),
      TablePlusColumn(key: 'name', label: 'Product Name', width: 200),
      // Only show the 'margin' column if the user is an admin
      TablePlusColumn(
        key: 'margin',
        label: 'Profit Margin',
        width: 120,
        visible: widget.isAdmin,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Column Visibility')),
      body: FlutterTablePlus(
        // The table will automatically filter out the invisible columns
        columns: _columns,
        data: yourData,
      ),
    );
  }
}
```

In this example, the "Profit Margin" column is only included in the table if `widget.isAdmin` is `true`.
