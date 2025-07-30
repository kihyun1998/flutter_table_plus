# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Table Plus is a highly customizable and efficient table widget for Flutter that provides synchronized scrolling, theming, sorting, selection, column reordering, and cell editing capabilities. The package is structured as a Flutter library with comprehensive documentation and examples.

## Common Development Commands

### Testing
```bash
flutter test                    # Run all tests
flutter test test/flutter_table_plus_test.dart  # Run specific test file
```

### Code Quality
```bash
flutter analyze                 # Run static analysis using analysis_options.yaml
dart format .                   # Format code according to Dart style
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

### Code Generation (when using Riverpod Generator)
```bash
dart run build_runner build     # Generate code once
dart run build_runner watch     # Watch for changes and generate code
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
- **`lib/src/models/table_theme.dart`**: Comprehensive theming system with nested theme classes

### Key Architectural Patterns

1. **Map-based Data Structure**: Tables use `List<Map<String, dynamic>>` for row data, requiring unique 'id' fields for selection features
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

- Column order is managed by the `order` field in TablePlusColumn
- Selection requires unique 'id' field in each row data map
- TableColumnsBuilder automatically handles order assignment to prevent conflicts
- Theming uses a nested structure for different table sections
- Custom cell builders allow rendering any Flutter widget in cells
- Sort cycle order is configurable (ascending-first or descending-first)

## Documentation Structure

Comprehensive documentation is available in the `documentation/` directory:
- EDITING.md: Cell editing implementation
- SELECTION.md: Row selection patterns  
- SORTING.md: Column sorting configuration
- THEMING.md: Complete theming guide
- ADVANCED_COLUMNS.md: Advanced column features
- RIVERPOD_GENERATOR_GUIDE.md: State management integration