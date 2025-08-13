# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Table Plus is a highly customizable and efficient table widget for Flutter that provides synchronized scrolling, theming, sorting, selection, column reordering, and cell editing capabilities. The package is structured as a Flutter library with comprehensive documentation and examples.

## Environment Notes

**IMPORTANT**: Claude Code runs in WSL environment while the user is on Windows. When Flutter/Dart commands need to be executed (flutter test, flutter analyze, dart format, etc.), DO NOT attempt to run them directly. Instead, ask the user to run these commands on their Windows environment.

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
flutter packages pub publish --dry-run  # Test package publishing
dart doc .                      # Generate API documentation
```

## Architecture Overview

### Core Components

- **`lib/flutter_table_plus.dart`**: Main library export file
- **`lib/src/widgets/flutter_table_plus.dart`**: Main FlutterTablePlus widget implementation
- **`lib/src/widgets/table_header.dart`**: Header row implementation with sorting and reordering
- **`lib/src/widgets/table_body.dart`**: Body rows implementation with selection and editing
- **`lib/src/widgets/synced_scroll_controllers.dart`**: Synchronized scrolling logic
- **`lib/src/widgets/custom_ink_well.dart`**: Custom tap handling widget

### Data Models

- **`lib/src/models/table_column.dart`**: TablePlusColumn model defining column properties
- **`lib/src/models/table_columns_builder.dart`**: Builder pattern for creating ordered columns safely
- **`lib/src/models/theme/theme.dart`**: Comprehensive theming system with nested theme classes
- **`lib/src/models/tooltip_behavior.dart`**: Tooltip display behavior configuration

### Key Architectural Patterns

1. **Map-based Data Structure**: Tables use `List<Map<String, dynamic>>` for row data, requiring unique row ID fields for selection features (default: 'id', configurable via `rowIdKey`)
2. **Builder Pattern**: TableColumnsBuilder prevents order conflicts and manages column ordering automatically
3. **Synchronized Scrolling**: Custom scroll controller synchronization between header and body
4. **Theme Composition**: Nested theme classes (TablePlusTheme, TablePlusHeaderTheme, etc.) for granular styling control
5. **State Management Ready**: Designed to work with state management solutions like Riverpod (see documentation/RIVERPOD_GENERATOR_GUIDE.md)

### Widget Lifecycle

FlutterTablePlus follows a composition pattern where:
- Header and body are separate widgets sharing synchronized scroll controllers
- Column reordering updates the column map and triggers rebuilds
- Selection state is managed externally and passed down as props
- Editing state can coexist with selection state

### Data Flow

1. Columns defined via TableColumnsBuilder or direct Map creation
2. Data provided as List of Maps with consistent keys matching column keys
3. User interactions (sort, select, edit, reorder) flow through callback functions
4. External state management handles data updates and passes back to widget

## Important Implementation Details

- **Column Order Management**: Column order is managed by the `order` field in TablePlusColumn. Use TableColumnsBuilder to prevent order conflicts
- **Selection Requirements**: Selection features require unique row ID field in each row data map (default: 'id', configurable via `rowIdKey` parameter) - duplicate IDs cause unexpected behavior
- **Null Safety for Features**: Setting `onSort: null` completely hides sort icons and disables sorting. Setting `onColumnReorder: null` disables drag-and-drop
- **Coexisting Features**: Selection and editing modes can coexist in the same table simultaneously
- **Theme Architecture**: Uses nested theme classes (TablePlusTheme > TablePlusHeaderTheme/TablePlusBodyTheme/etc.) for granular control
- **Custom Cell Rendering**: `cellBuilder` property allows rendering any Flutter widget in cells but can impact performance with large datasets
- **Sort Cycle Configuration**: Sort cycle order is configurable between ascending-first and descending-first patterns
- **Row Height Management**: Supports both uniform and dynamic row height modes. Dynamic mode calculates heights based on content when `textOverflow: TextOverflow.visible` is used
- **Tooltip Control**: Fine-grained tooltip behavior control for both cells and headers via `tooltipBehavior` and `headerTooltipBehavior` properties

## Code Patterns & Conventions

### Data Structure Requirements
- Row data: `List<Map<String, dynamic>>` where keys match column keys
- Selection feature: Each row must have unique row ID field (default: 'id', configurable via `rowIdKey`)
- Column definitions: Use `TableColumnsBuilder` for safe column creation

### Widget Composition Pattern
- Header and body are separate widgets with synchronized scroll controllers
- State is managed externally and passed down through props
- Callbacks flow user interactions (sort, select, edit, reorder) back to parent

### Performance Considerations
- Use simple text cells when possible; `cellBuilder` sparingly for complex widgets
- Consider pagination for 1000+ rows
- TableColumnsBuilder prevents order conflicts during column management

## Documentation Structure

Comprehensive documentation is available in the `documentation/` directory:
- EDITING.md: Cell editing implementation
- SELECTION.md: Row selection patterns  
- SORTING.md: Column sorting configuration
- THEMING.md: Complete theming guide
- ADVANCED_COLUMNS.md: Advanced column features
- EMPTY_STATE.md: Handling empty table states
- RIVERPOD_GENERATOR_GUIDE.md: State management integration

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.