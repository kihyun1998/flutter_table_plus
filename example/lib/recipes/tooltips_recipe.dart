/// Tooltips — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Hover a cell whose text is cut short and the rest of it appears.
///
/// **`TooltipBehavior.always` does not mean "always".** It means *whenever the
/// column is set to ellipsize* — `behavior == always` resolves to
/// `column.textOverflow == TextOverflow.ellipsis`, and that is the default for
/// every column. So a table nobody configured already shows a tooltip on every
/// cell, including the short ones where it only repeats what is already on
/// screen. [TooltipBehavior.onlyTextOverflow] is the one that measures: it
/// shows a tooltip on the cells that are actually clipped and stays silent on
/// the rest. It costs a text measurement per cell, which is why it is not the
/// default, and the measurement is cached.
///
/// That difference is invisible in a table where everything overflows, so the
/// data below is deliberately mixed: three positions long enough to be cut and
/// three that fit, in a column narrow enough to tell them apart. Switch between
/// the two behaviours and watch which rows stop responding.
///
/// **All of which is true of cells, and none of it of headers.** A header's
/// `always` returns true flat — it never looks at `textOverflow`, so the label
/// gets a tooltip whether or not it is cut. And a header's `onlyTextOverflow`
/// measures on every build, with no cache behind it, because the header is one
/// row and the body is however many you have. Two knobs of the same type,
/// answering to two different rules; that is why they are separate settings
/// rather than one.
///
/// **The anchor decides where the bubble is, and it has two honest answers.**
/// [TooltipAnchor.child] puts it against the middle of the thing you hovered;
/// [TooltipAnchor.pointer] puts it beside the cursor. Neither is more correct
/// in general — a cell is small, so its centre and your cursor are a few pixels
/// apart and both look the same until the cell is wide.
///
/// It stops being a preference exactly once. A **row** tooltip — the card the
/// row-card recipe draws — is anchored at the pointer by the package and you
/// cannot change it, because a row's box is as wide as the table's *content*,
/// not as wide as the part of it you can see. Its centre is therefore the
/// middle of the viewport rather than anything you pointed at — visible, and
/// unrelated to the cell under the cursor. (Not "off screen": the target is
/// clipped to the visible part, and has been since just_tooltip 0.4.2. That
/// reason was written down here once and withdrawn.) Same enum, and one of its
/// values is a correctness requirement rather than a taste.
///
/// **The header falls back rather than copying.** [TablePlusTheme
/// .headerTooltipTheme] is nullable, and null means *use `tooltipTheme`*. That
/// is why the header anchor here has three settings and not two: "follow cells"
/// passes null through and walks the fallback, and the other two hand the
/// header a theme of its own — which is the only way to anchor a header
/// differently from the cells beneath it. Handing it a copy of `tooltipTheme`
/// looks identical on screen and means something else in the code.
///
/// **Two ways to put your own content in a bubble, and one of them wins.**
/// [TablePlusColumn.tooltipFormatter] returns a `String` and gets the styled
/// text bubble; [TablePlusColumn.tooltipBuilder] returns a `Widget` and gets
/// the bubble as a container. When both are set the builder wins, which the
/// knobs above let you check. A widget tooltip also escapes the text gates
/// entirely — "did the text overflow" is undefined for a widget, so only
/// [TooltipBehavior.never] silences it — and it takes the whole cell as its
/// hover region rather than just the glyphs.
///
/// **An empty formatter is how you turn one row's tooltip off.** Return `''`
/// and the cell has nothing to draw, so it stands aside instead of covering the
/// row card underneath it. That is [TablePlusTooltipTheme.hideOnEmptyMessage],
/// on by default; set it to false and you get the empty bubble you asked for.
class TooltipsRecipe extends StatelessWidget {
  const TooltipsRecipe({
    super.key,
    this.enabled = true,
    this.behavior = TooltipBehavior.always,
    this.headerBehavior = TooltipBehavior.always,
    this.waitDuration = const Duration(milliseconds: 500),
    this.direction = TooltipDirection.bottom,
    this.alignment = TooltipAlignment.center,
    this.anchor = TooltipAnchor.child,
    this.headerAnchor,
    this.showArrow = false,
    this.offset = 8.0,
    this.showFormatter = false,
    this.showBuilder = false,
  });

  /// Whether any tooltip is shown at all. One switch above every column's
  /// [TooltipBehavior] — off here and no per-column setting can override it.
  final bool enabled;

  /// When a *cell* tooltip appears.
  final TooltipBehavior behavior;

  /// When a *header* tooltip appears. Separate from [behavior] because a header
  /// label and a cell value are truncated by the same width for different
  /// reasons, and a table often wants one and not the other.
  final TooltipBehavior headerBehavior;

  /// How long the pointer has to rest before the bubble appears.
  final Duration waitDuration;

  /// Which side of the anchor the bubble prefers. It is a preference: the
  /// bubble flips to the other side rather than leave the screen.
  final TooltipDirection direction;

  /// How the bubble lines up along that side.
  ///
  /// **Its meaning changes with [anchor].** Against a child there are two edges
  /// to line up with; against a pointer there are none, so it decides which of
  /// the bubble's *own* edges lands on the cursor.
  final TooltipAlignment alignment;

  /// Where a cell tooltip is anchored.
  final TooltipAnchor anchor;

  /// Where a *header* tooltip is anchored, or null to follow the cells.
  ///
  /// Null is not "unset with a default of child" — it is the fallback itself.
  /// See the class comment.
  final TooltipAnchor? headerAnchor;

