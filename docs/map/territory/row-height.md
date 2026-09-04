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
- **What it measures has to be what the glyphs get, and three of those inputs
  are not in the style the caller writes.** The ambient `DefaultTextStyle` a
  `Text` merges under it, `MediaQuery.textScalerOf`, and the width the cell's
  own decoration takes off the declared one. `createHeightCalculator` resolves
  the first two when handed a `context`; the third is a caller-supplied
  `extraWidth`, the same shape `TableColumnWidthCalculator` takes as
  `bodyExtraWidth`. Skip them and the row is sized from a string the screen
  never draws — measured at 100px predicted against 120px laid out, and the
  text is simply clipped.
- **A height is a per-row fact, not a per-table one**, which is what makes the
  body's geometry non-uniform and forces every offset to be accumulated rather
  than multiplied.

## Code

`utils/table_row_height_calculator.dart` — `TableRowHeightCalculator`, `calculateTextHeight`
`models/theme/body_theme.dart` — `TablePlusBodyTheme`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [A measurement is given what the paint resolves, never what the caller wrote](../invariant/measure-what-the-paint-resolves.md) — the public helper measured with the caller's bare style and a width the cell does not hand out; the symptom is clipped text with no banner
→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — a measured text height in a test is the square font's height, so wrap points differ from the screen's
→ [A decorated box hands its child less than it declares](../invariant/decoration-eats-the-child.md) — a measured height is the number declared, never the number the child receives
→ [A caller's function is not a cache key](../invariant/a-callers-function-is-not-a-key.md) — the one site where neither escape is available, because deriving the answers *is* the cost being avoided (#161)
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — four of the register's entries, including the pair whose halves drifted across four issues (#120, #128, #169)

## Blast radius

→ [Row rendering and geometry](row-render-geometry.md) — heights accumulate into every row's top edge, so a change here moves every hit test
→ [Text overflow detection](text-overflow.md) — wrapping and clipping are the same decision seen from two sides
→ [Column width resolution](column-width.md) — a narrower column wraps to more lines
→ [Merged rows](merged-rows.md) — a group is as tall as its members added up, and each member keeps its own height inside it
→ [Scale / zoom](scale-zoom.md) — scaled text changes what fits on a line

## Known holes / open

- **The documented wiring drops both height caches on every build.** The
  callback is compared with `==`, and a closure built fresh in `build` is never
  equal to the last one — so the per-row heights, the total that decides whether
  a vertical scrollbar appears, and the `RowGeometry` every drag hit-test reads
  are all rebuilt every frame. Measured 2026-09-03: two `createHeightCalculator`
  calls with identical arguments return callbacks that compare `!=`.

  **A value type with an `==` does not fix it, and that was measured rather than
  assumed.** Dart compares two tear-offs of the same method by whether their
  receivers are `identical`, never by whether they are `==` — so wrapping the
  configuration in a class with value equality changes nothing at the call site.
  (The first probe of this said otherwise because it used `const` instances,
  which canonicalise: it was comparing one object with itself.)

  **Changing the parameter's type to take a value object was also measured, and
  is refused.** Probed 2026-09-04 with non-`const` instances: such an object
  compares equal only when the caller already holds their `columns` stable —
  because the configuration contains a `List<TablePlusColumn>` whose
  `valueAccessor` is a function and which has no `==`, and a hand-written `==`
  on that class still fails for an inline accessor. Holding `columns` stable is
  the same discipline as holding the callback stable, so a breaking signature
  change buys nothing that is not already reachable. Worse, `const`-ness alone
  flips the comparison and the analyzer pushes callers toward `const`, so the
  fast path would exist by lint accident.

  **So the hole stays open, but it is no longer silent.** Since 2.17.0 the table
  emits one `debugPrint` per table when it sees the callback change identity on
  several consecutive builds while the data and the columns did not — a
  heuristic, in an `assert`, gated on `columns` identity so a resize drag does
  not trip it. A stable receiver is still the only actual repair and only the
  caller can hold one.
