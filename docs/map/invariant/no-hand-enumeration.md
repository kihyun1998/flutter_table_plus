# Never re-assemble an object by hand-listing its fields

## The fact

When a method produces a modified copy of a composite object, it must be built on
`copyWith` and name **only the fields it changes**. Reconstructing the object by
listing every field means a field added later is dropped by whoever forgets to
add a line — and nothing fails.

## Why it is cross-cutting

It holds wherever a composite is rebuilt, and those places do not call each
other: the root theme's `scaledBy` rebuilds nine sub-themes, each sub-theme's own
`scaledBy` rebuilds its fields, and any future "reset", "merge" or
"interpolate" helper would face the same choice. What they share is not a call
path but a *shape* — a class with many optional fields and a method that returns
a modified copy.

## Territories it holds in

→ [Theme system](../territory/theme-system.md) — nine sub-themes, one root, and the method where it was learned
→ [Scale / zoom](../territory/scale-zoom.md) — the caller of that method, and the only path on which the defect is observable

## What a violation looks like

A field that silently reverts to its default in a derived copy. Specifically:
everything renders correctly at the default factor and wrong at any other, because
the identity path returns the receiver untouched and never exercises the
reconstruction.

Nothing throws, nothing logs, no test that uses the identity factor fails, and
the visual symptom appears in a component that was never edited.

## Discovery history

- **#50** — `TablePlusTheme.scaledBy()` rebuilt the theme field by field and did
  not carry `rowTooltipTheme`. At any `scale` other than `1.0` it went `null`, the
  documented fallback handed the row tooltip to `tooltipTheme`, and a card styled
  for its own surface — transparent, unpadded — came back wearing the grey text
  tooltip's styling. **`scaledBy(1.0)` returns the receiver untouched**, so the
  default factor never fired it.
  The fix was not a test but the removal of the cliff: `scaledBy` now names only
  the six sub-themes it scales and leans on `copyWith` for the rest, so a field
  added later **cannot** be dropped by forgetting to list it.
- **#50 / #52 (the proof, not the defect)** — the first guard written for it
  passed with the fix removed: *"leaves an unset tooltip theme unset"* is true
  either way. The regression is caught by the *"carries … through untouched"*
  assertion. A semantic guard is not a regression guard.

## Where it will recur

**Any method that returns a modified copy of a class with more than a couple of
optional fields**, and any test of such a method that uses the identity argument.
The check is mechanical: if the method body names a field it does not change, it
is a candidate.
