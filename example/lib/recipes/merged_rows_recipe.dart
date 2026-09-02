/// Merged rows — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Several data rows drawn as one row, for the columns you say so.
///
/// **Groups are supplied, never inferred.** The package does not look at your
/// data and decide that two rows belong together — you hand it a
/// [MergedRowGroup] with the row ids it covers, and it draws them merged. Which
/// means grouping is your query, your sort, and your definition of "the same",
/// exactly like sorting and filtering are. The list below groups by department
/// because that is what this data has; nothing about it is a convention.
///
/// **Merging is per column, not per row.** [MergeCellConfig] decides, for one
/// column of one group, whether the cells collapse into one. So a group can
/// merge the column the rows agree on and keep the ones where they differ,
/// which is the whole point: the department is written once, the four people in
/// it are still four rows of names and salaries.
///
/// A merged cell shows either the value from one member row —
/// [MergeCellConfig.spanningRowIndex] picks which, defaulting to the first — or
/// a widget you supply as `mergedContent`. Supplying one replaces the value
/// rather than decorating it.
///
/// **A group is one row for layout and several rows for data**, and every
/// consequence of this feature follows from that sentence:
///
/// - **Selection reports the group id.** Click a merged row and
///   `onRowSelectionChanged` fires once, with `groupId`, not once per member.
///   That id lands in the same `Set<String>` your row ids do, so pick a shape
///   that cannot collide — `dept_Engineering` here, never a bare name that
///   might also be somebody's row id. The strip below shows what actually
///   arrives. A drag across the group reports the same way — but this recipe
///   wires no drag selection, so take that from the drag-selection recipe,
///   which does, rather than from a sentence here.
/// - **A merged row carries no row card.** There is no single row to build one
///   from, so the package returns the row unwrapped before it calls your
///   builder. Not a setting; a consequence.
/// - **Its height is the sum of its members' heights**, not one row's — so a
///   merged group sitting over rows with per-row heights is as tall as those
///   rows were — plus one `bodyTheme.rowHeight` while it is expanded, for the
///   summary row. And each *member* is drawn at its own measured height inside
///   that total — a 48/96/48 group is 192 tall and its members are 48, 96 and 48,
///   not three 64s. Until 2.17.0 they were three 64s (#121).
/// - **This recipe cannot show you that**, because it passes no
///   `calculateRowHeight` — every row here is `bodyTheme.rowHeight`, and an equal
///   split and a per-member one are the same picture. The proof is
///   `test/merged_row_member_heights_test.dart`, which renders the same rows
///   twice, once grouped and once not, and compares them.
///
/// **Expansion is your state, and so is the affordance.** [MergedRowGroup
/// .isExpanded] adds a summary row beneath the group — it does *not* hide the
/// member rows, which is the opposite of what "expand" suggests and the one
/// place this API's vocabulary will mislead you. The package draws no
/// expand/collapse control anywhere, so the chevron below is a plain
/// [IconButton] this recipe put inside `mergedContent` and wired to its own
/// `setState`. That is not a workaround: the group is an immutable value you
/// rebuild, so the state has to live where the data does.
class MergedRowsRecipe extends StatefulWidget {
  const MergedRowsRecipe({super.key, this.merged = true});

  /// Whether the groups are handed to the table at all.
  ///
  /// Passing an empty list is how you turn merging off — there is no `enabled`
  /// flag, because a group list *is* the feature.
  final bool merged;

  @override
  State<MergedRowsRecipe> createState() => _MergedRowsRecipeState();
}

class _MergedRowsRecipeState extends State<MergedRowsRecipe> {
  /// Three departments of three, deterministic so the groups are the same shape
  /// every time the page opens. Everything else about these people is random.
  static const List<String> _departments = [
    'Engineering',
    'Engineering',
    'Engineering',
    'Design',
    'Design',
    'Design',
    'Research',
    'Research',
    'Research',
  ];

