# Feature Guide: Theming and Styling

`FlutterTablePlus` offers an extensive theming system that allows you to customize nearly every visual aspect of the table. All styling is centralized in the `TablePlusTheme` class.

## 1. The `TablePlusTheme` Object

The main entry point for styling is the `theme` property of the `FlutterTablePlus` widget. It takes a `TablePlusTheme` object, which is composed of several sub-themes for different parts of the table.

```dart
FlutterTablePlus(
  // ... other properties
  theme: const TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(/* ... */),
    bodyTheme: TablePlusBodyTheme(/* ... */),
    selectionTheme: TablePlusSelectionTheme(/* ... */),
    scrollbarTheme: TablePlusScrollbarTheme(/* ... */),
  ),
);
```

Let's explore each sub-theme.

## 2. Header Styling (`TablePlusHeaderTheme`)

This theme controls the appearance of the header row.

- `height`: The height of the header.
- `backgroundColor`: The background color of the header cells.
- `textStyle`: The `TextStyle` for the column labels.
- `padding`: The padding within each header cell.
- `showVerticalDividers`: Whether to show vertical lines between header cells.
- `showBottomDivider`: Whether to show a horizontal line below the entire header.
- `dividerColor`: The color of the dividers.
- `sortIcons`: A `SortIcons` object to customize the icons for sorting.
- `sortedColumnBackgroundColor`: A special background color for the currently sorted column.

### Example

```dart
theme: const TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(
    height: 48,
    backgroundColor: Color(0xFFF8F9FA),
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF495057),
    ),
    showVerticalDividers: false,
    sortedColumnBackgroundColor: Colors.blue.withOpacity(0.1),
  ),
),
```

## 3. Body and Row Styling (`TablePlusBodyTheme`)

This theme controls the appearance of the data rows in the table body.

- `rowHeight`: The height of each data row.
- `backgroundColor`: The default background color for rows.
- `alternateRowColor`: If set, creates a striped (zebra) effect by applying this color to odd-indexed rows.
- `textStyle`: The default `TextStyle` for cell content.
- `padding`: The padding within each data cell.
- `showHorizontalDividers`: Whether to show horizontal lines between rows.
- `showVerticalDividers`: Whether to show vertical lines between cells.
- `dividerColor`: The color of the dividers.

### Example

```dart
theme: const TablePlusTheme(
  bodyTheme: TablePlusBodyTheme(
    rowHeight: 52,
    alternateRowColor: Colors.grey.shade50, // Striped rows
    textStyle: TextStyle(fontSize: 14, color: Colors.black87),
    showHorizontalDividers: true,
    dividerColor: Colors.grey.shade200,
  ),
),
```

## 4. Selection Styling (`TablePlusSelectionTheme`)

This theme controls the appearance of selection-related elements.

- `selectedRowColor`: The background color applied to a row when it is selected.
- `checkboxColor`: The color of the selection checkboxes.
- `checkboxSize`: The size of the checkbox icon.
- `checkboxColumnWidth`: The width of the dedicated selection column.

### Example

```dart
theme: const TablePlusTheme(
  selectionTheme: TablePlusSelectionTheme(
    selectedRowColor: Colors.blue.shade100,
    checkboxColor: Colors.blue.shade700,
  ),
),
```

## 5. Scrollbar Styling (`TablePlusScrollbarTheme`)

This theme controls the appearance and behavior of the synchronized scrollbars.

- `width`: The thickness of the scrollbar.
- `color`: The color of the scrollbar thumb (the part you drag).
- `trackColor`: The color of the scrollbar track.
- `hoverOnly`: If `true`, the scrollbars will only be visible when the mouse is hovering over the table.
- `animationDuration`: The fade-in/out duration for the scrollbar when `hoverOnly` is true.

### Example

```dart
theme: const TablePlusTheme(
  scrollbarTheme: TablePlusScrollbarTheme(
    width: 8.0,
    color: Colors.grey.shade500,
    trackColor: Colors.transparent,
    hoverOnly: true,
  ),
),
```
