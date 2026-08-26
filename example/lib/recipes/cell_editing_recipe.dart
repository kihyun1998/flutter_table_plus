/// Cell editing — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Click an editable cell and type.
///
/// **A commit reports; it does not mutate.** `onCellChanged` hands you the row,
/// the column key, the row index and both values, and then the table renders
/// whatever list you give it next. If you do not write the value back, the cell
/// snaps to its old contents the moment the field closes — which looks exactly
/// like a bug in the package and is not one. [_commit] is the write-back, and it
/// is the part of this file that matters.
///
/// **Editing is per column, not a mode.** The `editable` flag lives on
/// [TablePlusColumn], so one table mixes editable and read-only columns without
/// switching between states. `Email` below is read-only on purpose: click it and
/// nothing happens, which is the flag doing its job.
///
/// `Salary` shows the other half of the write-back — the field hands back a
/// `String`, and a column that holds an `int` has to parse it and decide what a
/// bad number means. Here a bad number keeps the old value; a real app might
/// keep the field open instead.
class CellEditingRecipe extends StatefulWidget {
  const CellEditingRecipe({super.key, this.editable = true});

  /// Whether the table accepts edits at all.
  ///
  /// Both this *and* the column's own `editable` flag must be true, which is
  /// the same shape as the rest of the package: the table opens the door, the
  /// column decides whether to walk through it.
  final bool editable;

  @override
  State<CellEditingRecipe> createState() => _CellEditingRecipeState();
}

class _CellEditingRecipeState extends State<CellEditingRecipe> {
  static final Map<String, TablePlusColumn<Employee>> _columns =
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'name',
              const TablePlusColumn<Employee>(
                key: 'name',
                label: 'Name',
                order: 0,
                width: 170,
                editable: true,
                valueAccessor: _name,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 180,
                editable: true,
                valueAccessor: _position,
              ),
            )
            // Read-only, and deliberately in the middle: the difference is a
            // column flag, not a region of the table.
            ..addColumn(
              'email',
              const TablePlusColumn<Employee>(
                key: 'email',
                label: 'Email (read-only)',
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
                width: 130,
                editable: true,
                textAlign: TextAlign.right,
                valueAccessor: _salary,
              ),
            ))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _position(Employee e) => e.position;
  static Object? _email(Employee e) => e.email;
  static Object? _salary(Employee e) => e.salary;

  List<Employee> _rows = RandomDataGenerator.generateEmployees(20);

  /// The write-back. Without this the table renders the old list and the edit
  /// appears to be discarded.
  void _commit(
    Employee row,
    String columnKey,
    int rowIndex,
    Object? oldValue,
    Object? newValue,
  ) {
    final text = '${newValue ?? ''}'.trim();

    final updated = switch (columnKey) {
      'name' => text.isEmpty ? row : row.copyWith(name: text),
      'position' => row.copyWith(position: text),
      // The field always hands back a String. A column holding an int has to
      // decide what an unparseable one means; here it keeps the old value.
      'salary' => switch (int.tryParse(text.replaceAll(',', ''))) {
          final int parsed => row.copyWith(salary: parsed),
          null => row,
        },
      _ => row,
    };

    if (identical(updated, row)) return;

    // Replace by index rather than by identity: `rowIndex` is the position in
    // the list this table was given, which is the list being replaced.
    setState(() {
      _rows = List.of(_rows)..[rowIndex] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _rows,
      rowId: (employee) => employee.id,
      theme: demoTableTheme(Theme.of(context).brightness),
      isEditable: widget.editable,
      onCellChanged: _commit,
    );
  }
}
