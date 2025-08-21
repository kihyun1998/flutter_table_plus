# Merged Rows in Flutter Table Plus

This document provides a comprehensive guide to using the merged row functionality in `flutter_table_plus`. Merged rows allow you to visually combine multiple data rows into a single, cohesive unit within your table, particularly useful for displaying grouped or hierarchical data.

## Table of Contents

1.  [Introduction](#introduction)
2.  [Core Concepts](#core-concepts)
    *   [MergedRowGroup](#mergedrowgroup)
    *   [MergeCellConfig](#mergecellconfig)
3.  [Enabling Merged Rows](#enabling-merged-rows)
4.  [Simple Merged Rows Example](#simple-merged-rows-example)
5.  [Complex Merged Rows (Multiple Columns & Custom Content)](#complex-merged-rows-multiple-columns--custom-content)
6.  [Expandable Summary Rows](#expandable-summary-rows)
7.  [Selection with Merged Rows](#selection-with-merged-rows)
8.  [Editing Merged Cells](#editing-merged-cells)
9.  [Considerations and Best Practices](#considerations-and-best-practices)

---

## 1. Introduction

The merged row feature in `flutter_table_plus` allows you to define groups of consecutive rows in your dataset that should be treated as a single visual row for specific columns. This is ideal for scenarios where you have repeating data in certain columns across multiple rows that logically belong together, such as departmental information for multiple employees.

Instead of repeating the same value in each row, you can merge the cells in that column across the grouped rows, displaying the value only once in a larger, spanning cell.

## 2. Core Concepts

The merged row functionality relies on two primary classes: `MergedRowGroup` and `MergeCellConfig`.

### MergedRowGroup

The `MergedRowGroup` class defines a set of original data rows that should be grouped together and how their cells should be merged.

```dart
class MergedRowGroup {
  const MergedRowGroup({
    required this.groupId,
    required this.rowKeys,
    required this.mergeConfig,
    this.isExpandable = false,
    this.isExpanded = false,
    this.summaryRowData,
  });

  /// Unique identifier for this merge group.
  /// Used for selection and editing operations.
  final String groupId;

  /// List of row keys that belong to this group.
  /// These keys refer to the unique identifiers of rows in the data list.
  final List<String> rowKeys;

  /// Configuration for how each column should be merged within this group.
  /// Key: column key, Value: merge configuration for that column.
  final Map<String, MergeCellConfig> mergeConfig;

  /// Whether this merge group supports expandable summary row functionality.
  final bool isExpandable;

  /// Whether the summary row is currently expanded.
  final bool isExpanded;

  /// Data to display in the summary row when expanded.
  /// Key: column key, Value: data to display in that column's summary cell.
  final Map<String, dynamic>? summaryRowData;

  /// Returns the number of rows in this group.
  int get rowCount => rowKeys.length;

  /// Returns true if the specified column should be merged for this group.
  bool shouldMergeColumn(String columnKey);

  /// Returns the row index where the merged content should be displayed for the specified column.
  int getSpanningRowIndex(String columnKey);

  /// Returns custom merged content for the specified column, if any.
  Widget? getMergedContent(String columnKey);

  /// Returns true if the merged cell for the specified column is editable.
  bool isMergedCellEditable(String columnKey);
}
```

*   **`groupId`**: A unique string identifier for this specific group of merged rows. This ID is used for selection and editing operations when dealing with merged groups.
*   **`rowKeys`**: A list of row keys (string identifiers) from your original `data` list that belong to this merged group. These keys must correspond to the unique identifier field (specified by `rowIdKey`) of the rows you wish to merge.
*   **`mergeConfig`**: A map where keys are column keys (e.g., `'department'`, `'level'`) and values are `MergeCellConfig` objects. This map specifies how each column within this group should behave regarding merging.

### MergeCellConfig

The `MergeCellConfig` class defines the merging behavior for a *specific cell* within a `MergedRowGroup`.

```dart
class MergeCellConfig {
  const MergeCellConfig({
    required this.shouldMerge,
    this.spanningRowIndex = 0,
    this.mergedContent,
    this.isEditable = false,
  });

  /// Whether this column should be merged for this group.
  /// If false, each row in the group will show its individual cell content.
  final bool shouldMerge;

  /// The index (0-based) of the row within the group where the merged cell content should be displayed.
  /// Other rows in the group will have empty cells for this column.
  /// Defaults to 0 (first row).
  final int spanningRowIndex;

  /// Custom widget content to display in the merged cell.
  /// If null, the content from the row at [spanningRowIndex] will be used.
  final Widget? mergedContent;

  /// Whether this merged cell should be editable.
  /// Only applies to merged cells without custom [mergedContent].
  /// If [mergedContent] is provided, this field is ignored.
  final bool isEditable;
}
```

*   **`shouldMerge`**: A boolean indicating whether the cells in this specific column should be merged across the `rowKeys` defined in the parent `MergedRowGroup`. If `false`, each row in the group will display its individual cell content for this column.
*   **`spanningRowIndex`**: When `shouldMerge` is `true`, this 0-based index specifies which row *within the `rowKeys` list* will display the merged content. For example, if `rowKeys` is `['user1', 'user2', 'user3']` and `spanningRowIndex` is `1`, the content from the row with key `'user2'` will be displayed in the merged cell. Defaults to `0` (the first row in the group).
*   **`mergedContent`**: An optional `Widget` that can be used to provide custom content for the merged cell. If provided, this widget will be displayed instead of the default text content from the `spanningRowIndex`. This is useful for displaying icons, custom layouts, or aggregated information.
*   **`isEditable`**: A boolean indicating whether this merged cell should be editable. This property is only considered if `shouldMerge` is `true` and `mergedContent` is `null`. If `mergedContent` is provided, the cell is considered custom-rendered and cannot be edited via the default text field.

## 3. Enabling Merged Rows

To enable merged rows, you need to provide a list of `MergedRowGroup` objects to the `mergedGroups` property of the `FlutterTablePlus` widget.

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  mergedGroups: mergedGroups, // Provide your list of MergedRowGroup here
  // ... other properties
)
```

The `FlutterTablePlus` widget will automatically detect and render the merged cells based on the provided `mergedGroups` configuration.

## 4. Simple Merged Rows Example

Let's say you have employee data and you want to merge the 'department' column for employees belonging to the same department.

**Data Structure:**

```dart
final List<Map<String, dynamic>> data = [
  {'id': '1', 'name': 'Alice', 'department': 'IT', 'salary': 100},
  {'id': '2', 'name': 'Bob', 'department': 'IT', 'salary': 120},
  {'id': '3', 'name': 'Charlie', 'department': 'Business', 'salary': 150},
];
```

**Column Configuration:**

```dart
final Map<String, TablePlusColumn> columns = {
  'id': TablePlusColumn(key: 'id', label: 'ID', width: 80),
  'name': TablePlusColumn(key: 'name', label: 'Name', width: 120),
  'department': TablePlusColumn(key: 'department', label: 'Department', width: 150),
  'salary': TablePlusColumn(key: 'salary', label: 'Salary', width: 100),
};
```

**Merged Group Configuration:**

To merge the 'IT' department for Alice and Bob (original indices 0 and 1):

```dart
final List<MergedRowGroup> mergedGroups = [
  MergedRowGroup(
    groupId: 'it_dept_group',
    rowKeys: ['1', '2'], // Alice and Bob (using their id values)
    mergeConfig: {
      'department': MergeCellConfig(
        shouldMerge: true,
        spanningRowIndex: 0, // Display 'IT' from the first row (Alice)
      ),
    },
  ),
];
```

**FlutterTablePlus Usage:**

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  mergedGroups: mergedGroups,
)
```

This will result in the 'Department' column for Alice and Bob being merged into a single cell displaying 'IT', while Charlie's 'Business' department remains a regular cell.

## 5. Complex Merged Rows (Multiple Columns & Custom Content)

You can merge multiple columns within the same group and provide custom widgets for the merged cells.

**Data Structure:**

```dart
final List<Map<String, dynamic>> data = [
  {'id': '1', 'name': 'Alice', 'department': 'IT', 'level': 'Senior'},
  {'id': '2', 'name': 'Bob', 'department': 'IT', 'level': 'Junior'},
  {'id': '3', 'name': 'Charlie', 'department': 'IT', 'level': 'Senior'},
  {'id': '4', 'name': 'David', 'department': 'Sales', 'level': 'Manager'},
  {'id': '5', 'name': 'Eve', 'department': 'Sales', 'level': 'Senior'},
];
```

**Merged Group Configuration (IT Department Example):**

Here, we merge 'department' with custom content and 'level' with default content, while 'name' remains unmerged.

```dart
final List<MergedRowGroup> mergedGroups = [
  MergedRowGroup(
    groupId: 'it_group',
    rowKeys: ['1', '2', '3'], // Alice, Bob, Charlie (using their id values)
    mergeConfig: {
      'department': MergeCellConfig(
        shouldMerge: true,
        spanningRowIndex: 0,
        mergedContent: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.computer, color: Colors.blue, size: 16),
              Text(
                'IT Department',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '3 members',
                style: TextStyle(fontSize: 10, color: Colors.blue.shade600),
              ),
            ],
          ),
        ),
      ),
      'level': MergeCellConfig(
        shouldMerge: true,
        spanningRowIndex: 1, // Display Bob's level ('Junior')
      ),
      // 'name' is not in mergeConfig, so it will not be merged.
      // Each row (Alice, Bob, Charlie) will show their individual names.
    },
  ),
  // ... other merged groups (e.g., for Sales department)
];
```

## 6. Expandable Summary Rows

Flutter Table Plus supports expandable summary rows for merged groups, allowing you to display calculated totals, counts, or any aggregated data that can be shown/hidden on demand.

### Basic Setup

To enable expandable summary functionality, set the following properties on your `MergedRowGroup`:

```dart
MergedRowGroup(
  groupId: 'department-001',
  rowKeys: ['emp1', 'emp2', 'emp3'],
  mergeConfig: {
    'department': MergeCellConfig(shouldMerge: true),
  },
  // Enable expandable functionality
  isExpandable: true,
  isExpanded: false, // Initially collapsed
  // Define summary data to display
  summaryRowData: {
    'name': 'Total Employees',
    'salary': '\$25,000', // Calculated total
    'count': '3 employees',
  },
)
```

### Handling Expand/Collapse Events

Add the `onMergedRowExpandToggle` callback to your `FlutterTablePlus`:

```dart
FlutterTablePlus(
  // ... other properties
  onMergedRowExpandToggle: (groupId) {
    setState(() {
      // Toggle the expanded state for the specific group
      expandedStates[groupId] = !(expandedStates[groupId] ?? false);
    });
  },
)
```

### Summary Row Features

- **Automatic Icons**: Expand/collapse icons (▼/▶) automatically appear in the first column of expandable groups
- **Custom Background**: Summary rows have a distinctive background color (configurable via `summaryRowBackgroundColor` in `TablePlusBodyTheme`)
- **Selective Display**: Only columns with data in `summaryRowData` will show content in the summary row
- **Rich Content**: Summary data can contain any displayable content (text, formatted numbers, counts, etc.)

### Complete Example

```dart
class ExpandableSummaryExample extends StatefulWidget {
  @override
  _ExpandableSummaryExampleState createState() => _ExpandableSummaryExampleState();
}

class _ExpandableSummaryExampleState extends State<ExpandableSummaryExample> {
  Map<String, bool> expandedStates = {
    'dept-001': false,
    'dept-002': true, // Start expanded
  };

  // Calculate totals dynamically
  int calculateDepartmentTotal(List<String> rowKeys) {
    return rowKeys.map((key) => 
      data.firstWhere((row) => row['id'] == key)['salary'] as int
    ).reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final mergedGroups = [
      MergedRowGroup(
        groupId: 'dept-001',
        rowKeys: ['emp1', 'emp2'],
        isExpandable: true,
        isExpanded: expandedStates['dept-001'] ?? false,
        summaryRowData: {
          'name': '📊 Department Total',
          'salary': '\$${calculateDepartmentTotal(['emp1', 'emp2'])}',
          'position': '2 employees',
        },
        mergeConfig: {
          'department': MergeCellConfig(shouldMerge: true),
        },
      ),
    ];

    return FlutterTablePlus(
      mergedGroups: mergedGroups,
      onMergedRowExpandToggle: (groupId) {
        setState(() {
          expandedStates[groupId] = !(expandedStates[groupId] ?? false);
        });
      },
      theme: TablePlusTheme(
        bodyTheme: TablePlusBodyTheme(
          summaryRowBackgroundColor: Colors.green.shade50,
        ),
      ),
      // ... other properties
    );
  }
}
```

> 💡 **For Advanced Expandable Functionality**: See [EXPANDABLE_ROWS.md](EXPANDABLE_ROWS.md) for comprehensive guides on state management, performance optimization, lazy loading, and complex expandable scenarios.

## 7. Selection with Merged Rows

When `isSelectable` is `true` in `FlutterTablePlus`, merged groups are treated as single selectable units.

*   **`selectedRows`**: The `selectedRows` `Set<String>` in `FlutterTablePlus` should contain the `groupId` of the `MergedRowGroup` if the entire group is selected. For individual (non-merged) rows, it will contain their `rowIdKey` value.
*   **`onRowSelectionChanged`**: When a merged group's checkbox or row area is tapped, the `onRowSelectionChanged` callback will be invoked with the `groupId` of the `MergedRowGroup`.
*   **`onSelectAll`**: The "Select All" checkbox in the header will consider each `MergedRowGroup` as one selectable unit.

**Example for Selectable Merged Rows:**

```dart
class SelectableMergedExample extends StatefulWidget {
  const SelectableMergedExample({super.key});

  @override
  State<SelectableMergedExample> createState() => _SelectableMergedExampleState();
}

class _SelectableMergedExampleState extends State<SelectableMergedExample> {
  Set<String> selectedRows = {}; // Stores groupId for merged, rowId for individual

  // ... (data, columns, mergedGroups as defined in previous examples)

  void _handleRowSelectionChanged(String rowId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedRows.add(rowId);
      } else {
        selectedRows.remove(rowId);
      }
    });
  }

  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        // Example: Select all merged groups and individual rows
        selectedRows = {'it_group', 'sales_group', '6'}; // '6' is an example individual row ID
      } else {
        selectedRows.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... AppBar
      body: FlutterTablePlus(
        columns: columns,
        data: data,
        mergedGroups: mergedGroups,
        isSelectable: true,
        selectedRows: selectedRows,
        onRowSelectionChanged: _handleRowSelectionChanged,
        onSelectAll: _handleSelectAll,
      ),
    );
  }
}
```

## 7. Editing Merged Cells

Merged cells can also be made editable. This is controlled by the `isEditable` property within `MergeCellConfig`.

*   **`MergeCellConfig.isEditable`**: Set this to `true` for a specific column within a `MergedRowGroup`'s `mergeConfig` if you want that merged cell to be editable.
    *   **Important**: A merged cell can only be editable if `mergedContent` is `null`. If `mergedContent` is provided, the cell is considered custom-rendered and cannot be edited via the default text field.
*   **`onMergedCellChanged`**: `FlutterTablePlus` introduces a new callback, `onMergedCellChanged`, specifically for changes made to merged cells.
    *   `void Function(String groupId, String columnKey, dynamic newValue)`
    *   `groupId`: The `groupId` of the `MergedRowGroup` that contains the changed cell.
    *   `columnKey`: The key of the column whose merged cell was changed.
    *   `newValue`: The new value entered into the merged cell.
    *   You should use this callback to update the underlying data for the `spanningRowIndex` of the merged group.

**Example for Editable Merged Cells:**

```dart
class EditableMergedExample extends StatefulWidget {
  const EditableMergedExample({super.key});

  @override
  State<EditableMergedExample> createState() => _EditableMergedExampleState();
}

class _EditableMergedExampleState extends State<EditableMergedExample> {
  List<Map<String, dynamic>> data = [
    // ... your data
  ];

  // ... (columns, mergedGroups)

  void _handleCellChanged(
    String columnKey,
    int rowIndex,
    dynamic oldValue,
    dynamic newValue,
  ) {
    // Handle changes for individual (non-merged) cells
    setState(() {
      data[rowIndex][columnKey] = newValue;
      // Update your data source
    });
  }

  void _handleMergedCellChanged(
      String groupId, String columnKey, dynamic newValue) {
    setState(() {
      // Find the group and update the appropriate row's data
      final group = mergedGroups.firstWhere((g) => g.groupId == groupId);
      final spanningRowIndex = group.getSpanningRowIndex(columnKey);
      final spanningRowKey = group.getSpanningRowKey(columnKey);
      final dataIndex = data.indexWhere((row) => row['id']?.toString() == spanningRowKey);

      data[dataIndex][columnKey] = newValue;
      // Update your data source for the merged cell
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... AppBar
      body: FlutterTablePlus(
        columns: columns,
        data: data,
        mergedGroups: mergedGroups,
        isEditable: true, // Enable editing for the table
        onCellChanged: _handleCellChanged, // For individual cells
        onMergedCellChanged: _handleMergedCellChanged, // For merged cells
      ),
    );
  }
}
```

## 8. Considerations and Best Practices

*   **Valid Row Keys**: Ensure that all `rowKeys` in `MergedRowGroup` correspond to existing rows in your data list and match the unique identifier field specified by `rowIdKey`.
*   **Data Consistency**: When a merged cell is edited, remember that the change applies to the single data entry at the `spanningRowIndex` within your original `data` list. If other rows in the merged group conceptually share this data, you might need to manually update them in your data source after `onMergedCellChanged` is triggered.
*   **`mergedContent` vs. `isEditable`**: If you provide `mergedContent`, the cell will not be editable. Choose between custom content or editability for merged cells.
*   **Performance**: For very large datasets with many merged groups, ensure your `mergeConfig` is optimized.
*   **Sorting**: When sorting a table with merged rows, the entire `MergedRowGroup` is treated as a single unit. For correct behavior, it is highly recommended to dynamically generate the `mergedGroups` list based on the sorted data. This ensures that groups are correctly identified after the data order changes. For a detailed example, refer to the `sortable_example.dart` file in the example project.
*   **Selection Mode**: In `SelectionMode.single`, selecting a merged group will deselect any previously selected individual rows or other merged groups. Clicking on an already selected merged group will deselect it (toggle behavior).
*   **Row Height**: Merged rows will visually span the height of all their constituent original rows. The height is determined by the theme's `rowHeight` setting.
*   **Column Visibility**: If a column involved in merging is made invisible, the merging behavior for that column will not be displayed.
