# Empty state

## What it is

What the table shows when there are no rows: the caller's `noDataWidget` in place
of the body, with the header still drawn.

## Governing decisions

**None.**

## Design model

- **The header stays.** An empty table is still a table with columns; only the
  body is replaced. That is what keeps column widths, sorting affordances and the
  horizontal scroll position stable across a data set becoming empty and filling
  again.
- **The widget is the caller's.** The package supplies no default message, no
  illustration and no retry affordance — those are policy.

## Code

`widgets/flutter_table_plus.dart` — `FlutterTablePlus`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — this is the branch that replaces the body
→ [Column width resolution](column-width.md) — widths are still resolved with no rows, so any width path that reads row content has to cope with an empty list

## Known holes / open

**None.**
