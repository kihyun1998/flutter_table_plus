# A measurement is given what the paint resolves, never what the caller wrote

## The fact

A `TextStyle` written in a theme is not the style the glyphs are painted with,
and the number in a width field is not the width they are laid out in. Between
the two sit resolutions that happen at build and paint time and are invisible to
a bare `TextPainter`:

- **The ambient `DefaultTextStyle` is merged under the style**, which is where
  the font family, `letterSpacing` and `height` come from when a theme style
  does not name them. `Text` does this; a `TextPainter` does not.
- **`MediaQuery.textScalerOf` multiplies the resolved size at paragraph build.**
  It is not in the style — a package zoom that scales `fontSize` inside the
  style is a different multiplication and stacks with it.
- **`Directionality` and the accessibility overrides** (`boldText`, letter- and
  word-spacing) arrive the same way.
- **The box hands the child less than it declares**, by whatever its decoration
  takes — see
  [a decorated box hands its child less than it declares](decoration-eats-the-child.md),
  which is this fact's geometry half.

So **any measurement built from the values a caller wrote predicts a different
string than the one on screen**, always in the same direction: too narrow, too
short, too generous about what fits.

## Why it is cross-cutting

**Three measurement sites in this package, no call path between any two of
them**, each written on its own against the same theme:

| site | what it answers |
|---|---|
| `utils/table_column_width_calculator.dart` | how wide does this column need to be |
| `utils/text_overflow_detector.dart` | does this cell's text fit |
| `utils/table_row_height_calculator.dart` | how tall does this row need to be |

They are three answers to one question — *how much room does this string
need* — and they drifted apart rather than together. The column-width one was
correct from the start; the other two resolved **none** of the inputs above
until 2.17.0, and the correct implementation sat 400 lines from one of them in
the same file, with a comment naming each resolution it performed.

That is what makes it an invariant rather than a rule of any one territory:
nothing in the code connects the three, so nothing propagates a fix, and the
next site added will be written against the theme exactly like the first two.

**The symptom differs at every site, which is why it was never recognised as one
fact.** Wrong width: a column too narrow. Wrong overflow verdict: a tooltip
withheld on the text it exists to reveal. Wrong height: a row too short and the
text clipped. Three bug reports that look unrelated.

## Territories it holds in

→ [Text overflow detection](../territory/text-overflow.md) — the detector measured with the theme's bare style, no scaler, and a width the divider's border had already taken 0.5px from (#156)
→ [Row height](../territory/row-height.md) — the same three, in the public helper, where the symptom is clipped text rather than a missing tooltip
→ [Column width resolution](../territory/column-width.md) — the site that got it right, and therefore the reference the other two were repaired against
→ [Scale / zoom](../territory/scale-zoom.md) — `scaledBy` multiplies `fontSize` *inside* the style while `TextScaler` multiplies the resolved size, so the two stack and neither substitutes for the other

## What a violation looks like

**A `TextPainter` constructed from a value the caller supplied, with no
resolution step between.** The tell is a constructor whose arguments are all
fields of a theme or of a config object — no `DefaultTextStyle.of`, no
`MediaQuery.textScalerOf`, no term for what a decoration consumes.

**And the failure is silent at every site.** Nothing overflows, nothing throws,
no banner prints. A width comes out small, a boolean comes out `false`, a height
comes out short — and the only way to see any of them is to compare the number
against what the box actually handed out. Measured 2026-09-03: the row-height
helper predicted 100px for a paragraph the screen laid out at 120px, and 100px
again where an OS text scale of 1.25 needed 225px.

**A defaulted parameter is not a fix.** Adding `TextScaler textScaler =
TextScaler.noScaling` reproduces the correct site's *shape* and changes nothing
by default — the resolution has to happen at a call site that holds a
`BuildContext`. A finding that stops at "the parameter exists" has not reached
the defect.

## Discovery history

**#156**, and it took three passes to see as one fact. The ticket named two
causes in the overflow detector — an unsubtracted border inset and an unread
`textScaler`. Two adversarial passes over the same tree, with opposing stances,
independently found a third the ticket had not: `style ?? DefaultTextStyle.of(context).style`
is a `??` and not a merge, and every call site passes a style, so the only
`BuildContext` in the file was dead. That one was **twenty times larger** than
the cause the ticket was filed for.

Both passes then found the same thing in the same place: the auto-fit path in
`widgets/flutter_table_plus.dart` already did all three, with a comment naming
each. **One layer had drifted from its own sibling**, which is the strongest
form of finding available here — the tie-breaker is this repo's own
measurement, so no external reference had to arbitrate it.

The row-height helper was found afterwards, by asking whether the fact held
outside the territory the change entered. It did, at a **public export**, where
the symptom is visible clipping rather than a missing tooltip.

**The scope question was closed by a matrix, not by an argument.** On one
reproduction: today `false`, the border term alone `false`, the style merge
alone `false`, both together `true`. Fixing causes one at a time was not a
smaller change — it was no change.

## Where it will recur

**Any new `TextPainter` in this package, and any new number derived from a
declared extent that will be compared against something laid out inside the
box.** The grep is mechanical: `rg 'TextPainter\(' lib/` and, for each hit, ask
whether a `DefaultTextStyle` merge and a `textScaler` reached it.

**And at the boundary, not just inside it.** Two of the three sites are exported,
so a consumer can call them directly — which means the resolution they need is
one this package must either perform or document as the caller's, never leave
implied. `createHeightCalculator` takes a `context` for exactly that reason.

**The trap that hides it is the default.** Every one of these inputs has a value
at which the defect is invisible: `TextScaler.noScaling`, a theme style that
happens to name its family, a decoration with no border, `scaledBy(1.0)`. A test
written without setting them cannot fail — which is the same lesson `scaledBy`
taught at #50, on a different knob.
