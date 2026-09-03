# A decorated box hands its child less than it declares

## The fact

A `Container` carrying both a `height` and a `decoration` with a border does
**not** give its child that height. `BoxDecoration.padding` is the border's
dimensions, `Container` folds it into the child's inset, and the child is laid
out inside `height − border`.

So **any child sized to the parent's declared height overflows it**, by exactly
the border width, and the overflow is only as visible as the child's layout makes
it. Size children to what the parent actually gives, or leave one of them
flexible so the shortfall has somewhere to go.

## Why it is cross-cutting

The number is declared in one place and consumed in another, and the two are
usually different files. A row's height comes from a measurement or a theme; the
box that carries it also carries the divider; the widget that fills it was
written against the declared number because that is the number with a name.

**The sites do not call each other.** Census at the time of writing: **12
containers carry both a `height:` and a `decoration:`** — four in the merged row,
two in the header cell, and one each in the plain row, the header, the body, the
selection cell and the table root. Each was written on its own, and each is one
fixed-size child away from the same defect.

The rule is easy to state and easy to miss because **it is invisible until a
child stops being flexible.** Every one of those eleven was correct for years
while its children were `Expanded`: a flex division silently absorbs whatever
space it is handed, so the shortfall existed all along and paid for itself.

## Territories it holds in

→ [Merged rows](../territory/merged-rows.md) — the group box carries the row divider and its members are laid out inside it; this is where the rule was measured (#121)
→ [Row rendering and geometry](../territory/row-render-geometry.md) — the plain row and the body's list slots build the same shape from `rowDecoration`
→ [Row selection](../territory/row-selection.md) — the selection cell and the header cell size a checkbox inside a decorated box
→ [Row height](../territory/row-height.md) — a measured height is the declared number, never the number the child receives

## What a violation looks like

A `RenderFlex overflowed by N pixels` where N is exactly `dividerThickness` — or,
far worse, **no banner at all**. A flexible child absorbs the shortfall and
reports nothing, which is how the eleven sites above stayed correct without
anyone knowing the rule. The defect only appears when someone gives a child a
fixed extent computed from the parent's declared height, and then it appears as a
1px stripe that reads like a rounding artifact.

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

**Any time a child's size is computed from a box's declared height rather than
from the constraints it receives.** In particular: a new fixed-height cell inside
any of the eleven containers above; a header that stops using `Expanded`; any
future per-row content sized from `theme.rowHeight` directly. The signal to watch
for is arithmetic that adds up to the parent's number — if it sums exactly, it is
already wrong by the border.
