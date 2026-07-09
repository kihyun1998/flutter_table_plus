# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Table Plus is a highly customizable and efficient table widget for Flutter that provides synchronized scrolling, theming, sorting, selection, column reordering, column resizing, and cell editing capabilities. The package is structured as a Flutter library with comprehensive documentation and examples.

## Package Philosophy

Flutter Table Plus follows a **"UI-only, data-agnostic"** philosophy. The package does not manage your data or state, but actively provides convenience utilities and sensible defaults to minimize boilerplate.

### Core Principles

1. **No Data Management**: The package does not store or mutate your table data internally. Data operations (sorting, filtering, pagination, etc.) remain under your control.

2. **Callback-Driven**: User interactions (sort clicks, selections, edits) are communicated back through callbacks. You decide how to handle them.

3. **Convenience First**: Where common patterns exist (gesture detection, delta normalization, etc.), the package provides ready-to-use utility widgets and helpers with sensible defaults. Users can always opt out and implement their own logic.

4. **State Management Agnostic**: Works equally well with setState, Provider, Riverpod, Bloc, or any other state management solution.

## Environment Notes

Claude Code and the user share the same Windows machine. The Flutter SDK is on `PATH`, so run `flutter test`, `flutter analyze`, and `dart format` directly — do not ask the user to run them.

The one exception is anything that opens a window or waits for input: `flutter run` needs a human to drive the app and read what is on screen. Ask for those, and say which settings to use and what to look for.

## Common Development Commands

### Testing
```bash
flutter test                    # Run all tests
flutter test test/flutter_table_plus_test.dart  # Run specific test file
```

### Code Quality
```bash
flutter analyze                 # Run static analysis using analysis_options.yaml with flutter_lints and custom_lint
dart format .                   # Format code according to Dart style
dart format lib/                # Format only the lib directory
```

### Dependencies
```bash
flutter pub get                 # Install dependencies  
flutter pub upgrade             # Upgrade dependencies
```

### Example App
```bash
cd example && flutter run       # Run the example application
cd example && flutter test      # Run example tests
```

### Package Development
```bash
flutter pub publish --dry-run   # Test package publishing
dart doc .                      # Generate API documentation
```

## Architecture Overview

### Core Components

- **`lib/flutter_table_plus.dart`**: Main library export file
- **`lib/src/widgets/flutter_table_plus.dart`**: Main FlutterTablePlus widget implementation
- **`lib/src/widgets/table_header.dart`**: Header row implementation with sorting, reordering, and column resizing
- **`lib/src/widgets/table_body.dart`**: Body rows `ListView` — a pure row renderer. Implements the `RowLocator` port (`indexAt` / `idsBetween`) via a public `TablePlusBodyState`, accessed by the parent through `GlobalKey`, so drag-selection logic can resolve coordinates to row IDs without owning the body's caches
- **`lib/src/widgets/row_locator.dart`**: `RowLocator` — the narrow port (`indexAt(localY)`, `idsBetween(start, end)`) that decouples drag selection from the body's internal caching strategy
- **`lib/src/widgets/drag_selection_controller.dart`**: `DragSelectionController` — the drag-to-select gesture state machine (threshold, lazy anchor, sticky range, emit), rubber-band geometry, and the auto-scroll loop (owns its own `Timer`; scroll application + repaint are injected as callbacks). Extracted from the table widget and driven by primitive coordinates so it is unit-testable without pumping a widget — including the timer loop via `fakeAsync` (see `test/drag_selection_controller_test.dart`)
- **`lib/src/widgets/synced_scroll_controllers.dart`**: Synchronized scrolling logic
- **`lib/src/widgets/custom_ink_well.dart`**: Custom tap handling widget
- **`lib/src/widgets/table_plus_merged_row.dart`**: Merged row rendering widget for grouped data display

### Data Models

- **`lib/src/models/table_column.dart`**: TablePlusColumn model defining column properties
- **`lib/src/models/table_columns_builder.dart`**: Builder pattern for creating ordered columns safely
- **`lib/src/models/merged_row_group.dart`**: MergedRowGroup and MergeCellConfig models for grouped row functionality
- **`lib/src/models/theme/theme.dart`**: Comprehensive theming system with nested theme classes
- **`lib/src/models/tooltip_behavior.dart`**: Tooltip display behavior configuration

### Utility Classes

