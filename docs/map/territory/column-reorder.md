# Column reordering

## What it is

Dragging a header cell to move a column, and reporting the new position to the
caller. Like sorting, it changes nothing on its own — the caller owns the order.

## Governing decisions

**None.**

## Design model

- **Order is a column property, not a list position.** Reordering asks the caller
  to change the `order` values; the package re-derives the visible list from them
  on the next build through `orderVisibleColumns`.
- **The drag is a header affordance.** It shares the header cell with the sort
  affordance and the resize handle, so the three gestures have to stay
  distinguishable — which is a real constraint on all three, not a note here.
- **Reordering does not move widths.** Widths are resolved from the column set
  after ordering, so a moved column keeps its own width rather than inheriting
  its neighbour's.
- **The drop targets are the header cells themselves, plus the empty space after
  the last one** — dropping there sends the column to the end. That trailing
  target is an `Expanded` in the header row, so it exists only when the columns
  leave room: with columns flexible enough to fill the viewport it is zero pixels
  wide and the affordance is unreachable. Measured 2026-08-26 in the example.
  A caller who wants it has to pin the columns (see
  [column width resolution](column-width.md)).
- **`newIndex` is the target column's current position**, so a caller's handler
  is remove-then-insert-at, with no `ReorderableListView`-style adjustment. Both
  indices exclude the synthetic selection column.

## Code

`widgets/table_header.dart` — `TablePlusHeader`
`utils/column_ordering.dart` — `orderVisibleColumns`
`models/table_columns_builder.dart` — `TableColumnsBuilder`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Column model and ordering](column-model.md) — this territory only edits what that one defines
→ [Column width resolution](column-width.md) — the width list is positional, so it must be re-derived in the new order, never re-indexed
→ [Column resizing](column-resize.md) — same header cell, competing horizontal drag
→ [Sorting](sorting.md) — same header cell, competing tap

## Known holes / open

**None.**
