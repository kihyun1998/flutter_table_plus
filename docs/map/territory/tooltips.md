# Tooltips

## What it is

Three tooltip layers over the same surface — a header tooltip, a cell tooltip,
and a row card — plus the rules for when each shows. It is the territory with the
most incident history in the repo, and almost all of it is about the boundary
with `just_tooltip` rather than about this code.

## Governing decisions

**None.**

The most consequential decisions in this area are recorded as *incidents*, not as
decisions: `docs/agents/lessons.md` holds why the row anchor is the pointer and
why the local empty-message guard was removed, but an incident record explains
what went wrong, not what the rule is for the next case.

## Design model

- **Nesting is arbitrated upstream, not here.** `just_tooltip` decides that the
  innermost tooltip wins; since 0.4.4 "innermost" means the innermost one *with
  something to draw*. This package holds **no** priority logic, and the local
  empty-message guard that used to substitute for it is gone — the floor
  (`^0.5.1` now, which includes 0.4.4's rule) is not a preference, and the
  guard must not come back.
- **A screen reader hears a tooltip only where the table did not already draw
  its text.** Since just_tooltip 0.5.1 a tooltip's text is put on its child's
  semantics node, so a tooltip that repeats the child would be read twice. The
  header tooltip (its message is `column.label`) and a cell tooltip showing the
  cell's own text (`wrapWithTooltip`'s `fallbackMessage`) pass
  `excludeFromSemantics: true`. A `tooltipFormatter` message is not the drawn
  text, so it stays heard; a `tooltipBuilder` or row card is not heard at all,
  since upstream reads a builder tooltip only through `semanticsTooltip`, which
  this package does not set. The flag is a `FlutterTooltipPlus` constructor
  parameter and not a theme field, because whether a tooltip repeats its child
  is decided by the call site, not by the consumer's styling.
- **`enableTap` is this package's own field, mapped onto upstream `tap`.**
  `TablePlusTooltipTheme.enableTap` stays a `bool`; `FlutterTooltipPlus` passes
  `tap: TooltipTap.claim` or `TooltipTap.none` for it, since upstream deprecated
  its own `enableTap` in 0.5.0. `TooltipTap.observe` is not exposed.
- **A row tooltip anchors at the pointer as a correctness requirement.** A row is
  `contentWidth` wide, so its hover region is not its anchor; `TooltipAnchor.pointer`
  is the only anchor that tracks where the user actually is. (The old reason —
  "the row centre scrolls off screen" — is false since just_tooltip 0.4.2 and was
  withdrawn; the conclusion stands on the width argument alone.)
- **A header tooltip is different and keeps its own gate.** `label.isEmpty` in the
  header cell is a `shouldShow` policy, not the removed guard: a header tooltip
  nests inside nothing, so suppressing it cannot hand anything to an ancestor.
- **Resolution is a pure decision.** `TooltipResolver.shouldShow` decides from the
  behaviour and the content; `wrapWithTooltip` applies it.

## Code

`utils/tooltip_resolver.dart` — `TooltipResolver`, `shouldShow`
`models/tooltip_behavior.dart` — `TooltipBehavior`
`widgets/flutter_tooltip_plus.dart` — `FlutterTooltipPlus`
`widgets/tooltip_wrapper.dart` — `wrapWithTooltip`
`models/theme/tooltip_theme.dart` — `TablePlusTooltipTheme`

## Reference behaviour

→ [lessons.md — Step 2, the boundary](../../agents/lessons.md#step-2--경계--우회-금지-원인은-pubspec-바깥일-수-있다) — the recorded comparisons against `../just_tooltip`: what 0.4.0 intended, what 0.4.2 changed about `child` anchoring, and what 0.4.4 made upstream law

The raw source is a sibling checkout (`../just_tooltip`), not a file in this
repository, so it cannot be linked from here. Read the source and its CHANGELOG
there — never the pub.dev rendering.

## Cross-cutting invariants

→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — this territory is where the invariant was learned, twice
→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — tooltip tests position against measured text, so the square font moves the expected coordinates

## Blast radius

→ [Example app](example-app.md) — a tooltip opens in the *nearest* `Overlay` and reads its render box to place itself, so a tooltip inside the scaled preview frame needs that frame to own an overlay

→ [Theme system](theme-system.md) — the row and header tooltip themes fall back to the shared one at the call site, and that chain is resolved outside this territory
→ [Text overflow detection](text-overflow.md) — "show a tooltip only when the text is clipped" makes overflow detection a precondition for showing one
→ [Merged rows](merged-rows.md) — only a merged *spanning* cell wires a tooltip separately; a member cell is an ordinary cell and measures through its cache (#155)
→ [Sorting](sorting.md) — the header cell hosts both the sort affordance and the header tooltip
→ [Public barrel](public-barrel.md) — four `just_tooltip` types are re-exported from here

## Known holes / open

**None.**
