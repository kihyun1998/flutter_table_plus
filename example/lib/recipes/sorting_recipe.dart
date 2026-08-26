/// Sorting — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// A sortable table: click a header, the rows reorder.
///
/// **The table does not sort. It asks you to.** `onSort` fires with the column
/// and the direction it should move to, and nothing happens until you hand back
/// a reordered list. That is the same identity the package holds everywhere —
/// it renders your data and reports what the user did to it.
///
/// Two things follow, and both are the code below rather than a setting:
///
/// **The direction is handed to you, already computed.** Do not cycle it
/// yourself. The package applies [SortCycleOrder] and gives you the *next*
/// state; your job is to sort by it. Pass [sortColumnKey] and [sortDirection]
/// back down or the header arrow freezes on the first click while the rows keep
/// moving.
///
/// **[SortDirection.none] is a real third state**, not a null. Clicking past
/// descending returns the table to unsorted — which is only expressible if you
/// kept the original order. [_original] is that copy, and it is the whole reason
/// this recipe holds two lists instead of sorting in place.
class SortingRecipe extends StatefulWidget {
  const SortingRecipe({
    super.key,
    this.sortable = true,
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
  });

  /// Whether the headers respond to a click at all.
  final bool sortable;

  /// Which direction a first click moves to.
  final SortCycleOrder sortCycleOrder;

  @override
  State<SortingRecipe> createState() => _SortingRecipeState();
}

class _SortingRecipeState extends State<SortingRecipe> {
  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
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
            // Left unsortable on purpose: `sortable` is a per-column flag, so a
            // table can offer sorting on the columns where it means something
            // and refuse it on the ones where it does not.
            ..addColumn(
              'email',
              const TablePlusColumn<Employee>(
                key: 'email',
                label: 'Email',
                order: 0,
                width: 230,
                valueAccessor: _email,
              ),
            )
            ..addColumn(
              'salary',
              const TablePlusColumn<Employee>(
                key: 'salary',
                label: 'Salary',
                order: 0,
                width: 120,
                sortable: true,
                textAlign: TextAlign.right,
                valueAccessor: _salary,
              ),
            ))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _email(Employee e) => e.email;
  static Object? _salary(Employee e) => e.salary;

  /// The order the rows arrived in. Kept so [SortDirection.none] has somewhere
  /// to go back to.
  late final List<Employee> _original =
      RandomDataGenerator.generateEmployees(20);

  late List<Employee> _rows = List.of(_original);

  String? _sortColumn;
  SortDirection _direction = SortDirection.none;

  /// The value each sortable column sorts by.
  ///
  /// A `Comparable` per column rather than a comparator, so the direction is
  /// applied in one place instead of twice per column.
  Comparable<Object> _keyOf(Employee e, String columnKey) => switch (columnKey) {
        'name' => e.name,
        'department' => e.department,
        'salary' => e.salary,
        _ => e.name,
      };

  void _sort(String columnKey, SortDirection direction) {
    setState(() {
      _sortColumn = columnKey;
      _direction = direction;

      if (direction == SortDirection.none) {
        _rows = List.of(_original);
        _sortColumn = null;
        return;
      }

      final sorted = List.of(_rows)
        ..sort((a, b) => _keyOf(a, columnKey).compareTo(_keyOf(b, columnKey)));
      _rows = direction == SortDirection.ascending
          ? sorted
          : sorted.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _rows,
      rowId: (employee) => employee.id,
      theme: demoTableTheme(Theme.of(context).brightness),
      sortCycleOrder: widget.sortCycleOrder,
      // Withholding `onSort` is what makes the headers inert — the same shape as
      // select-all. There is no `sortingEnabled` flag on the table.
      onSort: widget.sortable ? _sort : null,
      // Handed back down, or the arrow shows a state the rows have left.
      sortColumnKey: _sortColumn,
      sortDirection: _direction,
    );
  }
}
