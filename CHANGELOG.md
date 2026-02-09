## 2.1.1

*   **IMPROVEMENT**: Auto-scroll during column resize drag
    *   When dragging a resize handle near the viewport edge, the table now automatically scrolls in that direction
    *   Scroll speed is proportional to pointer proximity to the edge — closer means faster
    *   Column width adjusts in sync with the scroll so the resize handle stays under the pointer
    *   Works for both left and right edges with a 50px activation zone
    *   Auto-scroll stops immediately when the pointer moves away from the edge or the drag ends

## 2.1.0

*   **FEAT**: Added column resizing support
    *   New `resizable` parameter on `FlutterTablePlus` to enable drag-to-resize on column header edges
    *   New `onColumnResized` callback fires once per resize operation with `(String columnKey, double newWidth)` for external persistence
    *   Resized columns maintain fixed width while remaining columns redistribute proportionally
    *   Respects per-column `minWidth` and `maxWidth` constraints during drag
    *   Selection column (`__selection__`) is excluded from resizing
    *   Works alongside column reordering — resize handle and drag-to-reorder gestures are separated via Stack z-order
    *   Resize state is automatically cleaned up when columns are added or removed
*   **FEAT**: Added resize handle theme properties to `TablePlusHeaderTheme`
    *   `resizeHandleWidth` (default `8.0`) — hit-test area width at the right edge of header cells
    *   `resizeHandleColor` — indicator line color on hover/drag (defaults to `dividerColor`)
    *   Both properties available in `copyWith()`
*   **EXAMPLE**: Added "Column Resize" toggle to playground settings panel
*   **FIX**: Enforce `minWidth`/`maxWidth` constraints in column width calculation
    *   Previously `minWidth` and `maxWidth` were only applied during resize drag
    *   Now all layout calculation paths respect per-column `minWidth` and `maxWidth` via `clamp()`
    *   No behavior change for normal configurations where `width >= minWidth`

## 2.0.2

*   **FIX**: Enabled `showCheckboxColumn` property in `TablePlusCheckboxTheme`
    *   The property was defined but not functional - checkbox column was always shown when `isSelectable: true`
    *   Now setting `showCheckboxColumn: false` properly hides the checkbox column while preserving row-click selection via `onRowSelectionChanged`
    *   Useful for tables where selection should work through row clicks only, without a dedicated checkbox column
*   **EXAMPLE**: Added "Show Checkbox Column" toggle to playground settings panel
*   **IMPROVEMENT**: Header select-all checkbox now auto-hides when `onSelectAll` is null
    *   Previously the checkbox was shown but disabled when `onSelectAll` was not provided
    *   Now the checkbox is completely hidden, providing a cleaner UI for tables without select-all functionality
    *   Individual row selection via `onRowSelectionChanged` still works independently
*   **EXAMPLE**: Added "Select All" toggle to playground settings panel

## 2.0.1

*   **FIX**: Fixed header-body column width misalignment when table width exceeds total column widths
    *   Header now uses the same proportionally distributed `columnWidths` as body rows, including the selection checkbox column
    *   Replaced `Expanded` + `ReorderableListView` with flat `Row` layout to eliminate nested horizontal scrolling that caused header overlap artifacts
    *   Column reorder functionality preserved using `Draggable` + `DragTarget` instead of `ReorderableListView`

## 2.0.0

*   **BREAKING**: Migrated from `Map<String, dynamic>` to generic type parameter `<T>`
    *   `FlutterTablePlus<T>` now accepts any data model type instead of `Map<String, dynamic>`
    *   `rowIdKey` (String) replaced with `rowId` (function `String Function(T)`)
    *   `dimRowKey`/`invertDimRow` replaced with `isDimRow` (function `bool Function(T)?`)
    *   `TablePlusColumn<T>` requires `valueAccessor: (T) => dynamic` for cell value extraction
    *   `cellBuilder` signature changed from `(context, Map)` to `(context, T)`
    *   `hoverButtonBuilder` signature changed from `(rowId, Map)` to `(rowId, T)`
    *   `calculateRowHeight` signature changed from `(index, Map)` to `(index, T)`
    *   `onCellChanged` callback now receives `T` row object instead of `Map`
    *   `MergedRowGroup<T>` parameterized with data type
    *   `TableRowHeightCalculator` methods now generic
    *   `summaryRowData` in `MergedRowGroup` replaced with `summaryBuilder` (function `Widget? Function(String columnKey)?`)

