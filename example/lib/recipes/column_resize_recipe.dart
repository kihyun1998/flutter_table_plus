/// Column resizing — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Drag the boundary between two header cells to change a column's width.
///
/// **The width you are given back is not the width that was dragged.** The
/// handle works in the pixels on screen; the callback reports *logical* pixels,
/// which is the same number whatever the table is scaled to. Resize a column at
/// double zoom and you are handed the width you would have got at 1.0 — because
/// the value you are meant to store is the one that still means something the
/// next time the app opens at a different zoom. The strip below makes this
/// checkable rather than a claim: resize a column, then change the scale, and
/// watch the reported number stay where it was while the column visibly moves.
///
/// **Resizing is a table-wide switch, not a per-column flag.** Unlike
/// `sortable` and `editable`, there is no `resizable` on [TablePlusColumn] —
/// one `resizable: true` on the table arms every boundary. What *is* per-column
/// is the range: [TablePlusColumn.minWidth] and [TablePlusColumn.maxWidth]
/// bound the drag, and the handle refuses to cross them rather than reporting a
/// width you would have to reject yourself. Those bounds are logical pixels
/// like everything else here, so the floor this recipe puts on a knob is the
/// floor you get at any zoom — set the minimum to 120 and drag the boundary
/// left at every scale chip in turn, and the column stops at 120 each time.
///
/// It did not always. Until #114 the drag was measured in screen pixels and
/// bounded against logical ones, so at `scale: 2.0` a column clamped to half
/// its declared ceiling. An earlier version of this comment named that defect
/// rather than designing around it; the defect is gone and the note with it.
/// What is worth keeping is why nobody had seen it: at `scale: 1.0` the two
/// spaces are the same numbers, so the scale chips above are the only control
/// on this page that could ever have shown it.
///
/// **`initialResizedWidths` is misleadingly named.** It is not read once at
/// startup: whenever the map you pass changes by value, the table adopts it.
/// That is what makes the loop below work — the callback hands you a width, you
/// store it, and the map you hand back on the next build is the table's state.
/// Storing nothing and passing nothing still resizes, because the table keeps
/// its own copy while it lives; what you lose is the width surviving anything
/// that rebuilds the table from scratch.
///
/// Double-tapping a boundary auto-fits the column to its widest text. That path
/// reports through the same callback, so the loop below covers it with no extra
/// code.
class ColumnResizeRecipe extends StatefulWidget {
  const ColumnResizeRecipe({
    super.key,
    this.resizable = true,
    this.columnMinWidth = 50,
    this.stretchLastColumn = false,
    this.handleWidth = 8,
    this.handleThickness = 2,
    this.handleIndent = 0,
    this.handleEndIndent = 0,
  });

  /// Whether any boundary can be dragged.
  final bool resizable;

  /// The floor every column's width is clamped to.
  final double columnMinWidth;

  /// Whether the last column absorbs the space left over when the columns are
  /// narrower than the viewport.
  final bool stretchLastColumn;

  /// The invisible hit area around a boundary — how close the pointer has to
  /// get before the handle takes the drag.
  final double handleWidth;

  /// The visible indicator's thickness, and how far it is inset from the top
  /// and the bottom of the header.
  final double handleThickness;
  final double handleIndent;
  final double handleEndIndent;

  @override
  State<ColumnResizeRecipe> createState() => _ColumnResizeRecipeState();
}

class _ColumnResizeRecipeState extends State<ColumnResizeRecipe> {
  static final Map<String, TablePlusColumn<Employee>> _base =
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

  /// Rebuilt only when the floor moves. The table compares `columns` by
  /// identity, so handing it a freshly-built map on every frame would make it
  /// re-validate the set for nothing.
  late Map<String, TablePlusColumn<Employee>> _columns =
      _withMinWidth(widget.columnMinWidth);

  static Map<String, TablePlusColumn<Employee>> _withMinWidth(double min) => {
        for (final entry in _base.entries)
          entry.key: entry.value.copyWith(minWidth: min),
      };

  late final List<Employee> _employees =
      RandomDataGenerator.generateEmployees(20);

  /// The widths you own. Logical pixels, whatever the scale was when they were
  /// dragged — this is the map a real app would persist.
  Map<String, double> _widths = const {};

  /// Demo scaffolding: the zoom control that makes the paragraph above
  /// checkable. A real app would take `scale` from wherever it keeps it.
  double _scale = 1.0;

  @override
  void didUpdateWidget(ColumnResizeRecipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.columnMinWidth != oldWidget.columnMinWidth) {
      _columns = _withMinWidth(widget.columnMinWidth);
    }
  }

  /// The whole of the persistence loop. A new map rather than a mutation, so
  /// the table sees a value change and adopts it.
  void _store(String columnKey, double newWidth) {
    setState(() {
      _widths = {..._widths, columnKey: newWidth};
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = demoTableTheme(Theme.of(context).brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WidthStrip(
          resizable: widget.resizable,
          widths: _widths,
          scale: _scale,
          onScale: (value) => setState(() => _scale = value),
        ),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _employees,
            rowId: (employee) => employee.id,
            scale: _scale,
            resizable: widget.resizable,
            stretchLastColumn: widget.stretchLastColumn,
            onColumnResized: _store,
            initialResizedWidths: _widths,
            // `copyWith` down both levels, never a fresh sub-theme. A new
            // `TablePlusResizeHandleTheme` here would keep the four fields
            // below and silently drop `color`, which is the field that makes
            // the handle visible at all — the failure class #50 recorded.
            theme: theme.copyWith(
              headerTheme: theme.headerTheme.copyWith(
                resizeHandle: theme.headerTheme.resizeHandle.copyWith(
                  width: widget.handleWidth,
                  thickness: widget.handleThickness,
                  indent: widget.handleIndent,
                  endIndent: widget.handleEndIndent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What the callback reported, and a zoom control to test it against.
///
/// **This is the demo explaining itself; delete it when you paste.** The claim
/// this recipe makes — that a reported width is scale-independent — is only
/// worth anything if the reader can change the scale without leaving the page.
class _WidthStrip extends StatelessWidget {
  const _WidthStrip({
    required this.resizable,
    required this.widths,
    required this.scale,
    required this.onScale,
  });

  final bool resizable;
  final Map<String, double> widths;
  final double scale;
  final ValueChanged<double> onScale;

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
            resizable ? 'drag a boundary' : 'resizing is off',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: resizable ? scheme.onSurface : scheme.error,
            ),
          ),
          for (final factor in const [0.8, 1.0, 1.25])
            _ScaleChip(
              factor: factor,
              selected: scale == factor,
              onTap: () => onScale(factor),
            ),
          if (widths.isEmpty)
            Text(
              'nothing resized yet',
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            )
          else
            for (final entry in widths.entries)
              Text(
                '${entry.key} ${entry.value.toStringAsFixed(1)} logical px',
                style:
                    TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
              ),
        ],
      ),
    );
  }
}

class _ScaleChip extends StatelessWidget {
  const _ScaleChip({
    required this.factor,
    required this.selected,
    required this.onTap,
  });

  final double factor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${factor}x',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
