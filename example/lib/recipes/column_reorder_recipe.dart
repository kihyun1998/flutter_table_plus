/// Column reordering — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Drag a header cell sideways to move its column.
///
/// **The table does not move the column. It tells you where it was dropped.**
/// `onColumnReorder` hands back two indices and nothing changes until you
/// rewrite the columns and hand them down again — the same shape as `onSort`,
/// for the same reason: the package renders your column set, it does not own
/// one. Withholding the callback is what disables the drag; there is no
/// `reorderable` flag on the table.
///
/// Two facts about those indices are worth more than the rest of this file,
/// because both are invisible from the callback's signature:
///
/// **They index the columns as *displayed*, not as you stored them.** The table
/// sorts by [TablePlusColumn.order] and drops anything with `visible: false`
/// before it numbers anything, so `oldIndex` counts positions in that resolved
/// list. A map's own iteration order agrees with it only while nothing is
/// hidden and nothing has ever moved. [_reorder] therefore sorts before it
/// touches an index — which, in *this* file, is provably unnecessary and is
/// kept anyway: the set starts out builder-ordered and every reorder rebuilds
/// it in display order, so the two can never drift here. Deleting the sort
/// passes every test in this repository. It stays because a reader's column
/// set is not this one.
///
/// **The selection column is not in the count.** When selection is on the table
/// prepends a synthetic checkbox column at the front, and that one is excluded
/// from the numbering — index 0 is your first real column either way. Wiring
/// against the rendered list without allowing for that is an off-by-one that
/// only appears once someone turns selection on.
///
/// What you write back is `order`, not a list position: order is a property of
/// the column, which is why hiding a column and moving a column are independent
/// operations rather than two edits to the same list.
///
/// **The columns below are pinned, and that is what makes the last drop target
/// reachable.** [TablePlusColumn.width] is a *preference*, not a width: flexible
/// columns share whatever room is left in proportion to it, so four columns
/// totalling 820px render at 1500px wide in a 1500px viewport — and the strip of
/// empty header to the right of the last one, which is where you drop a column
/// to send it to the end, is then exactly zero pixels wide. Measured
/// 2026-08-26. Setting `maxWidth` equal to `width` opts a column out of the
/// distribution, which is the only lever there is. The empty band you see to the
/// right here is not slack; it is that drop target.
class ColumnReorderRecipe extends StatefulWidget {
  const ColumnReorderRecipe({super.key, this.reorderEnabled = true});

  /// Whether header cells can be dragged at all.
  final bool reorderEnabled;

  @override
  State<ColumnReorderRecipe> createState() => _ColumnReorderRecipeState();
}

class _ColumnReorderRecipeState extends State<ColumnReorderRecipe> {
  /// The column set, in state rather than in a `static final`, because
  /// reordering rewrites it. Every other recipe here can keep its columns
  /// constant; this is the one feature that cannot.
  late Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'name',
              const TablePlusColumn<Employee>(
                key: 'name',
                label: 'Name',
                order: 0,
                width: 220,
                maxWidth: 220,
                valueAccessor: _name,
              ),
            )
            ..addColumn(
              'department',
              const TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 200,
                maxWidth: 200,
                valueAccessor: _department,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 240,
                maxWidth: 240,
                valueAccessor: _position,
              ),
            )
            ..addColumn(
              'salary',
              const TablePlusColumn<Employee>(
                key: 'salary',
                label: 'Salary',
                order: 0,
                width: 160,
                maxWidth: 160,
                textAlign: TextAlign.right,
                valueAccessor: _salary,
              ),
            ))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;
  static Object? _salary(Employee e) => e.salary;

  late final List<Employee> _employees =
      RandomDataGenerator.generateEmployees(20);

  /// The columns in the order the table draws them.
  ///
  /// This is the index space `onColumnReorder` speaks in, so it is derived in
  /// one place and both the handler and the strip below read it from here.
  List<MapEntry<String, TablePlusColumn<Employee>>> get _displayed =>
      _columns.entries.where((e) => e.value.visible).toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final displayed = _displayed;
      final moved = displayed.removeAt(oldIndex);
      displayed.insert(newIndex, moved);

      // Renumber from 1: `TableColumnsBuilder` treats 0 and negatives as
      // reserved, and the table's own synthetic selection column uses -1. A
      // 0-based renumbering renders correctly today and collides the moment
      // this set goes back through the builder.
      _columns = {
        for (var i = 0; i < displayed.length; i++)
          displayed[i].key: displayed[i].value.copyWith(order: i + 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OrderStrip(
          enabled: widget.reorderEnabled,
          columns: _displayed,
        ),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _employees,
            rowId: (employee) => employee.id,
            theme: demoTableTheme(Theme.of(context).brightness),
            // Withheld, and the header cells stop being draggable. There is no
            // second flag to remember to turn off as well.
            onColumnReorder: widget.reorderEnabled ? _reorder : null,
          ),
        ),
      ],
    );
  }
}

/// The `order` values, drawn.
///
/// **This is the demo explaining itself; delete it when you paste.** The whole
/// of what a reorder changes is a number on each column, and a table that
/// simply redraws in the new order shows the effect while hiding the mechanism.
class _OrderStrip extends StatelessWidget {
  const _OrderStrip({required this.enabled, required this.columns});

  final bool enabled;
  final List<MapEntry<String, TablePlusColumn<Employee>>> columns;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: scheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            enabled
                ? 'drag a header — drop past the last one to send it to the end'
                : 'reorder is off',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: enabled ? scheme.onSurface : scheme.error,
            ),
          ),
          for (final entry in columns)
            Text(
              'order ${entry.value.order} · ${entry.key}',
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
