# Feature Guide: Row Selection

`FlutterTablePlus` supports both **single** and **multiple** row selection, managed by your application's state. This guide explains how to enable and control the selection feature.

## 1. Enabling Selection and Choosing a Mode

To enable row selection, set `isSelectable` to `true`. You can then choose the desired behavior using the `selectionMode` property.

- `SelectionMode.multiple` (Default): Allows users to select multiple rows simultaneously.
- `SelectionMode.single`: Restricts selection to only one row at a time.

```dart
FlutterTablePlus(
  isSelectable: true,
  selectionMode: SelectionMode.single, // Or SelectionMode.multiple
  // ... other properties
);
```

When `isSelectable` is `true`, a checkbox column appears by default, and tapping a row toggles its selection state. In `single` mode, the "Select All" checkbox is automatically hidden.

## 2. Providing a Unique Row Identifier

For the selection feature to work correctly, every row in your `data` list must have a unique identifier. By default, the widget looks for a key named `'id'`.

### Using a Custom Row ID Key

If your data uses a different key for its unique ID (e.g., `'user_uuid'`, `'productId'`), you can specify it using the `rowIdKey` property. This avoids the need to modify your data structure.

```dart
FlutterTablePlus(
  // ...
  rowIdKey: 'user_uuid', // Tell the table to use 'user_uuid' as the ID
  data: [
    {'user_uuid': 'abc-123', 'name': 'Product A'},
    {'user_uuid': 'def-456', 'name': 'Product B'},
  ],
  // ...
);
```

**Important**: The value associated with your `rowIdKey` will be converted to a `String` for internal tracking. Ensure it is unique for each row.

## 3. Managing Selection State

The table delegates selection state management to the parent widget. You need to store the set of selected row IDs and provide it to the table.

### State Management

- `selectedRows` (`Set<String>`): A set containing the unique IDs of the selected rows.

### Callbacks

- `onRowSelectionChanged`: Called when a single row's checkbox is toggled or a row is tapped. It provides the `rowId` and its new `isSelected` state.
- `onSelectAll`: Called when the header checkbox is clicked. **Note:** This is only relevant for `SelectionMode.multiple`.
- `onRowDoubleTap`: Called when a row is double-tapped. Provides the `rowId`. Active only when `isSelectable` is `true`.
- `onRowSecondaryTap`: Called when a row is right-clicked or long-pressed. Provides the `rowId`. Active only when `isSelectable` is `true`.

### Example with `StatefulWidget`

This example demonstrates how to handle selection, assuming the unique ID key is `'id'`.

```dart
class SelectableTablePage extends StatefulWidget {
  const SelectableTablePage({super.key, required this.data});
  final List<Map<String, dynamic>> data;

  @override
  State<SelectableTablePage> createState() => _SelectableTablePageState();
}

class _SelectableTablePageState extends State<SelectableTablePage> {
  // 1. Store selection state
  Set<String> _selectedRowIds = {};
  final String _rowIdKey = 'id'; // Define your ID key

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: /* your columns */,
      data: widget.data,
      rowIdKey: _rowIdKey,
      isSelectable: true,
      selectedRows: _selectedRowIds,
      
      // 2. Handle row selection
      onRowSelectionChanged: (rowId, isSelected) {
        setState(() {
          if (isSelected) {
            _selectedRowIds.add(rowId);
          } else {
            _selectedRowIds.remove(rowId);
          }
        });
      },
      
      // 3. Handle select-all
      onSelectAll: (selectAll) {
        setState(() {
          if (selectAll) {
            _selectedRowIds = widget.data.map((row) => row[_rowIdKey].toString()).toSet();
          } else {
            _selectedRowIds.clear();
          }
        });
      },
    );
  }
}
```

## 4. Customizing Selection Appearance

You can customize the appearance of selected rows, interaction effects, and checkboxes via the `TablePlusSelectionTheme`. See `THEMING.md` for more details on styling hover, splash, and highlight colors.

```dart
FlutterTablePlus(
  // ... other properties
  theme: const TablePlusTheme(
    selectionTheme: TablePlusSelectionTheme(
      selectedRowColor: Color(0xFFE3F2FD), // Light blue for selected rows
      checkboxColor: Colors.blue,
      rowHoverColor: Colors.black.withValues(alpha: 0.05),
    ),
  ),
);
```