# Row height

## What it is

How tall a row is: the fixed theme height, the caller's own
`calculateRowHeight`, and the helper that measures wrapped text so a caller can
compute one.

## Governing decisions

**None.**

## Design model

- **Height is the caller's answer when they want one.** `calculateRowHeight`
  takes the row and returns a height; without it the theme's height applies.
- **The package supplies the hard part, not the policy.**
  `TableRowHeightCalculator.calculateTextHeight` measures wrapped text at a
  width, which is the piece a caller cannot compute without the layout — the
  decision of what to do with it stays theirs.
- **A height is a per-row fact, not a per-table one**, which is what makes the
  body's geometry non-uniform and forces every offset to be accumulated rather
  than multiplied.

## Code

`utils/table_row_height_calculator.dart` — `TableRowHeightCalculator`, `calculateTextHeight`
`models/theme/body_theme.dart` — `TablePlusBodyTheme`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — a measured text height in a test is the square font's height, so wrap points differ from the screen's

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — heights accumulate into every row's top edge, so a change here moves every hit test
→ [Text overflow detection](text-overflow.md) — wrapping and clipping are the same decision seen from two sides
→ [Column width resolution](column-width.md) — a narrower column wraps to more lines
→ [Merged rows](merged-rows.md) — a group is as tall as its members added up, and each member keeps its own height inside it
→ [Scale / zoom](scale-zoom.md) — scaled text changes what fits on a line

## Known holes / open

**None.**
