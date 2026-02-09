## 2.3.1

*   **BREAKING**: Extracted `TablePlusResizeHandleTheme` from flat fields on `TablePlusHeaderTheme`
    *   Removed `resizeHandleWidth`, `resizeHandleColor`, `resizeHandleThickness`, `resizeHandleIndent`, `resizeHandleEndIndent` from `TablePlusHeaderTheme`
    *   Added `TablePlusResizeHandleTheme` class with `width`, `color`, `thickness`, `indent`, `endIndent` and `copyWith`
    *   New composed property: `TablePlusHeaderTheme.resizeHandle` (default `const TablePlusResizeHandleTheme()`)
    *   Consistent with existing `TablePlusHeaderBorderTheme` / `TablePlusHeaderDividerTheme` pattern
*   **FIX**: Hide vertical divider on column reorder drag feedback
    *   The floating header cell during drag-and-drop reorder no longer renders the right-edge vertical divider
    *   Added `showDivider` parameter to `_HeaderCell` (default `true`, set to `false` for feedback only)

## 2.3.0

*   **FEAT**: Added `tapTargetSize` to `TablePlusCheckboxTheme`
    *   Expands the checkbox tap/hover hit-test area without changing the visual checkbox size
    *   Configurable in logical pixels (e.g., `tapTargetSize: 40` gives a 40×40 hit area)
    *   Defaults to `size` when not set — fully backward compatible
    *   Applied to body rows, header select-all, and merged row checkboxes
*   **BREAKING**: Refactored header border/divider into separate theme classes
    *   Removed `showVerticalDividers`, `showBottomDivider`, `dividerColor`, `dividerThickness` from `TablePlusHeaderTheme`
    *   Added `TablePlusHeaderBorderTheme` for top/bottom horizontal borders (`show`, `color`, `thickness`)
    *   Added `TablePlusHeaderDividerTheme` for vertical column dividers with `indent` / `endIndent` support
    *   New properties: `topBorder` (default hidden), `bottomBorder` (default visible), `verticalDivider` (default visible)
    *   Vertical dividers now rendered as `Stack` overlay instead of `BoxDecoration.border`, enabling indent control
*   **FEAT**: Resize handle `indent` / `endIndent` / `thickness` theming
    *   `resizeHandleThickness` controls the visible indicator line width (default `2.0`)
    *   `resizeHandleIndent` / `resizeHandleEndIndent` inset the indicator from top/bottom edges
*   **FIX**: Resize handle now centered on column boundary
    *   Previously the handle was positioned entirely inside the left column (`right: 0`), making it asymmetric
    *   Now uses a header-level `Stack` overlay with `left: cumulativeWidth - handleWidth / 2`, giving equal hit area on both sides of the border
    *   Visual indicator line renders at the exact column boundary center
    *   `ValueKey` per handle ensures stable state across rebuilds and column reorders

## 2.2.0

*   **FEAT**: Drag-to-select rows
    *   `enableDragSelection` parameter enables mouse drag row selection (Excel/Finder style)
    *   `onDragSelectionUpdate` callback fires during drag with the dragged range row IDs
    *   `onDragSelectionEnd` callback fires once when drag ends
    *   Auto-scroll when dragging near viewport edges (~60fps, speed proportional to edge proximity)
    *   8px activation threshold prevents conflicts with existing tap/click gestures
    *   Works with uniform heights (O(1)), dynamic heights, and merged row groups
    *   Parent controls selection behavior (replace or additive) — consistent with UI-only philosophy

## 2.1.1

*   **IMPROVEMENT**: Auto-scroll during column resize drag
    *   When dragging a resize handle near the viewport edge, the table automatically scrolls in that direction
    *   Scroll speed is proportional to pointer proximity to the edge (50px activation zone)

## 2.1.0

*   **FEAT**: Column resizing support
    *   `resizable` parameter enables drag-to-resize on column header edges
    *   `onColumnResized` callback fires with `(String columnKey, double newWidth)` for persistence
    *   Respects per-column `minWidth` / `maxWidth` constraints; selection column excluded
*   **FEAT**: Resize handle theming in `TablePlusHeaderTheme`
    *   `resizeHandleWidth` (default `8.0`) and `resizeHandleColor` properties
*   **FIX**: `minWidth` / `maxWidth` constraints now enforced in all layout calculation paths

## 2.0.2

*   **FIX**: `showCheckboxColumn: false` in `TablePlusCheckboxTheme` now properly hides the checkbox column
*   **IMPROVEMENT**: Header select-all checkbox auto-hides when `onSelectAll` is null

## 2.0.1

*   **FIX**: Fixed header-body column width misalignment when table width exceeds total column widths

## 2.0.0

