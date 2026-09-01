/// The package assembled into something that looks like a product.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// A people directory: departments merged, members sorted, rows selectable.
///
/// **What this is for.** Every recipe in this app shows one feature with
/// nothing else switched on, which is what makes a recipe readable and what
/// makes it unlike any real screen. This one turns four of them on at once —
/// merged groups, sorting, selection, and the app's own theme — because the
/// question it answers is not *does this feature work* but *what does it look
/// like when you assemble them*.
///
/// **The sort is per department, and that is the interesting part.** The table
/// asks you to sort and hands you back a column and a direction; what it does
/// *not* do is reconcile the new row order with `mergedGroups`, because those
/// are two caller lists and the package validates neither against the other. A
/// group is anchored, measured and drawn on the members that are actually
/// there — so a global sort by salary would interleave departments, and each
/// group would be drawn stacked at wherever its earliest surviving member
/// landed. Nothing would throw and nothing would warn; it would simply look
/// wrong.
///
/// So this screen sorts *inside* each department and rebuilds the groups from
/// the result. That is not a workaround for a package limitation — it is what
/// "group by department, sort by salary" means in an HR tool, and it is the
/// shape any consumer who merges and sorts together will arrive at.
///
/// **Everything here is caller state**, including the grouping itself. Groups
/// are supplied, never inferred: the department split below is this screen's
/// query, in exactly the way the sort is.
class HrDashboardDemo extends ChangeNotifier {
  HrDashboardDemo() {
    _rebuild();
  }

  /// The departments, in the order the screen lists them.
  ///
  /// Fixed rather than read off the data so the dashboard's shape does not
  /// change when the generator's random draw does — the reader is meant to be
  /// looking at the layout, not at which department happened to come first.
  static const List<String> departments = [
    'Engineering',
    'Design',
    'Sales',
    'Marketing',
  ];

  /// Five people per department. Generated once, deterministic since the
  /// generator is seeded per call, then re-labelled so the groups have the
  /// shape above.
  static final List<Employee> _people = [
    for (final (index, employee)
        in RandomDataGenerator.generateEmployees(departments.length * 5)
            .indexed)
      employee.copyWith(department: departments[index ~/ 5]),
  ];

  List<Employee> _rows = const [];
  List<Employee> get rows => _rows;

  List<MergedRowGroup<Employee>> _groups = const [];
  List<MergedRowGroup<Employee>> get groups => _grouped ? _groups : const [];

  bool _grouped = true;
  bool get grouped => _grouped;
  set grouped(bool value) {
    if (_grouped == value) return;
    _grouped = value;
    // A group id can only have arrived by clicking a merged row, and with the
    // groups gone there is no merged row left to click again. Leaving it in
    // would be visible state with no control able to change it — the same
    // failure `EmployeeDemo.selectable` clears for, on a new axis.
    if (!value) {
      _selected = {..._selected}..removeWhere((id) => id.startsWith(_groupPrefix));
    }
    // The sort changes meaning with this flag: inside each department while the
    // groups are drawn, across the whole table when they are not.
    _rebuild();
    notifyListeners();
  }

  static const _groupPrefix = 'dept_';

  String? _sortColumn;
  String? get sortColumn => _sortColumn;

  SortDirection _direction = SortDirection.none;
  SortDirection get direction => _direction;

  Set<String> _selected = {};
  Set<String> get selected => _selected;

  /// The people the header strip counts.
  ///
  /// A group id is in the same `Set<String>` as the row ids, so counting the
  /// set would count `dept_Engineering` as a person. The strip counts rows.
  Iterable<Employee> get selectedPeople =>
      _rows.where((e) => _selected.contains(e.id));

  /// The departments selected as departments.
  ///
  /// Counted separately rather than folded into [selectedPeople], because
  /// clicking a merged row reports the **group id** and not its five members —
  /// so a strip that only counted people said "20 across 4 departments", which
  /// reads as *nothing selected*, while a row sat highlighted on screen.
  Iterable<String> get selectedGroups =>
      _selected.where((id) => id.startsWith(_groupPrefix));

