# Drag selection

## What it is

Press-and-drag over rows to select a range, with a rubber band drawn over the
viewport and auto-scroll when the pointer reaches an edge. It produces the same
`Set<String>` of row ids that ordinary selection does, and hands it back through
callbacks — it never stores it.

## Governing decisions

**None.**

`CLAUDE.md` records the resulting architecture as an invariant, and the war
stories record incidents, but no record holds the decision itself: why the
gesture state lives in a controller rather than in the body's `State`, and what
was rejected. The port and the controller are the two most reusable pieces here
and neither has a record above it.

## Design model

- **One coordinate frame.** The `Listener` sits *outside* the body's horizontal
  `Scrollable`, so `event.localPosition` is viewport-local on **both** axes. No
  conversion happens anywhere in the gesture path; there is nothing to get out of
  step.
- **The controller owns the state machine, the rubber-band geometry and the
  auto-scroll `Timer`.** Scroll application is injected as callbacks, so the
  whole thing is unit-testable with `fakeAsync` and no widget pump.
- **Row lookup goes through a narrow port.** `RowLocator` exposes only `indexAt`
  and `idsBetween`; the body implements it. That is what keeps the controller
  independent of the body's caching and layout.
- **Lazy anchor.** A pointer-down in the empty area below the last row defers the
  anchor until the pointer first crosses into a real row, so a drag confined to
  empty space selects nothing.
- **The two endpoints answer different questions, and a rebuild moves only one.**
  The anchor means *the row you pressed* and must survive the layout changing
  under it; the current endpoint means *the row under the pointer* and must
  follow it. A height change mid-gesture leaves the anchor alone for free, on
  account of what `measurementOnly` leaves standing — owned by
  [row rendering and geometry](row-render-geometry.md) and by the
  `RowCacheInvalidation` enum, and not restated here. The current endpoint is
  not covered: nothing outside the controller's own pointer and tick handlers
  rewrites it and a rebuild reaches none of them, so `FlutterTablePlusState`
  re-resolves it post-frame whenever that geometry was dropped (#133).

## Code

`widgets/drag_selection_controller.dart` — `DragSelectionController`
`widgets/row_locator.dart` — `RowLocator`
`widgets/edge_auto_scroller.dart` — `EdgeAutoScroller`
`widgets/table_body.dart` — `TablePlusBodyState`
`models/theme/drag_selection_theme.dart` — `TablePlusDragSelectionTheme`

## Reference behaviour

**None.** Flutter's own `SelectionArea` / `SelectableRegion` solve a related
problem (drag-extend over rendered content with auto-scroll) and have never been
read against this implementation.

## Cross-cutting invariants

→ [Never hand-maintain a list a later addition must join](../invariant/no-hand-enumeration.md) — `indexAt` answers from a cached row geometry, so an input missing from that cache's invalidation condition lands here as a drag selecting the wrong rows (#128)

→ [Viewport-local coordinates come from one frame](../invariant/viewport-local-frame.md) — this territory is the reason the invariant exists
→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — the auto-scroller clamps its proximity ratio
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — three of the register's entries are here — the gesture state machine, the auto-scroll `Timer`, and the port both sides agree on
→ [A file's directory is decided before it is written](../invariant/tree-rule.md) — `drag_selection_controller.dart` is the named exception on the `widgets/` side: not a `Widget`, and placed there anyway

## Blast radius

→ [Row selection](row-selection.md) — same `Set<String>`, different entry point; a change to what a selection *is* lands in both
→ [Synced scrolling](synced-scrolling.md) — auto-scroll drives the same controllers, and the frame depends on the header not being an input surface
→ [Row identity](row-identity.md) — `idsBetween` returns caller-owned ids, so identity rules bind here
→ [Row rendering and geometry](row-render-geometry.md) — `indexAt` is answered from row geometry; merged rows change what an index means

## Known holes / open

**The anchor drifts when `data` itself is replaced mid-gesture.** The endpoint
refresh above covers a geometry change; it does not cover the snapshot moving.
`_startRenderIndex` is a position in the list the drag began on, so handing over
a different list re-points it at whoever now holds that index — measured
2026-09-04 with a reversed six-row list, where an anchor taken on row `'2'`
reported the range from row `'3'`. Left undefined rather than repaired: what
"the row you pressed" means when that row may no longer exist is a question
nobody has needed an answer to, and the three candidate answers (re-point by id,
cancel the drag, leave it) each cost something. Stated on
`onDragSelectionUpdate` so a consumer meets it before a bug report does.

The endpoint refresh fires here too, and measured 2026-09-04 that costs less
than it sounds: it reports only when the resolved index moved, so a new list
that leaves every height alone emits nothing at all on the rebuild — pinned by
*a new data list under the pointer emits nothing by itself*. A structural change
that also moves heights delivers the undefined range a pointer move would have
delivered, only sooner. The refresh is deliberately **not** narrowed to
`measurementOnly` to sidestep that: a structural change drops the geometry too,
so the endpoint is equally stale there, and gating one consumer of
`classifyRowCacheInvalidation` on a hand-drawn subset of its answers is the
shape that has drifted in this repository three times (#120, #128, #169).
