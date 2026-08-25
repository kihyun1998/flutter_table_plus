# Scale / zoom

## What it is

A caller-owned zoom factor applied to the whole table, plus the Ctrl+wheel
gesture that asks the caller to change it. The package renders at the given
`scale` and reports the requested next one; it never stores the factor.

## Governing decisions

**None.**

The mechanism is documented — in `tip.md`, written for sibling packages — but no
record decides the policy questions: that scale is caller-owned rather than
internal state, that the step is 0.05, that colours and radii do not scale while
widths and text do.

## Design model

- **The caller owns the factor.** `scale` comes in, `onScaleChanged` goes out
  with the requested next value; clamping the range is the caller's (the doc
  comment's own example clamps to 0.5–3.0).
- **Blocking the scroll is a physics decision, not an event decision.** A
  `PointerSignalEvent` cannot be stopped from propagating, so a `Listener` that
  handles Ctrl+wheel does not prevent the inner `Scrollable` from scrolling too.
  The custom physics refuses the offset *before* the scrollable registers with
  the pointer-signal resolver — see the reference entry below.
- **Offsets are re-derived across a scale change**, both axes, from the pre-scale
  offset and the ratio, and clamped into the new extents.
- **Not everything scales.** Which theme fields participate is decided in the
  theme system, not here.

## Code

`widgets/flutter_table_plus.dart` — `FlutterTablePlus`
`models/theme/theme.dart` — `TablePlusTheme`

## Reference behaviour

→ [tip.md §1 — Ctrl+wheel scroll and zoom firing together](../../../tip.md#1-ctrlwheel-시-스크롤과-줌-동시-발생-문제) — settles that `Scrollable._receivedPointerSignal()` asks `physics.shouldAcceptUserOffset()` *before* handling the scroll, so returning `false` there keeps the scrollable out of the pointer-signal resolver entirely
→ [tip.md §2 — scroll position correction](../../../tip.md#2-스크롤-위치-보정) — settles how the pre-scale offset is carried across the change
→ [tip.md §4 — column width scaling formula](../../../tip.md#4-컬럼-너비-스케일링-공식) — settles the width arithmetic this territory hands to width resolution

## Cross-cutting invariants

→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — both re-derived offsets are clamped into the new extents
→ [Never re-assemble by hand-listing fields](../invariant/no-hand-enumeration.md) — scaling a theme is the site that lost a field

## Blast radius

→ [Theme system](theme-system.md) — `scaledBy` decides what a scale *means* per field; this territory only supplies the factor
→ [Synced scrolling](synced-scrolling.md) — both offsets are re-derived through it on every scale change
→ [Column width resolution](column-width.md) — scaled widths still have to clamp against `minWidth`/`maxWidth`
→ [Row height](row-height.md) — a scaled row height changes what fits, and therefore what overflows

## Known holes / open

**None.**
