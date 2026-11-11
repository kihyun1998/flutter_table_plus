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
- **A jump arms the guard only if it moves the slave.** A `jumpTo` to the offset
  the slave already has sends no notification, so a flag armed for it stays set
  and swallows the slave's next real change. Measured 2026-11-07: a scrollbar
  turned on in the same build as the rows shrank, then a track click, left strip
  542.4 and body 728. The no-op `jumpTo` is still made, for the `goIdle` in it.
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
  **With the block on, the body's physics are what keep Ctrl+wheel out**, because the strip does
  not carry `_ScaleBlockingScrollPhysics`: its `Scrollable` claims the event,
  and the hand-off then refuses it. So inside a page, Ctrl+wheel over the middle
  of the vertical strip does not move the page, where over the body it can;
  upstream records that as the maintainer's choice. A strip that does not claim
  the event leaves it to the page: the vertical strip at its end, and the
  horizontal strip for a vertical wheel.
- **A strip stays with its axis, and starts at the body** (#214). The two strips
  are conditional children of one `Stack`, so they carry keys: without them the
  horizontal strip drops into the vertical one's slot when that one leaves, and
  keeps its `ScrollPosition`. Mirroring runs only on a notification, and a strip
  that appears has sent none, while its position restores from `PageStorage` or
  starts at 0. So `_AlignedScrollbarController` corrects the position to the
  body's offset on `attach`, with `correctPixels`: the two agree in the frame it
  appears, and no `jumpTo` sends `NoCascadeGuard` an echo. Attach is the one
  unclamped path, because neither range is current there: when the rows shrink in
  the same build the body's extents are still the old ones, so a clamp would pass
  the old offset through. Both then settle at the new end. Upstream leaves keeping the
  two offsets equal to the consumer, so this is ours. Without it a wheel toward
  the strip's own edge is lost, because the strip decides from its own pixels.
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
  While a pointer is pressed on the strip it claims nothing, off the web, as
  `RawScrollbarState._receivedPointerSignal` refuses a wheel while `_thumbDrag`
  is set (`_thumbDrag == null || kIsWeb`, Flutter 3.47.1); the strip's
  `pointerScroll` goes idle and so would end the drag. The same `Listener`
  counts the pressed pointers with `onPointerDown`/`onPointerUp`/`onPointerCancel`.
  That set is wider than `_thumbDrag`, which only the thumb's drag recognizer
  sets: a press held on the track outside the thumb, a secondary-button press,
  and a thumb press before the drag recognizer starts also refuse the notch,
  where the SDK takes it. Kept wide by the maintainer's call (2026-11-11), shown
  those three cases (read from source, not run) against narrowing to the SDK's
  private thumb test; flutter_folderview keeps the same set. A refused notch is left to the resolver, so a
  horizontal page around the table takes it (measured 2026-11-11: page 60, table
  unmoved). Remove the handler, and this set with it, when the SDK reads the
  modifier.
- **The constraint is a floor.** `SyncedScrollControllers` builds on
  `ScrollbarController`, which 0.1.6 introduced. Below that, 0.1.0 declared
  Flutter `>=3.41.0`, the SDK it was built with, so a 3.32 user could not resolve
  it; and 0.1.1 dropped a notch, as closed below.

## Code

`widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`, `_AlignedScrollbarController`
`widgets/flutter_table_plus.dart` — `_handleHorizontalScrollbarSignal`, `_horizontalScrollbarPointers`
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
→ [A literal test pointer id can be a held gesture's id](../invariant/test-pointer-ids.md) — the wheel helper builds its pointer with `tester.nextPointer`; two single-test literal ids and one pair pinned by hand beside a held scrollbar-thumb gesture stay

## Blast radius

→ [Drag selection](drag-selection.md) — its coordinates are viewport-local *because* the header is not an input surface; change who scrolls and the frame moves
→ [Scale / zoom](scale-zoom.md) — a scale change re-derives both offsets from the old ones, through this pair
→ [Column resizing](column-resize.md) — the resize drag auto-scrolls the same horizontal controller
→ [Column width resolution](column-width.md) — total content width is what there is to scroll; `stretchLastColumn` changes it

## Known holes / open

- **A wheel over the body during a thumb drag ends the drag.** The mirrored
  `jumpTo` goes idle on the strip. Measured 2026-11-11 on the Windows target,
  `wheelMotion: null`: a 20px drag reached 60, a Shift+wheel of 60 over the body
  reached 120, and a further 20px drag left it at 120. A single `Scrollable`
  under a `Scrollbar` does the same, read from Flutter 3.47.1 and not run:
  `Scrollable` registers a wheel with no drag check, and
  `ScrollPositionWithSingleContext.pointerScroll` goes idle. Left as it is.
- **An inertia cancel over a strip does not stop a motion.**
  `RawScrollbarState._receivedPointerSignal` answers
  `PointerScrollInertiaCancelEvent` with a `jumpTo` on the strip alone, so the
  body's motion runs on; over the body the event stops it. Trackpad inertia only.

**Closed: Shift+wheel during a thumb drag no longer ends the drag** (#225).
On the Windows target a 20px thumb drag reached 60. Measured 2026-11-07: with
`wheelMotion: null` a Shift+wheel of 60 then took it to 120 and a further 20px
drag left it there; with a spring the notch moved nothing within a frame and the
further drag reached 61.6, not 120. Remeasured 2026-11-11 before the fix: the
notch took it to 120 with `wheelMotion: null`, and the spring's further drag
reached 61.6. The strip now claims no notch while a pointer is pressed on it;
`test/smooth_wheel_scroll_test.dart` pins both motions, and the release and the
cancel that clear the set.

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
