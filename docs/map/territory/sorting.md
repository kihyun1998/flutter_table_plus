# Sorting

## What it is

The sort affordance: which column is sorted, in which direction, what the next
direction is when the header is tapped, and which icon shows it. The package
never sorts the data — it reports the requested state and renders what the caller
gives back.

## Governing decisions

**None.**

The sort *cycle* is the only real decision here — whether a third tap returns to
unsorted, and whether ascending or descending comes first — and it is exposed as
`SortCycleOrder` without a record saying why both orders are offered rather than
one being chosen.

## Design model

- **Sorting is a request, not an operation.** `onSort(columnKey, direction)`
  fires; the caller re-sorts its own list and passes it back down.
- **The next direction is a pure function** of the current one and the cycle
  order — `nextSortDirection` — so the header cell holds no sort state.
- **Three states, not two.** `SortDirection.none` is a real state, which is what
  makes "tap back to unsorted" expressible.
- **Icons are theme data, not logic.** `SortIcons` supplies the three glyphs.

## Code

`utils/sort_cycle.dart` — `nextSortDirection`
`models/table_column.dart` — `SortDirection`, `SortCycleOrder`, `SortIcons`
`widgets/table_header_cell.dart` — `HeaderCell`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Column model and ordering](column-model.md) — `sortable` and the column key come from there, and the three sort types live in that file
→ [Row identity](row-identity.md) — re-sorting is exactly the case identity-by-id exists to survive; a selection must not move when the order does
→ [Theme system](theme-system.md) — icon and header text styling
→ [Tooltips](tooltips.md) — the header cell renders both the sort affordance and the header tooltip

## Known holes / open

**None.**
