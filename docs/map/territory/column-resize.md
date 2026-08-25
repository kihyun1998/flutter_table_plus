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
→ [Column model and ordering](column-model.md) — `resizable` and the bounds are column properties

## Known holes / open

**None.**