- **`lib/src/utils/table_row_height_calculator.dart`**: External row height calculation utility for dynamic heights with TextOverflow.visible support
- **`lib/src/utils/text_overflow_detector.dart`**: Text overflow detection utility for tooltip and layout decisions

### Key Architectural Patterns

1. **Generic, Data-Agnostic Rows**: `FlutterTablePlus<T>` takes `List<T>`; the row's identity comes from the required `rowId: String Function(T)`. Columns read values through `valueAccessor`, so rows can be maps, models, or anything else
2. **Builder Pattern**: TableColumnsBuilder prevents order conflicts and manages column ordering automatically
3. **Synchronized Scrolling**: Header and body each have their own horizontal `SingleChildScrollView`; `SyncedScrollControllers` synchronizes them through a shared-controller pattern (the body is the user-input master, the header uses `NeverScrollableScrollPhysics` and is driven by the body's position). The horizontal scrollbar is a third sync target. Vertical scroll lives inside the body's `ListView`
4. **Merged Row Groups**: MergedRowGroup system for visually combining multiple data rows with configurable merge behavior per column
5. **Theme Composition**: Nested theme classes (TablePlusTheme, TablePlusHeaderTheme, etc.) for granular styling control
6. **State Management Ready**: Designed to work with state management solutions like setState, Provider, Riverpod, or Bloc
7. **Row Widget Polymorphism**: TablePlusRowWidget abstract class enables different row types (_TablePlusRow for normal rows, TablePlusMergedRow for grouped rows) with consistent ListView.builder interface
8. **Drag Selection (single coordinate frame)**: A `Listener` wraps the body's horizontal `Scrollable` from the *outside*, so its `RenderBox` is stationary in screen — `event.localPosition` is therefore viewport-local on both axes. The widget's pointer handlers are thin translators that forward `down`/`move`/`up`/`cancel` to a `DragSelectionController`, which owns the gesture state machine, the auto-scroll loop (its own `Timer`, with scroll application injected as callbacks), and the content-anchored rubber-band origin (`downLocal − hDelta/vDelta` on both axes). Row lookups go through the `RowLocator` port the body implements

### Widget Lifecycle

FlutterTablePlus follows a composition pattern where:
- Header and body are separate widgets, each with its own horizontal `SingleChildScrollView`; `SyncedScrollControllers` keeps their positions aligned
- Drag selection is owned by a `DragSelectionController` (constructed in `_FlutterTablePlusState.initState`); a viewport-level `Listener` forwards pointer events to it, and the body is queried for row-index lookups through the `RowLocator` port it implements (reached via `GlobalKey<TablePlusBodyState<T>>`)
- Column reordering updates the column map and triggers rebuilds
- Column resizing is managed internally via `_resizedWidths` state map; `onColumnResized` callback notifies externally for persistence
- Selection state is managed externally and passed down as props
- Editing state can coexist with selection state
- Merged row groups are treated as single units for selection and editing operations

### Data Flow

1. Columns defined via TableColumnsBuilder or direct Map creation
2. Data provided as List of Maps with consistent keys matching column keys
3. User interactions (sort, select, edit, reorder, resize) flow through callback functions
4. External state management handles data updates and passes back to widget

## Important Implementation Details

- **Column Order Management**: Column order is managed by the `order` field in TablePlusColumn. Use TableColumnsBuilder to prevent order conflicts
- **Selection Requirements**: `rowId` must return a unique, stable id per row - duplicate ids cause unexpected behavior
- **Null Safety for Features**: Setting `onSort: null` completely hides sort icons and disables sorting. Setting `onColumnReorder: null` disables drag-and-drop. Setting `resizable: false` (default) hides resize handles entirely
- **Column Resizing**: `resizable: true` enables drag-to-resize on header cell right edges. Resize widths are internal layout state (`_resizedWidths`); `onColumnResized` callback fires once on drag end for persistence. Resized columns keep fixed width while unresized columns redistribute proportionally. `minWidth`/`maxWidth` per column are enforced via `clamp()` in all layout calculation paths. Selection column (`__selection__`) is excluded from resizing. Resize handle theming via `TablePlusHeaderTheme.resizeHandleWidth` and `resizeHandleColor`
- **Coexisting Features**: Selection and editing modes can coexist in the same table simultaneously
- **Theme Architecture**: Uses nested theme classes (TablePlusTheme > TablePlusHeaderTheme/TablePlusBodyTheme/etc.) for granular control
- **Custom Cell Rendering**: `statefulCellBuilder` (the only custom-cell hook; there is no `cellBuilder`) renders any Flutter widget in a cell, but can impact performance with large datasets
- **Sort Cycle Configuration**: Sort cycle order is configurable between ascending-first and descending-first patterns
- **Tooltip Control**: Fine-grained tooltip behavior control for both cells and headers via `tooltipBehavior` and `headerTooltipBehavior` properties. Two kinds of body tooltip, gated differently: a **text** tooltip exists to reveal truncated glyphs, so it is gated on ellipsis / non-empty text and its hover target is the `Text` itself. A **widget** tooltip (`tooltipBuilder`) draws unrelated content, so only `TooltipBehavior.never` suppresses it and its hover target is the whole cell. `TooltipResolver.shouldShow` takes `hasWidgetTooltip` to keep the two apart. A **row** tooltip (`rowTooltipBuilder`) wraps the whole row in `table_body.dart`'s `itemBuilder` with `TooltipAnchor.pointer` — hover region and anchor must differ, since a row is `contentWidth` wide. Nesting is arbitrated by just_tooltip (innermost wins), so this package holds no priority logic. Beware: `TooltipBehavior.always` gives every ellipsized column a tooltip whether or not its text is cut, which leaves a row card nowhere to appear
- **Merged Rows**: MergedRowGroup functionality allows grouping consecutive rows with configurable merge behavior per column. Supports custom content, selection, and editing within merged cells
- **Row Ink and Hover**: `TablePlusRowWidget` is a `StatefulWidget`; `TablePlusRowStateBase` owns the hover flag and wires `RowInteractionShell` once for every row type. Hover-button overlays are supported via `hoverButtonBuilder`, and the hover-tracking `MouseRegion` is installed only when one is set. Which ink appears is gated by **which callbacks are wired**, not by the colors: `InkWell` paints a splash/highlight only with a primary-button callback, a hover highlight with any callback. Passing a `null` color does not disable ink - it selects the framework default (`Colors.transparent` disables it, per `TablePlusBodyTheme` docs)
- **Column Width Constraints**: `minWidth`/`maxWidth` on `TablePlusColumn` are enforced in all `_calculateColumnWidths` paths via `clamp()` — both for resize drag and normal proportional layout distribution
- **Drag Selection Coordinate Model**: All drag-selection coordinates live in a single viewport-local reference frame. The `Listener` is placed at the body's viewport (outside the body's horizontal `SingleChildScrollView`), so `event.localPosition` is viewport-local on both axes — eliminating the asymmetry that previously existed when the body slid horizontally under a stale captured screen origin. Auto-scroll edge zones, the rubber band rectangle, and content-anchored origin (`downLocal − hDelta/vDelta`) all use this single frame. This gesture state machine + geometry is encapsulated in `DragSelectionController` (unit-tested in isolation via a fake `RowLocator`); the widget's pointer handlers are thin translators, and row-index lookups are routed to the body through the `RowLocator` port (reached via `GlobalKey<TablePlusBodyState<T>>`)

