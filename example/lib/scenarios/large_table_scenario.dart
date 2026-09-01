/// The performance claim, made visible.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../pages/playground/widgets/performance_monitor.dart';
import '../theme/table_palette.dart';

/// A table with far more rows than fit on a screen, and the numbers to go
/// with it.
///
/// **A scenario is not a recipe.** `lib/recipes/` is the pasteable zone and its
/// imports are held to an allow-list by `test/recipe_seam_test.dart`; this file
/// deliberately reaches into `pages/playground/` for [PerformanceMonitor],
/// which is exactly the kind of import a recipe may not have. A recipe is a
/// thing you copy; a scenario is a thing you look at, and it is allowed to be
/// composed out of what the app already has.
///
/// **The rows are generated eagerly, in the constructor and in the row-count
/// setter, and that is a correctness requirement rather than a simplification.**
/// An earlier version generated them lazily on the first read of `rows`, to keep
/// the shell's construction cheap. It was wrong, and wrong in a way only the
/// screen shows: the stage lives inside `PreviewFrame`, whose body is a
/// `LayoutBuilder`, and a `LayoutBuilder` element owns its own `BuildScope`
/// flushed from `performLayout`
/// (`packages/flutter/lib/src/widgets/layout_builder.dart:119`). The knob pane
/// is built in the ordinary build phase. So the panel was **always** built
/// before the stage generated — it opened showing a hard-coded `Total Rows
/// 1.0K` with no generation time at all, and after picking `10k` it drew the
/// 1 000-row figures beside a table of ten thousand. Not a race; the ordering
/// is structural.
///
/// Generating in the setter is the shape `EmployeeDemo` already uses, and it is
/// why that destination's knob pane can never be stale. The cost is real and
/// measured 2026-09-01: **18 ms for 1 000 rows, 68 ms for 10 000, 635 ms for
/// 100 000** — paid at shell construction for the smallest, and on the frame
/// that changes the count for the others. The largest is a visible pause, which
/// is honest for a control whose whole subject is what a hundred thousand rows
/// cost.
class LargeTableDemo extends ChangeNotifier {
  /// The counts offered, smallest first.
  ///
  /// The smallest is already past the point where a naive table stops being
  /// pleasant, and the largest is there to make the claim uncomfortable rather
  /// than flattering.
  static const List<int> counts = [1000, 10000, 100000];

  LargeTableDemo() {
    _regenerate();
  }

  int _rowCount = counts.first;
  int get rowCount => _rowCount;
  set rowCount(int value) {
    if (_rowCount == value) return;
    _rowCount = value;
    _regenerate();
    notifyListeners();
  }

  List<Employee> _rows = const [];
  List<Employee> get rows => _rows;

  /// What the monitor is given.
  ///
  /// `rowCount` here is the count these rows were generated at, so it and
  /// `rows.length` cannot disagree — which is the property the lazy version
  /// broke and the one worth asserting.
  late PerformanceMetrics _metrics;
  PerformanceMetrics get metrics => _metrics;

  String? _sortColumn;
  String? get sortColumn => _sortColumn;

  SortDirection _direction = SortDirection.none;
  SortDirection get direction => _direction;

  /// The order the rows arrived in, so [SortDirection.none] has somewhere to
  /// return to. Sorting a hundred thousand rows back into "unsorted" by
  /// re-generating them would be timing the generator instead of the sort.
  List<Employee> _unsorted = const [];

  void _regenerate() {
    final stopwatch = Stopwatch()..start();
    final generated = RandomDataGenerator.generateEmployees(_rowCount);
    stopwatch.stop();

    _unsorted = generated;
    _rows = generated;
    // A sort of the old rows is not a sort of these, so the header must not go
    // on claiming one.
    _sortColumn = null;
    _direction = SortDirection.none;
    _metrics = PerformanceMetrics(
      rowCount: _rowCount,
      dataGenerationTimeMs: stopwatch.elapsedMilliseconds,
      lastUpdate: DateTime.now(),
    );
  }

  void sort(String columnKey, SortDirection direction) {
    // Read outside the stopwatch. It reads trivially now, and it did not
    // before: while `rows` generated on first read, this line put a generation
    // inside the interval reported as "Last Sort".
    final current = _rows;

    final stopwatch = Stopwatch()..start();
    final List<Employee> sorted;
    if (direction == SortDirection.none) {
      sorted = _unsorted;
    } else {
      sorted = [...current]..sort((a, b) {
          final comparison = _compare(columnKey, a, b);
          return direction == SortDirection.ascending
              ? comparison
              : -comparison;
        });
    }
    stopwatch.stop();

    _rows = sorted;
    // Cleared rather than retained for `none`, matching the HR dashboard. The
    // header keys off the direction today, so retaining it changes nothing on
    // screen — and two scenarios answering the same question differently is a
    // defect waiting for the first theme that distinguishes "this column,
    // unsorted" from "no column".
    _sortColumn = direction == SortDirection.none ? null : columnKey;
    _direction = direction;
    _metrics = _metrics.copyWith(
      lastSortTimeMs: stopwatch.elapsedMilliseconds,
      lastUpdate: DateTime.now(),
    );
    notifyListeners();
  }

  static int _compare(String columnKey, Employee a, Employee b) =>
      switch (columnKey) {
        'salary' => a.salary.compareTo(b.salary),
        'department' => a.department.compareTo(b.department),
        _ => a.name.compareTo(b.name),
      };
}

/// The stage half — one table, and nothing else in the way of it.
class LargeTableStage extends StatelessWidget {
  const LargeTableStage({super.key, required this.demo});

  final LargeTableDemo demo;

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;
  static Object? _salary(Employee e) => e.salary;

  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'name',
              const TablePlusColumn<Employee>(
                key: 'name',
                label: 'Name',
                order: 0,
                width: 180,
                sortable: true,
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
                sortable: true,
                valueAccessor: _department,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 180,
                valueAccessor: _position,
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
      builder: (context, _) => FlutterTablePlus<Employee>(
        theme: demoTableTheme(Theme.of(context).brightness),
        columns: _columns,
        data: demo.rows,
        rowId: (e) => e.id,
        // The table does not sort; it asks. At this row count that is not a
        // philosophical point — it means the sort you are timing is your own
        // comparator over your own list, which is the number worth reporting.
        onSort: demo.sort,
        sortColumnKey: demo.sortColumn,
        sortDirection: demo.direction,
      ),
    );
  }
}

/// The knob half — the row count, and the existing monitor reporting on it.
///
/// The monitor is [PerformanceMonitor] unchanged. It reports Total Rows, Data
/// Generation and Last Sort; its fourth field, `lastRenderTimeMs`, is declared
/// and rendered under a null guard and computed by nothing in this app, so it
/// has never appeared and does not appear here either.
class LargeTableKnobs extends StatelessWidget {
  const LargeTableKnobs({super.key, required this.demo});

  final LargeTableDemo demo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ROW COUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final count in LargeTableDemo.counts)
                ChoiceChip(
                  label: Text(_short(count)),
                  selected: demo.rowCount == count,
                  onSelected: (_) => demo.rowCount = count,
                ),
            ],
          ),
          const SizedBox(height: 20),
          PerformanceMonitor(metrics: demo.metrics),
          const SizedBox(height: 16),
          Text(
            'Sort by clicking Name, Department or Salary. The sort is this '
            'page\'s own comparator over its own list — the table asks, it does '
            'not reorder.',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  static String _short(int count) =>
      count >= 1000 ? '${count ~/ 1000}k' : '$count';
}
