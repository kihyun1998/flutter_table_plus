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
- **Expansion is caller state**, reported through `onMergedRowExpandToggle`, like
  every other piece of state here.

## Code

`models/merged_row_group.dart` — `MergedRowGroup`, `MergeCellConfig`
`widgets/table_plus_merged_row.dart` — `TablePlusMergedRow`
`widgets/row_lookup.dart` — `RowLookup`
`utils/table_metrics.dart` — `TableMetrics`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — a group changes what a visual index means, so every index→row mapping is affected
→ [Drag selection](drag-selection.md) — `indexAt` and `idsBetween` must agree with the group's expansion state
→ [Row height](row-height.md) — a merged row's height is not a data row's height
→ [Cell editing](cell-editing.md) — merged cells commit through their own callback
→ [Row identity](row-identity.md) — a group id and a row id occupy the same string space in callbacks
→ [Tooltips](tooltips.md) — the merged row renders its own cells, so tooltip wiring exists twice

## Known holes / open

**None.**
