/// The row card — the whole feature, in one file you can paste.
library;

import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../demo_data/demo_data.dart';
import '../theme/table_palette.dart';

/// Hover anywhere on a row and a card about that row follows the cursor.
///
/// **The row is the hover region; the pointer is the anchor.** You do not get
/// to choose that. A row's render box is as wide as the table's *content*, not
/// as wide as the slice of it on screen — so a child anchor would aim at the
/// centre of whatever slice happens to be visible: on screen, and nowhere near
/// the cell you are pointing at. The package forces [TooltipAnchor.pointer]
/// for this one tooltip and ignores whatever the theme says, which is the only
/// place in the tooltip system where an anchor is a correctness requirement
/// rather than a taste.
///
/// It is worth stating that reason exactly, because a *different* one used to
/// be written here and this repository withdrew it: the tooltip does not miss
/// because the row's centre scrolls off screen. It has not, since just_tooltip
/// 0.4.2 clipped the target to the visible part. It misses because that centre
/// is the middle of the viewport, wherever your cursor happens to be along the
/// row. Same conclusion, and the wrong reason is the one that gets someone to
/// conclude the bug is fixed so `pointer` can go.
///
/// **A card needs the bubble to get out of its way.** The card is your widget
/// and it draws its own surface; the tooltip around it draws one too, and
/// without this the reader sees a `Card` sitting inside a grey lozenge with
/// twelve pixels of the wrong padding around it. So `rowTooltipTheme` is
/// overridden to a transparent, unpadded, shadowless container — which is what
/// the whole sub-theme is *for*, and why the shared demo theme leaves it alone
/// rather than making every other table pay for it.
///
/// **The cell tooltips will hide it, and by default they all exist.**
/// `TooltipBehavior.always` means "whenever the column ellipsizes", every
/// column ellipsizes by default, so an untouched table has a cell tooltip over
/// every cell — and a cell tooltip nests *inside* the row tooltip, so the
/// innermost one wins and the card never appears. Nothing is broken when that
/// happens; you asked for two tooltips over the same pixel and got the inner
/// one. The columns below therefore set [TooltipBehavior.never] on the ones
/// that have nothing to add. The `position` column deliberately does **not**,
/// so the reader can see the collision on purpose: hover a long position and
/// you get the text, hover anything else on the same row and you get the card.
///
/// Two other ways out, both real: give the column a `tooltipFormatter` that
/// returns `''` for the rows you want the card on — an empty message draws
/// nothing and, since just_tooltip 0.4.4, *claims* nothing, so the card comes
/// through — or take `hideOnEmptyMessage` off if what you actually wanted was
/// an empty bubble.
///
/// **Return null and that row has no card.** The builder's return type is
/// `Widget?`, so the decision is per-row and lives in your code, not in a
/// setting. Below, the inactive employees get none.
///
/// **A merged row never gets one either**, and that is not a rule you can turn
/// off: a merged row stands for several data rows, so there is no single
/// `rowData` to hand the builder. The package returns the row unwrapped before
/// it ever calls you. The strip below is there so you can watch that happen.
class RowCardRecipe extends StatefulWidget {
  const RowCardRecipe({
    super.key,
    this.enabled = true,
    this.waitDuration = const Duration(milliseconds: 700),
  });

  /// Whether the card is built at all.
  ///
  /// Wired to `rowTooltipTheme.enabled` rather than by withholding the builder,
  /// because those are two different switches and the theme one is the one a
  /// settings panel usually reaches for. Withholding the builder does the same
  /// thing one layer up.
  final bool enabled;

  /// How long the pointer rests before the card appears.
  ///
  /// Longer than a text tooltip's on purpose: a card is a large object that
  /// covers what you were looking at, so it should take more deliberation to
  /// summon than a line of text does.
  final Duration waitDuration;

  @override
  State<RowCardRecipe> createState() => _RowCardRecipeState();
}

class _RowCardRecipeState extends State<RowCardRecipe> {
  /// Two employees marked inactive, at fixed positions.
  ///
  /// The generator makes roughly one in five inactive at random, which is fine
  /// for a table and useless for a claim: "inactive employees have no card" is
  /// only demonstrable if the reader can find one. Pinning the one field the
  /// recipe asserts about — and leaving every other field random — is the same
  /// thing the tooltip and merged-rows recipes do.
  /// Both are outside the first four rows on purpose — see [_groups].
  static const Set<int> _inactive = {5, 9};

