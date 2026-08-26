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
  carried it.** `TablePlusBodyState.didUpdateWidget` has two branches:
  *structure* (`data`, `mergedGroups`) drops everything, because which rows
  exist has moved; *measurement* (`scale`, `calculateRowHeight`) keeps
  `RowLookup` and the renderable indices — those are answers about identity —
  and drops only the heights and the geometry accumulated from them. A new
  field goes in whichever branch that question puts it in. The split used to be
  a list of fields, and `calculateRowHeight` was simply missing from it while
  `FlutterTablePlus` watched it (#120), which is the failure a list has and a
  question does not.
- **The two widgets' invalidation conditions must be read together.** The
  parent's cached total height feeds `needsVerticalScroll`; the body's cache
  feeds the rows *and* `itemExtentBuilder`. So a field the parent watches and
  the body does not produces a table whose scroll decision and whose rows were
  measured by different functions — while the extent and the rows stay
  consistent with each other, which is what makes it look like nothing is
  wrong.
- **The last row's border is a named behaviour**, not an edge case:
  `LastRowBorderBehavior` makes the choice explicit rather than implicit in a
  conditional.

## Code

`widgets/table_body.dart` — `TablePlusBody`, `TablePlusBodyState`
`widgets/row_geometry.dart` — `RowGeometry`
`widgets/row_lookup.dart` — `RowLookup`
`utils/table_metrics.dart` — `TableMetrics`
`widgets/table_plus_row.dart` — `TablePlusRow`
`widgets/table_plus_row_widget.dart` — `TablePlusRowWidget`, `TablePlusRowStateBase`
`widgets/row_decoration.dart` — `rowDecoration`
`utils/row_background_color.dart` — `rowBackgroundColor`
`models/theme/body_theme.dart` — `LastRowBorderBehavior`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [Observe at the screen, assert by count](../invariant/observe-at-the-screen.md) — geometry is asserted through widget tests, where counting beats naming

## Blast radius

→ [Drag selection](drag-selection.md) — `indexAt` is answered from here; a geometry change moves every hit test
→ [Merged rows](merged-rows.md) — they are the reason index→row is not identity
→ [Row height](row-height.md) — the height it lays out is computed there
→ [Row interaction](row-interaction.md) — the interaction shell wraps each row this layer builds
→ [Theme system](theme-system.md) — body theme decides colours, borders and the dim treatment
→ [Synced scrolling](synced-scrolling.md) — total height is the vertical extent

## Known holes / open

**None.**
