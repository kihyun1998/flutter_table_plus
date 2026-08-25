# Theme system

## What it is

One root theme composed of nine sub-themes, the `copyWith` chain that produces
variants, the `scaledBy` factor that produces a zoomed variant, and the fallback
rules that decide which tooltip theme a given tooltip actually gets.

## Governing decisions

**None.**

`docs/THEMING.md` documents every field and shows what `scaledBy` scales — but as
a guide, not a decision: it records *that* colours and radii do not scale, not
why, and nothing records the fallback chain's precedence as a decision either.

## Design model

- **`scaledBy` is built on `copyWith` and names only the six sub-themes it
  scales.** Everything else is carried through unenumerated, so a sub-theme added
  later cannot be dropped by forgetting to list it. This is not a style
  preference: hand-listing is exactly how `rowTooltipTheme` went missing.
- **`scaledBy(1.0)` returns the receiver.** Convenient, and the reason the
  dropped field was invisible at the factor everyone tests with — any test of
  this area that uses 1.0 proves nothing.
- **Tooltip themes fall back at the call site**, not inside the theme:
  `rowTooltipTheme` / `headerTooltipTheme` fall back to `tooltipTheme` where they
  are read, which is why the chain is a property of the caller and not of the
  data.
- **Not everything scales, and the list is per sub-theme** — widths, paddings and
  font sizes do; colours and radii do not.

## Code

`models/theme/theme.dart` — `TablePlusTheme`
`models/theme/body_theme.dart` — `TablePlusBodyTheme`
`models/theme/header_theme.dart` — `TablePlusHeaderTheme`, `TablePlusHeaderBorderTheme`, `TablePlusHeaderDividerTheme`, `TablePlusResizeHandleTheme`
`models/theme/checkbox_theme.dart` — `TablePlusCheckboxTheme`
`models/theme/editable_theme.dart` — `TablePlusEditableTheme`
`models/theme/tooltip_theme.dart` — `TablePlusTooltipTheme`
`models/theme/scrollbar_theme.dart` — `TablePlusScrollbarTheme`
`models/theme/hover_button_theme.dart` — `TablePlusHoverButtonTheme`
`models/theme/drag_selection_theme.dart` — `TablePlusDragSelectionTheme`

## Reference behaviour

→ [tip.md §3 — what to scale and what not to](../../../tip.md#3-스케일링-대상-구분) — settles the split between scaled and unscaled properties
→ [tip.md §5 — scaling a custom icon](../../../tip.md#5-커스텀-아이콘-스케일링) — settles how icon sizing follows the factor
→ [tip.md §6 — Material checkbox caveat](../../../tip.md#6-material-checkbox-주의) — settles why the checkbox cannot simply be wrapped in a scaling box

## Cross-cutting invariants

→ [Never re-assemble by hand-listing fields](../invariant/no-hand-enumeration.md) — this territory is where the invariant was learned
→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — the checkbox sub-theme wraps a sibling package's widget, and its Material-3 factory sits on that seam

## Blast radius

→ [Scale / zoom](scale-zoom.md) — it supplies the factor; this territory decides what the factor *means*
→ [Tooltips](tooltips.md) — three tooltip themes and one fallback chain
→ [Row selection](row-selection.md) — checkbox theming, including the ripple and hover switches
→ [Row rendering and geometry](row-render-geometry.md) — body colours, borders and the dim treatment
→ [Column resizing](column-resize.md) — the resize handle's theme lives in the header sub-theme, not a resize one

## Known holes / open

**None.**
