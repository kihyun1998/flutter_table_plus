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
- **Wheel input is animated on the master only** (#181). The two body
  controllers `SyncedScrollControllers` creates are `SmoothScrollController`s;
  with `wheelMotion` null they carry a zero-duration motion, which is
  `ScrollController`'s own wheel path rather than an imitation of it. A slave
  still moves by `jumpTo`, now once per frame of a motion — the guard re-arms
  on every master notification, so it holds at that rate (measured: zero
  misaligned frames on either axis). Changing `wheelMotion` swaps the motion
  and keeps the controllers, because re-creating them resets the offset.

## Code

`widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`
`utils/no_cascade_guard.dart` — `NoCascadeGuard`, `resolveJump`, `reset`
`utils/clamped_scroll_delta.dart` — `clampedScrollDelta`
`test/smooth_wheel_scroll_test.dart` — per-frame alignment under `wheelMotion`

## Reference behaviour

**Not compared against the Flutter SDK's own two-axis scrolling**
(`TwoDimensionalScrollView` and friends), so it is not known which of its rules
are forced by the framework and which are this package's choice.

The wheel path was read against the SDK (3.41.9) and
`../flutter_smooth_wheel_scroll` 0.1.1, both raw, for #181.
`Scrollable._receivedPointerSignal` decides whether to claim a wheel event from
`position.pixels`, not from where a motion is heading, and the smooth position
overrides `pointerScroll` alone.

## Cross-cutting invariants

→ [Viewport-local coordinates come from one frame](../invariant/viewport-local-frame.md) — every drag and resize coordinate is read against this alignment
→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — `clampedScrollDelta` and `NoCascadeGuard.resolveJump` are two of its sites
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — the single coordinate frame is on the register: break it and every drag coordinate is wrong by a constant offset nothing reports

## Blast radius

→ [Drag selection](drag-selection.md) — its coordinates are viewport-local *because* the header is not an input surface; change who scrolls and the frame moves
→ [Scale / zoom](scale-zoom.md) — a scale change re-derives both offsets from the old ones, through this pair
→ [Column resizing](column-resize.md) — the resize drag auto-scrolls the same horizontal controller
→ [Column width resolution](column-width.md) — total content width is what there is to scroll; `stretchLastColumn` changes it

## Known holes / open

- **A wheel turned over a scrollbar is not animated.** The scrollbar is its own
  `Scrollable` with its own plain controller; the wheel jumps it, the slave
  listener jumps the body, and a motion in progress stops. Upstream documents
  the same limit.
- **Near an end, a notch during a motion is swallowed instead of passing
  outward.** Because the claim is decided from `position.pixels`, the body
  claims a notch while it is still short of its extent even when the motion is
  already heading there, and the notch then adds nothing. An enclosing scroll
  view takes the wheel only once the motion has settled. Measured 2026-09-22
  with the table inside a page `SingleChildScrollView`: one notch to the end,
  a second 60px notch two frames later — the page moved 60 with `wheelMotion`
  null and 0 with a spring, then 60 on the next notch after settling. This is
  the SDK's decision rule meeting upstream's target, and neither is this
  package's.
