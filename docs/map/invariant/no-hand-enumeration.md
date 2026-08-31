# Never hand-maintain a list a later addition must join

## The fact

**Two shapes, one failure.** A list of things, written by hand, that something
added later has to be added to — and nothing fails when it is not.

### Shape 1 — re-assembling an object

When a method produces a modified copy of a composite object, it must be built on
`copyWith` and name **only the fields it changes**. Reconstructing the object by
listing every field means a field added later is dropped by whoever forgets to
add a line — and nothing fails.

### Shape 2 — enumerating what a computation depends on

An invalidation condition lists the inputs a cached value is computed from. An
input added later is not added to the condition, and the cache silently serves a
stale answer.

**There is no `copyWith` here, and saying so is part of the invariant.** Dart
cannot enumerate the fields a computation reads, and folding the inputs into a
value type with an `==` only moves the hand-list into that operator — which is
Shape 1 again. What *is* achievable is reducing N lists to one: the failure that
actually occurred both times was **two conditions that disagreed**, not a single
condition that was incomplete.

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

→ [Theme system](../territory/theme-system.md) — ten sub-theme fields, one root, and the method where it was learned (shape 1)
→ [Scale / zoom](../territory/scale-zoom.md) — the caller of that method, and the only path on which the defect is observable (shape 1); and one of the three inputs a row height is computed from (shape 2)
→ [Row rendering and geometry](../territory/row-render-geometry.md) — two widgets caching row heights off two hand-written conditions (shape 2)
→ [Drag selection](../territory/drag-selection.md) — where shape 2's symptom is visible: the hit-test geometry answers from the cache
→ [Row identity and data binding](../territory/row-identity.md) — the other branch of the same two conditions, and where shape 2's second exit is recorded (#132)

## What a violation looks like

A field that silently reverts to its default in a derived copy. Specifically:
everything renders correctly at the default factor and wrong at any other, because
the identity path returns the receiver untouched and never exercises the
reconstruction.

Nothing throws, nothing logs, no test that uses the identity factor fails, and
the visual symptom appears in a component that was never edited.

**Shape 2 looks different and hides the same way.** A value that is correct on
screen and wrong wherever the *cached* copy is read. Rendering usually reads the
input live, so the rows are the right height and only the thing derived from the
cache — a hit test, a scroll decision — disagrees. Nothing throws there either,
and a test that pumps once can never see it: the stale path needs a **second**
build over the same data.

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
- **#120 / #128 (shape 2)** — `FlutterTablePlusState` and `TablePlusBodyState`
  both cache row heights, off two hand-written conditions. #120 found
  `calculateRowHeight` in the parent's list and not the body's: a new height
  function over the same list changed nothing on screen. #128 found
  `theme.rowHeight` in **neither**, one release later — measured 2026-08-31, rows
  drawn at 40px while a drag across four of them reported the two they covered at
  80px, and the parent's cached total leaving the vertical scrollbar undrawn.
  Affected 2.13.0–2.16.1 for the hit-test half, the whole 2.x line for the
  scrollbar half.

  **The interval is the finding.** #50 to #116 was six releases; #120 to #128 was
  one. The remedy is `rowMeasurementChanged` — one predicate, both callers — so
  the two can no longer disagree. Forgetting a genuinely new input is still
  possible and is now a one-site problem with the read sites named in the
  doc-comment.

  Two traps, both measured. The scale term is **redundant for the body and
  load-bearing for the parent**, because the parent hands the predicate an
  unscaled `theme.bodyTheme.rowHeight` while the body hands it one `scaledBy`
  has already scaled — so a mutation deleting that term survived until a test
  reached the parent's path alone. And the geometry snapshot is built **lazily on
  the first drag query**, so any test that does not drag before the change is
  green with or without the invalidation.
