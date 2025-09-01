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
    checkboxTheme: TablePlusCheckboxTheme(/* ... */),
    scrollbarTheme: TablePlusScrollbarTheme(/* ... */),
    editableTheme: TablePlusEditableTheme(/* ... */),
    tooltipTheme: TablePlusTooltipTheme(/* ... */),
    dividerTheme: TablePlusDividerTheme(/* ... */),
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

- `rowHeight`: The height of each data row. All rows will have this fixed height.
- `backgroundColor`: The default background color for rows.
- `alternateRowColor`: If set, creates a striped (zebra) effect. This color is applied to the rows that are at an odd *rendering* index (1, 3, 5, ...), not necessarily the odd index in your original data list. This ensures the striping is correct even after sorting or filtering.
- `summaryRowBackgroundColor`: The background color for expandable summary rows in merged row groups. If not set, defaults to a semi-transparent version of the default background color.
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
    summaryRowBackgroundColor: Colors.blue.shade50, // Summary row background
    textStyle: TextStyle(fontSize: 14, color: Colors.black87),
    showHorizontalDividers: true,
    dividerColor: Colors.grey.shade200,
  ),
),
```

## 4. Row Interaction Styling (`TablePlusBodyTheme`)

Row interaction effects like hover, splash, and highlight are now configured in the `TablePlusBodyTheme`. These properties are `nullable`:

- **If you provide a `Color`**: The specified color will be used.
- **If you leave it `null`**: The default Flutter framework effect will be used.
- **If you provide `Colors.transparent`**: The effect will be disabled.

### Available Properties

- `hoverColor` / `selectedRowHoverColor`: Colors for hover effects on unselected/selected rows
- `splashColor` / `selectedRowSplashColor`: Colors for tap splash effects on unselected/selected rows  
- `highlightColor` / `selectedRowHighlightColor`: Colors for highlight effects on unselected/selected rows

### Example

```dart
theme: TablePlusTheme(
  bodyTheme: TablePlusBodyTheme(
    // Row interaction effects
    hoverColor: Colors.grey.shade100,
    selectedRowHoverColor: Colors.blue.withValues(alpha: 0.1),
    
    // Disable splash effects
    splashColor: Colors.transparent,
    selectedRowSplashColor: Colors.transparent,
  ),
),
```


## 5. Checkbox Styling (`TablePlusCheckboxTheme`)

This theme provides comprehensive styling options for table checkboxes, supporting both the latest Flutter Material 3 design system with `WidgetStateProperty` and legacy single-color properties.

### Material 3 Properties (Recommended)

- `fillColor`: `WidgetStateProperty<Color?>?` - State-aware checkbox background/fill color
- `overlayColor`: `WidgetStateProperty<Color?>?` - State-aware overlay (ripple) color for interactions

### Traditional Single-Color Properties

- `checkColor`: Color of the check mark/icon inside the checkbox
- `focusColor`: Color when the checkbox receives keyboard focus
- `hoverColor`: Color when hovering over the checkbox with a mouse

### Shape and Behavior Properties

- `side`: Border styling for the checkbox
- `shape`: Custom shape for the checkbox (e.g., rounded corners)
- `mouseCursor`: Cursor to display when hovering
- `materialTapTargetSize`: Minimum size of the checkbox touch target
- `visualDensity`: How compact the checkbox layout will be
- `splashRadius`: Radius of the checkbox ripple effect

### Table-Specific Properties

- `size`: Size (width and height) of the checkbox in logical pixels
- `showCheckboxColumn`: Whether to show the checkbox column
- `showSelectAllCheckbox`: Whether to show the select-all checkbox in the header
- `checkboxColumnWidth`: Width of the checkbox column

### Examples

#### Material 3 Style (Recommended)

```dart
theme: TablePlusTheme(
  checkboxTheme: TablePlusCheckboxTheme.material3(
    primaryColor: Colors.blue,
    size: 18.0,
  ),
),
```

#### Advanced Custom Styling

```dart
theme: TablePlusTheme(
  checkboxTheme: TablePlusCheckboxTheme(
    // Modern WidgetStateProperty approach
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.blue.withOpacity(0.38);
        }
        return Colors.blue;
      }
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.blue.withOpacity(0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return Colors.blue.withOpacity(0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return Colors.blue.withOpacity(0.12);
      }
      return Colors.transparent;
    }),
    
    // Traditional properties
    checkColor: Colors.white,
    side: BorderSide(color: Colors.blue.shade800, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    
    // Table-specific
    size: 20.0,
    checkboxColumnWidth: 65.0,
    showCheckboxColumn: true,
    showSelectAllCheckbox: true,
  ),
),
```

#### Legacy Style (For Backward Compatibility)


## 6. Scrollbar Styling (`TablePlusScrollbarTheme`)

This theme controls the appearance and behavior of the synchronized scrollbars.

- `trackWidth`: The width of the scrollbar track container.
- `thickness`: The thickness of the scrollbar thumb. If null, defaults to `trackWidth * 0.7`.
- `radius`: The corner radius of both track and thumb. If null, defaults to `trackWidth / 2`.
- `thumbColor`: The color of the scrollbar thumb (the part you drag).
- `trackColor`: The color of the scrollbar track background.
- `trackBorder`: Optional border styling for the scrollbar track using Flutter's `Border` class.
- `hoverOnly`: If `true`, the scrollbars will only be visible when the mouse is hovering over the table.
- `animationDuration`: The fade-in/out duration for the scrollbar when `hoverOnly` is true.
- **Dynamic Visibility**: Scrollbars are now dynamically shown or hidden based on content overflow, providing a cleaner UI when not needed.

### Example

```dart
scrollbarTheme: const TablePlusScrollbarTheme(
  trackWidth: 16.0,                    // Track container size
  thickness: 12.0,                     // Thumb size (or null for auto)
  radius: 8.0,                         // Corner rounding (or null for auto)
  thumbColor: Colors.blueGrey,         // Thumb color
  trackColor: Colors.grey.shade200,    // Track background
  trackBorder: Border.all(             // Optional track border
    color: Colors.grey.shade400,
    width: 1.0,
  ),
  hoverOnly: true,                     // Show only on hover
  animationDuration: Duration(milliseconds: 200),
),
```

## 7. Editable Cell Styling (`TablePlusEditableTheme`)

Controls the appearance of cells in editing mode. See `EDITING.md` for more details.

## 8. Tooltip Styling (`TablePlusTooltipTheme`)

Controls the appearance of tooltips that appear when cell content overflows. See `ADVANCED_COLUMNS.md` for more details.

## 9. Last Row Border Behavior (`lastRowBorderBehavior`)

The `lastRowBorderBehavior` property in `TablePlusBodyTheme` gives you fine-grained control over when the bottom border of the very last row in the table is displayed. This is useful for achieving a clean, polished look in different scenarios.

It takes a `LastRowBorderBehavior` enum with three possible values:

-   `LastRowBorderBehavior.never` (Default): The last row will never have a bottom border. This is the classic behavior.
-   `LastRowBorderBehavior.always`: The last row will always have a bottom border. This can be useful to create a clear boundary for the table.
-   `LastRowBorderBehavior.smart`: The border is shown or hidden based on whether the table content requires vertical scrolling.
    -   **If content fits (no scrollbar)**: The border is shown to provide a clean, enclosed look.
    -   **If content overflows (scrollbar is present)**: The border is hidden, indicating that there is more content to see.

### Example

```dart
theme: const TablePlusTheme(
  bodyTheme: TablePlusBodyTheme(
    // Other properties...
    showHorizontalDividers: true,
    dividerColor: Colors.grey.shade300,
    lastRowBorderBehavior: LastRowBorderBehavior.smart, // Use smart behavior
  ),
),
```
'''