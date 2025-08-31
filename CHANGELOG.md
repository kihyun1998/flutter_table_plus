## 1.15.6 (Unreleased)

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