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

* Update README.md

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