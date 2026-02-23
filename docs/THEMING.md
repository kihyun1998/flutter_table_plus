# Theming Guide

Complete reference for Flutter Table Plus theming system.

---

## Overview

Flutter Table Plus uses a composable theme system with **7 nested theme classes** (plus 3 header sub-themes):

```dart
TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(...),
  bodyTheme: TablePlusBodyTheme(...),
  checkboxTheme: TablePlusCheckboxTheme(...),
  editableTheme: TablePlusEditableTheme(...),
  scrollbarTheme: TablePlusScrollbarTheme(...),
  tooltipTheme: TablePlusTooltipTheme(...),
  hoverButtonTheme: TablePlusHoverButtonTheme(...),
)
```

---

## TablePlusHeaderTheme

Styling for the table header row. Uses nested sub-theme classes for borders, dividers, and resize handles.

```dart
TablePlusHeaderTheme(
  // Dimensions
  height: 56.0,

  // Colors
  backgroundColor: Colors.grey.shade100,
  sortedColumnBackgroundColor: Colors.blue.shade50,

  // Text
  textStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Colors.black87,
  ),
  sortedColumnTextStyle: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),

  // Padding
  padding: EdgeInsets.symmetric(horizontal: 16.0),

  // Decorations
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
  ),
  cellDecoration: BoxDecoration(
    border: Border(right: BorderSide(color: Colors.grey.shade200)),
  ),

  // Borders (nested theme classes)
  topBorder: TablePlusHeaderBorderTheme(show: false),   // hidden by default
  bottomBorder: TablePlusHeaderBorderTheme(show: true),  // visible by default
  verticalDivider: TablePlusHeaderDividerTheme(show: true),

  // Sort Icons
  sortIcons: SortIcons(
    ascending: Icon(Icons.arrow_upward, size: 16),
    descending: Icon(Icons.arrow_downward, size: 16),
    unsorted: Icon(Icons.unfold_more, size: 16),
  ),
  sortIconSpacing: 4.0,
  sortIconWidth: 16.0,

  // Resize Handle (nested theme class)
  resizeHandle: TablePlusResizeHandleTheme(),
)
```

### TablePlusHeaderBorderTheme

Controls top and bottom horizontal borders of the header.

```dart
TablePlusHeaderBorderTheme(
  show: true,                     // Whether to display this border
  color: Color(0xFFE0E0E0),      // Border color
  thickness: 1.0,                 // Border thickness in pixels
)
```

### TablePlusHeaderDividerTheme

Controls vertical dividers between header columns.

```dart
TablePlusHeaderDividerTheme(
  show: true,                     // Whether to display dividers
  color: Color(0xFFE0E0E0),      // Divider color
  thickness: 1.0,                 // Divider thickness
  indent: 0.0,                   // Top inset
  endIndent: 0.0,                // Bottom inset
)
```

### TablePlusResizeHandleTheme

Controls the column resize drag handle appearance.

```dart
TablePlusResizeHandleTheme(
  width: 8.0,          // Invisible hit-test area width
  color: null,         // Visible indicator color (null = theme default)
  thickness: 2.0,      // Visible indicator line thickness
  indent: 0.0,        // Top inset of indicator
  endIndent: 0.0,     // Bottom inset of indicator
)
```

---

## TablePlusBodyTheme

Styling for table body rows and cells.

