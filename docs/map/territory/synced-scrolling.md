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
- **Whether the body scrolls is decided against the body's own height** (#231).
  The vertical strip is an overlay and reserves no width, but the horizontal
  strip has a spacer of `trackWidth` under the body, so the body's viewport is
  the table's height minus the header and that spacer. `needsVerticalScroll`
  compares the content against the table's height minus `horizontalTrackHeight`,
  the one value the spacer and the vertical strip's `bottom` also take, so the
  three cannot disagree. Compared against the whole height, a table that
  overflowed by less than the track scrolled with no vertical scrollbar:
  measured 2026-11-11 with the default theme, five rows and a 1000px column,
  heights 296 to 307 scrolled by up to 12px with no bar. The same decision
  drives `LastRowBorderBehavior.smart`, which drew the last row's border in that
  band. `TablePlusTheme.scaledBy` leaves `scrollbarTheme` unscaled, its
  doc-comment's reason being that the scrollbar renders in an overlay; the
  spacer is not an overlay but takes the same `trackWidth`, so it is 12 at every
  scale (measured at scale 2). It stays unscaled by the maintainer's call
  (2026-11-11): the spacer reserves the bar's room, so it follows the bar,
  which is unscaled by that doc-comment. The decision reads whatever value the
  spacer takes, so a later change to it moves all three together. `needsHorizontalScroll` has no
  such term, because nothing is reserved beside the body.
  `test/vertical_scrollbar_track_band_test.dart` pins both ends of the band, the
  cases with no spacer, scale 2 and the smart border. Prior art:
  flutter_folderview #177 made the same correction.
- **A strip stops at its ends, and leaves the fling to the platform** (#234).
  The strip's `SingleChildScrollView` carries `_ScrollbarStripPhysics`, which
  clamps at the ends as `ClampingScrollPhysics` does and hands everything else
  to the platform's physics. `RawScrollbarState._getPrimaryDelta` clamps a
  thumb drag only on the desktop and leaves iOS and Android to the physics
  (Flutter 3.47.1), so with `BouncingScrollPhysics` the strip went past the
  end while the body, mirrored through a clamped `jumpTo`, stopped there.
  Measured 2026-11-16 on the iOS target, 10 px thumb steps: horizontal strip
  1059.4 against a body at 800, vertical strip 48250111.1 against 4568. The
  vertical one runs away because `BouncingScrollPhysics` scales a push further
  out by `0.52 * (1 - overscroll / viewport)^2`, which is 0 at one viewport of
  overscroll and rises past 1 beyond about 2.4 viewports. A finger never gets
  past the zero; a thumb step is multiplied by track-to-scroll (24 on that
  vertical strip, viewport 232), and the first step past the end is applied
  unclamped, so it landed at 240 overscroll, past the zero. Plain
  `ClampingScrollPhysics` was not used because it also shortens the iOS
  thumb fling (measured: 300.6 to 119.2 horizontally, 720.6 to 539.2
  vertically); `test/scrollbar_thumb_drag_test.dart` derives the expected fling
  from the platform physics' own simulation, and pins a fling that reaches
  the end. The physics sits on the strip, not the controller, so it applies
  to whatever controller the strip gets.
  Prior art: flutter_folderview #220 (`FolderViewBarScrollPhysics`), declined
  plain clamping for the same fling.
- **A strip takes a thumb drag and a track click on Android too.** Material
  `Scrollbar` turns its gestures off on Android when neither the widget nor
  the theme sets `interactive` (`enableGestures`, Flutter 3.47.1). The
  strip's own scrollbar theme does not set it (until #235 a `Theme` wrapper
  that replaced the app's `ThemeData.scrollbarTheme`, now the thumb's own
  `ScrollbarTheme`, below), so an app's `interactive: true` never arrives.
  Measured 2026-11-16 on Android, mouse: a 30 px thumb drag and then
  a click near the far end of the track moved nothing on either axis; on
  Windows the drag reached 90.0 horizontally and 744.8 vertically, and the
  click took them to 410.0 and 930.4. The strip's `Scrollbar` now passes
  `interactive: true`, a widget argument, so no theme turns it off: neither
  `ThemeData.scrollbarTheme` nor a `ScrollbarTheme` widget around the table.
  The iOS `RawScrollbar` passes it too. **Maintainer's call** (2026-11-16), shown three
  options: this; inheriting the app's `ScrollbarTheme.interactive` with true
  when unset, which would also turn the thumb off on the desktop for an app
  that sets `false`; and a new `TablePlusScrollbarTheme.interactive` field
  defaulting to true. Chosen because the table's scrollbar is owned by
  `TablePlusScrollbarTheme`, and to match flutter_folderview #220.
  **Found after that call, and kept by a second maintainer's call**
  (2026-11-16, shown the measurements below; the alternative was to reopen
  the choice and hold the change). Measured 2026-11-16, Android, touch:
  - a touch drag on the thumb now moves the thumb. From mid-track, 30 px
    forward: 400 to 370 horizontally and 2284 to 2254 vertically before, the
    strip dragged as content; 490 and 3028.8 after.
  - a touch drag on the track off the thumb now pages toward the touch and
    ignores the drag: 320 horizontally and 185.6 vertically, either
    direction. Before, it dragged the strip as content: 120 for a 120 px drag
    toward the start, nothing toward the end from 0.
  - a released thumb now flings, as on iOS (`handleThumbPressEnd` hands the
    velocity on only on iOS and Android).
  - the Android path under an app's bouncing physics now reaches the end
    case #234 fixes; it could not before, because the thumb took no drag.
