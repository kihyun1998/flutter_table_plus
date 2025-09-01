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

### Single Selection Mode Behavior

In `SelectionMode.single`:
- Only one row can be selected at a time
- When a new row is selected, the previously selected row is automatically deselected
- **Toggle Behavior**: Clicking on an already selected row will deselect it, allowing for no rows to be selected
- This toggle behavior works consistently across all selection methods (row tap, checkbox click, merged row selection)

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

- `selectedRows` (`Set<String>`): A set containing the unique IDs of the selected rows. This set can contain both individual row IDs (from `rowIdKey`) and `groupId`s from `MergedRowGroup` for selected merged groups.

### Callbacks

- `onRowSelectionChanged`: Called when a row is tapped (not checkbox). It provides the `rowId` and its new `isSelected` state.
- `onCheckboxChanged`: Called when a checkbox is clicked specifically. If not provided, falls back to `onRowSelectionChanged`. This allows you to distinguish between row clicks and checkbox clicks for different behaviors.
- `onSelectAll`: Called when the header checkbox is clicked. This callback needs to handle selecting/deselecting both individual rows and merged groups. **Note:** This is only relevant for `SelectionMode.multiple`.
- `onRowDoubleTap`: Called when a row is double-tapped. Provides the `rowId`. Active only when `isSelectable` is `true`. The double-click timing can be customized via `TablePlusBodyTheme.doubleClickTime` (defaults to 500ms).
- `onRowSecondaryTapDown`: Called when a row is right-clicked or long-pressed. Provides the `rowId`, `TapDownDetails`, `RenderBox`, and `isSelected` state for precise context menu positioning. Active only when `isSelectable` is `true`.

### Example with `StatefulWidget`

This example demonstrates how to handle selection, assuming the unique ID key is `'id'`.

```dart
import 'package:flutter_table_plus/flutter_table_plus.dart'; // Add this import

class SelectableTablePage extends StatefulWidget {
  const SelectableTablePage({
    super.key,
    required this.data,
    this.mergedGroups = const [], // New: Accept merged groups
  });
  final List<Map<String, dynamic>> data;
  final List<MergedRowGroup> mergedGroups; // New: Merged groups property

  @override
  State<SelectableTablePage> createState() => _SelectableTablePageState();
}

class _SelectableTablePageState extends State<SelectableTablePage> {
  // 1. Store selection state
  Set<String> _selectedRowIds = {};
  final String _rowIdKey = 'id'; // Define your ID key

  // Helper to find merged group for a given original data index
  MergedRowGroup? _getMergedGroupForRow(int rowIndex) {
    if (rowIndex >= widget.data.length) return null;
    final rowData = widget.data[rowIndex];
    final rowKey = rowData[_rowIdKey]?.toString();
    if (rowKey == null) return null;
    
    for (final group in widget.mergedGroups) {
      if (group.rowKeys.contains(rowKey)) {
        return group;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: /* your columns */,
      data: widget.data,
      rowIdKey: _rowIdKey,
      isSelectable: true,
      selectedRows: _selectedRowIds,
      mergedGroups: widget.mergedGroups, // New: Pass merged groups to the table
      
      // 2. Handle row selection (row taps)
      onRowSelectionChanged: (rowId, isSelected) {
        print('Row tapped: $rowId');
        setState(() {
          if (isSelected) {
            _selectedRowIds.add(rowId);
          } else {
            _selectedRowIds.remove(rowId);
          }
        });
      },
      
      // 2b. Handle checkbox selection (optional - different behavior for checkbox clicks)
      onCheckboxChanged: (rowId, isSelected) {
        print('Checkbox clicked: $rowId');
        // Same logic as row selection, or implement different behavior
        setState(() {
          if (isSelected) {
            _selectedRowIds.add(rowId);
          } else {
            _selectedRowIds.remove(rowId);
          }
        });
      },
      
      // 3. Handle select-all, considering merged groups
      onSelectAll: (selectAll) {
        setState(() {
          if (selectAll) {
            final Set<String> allSelectableIds = {};
            Set<int> processedOriginalIndices = {};

            for (int i = 0; i < widget.data.length; i++) {
              if (processedOriginalIndices.contains(i)) continue;

              final mergedGroup = _getMergedGroupForRow(i);
              if (mergedGroup != null) {
                allSelectableIds.add(mergedGroup.groupId);
                for (final rowKey in mergedGroup.rowKeys) {
                  final rowIndex = widget.data.indexWhere((row) => row[_rowIdKey]?.toString() == rowKey);
                  if (rowIndex != -1) {
                    processedOriginalIndices.add(rowIndex);
                  }
                }
              } else {
                allSelectableIds.add(widget.data[i][_rowIdKey].toString());
                processedOriginalIndices.add(i);
              }
            }
            _selectedRowIds = allSelectableIds;
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

You can customize the appearance of selected rows and checkboxes using the theme system:

- **Row selection colors**: Use `TablePlusBodyTheme` for selected row background and text styling
- **Row interaction effects**: Use `TablePlusBodyTheme` for hover, splash, and highlight colors
- **Checkboxes**: Use `TablePlusCheckboxTheme` for checkbox styling

```dart
FlutterTablePlus(
  // ... other properties
  theme: const TablePlusTheme(
    bodyTheme: TablePlusBodyTheme(
      selectedRowColor: Color(0xFFE3F2FD), // Light blue for selected rows
      selectedRowTextStyle: TextStyle(fontWeight: FontWeight.w500),
      hoverColor: Colors.black.withValues(alpha: 0.05),
      selectedRowHoverColor: Colors.blue.withValues(alpha: 0.1),
    ),
    checkboxTheme: TablePlusCheckboxTheme(
      fillColor: WidgetStateProperty.all(Colors.blue),
      size: 18.0,
    ),
  ),
);
```