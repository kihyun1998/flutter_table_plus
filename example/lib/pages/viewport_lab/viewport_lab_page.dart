/// One table, three viewports, and nothing else.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../demo_data/demo_data.dart';
import '../../preview/preview_stage.dart';
import '../../preview/viewport_spec.dart';
import '../../theme/table_palette.dart';
import '../../theme/theme_mode_button.dart';

/// The viewport lab.
///
/// This page exists to settle one question before anything is built on it: does
/// a table constrained by [PreviewStage] behave like a genuinely narrow table,
/// drag selection included. It carries no sidebar, no recipes and no knobs, so
/// that a failure here is a failure of the stage and not of a shell around it.
///
/// It builds without an `ExampleThemeScope` above it, like every other page in
/// this example — the theme control draws nothing when there is none.
class ViewportLabPage extends StatefulWidget {
  const ViewportLabPage({super.key});

  @override
  State<ViewportLabPage> createState() => _ViewportLabPageState();
}

class _ViewportLabPageState extends State<ViewportLabPage> {
  ViewportSpec _viewport = ViewportSpec.desktop;
  Set<String> _selected = {};

  /// Generated once, at first build, and never again.
  ///
  /// `late final` rather than a field initialised in `initState` for brevity,
  /// but the property that matters is the same: switching viewport must not
  /// change the rows. The lab answers a layout question, and data that moved
  /// underneath a viewport switch would be one more thing that could explain a
  /// difference between two frames.
  late final List<Employee> _rows = RandomDataGenerator.generateEmployees(24);

  late final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
                'name',
                TablePlusColumn<Employee>(
                  key: 'name',
                  label: 'Name',
                  order: 0,
                  width: 160,
                  valueAccessor: (e) => e.name,
                ))
            ..addColumn(
                'department',
                TablePlusColumn<Employee>(
                  key: 'department',
                  label: 'Department',
                  order: 0,
                  width: 150,
                  valueAccessor: (e) => e.department,
                ))
            ..addColumn(
                'position',
                TablePlusColumn<Employee>(
                  key: 'position',
                  label: 'Position',
                  order: 0,
                  width: 150,
                  valueAccessor: (e) => e.position,
                ))
            ..addColumn(
                'email',
                TablePlusColumn<Employee>(
                  key: 'email',
                  label: 'Email',
                  order: 0,
                  width: 220,
                  valueAccessor: (e) => e.email,
                ))
            ..addColumn(
                'salary',
                TablePlusColumn<Employee>(
                  key: 'salary',
                  label: 'Salary',
                  order: 0,
                  width: 120,
                  textAlign: TextAlign.right,
                  valueAccessor: (e) => e.salary,
                )))
          .build();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewport lab'),
        actions: const [ThemeModeButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ViewportBar(
                  selected: _viewport,
                  onChanged: (v) => setState(() => _viewport = v),
                ),
                Text(
                  _selected.isEmpty
                      ? 'no rows selected'
                      : '${_selected.length} selected',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: scheme.surfaceContainerHighest,
              // Centred while it fits, scrolling once it does not — the stage is
              // never scaled to make it fit, because a transform above the table
              // would put the drag-selection coordinate frame in question, and
              // keeping that question closed is the whole point of this page.
              //
              // `ConstrainedBox` with the viewport's own minimums is what makes
              // both true at once: the child is at least as big as the space, so
              // `Center` has something to centre within, and bigger than it when
              // the viewport is wider, so the scroll view has somewhere to go.
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
                          padding: const EdgeInsets.all(24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: scheme.outline),
                              color: scheme.surface,
                            ),
                            child: PreviewStage(
                              spec: _viewport,
                              child: _table(),
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
      ),
    );
  }

  Widget _table() {
    return FlutterTablePlus<Employee>(
      // The table wears the demo's palette and follows the app's brightness.
      // Omitting this is not a smaller version of the same page: the table
      // falls back to the package defaults, which are light, and a dark app
      // then draws a white table. Nothing errors — it just looks wrong, and
      // only in one of the two themes.
      theme: demoTableTheme(Theme.of(context).brightness),
      columns: _columns,
      data: _rows,
      rowId: (e) => e.id,
      isSelectable: true,
      selectionMode: SelectionMode.multiple,
      enableDragSelection: true,
      selectedRows: _selected,
      onRowSelectionChanged: (id, selected) {
        setState(() {
          selected ? _selected.add(id) : _selected.remove(id);
        });
      },
      // Both callbacks, and the update one is not optional: the table wires the
      // drag handlers only when `enableDragSelection && isSelectable &&
      // selectionMode == multiple && onDragSelectionUpdate != null`. Omit it and
      // dragging silently does nothing — no error, no warning, just a gesture
      // that never arrives.
      onDragSelectionUpdate: (ids) => setState(() => _selected = Set.of(ids)),
      onDragSelectionEnd: (ids) => setState(() => _selected = Set.of(ids)),
    );
  }
}