*   **BREAKING**: Migrated from `Map<String, dynamic>` to generic type parameter `<T>`
    *   `FlutterTablePlus<T>` accepts any data model type
    *   `rowIdKey` → `rowId: String Function(T)`
    *   `dimRowKey` / `invertDimRow` → `isDimRow: bool Function(T)?`
    *   `TablePlusColumn<T>` requires `valueAccessor: (T) => dynamic`
    *   `cellBuilder`, `hoverButtonBuilder`, `calculateRowHeight` signatures use `T` instead of `Map`
    *   `onCellChanged` receives `T` instead of `Map`
    *   `MergedRowGroup<T>` parameterized with data type
    *   `summaryRowData` → `summaryBuilder: Widget? Function(String columnKey)?`

## 1.17.2

*   **PERF**: Eliminated full table rebuilds on mouse hover
*   **PERF**: Cached total data height, row count, and visible columns computation
*   **PERF**: Added overflow detection caching in `TablePlusCell`
*   **FIX**: Added missing `TextPainter.dispose()` in `TableRowHeightCalculator`

## 1.17.1

*   **FIX**: Fixed scroll controllers being destroyed on every parent rebuild
*   **FIX**: Improved scroll sync reliability in `SyncedScrollControllers`

## 1.17.0

*   **IMPROVEMENT**: Added `itemExtentBuilder` for improved scroll performance with large datasets (10,000+ rows)

## 1.16.7

*   **FEAT**: Added `verticalOffset` to `TablePlusTooltipTheme` for customizable tooltip positioning

## 1.16.6

*   **BREAKING**: Replaced `isDimRow` callback with `dimRowKey` and `invertDimRow`

## 1.16.5

*   **FEAT**: Added dim row feature with `isDimRow` callback and theme support

## 1.16.4

*   **FIX**: Rapid consecutive taps now correctly trigger multiple `onRowTap` when `onRowDoubleTap` is null

## 1.16.3

*   **FEAT**: Added `tooltipBuilder` for custom widget tooltips (priority: `tooltipBuilder` > `tooltipFormatter` > default)
*   **FEAT**: Enhanced tooltip timing with `exitDuration` property and hover interaction support
*   **FEAT**: Intelligent tooltip positioning that adapts to available screen space
*   **FEAT**: Added `CustomTooltipWrapperTheme` for tooltip configuration

## 1.16.2

*   **FEAT**: Added configurable `doubleClickTime` to `TablePlusBodyTheme` (default 500ms)

## 1.16.1

*   **FEAT**: Added `isSelected` parameter to `onRowSecondaryTapDown` callback
*   **IMPROVEMENT**: Enhanced `TablePlusScrollbarTheme` with independent track/thumb styling (`trackWidth`, `thickness`, `radius`, `thumbColor`, `trackBorder`)

## 1.16.0

*   **BREAKING**: Removed deprecated `TablePlusSelectionTheme`
    *   Selection styling → `TablePlusBodyTheme` (`selectedRowColor`, `selectedRowTextStyle`)
    *   Checkbox properties → `TablePlusCheckboxTheme`
    *   Row interaction colors → `TablePlusBodyTheme`
*   **BREAKING**: `onRowSecondaryTap` → `onRowSecondaryTapDown` with `TapDownDetails` and `RenderBox`

## 1.15.6

*   **FEAT**: Added `TooltipBehavior.onlyTextOverflow` — tooltips only appear when text overflows
*   **FIX**: Fixed row hover colors not appearing due to Stack blocking `CustomInkWell`
*   **REFACTOR**: Moved row interaction properties from `TablePlusSelectionTheme` to `TablePlusBodyTheme`
*   **DEPRECATED**: Row interaction properties in `TablePlusSelectionTheme` (removed in 1.16.0)

## 1.15.5

*   **FEAT**: Added `TablePlusCheckboxTheme` with Material 3 `WidgetStateProperty` support
*   **DEPRECATED**: Checkbox properties in `TablePlusSelectionTheme`

## 1.15.4

*   **BREAKING**: Removed `TooltipBehavior.onOverflowOnly`

## 1.15.3

*   **FEAT**: Added `onCheckboxChanged` callback to distinguish checkbox clicks from row clicks
*   **FEAT**: Added checkbox color customization (`hoverColor`, `focusColor`, `fillColor`, `side`)
*   **FIX**: Fixed tooltip null check error during column reordering

## 1.15.2

*   **FEAT**: Added `tooltipFormatter` to `TablePlusColumn` for custom tooltip content
*   **UPDATE**: Minimum Flutter version changed to >=3.10.0

## 1.15.1

*   **FIX**: Static analysis fixes

## 1.15.0

