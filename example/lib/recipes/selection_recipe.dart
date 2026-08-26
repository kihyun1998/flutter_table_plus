/// Row selection — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Selectable rows: checkboxes, select-all, and the two selection modes.
///
/// Everything selection needs is here — the columns, the data, the selected
/// set, and every callback the table hands back. Nothing is threaded in from a
/// settings object, so what you read is what runs.
///
/// **The table does not hold the selection; you do.** `selectedRows` is a set
/// you own and the package only draws. That is the package's identity, not an
/// omission, and it has one consequence that catches everybody:
/// [SelectionMode.single] does **not** clamp the set for you. Passing `single`
/// and then adding to a set gives you multi-selection wearing a single-select
/// label — the collapse in [_SelectionRecipeState._toggle] is the code that
/// makes `single` mean single, and every app that wants it has to write it.
///
/// The same asymmetry runs the other way: two of these settings can leave a
/// selection standing that the reader can no longer see or reach. Turning
/// selection off hides the checkboxes while the rows stay highlighted, and
/// switching to `single` leaves however many rows were already selected.
/// [_SelectionRecipeState.didUpdateWidget] is where that is repaired.
class SelectionRecipe extends StatefulWidget {
  const SelectionRecipe({
    super.key,
    this.selectable = true,
    this.selectionMode = SelectionMode.multiple,
    this.showCheckboxColumn = true,
    this.selectAllEnabled = true,
    this.showRowCheckbox = true,
    this.cellTapTogglesCheckbox = false,
  });

  /// Whether rows can be selected at all.
  final bool selectable;

  /// One row at a time, or many.
  final SelectionMode selectionMode;

  /// Whether the leading checkbox column is drawn.
  final bool showCheckboxColumn;

  /// Whether the header checkbox selects and clears every row.
  ///
  /// Not a flag on the table: select-all exists exactly when `onSelectAll` is
  /// non-null, so "disabled" is a callback you do not pass.
  final bool selectAllEnabled;

  /// Whether each body row draws its own checkbox.
  final bool showRowCheckbox;

  /// Whether tapping anywhere in a row toggles its checkbox.
  final bool cellTapTogglesCheckbox;

  @override
  State<SelectionRecipe> createState() => _SelectionRecipeState();
}

class _SelectionRecipeState extends State<SelectionRecipe> {
  /// Columns totalling 620px, so a phone-width viewport scrolls and a desktop
  /// one does not. A table that fits everywhere would make the viewport control
  /// look decorative.
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
              ),
            )
            ..addColumn(
              'department',
              const TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 150,
                valueAccessor: _department,
              ),
            )
            ..addColumn(
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 150,
                valueAccessor: _position,
              ),
            )
            ..addColumn(
              'salary',
              const TablePlusColumn<Employee>(
                key: 'salary',
                label: 'Salary',
                order: 0,
                width: 120,
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

  /// The selection. Yours, not the table's.
  Set<String> _selected = {};

  @override
  void didUpdateWidget(SelectionRecipe oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A selection that outlives the setting that made it reachable is state the
    // reader can see and can no longer change. Both repairs are the consumer's
    // — the package draws `selectedRows` exactly as handed to it, in every mode.
    if (!widget.selectable) {
      _selected = {};
    } else if (widget.selectionMode == SelectionMode.single &&
        _selected.length > 1) {
      _selected = {_selected.first};
    }
  }

  void _toggle(String rowId, bool isSelected) {
    setState(() {
      if (widget.selectionMode == SelectionMode.single) {
        // The whole of what `single` means. Remove this line and the mode is a
        // label with nothing behind it: nothing in the package clears the
        // previous row, because nothing in the package owns the set.
        _selected = isSelected ? {rowId} : {};
        return;
      }

      _selected = {..._selected};
      if (isSelected) {
        _selected.add(rowId);
      } else {
        _selected.remove(rowId);
      }
    });
  }

  void _selectAll(bool selectAll) {
    setState(() {
      _selected = selectAll ? {for (final e in _employees) e.id} : {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = demoTableTheme(Theme.of(context).brightness);

    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _employees,
      rowId: (employee) => employee.id,
      isSelectable: widget.selectable,
      selectionMode: widget.selectionMode,
      selectedRows: _selected,
      onRowSelectionChanged: _toggle,
      // Select-all is a callback, not a flag: withhold it and the header
      // checkbox has nothing to do.
      onSelectAll: widget.selectAllEnabled ? _selectAll : null,
      // `copyWith` on the sub-theme, never a fresh `TablePlusCheckboxTheme`.
      // Constructing one keeps only the three fields named here and silently
      // drops every other — including `style`, which is what colours the box
      // and the tick. This is the failure class #50 recorded: hand-listing
      // fields loses the ones you forget, and nothing goes red.
      theme: theme.copyWith(
        checkboxTheme: theme.checkboxTheme.copyWith(
          showCheckboxColumn: widget.showCheckboxColumn,
          showRowCheckbox: widget.showRowCheckbox,
          cellTapTogglesCheckbox: widget.cellTapTogglesCheckbox,
        ),
      ),
    );
  }
}
