# A literal test pointer id can be a held gesture's id

## The fact

`tester.startGesture` and `tester.createGesture` take their pointer id from
flutter_test's `WidgetController._nextPointer`. That counter is **`static`**,
starts at 1, only goes up, and is **never reset between tests**. In Flutter
3.47.1 it is `WidgetController.nextPointer` / `_nextPointer` / `_getNextPointer`
in `packages/flutter_test/lib/src/controller.dart`, lines 1835–1843.

A test that builds a `TestPointer` with a literal id, such as
`TestPointer(9, PointerDeviceKind.mouse)`, therefore shares the id space with
every gesture started earlier in the same file. When the literal equals the id
of a gesture that is **still down**, the next event on it trips
`GestureBinding`'s `'!_hitTests.containsKey(event.pointer)'` assertion:
*"Pointer of PointerHoverEvent … unexpectedly has a HitTestResult associated
with it."*

Which test gets which id depends on **how many gestures ran before it**. So the
same file can pass as a whole and fail when filtered, or start failing because a
test was added above it.

`tester.nextPointer` reads the counter without advancing it. It returns an id no
gesture has been given yet, so a `TestPointer` built with it cannot match a held
gesture. Hover and scroll events register no hit test, so a later
`startGesture` that receives the same id does not collide with it either.

## Why it is cross-cutting

Any test that sends a wheel, hover or trackpad event through a hand-built
`TestPointer` while a gesture from `startGesture` may be held is exposed. That is
how a held drag meets a wheel, how a zoom gesture meets a modifier-wheel, and how
a scrollbar thumb drag meets a notch. Those tests sit in four territories and
four test files. One of them is in `example/test/`, which runs under its own
`flutter test` on the same flutter_test counter. None of them knows the counter
is shared.

## Territories it holds in

→ [Drag selection](../territory/drag-selection.md) — the 'a scroll under a held drag' group in `test/drag_selection_test.dart` holds a drag and sends a wheel; its helper is where the collision was measured
→ [Synced scrolling](../territory/synced-scrolling.md) — `test/smooth_wheel_scroll_test.dart` sends wheel and trackpad events through hand-built `TestPointer`s, one of them beside a held scrollbar-thumb gesture
→ [Scale / zoom](../territory/scale-zoom.md) — `test/scale_zoom_test.dart` sends every Ctrl+wheel through a hand-built `TestPointer`
→ [Example app](../territory/example-app.md) — `example/test/recipes_b_test.dart` sends its zoom recipe's Ctrl+wheel through a hand-built `TestPointer`, in a file that also calls `startGesture`

## What a violation looks like

A test fails with the `_hitTests.containsKey` assertion from inside
`sendEventToBinding`, while the code under test is untouched. Typically it fails
only under `--plain-name`, or only after an unrelated test was added earlier in
the file.

The tempting repair is to pick a different literal until the run goes green.
That moves the collision to another run order and leaves it there.

Hand-built ids standing as of #229, read site by site. A collision needs,
inside one test, a gesture still down whose id equals the id of a hover,
scroll, down or pan-zoom start event sent meanwhile: `GestureBinding` stores a hit test only
for a down or a pan-zoom start and drops it on up, cancel or pan-zoom
end, so only the counter's value crosses from one test to the next.

- **Every shared helper now uses `tester.nextPointer`.** Five helpers built
  `TestPointer(1, …)`: `_wheel` in `test/smooth_wheel_scroll_test.dart`;
  `_ctrlWheel` in `test/scale_zoom_test.dart`, and in the same file the
  group-local `wheel` in 'the offsets across a scale change' and
  `ctrlWheelAt` in 'blockModifierScroll'; and `_ctrlWheel` in
  `example/test/recipes_b_test.dart`, used by four tests in a file that also
  calls `startGesture`. A helper is the exposure because a test written later
  can call it while holding a gesture: in a filtered run the first
  `startGesture` receives id 1, and the helper's next event would fail with
  the assertion above. No test does so today. The probe: a test that pumps the
  table, expects `tester.nextPointer` to be 1, holds
  `tester.startGesture(const Offset(1, 1))`, calls the helper and releases,
  run alone with `--plain-name`. It failed with the literal id and passed with
  `tester.nextPointer` for `_wheel`, the scale-zoom `_ctrlWheel` and the
  example `_ctrlWheel`; `wheel` and `ctrlWheelAt` were changed on the same
  reading without a probe of their own. It was not kept: its `nextPointer`
  guard holds only when it runs first.
- **`test/scale_zoom_test.dart` — three literal `TestPointer(1, …)` inside
  single tests stay.** The file calls no `startGesture`, `createGesture`, drag
  or tap, so no gesture is ever down when they are sent.
- **`test/smooth_wheel_scroll_test.dart` — two literal `TestPointer(1, …)`
  inside single tests stay**, the tilt wheel over the horizontal scrollbar and
  the trackpad scroll with the modifier. Neither test presses a gesture. Every
  test in the file that does press one sends its wheel before the press or
  after the release, except the next one.
- **The #225 pair stays**: 'during a thumb drag moves nothing and the drag
  still leads when the wheel …', one test per wheel motion, holds
  `startGesture(pointer: 1)` and wheels through `TestPointer(2, …)`. Both
  ids are pinned by hand, so the run order cannot move either.

## Discovery history

- **#225** — a Shift+wheel test over the horizontal scrollbar collided with the
  id `startGesture` had handed out. The fix pinned both ids by hand,
  `startGesture(pointer: 1)` and `TestPointer(2, …)`.
- **#227** — the 'a scroll under a held drag' group's wheel helper used
  `TestPointer(9, …)`. On main, running the group alone failed 'rows shrinking
  under it throw nothing' with the assertion above, while the whole file passed.
  Adding one more test to the group moved the failure to 'before the drag is
  live, nothing is emitted'. The helper now uses `tester.nextPointer`.
- **#229** — the same hazard in the shared wheel helpers of
  `test/smooth_wheel_scroll_test.dart` and `test/scale_zoom_test.dart`, latent:
  no test called them under a held gesture. A probe that held the run's first
  gesture and called each helper failed under `--plain-name`. Both helpers now
  use `tester.nextPointer`. A second change gave the same id to the two
  group-local helpers in `test/scale_zoom_test.dart` and to `_ctrlWheel` in
  `example/test/recipes_b_test.dart`. The single-test literals were read site
  by site and left.

## Where it will recur

**Any new test that builds a `TestPointer` by hand** for a wheel, hover,
trackpad pan-zoom or modifier gesture. It recurs especially in a file that also
calls `startGesture`, and in a helper shared by many tests, where one id is
reused under every run order. Build the id with `tester.nextPointer`, or pin
every id in the test by hand as #225 did, never one side only.
