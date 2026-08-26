/// Zoom — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Ctrl+wheel over the table to scale the whole thing.
///
/// **The factor is yours.** `scale` goes in, `onScaleChanged` comes back with
/// the value a wheel tick *proposes*, and nothing moves until you accept it.
/// The package deliberately does not clamp: a table that stopped at some range
/// it chose would be imposing a policy on an app that might legitimately want
/// to go to 8x, so the range lives in [_ZoomRecipeState._propose] and every app
/// that wants one writes it. Wire the callback straight to state with no clamp
/// and the reader can wheel the table down through zero.
///
/// **Withholding `onScaleChanged` turns off two things, not one.**
/// `blockModifierScroll` defaults to `null`, which means *follow
/// `onScaleChanged`* — so a table with no scale callback also stops
/// intercepting Ctrl+wheel, and Ctrl+wheel scrolls like an ordinary wheel. The
/// two are only separable by setting the flag explicitly, which is the switch
/// this recipe puts on a knob: turn it off with zoom still on and one gesture
/// zooms *and* scrolls at the same time. That is worth doing once, because it
/// is exactly the bug the flag exists to prevent — a `PointerSignalEvent`
/// cannot be stopped from propagating, so blocking the scroll is a decision the
/// scroll *physics* has to make before the scrollable ever registers for the
/// event.
///
/// **Scroll offsets survive a scale change.** The table re-derives both from
/// the pre-scale offset and the ratio, so the rows you were looking at are
/// still roughly under the pointer afterwards. Scroll to the middle of this
/// table before you zoom — that is the behaviour, and it is free.
///
/// What scales is dimensional: widths, row heights, text. What does not is
/// decisional — colours, and the radii and borders that would stop reading as
/// hairlines. That split is the theme's, not this file's.
class ZoomRecipe extends StatefulWidget {
  const ZoomRecipe({
    super.key,
    this.scale = 1.0,
    this.blockModifierScroll = true,
  });

  /// The factor to start at. Wheeling moves the recipe's own copy; moving this
  /// knob overrides it.
  final double scale;

  /// Whether Ctrl+wheel is consumed for zoom alone.
  ///
  /// Off, with zoom on, the same gesture does both — see the class comment.
  final bool blockModifierScroll;

  @override
  State<ZoomRecipe> createState() => _ZoomRecipeState();
}

class _ZoomRecipeState extends State<ZoomRecipe> {
  /// The range this app is willing to render at. Not the package's — it has
  /// none, and asserts only that the factor is above zero.
  static const _min = 0.5;
  static const _max = 3.0;

  /// Columns totalling 800px, so both axes have somewhere to scroll and the
  /// offset correction is something a reader can watch rather than take on
  /// trust.
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

  late final List<Employee> _employees =
      RandomDataGenerator.generateEmployees(40);

  late double _scale = widget.scale;

  @override
  void didUpdateWidget(ZoomRecipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when the knob itself moves. Comparing against the recipe's own
    // `_scale` instead would undo every wheel tick the moment any other
    // setting changed.
    if (widget.scale != oldWidget.scale) {
      _scale = widget.scale;
    }
  }

  /// The clamp the package leaves to you. Removing it is not a smaller version
  /// of this feature — it is a table that can be wheeled to a scale of zero.
  void _propose(double next) {
    setState(() => _scale = next.clamp(_min, _max));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScaleStrip(scale: _scale, blocking: widget.blockModifierScroll),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _employees,
            rowId: (employee) => employee.id,
            theme: demoTableTheme(Theme.of(context).brightness),
            scale: _scale,
            onScaleChanged: _propose,
            blockModifierScroll: widget.blockModifierScroll,
          ),
        ),
      ],
    );
  }
}

/// The factor, and what the flag is currently doing.
///
/// **This is the demo explaining itself; delete it when you paste.** A scale
/// change is legible on screen, but the number behind it is not — and the
/// difference between blocking and not blocking is a gesture doing two things
/// at once, which is easy to see and hard to name.
class _ScaleStrip extends StatelessWidget {
  const _ScaleStrip({required this.scale, required this.blocking});

  final double scale;
  final bool blocking;

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
            'Ctrl + wheel over the table',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            'scale ${scale.toStringAsFixed(2)}x',
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
          ),
          Text(
            blocking
                ? 'zoom only'
                : 'zooms and scrolls at once — blockModifierScroll is off',
            style: TextStyle(
              fontSize: 11.5,
              color: blocking ? scheme.onSurfaceVariant : scheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