## 1.17.2

*   **PERF**: Eliminated full table rebuilds on mouse hover
    *   Replaced `setState` with `ValueNotifier` + `ValueListenableBuilder` for scrollbar hover opacity
    *   Mouse enter/exit now only rebuilds the two `AnimatedOpacity` scrollbar widgets instead of the entire widget tree
*   **PERF**: Cached total data height and row count calculations
    *   `_calculateTotalDataHeight()` and `_getTotalRowCount()` were O(n×m×k) on every build — now computed once and cached
    *   Added O(1) `rowKey → index` and `rowKey → MergedRowGroup` lookup maps, replacing linear scans
    *   Cache is automatically invalidated when `data`, `mergedGroups`, or `calculateRowHeight` change
*   **PERF**: Reduced `_visibleColumns` computation from 4+ calls per build to 1
    *   Cached visible columns as a local variable in the build method
    *   Inlined `_columnsMinWidth` and passed cached columns to `_calculateColumnWidths`
*   **PERF**: Added overflow detection caching in `TablePlusCell`
    *   `TextOverflowDetector` result is now cached per cell and reused when text and width are unchanged
    *   Eliminates redundant `TextPainter` allocation/layout/dispose on every rebuild for `TooltipBehavior.onlyTextOverflow`
*   **FIX**: Added missing `TextPainter.dispose()` in `TableRowHeightCalculator.calculateTextHeight`
    *   Previously leaked native Skia paragraph resources until garbage collection
*   **FIX**: Fixed settings change detection bug in example playground
    *   `_handleSettingsChanged` compared new settings against already-overwritten `_settings`, causing merged rows toggle and column rebuilds to silently fail
*   **EXAMPLE**: Added missing feature demonstrations to playground
    *   `onRowSecondaryTapDown`: Right-click context menu with View, Select, Delete actions
    *   `hoverButtonBuilder`: Hover action buttons (View, Edit, Delete) on each row
    *   `calculateRowHeight`: Dynamic row height toggle in settings
    *   `dimRowKey` / `invertDimRow`: Dim inactive rows toggle in settings
    *   `noDataWidget`: Custom empty state widget
    *   `sortCycleOrder`: ASC First / DESC First dropdown in settings
    *   `tooltipBehavior`: Always / Never / On Overflow dropdown in settings
    *   `onSelectAll` / `onCheckboxChanged`: Select-all checkbox and individual checkbox callbacks

## 1.17.1

*   **FIX**: Fixed scroll controllers being destroyed on every parent rebuild (e.g., hover)
    *   `didUpdateWidget` now only re-initializes when external controllers actually change
    *   Previously, mouse enter/exit caused all scroll positions to reset
*   **FIX**: Improved scroll sync reliability in `SyncedScrollControllers`
    *   Removed `outOfRange` early-return that broke sync during rapid scrolling
    *   Removed `> 0.1` threshold that caused scrollbar lag
    *   Uses `minScrollExtent` instead of hardcoded `0.0` for correct clamping

## 1.17.0

*   **IMPROVEMENT**: Added `itemExtentBuilder` to `ListView.builder` in `TablePlusBody` for significantly improved scroll performance with large datasets
    *   Eliminates jank when jumping to middle of list (e.g., scrollbar drag) with 10,000+ rows
    *   Flutter no longer needs to build intermediate items to calculate scroll positions
    *   Works with both fixed row heights and dynamic row heights (`calculateRowHeight`)
    *   Properly handles merged row groups with `_getMergedGroupExtent` helper

## 1.16.7

*   **FEAT**: Added `verticalOffset` to `TablePlusTooltipTheme` for customizable tooltip positioning (default: 24.0px)
*   **IMPROVEMENT**: Created `FlutterTooltipPlus` widget to centralize tooltip logic across all table components

## 1.16.6

