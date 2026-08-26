# Widths and offsets are clamped on every path

## The fact

Every column width is bounded into `[minWidth, maxWidth]` and every scroll offset
is bounded into the range of the controller it is applied to — **on every path
that produces one**, not only on the paths a user is expected to reach.

## Why it is cross-cutting

A dimension produced in one place is applied in another. Width resolution
produces widths that the resize handle later re-produces, that scaling
re-produces again, and that the header and body both consume; offsets are
produced by the drag auto-scroller, the resize auto-scroller, the scale
correction and the scrollbar, and applied to two controllers with different
extents.

**The sites do not call each other.** `clampedScrollDelta`,
`NoCascadeGuard.resolveJump`, the resize handle's three drag phases and the
resolver's five branches are independent implementations of the same rule — which
is why no territory-to-territory edge could carry it, and why a note inside any
one territory would be invisible from the other six files.

Census at the time of writing: **18 clamp sites across 7 files.**

## Territories it holds in

→ [Column width resolution](../territory/column-width.md) — five sites: declared, resized, stretched and two auto-fit branches
→ [Column resizing](../territory/column-resize.md) — three sites, one per drag phase
→ [Synced scrolling](../territory/synced-scrolling.md) — the slave's range is not the master's, so every mirrored offset is bounded before it is applied
→ [Drag selection](../territory/drag-selection.md) — the auto-scroller bounds its proximity ratio before turning it into a velocity
→ [Scale / zoom](../territory/scale-zoom.md) — both offsets are re-derived across a scale change and bounded into the new extents

## What a violation looks like

A column draggable to zero width or past the viewport edge; a `jumpTo` that
throws or silently snaps because the target is outside the new extent; a scaled
width that ignores its own `maxWidth` at a large factor. The tell is that it
only shows at the extremes — the middle of the range behaves correctly, so a
manual check passes and the defect waits for a user with a narrow window or a
long column.

**A clamp that exists is not a clamp that holds.** #114 is the measured case: all
three of the resize handle's sites were present and none was reachable at its
declared bound, because the bound and the value were in different spaces. Count
the clamps to find a missing one; check the *operands* to find a wrong one.

## Discovery history

**Thin, and honestly so.** No single incident produced this rule; it is the
shape seven files converged on independently, and `CLAUDE.md` elevates it to an
invariant on that basis ("`minWidth`/`maxWidth` `clamp()` in every layout path").
Seven independent arrivals at the same rule is the same signal a rediscovery is,
recorded before rather than after the bug.

It has since gained one measured failure of its own: **#114**, where three of the
eighteen sites clamped against operands from the wrong space, so the rule was
satisfied by inspection and violated in fact.

The related failure is the *inverse* one: `scaledBy(1.0)` returning the receiver
meant a whole class of scale-path defects was invisible at the factor everyone
tests with (#50) — a reminder that the extremes are where this rule is
observable at all. Both are now
[one note](scale-one-hides-it.md).

## Where it will recur

**If a function returns a width or a scroll offset, it is subject to this.** In
particular: any new width source (a per-row width, a content-driven width, a
persisted width restored from disk), and any new place that applies an offset to
a controller it did not itself compute.
