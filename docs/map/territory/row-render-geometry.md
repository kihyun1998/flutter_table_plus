# Row rendering and geometry

## What it is

The body list: which row is at which visual index, how tall it is, where its top
edge sits, and what decorates it — background colour, dim state, borders,
including the last row's. It is the layer every hit test and every scroll
calculation ultimately asks.

## Governing decisions

**None.**

## Design model

- **The body is a pure row renderer.** It holds no gesture state and no selection
  state; it renders what it is given and answers questions about geometry.
- **It answers those questions through a narrow port.** `TablePlusBodyState`
  implements `RowLocator`, and the parent reaches it through a `GlobalKey` — the
  only reason the state is public.
- **Index → row goes through one place.** `RowLookup` owns it, because merged
  groups make the mapping non-trivial; `TableMetrics` owns the totals for the
  same reason.
- **Decoration is derived, not stored.** `rowBackgroundColor` and `rowDecoration`
  are functions of (state, theme), so a row cannot be left wearing a stale
  colour after a rebuild.
- **Cache invalidation is split by what the change *is*, not by which field
  carried it.** `classifyRowCacheInvalidation` answers `structural` /
  `measurementOnly` / `none`, and every consumer switches on it — the two
  caching widgets, and since #133 a third that drops no cache at all: a live
  drag's moving endpoint is re-resolved on the same answer, because the row
  geometry it hit-tests against is one of the things being dropped. *structural*
  (`data`, `mergedGroups`, or the ids no longer matching) drops everything,
  because which rows exist has moved; *measurementOnly* (`scale`,
  `theme.rowHeight`, `calculateRowHeight`) keeps `RowLookup` and the renderable
  indices — those are answers about identity — and drops only the heights and the
  geometry accumulated from them. A new field goes in whichever branch that
  question puts it in. The split used to be a list of fields, and
  `calculateRowHeight` was simply missing from it while `FlutterTablePlus`
  watched it (#120), which is the failure a list has and a question does not.
- **The measurement inputs are one list, in one place.** `rowMeasurementChanged`
  in `utils/` holds them — the height callback, the scale, and the body theme's
  `rowHeight`. They used to be two hand-written conditions, and the two
  disagreed twice: #120 had the height callback in the parent's and not the
  body's, #128 had the theme's height in neither.
- **And the *response* to that predicate is one function too**, which it was not
  until #169. `classifyRowCacheInvalidation` returns `structural` /
  `measurementOnly` / `none` and its consumers switch on it, each dropping its
  own caches — or, in the drag-selection case, re-resolving a gesture rather
  than a cache. Unifying the predicate and leaving each caller to decide what to
  drop had left the same defect one layer up: the body reasoned its way to the
  split above and the parent kept a single branch, so a `scale` change rebuilt a
  `RowLookup` no scale can move. `structural` dominates `measurementOnly`, so
  the id walk is consulted before a measurement-only answer can be returned —
  measured at 13–15% of the rebuild it replaces, which is what makes paying it
  the cheaper side.
  - **It is a reduced list, not a derivation**, and the difference is the point.
    Dart cannot enumerate what a computation reads, and folding the inputs into
    a value type with an `==` moves the hand-list into that operator — which is
    the shape that dropped fields from `scaledBy`. One predicate removes the
    failure that actually happened; it does not remove forgetting a new input.
  - **The two callers pass different things and that matters.** The parent hands
    it an unscaled `theme.bodyTheme.rowHeight` and multiplies by `scale` itself;
    the body hands it one `scaledBy` has already scaled. So the scale term is
    redundant for the body and load-bearing for the parent — a mutation deleting
    it survives every body-side test.
- **A stale cache here is invisible where you would look for it.** Rendering
  reads the inputs live — `itemExtent`, `itemExtentBuilder` — so the rows are
  always the right height. Only what is *derived* from the cache disagrees: the
  parent's total, which decides whether a vertical scrollbar exists, and the
  body's `RowGeometry`, which every drag hit-test is answered from. And the
  geometry is built lazily on the first drag query, so a test that never drags
  before the change cannot observe the difference at all.
- **The identity assumptions are stated in one place, and it is not here.**
  What `data`, `rowId` and `mergedGroups` oblige the caller to do lives in
  [Row identity](row-identity.md); the two `didUpdateWidget` branches here are
  the mechanism, not the rule. #132 found the rule stated nowhere and implied
  by four conditions — and found that the structure branch's own inputs have
  the same shape as the measurement branch's, one level up.
- **The last row's border is a named behaviour**, not an edge case:
  `LastRowBorderBehavior` makes the choice explicit rather than implicit in a
  conditional.

## Code

`widgets/table_body.dart` — `TablePlusBody`, `TablePlusBodyState`
`widgets/row_geometry.dart` — `RowGeometry`
`widgets/row_lookup.dart` — `RowLookup`
`utils/table_metrics.dart` — `TableMetrics`
`utils/row_cache_invalidation.dart` — `RowCacheInvalidation`, `classifyRowCacheInvalidation`
`utils/row_measurement.dart` — `rowMeasurementChanged`
`widgets/table_plus_row.dart` — `TablePlusRow`
`widgets/table_plus_row_widget.dart` — `TablePlusRowWidget`, `TablePlusRowStateBase`
`widgets/row_decoration.dart` — `rowDecoration`
`utils/row_background_color.dart` — `rowBackgroundColor`
`models/theme/body_theme.dart` — `LastRowBorderBehavior`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [Never hand-maintain a list a later addition must join](../invariant/no-hand-enumeration.md) — two widgets cached row heights off two hand-written conditions, and the lists disagreed twice (#120, #128)
→ [Observe at the screen, assert by count](../invariant/observe-at-the-screen.md) — geometry is asserted through widget tests, where counting beats naming
→ [A decorated box hands its child less than it declares](../invariant/decoration-eats-the-child.md) — the plain row and the body's list slots build the same decorated-box shape
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — the cached geometry a hit test answers from, never exercised against changing row heights (#128)

## Blast radius

→ [Drag selection](drag-selection.md) — `indexAt` is answered from here; a geometry change moves every hit test
→ [Merged rows](merged-rows.md) — they are the reason index→row is not identity
→ [Row height](row-height.md) — the height it lays out is computed there
→ [Row interaction](row-interaction.md) — the interaction shell wraps each row this layer builds
→ [Row identity](row-identity.md) — the ids this layer snapshots are that territory's, and so is the rule for when they go stale
→ [Theme system](theme-system.md) — body theme decides colours, borders and the dim treatment
→ [Synced scrolling](synced-scrolling.md) — total height is the vertical extent

## Known holes / open

**None.**