*   **BREAKING**: Replaced `isDimRow` callback with `dimRowKey` and `invertDimRow` for better performance
    *   Use `dimRowKey` to specify a boolean field in rowData that determines dim state
    *   Use `invertDimRow: true` to invert the logic (e.g., dim when `isActive` is false)
    *   Eliminates callback overhead - dim state is determined by simple Map lookup

## 1.16.5

*   **FEAT**: Added dim row feature with `isDimRow` callback and theme support for styling inactive or conditional rows

## 1.16.4

*   **FIX**: Fixed row tap behavior when `onRowDoubleTap` is null
    *   When `onRowDoubleTap` is not provided, rapid consecutive taps now correctly trigger multiple `onRowTap` calls
    *   Previously, the second tap in a rapid sequence was incorrectly treated as a double-tap and ignored
    *   Improved user experience by ensuring consistent tap response when double-tap functionality is disabled

## 1.16.3

*   **FEAT**: Added `tooltipBuilder` support for custom widget tooltips
    *   New `tooltipBuilder` property enables rich content tooltips with any Flutter widget
    *   Priority system: `tooltipBuilder` > `tooltipFormatter` > default text tooltip
    *   Works with both regular cells and merged rows
    *   Full backward compatibility with existing `tooltipFormatter`

*   **FEAT**: Enhanced `TablePlusTooltipTheme` with improved tooltip timing controls
    *   Added `exitDuration` property for controlling tooltip dismiss timing
    *   Clarified `waitDuration`, `showDuration`, and `exitDuration` documentation
    *   Fixed tooltip hover interaction - tooltips now stay visible when mouse hovers over tooltip content
    *   Default `exitDuration` is 100ms for responsive tooltip dismissal

*   **FEAT**: Intelligent tooltip positioning system for `tooltipBuilder`
    *   Automatically switches between above/below based on available screen space
    *   Prevents clipping at screen boundaries with horizontal repositioning

*   **FEAT**: Added `CustomTooltipWrapperTheme` for tooltip configuration
    *   New theme structure: `TablePlusTooltipTheme.customWrapper` 
    *   Configurable positioning and spacing parameters with sensible defaults

## 1.16.2

*   **FEAT**: Added configurable `doubleClickTime` to `TablePlusBodyTheme`
    *   Double-click timing for row interactions is now customizable through theme
    *   Default value changed from 300ms to 500ms for improved user experience
    *   Applies to both regular rows and merged row groups
    *   Usage: `bodyTheme: TablePlusBodyTheme(doubleClickTime: Duration(milliseconds: 400))`

## 1.16.1

*   **FEAT**: Enhanced `onRowSecondaryTapDown` callback with selection state information
    *   Added `isSelected` parameter to provide row selection state during right-click/long-press events
    *   New signature: `(String rowId, TapDownDetails details, RenderBox renderBox, bool isSelected)`
    *   Enables context-aware menus that can differentiate between selected and unselected rows
*   **IMPROVEMENT**: Enhanced `TablePlusScrollbarTheme` with independent styling controls
    *   Renamed `width` to `trackWidth` for clearer semantics (track container size)
    *   Added `thickness` property for independent thumb size control (defaults to `trackWidth * 0.7`)
    *   Added `radius` property for independent corner rounding control (defaults to `trackWidth / 2`)
    *   Renamed `color` to `thumbColor` for better clarity
    *   Added `trackBorder` property supporting full `Border` styling for track edges
    *   Improved flexibility allowing separate customization of track and thumb appearance

## 1.16.0

*   **BREAKING**: Removed deprecated `TablePlusSelectionTheme` class
    *   Selection-related styling moved to `TablePlusBodyTheme` (`selectedRowColor`, `selectedRowTextStyle`)
    *   Checkbox-related properties moved to `TablePlusCheckboxTheme` 
    *   Row interaction colors moved to `TablePlusBodyTheme` (hover, splash, highlight colors)
*   **BREAKING**: Changed `onRowSecondaryTap` to `onRowSecondaryTapDown` with enhanced position information
    *   Now provides `TapDownDetails` and `RenderBox` for precise context menu positioning
