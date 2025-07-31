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

The table delegates selection state management to the parent widget. You need to store the set of selected row IDs and provide it to the table.

### State Management

- `selectedRows` (`Set<String>`): A set containing the unique IDs of the selected rows.

### Callbacks

- `onRowSelectionChanged`: Called when a single row's checkbox is toggled or a row is tapped. It provides the `rowId` and its new `isSelected` state.
- `onSelectAll`: Called when the header checkbox is clicked. **Note:** This is only relevant for `SelectionMode.multiple`.
- `onRowDoubleTap`: Called when a row is double-tapped. Provides the `rowId`. Active only when `isSelectable` is `true`.
- `onRowSecondaryTap`: Called when a row is right-clicked or long-pressed. Provides the `rowId`. Active only when `isSelectable` is `true`.

### Example with `StatefulWidget`

This example demonstrates how to handle both single and multiple selection modes.

```dart
class SelectableTablePage extends StatefulWidget {
  const SelectableTablePage({super.key, required this.data});
  final List<Map<String, dynamic>> data;

  @override
  State<SelectableTablePage> createState() => _SelectableTablePageState();
}

class _SelectableTablePageState extends State<SelectableTablePage> {
  // 1. Store selection state and mode
  Set<String> _selectedRowIds = {};
  SelectionMode _selectionMode = SelectionMode.multiple;

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: /* your columns */,
      data: widget.data,
      isSelectable: true,
      selectionMode: _selectionMode,
      selectedRows: _selectedRowIds,
      
      // 2. Handle row selection for both modes
      onRowSelectionChanged: (rowId, isSelected) {
        setState(() {
          if (_selectionMode == SelectionMode.single) {
            // For single selection, clear previous and add new
            _selectedRowIds.clear();
            if (isSelected) {
              _selectedRowIds.add(rowId);
            }
          } else {
            // For multiple selection, add or remove
            if (isSelected) {
              _selectedRowIds.add(rowId);
            } else {
              _selectedRowIds.remove(rowId);
            }
          }
        });
      },
      
      // 3. Handle select-all (for multiple mode)
      onSelectAll: (selectAll) {
        if (_selectionMode == SelectionMode.multiple) {
          setState(() {
            if (selectAll) {
              _selectedRowIds = widget.data.map((row) => row['id'].toString()).toSet();
            } else {
              _selectedRowIds.clear();
            }
          });
        }
      },
      
      // 4. Handle double-tap
      onRowDoubleTap: (rowId) {
        // ... show details or perform action
      },
      
      // 5. Handle secondary-tap
      onRowSecondaryTap: (rowId) {
        // ... show context menu
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
      // Hide the checkbox column completely if desired
      showCheckboxColumn: false, 
    ),
  ),
);
```

In `SelectionMode.single`, the `showSelectAllCheckbox` property of `TablePlusSelectionTheme` is automatically forced to `false`, so you don't need to manage it manually.