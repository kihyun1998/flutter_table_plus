# Row interaction

## What it is

What a pointer does to a row that is not selection or editing: tap, double tap,
secondary (right) tap, hover, and the ink response. Small, rarely changed, and
the place where several gestures on the same surface have to stay
distinguishable.

## Governing decisions

**None.**

This is the territory the maintainer names as quiet and dangerous: nothing here
changes for long stretches, nothing local fails when it breaks, and the symptom a
user reports ("the tap fired twice", "the ripple is on the wrong row") does not
point back here.

## Design model

- **Gestures are counted, not guessed.** `TapCounter` distinguishes a single tap
  from the first half of a double tap, so a double-tap handler cannot make single
  taps fire twice.
- **The ink response is custom on purpose.** `CustomInkWell` exists because
  Material's own tap handling did not compose with the counting and with the
  row-level hover treatment.
- **One shell per row.** `RowInteractionShell` is the single place a row's
  gestures are wired, so a new gesture is added in one place rather than three.
- **Hover is a consumer concern by definition** — the package reports it and
  styles it, and never decides what a hover means.

## Code

`widgets/tap_counter.dart` — `TapCounter`
`widgets/custom_ink_well.dart` — `CustomInkWell`
`widgets/row_interaction_shell.dart` — `RowInteractionShell`

## Reference behaviour

**None.** Material's `InkWell` and `GestureDetector` double-tap timing is the
obvious reference for the counting rules and has never been read against them.

## Cross-cutting invariants

**None.**

## Blast radius

→ [Row selection](row-selection.md) — tap-to-select enters through this shell
→ [Cell editing](cell-editing.md) — entering edit mode competes for the same taps
→ [Drag selection](drag-selection.md) — a press that becomes a drag must not also read as a tap
→ [Hover buttons](hover-buttons.md) — they appear on the hover this territory tracks
→ [Row rendering and geometry](row-render-geometry.md) — the shell wraps each rendered row

## Known holes / open

**None.**
