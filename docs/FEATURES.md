# Features Guide

Complete guide to all Flutter Table Plus features.

---

## Table of Contents

- [Sorting](#sorting)
- [Selection](#selection)
- [Cell Editing](#cell-editing)
- [Column Reordering](#column-reordering)
- [Merged Rows](#merged-rows)
- [Hover Buttons](#hover-buttons)
- [Dynamic Row Heights](#dynamic-row-heights)
- [Tooltips](#tooltips)
- [Dim Rows](#dim-rows)
- [Empty State](#empty-state)
- [Context Menu (Right-Click)](#context-menu)

---

## Sorting

Enable column sorting with customizable sort cycles.

### Basic Usage

```dart
// 1. Make columns sortable
TablePlusColumn<User>(
  key: 'name',
  label: 'Name',
  order: 1,
  valueAccessor: (user) => user.name,
  sortable: true,  // Enable sorting for this column
)

// 2. Handle sort events
FlutterTablePlus<User>(
  columns: columns,
  data: users,
  rowId: (user) => user.id,

  sortColumnKey: _sortColumn,
  sortDirection: _sortDirection,
  onSort: (columnKey, direction) {
    setState(() {
      _sortColumn = columnKey;
      _sortDirection = direction;

      if (direction == SortDirection.none) {
        _users = List.of(_originalUsers);  // Reset to original order
      } else {
        _users.sort((a, b) {
          final aVal = _getColumnValue(a, columnKey);
          final bVal = _getColumnValue(b, columnKey);
          final cmp = aVal.compareTo(bVal);
          return direction == SortDirection.ascending ? cmp : -cmp;
        });
      }
    });
  },
)
```

### Sort Cycle Order

```dart
// Default: none → ascending → descending → none
sortCycleOrder: SortCycleOrder.ascendingFirst,

// Alternative: none → descending → ascending → none
sortCycleOrder: SortCycleOrder.descendingFirst,
```

### Custom Sort Icons

```dart
TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(
    sortIcons: SortIcons(
      ascending: Icon(Icons.arrow_upward, size: 16),
      descending: Icon(Icons.arrow_downward, size: 16),
      unsorted: Icon(Icons.unfold_more, size: 16),
    ),
  ),
)
```

### Disable Sorting

```dart
// Hide all sort UI
onSort: null,

// Or disable per column
TablePlusColumn(sortable: false)
```

---

## Selection

Support for single and multiple row selection.

### Multiple Selection

```dart
FlutterTablePlus<User>(
  isSelectable: true,
  selectionMode: SelectionMode.multiple,
  selectedRows: _selectedRowIds,  // Set<String>

  // Row click selection
  onRowSelectionChanged: (rowId, isSelected) {
    setState(() {
      isSelected ? _selectedRowIds.add(rowId) : _selectedRowIds.remove(rowId);
    });
  },

  // Checkbox click (same behavior, different trigger)
  onCheckboxChanged: (rowId, isSelected) {
    setState(() {
      isSelected ? _selectedRowIds.add(rowId) : _selectedRowIds.remove(rowId);
    });
  },

  // Select-all checkbox in header
  onSelectAll: (selectAll) {
    setState(() {
      _selectedRowIds = selectAll
        ? _users.map((u) => u.id).toSet()
        : {};
    });
  },
)
```

### Single Selection

```dart
FlutterTablePlus<User>(
  isSelectable: true,
  selectionMode: SelectionMode.single,  // Only one row at a time
  selectedRows: _selectedRowIds,
  onRowSelectionChanged: (rowId, isSelected) {
    setState(() {
      _selectedRowIds = isSelected ? {rowId} : {};
    });
  },
)
```

### Hide Select-All Checkbox

```dart
// Set onSelectAll to null to hide the select-all checkbox
onSelectAll: null,
```

### Hide Checkbox Column

```dart
TablePlusTheme(
  checkboxTheme: TablePlusCheckboxTheme(
    showCheckboxColumn: false,  // Use row click only
  ),
)
```

### Header Checkbox Only (No Row Checkboxes)

```dart
TablePlusTheme(
  checkboxTheme: TablePlusCheckboxTheme(
    showRowCheckbox: false,  // Header select-all visible, row checkboxes hidden
  ),
)
```

---

## Cell Editing

Enable inline cell editing with auto-save.

### Basic Usage

```dart
// 1. Enable editing globally and per column
FlutterTablePlus<User>(
  isEditable: true,
  columns: {
    'name': TablePlusColumn(
      key: 'name',
      label: 'Name',
      order: 1,
      valueAccessor: (user) => user.name,
      editable: true,  // Enable editing for this column
      hintText: 'Enter name',  // Placeholder text
    ),
  },

  // 2. Handle cell changes
  onCellChanged: (User row, String columnKey, int rowIndex, dynamic oldValue, dynamic newValue) {
    setState(() {
      switch (columnKey) {
        case 'name':
          _users[rowIndex] = row.copyWith(name: newValue as String);
          break;
        case 'email':
          _users[rowIndex] = row.copyWith(email: newValue as String);
          break;
      }
    });
  },
)
```

### Editing Behavior

- **Click** a cell to start editing
- **Enter** to save and exit
- **Escape** to cancel
- **Tab** / focus loss auto-saves
- Cells with `statefulCellBuilder` cannot be edited

### Styling

```dart
TablePlusTheme(
  editableTheme: TablePlusEditableTheme(
    editingCellColor: Colors.yellow.shade100,
    editingBorderColor: Colors.blue,
    editingBorderWidth: 2.0,
    editingBorderRadius: BorderRadius.circular(4),
    cursorColor: Colors.blue,
  ),
)
```

---

## Column Reordering

Drag-and-drop to reorder columns.

```dart
FlutterTablePlus<User>(
  onColumnReorder: (int oldIndex, int newIndex) {
    setState(() {
      final entries = _columns.entries.toList();
      final item = entries.removeAt(oldIndex);
      entries.insert(newIndex, item);

      // Update order values
      _columns = Map.fromEntries(
        entries.asMap().entries.map((e) => MapEntry(
          e.value.key,
          e.value.value.copyWith(order: e.key),
        )),
      );
    });
  },
)

// Disable reordering
onColumnReorder: null,
```

---

## Merged Rows

Group multiple rows with merged cells.

### Basic Usage

```dart
FlutterTablePlus<User>(
  data: users,
  rowId: (user) => user.id,

  mergedGroups: [
    MergedRowGroup<User>(
      groupId: 'engineering-team',
      rowKeys: ['user-1', 'user-2', 'user-3'],  // Row IDs to merge
      mergeConfig: {
        'department': MergeCellConfig(
          shouldMerge: true,
          mergedContent: Text(
            'Engineering',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      },
    ),
  ],
)
```

### Advanced Configuration

```dart
MergedRowGroup<User>(
  groupId: 'sales-team',
  rowKeys: ['user-4', 'user-5'],
  mergeConfig: {
    // Show first row's data in merged cell
    'name': MergeCellConfig(
      shouldMerge: true,
      spanningRowIndex: 0,  // Use first row's value
    ),
    // Custom widget
    'status': MergeCellConfig(
      shouldMerge: true,
      mergedContent: Icon(Icons.group, color: Colors.blue),
    ),
    // Editable merged cell
    'notes': MergeCellConfig(
      shouldMerge: true,
      isEditable: true,
    ),
  },
  isExpandable: true,
  isExpanded: true,
)

// Handle merged cell edits
onMergedCellChanged: (String groupId, String columnKey, dynamic newValue) {
  // Update your data
},

// Handle expand/collapse
onMergedRowExpandToggle: (String groupId) {
  setState(() {
    // Toggle expand state
  });
},
```

---

## Hover Buttons

Action buttons that appear when hovering a row.

```dart
FlutterTablePlus<User>(
  hoverButtonBuilder: (String rowId, User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, size: 18),
          onPressed: () => _editUser(user),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: Icon(Icons.delete, size: 18, color: Colors.red),
          onPressed: () => _deleteUser(user.id),
          tooltip: 'Delete',
        ),
      ],
    );
  },
  hoverButtonPosition: HoverButtonPosition.right,  // left, center, right
)
```

### Theming

```dart
TablePlusTheme(
  hoverButtonTheme: TablePlusHoverButtonTheme(
    horizontalOffset: 8.0,
  ),
)
```

---

## Dynamic Row Heights

Support variable height rows based on content.

### Using TableRowHeightCalculator

```dart
FlutterTablePlus<User>(
  calculateRowHeight: TableRowHeightCalculator.createHeightCalculator(
    columns: columnsList,
    columnWidths: columnsList.map((c) => c.width).toList(),
    defaultTextStyle: TextStyle(fontSize: 14),
    minHeight: 48.0,
  ),
)
```

### Custom Height Function

```dart
FlutterTablePlus<User>(
  calculateRowHeight: (int rowIndex, User user) {
    // Taller rows for longer content
    if (user.bio.length > 100) {
      return 80.0;
    }
    return null;  // Use default height
  },
)
```

### For TextOverflow.visible Columns

```dart
TablePlusColumn<User>(
  key: 'description',
  label: 'Description',
  order: 1,
  valueAccessor: (user) => user.description,
  textOverflow: TextOverflow.visible,  // Allow text to expand
)

// Then use TableRowHeightCalculator to auto-calculate heights
```

---

## Tooltips

Text or widget-based tooltips with smart positioning.

### Text Tooltips

```dart
TablePlusColumn<User>(
  key: 'name',
  label: 'Name',
  order: 1,
  valueAccessor: (user) => user.name,
  tooltipFormatter: (user) => 'Employee: ${user.name}\nDepartment: ${user.department}',
  tooltipBehavior: TooltipBehavior.always,
)
```

### Widget Tooltips

```dart
TablePlusColumn<User>(
  key: 'profile',
  label: 'Profile',
  order: 1,
  valueAccessor: (user) => user.name,
  tooltipBuilder: (context, user) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
          SizedBox(height: 8),
          Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(user.email),
        ],
      ),
    );
  },
)
```

### Tooltip Behavior

```dart
tooltipBehavior: TooltipBehavior.always,         // Always show tooltip
tooltipBehavior: TooltipBehavior.never,          // Never show
tooltipBehavior: TooltipBehavior.onlyTextOverflow,  // Only when text is truncated

// Also for headers
headerTooltipBehavior: TooltipBehavior.always,
```

### Styling

```dart
TablePlusTheme(
  tooltip: TablePlusTooltipTheme(
    enabled: true,
    waitDuration: Duration(milliseconds: 500),
    showDuration: Duration(seconds: 2),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: TextStyle(color: Colors.white),
  ),
)
```

---

## Dim Rows

Style inactive or disabled rows differently.

```dart
FlutterTablePlus<User>(
  isDimRow: (User user) => !user.isActive,  // Dim inactive users

  theme: TablePlusTheme(
    bodyTheme: TablePlusBodyTheme(
      dimRowColor: Colors.grey.shade200,
      dimRowTextStyle: TextStyle(color: Colors.grey),
      dimRowHoverColor: Colors.grey.shade300,
    ),
  ),
)
```

---

## Empty State

Custom widget when there's no data.

```dart
FlutterTablePlus<User>(
  data: [],  // Empty list
  noDataWidget: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
      SizedBox(height: 12),
      Text('No data available', style: TextStyle(fontSize: 18)),
      SizedBox(height: 8),
      ElevatedButton(
        onPressed: _loadData,
        child: Text('Refresh'),
      ),
    ],
  ),
)
```

---

## Context Menu

Right-click context menu support.

```dart
FlutterTablePlus<User>(
  onRowSecondaryTapDown: (
    String rowId,
    TapDownDetails details,
    RenderBox renderBox,
    bool isSelected,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(details.localPosition, ancestor: overlay),
        renderBox.localToGlobal(details.localPosition, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(value: 'view', child: Text('View')),
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      switch (value) {
        case 'view': _viewUser(rowId); break;
        case 'edit': _editUser(rowId); break;
        case 'delete': _deleteUser(rowId); break;
      }
    });
  },
)
```

---

## Double-Click

Handle double-click on rows.

```dart
FlutterTablePlus<User>(
  onRowDoubleTap: (String rowId) {
    _openDetailView(rowId);
  },

  theme: TablePlusTheme(
    bodyTheme: TablePlusBodyTheme(
      doubleClickTime: Duration(milliseconds: 500),  // Adjust timing
    ),
  ),
)
```
