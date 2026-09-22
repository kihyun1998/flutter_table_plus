/// Smooth wheel — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Turn the mouse wheel over the table, and Shift+wheel for the other axis.
///
/// **One argument, and `null` is the default.** `wheelMotion` left out moves
/// the body at once on every notch, which is the table as it always was. Hand
/// it a `WheelMotion` and the body animates to where the notch points instead;
/// notches during the motion add to its target, so a fast flick still travels
/// the whole distance. The header and scrollbars follow on every frame.
///
/// **`WheelMotion` comes from this package's import.** It is re-exported, so
/// there is no second dependency to add for it.
///
/// **Only the wheel animates.** Dragging a scrollbar jumps, and stops a motion
/// in progress; so does a wheel turned over a scrollbar, which is a scroll view
/// of its own. How far one notch travels is not a table setting at all — that
/// is app-wide, through `SmoothWheelBinding` in `flutter_smooth_wheel_scroll`.
class SmoothWheelRecipe extends StatelessWidget {
  const SmoothWheelRecipe({super.key, this.wheelMotion});

  /// How the body moves on a wheel notch; `null` moves it at once.
  final WheelMotion? wheelMotion;

  /// Columns totalling 800px over 200 rows, so both axes have distance to
  /// travel and a motion has time to be seen.
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
              'position',
              const TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position',
                order: 0,
                width: 240,
                valueAccessor: _position,
              ),
            ))
          .build();

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _email(Employee e) => e.email;
  static Object? _position(Employee e) => e.position;

  static final List<Employee> _employees =
      RandomDataGenerator.generateEmployees(200);

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _employees,
      rowId: (employee) => employee.id,
      theme: demoTableTheme(Theme.of(context).brightness),
      wheelMotion: wheelMotion,
    );
  }
}