  /// Whether the bubble grows a little pointer toward its anchor.
  final bool showArrow;

  /// The gap between the anchor and the bubble.
  final double offset;

  /// Whether the `position` column formats its own tooltip text instead of
  /// repeating the cell.
  final bool showFormatter;

  /// Whether the `position` column builds a *widget* tooltip. Wins over
  /// [showFormatter] when both are on.
  final bool showBuilder;

  /// Positions chosen so that some overflow the column and some do not —
  /// which is the only state in which the two behaviours look different.
  ///
  /// Everything else about these rows comes from the shared generator, so this
  /// pins the one field the recipe makes a claim about and leaves the rest as
  /// varied as any other page's.
  static const List<String> _positions = [
    'Principal Engineer, Platform Infrastructure',
    'Staff Engineer',
    'Analyst',
    'Distinguished Engineer, Routing and Bridging Protocols',
    'Designer',
    'Engineering Manager, Developer Experience',
  ];

  /// One employee marked inactive, at a fixed index.
  ///
  /// [_positionTooltip] returns `''` for an inactive row, and the class comment
  /// sells that as the demonstration of how an empty formatter turns one row's
  /// tooltip off. The generator makes roughly one in five inactive at random,
  /// so over six rows there was a one-in-four chance the page opened with no
  /// inactive row at all and demonstrated nothing. Pinning the second field the
  /// recipe makes a claim about, for the same reason as the first.
  static const int _inactiveIndex = 3;

  static final List<Employee> _rows = [
    for (final (index, employee)
        in RandomDataGenerator.generateEmployees(_positions.length).indexed)
      employee.copyWith(
        position: _positions[index],
        isActive: index != _inactiveIndex,
      ),
  ];

  static Object? _name(Employee e) => e.name;
  static Object? _position(Employee e) => e.position;
  static Object? _department(Employee e) => e.department;

  /// The text the `position` column puts in its bubble.
  ///
  /// Returning `''` gives that row no tooltip at all rather than an empty
  /// bubble — the mechanism the row card relies on.
  static String _positionTooltip(Employee e) =>
      e.isActive ? '${e.position}\n${e.department}' : '';

  /// A *widget* tooltip: the bubble is still the theme's, only its contents are
  /// yours.
  ///
  /// So the ink has to come from the same place the bubble's colour does. The
  /// app's `ColorScheme` is the wrong source — it describes the page, and the
  /// bubble is drawn over the page in the opposite value. Reading
  /// `tooltipTheme.textStyle` back off the theme is what keeps the two in step
  /// when either changes.
  static Widget _positionCard(BuildContext context, Employee e) {
    final ink =
        demoTableTheme(Theme.of(context).brightness).tooltipTheme.textStyle
            .color;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(e.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ink,
              )),
          const SizedBox(height: 2),
          Text(e.position, style: TextStyle(fontSize: 11.5, color: ink)),
        ],
      ),
    );
  }

  Map<String, TablePlusColumn<Employee>> get _columns =>
      (TableColumnsBuilder<Employee>()
            ..addColumn(
              'name',
              TablePlusColumn<Employee>(
                key: 'name',
                label: 'Name',
                order: 0,
                width: 150,
                valueAccessor: _name,
                tooltipBehavior: behavior,
                headerTooltipBehavior: headerBehavior,
              ),
            )
            // The narrow column, and the long header. Both are cut on purpose:
            // one shows a cell tooltip earning its keep, the other shows that a
            // header has its own behaviour and its own anchor.
            ..addColumn(
              'position',
              TablePlusColumn<Employee>(
                key: 'position',
                label: 'Position, with a heading long enough to be cut too',
                order: 0,
                width: 210,
                valueAccessor: _position,
                tooltipBehavior: behavior,
                headerTooltipBehavior: headerBehavior,
                tooltipFormatter: showFormatter ? _positionTooltip : null,
                tooltipBuilder: showBuilder ? _positionCard : null,
              ),
            )
            ..addColumn(
              'department',
              TablePlusColumn<Employee>(
                key: 'department',
                label: 'Department',
                order: 0,
                width: 150,
                valueAccessor: _department,
                // Silenced per column, which is the level the decision belongs
                // at: this value is never cut, so a tooltip on it would only
                // repeat what the cell already says.
                tooltipBehavior: TooltipBehavior.never,
                headerTooltipBehavior: TooltipBehavior.never,
              ),
            ))
          .build();

  @override
  Widget build(BuildContext context) {
    final theme = demoTableTheme(Theme.of(context).brightness);
    final cellTooltip = theme.tooltipTheme.copyWith(
      enabled: enabled,
      anchor: anchor,
      direction: direction,
      alignment: alignment,
      showArrow: showArrow,
      offset: offset,
      waitDuration: waitDuration,
    );

    return FlutterTablePlus<Employee>(
      columns: _columns,
      data: _rows,
      rowId: (employee) => employee.id,
      // `copyWith`, naming only what changes. A tooltip theme has far more
      // fields than the handful below, and constructing a fresh one resets
      // every field this recipe did not think to mention — including the ones
      // added to `TablePlusTooltipTheme` after this line was written. Counting
      // them here would only produce a number that goes stale silently.
      theme: theme.copyWith(
        tooltipTheme: cellTooltip,
        // Null while the header follows the cells, so the package's documented
        // fallback is the path this recipe normally walks. The two themes then
        // differ in nothing but the anchor.
        headerTooltipTheme: headerAnchor == null
            ? null
            : cellTooltip.copyWith(anchor: headerAnchor),
      ),
    );
  }
}
