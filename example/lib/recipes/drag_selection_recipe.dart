/// Drag selection — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Drag across rows to select them.
///
/// **Four things must all be true or no drag handler is attached at all** —
/// silently, with no error and no warning, and dragging simply does nothing:
///
/// ```dart
/// enableDragSelection == true
/// isSelectable == true
/// selectionMode == SelectionMode.multiple
/// onDragSelectionUpdate != null          // ← the one everybody forgets
/// ```
///
/// That last term is not a convenience. It is part of the activation
/// condition, and omitting it is how the example's own viewport lab shipped
/// with drag selection inert through an entire green test suite. Three of the
/// four are invisible on screen, which is why this recipe draws them: see
/// [_WiringStrip], the one part of this file that is demo scaffolding rather
/// than table code.
///
/// The two callbacks do different jobs. [FlutterTablePlus.onDragSelectionUpdate]
/// fires continuously while the pointer moves and carries the whole set the
/// band currently covers — so the natural thing to do with it is *replace* your
/// set, not add to it. [FlutterTablePlus.onDragSelectionEnd] fires once, on
/// release, which is where a commit or an undo entry belongs.
class DragSelectionRecipe extends StatefulWidget {
  const DragSelectionRecipe({super.key, this.dragSelection = true});

  /// The one term of the four this recipe puts on a knob.
  final bool dragSelection;

  @override
  State<DragSelectionRecipe> createState() => _DragSelectionRecipeState();
}

class _DragSelectionRecipeState extends State<DragSelectionRecipe> {
  /// Columns totalling 560px, so the band has room to cross more than one.
  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'name',
              const TablePlusColumn<Employee>(
                key: 'name',
                label: 'Name',
                order: 0,
                width: 170,
                valueAccessor: _name,
              ),
            )
            ..addColumn(
              'department',
              const TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 160,
                valueAccessor: _department,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 230,
                valueAccessor: _position,
              ),
            ))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;

  late final List<Employee> _employees =
      RandomDataGenerator.generateEmployees(20);

  Set<String> _selected = {};

  /// How many times the drag finished. Shown so that the difference between the
  /// two callbacks is visible rather than asserted.
  int _completedDrags = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WiringStrip(
          dragSelection: widget.dragSelection,
          selected: _selected.length,
          completedDrags: _completedDrags,
        ),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _employees,
            rowId: (employee) => employee.id,
            theme: demoTableTheme(Theme.of(context).brightness),
            isSelectable: true,
            selectionMode: SelectionMode.multiple,
            selectedRows: _selected,
            onRowSelectionChanged: (rowId, isSelected) {
              setState(() {
                _selected = {..._selected};
                if (isSelected) {
                  _selected.add(rowId);
                } else {
                  _selected.remove(rowId);
                }
              });
            },
            enableDragSelection: widget.dragSelection,
            // Continuous, and it carries the whole covered set — so replace.
            // Adding here would make the band unable to shrink.
            onDragSelectionUpdate: (ids) =>
                setState(() => _selected = Set.of(ids)),
            // Once, on release. A commit or an undo entry belongs here.
            onDragSelectionEnd: (ids) => setState(() {
              _selected = Set.of(ids);
              _completedDrags++;
            }),
          ),
        ),
      ],
    );
  }
}

/// The activation condition, drawn.
///
/// **This is the demo explaining itself; delete it when you paste.** It exists
/// because three of the four terms have no on-screen consequence until they are
/// all satisfied at once, so a reader who turns the knob off sees a table that
/// looks completely normal and does nothing.
class _WiringStrip extends StatelessWidget {
  const _WiringStrip({
    required this.dragSelection,
    required this.selected,
    required this.completedDrags,
  });

  final bool dragSelection;
  final int selected;
  final int completedDrags;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The other three are constants in this file, so they are constants here.
    final terms = <String, bool>{
      'enableDragSelection': dragSelection,
      'isSelectable': true,
      'multiple': true,
      'onDragSelectionUpdate': true,
    };
    final wired = terms.values.every((v) => v);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: scheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            wired ? 'drag is wired' : 'drag does nothing',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: wired ? scheme.onSurface : scheme.error,
            ),
          ),
          for (final term in terms.entries)
            Text(
              '${term.value ? '✓' : '✗'} ${term.key}',
              style: TextStyle(
                fontSize: 11.5,
                color: term.value ? scheme.onSurfaceVariant : scheme.error,
              ),
            ),
          Text(
            '· $selected selected · $completedDrags drags completed',
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