  /// One position long enough that the `position` column has to cut it.
  ///
  /// The collision this recipe exists to show — a cell tooltip appearing
  /// instead of the card — only fires on truncated text, and the generator's
  /// longest title is twenty-four characters, which fits. So the claim had
  /// nothing to point at. Same discipline as [_inactive]: pin the field a claim
  /// rests on, leave the rest random.
  static const int _longPositionIndex = 1;
  static const String _longPosition =
      'Principal Engineer, Platform Infrastructure and Developer Tooling';

  static final List<Employee> _rows = [
    for (final (index, employee)
        in RandomDataGenerator.generateEmployees(12).indexed)
      employee.copyWith(
        isActive: !_inactive.contains(index),
        position: index == _longPositionIndex ? _longPosition : null,
      ),
  ];

  static Object? _name(Employee e) => e.name;
  static Object? _position(Employee e) => e.position;
  static Object? _department(Employee e) => e.department;
  static Object? _salary(Employee e) => e.salary;

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
                // Silenced so the card has somewhere to appear. Left at the
                // default, this cell would cover it.
                tooltipBehavior: TooltipBehavior.never,
                headerTooltipBehavior: TooltipBehavior.never,
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
                // Left loud on purpose: this is the collision, visible. Hover a
                // position that is cut short and the cell wins; hover any other
                // column on the same row and the card appears.
                tooltipBehavior: TooltipBehavior.onlyTextOverflow,
                headerTooltipBehavior: TooltipBehavior.never,
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
                tooltipBehavior: TooltipBehavior.never,
                headerTooltipBehavior: TooltipBehavior.never,
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
                tooltipBehavior: TooltipBehavior.never,
                headerTooltipBehavior: TooltipBehavior.never,
              ),
            ))
          .build();

  /// Demo scaffolding — see [_MergeStrip].
  bool _merged = false;

  /// The first four rows, as one group. Only here to make the "no card on a
  /// merged row" rule visible; a real table would build groups from its data.
  ///
  /// They are the first four deliberately: [_inactive] keeps them all active,
  /// so every card the merge removes is one that was there a moment ago.
  List<MergedRowGroup<Employee>> get _groups => _merged
      ? [
          MergedRowGroup<Employee>(
            groupId: 'group_a',
            rowKeys: _rows.take(4).map((e) => e.id).toList(),
            mergeConfig: const {
              'department': MergeCellConfig(
                shouldMerge: true,
                mergedContent: Text('Four rows, one card fewer'),
              ),
            },
          ),
        ]
      : const [];

  /// The card itself.
  ///
  /// Returning null is a per-row opt-out: an employee who has left gets no
  /// card, and nothing in the table needed configuring for that.
  Widget? _card(BuildContext context, Employee employee) {
    if (!employee.isActive) return null;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                employee.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${employee.position} · ${employee.department}',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                employee.email,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = demoTableTheme(Theme.of(context).brightness);

    return Column(
      children: [
        _MergeStrip(
          merged: _merged,
          onChanged: (value) => setState(() => _merged = value),
        ),
        Expanded(
          child: FlutterTablePlus<Employee>(
            columns: _columns,
            data: _rows,
            rowId: (employee) => employee.id,
            mergedGroups: _groups,
            rowTooltipBuilder: _card,
            // `copyWith` from the shared theme rather than a fresh
            // `TablePlusTooltipTheme`: this recipe names a handful of fields
            // and constructing a new one silently resets every other one to a
            // package default — including fields added after this was written.
            theme: theme.copyWith(
              rowTooltipTheme: theme.tooltipTheme.copyWith(
                enabled: widget.enabled,
                waitDuration: widget.waitDuration,
                // The card draws its own surface, so the tooltip must not draw
                // one behind it.
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                elevation: 0,
                showArrow: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A merge toggle, so the "a merged row carries no card" rule can be watched
/// rather than believed.
///
/// **This is the demo explaining itself; delete it when you paste.** The rule
/// belongs to two features at once, so neither one's knob pane can hold it —
/// a pane draws its own feature's controls and nothing else. The same reason
/// the resize recipe carries a zoom control.
class _MergeStrip extends StatelessWidget {
  const _MergeStrip({required this.merged, required this.onChanged});

  final bool merged;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: scheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Text(
              merged
                  ? 'the first four rows are one merged row — hover it, no card'
                  : 'hover a row; inactive employees have no card by choice',
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
          ),
          Text(
            'merge four rows',
            style: TextStyle(fontSize: 11.5, color: scheme.onSurface),
          ),
          Switch(value: merged, onChanged: onChanged),
        ],
      ),
    );
  }
}
