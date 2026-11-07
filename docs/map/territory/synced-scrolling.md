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
  controllers `SyncedScrollControllers` creates are `SmoothScrollController`s.
  `FlutterTablePlus.wheelMotion` defaults to a spring, by the maintainer's
  call, which reversed the opt-in #181 shipped with before 2.18.0 was
  published. `null` is the way out: the controllers then carry a
  zero-duration motion, which is
  `ScrollController`'s own wheel path rather than an imitation of it. A slave
  still moves by `jumpTo`, now once per frame of a motion — the guard re-arms
  on every master notification, so it holds at that rate (measured: zero
  misaligned frames on either axis). Changing `wheelMotion` swaps the motion
  and keeps the controllers, because re-creating them resets the offset.
- **A wheel over a scrollbar is the body's input** (#212). A strip is a
  `Scrollable` of its own, and the controller this widget creates for it is a
  `ScrollbarController` from `flutter_smooth_wheel_scroll`, which hands the
  wheel to the body's position, takes its end from the body's, and stops the
  body's motion on a press or a track click. The mirroring stays here: a strip
  still follows by `jumpTo`, through `NoCascadeGuard`. A scrollbar controller
  passed in is left as it is. The hand-off is upstream's because
  flutter_folderview needs the same code (maintainer's call, 2026-11-06,
  upstream #32).
  **The strip holds no motion of its own, because two synced motions cancel
  each other.** Each mirrored `jumpTo` ends the other side's motion, and
  `NoCascadeGuard` stops the echo, not the cancellation. Measured 2026-11-06
  against 0.1.5 with `SmoothScrollController`s on the strips: a 120 notch over
  the strip and a 60 notch over the body two frames later settled at 120, and
  the same in the other order, against 180 with the hand-off.
  **The body's physics are what keep Ctrl+wheel out**, because the strip does
  not carry `_ScaleBlockingScrollPhysics`: its `Scrollable` claims the event,
  and the hand-off then refuses it. So inside a page, Ctrl+wheel over the middle
  of the vertical strip does not move the page, where over the body it can;
  upstream records that as the maintainer's choice. A strip that does not claim
  the event leaves it to the page: the vertical strip at its end, and the
  horizontal strip for a vertical wheel.
- **Shift+wheel over the horizontal strip is handled here** (maintainer's call,
  2026-11-06). `RawScrollbarState._pointerSignalEventDelta` reads `dx` on a
  horizontal bar and ignores `pointerAxisModifiers` (flutter/flutter#193282),
  and on the desktop the bar's painter takes the hit, so the strip's
  `Scrollable` never sees the event. A `Listener` around the strip,
  `_handleHorizontalScrollbarSignal`, reads the modifier as `Scrollable` does and
  registers with the pointer-signal resolver. Its body's physics are asked by the
  hand-off, not here. That registration is why there is no double
  move on Android, where the strip's `Scrollable` is hit and registers first.
  It goes through `position.pointerScroll`, so it takes the hand-off above.
  Remove it when the SDK reads the modifier.
- **The constraint is a floor.** `SyncedScrollControllers` builds on
  `ScrollbarController`, which 0.1.6 introduced. Below that, 0.1.0 declared
  Flutter `>=3.41.0`, the SDK it was built with, so a 3.32 user could not resolve
  it; and 0.1.1 dropped a notch, as closed below.

## Code

`widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`
`widgets/flutter_table_plus.dart` — `_handleHorizontalScrollbarSignal`
`utils/no_cascade_guard.dart` — `NoCascadeGuard`, `resolveJump`, `reset`
`utils/clamped_scroll_delta.dart` — `clampedScrollDelta`
`test/smooth_wheel_scroll_test.dart` — per-frame alignment under `wheelMotion`

## Reference behaviour

**Not compared against the Flutter SDK's own two-axis scrolling**
(`TwoDimensionalScrollView` and friends), so it is not known which of its rules
are forced by the framework and which are this package's choice.

The wheel path was read against the SDK (3.41.9) and
`../flutter_smooth_wheel_scroll` 0.1.1, both raw, for #181, and 0.1.2 again
for its fix. `Scrollable._receivedPointerSignal` decides whether to claim a
wheel event from `position.pixels`, not from where a motion is heading, and
the smooth position overrides `pointerScroll` alone. Since 0.1.2 a notch the
motion cannot use is handed to the nearest enclosing scroll view on the same
axis that can move (`_passToAncestor`). The body's vertical `Scrollable` sits
inside its horizontal one, so that walk skips the horizontal one on its way
to a page; `test/smooth_wheel_scroll_test.dart` pins this layout, which
upstream's own tests do not have.

A wheel reaches a strip by two routes, read in the SDK (3.41.9):
`Scrollable._receivedPointerSignal` and, over the thumb or track,
`RawScrollbarState._receivedPointerSignal`. Both decide from the strip's own
pixels and extents and both end in `position.pointerScroll`, which is where
`ScrollbarController` takes over. Re-read on 3.47.1 with
`flutter_smooth_wheel_scroll` 0.1.6, raw.

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

- **Shift+wheel during a thumb drag ends the drag.** Measured 2026-11-07 on the
  Windows target, `wheelMotion: null`: a 20px drag reached 60, a Shift+wheel of
  60 reached 120, and a further 20px drag left it at 120, with no exception. A
  plain wheel over the bar is ignored during a thumb drag off the web
  (`RawScrollbarState._thumbDrag`), but over the body it ends the drag too,
  because the mirrored `jumpTo` goes idle. Telling a drag apart here would take
  state for a case nobody has reported.
- **An inertia cancel over a strip does not stop a motion.**
  `RawScrollbarState._receivedPointerSignal` answers
  `PointerScrollInertiaCancelEvent` with a `jumpTo` on the strip alone, so the
  body's motion runs on; over the body the event stops it. Trackpad inertia only.

**Closed: the vertical strip's end is the body's.** The strip's `contentExtent`
subtracted `trackWidth` when the table scrolled sideways, 12px with the default
theme, though the two viewports are the same height. `ScrollbarController` takes
its end from the body and hides that number, so the test reads the strip's
content size rather than its extent.

**Closed: a press on the thumb stops a motion and a drag then takes.** On a plain
strip controller a 30px thumb drag left a motion running to 300, measured
2026-11-06. `test/smooth_wheel_scroll_test.dart` pins the behaviour on 0.1.6.

**Closed: a notch during a motion near an end no longer disappears.** On
0.1.1 the body claimed the notch, because it was still short of its extent,
and then used none of it. Measured 2026-09-22 with the table inside a page
`SingleChildScrollView`: one notch to the end, then a second 60px notch two
frames later. The page moved 60 with `wheelMotion` null, 0 with a spring on
0.1.1, and 60 with a spring on 0.1.2. It was reported upstream rather than
worked around here (upstream #7) and fixed there.