  static final List<Employee> _rows = [
    for (final (index, employee)
        in RandomDataGenerator.generateEmployees(_departments.length).indexed)
      employee.copyWith(department: _departments[index]),
  ];

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;
  static Object? _salary(Employee e) => e.salary;

  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'department',
              const TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 210,
                valueAccessor: _department,
              ),
            )
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
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 200,
                valueAccessor: _position,
              ),
            )
            ..addColumn(
              'salary',
              const TablePlusColumn<Employee>(
                key: 'salary',
                label: 'Salary',
                order: 0,
                width: 130,
                textAlign: TextAlign.right,
                valueAccessor: _salary,
              ),
            ))
          .build();

  /// The row ids and group ids the user has selected. One `Set<String>`, which
  /// is why a group id has to be a string a row id can never be.
  Set<String> _selected = {};

  /// Which groups are showing their summary row. Caller state, like everything
  /// else here.
  final Set<String> _expanded = {};

  /// One group per department, rebuilt on every build because a
  /// [MergedRowGroup] is immutable and `isExpanded` is part of it.
  List<MergedRowGroup<Employee>> get _groups {
    if (!widget.merged) return const [];

    final byDepartment = <String, List<Employee>>{};
    for (final employee in _rows) {
      byDepartment.putIfAbsent(employee.department, () => []).add(employee);
    }

    return [
      for (final entry in byDepartment.entries)
        MergedRowGroup<Employee>(
          // Prefixed so a group id can never be mistaken for a row id: they
          // share one namespace in every callback the table has.
          groupId: 'dept_${entry.key}',
          rowKeys: entry.value.map((e) => e.id).toList(),
          mergeConfig: {
            // Merged: one department label for the whole group, with the
            // expand control this recipe draws itself.
            'department': MergeCellConfig(
              shouldMerge: true,
              mergedContent: _GroupHeading(
                department: entry.key,
                count: entry.value.length,
                expanded: _expanded.contains('dept_${entry.key}'),
                onToggle: () => _toggleExpanded('dept_${entry.key}'),
              ),
            ),
            // Every other column is left out of `mergeConfig` entirely, which
            // is how a column stays per-row. `shouldMerge: false` says the same
            // thing more loudly; absence is the default.
          },
          isExpanded: _expanded.contains('dept_${entry.key}'),
          summaryBuilder: (columnKey) => _summaryFor(columnKey, entry.value),
        ),
    ];
  }

  void _toggleExpanded(String groupId) {
    setState(() {
      if (!_expanded.remove(groupId)) _expanded.add(groupId);
    });
  }

  /// What the summary row puts in each column. Returning null leaves that cell
  /// empty, which is what most columns want.
  Widget? _summaryFor(String columnKey, List<Employee> members) {
    if (columnKey == 'name') {
      return const Text('Total', style: TextStyle(fontWeight: FontWeight.w700));
    }
    if (columnKey == 'salary') {
      final total = members.fold<int>(0, (sum, e) => sum + e.salary);
      return Text(
        '$total',
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.w700),
      );
    }
    return null;
  }

  void _onSelectionChanged(String id, bool isSelected) {
    setState(() {
      final next = Set<String>.from(_selected);
      isSelected ? next.add(id) : next.remove(id);
      _selected = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectionStrip(merged: widget.merged, selected: _selected),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _rows,
            rowId: (employee) => employee.id,
            theme: demoTableTheme(Theme.of(context).brightness),
            mergedGroups: _groups,
            // On so the group-id rule has somewhere to show itself.
            isSelectable: true,
            selectionMode: SelectionMode.multiple,
            selectedRows: _selected,
            onRowSelectionChanged: _onSelectionChanged,
          ),
        ),
      ],
    );
  }
}

/// The merged cell's contents: the department, its size, and the control this
/// recipe draws because the package does not.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({
    required this.department,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  final String department;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onToggle,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          tooltip: expanded ? 'Hide the total' : 'Show the total',
          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        ),
        Flexible(
          child: Text(
            department,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// What the selection callback actually reported.
///
/// **This is the demo explaining itself; delete it when you paste.** "Selecting
/// a merged row reports the group id" is a claim about a callback, and a
/// callback has no on-screen consequence to point at — the rows highlight
/// either way. Printing the set is the only way to show the difference between
/// one `dept_Engineering` and three employee ids.
class _SelectionStrip extends StatelessWidget {
  const _SelectionStrip({required this.merged, required this.selected});

  final bool merged;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: scheme.surfaceContainerHighest,
      child: Text(
        selected.isEmpty
            ? merged
                ? 'click a merged row — one group id arrives, not three row ids'
                : 'merging is off; clicking a row reports that row'
            : 'selectedRows: ${selected.join(', ')}',
        style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