*   **MIGRATION**: Update your code for breaking changes:
    *   Replace `TablePlusSelectionTheme` properties with `TablePlusBodyTheme` and `TablePlusCheckboxTheme`
    *   Update `onRowSecondaryTap` callbacks to `onRowSecondaryTapDown` with new signature
*   **IMPROVEMENT**: Enhanced interaction color fallback logic in `TablePlusBodyTheme`
    *   Selected row interaction colors now fallback to base colors when not specified (previously used Flutter defaults)

## 1.15.6

*   **FEAT**: Added `TooltipBehavior.onlyTextOverflow` for smart tooltip display
    *   Tooltips now only appear when text actually overflows the available space
    *   Uses `TextOverflowDetector` utility for accurate overflow detection
    *   Applies to both cell tooltips and header tooltips
    *   Calculates available width considering padding, sort icons, and other UI elements
*   **FIX**: Restored `onlyTextOverflow` tooltip behavior that was previously removed
*   **FIX**: Fixed row hover colors not appearing due to Stack widget blocking CustomInkWell effects
    *   Container background color is now conditionally applied based on CustomInkWell availability
    *   Hover effects from TablePlusSelectionTheme (rowHoverColor, selectedRowHoverColor) now work properly
*   **FEAT**: Added tooltip overflow test page to example app for demonstrating smart tooltip behavior
*   **REFACTOR**: Moved row interaction properties from TablePlusSelectionTheme to TablePlusBodyTheme
    *   Moved `rowHoverColor`, `rowSplashColor`, `rowHighlightColor` to `TablePlusBodyTheme.hoverColor`, `splashColor`, `highlightColor`
    *   Moved `selectedRowHoverColor`, `selectedRowSplashColor`, `selectedRowHighlightColor` to corresponding properties in `TablePlusBodyTheme`
    *   Updated widget implementations to use `TablePlusBodyTheme` for row interaction effects
*   **DEPRECATED**: Row interaction properties in TablePlusSelectionTheme will be removed in v1.16.0
    *   Use corresponding properties in `TablePlusBodyTheme` instead
    *   Added deprecation warnings and migration guidance in documentation
*   **UPDATE**: Updated documentation (THEMING.md, SELECTION.md) to reflect new theme structure

## 1.15.5

*   **FEAT**: Added TablePlusCheckboxTheme for comprehensive checkbox styling with Material 3 support
*   **DEPRECATED**: Checkbox properties in TablePlusSelectionTheme are deprecated (use TablePlusCheckboxTheme instead)
*   **FEAT**: Added Material 3 compliant checkbox theme factory with WidgetStateProperty support
*   **FIX**: Improved tooltip stability during column reordering operations

## 1.15.4

*   **BREAKING CHANGE**: Removed TooltipBehavior.onOverflowOnly (use cellBuilder for overflow tooltips)

## 1.15.3

*   **FEAT**: Added onCheckboxChanged callback to distinguish checkbox clicks from row clicks
*   **FEAT**: Enhanced checkbox customization with new color options
    *   Added checkboxHoverColor for mouse hover states
    *   Added checkboxFocusColor for focus states
    *   Added checkboxFillColor for background fill
    *   Added checkboxSide for border color and width control
*   **FIX**: Fixed tooltip null check error during column reordering

## 1.15.2

*   **FEAT**: Added tooltipFormatter to TablePlusColumn for custom tooltip content based on rowData
*   **REFACTOR**: Removed unused properties from TablePlusHoverButtonTheme (only horizontalOffset remains)
*   **UPDATE**: Minimum Flutter version requirement changed from >=1.17.0 to >=3.10.0
*   **CLEANUP**: Removed unnecessary imports and code

## 1.15.1
*   **FIX** flutter analyze

## 1.15.0

*   **BREAKING CHANGE**: Removed frozen column functionality.
    *   Eliminated `frozenColumns` parameter and related frozen column features for code simplification and better maintainability.
    *   Removed `TablePlusFrozenTheme` and `TablePlusDividerTheme` classes.
    *   Applications using frozen columns should migrate to alternative layout approaches.