- **#132 (shape 2, and the exit that is not a longer list)** — the *structure*
  branch of the same two `didUpdateWidget` methods, one level up from the
  measurement branch #120 and #128 worked on. `rowId` is compared nowhere in the
  package; `mergedGroups` is compared by identity, so `groups[0] = newGroup` on
  the same list is invisible. Measured 2026-08-31 with a drag before the change:
  a swapped `rowId` over an unchanged list left the drag reporting `{0,1,2,3}`
  while the rows rendered — and the selection highlight tracked — `X0..X5`. The
  screen right, the callback wrong, which is #128's shape exactly.

  **The resolution was a contract, not another list entry — and the reason is
  ordering, not cost.** The first reason recorded here was that watching
  `rowId` is unaffordable, and that was wrong. It is right about the *obvious*
  guard: `rowId` is required, every call site writes an inline closure (all
  fifteen in this repo's example), an inline closure is a new object on every
  build even when it captures nothing, so `!identical(rowId)` fires for every
  caller on every build and rebuilds both lookups. Measured AOT, both widgets:
  0.08% of a 16.7ms frame at 100 rows, 0.70% at 1,000, **10.0%** at 10,000.

  **But there was a third option nobody costed: compare the answers.**
  `RowLookup` already stores the ids, so regenerating them through the current
  closure and comparing is complete rather than heuristic, and measured AOT
  costs 0.010% / 0.112% / **0.971%** at the same three sizes — about ten times
  less. It is not a new pattern here either: `utils/overflow_cache.dart` keys
  on the derived `(text, width)` pair and never compares the `measure`
  function it is handed. **The whole first analysis asked "compare the closure
  or not" and the answer was four files away in the same directory.**

  **It shipped in #135, and the order it shipped in is the finding.** Switched
  on alone it would have made things worse, not better: 412/412 green and the
  in-place `RangeError` gone, but on a merged-group table the rebuild it
  triggers ran a `computeRenderableIndices` that dropped a group whose first
  key was missing — a loud crash traded for a **silently missing row**, with
  which of the two you got depending on which member the caller removed. The
  derivation was fixed first and the guard second.

  **So a hand-list can have a mechanical fix that is unsafe to apply yet**, and
  the thing to record is not the fix but the sequence. #132 wrote the contract
  and said the guard was unaffordable, which was wrong; the corrected reason was
  that it was ordered behind something else, and that reason had an expiry date
  the first one did not.

  **Two qualifications on that figure, both found by the pass that checked
  it.** The amplifier is real for `FlutterTablePlusState`, whose
  `_rebuildCaches` re-runs `computeTableMetrics` and calls `calculateRowHeight`
  once per row *uncached*, and it is **not** real for the body, where a
  `rowId`-only branch would keep the index-keyed heights untouched because
  `rowId` does not move an index. And the rule this was generalised into —
  *required plus closure-typed* — is wider than the evidence: what was measured
  is how a caller **happens to write** the argument, not whether the parameter
  is optional. `playground_page.dart` passes an inline `calculateRowHeight`
  closure and pays the full cost on every build today; a required `rowId`
  passed as a top-level tear-off would be perfectly watchable.

  So shape 2 has a **second exit**: name the input as the caller's obligation
  and record why it is not watched. **The exit is real and the reason has to be
  the true one** — here it is that the guard is ready and the code beneath it
  is not, which is a statement with an expiry date, not a principle. Recording
  "unaffordable" would have closed the question permanently on a number that
  was measuring the wrong guard.

  Flutter states the new-list obligation four times over
  for lists and states none anywhere for a function — and, contrary to what
  this note first said, it does **not** always either compare a caller function
  or refuse to cache from it. `RawAutocomplete.optionsBuilder` is required, its
  result is cached in `_options`, `didUpdateWidget` compares only the
  controller and the focus node, and neither it nor `displayStringForOption` —
  a caller-supplied `T` to `String` extractor, the closest analogue to `rowId`
  in the SDK — is compared anywhere. So the precedent supports the contract
  more directly than the argument that was made for it, and the argument that
  was made for it is refutable in one grep.

  The check for the next one is a grep and the number is worth recording: of
  the **nineteen** function-typed parameters on the public widget, exactly
  **two** have cached results — `rowId` and `calculateRowHeight` — and the other
  seventeen are called live at build.

  **That number was first written as fifteen, and how it got there belongs in
  this note more than the number does.** It came from
  `grep -c "final .*Function.*;"`, which misses two declarations that wrap onto
  a second line (`onRowSecondaryTapDown`, `onMergedCellChanged`) and two whose
  types do not contain the token `Function` at all (`CellChangedCallback<T>?`,
  `ValueChanged<double>?`). So the guard against a hand-maintained list was
  itself a hand-run grep, reported as a census — #65's shape, inside the note
  that exists to catch it. **Count the declarations, not the lines that match a
  pattern**, and say which command produced the number so the next reader can
  find it wrong the same way.

## Where it will recur

**Shape 1: any method that returns a modified copy of a class with more than a
couple of optional fields**, and any test of such a method that uses the identity
argument. **Shape 2: any cache with a hand-written invalidation condition**, and
especially any pair of caches over the same inputs — the grep there is for a
second `didUpdateWidget` comparing some of the same fields.
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
