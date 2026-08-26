# Never re-assemble an object by hand-listing its fields

## The fact

When a method produces a modified copy of a composite object, it must be built on
`copyWith` and name **only the fields it changes**. Reconstructing the object by
listing every field means a field added later is dropped by whoever forgets to
add a line — and nothing fails.

## Why it is cross-cutting

It holds wherever a composite is rebuilt, and those places do not call each
other: the root theme's `scaledBy` rebuilds ten sub-theme fields, each sub-theme's own
`scaledBy` rebuilds its fields, and any future "reset", "merge" or
"interpolate" helper would face the same choice. What they share is not a call
path but a *shape* — a class with many optional fields and a method that returns
a modified copy.

**Fixing one level does not fix the others.** #50 rebuilt the root on `copyWith`
and the sub-themes kept hand-listing for six more releases (#116). The levels
look like one rule because they share a method name; they are separate sites and
the rule has to be applied at each.

**The sharpest case is a type you do not own.** `TablePlusCheckboxTheme.scaledBy`
re-assembled `flutter_checkbox`'s `CheckboxStyle`, whose field set grows when
*that* package ships. A hand-list against your own class is stale when someone
edits the class; a hand-list against someone else's is stale after a `pub get`,
with no commit in this repository to point at.

**An additive change upstream is a subtractive change to your hand-list**, and
the two are easy to confuse because only one of them appears in a diff. The
measured case is exact: `flutter_checkbox` 0.2.0 and 0.2.1 declared precisely the
17 fields the list named, so the list was *complete* for six releases. 0.3.0
added five, and this repository's changelog described that release as **"purely
additive over the surface this package uses"** while naming both
`CheckboxStyle.copyWith` and `CheckboxStyle.checkScale` in the same sentence —
the remedy and the defect, neither recognised. The upgrade note was true about
the API and false about the behaviour.

## Territories it holds in

→ [Theme system](../territory/theme-system.md) — ten sub-theme fields, one root, and the method where it was learned
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

  Worth being precise about what hid #50, because the obvious answer is wrong:
  measured at `60c2a58^`, `theme_scaling_test.dart` already made **eight**
  assertions at factors of 2.0 and 3.0 and named `rowTooltipTheme` in **none**.
  The suite had left 1.0 long before. What was missing was an assertion that
  named the field.
- **#116** — `TablePlusCheckboxTheme.scaledBy` hand-listed 17 of `CheckboxStyle`'s
  22 fields at the pinned `flutter_checkbox 0.3.1`. Measured 2026-08-26 at factor
  2.0: `checkScale` 0.42 → 1.0, `hoverColor` / `focusColor` / `splashColor` →
  null, `disabledOpacity` 0.17 → 0.4. Live in 2.16.1, reachable the moment a
  consumer sets a zoom. `TablePlusHeaderTheme.scaledBy` did the same to
  `TablePlusResizeHandleTheme` and dropped nothing — all five fields happened to
  be listed — which is what "armed" looks like as opposed to "sprung".

## Where it will recur

**Any method that returns a modified copy of a class with more than a couple of
optional fields**, and any test of such a method that uses the identity argument.
The check is mechanical, and it is a grep: **a constructor call inside such a
method body is the tell.** Run it over the family rather than the one site you
arrived at — at the time of writing, that grep over `lib/src/models/theme/*.dart`
returns exactly two, and both were defects of this shape.

**Run it over the family, and record the number.** At the time of writing it
returns **zero** — both sites are fixed. It returned two before #116, and a note
still saying two reads as though the fix never landed.

**The grep does not see the shape one level out.** It looks for a constructor
call inside a `scaledBy` body; the *outer* `TablePlusCheckboxTheme.scaledBy`
re-assembling its own class is the same defect and matches the same pattern —
but a fixture whose outer fields are all defaults cannot observe it. Measured
2026-08-26: that mutation passed 401 tests, inside the change that fixed the
inner one.

**And no value assertion catches the next field a sibling adds.** Neither type
implements `==` or `toString`, and Flutter has no reflection. Reading the
resolved package does work: `test/checkbox_style_field_set_test.dart` pins
`CheckboxStyle`'s field set through `.dart_tool/package_config.json`, green at
0.3.1 and red at 0.3.2 naming `shadows`. That is a **tripwire, not a guard** —
`copyWith` is the guard, and the tripwire only says go look.
