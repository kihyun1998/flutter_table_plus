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
