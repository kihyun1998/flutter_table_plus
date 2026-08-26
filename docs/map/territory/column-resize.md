# Column resizing

## What it is

The drag handle between two header cells, the live width it produces while
dragging, the auto-scroll when the drag reaches a viewport edge, the double-tap
auto-fit, and handing the final width back to the caller to persist.

## Governing decisions

**None.**

Width persistence is a caller responsibility (`initialResizedWidths` in,
`onColumnResized` out) and that split is not recorded anywhere — only
demonstrated in `docs/FEATURES.md`.

## Design model

- **The drag produces a width, not a layout.** The handle computes a candidate
  width, bounds it, and reports it; the caller decides whether to keep it and
  hands it back on the next build. The package stores nothing.
- **The handle needs a viewport coordinate and gets it differently from the drag
  path.** It converts through its own `RenderBox` rather than reading a
  viewport-local pointer position — the one site in the repo that satisfies the
  single-frame invariant by argument instead of by construction.
- **Auto-scroll during a resize drag reuses the drag-selection auto-scroller**,
  so the edge behaviour is the same in both gestures by construction rather than
  by imitation.
- **Auto-fit is a measurement, not a heuristic** — it delegates to width
  resolution's text measurement and is bounded like any other width.
- **Resizing is armed table-wide.** There is no `resizable` on the column, only
  on the table — the one capability in this package that is not per-column,
  which is worth knowing because `sortable` and `editable` sitting next to each
  other make it look like there must be a third.
- **Widths cross the boundary in logical units, and so do the bounds.** The
  handle drags in rendered pixels; what is stored and what is reported are
  divided by the scale first, so a persisted width survives a change of zoom.
  `minWidth` / `maxWidth` make the trip the other way — they are declared
  logical and multiplied by the scale before they can bound a rendered drag.
  Both conversions are the same rule, and the second one was missing until #114:
  a bound compared in the wrong space is wrong by exactly the factor, and
  invisible at 1.0.

## Code

`widgets/table_resize_handle.dart` — `ResizeHandle`
`widgets/edge_auto_scroller.dart` — `EdgeAutoScroller`
`utils/clamped_scroll_delta.dart` — `clampedScrollDelta`
`models/theme/header_theme.dart` — `TablePlusResizeHandleTheme`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — three sites in the handle alone, one per drag phase
→ [Viewport-local coordinates come from one frame](../invariant/viewport-local-frame.md) — this territory holds the site that satisfies it the other way, and it is the one a grep for the frame cannot see

## Blast radius

→ [Column width resolution](column-width.md) — resized widths re-enter resolution and must survive its ordering
→ [Synced scrolling](synced-scrolling.md) — the resize auto-scroll drives the shared horizontal controller
→ [Drag selection](drag-selection.md) — shares the auto-scroller; a change to edge behaviour lands in both gestures
→ [Column model and ordering](column-model.md) — the bounds are column properties; `resizable` itself is not, and never was

## Known holes / open

The bounds-conversion hole this section used to hold was fixed in #114. Three
smaller ones were measured while fixing it and are **not** fixed.

**A scale change during a held drag reports a width in a space nothing
measured.** `_dragWidth` is seeded once, in rendered pixels, at drag start;
both things that consume it — the bounds and the divisor — are re-derived from
the *current* scale on every build. Measured 2026-08-26, identical pointer path:
**241.0** with the scale held, **120.5** with the host rebuilt at 2.0 mid-drag.
Reachable in the product, because a `PointerScrollEvent` is dispatched by hit
test and is not captured by the drag's gesture arena, so ctrl+wheel during a
resize reaches the zoom handler. Pre-existing and unchanged by #114 — the
divisor alone was already scale-dependent — but #114 added a second term that
reads the live scale, so the desync now has two sources instead of one.

**The reported width can land just outside the declared bound.**
`maxWidth * scale` then `/ scale` is not a lossless round trip at every double.
Measured at `scale = 0.8999999999999999` — which is exactly what this package's
own Ctrl+wheel handler produces two default ticks down from 1.0 — a declared
ceiling of `300` reports **300.00000000000006** and a floor of `80` reports
**80.000000000000014**. Layout is unaffected (width resolution re-clamps in
logical space), so this reaches `onColumnResized` and nothing else. It is exact
at 2.0 and at the example's own chips (0.8, 1.25), which is why the tests do not
see it — they were written at the one non-1.0 factor where the arithmetic is
exact.

**The auto-scroll drag phase is unobserved at any scale.**
`test/resize_auto_scroll_test.dart` asserts that the handle exists and that the
header moved, and names neither `scale` nor a bound. `_onResizeScrolled` is the
third of this territory's three clamp sites and no assertion anywhere pins a
width it produced.