  void toggle(String id, bool on) {
    _selected = {..._selected};
    on ? _selected.add(id) : _selected.remove(id);
    notifyListeners();
  }

  void sort(String columnKey, SortDirection direction) {
    _sortColumn = direction == SortDirection.none ? null : columnKey;
    _direction = direction;
    _rebuild();
    notifyListeners();
  }

  /// Rows and groups, produced together from the same pass.
  ///
  /// **They are rebuilt in one place on purpose.** The failure this shape rules
  /// out is the ordinary one: sorting the rows and leaving the group list
  /// alone. The group would still hold the right ids, so nothing would error —
  /// it would just be anchored somewhere else on screen.
  void _rebuild() {
    final rows = <Employee>[];
    final groups = <MergedRowGroup<Employee>>[];

    for (final department in departments) {
      final members = _people.where((e) => e.department == department).toList();
      // Per department **while the groups are drawn**, and that condition is
      // load-bearing. Ungrouped, there is no merged cell left to explain why
      // salary ascends and resets four times, so the sort that is honest there
      // is the ordinary one across the whole table — applied below.
      if (_sortColumn != null && _grouped) _sortInPlace(members);

      rows.addAll(members);
      groups.add(
        MergedRowGroup<Employee>(
          // Prefixed so it can never collide with a row id — they share one
          // namespace in every callback the table has.
          groupId: '$_groupPrefix$department',
          rowKeys: members.map((e) => e.id).toList(),
          mergeConfig: {
            'department': MergeCellConfig(
              shouldMerge: true,
              mergedContent: _DepartmentCell(
                department: department,
                headcount: members.length,
                payroll: members.fold<int>(0, (sum, e) => sum + e.salary),
              ),
            ),
          },
        ),
      );
    }

    if (_sortColumn != null && !_grouped) _sortInPlace(rows);

    _rows = rows;
    _groups = groups;
  }

  void _sortInPlace(List<Employee> employees) {
    employees.sort((a, b) {
      final comparison = _compare(_sortColumn!, a, b);
      return _direction == SortDirection.ascending ? comparison : -comparison;
    });
  }

  static int _compare(String columnKey, Employee a, Employee b) =>
      switch (columnKey) {
        'salary' => a.salary.compareTo(b.salary),
        'performance' => a.performance.compareTo(b.performance),
        _ => a.name.compareTo(b.name),
      };
}

/// The stage half — a header strip and the table under it.
class HrDashboardStage extends StatelessWidget {
  const HrDashboardStage({super.key, required this.demo});

  final HrDashboardDemo demo;

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;
  static Object? _salary(Employee e) => e.salary;
  static Object? _performance(Employee e) => e.performance;

  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'department',
              const TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 190,
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
                sortable: true,
                valueAccessor: _name,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 190,
                valueAccessor: _position,
              ),
            )
            ..addColumn(
              'performance',
              TablePlusColumn<Employee>(
                key: 'performance',
                label: 'Performance',
                order: 0,
                width: 150,
                sortable: true,
                valueAccessor: _performance,
                // `statefulCellBuilder`, not a plain one: the package has a
                // single cell-builder seam and it hands over the selection and
                // dim flags whether or not a given cell reads them. This one
                // does not, and taking the four-argument form anyway is
                // cheaper than a second seam that differs by two booleans.
                statefulCellBuilder: (context, employee, isSelected, isDim) =>
                    _PerformanceBar(value: employee.performance),
              ),
            )
            ..addColumn(
              'salary',
              const TablePlusColumn<Employee>(
                key: 'salary',
                label: 'Salary',
                order: 0,
                width: 140,
                sortable: true,
                textAlign: TextAlign.right,
                valueAccessor: _salary,
              ),
            ))
          .build();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderStrip(demo: demo),
          Expanded(
            child: FlutterTablePlus<Employee>(
              theme: demoTableTheme(Theme.of(context).brightness),
              columns: _columns,
              data: demo.rows,
              rowId: (e) => e.id,
              mergedGroups: demo.groups,
              isSelectable: true,
              selectionMode: SelectionMode.multiple,
              selectedRows: demo.selected,
              onRowSelectionChanged: demo.toggle,
              onSort: demo.sort,
              sortColumnKey: demo.sortColumn,
              sortDirection: demo.direction,
            ),
          ),
        ],
      ),
    );
  }
}

