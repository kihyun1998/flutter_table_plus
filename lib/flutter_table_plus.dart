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
/// - **Hover Buttons:** Interactive action buttons that appear on row hover
/// - **Expandable Rows:** Collapsible summary rows for merged row groups
/// - **Merged Rows:** Visual grouping of multiple data rows with custom content
/// - **Custom Cell Builders:** Custom widget rendering in cells
/// - **Type-Safe Column Builder:** Use `TableColumnsBuilder` for safe column management
library;

export 'src/models/hover_button_position.dart';
export 'src/models/merged_row_group.dart';

/// Models
export 'src/models/table_column.dart';
export 'src/models/table_columns_builder.dart';

/// Theme
export 'src/models/theme/body_theme.dart';
export 'src/models/theme/checkbox_theme.dart';
export 'src/models/theme/editable_theme.dart';
export 'src/models/theme/header_theme.dart';
export 'src/models/theme/hover_button_theme.dart';
export 'src/models/theme/scrollbar_theme.dart';
export 'src/models/theme/selection_theme.dart';
export 'src/models/theme/theme.dart';
export 'src/models/theme/tooltip_theme.dart';
export 'src/models/tooltip_behavior.dart';

/// Utilities
export 'src/utils/table_row_height_calculator.dart';

/// Widgets
export 'src/widgets/custom_ink_well.dart';
export 'src/widgets/flutter_table_plus.dart';
