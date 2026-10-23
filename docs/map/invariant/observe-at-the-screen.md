# Observe at the screen, assert by count

## The fact

A widget test observes what a user could see — an icon, a rendered string in a
known place, a count of controls — not the implementation that produced it. And
where a set of things is being asserted, it asserts **how many**, not **which
names**.

`find.byIcon(Icons.expand_more)` survives a widget swap. `find.byType(ExpansionTile)`
does not.

## Why it is cross-cutting

Every widget test in the package and in the example app makes this choice, and
the tests do not share code — each one picks its finders independently. What they
share is a purpose: to keep passing across a refactor that does not change
behaviour, and to fail when behaviour does change. Where the observation point
sits decides both, and it is chosen one test at a time.

## Territories it holds in

→ [Example app](../territory/example-app.md) — where all three measurements were taken
→ [Row rendering and geometry](../territory/row-render-geometry.md) — geometry is asserted through rendered output
→ [Cell editing](../territory/cell-editing.md) — focus and commit are observed through what the field shows, not through session internals
→ [Theme system](../territory/theme-system.md) — the derived editing fill is asserted by its colour, not by the canvas call that paints it (#199)

## What a violation looks like

Two shapes:

- **A test that breaks on a refactor that changed nothing a user can see.** The
  test was pinned to a type, a private widget, or a name.
- **A test that passes when it should not.** A `find.text` assertion on a common
  word matches *some other widget* that happens to draw the same string — so the
  test proves the string exists somewhere on screen, which is nothing.

The second is worse and quieter: a green suite that has stopped observing.

A third shape sits between them: **a `paints` matcher over a widget the
framework paints.** It pins which canvas call the installed Flutter makes, and
`pubspec.yaml` admits a range of Flutter versions while every gate runs one. The
test is green on the SDK it was written on and red on an older one the package
supports, with nothing on screen different. A `paints` pattern over this
package's own painter does not have this exposure, because this package makes
those calls.

## Discovery history

- **#62** — a section's collapse behaviour was asserted with
  `find.byType(ExpansionTile)`; swapping the widget broke the test immediately,
  while `find.byIcon(Icons.expand_more)` survived. The refactor was behaviour-
  preserving; only the observation point decided which test noticed.
- **#59** — 68 controls were covered by counting them
  (`Switch 25 / Dropdown 12 / Slider 20`). Pinning them by name would have
  required editing the test on every section move, which would have destroyed the
  evidence the test existed to give: that the move changed nothing. A count breaks
  honestly, 20 → 21.
- **#199** — the editing-cell fill test asserted `paints..rrect(color:)` on the
  `InputDecorator`. Flutter 3.44.0 (flutter#184258) moved that fill from
  `drawPath(getOuterPath)` to `paintInterior`, which is `drawRRect`. The test
  was written on 3.44 or later and failed on 3.41.9, inside the declared
  `flutter: ">=3.32.0"`, with the fill painted correctly. The only `drawRRect`
  there is the border stroke, which is the black rect the failure named. It now
  accepts the fill colour on either call, and still reddens when
  `fromColorScheme` stops setting `filled`.
- **#58** — a test passed on `find.text('Playground')` while the page under test
  had no such element: a settings panel drew the same string. A common-word
  assertion says nothing.

## Where it will recur

**Every new widget test**, and especially any test written *during* a refactor —
that is exactly when reaching for the type you are holding is most tempting. The
check: *if I rename or replace the widget under test without changing what the
user sees, does this test still pass?* If not, the observation point is too deep.
