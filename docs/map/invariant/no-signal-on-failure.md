# A defect in these files produces no signal

## The fact

Most of this package fails loudly: a wrong column width throws, a bad index
crashes, a broken build reddens the suite. **A short list of files does not.** A
defect in one of them renders, passes every gate, ships, and is found by a
consumer weeks later — because the wrong answer is still a *valid* answer, and
nothing in the type system, the analyzer or the test suite can tell it from the
right one.

The consequence is procedural, not architectural: **a diff touching one of these
files is not finished when the gates are green.** Green is the expected outcome
either way, so it carries no information here. The change needs an adversarial
read — a second pass that hunts for the wrong-but-valid answer — before it is
called done.

The list is below. It is a **register of measured incidents**, never a
derivation: each row is here because something in it shipped broken, and the
right-hand column is the measurement, not a guess at risk.

| Path | Why it costs more than a wrong number |
|---|---|
| `lib/src/models/theme/**` | a field can be dropped **silently** — no test breaks, and `scaledBy(1.0)` hides it (#50, #116) |
| `lib/src/widgets/drag_selection_controller.dart` | the auto-scroll `Timer` and the gesture state machine — a leak keeps scrolling in the consumer's app |
| `lib/src/widgets/row_locator.dart` | the port both sides of drag-select agree on |
| `lib/src/widgets/synced_scroll_controllers.dart` | the single-coordinate-frame invariant; break it and every drag coordinate is wrong by an offset |
| `lib/src/widgets/flutter_table_plus.dart` | where edit commits and selection callbacks cross into the **consumer's data** |
| `lib/src/widgets/row_geometry.dart` | drag-select hit-testing reads row geometry, and #128 records that it has **never** been exercised against changing row heights |
| `lib/src/widgets/table_body.dart` | it caches measured row heights; #120 shipped stale ones when `calculateRowHeight` changed identity |
| `lib/src/widgets/table_plus_merged_row.dart` | it owns the height distribution — each member's extent, and which cell absorbs the group's bottom border. #121 shipped every measured height computed and discarded, through 2.16.1 |
| `lib/src/utils/table_row_height_calculator.dart` | a **public API** (exported from the barrel) that every row's geometry is derived from |
| `lib/src/utils/row_measurement.dart` | the **one** list both height caches consult. It is a hand-maintained enumeration Dart cannot derive, so a forgotten fourth input stales the `RowGeometry` every drag hit-test reads *and* the total that decides whether a scrollbar appears — the #120/#128 failure with the two lists collapsed into one site. #137 then measured its `identical` guard wrong, and wrong **differently in JIT and AOT** |
| `lib/src/utils/row_cache_invalidation.dart` | the **response** half of the same rule `row_measurement.dart` holds the inputs for: which caches an update invalidates, for both widgets that hold any. Unifying the predicate and leaving each caller to decide what to drop was half a repair and the halves drifted — the body split structural from measurement-only and the parent did not, so a `scale` change rebuilt a `RowLookup` no scale can move, and the asymmetry survived #120, #128, #132 and #135 (#169). `structural` must dominate `measurementOnly` or a list sorted in place is reported as a height change |
| `pubspec.yaml` | a false floor breaks users' trees while `pub get` still succeeds here (#69); a dep's floor rise is BREAKING for us even with `lib/` untouched (2.16.0) |
| `CHANGELOG.md` | pub.dev snapshots at publish — a published entry edited in place splits the repo from the registry (2.15.0) |
| `.pubignore` | it decides the archive's contents, and the archive **cannot be un-published** |
| `lib/src/widgets/cells/table_plus_cell.dart` | #155 routed the merged row's members through it, so one defect here lands on **every plain row and every group member** at once. #156 already records two live ones in it: the overflow width ignores the divider's own inset, and the detector never reads `MediaQuery.textScaler` |
| `lib/src/utils/text_overflow_detector.dart` | all **three** overflow call sites go through it — the ordinary cell, the header cell, and the merged row's spanning cell — so a defect here is three at once. #156 found four, every one silent, and the largest was named by neither the ticket nor the first adversarial pass. A diff that changes only this file touches no other path on this list, which is how those four reached release |
| `lib/src/widgets/table_header.dart` | a caller's `headerTheme.decoration` is applied to the box wrapping the whole header, and the body has no equivalent box. One border slid every header column against its body column — measured 2.0px, no exception, no banner — and what it broke is the alignment `CLAUDE.md` names as core (#160) |

**Absent a hit on this list, the risk is enumeration rather than silence**: many
edges, domain semantics, cross-feature interaction. The tell is a reactive spike
that keeps catching *new* gaps one probe at a time — that is the signal the
enumeration is incomplete, not that the list above is wrong.

## Why it is cross-cutting

The entries sit in six directories and ten territories, and **they do not call
each other**. What they share is not a call path but a failure *grade*: the wrong
answer type-checks, renders, and satisfies every assertion anyone thought to
write.

**It is not derivable from the code, in either direction.** Nothing marks these
files, and nothing about their size, complexity or churn predicts membership —
`row_locator.dart` is a handful of lines and `table_header.dart` is ordinary
widget code. Membership comes from history: something shipped broken out of it
and nobody noticed until a consumer did.

**So the list only grows by incident, and it used to grow in two files at once.**
It was kept twice — once as prose and once as a shell script's pattern array —
with a generated check asserting the two against each other. Both copies are gone
and this note is the single site. What replaces that check is the property that
made it possible in the first place: **every row names the measurement that put
it there**, so a row nobody can trace to an incident is a row to challenge.

## Territories it holds in

→ [Theme system](../territory/theme-system.md) — the sub-theme field set, where a dropped field is invisible at the factor everyone tests with (#50, #116)
→ [Drag selection](../territory/drag-selection.md) — the gesture state machine, the auto-scroll `Timer`, and the port both sides agree on: a leak here keeps scrolling inside the consumer's app
→ [Synced scrolling](../territory/synced-scrolling.md) — the single coordinate frame; break it and every drag coordinate is wrong by a constant offset that nothing reports
→ [Row rendering and geometry](../territory/row-render-geometry.md) — the cached geometry a hit test answers from, never exercised against changing row heights (#128)
→ [Row height](../territory/row-height.md) — four of the entries, and the pair (`row_measurement.dart`, `row_cache_invalidation.dart`) whose halves drifted for four issues (#120, #128, #169)
→ [Merged rows](../territory/merged-rows.md) — the height distribution and which cell absorbs the group's border; every measured height was computed and discarded through 2.16.1 (#121)
→ [Text overflow detection](../territory/text-overflow.md) — the two files every overflow decision funnels through, where #156 found four silent defects at once
→ [Cell editing](../territory/cell-editing.md) — where an edit commit crosses into the consumer's own data, which this package does not own and cannot validate
→ [Public barrel and re-exports](../territory/public-barrel.md) — `table_row_height_calculator.dart` is exported, so a change to it is a change to the published API whether or not it looks like one
→ [Publishing and release](../territory/publishing.md) — the three release-surface entries, and the only ones whose failure cannot be repaired by a later commit

## What a violation looks like

**It looks like nothing.** That is the entire content of the invariant, and every
concrete symptom is a variation on it:

- The suite is green, the analyzer is clean, the app renders, and the number is
  wrong. Measured: rows drawn at 40px while a drag across four of them reported
  two (#128); the header offset from the body by exactly 2.0px (#160); every
  member of a merged group drawn at the group's mean instead of its own measured
  height (#121).
- The defect is **visible only on a second build** over the same data, so any
  test that pumps once cannot see it (#120, #128).
- The defect is visible only at a non-default parameter, so the value everyone
  tests with is the one value that hides it — `scaledBy(1.0)` returns the
  receiver (#50).
- For the three release-surface entries, the violation is not observable in this
  repository at all: `pub get` succeeds here and breaks in the consumer's tree
  (#69), and a published archive cannot be un-published.

The procedural violation is separate and easier to spot: **a change touching one
of these files, merged on green gates alone.** Green was never evidence here.

## Discovery history

- **#50 → #116** — a dropped theme field, six releases apart, at two levels of
  the same object. Neither reddened anything.
- **#69 / 2.16.0** — a dependency floor that was honest about the SDK it was
  built with and dishonest about the SDK its code needed. `pub get` succeeded in
  this repository throughout.
- **#120 → #128 → #132 → #135 → #169** — two hand-written invalidation
  conditions that disagreed, unified into one predicate, and the *response* to
  that predicate left copied in two widgets, which then drifted the same way.
  Five issues, one root, and each one green before it shipped.
- **#121** — every member height computed, threaded through the widget, and
  discarded by an `Expanded`. Shipped through 2.16.1. The test that should have
  caught it used a `closeTo(±1.0)` tolerance, and `1.0` was the exact magnitude
  of the error: **the suite was calibrated to hide the defect it existed to
  catch.**
- **#156** — four silent defects in the overflow path at once, the largest named
  by neither the ticket nor the first adversarial pass. It is also the row that
  explains the register's shape: a diff changing only
  `text_overflow_detector.dart` touches nothing else on this list, and that is
  how four defects reached a release together.
- **#160** — a caller's header decoration wrapping the whole header, with no
  equivalent box on the body. 2.0px, no exception, no banner, and what it broke
  is the alignment `CLAUDE.md` names as core.
- **2026-09-04** — `row_cache_invalidation.dart` added by hand, because #169 had
  moved half of `row_measurement.dart`'s rule into it and the register still
  pointed at one half. **A register entry can go stale by the code moving
  underneath it**, and nothing signals that either.

## Where it will recur

**The shape to watch for is a wrong answer that is still a well-typed answer.**
Concretely, a new file joins this list when it acquires any of:

- **a cache with a hand-written invalidation condition** — see
  [never hand-maintain a list](no-hand-enumeration.md); the stale answer is
  always well-typed
- **a measurement whose consumer is geometry rather than paint** — the screen
  looks right and the derived number is wrong; see
  [a measurement is given what the paint resolves](measure-what-the-paint-resolves.md)
- **a value crossing into the consumer's own data**, which this package does not
  own and therefore cannot validate
- **anything on the release surface**, where the failure is unobservable here by
  construction

**The register is not a substitute for reading.** A file being absent from it
means nobody has been burned there yet, which is a statement about this
repository's history and not about the file. The entries added most recently —
`table_plus_cell.dart`, `text_overflow_detector.dart`, `table_header.dart`,
`row_cache_invalidation.dart` — were all absent right up until the incident that
added them.
