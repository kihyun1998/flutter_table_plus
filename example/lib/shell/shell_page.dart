/// The shell — the page the rest of this example is built in.
library;

import 'package:flutter/material.dart';

import '../pages/playground/playground_page.dart';
import '../preview/device_wall.dart';
import '../preview/preview_frame.dart';
import '../preview/preview_stage.dart';
import '../preview/viewport_spec.dart';
import '../theme/theme_mode_button.dart';
import 'destinations/employee_demo.dart';
import 'destinations/recipe_destination.dart';
import 'recipe_catalog.dart';
import 'shell_destination.dart';
import 'shell_menu.dart';
import 'source_pane.dart';

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

  /// One per recipe, owned here so a recipe's selection and its knobs survive
  /// every rebuild of the shell around them.
  late final Map<String, RecipeDemo> _recipeDemos = {
    for (final recipe in recipeCatalog) recipe.featureId: RecipeDemo(recipe),
  };

  late final List<ShellDestination> _destinations = [
    StageDestination(
      id: 'employees',
      label: 'Employees',
      category: ShellCategory.recipes,
      stage: (context) => EmployeeDemoTable(demo: _employeeDemo),
      knobs: (context) => EmployeeDemoKnobs(demo: _employeeDemo),
    ),
    ...recipeDestinations(_recipeDemos),
    RouteDestination(
      id: 'playground',
      label: 'Every setting',
      category: ShellCategory.playground,
      open: (context) => const PlaygroundPage(),
    ),
  ];

  late String _selectedId =
      _destinations.whereType<StageDestination>().first.id;

  /// A [ViewportSpec.id], or [ViewportBar.wallId] for the Device Wall.
  String _viewportId = ViewportSpec.desktop.id;

  bool get _showingWall => _viewportId == ViewportBar.wallId;

  /// Shrink the whole viewport into view, rather than showing a 1:1 slice of it.
  ///
  /// The default, because the question the preview answers is "what does this
  /// look like on a desktop" — and a clipped 1:1 slice answers a different one.
  bool _fit = true;

  /// Whether the stage region is showing the open recipe's source instead of
  /// the recipe running.
  ///
  /// Kept across destination switches on purpose: a reader comparing two
  /// recipes' code should not have to press Code again for each one. It is
  /// ignored — and the control is not drawn — for a destination with no source.
  bool _showCode = false;

  @override
  void dispose() {
    _employeeDemo.dispose();
    for (final demo in _recipeDemos.values) {
      demo.dispose();
    }
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
    final source = _open.source;
    final showingCode = _showCode && source != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              if (source != null)
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Preview'),
                      icon: Icon(Icons.play_arrow_outlined, size: 17),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Code'),
                      icon: Icon(Icons.code, size: 17),
                    ),
                  ],
                  selected: {showingCode},
                  onSelectionChanged: (s) =>
                      setState(() => _showCode = s.first),
                ),
              const Spacer(),
              // Source has no viewport, and no fit factor either. Leaving these
              // on screen over a block of code would say the code was being
              // rendered at 390px, which is not a thing that happens.
              if (!showingCode) ...[
                // The wall has no fit control for the same kind of reason. A
                // wall column is whatever a third of this region happens to
                // be, so 1:1 there would be three clipped slices at three
                // arbitrary widths — a control that can only make the view
                // worse is one the toolbar should not be offering.
                if (!_showingWall) ...[
                  Tooltip(
                    message: _fit
                        ? 'Shrink the whole viewport into view'
                        : 'Show real pixels and scroll',
                    child: TextButton.icon(
                      onPressed: () => setState(() => _fit = !_fit),
                      icon: Icon(
                        _fit ? Icons.fit_screen_outlined : Icons.crop_free,
                        size: 18,
                      ),
                      label: Text(_fit ? 'Fit' : '1:1'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ViewportBar(
                  compact: true,
                  // Unconditional, and only correct while every destination is
                  // a single table. The very-large-row-count scenario (#109) is
                  // mutually exclusive with the wall: that scenario is a
                  // single-table performance claim and the wall draws three
                  // tables over the same data, so a frame rate measured there
                  // is measuring the wall. When it lands this becomes
                  // `showsWall: _open.allowsWall` or equivalent.
                  //
                  // The exclusion is already reachable without #109 —
                  // `EmployeeDemo` offers 20 000 rows and its knobs sit outside
                  // the wall's `IgnorePointer` — which is recorded in
                  // `docs/map/territory/example-app.md` under Known holes.
                  showsWall: true,
                  selectedId: _viewportId,
                  onChanged: (id) => setState(() => _viewportId = id),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: showingCode
              // Beside the frame, not inside it. A `PreviewFrame` would scale
              // the source to whatever factor fits 1440px into the pane and
              // then clip it to a phone, which is unreadable and answers a
              // question nobody asked.
              ? SourcePane(assetPath: source)
              : ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: _showingWall
                      // The builder, not `_open.stage(context)`. Three frames
                      // over one built widget would hand the same subtree to
                      // three places in the tree; the wall wants three
                      // layouts over one set of knobs, which is the destination
                      // built three times.
                      ? DeviceWall(stage: _open.stage)
                      : PreviewFrame(
                          spec: ViewportSpec.byId(_viewportId),
                          fit: _fit,
                          child: _open.stage(context),
                        ),
                ),
        ),
      ],
    );
  }
}
