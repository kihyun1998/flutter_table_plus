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