*   **FEAT**: Added comprehensive hover button system for table rows.
    *   New `hoverButtonBuilder` callback parameter for creating custom action buttons on row hover.
    *   Added `HoverButtonPosition` enum for positioning buttons (left, center, right).
    *   Introduced `TablePlusHoverButtonTheme` with extensive customization options.
    *   Supports custom styling, animations, and button behavior configuration.
    *   Integrated seamlessly with existing selection and editing features.
*   **FEAT**: Enhanced expandable row functionality for merged row groups.
    *   Improved expand/collapse state management with better performance.
    *   Added support for custom summary content in collapsed state.
    *   Enhanced integration with sorting, selection, and editing operations.
    *   Better visual indicators and animations for expand/collapse actions.
*   **FEAT**: Added comprehensive demo page showcasing all table features.
    *   New `ComprehensiveTableDemo` demonstrating progressive feature adoption.
    *   Interactive control panels for testing different configurations.
    *   Real-world scenarios with employee data management examples.
    *   Improved developer experience with better feature discovery.
*   **IMPROVEMENT**: Major codebase refactoring and optimization.
    *   Enhanced performance through optimized widget rebuilding strategies.
    *   Improved code organization and maintainability.
    *   Better separation of concerns across widget components.
    *   Reduced complexity by removing unused and deprecated code paths.
*   **IMPROVEMENT**: Updated example applications with new features.
    *   Added `HoverButtonDemo` page demonstrating hover button capabilities.
    *   Enhanced existing examples with better feature integration.
    *   Improved documentation and code comments throughout examples.
*   **DOCS**: Added comprehensive documentation for new features.
    *   New `HOVER_BUTTONS.md` guide with usage patterns and customization examples.
    *   New `EXPANDABLE_ROWS.md` guide covering advanced expandable row scenarios.
    *   Updated existing documentation to reflect architectural improvements.

## 1.14.2

*   **FEAT**: Added expandable summary row functionality for merged row groups.
    *   Added `isExpandable`, `isExpanded`, and `summaryRowData` properties to `MergedRowGroup`.
    *   Added `onMergedRowExpandToggle` callback to `FlutterTablePlus` for handling expand/collapse interactions.
    *   Summary rows can display calculated totals, counts, or any custom data.
    *   Expand/collapse icons automatically appear in the first column of expandable groups.
*   **FEAT**: Added `summaryRowBackgroundColor` to `TablePlusBodyTheme` for styling summary rows.
*   **IMPROVEMENT**: Enhanced `TableRowHeightCalculator.createHeightCalculator` for more accurate height calculations.
    *   Improved text layout calculations for complex scenarios.
    *   Better handling of padding and text overflow in dynamic height scenarios.
*   **FIX**: Fixed tooltip functionality in merged row cells.
*   **FIX**: Improved merged row compatibility and rendering issues.
*   **FIX**: Enhanced height calculation logic for merged row groups.
*   **DOCS**: Added comprehensive `expandable_summary_example.dart` demonstrating expandable summary functionality.
*   **DOCS**: Updated examples with better feature demonstrations and descriptions.

## 1.14.1

*   **FEAT**: Added `lastRowBorderBehavior` to `TablePlusBodyTheme` to control the visibility of the last row's bottom border (`never`, `always`, `smart`).
*   **FIX**: Fixed an issue where sorting did not work correctly with merged rows in the example.
*   **DOCS**: Added a comprehensive example (`comprehensive_merged_example.dart`) demonstrating various table features together.
*   **CHORE**: Updated the main example page to link to the new comprehensive example.
*   **CHORE**: Updated an icon in the frozen columns demo.

## 1.14.0

*   **FEAT**: Added frozen column divider feature.
    *   Introduced `TablePlusDividerTheme` for customizing divider appearance.
    *   Added divider between frozen and scrollable columns with configurable color, thickness, and margins.
    *   Header divider displays at fixed header height, body divider matches actual data content height.
    *   Divider automatically appears when both frozen and scrollable columns are present.
    *   Added divider theme configuration to main `TablePlusTheme` class.
