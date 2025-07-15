# Feature Guide: Advanced Column Settings

Beyond basic text display, `TablePlusColumn` offers powerful options to control column width and render custom widgets within cells.

## 1. Custom Cell Rendering with `cellBuilder`

The `cellBuilder` property allows you to break free from simple text and render any widget you want inside a table cell. This is perfect for formatting data, showing images, adding buttons, or displaying custom status badges.

`cellBuilder` is a function that provides the `BuildContext` and the `rowData` (the `Map<String, dynamic>` for the current row) and must return a `Widget`.

### Example 1: Formatting a Salary

Instead of just showing `75000`, you can format it as a currency string and apply a custom style.

```dart
.addColumn(
  'salary',
  TablePlusColumn(
    key: 'salary',
    label: 'Salary',
    order: 0,
    cellBuilder: (context, rowData) {
      final salary = rowData['salary'] as int? ?? 0;
      final formattedSalary = '\$${salary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
      
      return Text(
        formattedSalary,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    },
  ),
)
```

### Example 2: Displaying a Status Badge

Based on a boolean `active` flag, you can display a colorful status badge.

```dart
.addColumn(
  'active',
  TablePlusColumn(
    key: 'active',
    label: 'Status',
    order: 0,
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

- `width`: The **preferred** width of the column. The table will try to respect this width if there is enough horizontal space.
- `minWidth`: The **minimum** width the column can shrink to. This is a hard constraint.
- `maxWidth`: The **maximum** width the column can expand to. This is useful to prevent one column from taking up too much space.

### How Widths are Calculated

- **If total preferred width fits:** Any extra space is distributed proportionally among all columns.
- **If total preferred width exceeds available space:** Columns are scaled down proportionally, but never smaller than their `minWidth`.
- **If total minimum width exceeds available space:** The table will overflow horizontally, and a scrollbar will appear.

### Example

```dart
.addColumn(
  'id',
  const TablePlusColumn(
    key: 'id',
    label: 'ID',
    order: 0,
    width: 60,      // Small preferred width
    minWidth: 50,   // Cannot get smaller than 50px
    maxWidth: 80,   // Cannot get larger than 80px
    alignment: Alignment.center,
  ),
)
.addColumn(
  'description',
  const TablePlusColumn(
    key: 'description',
    label: 'Description',
    order: 0,
    width: 300,     // Give this column more space initially
    minWidth: 150,  // But allow it to shrink if needed
  ),
)
```

By combining `cellBuilder` and width constraints, you can build complex and responsive data tables that are tailored to your specific needs.
