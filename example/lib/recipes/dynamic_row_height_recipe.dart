/// Dynamic row heights — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Rows that are as tall as their content needs, one row at a time.
///
/// **The table does not measure your rows.** It asks. `calculateRowHeight` is
/// handed the index and the row and returns a height in logical pixels, or
/// `null` to mean *use the theme's*. Which is the same identity the package
/// holds everywhere — it will do the arithmetic nobody can do without the
/// layout, and it will not decide policy for you. Automatic height would mean
/// laying every cell out twice, so it is a thing you opt into per row rather
/// than a mode the table runs in.
///
/// **The measurement is the part you cannot do yourself**, and the package
/// supplies it: [TableRowHeightCalculator.calculateTextHeight] lays the string
/// out at a width with a `TextPainter` and tells you how tall it wrapped to.
/// You need it because the answer depends on the font, the scale, and the exact
/// width the column ended up at — none of which you can read off your data. The
/// `notes` column below is measured that way; the row is as tall as that
/// column's text wrapped, and no taller.
///
/// **A wrapped column has to be told to wrap.** Every column ellipsizes by
/// default, so a taller row would just add empty space under one clipped line.
/// [TextOverflow.visible] on the column is what turns extra height into extra
/// text — the two settings are one decision made in two places, and setting
/// only the height is the mistake that makes this feature look broken.
///
/// **Hold the callback still, and make it a pure function of the row.** Two
/// separate reasons, and they pull in the same direction.
///
/// The table compares `calculateRowHeight` by identity and, when it changes,
/// re-walks every row to re-total the scrollable height. A closure written
/// inline in `build` is a new object each time, so an inline `(i, row) => ...`
/// buys that walk on every rebuild — proportional to your row count, with
/// nothing warning you. A `static` function is the cheapest possible fix: the
/// same object every time.
///
/// The second reason used to bite rather than cost, and no longer does. Row
/// heights are also cached *per index*, one layer down, and that cache was not
/// keyed on the callback: measured 2026-08-26, swapping a callback returning
/// 100 for one returning 40 with the data list unchanged kept a row pitch of
/// 100.5px. **Fixed in 2.17.0** — both layers now invalidate through one
/// `rowMeasurementChanged` predicate, so a function that answers differently
/// is honoured. The advice is unchanged and its reason is not: hold the
/// callback still because the walk above is not free, not because a stale
/// height will be drawn. A pure function of the row makes both moot.
///
/// **Heights accumulate.** Once rows differ, a row's top edge is the sum of
/// every row above it rather than `index * rowHeight`. Everything downstream —
/// hit testing, drag selection, the scroll extent, a merged group's total
/// height — is computed from that sum. It is why this is a per-row fact the
/// table caches rather than a number it multiplies.
class DynamicRowHeightRecipe extends StatelessWidget {
  const DynamicRowHeightRecipe({super.key, this.perRowHeight = true});

  /// Whether the table asks for a per-row height at all. Off, every row is
  /// `bodyTheme.rowHeight` and the notes are clipped to one line.
  final bool perRowHeight;

  /// The `notes` column's width, named once because the height calculation has
  /// to measure at exactly the width the text will be laid out at. Two
  /// different numbers here is the classic way to get rows that are almost tall
  /// enough.
  ///
  /// **`width` alone is not that number.** A column's `width` is a *preference*:
  /// when the viewport is wider than every column's preference added up, the
  /// resolver hands each flexible column a proportional share of the surplus,
  /// so a column asking for 300 renders at whatever it is grown to. Measured
  /// 2026-08-26 in an 1100px window: this column asked for 300 and painted at
  /// 517.5, and every row was measured for a wrap 250px narrower than the one
  /// it got. `maxWidth` below is what makes the preference a fact — without it
  /// this recipe demonstrates the defect its own comment warns about.
  static const double _notesWidth = 300;

  /// The cell's own horizontal padding, subtracted for the same reason: the
  /// text wraps inside the padding, not inside the column. It is
  /// `bodyTheme.padding`, which defaults to 16 a side — read it from the theme
  /// instead of this constant the moment you set your own.
  static const double _cellPadding = 32;

