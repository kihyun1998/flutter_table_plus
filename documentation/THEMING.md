'''# Feature Guide: Theming and Styling

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
    editableTheme: TablePlusEditableTheme(/* ... */),
    tooltipTheme: TablePlusTooltipTheme(/* ... */),
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
- `dividerThickness`: The thickness of the dividers.
- `sortIcons`: A `SortIcons` object to customize the icons for sorting.
- `sortedColumnBackgroundColor`: A special background color for the currently sorted column.
- `decoration`: A `BoxDecoration` for advanced styling of the entire header.
- `cellDecoration`: A `BoxDecoration` for styling individual header cells.

### Advanced Header Styling with `decoration`

For more complex header designs, you can use the `decoration` property to apply a `BoxDecoration`. This allows you to add gradients, custom borders, shadows, and more.

**Note:** When you provide a `decoration`, it overrides the basic properties like `backgroundColor` and `showBottomDivider`.

```dart
theme: const TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade400, width: 2.0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF495057),
    ),
  ),
),
```

## 3. Body and Row Styling (`TablePlusBodyTheme`)

This theme controls the appearance of the data rows in the table body.

- `rowHeight`: The height of each data row. Note that row heights are now dynamically calculated based on content, ensuring optimal display for varying data lengths.
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

## 4. Selection and Interaction Styling (`TablePlusSelectionTheme`)

This theme controls the appearance of selection-related elements and row interaction effects.

- `selectedRowColor`: The background color applied to a row when it is selected.
- `selectedTextStyle`: The `TextStyle` for cell content in a selected row. If `null`, it defaults to `bodyTheme.textStyle`.
- `checkboxColor`: The color of the selection checkboxes.
- `checkboxSize`: The size of the checkbox icon.
- `checkboxColumnWidth`: The width of the dedicated selection column.
- `showCheckboxColumn`: Whether to display the checkbox column.
- `showSelectAllCheckbox`: Whether to show the "Select All" checkbox in the header.

### Row Interaction Effects (Hover, Splash, Highlight)

You can customize the colors for row interaction effects. These properties are `nullable`.

- **If you provide a `Color`**: The specified color will be used.
- **If you leave it `null`**: The default Flutter framework effect will be used.
- **If you provide `Colors.transparent`**: The effect will be disabled.

The following properties are available for both normal and selected rows:

- `rowHoverColor` / `selectedRowHoverColor`
- `rowSplashColor` / `selectedRowSplashColor`
- `rowHighlightColor` / `selectedRowHighlightColor`

### Example

```dart
theme: const TablePlusTheme(
  selectionTheme: TablePlusSelectionTheme(
    selectedRowColor: Colors.blue.shade100,
    checkboxColor: Colors.blue.shade700,
    
    // Use default hover for normal rows
    rowHoverColor: null, 
    
    // Use a custom semi-transparent blue for selected row hover
    selectedRowHoverColor: Colors.blue.withValues(alpha: 0.1), 
    
    // Disable the splash effect entirely
    rowSplashColor: Colors.transparent,
    selectedRowSplashColor: Colors.transparent,
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
- **Dynamic Visibility**: Scrollbars are now dynamically shown or hidden based on content overflow, providing a cleaner UI when not needed.

## 6. Editable Cell Styling (`TablePlusEditableTheme`)

Controls the appearance of cells in editing mode. See `EDITING.md` for more details.

## 7. Tooltip Styling (`TablePlusTooltipTheme`)

Controls the appearance of tooltips that appear when cell content overflows. See `ADVANCED_COLUMNS.md` for more details.
''
