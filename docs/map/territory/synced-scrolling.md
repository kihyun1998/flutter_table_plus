# Synced scrolling

## What it is

Keeping the header, the body and the horizontal scrollbar aligned on one
horizontal offset, and keeping the body's vertical scroll usable at the same
time. Every coordinate any other territory reads is read *through* this
alignment, which is why it is the smallest territory with the widest blast
radius.

## Governing decisions

**None.**

`CLAUDE.md` states the rule — the body is the input master, the header uses
`NeverScrollableScrollPhysics` — but it is an identity document: it records the
rule that won, not the alternatives that lost or why. Nothing in the repo records
why the body (rather than the header, or a shared controller above both) is the
master, so the next author is free to reverse it without knowing what breaks.

## Design model

- **The body is the input master.** The header never accepts user scroll input;
  it is driven. The scrollbar is driven the same way.
- **A driven controller must not drive back.** `NoCascadeGuard` suppresses the
  echo a `jumpTo` would otherwise produce, so a single user gesture cannot
  ping-pong between the two controllers.
- **Every jump is clamped into the slave's own range** before it is applied —
  the slave's extent is not the master's, so an unclamped mirror of the master's
  offset is out of range whenever the two differ.

## Code

`widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`
`utils/no_cascade_guard.dart` — `NoCascadeGuard`, `resolveJump`, `reset`
`utils/clamped_scroll_delta.dart` — `clampedScrollDelta`

## Reference behaviour

**None.** This area has never been compared against the Flutter SDK's own
two-axis scrolling (`TwoDimensionalScrollView` and friends), so it is not known
which of its rules are forced by the framework and which are this package's
choice.

## Cross-cutting invariants

→ [Viewport-local coordinates come from one frame](../invariant/viewport-local-frame.md) — every drag and resize coordinate is read against this alignment
→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — `clampedScrollDelta` and `NoCascadeGuard.resolveJump` are two of its sites

## Blast radius

→ [Drag selection](drag-selection.md) — its coordinates are viewport-local *because* the header is not an input surface; change who scrolls and the frame moves
→ [Scale / zoom](scale-zoom.md) — a scale change re-derives both offsets from the old ones, through this pair
→ [Column resizing](column-resize.md) — the resize drag auto-scrolls the same horizontal controller
→ [Column width resolution](column-width.md) — total content width is what there is to scroll; `stretchLastColumn` changes it

## Known holes / open

**None.**
