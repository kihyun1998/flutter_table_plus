# Hover buttons

## What it is

Action buttons that appear over a row while the pointer is on it, built by the
caller and positioned by the package on one side of the row.

## Governing decisions

**None.**

## Design model

- **The caller builds the buttons; the package places them.**
  `hoverButtonBuilder` returns a widget for a row, `HoverButtonPosition` decides
  the side. The package never decides what an action is or does.
- **They overlay the row, they do not re-flow it.** A hovered row is the same
  height and the same width as an unhovered one, which is what keeps hover from
  interacting with row height and overflow.
- **Appearance is tied to the hover state the interaction shell already tracks**,
  rather than to a second hover listener.

## Code

`widgets/row_hover_button.dart` — `buildRowHoverButton`
`models/hover_button_position.dart` — `HoverButtonPosition`
`models/theme/hover_button_theme.dart` — `TablePlusHoverButtonTheme`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row interaction](row-interaction.md) — the hover state comes from there, and a button's taps must not reach the row beneath
→ [Row rendering and geometry](row-render-geometry.md) — the overlay is built inside the row widget
→ [Theme system](theme-system.md) — its own sub-theme
→ [Merged rows](merged-rows.md) — a merged row builds its own hover overlay

## Known holes / open

**None.**
