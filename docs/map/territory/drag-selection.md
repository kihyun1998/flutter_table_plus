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

**None.**
