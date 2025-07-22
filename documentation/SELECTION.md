# Feature Guide: Row Selection

`FlutterTablePlus` supports single or multiple row selection, managed by your application's state. This guide explains how to enable and control the selection feature.

## 1. Enabling Selection

To enable row selection, set the `isSelectable` property to `true`.

```dart
FlutterTablePlus(
  isSelectable: true,
  // ... other properties
);
```

When enabled, a checkbox column will appear at the beginning of the table, and tapping on a row will toggle its selection state.

## 2. The Importance of a Unique `id`

**This is critical:** For the selection feature to work correctly, every row in your `data` list (each `Map<String, dynamic>`) **must** have a unique identifier under the key `'id'`.

The widget uses `rowData['id'].toString()` to track selected rows. Duplicate or missing IDs will lead to unpredictable selection behavior.

```dart
// GOOD: Each row has a unique 'id'.
final data = [
  {'id': 1, 'name': 'Product A'},
  {'id': 2, 'name': 'Product B'},
  {'id': 'prod_c', 'name': 'Product C'}, // IDs can be String or int
];

// BAD: Missing or duplicate IDs.
final badData = [
  {'name': 'Product A'}, // Missing 'id'
  {'id': 1, 'name': 'Product B'},
  {'id': 1, 'name': 'Product C'}, // Duplicate 'id'
];
```

## 3. Managing Selection State

Similar to sorting, the table delegates selection state management to the parent widget. You need to store the set of selected row IDs and provide it to the table.

### State Management

- `selectedRows` (`Set<String>`): A set containing the unique IDs of the selected rows.

### Callbacks

- `onRowSelectionChanged`: Called when a single row's checkbox is toggled or a row is tapped. It provides the `rowId` and its new `isSelected` state.
- `onSelectAll`: Called when the header checkbox is clicked. It provides a boolean indicating whether to select all rows.
- `onRowDoubleTap`: **New!** Called when a row is double-tapped. Provides the `rowId` of the double-tapped row. This callback is active only when `isSelectable` is `true`.
- `onRowSecondaryTap`: **New!** Called when a row is right-clicked (or long-pressed on touch devices). Provides the `rowId` of the secondary-tapped row. This callback is active only when `isSelectable` is `true`.

### Example with `StatefulWidget`

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

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: /* your columns */,
      data: widget.data,
      isSelectable: true,
      selectedRows: _selectedRowIds, // Provide the current selection state
      
      // 2. Handle single row selection
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
            _selectedRowIds = widget.data.map((row) => row['id'].toString()).toSet();
          } else {
            _selectedRowIds.clear();
          }
        });
      },
      
      // 4. Handle double-tap (New!)
      onRowDoubleTap: (rowId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Double-tapped row: $rowId'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      
      // 5. Handle secondary-tap (New!)
      onRowSecondaryTap: (rowId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Secondary-tapped row: $rowId'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
```

## 4. Customizing Selection Appearance

You can customize the appearance of selected rows and checkboxes via the `TablePlusSelectionTheme`.

```dart
FlutterTablePlus(
  // ... other properties
  theme: const TablePlusTheme(
    selectionTheme: TablePlusSelectionTheme(
      selectedRowColor: Color(0xFFE3F2FD), // Light blue for selected rows
      checkboxColor: Colors.blue,
      checkboxSize: 20.0,
      checkboxColumnWidth: 50.0,
    ),
  ),
);
```