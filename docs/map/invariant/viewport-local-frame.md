# Viewport-local coordinates come from one frame

## The fact

Pointer coordinates used for hit-testing rows are **viewport-local on both axes**,
and they are viewport-local *by construction*: the `Listener` sits **outside** the
body's horizontal `Scrollable`, so `event.localPosition` already is what the
gesture code needs. There is no conversion step in the drag path, and therefore
nothing that can drift out of step with the scroll offset.

## Why it is cross-cutting

Two gestures and one correction path all need a viewport coordinate, and they do
not share code: the drag-selection path reads it from the pointer event, the
resize handle derives it from its own `RenderBox`, and the scale correction
re-derives both offsets from the previous ones. The shared assumption is the
*frame* — which axis is scrolled by whom — and it is stated nowhere in any of
their signatures.

**Two of the three satisfy this differently**, and that is the important part.
Four sites in total: three read `event.localPosition` inside the main widget, and
the resize handle converts through `localToGlobal` instead. A grep for the frame,
or for the pointer field, finds three and misses the fourth — which is
simultaneously the hardest site to rediscover and the easiest to misread as a
missing call and "fix" into a wrong one.

## Territories it holds in

→ [Drag selection](../territory/drag-selection.md) — the reason the invariant exists; the `Listener`'s placement is the mechanism
→ [Synced scrolling](../territory/synced-scrolling.md) — the frame only holds because the header is not an input surface
→ [Column resizing](../territory/column-resize.md) — the site that satisfies it the *other* way, by conversion and by argument
→ [Example app](../territory/example-app.md) — where a host transform was believed to break the frame, and where the measurement that says otherwise lives

## What a violation looks like

Selection that is correct at horizontal offset zero and wrong once the table is
scrolled sideways — off by exactly the scroll offset. Or a rubber band that
tracks the pointer vertically but lags horizontally.

It reproduces only when the horizontal scroll is non-zero, which is why it
survives a manual check on a table narrow enough to fit.

## Discovery history

**Recorded as a design decision rather than a bug.** `CLAUDE.md` states the frame
as an identity invariant, and the drag-selection controller was built around it
from the start — the `Listener`'s position outside the horizontal `Scrollable` is
deliberate and load-bearing, not incidental.

The evidence that it needs to be a node rather than a line in one territory is
the *site census*: three sites express it one way, one expresses it another, and
the odd one out lives in a different territory from the other three.

## Where it will recur

**Any new pointer-driven feature that maps a position to a row or a column** —
a context menu, a drag-to-reorder rows, a marquee over cells, a
touch-and-hold. The test to run first: *where does this coordinate come from, and
is the widget that produced it inside or outside the horizontal `Scrollable`?*

**And the inverse question, which has already been answered wrong once.** A host
that puts a `Transform` or a `FittedBox` *above* the table does **not** move this
frame: `Transform` applies the inverse during hit testing, so
`event.localPosition` reaches the gesture code already in the child's own
untransformed space, and a drag inside a frame drawn at roughly half size selects
exactly the rows it crosses. #101 recorded the opposite — that a scaled host put
the frame in question — and made it the reason a viewport preview must never
scale. The evidence was a test whose own arithmetic mixed scaled screen
coordinates with unscaled logical ones; `getRect` is screen space, `getSize` is
layout space, and inside a `FittedBox` the child still lays out at full size. The
example's fit mode is interactive because the correction holds.

The reason this is here rather than in one file's comment: at the time of
writing, the correction is stated in **six** example sources and in no note, so
each new site has had to re-derive it. **Pick one space and stay in it, and
measure rather than reason** — the wrong answer here survived review by sounding
careful.
