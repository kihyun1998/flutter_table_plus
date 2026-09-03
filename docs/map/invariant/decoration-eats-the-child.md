# A decorated box hands its child less than it declares

## The fact

A `Container` carrying a `decoration` with a border does **not** give its child
the extent it declares — **on every side the border draws**.
`BoxDecoration.padding` is `border.dimensions`, which is
`EdgeInsets.fromLTRB(left, top, right, bottom)` of each side's `strokeInset`,
per side and unconditional; `Container` folds it into the child's inset; and the
child is laid out inside `declared − border`.

So **any child sized to the parent's declared extent overflows it**, by exactly
the border width on that axis, and the overflow is only as visible as the child's
layout makes it. Size children to what the parent actually gives, or leave one of
them flexible so the shortfall has somewhere to go.

**Both axes, and the second one was found five days after the first.** This note
was written from #121, which was a `height` case, and every sentence in it said
`height` — so a reader who opened it while working #156, a `width` case in the
same mechanism, found nothing that applied. The rule's own recurrence test below
had *predicted* #156 and could not be reached from it. That is the failure mode
of an invariant note written from one instance: the mechanism generalises and the
prose does not.

## Why it is cross-cutting

The number is declared in one place and consumed in another, and the two are
usually different files. A row's height comes from a measurement or a theme; the
box that carries it also carries the divider; the widget that fills it was
written against the declared number because that is the number with a name.

**The sites do not call each other.** Each was written on its own, and each is
one fixed-size child away from the same defect.

**No count is kept here, deliberately.** One was, and it was wrong on its own
page: it said *"12 containers"* in one sentence while its own enumeration summed
to eleven and three later sentences said *"eleven"*. Nothing reads the number —
no script in `scripts/` counts decorated containers — so it was a second answer
with nowhere to be checked, and adding the width axis would have produced a
third. The roster is the tree: `rg -B4 'decoration:' lib/src` and look for a
`height:` or a `width:` in the same constructor.

The rule is easy to state and easy to miss because **it is invisible until a
child stops being flexible.** Every one of those eleven was correct for years
while its children were `Expanded`: a flex division silently absorbs whatever
space it is handed, so the shortfall existed all along and paid for itself.

## Territories it holds in

→ [Merged rows](../territory/merged-rows.md) — the group box carries the row divider and its members are laid out inside it; this is where the rule was measured (#121)
→ [Row rendering and geometry](../territory/row-render-geometry.md) — the plain row and the body's list slots build the same shape from `rowDecoration`
→ [Row selection](../territory/row-selection.md) — the selection cell and the header cell size a checkbox inside a decorated box
→ [Row height](../territory/row-height.md) — a measured height is the declared number, never the number the child receives
→ [Text overflow detection](../territory/text-overflow.md) — the width axis: a cell measured its text against `width − padding` while the divider's border took another 0.5px from the glyphs, so text that was clipped on screen was reported as fitting (#156)

## What a violation looks like

A `RenderFlex overflowed by N pixels` where N is exactly `dividerThickness` — or,
far worse, **no banner at all**. A flexible child absorbs the shortfall and
reports nothing, which is how every site in the census stayed correct without
anyone knowing the rule. The defect only appears when someone gives a child a
fixed extent computed from the parent's declared one, and then it appears as a
1px stripe that reads like a rounding artifact.

**On the width axis it can be worse than no banner: no pixels at all.** When what
was computed from the declared width is a *number* rather than a child — #156's
`TextPainter` argument — nothing overflows, nothing paints wrong, and a boolean
is simply answered incorrectly. The only way to see it is to compare the number
against what the box actually handed out.

**Fixing it by distributing the shortfall is a trap, and it was measured.** #121's
first fix gave each member a share proportional to its height, which does not
overflow — and moves *every* child off its correct position, by an amount that
grows with `dividerThickness` and with position, silently. The border is at one
edge; the cost belongs to the child at that edge, not spread across all of them.

## Discovery history

**#121**, and it arrived as a surprise inside a fix for something else. Merged
group members were drawn at an equal share of the group's total instead of their
own measured heights. Replacing the equal split with fixed extents summing to
that total overflowed by exactly 1.00px, which is `bodyTheme.dividerThickness`.

The doc comment written for the first repair claimed a ratio was "right whatever
`dividerThickness` is set to". Two adversarial passes over the same tree, with
opposing stances, independently measured that false: at `dividerThickness: 4` the
third member of a 48/96/48 group lands 2.0px high. The test that was supposed to
catch it allowed 1.0px — the same number as the default thickness, so the suite
was calibrated to exactly hide the error the mechanism introduced.

## Where it will recur

**Any time a size is computed from a box's declared extent rather than from the
constraints it receives — on either axis.** In particular: a new fixed-height
cell inside any decorated container; a header that stops using `Expanded`; any
per-row content sized from `theme.rowHeight` directly; and, on the width axis,
**any number derived from a column width that will be compared against something
laid out inside the box** — a measurement, a hit-test, a truncation decision.
The signal to watch for is arithmetic that adds up to the parent's number — if it
sums exactly, it is already wrong by the border.

**And the child does not have to be a widget.** #121's was: a member cell laid
out inside a group box. #156's was a *number* — `width − padding.horizontal`,
computed from the declared width and handed to a `TextPainter`, with no widget
anywhere to overflow and no banner to print. That is the harder half of this
rule, because the height cases at least have `RenderFlex` to complain: a
mismeasurement just answers a boolean wrongly, forever, in silence.

**One site is confirmed, measured, and reachable through a public field.**
`table_header.dart`'s `_buildHeaderDecoration` returns the caller's
`theme.decoration` unchanged when they set one, and the box it decorates is
`width: totalWidth` around a `Row` of header cells whose widths already sum to
`totalWidth`. Probed 2026-09-03, two 150px columns in a 500px viewport:

| header decoration | header label `x` | body value `x` | desync |
|---|---|---|---|
| none | 166.0 | 166.0 | 0.0 |
| `Border.all(width: 2)` | 168.0 | 166.0 | **2.0** |

**And no exception, no overflow banner.** The header slides against the body by
exactly the left border's width, silently, in a table whose whole contract is
that the two stay aligned. Found by the adversarial pass on #156 and probed when
that pass — being read-only — could only name the mutation. Not repaired there:
the fix moves the header's width, which is
[synced scrolling](../territory/synced-scrolling.md)'s blast radius and not text
overflow's.
