# A scale of 1.0 hides every missing conversion

## The fact

At `scale: 1.0` logical pixels and rendered pixels are **the same numbers**, and
`scaledBy(1.0)` returns its receiver untouched. So every defect in the scaling
path — a value never converted, a field never copied, a bound compared in the
wrong space — produces a correct result at the one factor everything is written
and tested at.

**A test at `scale: 1.0` cannot observe a scaling defect.** Not "is unlikely to":
the two candidate implementations agree on every input, so no assertion can
separate them.

## Why it is cross-cutting

The factor is applied in one place and consumed everywhere. `FlutterTablePlus`
resolves widths in logical space and multiplies the result; the theme system
re-derives a whole tree through `scaledBy`; the resize handle drags in rendered
pixels and reports logical ones; auto-fit measures in rendered space against
converted bounds. **None of those sites knows the others exist**, and each one
crosses the same boundary independently — which is why the shared blind spot is
the *fixture*, not any one call path.

It has produced two defects by two unrelated mechanisms, which is the signal
this note is recorded on:

- **A field was never copied** (#50) — `scaledBy` hand-listed sub-themes and
  dropped `rowTooltipTheme`. Every theme test ran at 1.0, where `scaledBy`
  returns the receiver and the dropped field is present.
- **A bound was never converted** (#114) — the drag accumulated rendered pixels
  and clamped them against logical `minWidth` / `maxWidth`. All three
  drag-to-resize tests ran at 1.0, where the two spaces coincide, and all three
  asserted the right number.

## Territories it holds in

→ [Scale / zoom](../territory/scale-zoom.md) — where the factor enters, and the only territory whose tests are *obliged* to leave 1.0
→ [Theme system](../territory/theme-system.md) — `scaledBy` is the mechanism, and its 1.0 short-circuit is the concrete hiding place
→ [Column resizing](../territory/column-resize.md) — the drag crosses the boundary three times, once per phase, from one pair of inputs
→ [Column width resolution](../territory/column-width.md) — widths are resolved logical and multiplied out, so every bound it applies is a crossing
→ [Example app](../territory/example-app.md) — the zoom and resizing recipes are the only place a reader can move the factor at all

## What a violation looks like

A green suite and a consumer report. The tell is always the same shape: the
behaviour is correct in every test and wrong for one user, and the user's only
distinguishing setting is a zoom level.

Two more specific tells, both cheap to check:

- **A conversion that appears on one path into a shared function and not the
  other.** `_handleColumnAutoFit` converts its bounds; the drag path did not, and
  they meet in the same `clamp`. One converted operand beside one unconverted one
  is the defect, not a style difference.
- **A test file that never names `scale`.** Coverage of a scaling-sensitive
  behaviour with no factor other than the default is coverage of the case where
  the bug is invisible.

## Discovery history

- **#50** — `scaledBy()` dropped `rowTooltipTheme`, silently reverting row
  tooltip style at non-1.0 scale. The fix rebuilt `scaledBy` on `copyWith` so a
  field cannot be forgotten; see
  [Never re-assemble by hand-listing fields](no-hand-enumeration.md). What that
  note does not carry is *why the tests missed it*, which is this.
- **#114** — the resize drag's bounds were compared in scaled space against
  logical `minWidth` / `maxWidth`. Measured 2026-08-26: a column declaring
  `maxWidth: 300` at `scale: 2.0` reported **150** and could not grow past it;
  `minWidth: 80` reported **40**. Turning the fix off leaves the three existing
  drag tests green, because all three run at 1.0.

Two rediscoveries by two mechanisms, recorded on the second — the same bar
[the square test font](test-font-square.md) was recorded on.

## Where it will recur

**Any value that crosses between logical and rendered space, and any test that
exercises one.** Concretely: a new theme field (does `scaledBy` carry it?), a new
dimension a caller declares (is it converted before it meets a rendered one?), and
any new geometry the handle or the resolver produces.

The operational form is a rule about tests, not about code: **when a behaviour
depends on the factor, at least one assertion runs at a factor that is not 1.0.**
A suite that only ever pumps the default has not tested the feature; it has
tested the case where both implementations agree.
