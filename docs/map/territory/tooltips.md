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
  empty-message guard that used to substitute for it is gone — `^0.4.4` is a
  floor, not a preference, and the guard must not come back.
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

→ [Theme system](theme-system.md) — the row and header tooltip themes fall back to the shared one at the call site, and that chain is resolved outside this territory
→ [Text overflow detection](text-overflow.md) — "show a tooltip only when the text is clipped" makes overflow detection a precondition for showing one
→ [Merged rows](merged-rows.md) — merged cells wire tooltips separately from ordinary cells
→ [Sorting](sorting.md) — the header cell hosts both the sort affordance and the header tooltip
→ [Public barrel](public-barrel.md) — four `just_tooltip` types are re-exported from here

## Known holes / open

**None.**
