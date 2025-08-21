# Hover Buttons

Flutter Table Plus now supports hover buttons that appear when users hover over table rows. This feature provides quick access to row-specific actions like edit and delete operations.

## Overview

Hover buttons are custom widgets that appear as overlays on table rows when the user hovers their mouse over them. They can be positioned on the left, center, or right side of the row and are fully themeable.

## Key Features

- **Hover Detection**: Buttons automatically appear/disappear on mouse enter/exit
- **Flexible Positioning**: Left, center, or right alignment with configurable offset
- **Theme Integration**: Full styling control through `TablePlusHoverButtonTheme`
- **Custom Builders**: Complete flexibility to create any button combination
- **Built-in Animations**: Smooth fade in/out transitions

## Basic Usage

### Simple Implementation

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  hoverButtonBuilder: (rowId, rowData) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _handleEdit(rowId, rowData),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _handleDelete(rowId, rowData),
      ),
    ],
  ),
)
```

### With Positioning

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  hoverButtonPosition: HoverButtonPosition.left, // or center, right
  hoverButtonBuilder: (rowId, rowData) => _buildActionButtons(rowId, rowData),
)
```

## Button Positioning

### HoverButtonPosition Enum

```dart
enum HoverButtonPosition {
  left,   // Buttons appear on the left side
  center, // Buttons appear in the center  
  right,  // Buttons appear on the right side (default)
}
```

### Position Behavior

- **Left**: Buttons are positioned from the left edge + horizontal offset
- **Center**: Buttons are centered in the row regardless of content
- **Right**: Buttons are positioned from the right edge - horizontal offset

## Theme Configuration

### TablePlusHoverButtonTheme

```dart
TablePlusHoverButtonTheme(
  backgroundColor: Colors.white,
  borderColor: Colors.grey.shade300,
  borderRadius: BorderRadius.circular(4),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ],
  padding: EdgeInsets.symmetric(horizontal: 4),
  iconSize: 16.0,
  iconColor: Colors.grey.shade600,
  spacing: 4.0,
  horizontalOffset: 8.0,
  showOnHover: true,
  animationDuration: Duration(milliseconds: 200),
  elevation: 0.0,
  opacity: 0.9,
  // Specific icon styling
  editIconData: Icons.edit,
  deleteIconData: Icons.delete,
  editIconColor: Colors.blue,
  deleteIconColor: Colors.red,
)
```

