# Column model and ordering

## What it is

What a column *is* — its key, how it reads a value out of a row, how it renders,
what it allows (sorting, editing) and within what bounds (`minWidth`,
`maxWidth`) — and the order the visible ones appear in. Resizing is *not* here:
it is armed on the table, not on the column. Every other column territory starts from this object.

## Governing decisions

**None.**

`docs/MIGRATION.md` documents the v1→v2 shape change (a `Map`-keyed column set,
a typed `valueAccessor`) but it is a migration guide: it tells a caller what to
change, not why the shape was chosen or what was rejected.

## Design model

- **Columns are a keyed map, not a list.** Identity is the key, so order is a
  separate concern from membership — which is what makes reordering and hiding
  independent of the column set.
- **The builder is the only safe way to construct an ordered set.**
  `TableColumnsBuilder` exists because hand-assigning order values silently
  produces duplicates and gaps.
- **Reading a value is the column's job, not the table's.** `valueAccessor`
  keeps the table agnostic about `T`.
- **Visibility and order are resolved once per build** by
  `orderVisibleColumns`, and everything downstream consumes that list
  positionally — which is why the width list and the column list must stay
  index-aligned.

## Code

`models/table_column.dart` — `TablePlusColumn`
`models/table_columns_builder.dart` — `TableColumnsBuilder`
`utils/column_ordering.dart` — `orderVisibleColumns`

## Reference behaviour

**None.** Flutter's `DataColumn` / `DataTable` and the other table packages have
never been read against this model.

## Cross-cutting invariants

**None.**

## Blast radius

→ [Column width resolution](column-width.md) — widths are produced per visible column, positionally aligned with this list
→ [Column reordering](column-reorder.md) — it edits order, not membership
→ [Sorting](sorting.md) — `sortable` and the column key are read from here
→ [Cell editing](cell-editing.md) — `editable` is a per-column flag
→ [Tooltips](tooltips.md) — per-column tooltip behaviour hangs off the column
→ [Public barrel](public-barrel.md) — this is the most-imported public type in the package

## Known holes / open

**None.**
