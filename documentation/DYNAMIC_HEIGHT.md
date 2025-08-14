# Feature Guide: Dynamic Row Height

`FlutterTablePlus` supports dynamic row heights, allowing each row to adapt its height based on its content. This is particularly useful when cells contain variable-length text that needs to wrap to multiple lines.

## 1. Enabling Dynamic Row Height

To enable dynamic row heights, set the `rowHeightMode` property on the `FlutterTablePlus` widget to `RowHeightMode.dynamic`.

```dart
FlutterTablePlus(
  // ... other properties
  rowHeightMode: RowHeightMode.dynamic,
  minRowHeight: 48.0, // Optional: specify a minimum row height
)
```

### Properties

-   **`rowHeightMode`**: An enum that controls how row heights are calculated.
    -   `RowHeightMode.dynamic`: Each row's height is calculated individually based on its content. The table may have rows of varying heights.
    -   `RowHeightMode.uniform`: All rows will have the same height, determined by the tallest row in the dataset. This ensures a uniform look but may result in extra whitespace for shorter rows.
-   **`minRowHeight`**: The minimum height for any row. This is respected in both `dynamic` and `uniform` modes. Defaults to `48.0`.

## 2. How it Works: `textOverflow`

The dynamic height calculation is directly influenced by the `textOverflow` property on each `TablePlusColumn`.

-   **`TextOverflow.visible`**: When a column's `textOverflow` is set to `visible`, the table will measure the text content and allow it to wrap, expanding the row height as needed.
-   **`TextOverflow.ellipsis` or `TextOverflow.clip`**: If the `textOverflow` is set to `ellipsis` or `clip`, the text will be truncated, and it will *not* contribute to the dynamic height calculation for that cell.

To have a row's height expand, at least one column in that row must have `textOverflow: TextOverflow.visible` and contain content that requires wrapping.

### Example Column Setup

```dart
final Map<String, TablePlusColumn> columns = {
  'id': TablePlusColumn(
    key: 'id',
    label: 'ID',
    width: 60,
    textOverflow: TextOverflow.ellipsis, // Will not expand row height
  ),
  'description': TablePlusColumn(
    key: 'description',
    label: 'Description',
    width: 200,
    textOverflow: TextOverflow.visible, // WILL expand row height if content wraps
  ),
};
```

## 3. Dynamic Height with Merged Rows

Dynamic row height is fully compatible with merged rows. The height of a merged group is determined by the height of the tallest row within that group.

-   The `TextHeightCalculator` first calculates the required height for each individual row in the dataset.
-   It then identifies all rows belonging to a `MergedRowGroup`.
-   The height of all rows within that group is adjusted to match the maximum height calculated among them.

This ensures that the merged cell correctly spans the entire height of all the rows it contains, even when their individual heights vary.

## 4. Example

Here is a complete example demonstrating dynamic row height with both regular and merged rows.

```dart
class DynamicHeightExample extends StatefulWidget {
  const DynamicHeightExample({super.key});

  @override
  State<DynamicHeightExample> createState() => _DynamicHeightExampleState();
}

class _DynamicHeightExampleState extends State<DynamicHeightExample> {
  RowHeightMode _currentHeightMode = RowHeightMode.dynamic;

  List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'department': 'Engineering',
      'description': 'Short description.',
    },
    {
      'id': '2',
      'department': 'Engineering',
      'description': 'This is a much longer description that will cause the row to expand because the text will wrap to multiple lines.',
    },
    {
      'id': '3',
      'department': 'Marketing',
      'description': 'A standard length description.',
    },
  ];

  List<MergedRowGroup> get mergedGroups => [
        MergedRowGroup(
          groupId: 'engineering_group',
          rowKeys: ['1', '2'],
          mergeConfig: {
            'department': MergeCellConfig(shouldMerge: true),
          },
        ),
      ];

  final Map<String, TablePlusColumn> columns = {
    'id': TablePlusColumn(key: 'id', label: 'ID', width: 60),
    'department': TablePlusColumn(key: 'department', label: 'Department', width: 120),
    'description': TablePlusColumn(
      key: 'description',
      label: 'Description',
      width: 200,
      textOverflow: TextOverflow.visible, // Allow wrapping
    ),
  };

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: columns,
      data: data,
      rowIdKey: 'id',
      mergedGroups: mergedGroups,
      rowHeightMode: _currentHeightMode,
      minRowHeight: 50.0,
      theme: TablePlusTheme(
        bodyTheme: TablePlusBodyTheme(
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
```

In this example:

-   The `description` column has `textOverflow.visible`, allowing it to drive the height of the rows.
-   Row 2 contains a long description and will be taller than Row 1 and Row 3.
-   The "Engineering" merged group contains Row 1 and Row 2. The height of this entire group will be determined by the height of Row 2 (the taller row).
-   Both Row 1 and Row 2 will be rendered with the same, taller height to ensure the merged 'department' cell aligns correctly.