*   **BUG FIX**: Fixed layout overflow issues in constrained height containers.
    *   Resolved Column overflow errors when table is placed in fixed-height containers like Card.
    *   Improved divider positioning to work correctly with flexible layouts.
*   **BUG FIX**: Fixed vertical scrollbar track height calculation.
    *   Corrected scrollbar track height to account for horizontal scrollbar space.
    *   Eliminated extra bottom padding in vertical scrollbar when horizontal scrollbar is present.

## 1.13.2

*   **BUG FIX**: Fixed single selection mode toggle behavior.
    *   Fixed issue where clicking on an already selected row in `SelectionMode.single` would not deselect the row.
    *   Updated row tap handling logic to consistently support toggle behavior in both single and multiple selection modes.
    *   Fixed similar issue in merged row groups when using single selection mode.
    *   Improved consistency across all selection interaction methods (row tap, checkbox click, merged row selection).

## 1.13.1

*   **FEAT**: Added `calculateRowHeight` callback for external row height calculation.
    *   Introduced optional `calculateRowHeight` parameter to `FlutterTablePlus`.
    *   Added `TableRowHeightCalculator` utility class with helper methods.
    *   Supports `TextOverflow.visible` with proper height calculation.
    *   Scrollbar height calculation now accounts for dynamic row heights.
    *   Includes comprehensive example demonstrating all features together.
*   **IMPROVEMENT**: Enhanced example applications.
    *   Added Dynamic Height Example with selection, sorting, and editing features.
    *   Increased table heights across all examples for better visibility.
    *   Added scrollable main page for better navigation.

## 1.13.0

*   **BREAKING CHANGE**: Removed dynamic row height feature for performance and stability.
    *   Removed `RowHeightMode` enum and `rowHeightMode` parameter.
    *   Removed `minRowHeight` parameter.
    *   Removed `TextHeightCalculator` utility class.
    *   All tables now use fixed row height from theme (reverted to v1.9.0 behavior).
    *   This change resolves scroll position issues with large datasets and improves overall performance.

## 1.12.0

*   **FEAT**: Added support for dynamic row height.
    *   Introduced `RowHeightMode.dynamic` to allow rows to resize based on content.
    *   Added `minRowHeight` to control the minimum height of a row.
    *   Added a new example page to demonstrate dynamic row height.
*   **FEAT**: Improved sorting with merged rows.
    *   Merged groups are now dynamically generated based on the sorted data, ensuring they are correctly displayed after sorting.
*   **REFACTOR**: `MergedRowGroup` now uses `rowKeys` instead of `originalIndices` for a more robust implementation.
*   **FIX**: Corrected the alternate row color logic to use the render index, ensuring correct striping after sorting.
*   **FIX**: Fixed an issue where the background color of rows was not being applied correctly.

## 1.11.1

*   **IMPROVEMENT**: Improved focusing on modification for editable cells.

## 1.11.0

*   **FEAT**: Introduced merged row functionality.
    *   Added `MergedRowGroup` and `MergeCellConfig` models to define row merging behavior.
    *   Implemented `FlutterTablePlus` and `TablePlusBody` support for `mergedGroups`.
    *   Enabled selection for merged row groups, treating them as single selectable units.
    *   Added editing capabilities for merged cells, allowing specific merged cells to be editable.
*   **IMPROVEMENT**: Enhanced editable cell experience.
    *   Improved styling and behavior of editable text fields in merged cells to match regular cells.
    *   Implemented auto-save on focus loss for editable cells.
    *   Added `cellContainerPadding` to `TablePlusEditableTheme` for consistent padding around editable cell containers.
*   **CHORE**: Removed unnecessary code.
    *   Cleaned up `operator ==` and `hashCode` overrides from `MergedRowGroup` and `TablePlusColumn`.
*   **DOCS**: Added new examples for merged row features.
    *   Created `simple_merged_example.dart` for basic merged rows.
    *   Created `complex_merged_example.dart` for advanced merging scenarios (multiple columns, custom content, multiple groups).
    *   Created `selectable_merged_example.dart` to demonstrate selection with merged rows.
    *   Created `editable_merged_example.dart` to showcase editing functionality with merged rows.

## 1.10.1

*   **CHORE**: Apply `dart format` for code consistency.