```dart
TablePlusBodyTheme(
  // Dimensions
  rowHeight: 48.0,

  // Colors
  backgroundColor: Colors.white,
  alternateRowColor: Colors.grey.shade50,  // Striped rows
  summaryRowBackgroundColor: Colors.blue.shade50,

  // Text
  textStyle: TextStyle(fontSize: 14, color: Colors.black87),

  // Padding
  padding: EdgeInsets.symmetric(horizontal: 16.0),

  // Dividers
  dividerColor: Color(0xFFE0E0E0),
  dividerThickness: 1.0,
  showHorizontalDividers: true,
  showVerticalDividers: true,
  lastRowBorderBehavior: LastRowBorderBehavior.never,

  // Selection
  selectedRowColor: Color(0xFFE3F2FD),
  selectedRowTextStyle: TextStyle(fontWeight: FontWeight.w500),

  // Hover Effects (unselected rows)
  hoverColor: Colors.grey.shade100,
  splashColor: Colors.grey.shade200,
  highlightColor: Colors.grey.shade150,

  // Hover Effects (selected rows)
  selectedRowHoverColor: Colors.blue.shade200,
  selectedRowSplashColor: Colors.blue.shade300,
  selectedRowHighlightColor: Colors.blue.shade250,

  // Dim Rows (inactive/disabled)
  dimRowColor: Colors.grey.shade100,
  dimRowTextStyle: TextStyle(color: Colors.grey),
  dimRowHoverColor: Colors.grey.shade150,
  dimRowSplashColor: Colors.grey.shade200,
  dimRowHighlightColor: Colors.grey.shade175,

  // Double Click
  doubleClickTime: Duration(milliseconds: 500),
)
```

### LastRowBorderBehavior

```dart
// Never show bottom border on last row (default)
LastRowBorderBehavior.never

// Always show bottom border on last row
LastRowBorderBehavior.always

// Smart: show only when content fills viewport
LastRowBorderBehavior.smart
```

---

## TablePlusCheckboxTheme

Styling for selection checkboxes.

```dart
TablePlusCheckboxTheme(
  // Column visibility
  showCheckboxColumn: true,       // Show/hide entire checkbox column
  showSelectAllCheckbox: true,    // Show/hide header select-all checkbox
  showRowCheckbox: true,          // false = header checkbox only, no row checkboxes
  checkboxColumnWidth: 60.0,     // Width of checkbox column
  size: 18.0,                    // Visual checkbox size
  tapTargetSize: null,           // Hit-test area size (null = same as size)

  // Material 3 style (WidgetStateProperty)
  fillColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.blue;
    }
    return Colors.transparent;
  }),
  overlayColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.1)),

  // Legacy single colors
  checkColor: Colors.white,
  focusColor: Colors.blue.shade100,
  hoverColor: Colors.blue.shade50,

  // Shape
  side: BorderSide(color: Colors.grey, width: 2),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

  // Behavior
  mouseCursor: SystemMouseCursors.click,
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
  splashRadius: 20.0,
  cellTapTogglesCheckbox: false,  // true = entire cell area toggles checkbox
)
```

### Material 3 Factory

```dart
// Pre-configured Material 3 theme
TablePlusCheckboxTheme.material3(
  primaryColor: Colors.blue,
  size: 18.0,
  tapTargetSize: null,
  showCheckboxColumn: true,
  showSelectAllCheckbox: true,
  showRowCheckbox: true,
  checkboxColumnWidth: 60.0,
  cellTapTogglesCheckbox: false,
)
```

---

## TablePlusEditableTheme

Styling for cell editing mode.

```dart
TablePlusEditableTheme(
  // Cell appearance while editing
  editingCellColor: Colors.yellow.shade100,
  editingBorderColor: Colors.blue,
  editingBorderWidth: 2.0,
  editingBorderRadius: BorderRadius.circular(4),

  // Text field
  editingTextStyle: TextStyle(fontSize: 14),
  hintStyle: TextStyle(color: Colors.grey),
  cursorColor: Colors.blue,
  textAlignVertical: TextAlignVertical.center,

  // Padding
  textFieldPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  cellContainerPadding: EdgeInsets.all(8.0),

  // Input decoration
  focusedBorderColor: Colors.blue,     // null = uses editingBorderColor
  enabledBorderColor: Colors.grey,     // null = lighter editingBorderColor
  borderRadius: BorderRadius.circular(4),  // null = uses editingBorderRadius
  fillColor: Colors.white,            // null = uses editingCellColor
  filled: false,
  isDense: true,
)
```

---

## TablePlusScrollbarTheme

Styling for scrollbars.

```dart
TablePlusScrollbarTheme(
  // Visibility
  showVertical: true,
  showHorizontal: true,
  hoverOnly: false,  // Show only on hover

  // Dimensions
  trackWidth: 12.0,
  thickness: null,   // null = trackWidth * 0.7
  radius: null,      // null = trackWidth / 2

  // Colors
  thumbColor: Color(0xFF757575),
  trackColor: Color(0xFFE0E0E0),
  trackBorder: null,

  // Animation
  opacity: 1.0,
  animationDuration: Duration(milliseconds: 300),
)
```

