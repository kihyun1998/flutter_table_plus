/// A highly customizable and efficient table widget for Flutter.
///
/// This library provides a feature-rich table implementation with synchronized
/// scrolling, theming support, and flexible data handling through Map-based data.
///
/// ## Features
///
/// - **Highly Customizable Table:** Flexible and efficient table widget
/// - **Synchronized Scrolling:** Horizontal and vertical scrolling between header and body
/// - **Theming:** Extensive customization through `TablePlusTheme`
/// - **Column Sorting:** Sortable columns with custom sort logic
/// - **Row Selection:** Single or multiple row selection with checkboxes
/// - **Column Reordering:** Drag-and-drop column reordering
/// - **Cell Editing:** Inline text field editing for specific columns
/// - **Custom Cell Builders:** Custom widget rendering in cells
/// - **Type-Safe Column Builder:** Use `TableColumnsBuilder` for safe column management
library;

// Models
export 'src/models/table_column.dart';
export 'src/models/table_columns_builder.dart';
export 'src/models/table_theme.dart';
// Widgets
export 'src/widgets/custom_ink_well.dart';
export 'src/widgets/flutter_table_plus.dart';
