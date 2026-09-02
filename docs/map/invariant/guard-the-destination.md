# A guard reads the destination, never the source

## The fact

A check that asserts on **where a value comes from** passes anything that
acquired the value **another way**. The assertion has to read the artifact the
user actually meets.

The shape is always the same, and it is not obviously wrong when you write it:

1. A property is decided somewhere central — a theme, a widget's declared style,
   a factory.
2. A test asserts the property **at that central place**, because that is where
   the decision lives and it is the convenient thing to reach.
3. Something else acquires the property by a different route — a sub-theme
   nobody rendered, a wrapper the framework inserts, a leaf span that overrides
   an inherited value.
4. The defect is now invisible. The test is green, it is *correct* about what it
   reads, and it has stopped covering what it was written for.

**A green guard of this shape is worse than no guard**, because it is cited as
evidence. Every instance below closed a ticket that read as done.

## Why it is cross-cutting

The sites do not call each other and do not look alike. What they share is that
a value has **two ends** — a place it is decided and a place it is drawn — and
that only one end is convenient to assert on.

That description covers a theme and its rendered widgets, a widget's declared
`TextStyle` and the span tree beneath it, a factory's output and the surfaces
that read it. None of those is a call path; it is a *shape*, which is why fixing
one instance teaches nothing about the next.

**The convenient end is always the source.** That is what makes this recur
rather than being learned once: the source is one object with a name, and the
destination is N places you have to enumerate. So the guard drifts toward the
source every time somebody writes one under time pressure.

## Territories it holds in

→ [Theme system](../territory/theme-system.md) — a theme object is a source by
construction, and what a table draws is the destination
→ [Example app](../territory/example-app.md) — where it was measured three
times, twice in one change

## What a violation looks like

Two tells, and the first is cheap enough to apply to every guard you write:

- **Ask what the assertion would still pass if the feature were removed at the
  draw site.** If the answer is "it would pass", the guard reads the source.
- **The guard names an object rather than a rendering.** `theme.colorScheme`,
  `widget.style`, `factory().field` — as opposed to what a `find.` reaches, what
  a span tree flattens to, or what the clipboard receives.

The repair is rarely to rewrite the guard, because the source assertion is
usually still worth holding. It is to **add** the destination one, and to say in
the test which of the two each is.

## Discovery history

- **#110** — closed as *"the demo table goes neutral too — no hard-coded blue"*.
  True of the demo's theme object and false of the screen: `demoTableTheme` sets
  3 of 10 sub-themes, and four blues survived in the three nobody had rendered
  yet. Recorded in #112's measurement, which is the ticket that had to be opened
  because the first one read as finished.
- **#113, twice in one change, which is what promoted this.**
  - The achromatic-chrome guard runs a `grey()` predicate over `exampleTheme`'s
    `ColorScheme`. The Code pane's highlighter draws from that scheme, so a hued
    palette would have crossed a written decision with the guard still green —
    the guard reads the scheme, not the spans. Two roles the highlighter uses
    were then found to be outside the hand-listed four.
  - The monospace guard from #123 reads `EditableText.style`. `SelectableText`
    wraps a given span tree as `TextSpan(style: style, children: [yours])`, so
    that style is the **wrapper**: once the pane rendered `.rich`, a leaf naming
    a font family drew proportional text with the guard still green. Measured by
    mutation — the added leaf-level assertion reddens while all three original
    ones stay green.

## Where it will recur

**Any test written against a theme, a factory, or a widget's declared
configuration** — which is most of what is convenient to assert without pumping
a frame. And specifically wherever a value is *inherited*: an inherited value has
a source that is easy to check and an arbitrarily deep set of places that may
override it, which is the same asymmetry one level down.
