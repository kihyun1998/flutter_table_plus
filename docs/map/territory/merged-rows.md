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

## Code

`models/merged_row_group.dart` — `MergedRowGroup`, `MergeCellConfig`
`widgets/table_plus_merged_row.dart` — `TablePlusMergedRow`
`widgets/row_lookup.dart` — `RowLookup`
`utils/table_metrics.dart` — `TableMetrics`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [Never hand-maintain a list a later addition must join](../invariant/no-hand-enumeration.md) — four derivations of one fact, two of them wrong, and no mechanism that made them agree (#135)

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — a group changes what a visual index means, so every index→row mapping is affected
→ [Drag selection](drag-selection.md) — `indexAt` and `idsBetween` must agree with the group's expansion state
→ [Row height](row-height.md) — a merged row's height is not a data row's height
→ [Cell editing](cell-editing.md) — merged cells commit through their own callback
→ [Row identity](row-identity.md) — a group id and a row id occupy the same string space in callbacks
→ [Tooltips](tooltips.md) — the merged row renders its own cells, so tooltip wiring exists twice

## Known holes / open

**None.**
