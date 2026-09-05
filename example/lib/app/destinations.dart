/// What this example asks the shell to show.
library;

import '../gallery/gallery.dart';
import '../pages/playground/playground_page.dart';
import '../pages/tooltip_anchor/tooltip_anchor_page.dart';
import '../scenarios/hr_dashboard_scenario.dart';
import '../scenarios/large_table_scenario.dart';
import 'employee_demo.dart';
import 'recipe_catalog.dart';
import 'recipe_destination.dart';

/// The destinations of *this* app, and the demo state behind them.
///
/// Everything the shell used to hold as its own fields lives here now. The split
/// is the point: `ShellPage` draws a menu, a stage and a knob region and knows
/// nothing about tables, and this file knows nothing about layout.
///
/// The demos are created with this object and disposed with it, which is the
/// lifetime they had as fields of the shell's state — see [ShellDestinations].
class TablePlusDestinations implements ShellDestinations {
  TablePlusDestinations();

  final _employeeDemo = EmployeeDemo();

  /// One per recipe, owned here so a recipe's selection and its knobs survive
  /// every rebuild of the shell around them.
  late final Map<String, RecipeDemo> _recipeDemos = {
    for (final recipe in recipeCatalog) recipe.featureId: RecipeDemo(recipe),
  };

  final _hrDashboard = HrDashboardDemo();
  final _largeTable = LargeTableDemo();

  @override
  late final List<ShellDestination> all = [
    StageDestination(
      id: 'employees',
      label: 'Employees',
      category: ShellCategory.recipes,
      stage: (context) => EmployeeDemoTable(demo: _employeeDemo),
      knobs: (context) => EmployeeDemoKnobs(demo: _employeeDemo),
    ),
    ...recipeDestinations(_recipeDemos),
    StageDestination(
      id: 'scenario/hr-dashboard',
      label: 'HR dashboard',
      category: ShellCategory.scenarios,
      stage: (context) => HrDashboardStage(demo: _hrDashboard),
      knobs: (context) => HrDashboardKnobs(demo: _hrDashboard),
    ),
    StageDestination(
      id: 'scenario/large-table',
      label: 'A hundred thousand rows',
      category: ShellCategory.scenarios,
      stage: (context) => LargeTableStage(demo: _largeTable),
      knobs: (context) => LargeTableKnobs(demo: _largeTable),
      // The one destination the wall must not draw: three tables over the same
      // hundred thousand rows makes a frame rate a measurement of the wall.
      allowsWall: false,
    ),
    RouteDestination(
      id: 'playground',
      label: 'Every setting',
      category: ShellCategory.pages,
      open: (context) => const PlaygroundPage(),
    ),
    RouteDestination(
      id: 'tooltip-anchors',
      label: 'Tooltip anchors',
      category: ShellCategory.pages,
      // Pointed at rather than absorbed, for the same reason the playground is:
      // it is a full page with its own `Scaffold` and `AppBar`. It survives the
      // retirement of the old home list because it answers a question the
      // tooltips recipe structurally cannot — a recipe shows one configuration,
      // and this compares two (#147).
      open: (context) => const TooltipAnchorPage(),
    ),
  ];

  @override
  void dispose() {
    _employeeDemo.dispose();
    for (final demo in _recipeDemos.values) {
      demo.dispose();
    }
    _hrDashboard.dispose();
    _largeTable.dispose();
  }
}