## Code Patterns & Conventions

### Data Structure Requirements
- Row data: `List<T>`; each column reads its value through `valueAccessor`
- Selection feature: `rowId` must return a unique, stable id per row
- Column definitions: Use `TableColumnsBuilder` for safe column creation
- Merged rows: MergedRowGroup requires valid `rowKeys` that match the ids returned by `rowId`

### Widget Composition Pattern
- Header and body are separate widgets with independent horizontal `Scrollable`s synchronized through a shared `SyncedScrollControllers` instance
- State is managed externally and passed down through props
- Callbacks flow user interactions (sort, select, edit, reorder, resize) back to parent

### Performance Considerations
- Use simple text cells when possible; `statefulCellBuilder` sparingly for complex widgets
- Consider pagination for 1000+ rows
- TableColumnsBuilder prevents order conflicts during column management

## Documentation Structure

User-facing documentation lives in the `docs/` directory:
- FEATURES.md: Sorting, selection, editing, merged rows, dynamic heights, empty state, advanced columns
- THEMING.md: Complete theming guide
- MIGRATION.md: Breaking-change migration notes

`docs/agents/` holds the agent-facing conventions referenced under "Agent skills" below.

## Agent skills

### Issue tracker

Issues are tracked in this repo's GitHub Issues via the `gh` CLI; external PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (`needs-triage` / `needs-info` / `ready-for-agent` / `ready-for-human` / `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.