## 1.10.0

*   **FEAT**: Dynamic row height calculation based on content.
*   **FEAT**: Scrollbar visibility is now dynamically adjusted based on content height.
*   **REFACTOR**: Removed deprecated code and updated to the latest syntax.

## 1.9.0

*   **FEAT**: Add header tooltip behavior to table columns.
    *   Introduces a new `headerTooltipBehavior` property to `TablePlusColumn` for controlling tooltip display on column headers.
    *   Updates header rendering logic to show tooltips based on overflow or always/never settings.

## 1.8.0

*   **Features**
    *   Added `tooltipBehavior` to `TablePlusColumn` to control when tooltips are displayed (`always`, `onOverflowOnly`, `never`).
*   **Improvements**
    *   Added `TextOverflowDetector` to accurately determine when text overflows in a cell.
*   **Deprecations**
    *   Deprecated `showTooltipOnOverflow` in `TablePlusColumn` in favor of the new `tooltipBehavior` property.

## 1.7.0

*   **Features**
    *   Added `noDataWidget` property to `FlutterTablePlus` to allow displaying a custom widget when the data source is empty.
*   **Improvements**
    *   The header sorting functionality is now automatically disabled when there is no data, preventing unnecessary sort actions.
*   **Documentation**
    *   Added a new guide, `EMPTY_STATE.md`, to explain how to use the `noDataWidget` feature.
    *   Updated `README.md` to include the new feature and documentation link.

## 1.6.2

*   **Documentation**
    *   Added documentation for the `visible` property in `TablePlusColumn` to control column visibility.
    *   Updated `README.md` to include column visibility in the feature list.
*   **Improvements**
    *   Added a comprehensive example for managing column visibility, including UI controls and dialogs.
    *   Enhanced the example application with helper functions for column state management.

## 1.6.1

*   **Added Selected Text Style**
    *   Added `selectedTextStyle` to `TablePlusTheme` to allow customizing the text style of selected rows.

## 1.6.0

*   **Enhanced Theming and Styling Capabilities**
    *   **Advanced Header Customization**: `TablePlusHeaderTheme` now includes a `decoration` property, allowing full control over the header's appearance (e.g., borders, gradients, shadows) using `BoxDecoration`.
    *   **Individual Header Cell Styling**: Added `cellDecoration` to `TablePlusHeaderTheme` for styling individual header cells.
    *   **Flexible Row Interaction Effects**: `TablePlusSelectionTheme` has been updated to provide more granular control over row interaction effects:
        *   Set `hoverColor`, `splashColor`, and `highlightColor` independently for both normal and selected rows (e.g., `rowHoverColor`, `selectedRowHoverColor`).
        *   If these properties are left `null`, the default Flutter framework effects will be used, enhancing consistency and predictability.
        *   The `enableRowInteractionEffects` property has been removed for a simpler and more direct API.
    *   **Customizable Header Divider**: Added `dividerThickness` to `TablePlusHeaderTheme` to control the thickness of the header's bottom divider.

*   **Improved Feature Flexibility**
    *   **Custom Row ID Key**: Added a `rowIdKey` property to `FlutterTablePlus`, allowing developers to specify which key in their data map should be used as a unique row identifier. This removes the previous requirement of having a mandatory `'id'` key.
    *   **Text Overflow and Tooltip**: `TablePlusColumn` now supports a `textOverflow` property (`ellipsis`, `clip`, `fade`). When `ellipsis` is used, a tooltip automatically appears on hover to show the full text.

*   **Internal Code Refinements**
    *   **Theme Structure Refactoring**: Theme-related classes have been organized into separate files (`header_theme.dart`, `body_theme.dart`, etc.) for better code structure and maintainability.

## 1.5.0

*   **Added Single Selection Mode**
    *   Introduced `SelectionMode.single` to allow only one row to be selected at a time.
    *   When a new row is selected in single selection mode, the previous selection is automatically cleared.
    *   The "Select All" checkbox is now automatically hidden when in single selection mode for a cleaner UI.

