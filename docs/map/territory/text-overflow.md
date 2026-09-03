# Text overflow detection

## What it is

Deciding whether a cell's text is actually clipped at its current width, and
caching that answer. It exists because "show a tooltip only when the text does
not fit" needs a real measurement, not a guess.

## Governing decisions

**None.**

## Design model

- **Overflow is measured by laying the text out**, not estimated from character
  counts — `willTextOverflow` does a real layout at the given width.
- **The inputs are resolved from the context the `Text` will be built in**, not
  read off the theme as written. `measurementFor` mirrors what `Text` resolves:
  the ambient `DefaultTextStyle` merged under the theme's style — which supplies
  the font family, `letterSpacing` and `height` a theme style typically does not
  name — and `MediaQuery.textScalerOf`. A measurement that skips either predicts
  a different string than the one on screen, and the auto-fit path in
  `widgets/flutter_table_plus.dart` had been resolving all of it correctly for
  releases while this path resolved none of it.
- **The width measured against is what the glyphs receive, not what the box
  declares.** A `Container` folds `decoration.padding` — the border's own
  `dimensions` — into the child's inset, so each call site subtracts what its own
  decoration consumes, by asking the decoration rather than re-deriving the
  divider's thickness.
- **The measurement is cached on the measurement itself.** `OverflowCache` keys
  on the `TextMeasurement` the answer was computed from, so the memo and the
  layout cannot list different inputs — there is only one list. It keyed on
  `(text, width)` until #156, and that is a hand-written subset: a style change
  or an OS text-size change left a wrong answer in place for as long as the cell
  stayed alive.
- **The cache takes the measurement as a callback** rather than performing it, so
  the caching policy and the measurement can be tested apart.

## Code

`utils/text_overflow_detector.dart` — `TextMeasurement`, `TextOverflowDetector`, `measurementFor`, `willTextOverflow`, `willTextOverflowInContext`
`utils/overflow_cache.dart` — `OverflowCache`, `resolve`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — this territory is where the invariant bites hardest: in a test the same string measures far wider than on screen, so an overflow in a test is a worst-case width simulation and not a defect to be resized away
→ [A decorated box hands its child less than it declares](../invariant/decoration-eats-the-child.md) — the width axis, and the case where what the box shortchanges is a *number* rather than a child, so nothing overflows and nothing paints wrong (#156)
→ [Never re-assemble by hand-listing fields](../invariant/no-hand-enumeration.md) — shape 2, and the site the note itself had cited as the positive precedent: the cache listed two of the inputs the answer depends on (#156)

## Blast radius

→ [Tooltips](tooltips.md) — the overflow answer is the precondition for showing a cell tooltip
→ [Column width resolution](column-width.md) — the width it measures against comes from there, and auto-fit uses the same text measurement
→ [Row height](row-height.md) — text that wraps instead of clipping changes the row's height
→ [Scale / zoom](scale-zoom.md) — a scaled font and a scaled width move the threshold together, and the cache key must reflect both
→ [Merged rows](merged-rows.md) — a group's member cells measure through the ordinary cell, so anything wrong here is wrong once per member too (#155)

## Known holes / open

The two recorded here before — the unsubtracted divider inset and the unread
`MediaQuery.textScaler` — are **closed by #156**, along with two the ticket never
named: the ambient `DefaultTextStyle` was not merged, and the cache key was a
subset of the inputs. What remains:

- **The detector fixes `maxLines: 1` while the cell's `Text` passes none.**
  Measured 2026-09-03 with a throwaway probe on the default theme: a value
  needing 470px in an 87.5px cell renders as **exactly one 20.0px line**, so the
  hardcoded `1` matches what is drawn. Recorded because it is a disagreement
  nothing checks, not because a failure is known — two adversarial passes both
  reasoned that it wrapped, and the probe said otherwise.
  *(`textDirection` was listed here too and is now resolved from
  `Directionality` like the rest. No failure was ever measured under it — only
  bidi strings could break differently — but it is an input the glyphs get, and
  the point of keying on the measurement is that the set is not curated by
  whether a failure has been seen yet.)*
- **Half the return expression is unreachable.** `willTextOverflow` returns
  `didExceedMaxLines || textWidth > maxWidth`, and the painter's reported width
  is clamped to the layout's `maxWidth`, so the second disjunct can never be
  true — the verdict rests on `didExceedMaxLines` alone. #156 offered this to the
  maintainer and it was explicitly declined, so it is **out of scope rather than
  undecided**.
- **`TableRowHeightCalculator.calculateTextHeight` is a third measurement site**
  with a fourth input set — no scaler, no merge, no border term — and it is a
  public export. See [row height](row-height.md).