- **A strip's thumb is `TablePlusScrollbarTheme`'s on every platform** (#235).
  `_ScrollbarStripThumb` paints it. Off iOS it is a Material `Scrollbar` under
  a `ScrollbarTheme` widget built from `TablePlusScrollbarTheme`:
  `ScrollbarTheme.of` reads the nearest such widget before
  `ThemeData.scrollbarTheme`, so the `Theme` copy that stood here until #235
  let a `ScrollbarTheme` around the table restyle the thumb. Measured
  2026-11-16 on Android, for #234: its `thumbColor` reached the strip, and
  an empty one gave the thumb Material's Android size, so a press 7 px into
  the 12 px track missed it. On iOS Material `Scrollbar.build` returns a
  `CupertinoScrollbar` built from its own arguments, which has no colour
  argument (`material/scrollbar.dart`, Flutter 3.47.1). Measured 2026-11-16
  on the iOS target, theme thickness 6, radius 1, red: painted thickness 3.0,
  Cupertino's. So iOS gets a `RawScrollbar` with the values Material's
  `Scrollbar` paints with on iOS when it does not hand over: the theme's
  colour, thickness and radius, `crossAxisMargin` 2, `minThumbLength` 48, and
  `minOverscrollLength` 18, which `_MaterialScrollbar` never sets and so
  keeps from `RawScrollbar`'s default `minThumbLength` (`_kMinThumbExtent`,
  `RawScrollbarState.initState`). Off iOS the margins and minimum lengths are
  left to Material, so Android keeps its 0 margin.
  `test/scrollbar_thumb_theme_test.dart` reads the painter on iOS, Android
  and Windows, both strips, with and without a `ScrollbarTheme` around the
  table (thickness 1, radius 9, green, margins 5 and 7, minimum 20).
  **Maintainer's call** (2026-11-16), made against flutter_folderview #218's
  precedent (`FolderViewScrollbarThumb`, its #147 and #216); the alternative
  was to fix the `ScrollbarTheme` leak only and keep `CupertinoScrollbar`
  on iOS, passing only thickness and radius, which leaves the thumb colour
  out of reach there. Accepted with it: the native Cupertino thumb, and its
  thickening while dragged, are gone on iOS.
  **Found in the work, after that call:** a click on the iOS track
  now pages. `CupertinoScrollbar.handleTrackTapDown` skips paging on iOS on
  purpose ("On iOS, tapping the track does not page towards the position of
  the tap", `cupertino/scrollbar.dart`, Flutter 3.47.1); `RawScrollbar`
  pages, as flutter_folderview #218's thumb does. Measured 2026-11-16 on the
  iOS target, a click or a touch 5 px from the far end: 0.0 on both axes
  before, 320.0 horizontally and 185.6 vertically after, the same as Android
  and Windows. A touch drag along the track from there, 120 px toward the
  start, moved nothing before and now pages toward the touch on release, to
  the same values, as on Android. A thumb drag on iOS needs no press hold
  either way (`CupertinoScrollbar` waits 100 ms, `RawScrollbar` 0):
  measured, a 30 px drag with no hold moved the body before and after, mouse
  and touch. The haptic tap is gone too: `CupertinoScrollbar` calls
  `HapticFeedback.mediumImpact()` when the thumb press is taken and when a
  moved thumb is let go slowly (`cupertino/scrollbar.dart`, Flutter 3.47.1),
  and `RawScrollbar` does not. flutter_folderview #218 does not record it.
  **Kept by a second maintainer's call** (2026-11-16), shown these
  measurements and three options: keep it; block iOS track paging with a
  private `RawScrollbar` subclass that skips `handleTrackTapDown` there, as
  `CupertinoScrollbar` does; and that plus the haptic tap. Chosen to match
  flutter_folderview #218 and keep one behaviour across platforms, accepting
  the divergence from iOS's native track tap and haptics.
- **A thumb is painted no thicker than its room** (#237). The room is the
  extent across the strip that the thumb's painter is laid out in: the
  track's `Container` folds its `BoxDecoration` border into the child's
  inset ([decoration-eats-the-child](../invariant/decoration-eats-the-child.md)),
  so the painter gets `trackWidth` less the border on both sides of the
  cross axis. `_buildScrollbarTrack` reads that from the decoration's
  `padding`, the value `Container` insets by, not from the widths the
  caller wrote ([measure-what-the-paint-resolves](../invariant/measure-what-the-paint-resolves.md)).
  `_ScrollbarStripThumb` paints `max(0, min(thickness, room - margin))`,
  where the margin is 0 on Android and 2 elsewhere, and passes the margin
  explicitly to Material's `Scrollbar` too, so the margin the cap uses is
  the one painted; it equals Material's default (`_kScrollbarMargin`,
  `material/scrollbar.dart`, Flutter 3.41.9), so a thumb that fitted paints
  as before. `TablePlusScrollbarTheme.thickness` keeps the value given.
  `MediaQuery` padding is not in the cap: the thumb is built without it, as
  the #238 entry below says. `test/scrollbar_thumb_theme_test.dart` pins the cap
  per platform and axis, with borders on both or one side and drawn inside,
  centred on and outside the edge; the last two are the cases a cap summed
  from the caller's widths gets wrong.
  **Maintainer's call** (2026-11-17), shown the measurements in the closed
  entry below and these alternatives: flutter_folderview's
  `trackWidth - margin` (its #122, #146), which has no border term because
  its track has no border field; documentation only; and leaving it.
  It did not cover the `MediaQuery` padding term, left to #238.
- **A thumb ignores `MediaQuery` padding** (#238). Both scrollbars inset
  their painter by `MediaQuery` padding: Material's `Scrollbar` always
  (`_MaterialScrollbarState.updateScrollbarPainter`, Flutter 3.41.9; it has
  no `padding` argument), `RawScrollbar` unless its `padding` is given
  (`RawScrollbarState.updateScrollbarPainter`). That default keeps a scrollbar
  drawn along the screen's edge clear of a notch or a system bar. A strip's
  thumb runs inside its own track, which the table lays out, so the inset only
  moves it off the track. `_ScrollbarStripThumb` wraps both paths in
  `MediaQuery.removePadding` on all four sides, so the cap above holds
  under any padding. The padding at both ends of a strip also shortened the
  run the thumb travels along. Under a `Scaffold` the body keeps the top
  padding when there is no app bar, the bottom padding when there is no bottom
  bar or footer, and the left and right padding always, so a table in a real
  app is under a padding.
  **Maintainer's call** (2026-11-17): the thumbs ignore the padding on every
  platform, removed in the context Material's `Scrollbar` reads it from.
  **Derivation** (open to a better one): the iOS `RawScrollbar` path takes
  the same wrapper rather than `padding: EdgeInsets.zero`, so one mechanism
  covers both paths and one test exercises both. The wrapper also reaches the
  strip's `SingleChildScrollView`, which reads no `MediaQuery` padding
  (`widgets/single_child_scroll_view.dart`, Flutter 3.41.9). Not covered by
  the call: `MediaQuery` read anywhere else in the table. The body list's
  padding is #242, in [row rendering and geometry](row-render-geometry.md),
  which keeps a cell's `viewPadding` and so does not use `removePadding`.
  `test/scrollbar_thumb_theme_test.dart` pins the painted rect with and
  without padding per platform and axis.
- **The constraint is a floor.** `SyncedScrollControllers` builds on
  `ScrollbarController`, which 0.1.6 introduced. Below that, 0.1.0 declared
  Flutter `>=3.41.0`, the SDK it was built with, so a 3.32 user could not resolve
  it; and 0.1.1 dropped a notch, as closed below.

## Code

`widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`, `_AlignedScrollbarController`
`widgets/flutter_table_plus.dart` — `_handleHorizontalScrollbarSignal`, `_horizontalScrollbarPointers`, `_ScrollbarStripPhysics`, `_ScrollbarStripThumb`
`utils/no_cascade_guard.dart` — `NoCascadeGuard`, `resolveJump`, `reset`
`utils/clamped_scroll_delta.dart` — `clampedScrollDelta`
`test/smooth_wheel_scroll_test.dart` — per-frame alignment under `wheelMotion`
`test/scrollbar_thumb_drag_test.dart` — a thumb drag past either end, the iOS thumb fling, and the thumb and track on Android and iOS
`test/scrollbar_thumb_theme_test.dart` — the thumb painted from `TablePlusScrollbarTheme` on every platform, under a `ScrollbarTheme` too, capped to its room, and in the same place under a `MediaQuery` padding

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
→ [A decorated box hands its child less than it declares](../invariant/decoration-eats-the-child.md) — the scrollbar track's border insets the thumb's painter, and the thumb's cap reads that room (#237)
→ [A measurement is given what the paint resolves, never what the caller wrote](../invariant/measure-what-the-paint-resolves.md) — the thumb's cap reads the track border from the decoration's `padding`, which follows `strokeAlign`, not from the widths the caller wrote (#237)
→ [Widths and offsets are clamped on every path](../invariant/clamped-dimensions.md) — `clampedScrollDelta` and `NoCascadeGuard.resolveJump` are two of its sites
→ [`MediaQuery` padding is the screen's edge, not the table's](../invariant/media-padding-is-the-screens-edge.md) — both scrollbar thumbs were inset off their tracks by it (#238)
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — the single coordinate frame is on the register: break it and every drag coordinate is wrong by a constant offset nothing reports
→ [A literal test pointer id can be a held gesture's id](../invariant/test-pointer-ids.md) — the wheel helper builds its pointer with `tester.nextPointer`; two single-test literal ids and one pair pinned by hand beside a held scrollbar-thumb gesture stay

## Blast radius

→ [Drag selection](drag-selection.md) — its coordinates are viewport-local *because* the header is not an input surface; change who scrolls and the frame moves
→ [Scale / zoom](scale-zoom.md) — a scale change re-derives both offsets from the old ones, through this pair
→ [Column resizing](column-resize.md) — the resize drag auto-scrolls the same horizontal controller
→ [Column width resolution](column-width.md) — total content width is what there is to scroll; `stretchLastColumn` changes it
→ [Row render geometry](row-render-geometry.md) — `needsVerticalScroll`, decided here, is what `LastRowBorderBehavior.smart` reads

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

**Closed: a thumb thicker than its room painted outside the track** (#237).
Measured 2026-11-16, `thickness: 12` on the default 12 px track: the thumb
spanned -2 to 10 on Windows and iOS; Android, with no margin, fitted. The
entry that stood here said the default thickness reached it only once
`trackWidth` was under 6.67; that left out the track border. Measured
2026-11-17 on Flutter 3.41.9, in the track's coordinates: the default
thickness with `Border.all(width: 2)` spanned -0.4 to 8.0 off Android and
1.6 to 10 on Android, against a room of 2 to 10; `thickness: 10` with
`Border.all(width: 1)` spanned -1 to 9 and 1 to 11. The thumb is now capped
as the design model's #237 entry says.

**Closed: `MediaQuery` padding moved the thumbs off their tracks** (#238).
Measured 2026-11-17 on Flutter 3.41.9, thickness 6, a 400x300 table under a
padding of 20, 30, 40, 50 (left, top, right, bottom), in the painter's
coordinates: the horizontal thumb spanned -46 to -40 across on iOS and
Windows and -44 to -38 on Android, against 4 to 10 and 6 to 12 with no
padding, and ran from 20 to 121.4 along instead of 0 to 133.3; the vertical
thumb spanned -36 to -30 and -34 to -28, and started at 30 instead of 0. Both were painted wholly
outside the track. The thumb is now built as the design model's #238 entry
says.

**Closed: a `ScrollbarTheme` around the table restyled the strips, and on
iOS `TablePlusScrollbarTheme` did not reach them** (#235). Both were found
for #234. The thumb is now built as the design model's #235 entry says, by the
maintainer's call recorded there.

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