### Theme Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `backgroundColor` | `Color` | `Color(0xFFFFFFFF)` | Background color of button container |
| `borderColor` | `Color?` | `null` | Border color (null = no border) |
| `borderRadius` | `BorderRadius` | `BorderRadius.circular(4)` | Corner radius of container |
| `boxShadow` | `List<BoxShadow>` | Default shadow | Drop shadow configuration |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(horizontal: 4)` | Internal padding |
| `iconSize` | `double` | `16.0` | Size of button icons |
| `iconColor` | `Color?` | `null` | Default icon color |
| `spacing` | `double` | `4.0` | Space between buttons |
| `horizontalOffset` | `double` | `8.0` | Distance from row edge |
| `showOnHover` | `bool` | `true` | Whether to show only on hover |
| `animationDuration` | `Duration` | `Duration(milliseconds: 200)` | Fade animation duration |
| `elevation` | `double` | `0.0` | Material elevation |
| `opacity` | `double` | `0.9` | Container opacity |
| `editIconData` | `IconData` | `Icons.edit` | Default edit icon |
| `deleteIconData` | `IconData` | `Icons.delete` | Default delete icon |
| `editIconColor` | `Color?` | `null` | Edit icon color override |
| `deleteIconColor` | `Color?` | `null` | Delete icon color override |

## Advanced Examples

### Theme-Based Button Builder

```dart
Widget _buildThemeBasedButtons(String rowId, Map<String, dynamic> rowData) {
  final theme = _currentHoverButtonTheme;
  final List<Widget> buttons = [];

  // Add edit button
  buttons.add(
    IconButton(
      icon: Icon(
        theme.getEffectiveIconData('edit'),
        size: theme.iconSize,
        color: theme.getEffectiveIconColor('edit', context),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      onPressed: () => _handleEdit(rowId, rowData),
      tooltip: 'Edit',
    ),
  );

  // Add spacing
  buttons.add(SizedBox(width: theme.spacing));

  // Add delete button
  buttons.add(
    IconButton(
      icon: Icon(
        theme.getEffectiveIconData('delete'),
        size: theme.iconSize,
        color: theme.getEffectiveIconColor('delete', context),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      onPressed: () => _handleDelete(rowId, rowData),
      tooltip: 'Delete',
    ),
  );

  // Create styled container
  Widget container = Container(
    padding: theme.padding,
    decoration: BoxDecoration(
      color: theme.backgroundColor.withOpacity(theme.opacity),
      borderRadius: theme.borderRadius,
      border: theme.borderColor != null
          ? Border.all(color: theme.borderColor!)
          : null,
      boxShadow: theme.boxShadow,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    ),
  );

  // Apply elevation if specified
  if (theme.elevation > 0) {
    container = Material(
      elevation: theme.elevation,
      borderRadius: theme.borderRadius,
      color: Colors.transparent,
      child: container,
    );
  }

  return container;
}
```

### Custom Styled Buttons

```dart
hoverButtonBuilder: (rowId, rowData) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 6),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade400, Colors.blue.shade600],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => _handleEdit(rowId, rowData),
      ),
      Container(
        width: 1,
        height: 20,
        color: Colors.white.withOpacity(0.3),
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => _handleDelete(rowId, rowData),
      ),
    ],
  ),
)
```

### Conditional Button Display

```dart
hoverButtonBuilder: (rowId, rowData) {
  List<Widget> buttons = [];
  
  // Show edit button only for certain roles
  if (rowData['role'] != 'Admin') {
    buttons.add(
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _handleEdit(rowId, rowData),
      ),
    );
  }
  
  // Show delete button only for active users
  if (rowData['status'] == 'active') {
    if (buttons.isNotEmpty) {
      buttons.add(const SizedBox(width: 4));
    }
    buttons.add(
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _handleDelete(rowId, rowData),
      ),
    );
  }
  
  // Always show info button
  if (buttons.isNotEmpty) {
    buttons.add(const SizedBox(width: 4));
  }
  buttons.add(
    IconButton(
      icon: const Icon(Icons.info),
      onPressed: () => _showInfo(rowId, rowData),
    ),
  );
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    ),
  );
}
```

## Integration with Other Features

### With Selection

Hover buttons work seamlessly with row selection. The selection behavior is independent of hover button interactions.

```dart
FlutterTablePlus(
  columns: columns,
  data: data,
  isSelectable: true,
  selectionMode: SelectionMode.multiple,
  selectedRows: selectedRows,
  onRowSelectionChanged: (rowId) {
    setState(() {
      if (selectedRows.contains(rowId)) {
        selectedRows.remove(rowId);
      } else {
        selectedRows.add(rowId);
      }
    });
  },
  hoverButtonBuilder: (rowId, rowData) => _buildActionButtons(rowId, rowData),
)
```

### With Editing

Hover buttons can be used to trigger editing mode or perform actions on editable rows.

```dart
hoverButtonBuilder: (rowId, rowData) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(isEditing ? Icons.save : Icons.edit),
      onPressed: () => isEditing 
          ? _saveChanges(rowId, rowData)
          : _startEditing(rowId, rowData),
    ),
    if (isEditing)
      IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: () => _cancelEditing(rowId, rowData),
      ),
  ],
)
```

### With Merged Rows

Hover buttons are supported on merged rows and work with the expanded/collapsed state.

## Best Practices

### Performance

1. **Keep builders lightweight**: Avoid complex computations in the hover button builder
2. **Use const widgets**: Make icon buttons and containers const where possible
3. **Minimize rebuilds**: Use proper state management to avoid unnecessary rebuilds

### UX Guidelines

1. **Consistent positioning**: Use the same position across your application
2. **Clear icons**: Use universally understood icons (edit, delete, info)
3. **Appropriate spacing**: Maintain consistent spacing between buttons
4. **Subtle animations**: Keep animations smooth but not distracting

### Accessibility

1. **Tooltips**: Always provide tooltips for better accessibility
2. **Keyboard support**: Ensure buttons are keyboard accessible
3. **Screen readers**: Use semantic labels for assistive technologies

```dart
IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () => _handleEdit(rowId, rowData),
  tooltip: 'Edit ${rowData['name']}',
  semanticLabel: 'Edit employee ${rowData['name']}',
)
```

## Common Patterns

### Action Confirmation

```dart
void _handleDelete(String rowId, Map<String, dynamic> rowData) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete ${rowData['name']}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Perform delete action
            setState(() {
              data.removeWhere((item) => item['id'] == rowId);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${rowData['name']} deleted')),
            );
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

### Navigation Actions

```dart
hoverButtonBuilder: (rowId, rowData) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.visibility),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(id: rowId),
        ),
      ),
      tooltip: 'View Details',
    ),
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => Share.share('Check out ${rowData['name']}'),
      tooltip: 'Share',
    ),
  ],
)
```

## Troubleshooting

### Buttons Not Appearing

1. Ensure `hoverButtonBuilder` returns a non-null widget
2. Check that the row has a valid `rowId` (required for hover functionality)
3. Verify mouse hover is working (test on desktop/web)

### Positioning Issues

1. Adjust `horizontalOffset` in theme for better positioning
2. Consider row content width when using center positioning
3. Test with different table widths and column configurations

### Theme Not Applied

1. Ensure theme is passed to the table through `TablePlusTheme.hoverButtonTheme`
2. Check theme inheritance in custom builders
3. Verify theme methods like `getEffectiveIconColor` are used correctly

## Migration Guide

If upgrading from a version without hover buttons:

1. **No breaking changes**: Existing code will continue to work
2. **Optional feature**: Hover buttons are opt-in via `hoverButtonBuilder`
3. **Theme addition**: New theme class added to main `TablePlusTheme`

```dart
// Before - no changes needed
FlutterTablePlus(
  columns: columns,
  data: data,
)

// After - with hover buttons
FlutterTablePlus(
  columns: columns,
  data: data,
  hoverButtonBuilder: (rowId, rowData) => _buildButtons(rowId, rowData),
)
```