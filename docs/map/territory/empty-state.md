# Empty state

## What it is

What the table shows when there are no rows, with the header still drawn: the
caller's `noDataWidget` in place of the body, or, when there is none, the body's
own "No data available" placeholder.

## Governing decisions

**None.**

## Design model

- **The header stays.** An empty table is still a table with columns; only the
  body is replaced. That is what keeps column widths, sorting affordances and the
  horizontal scroll position stable across a data set becoming empty and filling
  again.
- **The package supplies one default, and only as text.** With no
  `noDataWidget`, the body draws "No data available", three rows tall on
  `backgroundColor`, in `effectiveEmptyStateTextStyle`. Its wording is fixed; its
  style is the theme's, and follows the body text colour (#192). Anything more — an
  illustration, a retry affordance, a different message — is policy, and goes in
  `noDataWidget`.

## Code

`widgets/flutter_table_plus.dart` — `FlutterTablePlus`, which chooses `noDataWidget` over the body
`widgets/table_body.dart` — `TablePlusBody`, which draws the default placeholder

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — this is the branch that replaces the body
→ [Column width resolution](column-width.md) — widths are still resolved with no rows, so any width path that reads row content has to cope with an empty list
→ [Theme system](theme-system.md) — the default placeholder's style is `bodyTheme.emptyStateTextStyle`, and its fallback derives from `textStyle`

## Known holes / open

**None.**
