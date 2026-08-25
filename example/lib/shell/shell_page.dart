/// The shell — the page the rest of this example is built in.
library;

import 'package:flutter/material.dart';

import '../pages/playground/playground_page.dart';
import '../preview/preview_stage.dart';
import '../preview/viewport_spec.dart';
import '../theme/theme_mode_button.dart';
import 'destinations/employee_demo.dart';
import 'shell_destination.dart';
import 'shell_menu.dart';

/// Three regions: a category menu, a preview stage, and a knob region.
///
/// The menu points at destinations; a destination fills the other two. That
/// division is what makes the shell reusable — nothing here knows what a recipe
/// or a scenario is, only that a destination supplies a stage and some knobs.
///
/// **The playground is pointed at, not absorbed.** It is a full page with its own
/// app bar and its own three panes, and hosting it inside the stage would mean
/// taking it apart. It opens on the route it already has, working exactly as it
/// does today, and `pages/playground/` is untouched by this ticket.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  /// Below this the three regions do not fit side by side, and the shell shows
  /// one at a time instead. Measured against the widest of them plus the stage's
  /// narrowest viewport, not chosen for the shape of any particular device.
  static const narrowBreakpoint = 900.0;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  final _employeeDemo = EmployeeDemo();

  late final List<ShellDestination> _destinations = [
    StageDestination(
      id: 'employees',
      label: 'Employees',
      category: ShellCategory.recipes,
      stage: (context) => EmployeeDemoTable(demo: _employeeDemo),
      knobs: (context) => EmployeeDemoKnobs(demo: _employeeDemo),
    ),
    RouteDestination(
      id: 'playground',
      label: 'Every setting',
      category: ShellCategory.playground,
      open: (context) => const PlaygroundPage(),
    ),
  ];

  late String _selectedId =
      _destinations.whereType<StageDestination>().first.id;
  ViewportSpec _viewport = ViewportSpec.desktop;

  @override
  void dispose() {
    _employeeDemo.dispose();
    super.dispose();
  }

  StageDestination get _open => _destinations
      .whereType<StageDestination>()
      .firstWhere((d) => d.id == _selectedId);

  void _select(ShellDestination destination) {
    switch (destination) {
      case RouteDestination(:final open):
        Navigator.of(context).push(MaterialPageRoute<void>(builder: open));
      case StageDestination(:final id):
        setState(() => _selectedId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Plus'),
        actions: const [ThemeModeButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < ShellPage.narrowBreakpoint;
          return narrow ? _narrow(context) : _wide(context);
        },
      ),
    );
  }

  Widget _wide(BuildContext context) {
    return Row(
      children: [
        ShellMenu(
          destinations: _destinations,
          selectedId: _selectedId,
          onSelected: _select,
        ),
        Expanded(child: _stageRegion(context)),
        Container(
          width: 320,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: _open.knobs(context),
        ),
      ],
    );
  }

  /// One region at a time, chosen by a tab bar.
  ///
  /// Not a narrower version of the wide layout: three columns squeezed into a
  /// phone gives three unusable columns. The regions are the same widgets, shown
  /// one at a time.
  Widget _narrow(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Menu'),
              Tab(text: 'Preview'),
              Tab(text: 'Knobs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ShellMenu(
                  destinations: _destinations,
                  selectedId: _selectedId,
                  onSelected: _select,
                  width: double.infinity,
                ),
                _stageRegion(context),
                _open.knobs(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageRegion(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ViewportBar(
              selected: _viewport,
              onChanged: (v) => setState(() => _viewport = v),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: scheme.surfaceContainerHighest,
            // Centred while it fits, scrolling once it does not. The stage is
            // never scaled: a transform above the table would put the
            // drag-selection coordinate frame in question, and #101 measured
            // that a scaled stage is not pointer-equivalent to an unscaled one.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outline),
                            color: scheme.surface,
                          ),
                          child: PreviewStage(
                            spec: _viewport,
                            child: _open.stage(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