/// The bar across the top — what a real screen puts there.
class _HeaderStrip extends StatelessWidget {
  const _HeaderStrip({required this.demo});

  final HrDashboardDemo demo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final people = demo.selectedPeople.length;
    final groups = demo.selectedGroups.length;
    final payroll = demo.rows.fold<int>(0, (sum, e) => sum + e.salary);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'People',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(demo, people, groups),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          _Stat(label: 'Headcount', value: '${demo.rows.length}'),
          const SizedBox(width: 24),
          _Stat(label: 'Payroll', value: _money(payroll)),
        ],
      ),
    );
  }

  /// Three cases, not two.
  ///
  /// Selecting a merged department reports the **group id** and no member ids,
  /// so a subtitle that only counted people fell back to the headcount line —
  /// which reads as *nothing selected* while a row is visibly highlighted and
  /// the knob pane lists the group. Two derived facts in two places is the
  /// shape this repo has paid for three times.
  static String _subtitle(HrDashboardDemo demo, int people, int groups) {
    if (people == 0 && groups == 0) {
      return '${demo.rows.length} across '
          '${HrDashboardDemo.departments.length} departments';
    }
    final parts = [
      if (people > 0) '$people selected',
      if (groups > 0) '$groups ${groups == 1 ? 'department' : 'departments'}',
    ];
    return parts.join(' · ');
  }

  static String _money(int amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).round()}k';
    return '\$$amount';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// What the merged department cell draws.
class _DepartmentCell extends StatelessWidget {
  const _DepartmentCell({
    required this.department,
    required this.headcount,
    required this.payroll,
  });

  final String department;
  final int headcount;
  final int payroll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            department,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$headcount people · ${_HeaderStrip._money(payroll)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// A performance score drawn as a bar rather than a number.
///
/// Here because it is the difference between a table of figures and a screen
/// someone would ship — and because `cellBuilder` is the seam that makes it
/// possible without the package knowing what a performance score is.
class _PerformanceBar extends StatelessWidget {
  const _PerformanceBar({required this.value});

  /// A 0..1 score. `RandomDataGenerator` produces **0.5 to 1.0**
  /// (`random_data_generator.dart:469` — `0.5 + random.nextDouble() * 0.5`),
  /// so a real bar here is always at least half full.
  ///
  /// This read `value / 5.0` and its comment said the generator produced 0.0
  /// to 5.0. It does not, and never did: every bar on the screen drew between
  /// 10% and 20% full under a label reading `0.7`. The rationale and the code
  /// agreed with each other and the fact they both depended on lived in another
  /// file — which is why no test caught it and only looking would have.
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = value.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(fraction * 100).round()}%',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The knob half.
class HrDashboardKnobs extends StatelessWidget {
  const HrDashboardKnobs({super.key, required this.demo});

  final HrDashboardDemo demo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Group by department'),
            subtitle: const Text(
              'Handing the table an empty group list is how you turn merging '
              'off — there is no enabled flag, because the list is the feature.',
              style: TextStyle(fontSize: 12),
            ),
            value: demo.grouped,
            onChanged: (value) => demo.grouped = value,
          ),
          const Divider(height: 28),
          Text(
            'SELECTED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (demo.selected.isEmpty)
            Text(
              'nothing selected',
              style: TextStyle(fontSize: 13, color: scheme.outline),
            )
          else
            // The raw set, on purpose: clicking a merged department reports
            // the group id, not its five members, and this is where that
            // stops being a sentence in a doc-comment.
            Text(
              demo.selected.join(', '),
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          const Divider(height: 28),
          Text(
            demo.grouped
                ? 'Sorting is per department while the groups are drawn: the '
                    'row order and the group list are two caller lists and the '
                    'package reconciles neither against the other, so they are '
                    'rebuilt together.'
                : 'Ungrouped, sorting runs across the whole table — there is no '
                    'merged cell left for a per-department order to explain.',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
