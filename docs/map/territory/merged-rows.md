# Merged rows

## What it is

Grouping several data rows into one visual row: which columns merge, what a
merged cell shows, and whether the group is expanded or collapsed. It is the one
feature that breaks the one-row-one-index assumption every other territory would
otherwise be entitled to.

## Governing decisions

**None.**

Nothing records why merging is a caller-supplied *group list* rather than a
property of the rows themselves, nor what the id space of a group is relative to
row ids — which is the question every callback in this area answers implicitly.

## Design model

- **Groups are supplied, not inferred.** `mergedGroups` comes in from the caller;
  the package never decides that two rows belong together.
- **A group is a row for layout purposes and several rows for data purposes.**
  `RowLookup` is what reconciles the two, and `TableMetrics` is what totals them —
  which is why every count in this package goes through those two rather than
  `data.length`.
- **A group is as tall as its present members added up, and each member is drawn
  at its own height inside it.** Every member but the **last cell in the column**
  gets a fixed extent; the last stays flexible, because the group's
  `BoxDecoration` bottom border is taken out of the `Column` the members are laid
  out in and the border sits against that cell. Absent `calculateRowHeight` every
  cell is flexible and the equal split is correct. An expanded group's summary
  row is `bodyTheme.rowHeight` while the members keep their measurements.
  - Until 2.17.0 every member carried `flex: 1`, so the measured heights were
    computed, passed into the widget and discarded — a 48/96/48 group drew three
    64px members inside a correct 192px total (#121). Distributing the border
    shortfall proportionally instead of placing it was tried and is worse: it
    moves every member, by an amount that grows with `dividerThickness`, and
    silently.
- **A member is drawn by the ordinary cell; only a *spanning* cell is built
  here.** A member is an ordinary row for every purpose except that it has no
  row of its own, so the stacked branch builds `TablePlusCell` and hands it the
  one thing a plain row's cell does not need — the line between two members,
  which no row decoration can reach. A merged cell is genuinely different (one
  cell over several rows) and keeps its own build.
  - The copy this replaced drifted one decision at a time and every drift was
    silent: overflow measured against a **height** in a parameter named
    `maxWidth`, two divider widths hardcoded past the theme, a widget tooltip
    anchored to the bare `Text` rather than to the cell, no overflow cache, and
    a fifth inline `editKeyAction` (#155). **Parity between the two paths could
    not have caught any of it — and cannot now**: once both sides are one
    widget, breaking that widget breaks both and the comparison still holds.
    Measured. The assertions that discriminate read the *theme*.
- **A merged row builds a cell per *rendered column*, gating on the column and
  never on `isSelectable`.** The selection column is injected only when
  `isSelectable && checkboxTheme.showCheckboxColumn`, and gating on the flag
  instead built a cell no other row had — sized from `columns.first`, which with
  no selection column injected is the first *data* column. Measured before the
  fix: a plain row's text at `x = 16` and the group's at `x = 616` in a 600px
  viewport, so the group rendered blank on a documented setting (#155).
- **Per-column merge configuration.** `MergeCellConfig` decides, per column,
  what a merged cell renders — so a group can merge some columns and keep others
  per-row.
- **Expansion is caller state, and so is the affordance.** `isExpanded` adds
  a summary row — it does not hide the member rows, which is the one place
  this API's vocabulary misleads. The package draws no expand/collapse
  control and reports no toggle: the caller puts one in the merged cell's
  `mergedContent` and drives its own `setState`, because a `MergedRowGroup`
  is an immutable value that gets rebuilt.
  - This bullet used to say expansion was *"reported through
    `onMergedRowExpandToggle`"*. That callback existed, was threaded through
    three widgets, and was never invoked; `docs/FEATURES.md` showed it as
    working too. Both were removed in 2.17.0 along with `isExpandable`, which
    was an extra `&&` in front of `isExpanded` — deleting it from all five
    consumption sites left the whole suite green. **A callback that is
    plumbed but never called reads exactly like one that works**, from the
    declaration and from the docs alike; only a grep for the *call* tells
    them apart.

- **`data` and `mergedGroups` are two caller lists and nothing validates one
  against the other.** A group may name a row `data` does not hold; the table
  renders what it has, anchoring the group at its **earliest present member**
  and reserving no height for the absent ones. It does not warn — the drift
  stays the caller's to notice.
  - **Seven derivations answer "which rows, and how tall", and three of them
    disagreed with the rest.** `computeTableMetrics` anchors on the earliest
    present member and `_getMergedRowHeight` skips an unresolvable key;
    `computeRenderableIndices` anchored on `rowKeys.first`,
    `_getMergedGroupExtent` added `theme.rowHeight` for a key it could not
    find, and inside the widget `_buildRowWidget` kept its **own** copy of the
    anchor and its own copy of the phantom while `_buildStackedCells` drew an
    empty cell for the absent member. So the parent counted a group the body
    drew nothing for, and the body laid out one row height the parent had not
    totalled (#135).
  - **The count was written as four and the real number was seven**, and the
    three that were missed are the three that live in a **widget** while the
    four that were found live in pure functions and state methods. A hand-list
    audited only where it is testable in isolation reports itself complete —
    the pure tests were all green while the screen was still wrong.
  - The anchor has one home now, `TablePlusBodyState._mergedGroupAnchor`, so a
    fourth copy cannot be written by accident.
  - **What that cost is worth stating, because "the two disagree" understates
    it.** Anchoring on `rowKeys.first` made the render condition *unsatisfiable*
    when that key was gone, while the loop still marked every other member
    processed — so one absent row took its whole group off the screen. Measured
    2026-08-31: a group over `['0','1']` and a `data` list without `'0'` drew
    neither. The same shape with the keys merely out of order was pinned as
    correct by a test named *"preserves the out-of-order-rowKeys quirk"*.
  - The rule is one sentence and every site holds it: **a group is anchored,
    measured and drawn on the members that are actually there.**
- **Sorting is the case where those two lists diverge fastest, and the divergence
  is silent.** The table reports a sort and renders what comes back; it does not
  reconcile the new row order with `mergedGroups`, and there is nothing it could
  reconcile them *against* — the caller owns both. So a **global** sort across a
  grouped table interleaves the groups' members, and each group is then anchored
  at wherever its earliest surviving member landed: drawn stacked, correctly by
  the rule above, and wrong on screen. Nothing throws and nothing warns.
  A caller who merges and sorts sorts **within** each group and rebuilds the
  group list from the same pass;
  `example/lib/scenarios/hr_dashboard_scenario.dart` is a worked version, and
  the failure it rules out is the ordinary one — sorting the rows and leaving
  the group list alone, which keeps every id in the right group and moves only
  where it is drawn (#109).

## Code

`models/merged_row_group.dart` — `MergedRowGroup`, `MergeCellConfig`
`widgets/table_plus_merged_row.dart` — `TablePlusMergedRow`
`widgets/cells/table_plus_cell.dart` — `TablePlusCell`
`widgets/row_lookup.dart` — `RowLookup`
`utils/table_metrics.dart` — `TableMetrics`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [Never hand-maintain a list a later addition must join](../invariant/no-hand-enumeration.md) — four derivations of one fact, two of them wrong, and no mechanism that made them agree (#135)
→ [A decorated box hands its child less than it declares](../invariant/decoration-eats-the-child.md) — the group box carries the row divider, and its members are laid out inside `height − border` (#121)

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — a group changes what a visual index means, so every index→row mapping is affected
→ [Drag selection](drag-selection.md) — `indexAt` and `idsBetween` must agree with the group's expansion state
→ [Row height](row-height.md) — a merged row's height is not a data row's height
→ [Cell editing](cell-editing.md) — merged cells commit through their own callback
→ [Row identity](row-identity.md) — a group id and a row id occupy the same string space in callbacks
→ [Tooltips](tooltips.md) — a merged *spanning* cell still wires its own tooltip; a member cell is an ordinary cell and wires it the ordinary way (#155)
→ [Text overflow detection](text-overflow.md) — a member measures its own text, and the width it is handed is this territory’s to get right; handing it a height is what #155 fixed
→ [Sorting](sorting.md) — a sort reorders `data` and nothing reorders `mergedGroups` with it

## Known holes / open

- **A member's separator is gated on the *group's* `isLastRow`.** The question
  is asked at row level and the answer applied at member level, so at the
  default `LastRowBorderBehavior.never` the **last group in a table loses every
  internal separator** and its members render as one undivided block; every
  other group draws two lines at its bottom edge, the last member's and the
  group's own. Found while fixing #155 and deliberately left there — repairing
  it widens a change sized for the cell into one about what the row assembles.
  Measured: a parity test written with the group covering every row read `0.0`
  where it expected the separator's width.
- **The summary cell's `top` border is hardcoded and ungated.** It ignores
  `showHorizontalDividers` where every other horizontal side honours it, and it
  stacks against the last member's own bottom: at `dividerThickness: 4` that
  boundary draws 4px + 0.5px where every other member boundary draws 4px.
- **`getSpanningRowKey` indexes `rowKeys` positionally.** A `spanningRowIndex`
  naming a member `data` no longer holds resolves to an absent row — the one
  place the rule above is not held.
- ~~Two the ordinary cell already had, now inherited by every member~~ —
  **closed by #156**, along with two the ticket never named. Members render
  through the ordinary cell, so the fix reached them for free; the group's
  **spanning** cell kept its own copy of the measurement and was repaired
  separately, because #155's exclusion covered members and not it. See
  [text overflow detection](text-overflow.md).