---

## TablePlusTooltipTheme

Styling for text tooltips.

```dart
TablePlusTooltipTheme(
  enabled: true,

  // Timing
  waitDuration: Duration(milliseconds: 500),
  showDuration: Duration(seconds: 2),
  exitDuration: Duration(milliseconds: 100),

  // Appearance
  decoration: BoxDecoration(
    color: Color(0xFF424242),
    borderRadius: BorderRadius.circular(4),
  ),
  textStyle: TextStyle(color: Colors.white, fontSize: 12),
  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  margin: EdgeInsets.zero,

  // Position
  preferBelow: true,
  verticalOffset: 24.0,

  // Widget tooltips (tooltipBuilder)
  customWrapper: CustomTooltipWrapperTheme(
    maxWidth: 300.0,
    spacingPadding: 8.0,
    horizontalPadding: 8.0,
    minSpace: 100.0,
    minScrollHeight: 80.0,
    estimatedHeight: 150.0,
  ),
)
```

---

## TablePlusHoverButtonTheme

Styling for hover action buttons.

```dart
TablePlusHoverButtonTheme(
  horizontalOffset: 8.0,  // Distance from row edge
)
```

---

## Complete Example

```dart
FlutterTablePlus<User>(
  theme: TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      height: 56,
      backgroundColor: Colors.indigo.shade50,
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.indigo.shade900,
      ),
      bottomBorder: TablePlusHeaderBorderTheme(
        color: Colors.indigo.shade200,
        thickness: 2,
      ),
      verticalDivider: TablePlusHeaderDividerTheme(
        color: Colors.indigo.shade100,
      ),
    ),
    bodyTheme: TablePlusBodyTheme(
      rowHeight: 52,
      backgroundColor: Colors.white,
      alternateRowColor: Colors.indigo.shade50.withOpacity(0.3),
      selectedRowColor: Colors.indigo.shade100,
      hoverColor: Colors.indigo.shade50,
      textStyle: TextStyle(fontSize: 14),
      showHorizontalDividers: true,
      dividerColor: Colors.grey.shade200,
    ),
    checkboxTheme: TablePlusCheckboxTheme.material3(
      primaryColor: Colors.indigo,
    ),
    editableTheme: TablePlusEditableTheme(
      editingCellColor: Colors.yellow.shade50,
      editingBorderColor: Colors.indigo,
    ),
    scrollbarTheme: TablePlusScrollbarTheme(
      thumbColor: Colors.indigo.shade300,
      trackColor: Colors.indigo.shade50,
    ),
    tooltipTheme: TablePlusTooltipTheme(
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: Colors.white),
    ),
  ),
)
```

---

## Dark Theme Example

```dart
TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(
    backgroundColor: Color(0xFF1E1E1E),
    textStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    bottomBorder: TablePlusHeaderBorderTheme(color: Colors.grey.shade800),
    verticalDivider: TablePlusHeaderDividerTheme(color: Colors.grey.shade800),
  ),
  bodyTheme: TablePlusBodyTheme(
    backgroundColor: Color(0xFF121212),
    alternateRowColor: Color(0xFF1A1A1A),
    textStyle: TextStyle(color: Colors.white70),
    selectedRowColor: Colors.blue.shade900,
    hoverColor: Color(0xFF2A2A2A),
    dividerColor: Colors.grey.shade800,
  ),
  scrollbarTheme: TablePlusScrollbarTheme(
    thumbColor: Colors.grey.shade600,
    trackColor: Color(0xFF1E1E1E),
  ),
)
```

---

## Inheriting from App Theme

```dart
FlutterTablePlus<User>(
  theme: TablePlusTheme(
    headerTheme: TablePlusHeaderTheme(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      textStyle: Theme.of(context).textTheme.titleSmall,
    ),
    bodyTheme: TablePlusBodyTheme(
      backgroundColor: Theme.of(context).colorScheme.surface,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      selectedRowColor: Theme.of(context).colorScheme.primaryContainer,
    ),
  ),
)
```
