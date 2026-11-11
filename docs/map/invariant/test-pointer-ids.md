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
a scrollbar thumb drag meets a notch. Those tests sit in three territories and
three test files, and none of them knows the counter is shared.

## Territories it holds in

→ [Drag selection](../territory/drag-selection.md) — the 'a scroll under a held drag' group in `test/drag_selection_test.dart` holds a drag and sends a wheel; its helper is where the collision was measured
→ [Synced scrolling](../territory/synced-scrolling.md) — `test/smooth_wheel_scroll_test.dart` sends wheel and trackpad events through literal ids, one of them beside a held scrollbar-thumb gesture
→ [Scale / zoom](../territory/scale-zoom.md) — `test/scale_zoom_test.dart` builds every Ctrl+wheel pointer with a literal id

## What a violation looks like

A test fails with the `_hitTests.containsKey` assertion from inside
`sendEventToBinding`, while the code under test is untouched. Typically it fails
only under `--plain-name`, or only after an unrelated test was added earlier in
the file.

The tempting repair is to pick a different literal until the run goes green.
That moves the collision to another run order and leaves it there.

Literal ids standing as of #227, none of them failing today. Whether each one is
sent while a gesture is held was not measured site by site:

- `test/scale_zoom_test.dart` — six `TestPointer(1, PointerDeviceKind.mouse)`,
  one in the file's Ctrl+wheel helper and five inside individual tests.
- `test/smooth_wheel_scroll_test.dart` — four: three `TestPointer(1, …)` (two
  mice and a trackpad) and one `TestPointer(2, …)`, which #225 placed beside a
  `startGesture` that was pinned to `pointer: 1` for this reason.

## Discovery history

- **#225** — a Shift+wheel test over the horizontal scrollbar collided with the
  id `startGesture` had handed out. The fix pinned both ids by hand,
  `startGesture(pointer: 1)` and `TestPointer(2, …)`.
- **#227** — the 'a scroll under a held drag' group's wheel helper used
  `TestPointer(9, …)`. On main, running the group alone failed 'rows shrinking
  under it throw nothing' with the assertion above, while the whole file passed.
  Adding one more test to the group moved the failure to 'before the drag is
  live, nothing is emitted'. The helper now uses `tester.nextPointer`.

## Where it will recur

**Any new test that builds a `TestPointer` by hand** for a wheel, hover,
trackpad pan-zoom or modifier gesture. It recurs especially in a file that also
calls `startGesture`, and in a helper shared by many tests, where one id is
reused under every run order. Build the id with `tester.nextPointer`, or pin
every id in the test by hand as #225 did, never one side only.