*   **BREAKING**: Removed frozen column functionality (`frozenColumns`, `TablePlusFrozenTheme`, `TablePlusDividerTheme`)
*   **FEAT**: Hover button system with `hoverButtonBuilder`, `HoverButtonPosition`, and `TablePlusHoverButtonTheme`
*   **FEAT**: Enhanced expandable row functionality for merged row groups

## 1.14.2

*   **FEAT**: Expandable summary rows for merged row groups
    *   `isExpandable`, `isExpanded`, `summaryRowData` on `MergedRowGroup`
    *   `onMergedRowExpandToggle` callback
*   **FEAT**: Added `summaryRowBackgroundColor` to `TablePlusBodyTheme`
*   **FIX**: Fixed tooltip and height calculation in merged rows

## 1.14.1

*   **FEAT**: Added `lastRowBorderBehavior` to `TablePlusBodyTheme` (`never`, `always`, `smart`)
*   **FIX**: Fixed sorting with merged rows

## 1.14.0

*   **FEAT**: Frozen column divider with `TablePlusDividerTheme`
*   **FIX**: Fixed layout overflow in constrained height containers
*   **FIX**: Fixed vertical scrollbar track height calculation

## 1.13.2

*   **FIX**: Fixed single selection mode — clicking selected row now correctly deselects

## 1.13.1

*   **FEAT**: Added `calculateRowHeight` callback and `TableRowHeightCalculator` utility

## 1.13.0

*   **BREAKING**: Removed dynamic row height feature (`RowHeightMode`, `minRowHeight`, `TextHeightCalculator`)

## 1.12.0

*   **FEAT**: Dynamic row height with `RowHeightMode.dynamic` and `minRowHeight`
*   **FEAT**: Improved sorting with merged rows
*   **REFACTOR**: `MergedRowGroup` uses `rowKeys` instead of `originalIndices`
*   **FIX**: Fixed alternate row color logic and background color application

## 1.11.1

*   **IMPROVEMENT**: Improved focus handling for editable cells

## 1.11.0

*   **FEAT**: Merged row functionality with `MergedRowGroup` and `MergeCellConfig`
    *   Selection and editing support for merged cells
    *   Auto-save on focus loss for editable cells
*   **FEAT**: Added `cellContainerPadding` to `TablePlusEditableTheme`

## 1.10.1

*   **CHORE**: Applied `dart format`

## 1.10.0

*   **FEAT**: Dynamic row height calculation based on content
*   **FEAT**: Dynamic scrollbar visibility based on content height

## 1.9.0

*   **FEAT**: Added `headerTooltipBehavior` to `TablePlusColumn`

## 1.8.0

*   **FEAT**: Added `tooltipBehavior` to `TablePlusColumn` (`always`, `onOverflowOnly`, `never`)
*   **DEPRECATED**: `showTooltipOnOverflow` in favor of `tooltipBehavior`

## 1.7.0

*   **FEAT**: Added `noDataWidget` for custom empty state display
*   **IMPROVEMENT**: Sorting auto-disabled when data is empty

## 1.6.2

*   **FEAT**: Added `visible` property to `TablePlusColumn` for column visibility control

## 1.6.1

*   **FEAT**: Added `selectedTextStyle` to `TablePlusTheme`

## 1.6.0

*   **FEAT**: `decoration` and `cellDecoration` in `TablePlusHeaderTheme`
*   **FEAT**: Granular row interaction colors in `TablePlusSelectionTheme` (`hoverColor`, `splashColor`, `highlightColor`)
*   **FEAT**: `dividerThickness` in `TablePlusHeaderTheme`
*   **FEAT**: `rowIdKey` for custom row identifier field
*   **FEAT**: `textOverflow` property on `TablePlusColumn` with auto-tooltip on ellipsis

## 1.5.0

*   **FEAT**: Added `SelectionMode.single` for single row selection

## 1.4.0

*   **FEAT**: Disable column reordering with `onColumnReorder: null`
*   **FEAT**: Disable sorting with `onSort: null`

## 1.3.0

*   **FEAT**: Enabled simultaneous selection and editing

## 1.2.0

*   **FEAT**: Configurable sort cycle order via `sortCycle`

## 1.1.2

*   **FEAT**: Added `hintText` to `TablePlusColumn` and `hintStyle` to `TablePlusEditableTheme`
*   **FEAT**: Added `onRowDoubleTap` and `onRowSecondaryTap` callbacks

## 1.1.1

*   Updated README.md

## 1.1.0

*   **FEAT**: Cell editing with `isEditable`, per-column `editable`, `onCellChanged`, and `TablePlusEditableTheme`

## 1.0.0

*   **Initial release** — customizable table widget with synchronized scrolling, theming, sorting, selection, column reordering, and custom cell builders
