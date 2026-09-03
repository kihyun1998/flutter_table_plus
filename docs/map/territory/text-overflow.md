# Text overflow detection

## What it is

Deciding whether a cell's text is actually clipped at its current width, and
caching that answer. It exists because "show a tooltip only when the text does
not fit" needs a real measurement, not a guess.

## Governing decisions

**None.**

## Design model

- **Overflow is measured by laying the text out**, not estimated from character
  counts — `willTextOverflow` and its in-context variant do a real layout at the
  given width.
- **The measurement is cached per (text, width).** `OverflowCache` exists because
  the question is asked once per cell per build, and the layout is the expensive
  part.
- **The cache takes the measurement as a callback** rather than performing it, so
  the caching policy and the measurement can be tested apart.

## Code

`utils/text_overflow_detector.dart` — `TextOverflowDetector`, `willTextOverflow`, `willTextOverflowInContext`
`utils/overflow_cache.dart` — `OverflowCache`, `resolve`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — this territory is where the invariant bites hardest: in a test the same string measures far wider than on screen, so an overflow in a test is a worst-case width simulation and not a defect to be resized away

## Blast radius

→ [Tooltips](tooltips.md) — the overflow answer is the precondition for showing a cell tooltip
→ [Column width resolution](column-width.md) — the width it measures against comes from there, and auto-fit uses the same text measurement
→ [Row height](row-height.md) — text that wraps instead of clipping changes the row's height
→ [Scale / zoom](scale-zoom.md) — a scaled font and a scaled width move the threshold together, and the cache key must reflect both

## Known holes / open

- **The measured width subtracts padding and not the divider.** A cell measures
  against `width - theme.padding.horizontal`, but it also draws a 0.5px
  `verticalDividerSide` whose inset `Container` folds into the child — so a
  string filling the cell is judged to fit by up to half a pixel, and
  `onlyTextOverflow` withholds the tooltip on exactly the text that is clipped.
- **`MediaQuery.textScaler` is not read.** The detector lays out at the style's
  own size while the `Text` it predicts for scales, so a user text-scale setting
  changes what is clipped on screen and not what the detector reports. The
  *width* path already takes a `TextScaler`; this one has no parameter for one.
- Both are the ordinary cell's, both predate merged rows, and both reached every
  group member when the stacked branch started reusing it (#156).