*   **Refactored Example Page**
    *   The main example page (`table_example_page.dart`) has been significantly refactored for better readability and maintainability.
    *   Key UI components like the app bar actions, status indicators, and documentation sections have been extracted into their own reusable widgets:
        *   `TableAppBarActions`
        *   `TableStatusIndicators`
        *   `ExampleDocumentation`
    *   This improves code organization and makes the example easier to understand and adapt.

## 1.4.0

*   **Enhanced Feature Control Options**
    *   Added ability to completely disable column reordering by setting `onColumnReorder: null`. This removes drag handles and disables drag-and-drop functionality entirely.
    *   Added ability to completely disable sorting by setting `onSort: null`. This hides all sort icons and disables sorting click handlers for all columns.
    *   Improved conditional feature control for better user experience and permissions-based functionality.

*   **Documentation Improvements**
    *   Added comprehensive Column Reordering section to ADVANCED_COLUMNS.md with complete implementation examples.
    *   Enhanced SORTING.md with detailed comparison between `sortable: false` and `onSort: null`.
    *   Updated README.md with new "Conditional Feature Control" section and examples.
    *   Added practical examples for dynamic feature enabling/disabling based on user permissions.

## 1.3.0

*   **Enabled Simultaneous Selection and Editing**
    *   Removed the restriction that prevented `isSelectable` and `isEditable` from being active at the same time.
    *   Now, rows can be selected even when cell editing is enabled, providing greater flexibility.

## 1.2.0

*   **Added Configurable Sort Cycle Order**
    *   `FlutterTablePlus` now includes a `sortCycle` property to define the sequence of sorting states (`ascending`, `descending`, `none`).
    *   The default cycle is `ascending` -> `descending` -> `none`.
    *   This allows for more flexible sorting behaviors, such as disabling the `none` state or changing the order.

## 1.1.2

*   **Added Hint Text and Style for Editable Cells**
    *   `TablePlusColumn` now includes an optional `hintText` property to display placeholder text in editable `TextField`s.
    *   `TablePlusEditableTheme` now includes an optional `hintStyle` property to customize the style of the hint text.
*   **Added Row Double-Tap and Secondary-Tap Callbacks**
    *   `FlutterTablePlus` now provides `onRowDoubleTap` and `onRowSecondaryTap` callbacks for row-level gesture detection.
    *   These callbacks are active when `isSelectable` is `true` and `isEditable` is `false`.
    *   `CustomInkWell` now correctly handles `onDoubleTap` and `onSecondaryTap` events without interfering with `onTap`.
    *   Ensured `CustomInkWell`'s internal state is preserved during `setState` by adding `key: ValueKey(rowId)`.

## 1.1.1

*   Update README.md

## 1.1.0

* **Added Cell Editing Feature**

### Features

*   **Editable Cells:** Introduced `isEditable` property in `FlutterTablePlus` to enable or disable cell editing.
*   **Column-Specific Editing:** Added `editable` property to `TablePlusColumn` to control which columns can be edited.
*   **Cell Change Callback:** Implemented `onCellChanged` to notify when a cell's value is updated.
*   **Theming for Editing:** Added `TablePlusEditableTheme` to customize the appearance of cells in editing mode (background color, text style, borders, etc.).
*   **Keyboard Support:** Press `Enter` to save changes or `Escape` to cancel editing. Editing also stops when the cell loses focus.

## 1.0.0

* **Initial release of `flutter_table_plus`**

### Features

*   **Highly Customizable Table:** Provides a flexible and efficient table widget.
*   **Synchronized Scrolling:** Horizontal and vertical scrolling is synchronized between the header and body.
*   **Theming:** Extensive customization of table appearance through `TablePlusTheme`, including headers, rows, scrollbars, and selection styles.
*   **Column Sorting:** Supports sorting columns in ascending, descending, or unsorted order. The sorting logic is handled by the parent widget.
*   **Row Selection:** Allows for single or multiple row selection with checkboxes.
*   **Column Reordering:** Supports drag-and-drop column reordering.
*   **Custom Cell Builders:** Allows for custom widget rendering in cells for complex data representation.
*   **Type-Safe Column Builder:** Use `TableColumnsBuilder` to safely create and manage column order.