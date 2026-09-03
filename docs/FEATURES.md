# Features Guide

Complete guide to all Flutter Table Plus features.

---

## Table of Contents

- [Sorting](#sorting)
- [Selection](#selection)
- [Cell Editing](#cell-editing)
- [Column Reordering](#column-reordering)
- [Column Resizing](#column-resizing)
- [Drag Selection](#drag-selection)
- [Merged Rows](#merged-rows)
- [Hover Buttons](#hover-buttons)
- [Dynamic Row Heights](#dynamic-row-heights)
- [Tooltips](#tooltips)
  - [Row Tooltips](#row-tooltips)
- [Dim Rows](#dim-rows)
- [Empty State](#empty-state)
- [Context Menu (Right-Click)](#context-menu)
- [Scale / Zoom](#scale--zoom)

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
        // A new list, not an in-place sort: `data` is invalidated on the
        // list's identity, so `_users.sort(...)` would not be seen.
        _users = List.of(_users)..sort((a, b) {
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

**The `{rowId}` below is required, not stylistic.** `selectedRows` is your set
and the table never writes to it, so `SelectionMode.single` does not clear the
previous row for you — replace the set on every change, or you get
multi-selection wearing a single-select label. The mode's own effect is
narrower: drag-to-select is wired only in `SelectionMode.multiple`.

```dart
FlutterTablePlus<User>(
  isSelectable: true,
  selectionMode: SelectionMode.single,
  selectedRows: _selectedRowIds,
  onRowSelectionChanged: (rowId, isSelected) {
    // Replace, never add — this line is what makes `single` mean single.
    setState(() {
      _selectedRowIds = isSelected ? {rowId} : {};
    });
  },
)
```

### Hide Select-All Checkbox

The header draws its select-all checkbox when `showSelectAllCheckbox` is true
**and** `onSelectAll` is non-null. It does not consult `selectionMode`, so a
single-selection table still shows a working select-all until you withhold one
of the two — usually the callback, since that is what the button would call.

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
      // A new list, as with the sort above: an in-place
      // `_users[rowIndex] = ...` renders the new value but keeps the cached
      // row height.
      switch (columnKey) {
        case 'name':
          _users = List.of(_users)..[rowIndex] = row.copyWith(name: newValue as String);
          break;
        case 'email':
          _users = List.of(_users)..[rowIndex] = row.copyWith(email: newValue as String);
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
      // Both indices count the columns *as displayed*: sorted by `order`,
      // invisible ones dropped, selection column excluded. Sort before
      // indexing — a Map's own iteration order agrees only by coincidence.
      final entries = _columns.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));

      final item = entries.removeAt(oldIndex);
      entries.insert(newIndex, item);

      // Renumber from 1: `TableColumnsBuilder` reserves 0 and below, and the
      // synthetic selection column sits at -1.
      _columns = {
        for (var i = 0; i < entries.length; i++)
          entries[i].key: entries[i].value.copyWith(order: i + 1),
      };
    });
  },
)

// Disable reordering — there is no separate flag
onColumnReorder: null,
```

---

## Column Resizing

Drag header edges to resize columns with min/max constraints.

```dart
FlutterTablePlus<User>(
  resizable: true,

  onColumnResized: (String columnKey, double newWidth) {
    // Persist the new width
    setState(() {
      _columnWidths[columnKey] = newWidth;
    });
  },

  // Per-column constraints
  columns: {
    'name': TablePlusColumn<User>(
      key: 'name',
      label: 'Name',
      order: 1,
      valueAccessor: (user) => user.name,
      width: 150,
      minWidth: 80,
      maxWidth: 300,
    ),
  },
)
```

### Width Persistence

Save column widths with `onColumnResized` and restore them with `initialResizedWidths`:

```dart
FlutterTablePlus<User>(
  resizable: true,

  // Restore saved widths on widget creation.
  // Columns in this map are treated as fixed (exact pixel width),
  // just as if the user had manually resized them.
  initialResizedWidths: prefs.getSavedColumnWidths(),

  // Save each resize to your persistence layer.
  // Fires on manual drag end and auto-fit double-tap.
  onColumnResized: (columnKey, newWidth) {
    prefs.saveColumnWidth(columnKey, newWidth);
  },
)
```

> **Note:** `initialResizedWidths` is read at widget creation and **re-adopted
> whenever the map changes by value** — it is not a one-shot despite the name.
> That is what makes the loop above work: store what `onColumnResized` hands
> back, pass it down on the next build. An unchanged map leaves the table's own
> state alone, so a rebuild never interrupts a resize in progress.
> Columns not in the map remain flexible and participate in proportional distribution.

> **Every width here is logical (unscaled) pixels — including the bounds.**
>
> `onColumnResized` reports the width the column would have at `scale: 1.0`, not
> the pixels the drag covered, and `initialResizedWidths` is read the same way —
> so a stored width still means the same thing when the app reopens at a
> different zoom. `minWidth` and `maxWidth` are declared in the same space and
> the table converts them itself, so a column stops at the range you wrote at
> every zoom level, not at a range scaled along with it. (Before 2.17.0 the drag
> path did not convert them, so at `scale: 2.0` a declared `maxWidth: 300`
> behaved as 150.)

### Auto-Fit (Double-Tap)

Double-tap a resize handle to auto-fit the column width to its content. By default, the built-in measurement uses `valueAccessor` + body theme `textStyle`.

For columns with `statefulCellBuilder` that use custom styles, padding, or text transformations, override the measurement with `autoFitColumnWidth`:

```dart
FlutterTablePlus<User>(
  resizable: true,
  autoFitColumnWidth: (columnKey) {
    if (columnKey == 'description') {
      return TableColumnWidthCalculator.calculateColumnWidth<User>(
        headerLabel: 'Description',
        headerTextStyle: myHeaderStyle,
        data: users,
        valueAccessor: (user) => user.description.replaceAll('\n', ' '),
        bodyTextStyle: myCustomBodyStyle,
        bodyPadding: EdgeInsets.symmetric(horizontal: 24.0),
        textScaler: MediaQuery.textScalerOf(context),
      );
    }
    return null; // Other columns use default auto-fit
  },
)
```

You can also measure a single text value directly:

```dart
final width = TableColumnWidthCalculator.measureTextWidth(
  text: 'Hello World',
  textStyle: TextStyle(fontSize: 14),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  extraWidth: 24.0, // e.g., icon space
);
```

### Resize Handle Styling

```dart
TablePlusTheme(
  headerTheme: TablePlusHeaderTheme(
    resizeHandle: TablePlusResizeHandleTheme(
      width: 8.0,        // Hit-test area width
      thickness: 2.0,    // Visible indicator thickness
      color: Colors.blue, // Indicator color
      indent: 4.0,       // Top inset
      endIndent: 4.0,    // Bottom inset
    ),
  ),
)
```

---

## Drag Selection

Mouse drag to select row ranges (Excel/Finder style).

**Every line below marked required is required.** Drag selection wires no
handler at all unless all four hold, and when one is missing the feature is
inert rather than broken — no error, no warning, dragging simply does nothing.
Passing only `onDragSelectionEnd` is the usual way to hit this.

```dart
FlutterTablePlus<User>(
  isSelectable: true,                     // required
  selectionMode: SelectionMode.multiple,  // required — single mode never drags
  selectedRows: _selectedRowIds,
  enableDragSelection: true,              // required

  // required — without this callback no drag is detected at all
  onDragSelectionUpdate: (Set<String> draggedRowIds) {
    setState(() {
      _selectedRowIds = draggedRowIds;
    });
  },

  // optional — if omitted, onDragSelectionUpdate is also the final callback
  onDragSelectionEnd: (Set<String> draggedRowIds) {
    // Finalize selection
  },
)
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
  // Adds the summary row. It does not hide the member rows.
  isExpanded: _expandedGroups.contains('group_1'),
  summaryBuilder: (columnKey) => columnKey == 'notes'
      ? const Text('Total', style: TextStyle(fontWeight: FontWeight.w700))
      : null,
)

// Handle merged cell edits
onMergedCellChanged: (String groupId, String columnKey, dynamic newValue) {
  // Update your data
},
```

**The expand control is yours to draw.** The package renders no
expand/collapse affordance anywhere and fires no callback for one — put an
`IconButton` in the merged cell's `mergedContent` and wire it to your own
`setState`:

```dart
'department': MergeCellConfig(
  shouldMerge: true,
  mergedContent: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () => setState(() { /* toggle your own state */ }),
      ),
      Text(department),
    ],
  ),
),
```

A `MergedRowGroup` is an immutable value you rebuild, so the state has to
live where your data does. `example/lib/recipes/merged_rows_recipe.dart` is
a complete working version.

> **Changed in 2.17.0.** `onMergedRowExpandToggle` and `isExpandable` were
> removed. The callback was declared, threaded through three widgets and
> never invoked — this document showed it as working, which is the reason it
> went unnoticed. `isExpandable` was an extra `&&` in front of `isExpanded`
> and gated nothing on its own. Delete both arguments; nothing else changes.

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
// Build it ONCE and hold it in a field — see the two notes below.
_rowHeight = TableRowHeightCalculator.createHeightCalculator(
  columns: columnsList,
  columnWidths: columnsList.map((c) => c.width).toList(),
  defaultTextStyle: TextStyle(fontSize: 14),
  minHeight: 48.0,
  // Resolves the ambient DefaultTextStyle and MediaQuery.textScalerOf, which
  // are what the glyphs actually get. Without it the measurement is of a
  // different string than the one on screen.
  context: context,
);

FlutterTablePlus<User>(
  calculateRowHeight: _rowHeight,
)
```

> **Pass `context`.** A `TextPainter` sees only the style you hand it. The `Text`
> in the cell merges the inherited `DefaultTextStyle` under it — that is where
> the font family, `letterSpacing` and `height` come from when your style does
> not name them — and applies `MediaQuery.textScalerOf`. Measured on the default
> theme: a style naming only `fontSize` predicts **100px** for a paragraph the
> screen lays out at **120px**, and at an OS text scale of 1.25 it needs **225px**
> against the same prediction. The text is clipped and nothing warns you.

> **Do not build it inline in the widget's constructor.** The height caches — and
> the row geometry every drag hit-test is answered from — drop whenever this
> callback is not equal to the previous one, and a closure built fresh in `build`
> never is. Measured: two calls with identical arguments return callbacks that
> compare `!=`, so the inline form re-measures every row on every frame. Hold it
> in a field and rebuild it in `didChangeDependencies`, which is also exactly
> when the ambient inputs above can have changed.

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

### Row Tooltips

A card shown while the pointer is anywhere on the row — not just over a cell's text. It is anchored beside the pointer, so it stays where you are looking even on a table wide enough to scroll horizontally.

```dart
FlutterTablePlus<User>(
  // ...
  rowTooltipBuilder: (context, user) {
    if (!user.hasProfile) return null;   // this row gets no card
    return AccountCard(user);
  },
  theme: TablePlusTheme(
    // A card draws its own surface, so the tooltip must not draw one behind it.
    rowTooltipTheme: TablePlusTooltipTheme(
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0,
    ),
  ),
)
```

When a cell under the pointer has a tooltip of its own, that one wins — exactly one tooltip is ever visible. So a truncated cell still reveals its full text, while the rest of the row shows the card.

The whole row is the hover region, including the empty space past the last column and cells whose value is empty. A cell only takes the card's place when it has a tooltip to put there: `tooltipBehavior: TooltipBehavior.always` gives every ellipsized text column one whether or not its text is cut, which leaves the card nowhere to appear. Use `TooltipBehavior.onlyTextOverflow` on the text columns of a table that shows a card.

A `tooltipFormatter` returning an empty string means "no tooltip on this cell", so the card shows there too. A `tooltipBuilder` returning an invisible widget does not: a widget tooltip is always taken to have content, and it wins.

Merged rows stand for several data rows, so there is no single `rowData` to build from. They carry no card.

`rowTooltipTheme` falls back to `tooltipTheme` when omitted.

> **A row card and `TooltipBehavior.always` do not mix.** `always` shows a text tooltip on every ellipsized column whether or not its text is actually cut — and ellipsis is the default. Since the cell's tooltip wins, the card would surface nowhere. Give your text columns `tooltipBehavior: TooltipBehavior.onlyTextOverflow` alongside a row card, so a text tooltip appears only when it has something to add.

### Tooltip Behavior

```dart
// Per-column cell tooltip behavior
tooltipBehavior: TooltipBehavior.always,            // Whenever the column is ellipsized — even if the text is not actually cut
tooltipBehavior: TooltipBehavior.never,             // Never show
tooltipBehavior: TooltipBehavior.onlyTextOverflow,  // Only when the text is actually truncated

// Per-column header tooltip behavior
headerTooltipBehavior: TooltipBehavior.always,
headerTooltipBehavior: TooltipBehavior.onlyTextOverflow,
```

### Styling

```dart
TablePlusTheme(
  tooltipTheme: TablePlusTooltipTheme(
    enabled: true,
    waitDuration: Duration(milliseconds: 500),
    showDuration: Duration(seconds: 2),
    backgroundColor: Color(0xFF616161),
    borderRadius: BorderRadius.circular(6),
    textStyle: TextStyle(color: Colors.white),
    direction: TooltipDirection.bottom,
    showArrow: true,
    offset: 8.0,
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

---

## Scale / Zoom

Scale the entire table by a factor — all dimensions (column widths, row heights, font sizes, padding, icons) are multiplied.

### Basic Usage

```dart
double _scale = 1.0;

FlutterTablePlus<User>(
  columns: columns,
  data: users,
  rowId: (user) => user.id,
  scale: _scale,
)
```

### Ctrl+Wheel Zoom

Provide `onScaleChanged` to enable Ctrl+wheel (Cmd+wheel on macOS) zoom with automatic scroll prevention.

```dart
FlutterTablePlus<User>(
  columns: columns,
  data: users,
  rowId: (user) => user.id,
  scale: _scale,
  onScaleChanged: (newScale) {
    setState(() {
      _scale = newScale.clamp(0.5, 3.0);  // You control the limits
    });
  },
  scaleStep: 0.05,  // Increment per wheel tick (default 0.05)
)
```

When `onScaleChanged` is non-null:
- Ctrl+wheel events are intercepted internally
- Scrolling is blocked via custom `ScrollPhysics` (`shouldAcceptUserOffset` returns `false` when Ctrl is held)
- Scroll positions are automatically corrected to keep the same content visible

### What Gets Scaled

| Scaled | Not Scaled |
|--------|------------|
| Row height | Scrollbar (UI chrome) |
| Column widths | Colors, booleans |
| Font sizes | Border/divider thickness |
| Padding | Tooltip (overlay) |
| Sort icon size (via FittedBox) | Duration values |
| Resize handle | |
| Checkbox, via `CheckboxStyle.scale` | |
| The selection column's width | |
| `minWidth` / `maxWidth` (converted before they bound a drag) | |

### Column Width Persistence

Resized widths are stored in **logical (unscaled) units**. The `onColumnResized` callback always reports logical widths, and `initialResizedWidths` expects logical widths. This means saved widths work correctly regardless of the current scale.

`minWidth` and `maxWidth` are declared in the same units and travel the other way — the table multiplies them by `scale` before they bound a drag measured on screen. So the range a column stops at is the range you wrote, not a range scaled along with the zoom. (Fixed in 2.17.0; from 2.9.0 to 2.16.1 the drag path compared them unconverted, so at `scale: 2.0` a declared `maxWidth: 300` behaved as 150.)

> **One caveat on the reported number.** Multiplying by `scale` and dividing back is exact for most factors but not all — at a scale accumulated by repeated Ctrl+wheel steps, `onColumnResized` can report a width outside the declared bound by around 1e-14. Layout re-clamps in logical space and is never outside it. Compare with a tolerance if you assert on the callback's value.

```dart
FlutterTablePlus<User>(
  scale: _scale,
  resizable: true,
  initialResizedWidths: savedWidths,  // Logical units — scale-independent
  onColumnResized: (columnKey, newWidth) {
    // newWidth is in logical units, safe to persist
    savedWidths[columnKey] = newWidth;
  },
)
```

### Notes

- `scale` must be greater than zero (`assert(scale > 0)`)
- No min/max is enforced by the library — the caller clamps in `onScaleChanged`
- The checkbox scales visually through `CheckboxStyle.scale`. Every other `CheckboxStyle` field is carried through untouched — this bullet used to say the opposite, describing the Material `Checkbox` that 2.10.0 replaced
- Custom sort icons are automatically scaled via `FittedBox` to match the scaled `sortIconWidth`
