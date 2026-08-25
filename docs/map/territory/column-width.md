# Column width resolution

## What it is

Turning a column set plus the available viewport width into the concrete pixel
width of every visible column: declared widths, caller-supplied resized widths,
`stretchLastColumn`, the auto-fit measurement, and the `minWidth`/`maxWidth`
bounds that hold across all of them.

## Governing decisions

**None.**

Nothing records the resolution *order* — which of declared width, resized width
and stretch wins when they disagree — although the order is the whole behaviour
of this territory and is currently readable only from the source.

## Design model

- **Resolution is a pure function of (columns, resized widths, viewport).** It
  produces a `List<double>` positionally aligned with the visible column list;
  everything downstream indexes into it rather than re-deriving.
- **`minWidth` / `maxWidth` bound every path into it** — declared, resized,
  stretched, auto-fitted, scaled. There is no path that is allowed to skip the
  bound, which is why this is an invariant rather than a rule of this note.
- **Auto-fit measures text, it does not guess.** `measureTextWidth` lays the text
  out and takes the widest; the result is then bounded like any other width.
- **Index access is an extension, not raw indexing.** `ColumnWidthAccess.widthAt`
  exists so a width lookup cannot silently read the wrong column when the visible
  list and the width list disagree.

## Code

`utils/column_width_resolver.dart` — `computeColumnWidths`
`utils/table_column_width_calculator.dart` — `TableColumnWidthCalculator`, `measureTextWidth`
`utils/column_width_access.dart` — `ColumnWidthAccess`, `widthAt`

## Reference behaviour

→ [tip.md §4 — column width scaling formula](../../../tip.md#4-컬럼-너비-스케일링-공식) — settles how a scale factor combines with a declared width before the bounds are applied

## Cross-cutting invariants

→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — five of the eighteen sites are in this territory alone
→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — any test that asserts a measured width is measuring the square font, not the screen

## Blast radius

→ [Column resizing](column-resize.md) — it produces the resized widths this consumes, and clamps them the same way
→ [Synced scrolling](synced-scrolling.md) — total width is the horizontal scroll extent
→ [Text overflow detection](text-overflow.md) — a width is exactly what decides whether text overflows
→ [Scale / zoom](scale-zoom.md) — scaled widths re-enter this resolution
→ [Row height](row-height.md) — a narrower column wraps to more lines, which changes the row's height

## Known holes / open

**Automatic column width is undecided.** Double-tap auto-fit exists, but what an
*automatic* width would mean — resolved once on first build, maintained as data
changes, or content-driven per frame — has never been settled, and the three
answers have different costs in this resolution path. Tracked: #2.
