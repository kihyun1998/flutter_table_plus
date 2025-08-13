# Cell Editing Guide

`flutter_table_plus` supports cell editing, allowing users to modify data directly within the table. This guide explains how to enable and customize this feature.

---

## Enabling Editing

To enable editing for the entire table, set the `isEditable` property to `true` in the `FlutterTablePlus` widget.

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  isEditable: true, // Enable editing mode
  onCellChanged: (String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    // Handle the updated value
    print('Cell[$rowIndex, $columnKey] changed from $oldValue to $newValue');
    // You should update your state management solution here
  },
);
```

**Important Notes:**

- When `isEditable` is `true`, you can now also enable `isSelectable` to allow row selection and cell editing at the same time.

## Column-Specific Editing

You can control which columns are editable by setting the `editable` property in `TablePlusColumn`.

```dart
final Map<String, TablePlusColumn> columns = const TableColumnsBuilder()
    .addColumn('id', TablePlusColumn(key: 'id', label: 'ID', width: 80))
    .addColumn('name', TablePlusColumn(key: 'name', label: 'Name', width: 150, editable: true, hintText: 'Enter full name')) // Added editable and hintText
    .addColumn('department', TablePlusColumn(key: 'department', label: 'Department', width: 200, editable: true)) // This one too
    .build();
```

In this example, only the `name` and `department` columns can be edited. The `id` column will remain read-only.

## Handling Value Changes

The `onCellChanged` callback is triggered when a cell's value is modified. It provides the column key, row index, the old value, and the new value.

```dart
onCellChanged: (String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
  // Find the row that was edited
  final editedRow = data[rowIndex];

  // Update the value in your data source
  setState(() {
    editedRow[columnKey] = newValue;
  });

  // If you are using a state management library like Riverpod or BLoC,
  // you would call your provider/bloc method here to update the state.
},
```

Editing is committed when:
- The user presses the **Enter** key.
- The text field loses focus.

Editing is canceled (reverted to the old value) when:
- The user presses the **Escape** key.

## Editing Merged Cells

`flutter_table_plus` extends its editing capabilities to merged cells, allowing you to modify data directly within these spanning cells.

### Enabling Editing for Merged Cells

To make a merged cell editable, you need to configure the `isEditable` property within its `MergeCellConfig` in your `MergedRowGroup` definition.

```dart
final List<MergedRowGroup> mergedGroups = [
  MergedRowGroup(
    groupId: 'it_group',
    originalIndices: [0, 1, 2], // Alice, Bob, Charlie
    mergeConfig: {
      'department': MergeCellConfig(
        shouldMerge: true,
        spanningRowIndex: 0,
        isEditable: true, // Make the merged 'department' cell editable
      ),
      'level': MergeCellConfig(
        shouldMerge: true,
        spanningRowIndex: 1,
        isEditable: true, // Make the merged 'level' cell editable
      ),
      // Note: If 'mergedContent' is provided, 'isEditable' is ignored.
      // Only default text-based merged cells can be made editable.
    },
  ),
];
```

**Important Considerations for Merged Cell Editing:**

*   A merged cell can only be editable if its `MergeCellConfig` has `shouldMerge: true` and `mergedContent` is `null`. If `mergedContent` is provided, the cell is considered custom-rendered and cannot be edited via the default text field.
*   The `TablePlusEditableTheme` properties (e.g., `editingCellColor`, `editingTextStyle`, `textFieldPadding`) apply to merged cell editing fields as well, ensuring a consistent look and feel.

### Handling Merged Cell Value Changes

When a merged cell's value is modified, the `onMergedCellChanged` callback in `FlutterTablePlus` is triggered. This callback is specifically designed for merged cell updates, providing the `groupId` of the affected group.

```dart
FlutterTablePlus(
  // ... other properties
  isEditable: true, // Ensure overall table editing is enabled
  onCellChanged: (String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    // Handle changes for individual (non-merged) cells here
    // e.g., update data[rowIndex][columnKey] = newValue;
  },
  onMergedCellChanged: (String groupId, String columnKey, dynamic newValue) {
    // This callback is for changes in merged cells.
    // You need to find the specific data entry within the merged group to update.

    // Example: Find the group and update the data at the spanningRowIndex
    final group = yourMergedGroupsList.firstWhere((g) => g.groupId == groupId);
    final spanningRowOriginalIndex = group.originalIndices[group.getSpanningRowIndex(columnKey)];

    // Update your underlying data source for the specific cell
    setState(() {
      yourDataSource[spanningRowOriginalIndex][columnKey] = newValue;
    });

    print('Merged cell in group "$groupId", column "$columnKey" changed to "$newValue"');
  },
);
```

**Key Points for `onMergedCellChanged`:**

*   **`groupId`**: The unique identifier of the `MergedRowGroup` that contains the edited cell.
*   **`columnKey`**: The key of the column whose merged cell was changed.
*   **`newValue`**: The new value entered into the merged cell.
*   **Data Update Logic**: Your implementation of `onMergedCellChanged` should locate the correct data entry within your original data source that corresponds to the `spanningRowIndex` of the merged cell and update its value. If other rows in the merged group conceptually share this data, you might need to manually propagate the change to them in your data source.

For a more detailed understanding of `MergedRowGroup` and `MergeCellConfig`, please refer to the [Merged Rows documentation](MERGED_ROWS.md).

## Customizing the Editing UI

You can customize the appearance of cells in editing mode using `TablePlusEditableTheme` within your `TablePlusTheme`.

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  isEditable: true,
  theme: const TablePlusTheme(
    // ... other themes
    editableTheme: TablePlusEditableTheme(
      editingCellColor: Colors.yellow.shade100,
      editingTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
      editingBorderColor: Colors.blueAccent,
      editingBorderWidth: 2.0,
      editingBorderRadius: BorderRadius.zero,
      textFieldPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      hintStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey), // New: Customize hint text style
    ),
  ),
);
```

### `TablePlusEditableTheme` Properties:

- `editingCellColor`: Background color of the cell's text field when editing.
- `editingTextStyle`: Text style for the editing text field.
- `hintStyle`: **New!** Text style for the hint text displayed in the editing text field.
- `editingBorderColor`: Border color of the cell when editing.
- `editingBorderWidth`: Border width when editing.
- `editingBorderRadius`: Border radius for the editing text field.
- `textFieldPadding`: Padding inside the text field.
- `cursorColor`: Color of the cursor in the text field.
- `focusedBorderColor`: Border color when the text field is focused.
- `enabledBorderColor`: Border color when the text field is enabled but not focused.
- `fillColor`: Fill color for the text field.
- `filled`: Whether the text field should be filled.
- `isDense`: Whether the text field uses a dense layout.

### `TablePlusColumn` Properties for Editing:

- `editable`: Set to `true` to make a specific column's cells editable.
- `hintText`: **New!** Optional placeholder text to display in the `TextField` when a cell in this column is being edited.