  /// One sentence per employee, long enough that a narrow column has to wrap
  /// them onto two or three lines — and short enough on some rows that the
  /// difference between rows is visible rather than uniform.
  static String _notes(Employee e) => switch (e.id.hashCode % 3) {
        0 => '${e.name} joined the ${e.department} team and works on '
            '${e.position.toLowerCase()}, which is a long enough sentence to '
            'need three lines in a column this narrow.',
        1 => '${e.name} — ${e.position}.',
        _ => '${e.name} covers ${e.department} and is the first person to ask '
            'about anything in it.',
      };

  static Object? _name(Employee e) => e.name;
  static Object? _department(Employee e) => e.department;
  static Object? _notesValue(Employee e) => _notes(e);

  static final List<Employee> _rows =
      RandomDataGenerator.generateEmployees(12);

  /// The metrics the notes column is measured *and* drawn with.
  ///
  /// **The measurement and the rendering must agree**, so both read this. A
  /// height measured in one style and drawn in another is wrong by whatever the
  /// two differ by, and it is wrong quietly — the text just clips.
  ///
  /// Metrics only, deliberately: it carries no colour, so it is `merge`d onto
  /// the shared body style below rather than replacing it. Replacing it drops
  /// the palette's ink and the row silently falls back to whatever
  /// `DefaultTextStyle` had — a colour nothing in this app chose.
  ///
  /// **What it cannot carry is the font family**, and that is a real limit
  /// rather than an omission. The family is merged in at paint time from the
  /// app's `ThemeData`, which a `static` measurement cannot see, so on a device
  /// whose font is not the measuring font the wrap points differ. Name the
  /// family here if that matters to you — this demo leaves it out so the
  /// recipe stays about heights.
  static const TextStyle _notesStyle = TextStyle(fontSize: 13, height: 1.35);

  /// The height of one row, or null for the theme's.
  ///
  /// A `static` rather than a closure: see the class comment. It also means the
  /// function cannot capture widget state, which is exactly what would make its
  /// answer depend on something the per-index cache does not know changed —
  /// the second hazard, designed out rather than remembered.
  static double? _heightOf(int index, Employee employee) {
    return TableRowHeightCalculator.calculateTextHeight(
      text: _notes(employee),
      textStyle: _notesStyle,
      maxWidth: _notesWidth - _cellPadding,
      // Added to the measured text, not read from the cell: a body cell's
      // vertical padding defaults to zero, so text laid out at exactly its own
      // height would touch the row divider. Eight a side is this recipe's
      // choice of breathing room, and it is the calculator's default too.
      padding: const EdgeInsets.symmetric(vertical: 8),
      // The floor. Returning something shorter than the theme's row height is
      // allowed and looks like a mistake, so the calculator takes a minimum
      // instead of leaving it to the caller to remember.
      minHeight: 48,
    );
  }

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
                width: 140,
                valueAccessor: _department,
              ),
            )
            ..addColumn(
              'notes',
              const TablePlusColumn<Employee>(
                key: 'notes',
                label: 'Notes',
                order: 0,
                width: _notesWidth,
                // The half that turns the preference into the number the
                // measurement above assumed.
                maxWidth: _notesWidth,
                valueAccessor: _notesValue,
                // The other half of the decision. Without this the extra height
                // is empty space under one ellipsized line.
                textOverflow: TextOverflow.visible,
                // And with the text no longer cut, a tooltip repeating it would
                // say nothing.
                tooltipBehavior: TooltipBehavior.never,
              ),
            ))
          .build();

  @override
  Widget build(BuildContext context) {
    final theme = demoTableTheme(Theme.of(context).brightness);

    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _rows,
      rowId: (employee) => employee.id,
      // The style the height was measured in has to be the style the cell is
      // drawn in — `merge`d, not assigned, so the palette's ink survives.
      theme: theme.copyWith(
        bodyTheme: theme.bodyTheme.copyWith(
          textStyle: theme.bodyTheme.textStyle.merge(_notesStyle),
        ),
      ),
      // A tear-off, not a closure — the same object on every build, so the
      // table's height cache survives.
      calculateRowHeight: perRowHeight ? _heightOf : null,
    );
  }
}
