/// The shell's first destination: a table, and the handful of knobs that own it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../demo_data/demo_data.dart';
import '../../theme/table_palette.dart';

/// The state the stage and the knob region both need.
///
/// They are drawn into two different regions of the shell, so neither can own
/// the state and neither can reach the other. A small notifier between them is
/// what a destination is: one object, two views of it.
///
/// This is the shape a recipe will need in #103, met here first because the
/// shell needs a destination before it needs a recipe.
class EmployeeDemo extends ChangeNotifier {
  EmployeeDemo() {
    _regenerate();
  }

  int _rowCount = 24;
  int get rowCount => _rowCount;
  set rowCount(int value) {
    if (_rowCount == value) return;
    _rowCount = value;
    _regenerate();
    notifyListeners();
  }

  bool _selectable = true;
  bool get selectable => _selectable;
  set selectable(bool value) {
    if (_selectable == value) return;
    _selectable = value;
    // Rows selected while selection was on would otherwise stay highlighted
    // after it is turned off — visible state with no control left to change it.
    if (!value) _selected = {};
    notifyListeners();
  }

  List<Employee> _rows = const [];
  List<Employee> get rows => _rows;

  Set<String> _selected = {};
  Set<String> get selected => _selected;

  void toggle(String id, bool on) {
    _selected = {..._selected};
    on ? _selected.add(id) : _selected.remove(id);
    notifyListeners();
  }

  void replaceSelection(Set<String> ids) {
    _selected = Set.of(ids);
    notifyListeners();
  }

  void _regenerate() {
    _rows = RandomDataGenerator.generateEmployees(_rowCount);
    _selected = {};
  }
}

/// The table half.
class EmployeeDemoTable extends StatelessWidget {
  const EmployeeDemoTable({super.key, required this.demo});

  final EmployeeDemo demo;

  /// Columns totalling 800px, so a phone-width viewport clips and scrolls while
  /// a desktop one has room. A table that fits at every viewport would make the
  /// viewport control look decorative.
  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
                'name',
                const TablePlusColumn<Employee>(
                  key: 'name',
                  label: 'Name',
                  order: 0,
                  width: 160,
                  valueAccessor: _name,
                ))
            ..addColumn(
                'department',
                const TablePlusColumn<Employee>(
                  key: 'department',
                  label: 'Department',
                  order: 0,
                  width: 150,
                  valueAccessor: _department,
                ))
            ..addColumn(
                'position',
                const TablePlusColumn<Employee>(
                  key: 'position',
                  label: 'Position',
                  order: 0,
                  width: 150,
                  valueAccessor: _position,
                ))
            ..addColumn(
                'email',
                const TablePlusColumn<Employee>(
                  key: 'email',
                  label: 'Email',
                  order: 0,
                  width: 220,
                  valueAccessor: _email,
                ))
            ..addColumn(
                'salary',
                const TablePlusColumn<Employee>(
                  key: 'salary',
                  label: 'Salary',
                  order: 0,
                  width: 120,
                  textAlign: TextAlign.right,
                  valueAccessor: _salary,
                )))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _position(Employee e) => e.position;
  static Object? _email(Employee e) => e.email;
  static Object? _salary(Employee e) => e.salary;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => FlutterTablePlus<Employee>(
        theme: demoTableTheme(Theme.of(context).brightness),
        columns: _columns,
        data: demo.rows,
        rowId: (e) => e.id,
        isSelectable: demo.selectable,
        selectionMode: SelectionMode.multiple,
        enableDragSelection: demo.selectable,
        selectedRows: demo.selected,
        onRowSelectionChanged: demo.toggle,
        // Not optional: the table wires its drag handlers only when
        // `onDragSelectionUpdate` is non-null, alongside `isSelectable` and
        // `selectionMode == multiple`. Omit it and dragging is silently inert.
        onDragSelectionUpdate: demo.replaceSelection,
        onDragSelectionEnd: demo.replaceSelection,
      ),
    );
  }
}

/// The knob half — this destination's own controls, and no others.
class EmployeeDemoKnobs extends StatelessWidget {
  const EmployeeDemoKnobs({super.key, required this.demo});

  final EmployeeDemo demo;

  static const _rowCounts = [24, 200, 2000, 20000];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: demo,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Rows',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final count in _rowCounts)
                ChoiceChip(
                  label: Text('$count'),
                  selected: demo.rowCount == count,
                  onSelected: (_) => demo.rowCount = count,
                ),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Selectable'),
            subtitle: Text(
              'Row taps and drag-select',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            value: demo.selectable,
            onChanged: (value) => demo.selectable = value,
          ),
          const SizedBox(height: 8),
          Text(
            demo.selected.isEmpty
                ? 'no rows selected'
                : '${demo.selected.length} selected',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
