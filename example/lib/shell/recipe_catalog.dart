/// Which recipes exist, what each one demonstrates, and where its source is.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../pages/playground/models/playground_settings.dart';
import '../pages/playground/models/settings_spec.dart';
import '../recipes/cell_editing_recipe.dart';
import '../recipes/column_reorder_recipe.dart';
import '../recipes/column_resize_recipe.dart';
import '../recipes/drag_selection_recipe.dart';
import '../recipes/dynamic_row_height_recipe.dart';
import '../recipes/merged_rows_recipe.dart';
import '../recipes/row_card_recipe.dart';
import '../recipes/selection_recipe.dart';
import '../recipes/sorting_recipe.dart';
import '../recipes/tooltips_recipe.dart';
import '../recipes/zoom_recipe.dart';

/// One feature, demonstrated in one self-contained file.
///
/// **The dependency points this way on purpose.** The catalogue names a
/// feature; the feature knows nothing about recipes. Hanging a recipe reference
/// off [SettingFeature] would point the playground's description at the shell —
/// the general at the specific — and would mean editing `pages/playground/`,
/// which this series does not do. Naming the feature from here gives the same
/// invariant (`test/recipe_seam_test.dart` insists every [featureId] exists)
/// in the honest direction.
///
/// A feature with no recipe simply is not listed. That is a data fact, not an
/// error: recipes arrive one ticket at a time and the menu shows what is here.
class Recipe {
  const Recipe({
    required this.featureId,
    required this.source,
    required this.build,
  });

  /// The [SettingFeature] this demonstrates. Its title names the menu entry and
  /// its options are the knobs, so neither is written twice.
  final String featureId;

  /// This recipe's own source file, relative to `example/`, and declared as an
  /// asset so it can be read back at runtime.
  ///
  /// The point is that what is on screen and what runs cannot disagree: the
  /// panel reads the bundled file rather than a copy someone pasted into a
  /// string. `test/recipe_seam_test.dart` insists the path exists and is
  /// covered by an asset declaration.
  final String source;

  /// The recipe, wired from the settings its feature owns — and only those.
  final Widget Function(PlaygroundSettings settings) build;

  /// The feature this recipe demonstrates.
  SettingFeature get feature => featureById(featureId);

  /// The settings ids this recipe's knob pane will draw: the feature's switch,
  /// and the options that only mean something once it is on.
  List<String> get knobIds => [
        if (feature.switchId != null) feature.switchId!,
        ...feature.options,
      ];
}

/// Every recipe, in the order the menu lists them.
final List<Recipe> recipeCatalog = [
  Recipe(
    featureId: 'selection',
    source: 'lib/recipes/selection_recipe.dart',
    build: (settings) => SelectionRecipe(
      selectable: settings.selectionEnabled,
      selectionMode: settings.selectionMode,
      showCheckboxColumn: settings.showCheckboxColumn,
      selectAllEnabled: settings.selectAllEnabled,
      showRowCheckbox: settings.showRowCheckbox,
      cellTapTogglesCheckbox: settings.cellTapTogglesCheckbox,
    ),
  ),
  Recipe(
    featureId: 'sorting',
    source: 'lib/recipes/sorting_recipe.dart',
    build: (settings) => SortingRecipe(
      sortable: settings.sortingEnabled,
      sortCycleOrder: settings.sortCycleOrder,
    ),
  ),
  Recipe(
    featureId: 'dragSelection',
    source: 'lib/recipes/drag_selection_recipe.dart',
    build: (settings) => DragSelectionRecipe(
      dragSelection: settings.dragSelectionEnabled,
    ),
  ),
  Recipe(
    featureId: 'editing',
    source: 'lib/recipes/cell_editing_recipe.dart',
    build: (settings) => CellEditingRecipe(
      editable: settings.editingEnabled,
    ),
  ),
  Recipe(
    featureId: 'columnReorder',
    source: 'lib/recipes/column_reorder_recipe.dart',
    build: (settings) => ColumnReorderRecipe(
      reorderEnabled: settings.columnReorderEnabled,
    ),
  ),
  Recipe(
    featureId: 'resizing',
    source: 'lib/recipes/column_resize_recipe.dart',
    build: (settings) => ColumnResizeRecipe(
      resizable: settings.resizableEnabled,
      columnMinWidth: settings.columnMinWidth,
      stretchLastColumn: settings.stretchLastColumn,
      handleWidth: settings.resizeHandleWidth,
      handleThickness: settings.resizeHandleThickness,
      handleIndent: settings.resizeHandleIndent,
      handleEndIndent: settings.resizeHandleEndIndent,
    ),
  ),
  Recipe(
    featureId: 'zoom',
    source: 'lib/recipes/zoom_recipe.dart',
    build: (settings) => ZoomRecipe(
      scale: settings.scale,
      blockModifierScroll: settings.blockModifierScroll,
    ),
  ),
  Recipe(
    featureId: 'tooltips',
    source: 'lib/recipes/tooltips_recipe.dart',
    build: (settings) => TooltipsRecipe(
      enabled: settings.tooltipEnabled,
      behavior: settings.tooltipBehavior,
      headerBehavior: settings.headerTooltipBehavior,
      waitDuration: Duration(milliseconds: settings.tooltipWaitDurationMs),
      direction: settings.tooltipDirection,
      alignment: settings.tooltipAlignment,
      anchor: settings.tooltipAnchor,
      // The playground's three-way choice becomes a nullable anchor, because
      // that is what the package's API actually is: null *is* "follow the
      // cells". The enum exists in the settings layer so a radio group has
      // three labels to draw; translating it here is what keeps a recipe from
      // importing a settings type it is not allowed to see.
      headerAnchor: switch (settings.headerTooltipAnchor) {
        HeaderTooltipAnchor.followCells => null,
        HeaderTooltipAnchor.child => TooltipAnchor.child,
        HeaderTooltipAnchor.pointer => TooltipAnchor.pointer,
      },
      showArrow: settings.tooltipShowArrow,
      offset: settings.tooltipOffset,
      showFormatter: settings.showTooltipFormatter,
      showBuilder: settings.showTooltipBuilder,
    ),
  ),
  Recipe(
    featureId: 'rowCard',
    source: 'lib/recipes/row_card_recipe.dart',
    build: (settings) => RowCardRecipe(
      enabled: settings.rowCardTooltip,
      waitDuration: Duration(milliseconds: settings.rowCardWaitDurationMs),
    ),
  ),
  Recipe(
    featureId: 'mergedRows',
    source: 'lib/recipes/merged_rows_recipe.dart',
    build: (settings) => MergedRowsRecipe(
      merged: settings.mergedRowsEnabled,
    ),
  ),
  Recipe(
    featureId: 'dynamicRowHeight',
    source: 'lib/recipes/dynamic_row_height_recipe.dart',
    build: (settings) => DynamicRowHeightRecipe(
      perRowHeight: settings.dynamicRowHeight,
    ),
  ),
];
