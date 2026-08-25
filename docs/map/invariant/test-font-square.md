# The widget-test font is a square per glyph

## The fact

In a Flutter widget test the default font renders **every glyph as a `fontSize` ×
`fontSize` square**. Text therefore measures far wider in a test than on screen:
`'Performance Metrics'` is 19 × 16 = **304px** in a test against roughly **190px**
rendered.

An overflow in a widget test is a **worst-case width simulation**, not a test
artifact to be resized away.

## Why it is cross-cutting

Every measurement-dependent behaviour in the package shares this fixture, and
none of the sites know about each other: width auto-fit measures text, overflow
detection measures text, row height measures wrapped text, and tooltip
positioning is computed from a measured anchor. The shared assumption is the
*font*, which is invisible in all four call paths.

## Territories it holds in

→ [Text overflow detection](../territory/text-overflow.md) — the site where the discrepancy is largest, because overflow is exactly a width comparison
→ [Column width resolution](../territory/column-width.md) — auto-fit measures the widest cell, so its test expectations are square-font numbers
→ [Row height](../territory/row-height.md) — wrap points move, so a measured height in a test is not the rendered height
→ [Tooltips](../territory/tooltips.md) — anchor positions derived from measured text land elsewhere in a test than on screen
→ [Example app](../territory/example-app.md) — where it was measured, twice

## What a violation looks like

Two symptoms, opposite in shape:

- A test fails with an overflow and someone **enlarges the viewport** until it
  passes. The defect is now hidden and the accessibility case it was simulating —
  a user with large text — is untested.
- A test asserts a pixel width that was read off a real screen, and fails for a
  reason that looks like a layout bug.

The tell for both is a number in a test that nobody can derive: if the expected
value cannot be explained as `characters × fontSize`, it probably came from the
wrong place.

## Discovery history

- **#55** — a demo page did not fit an 800×600 test surface. The issue asserted
  the cause ("make the viewport bigger"); at 2000×1200 it still failed, because a
  settings panel was `width: 380` and the constraint was unchanged. The real
  cause was the font.
- **#65** — an estimate of "about 12 overflows"; aggregating the failure stacks
  by source line gave **34 instances resolving to exactly two shared helper
  lines**. A defect count is not an instance count, and the instances were all
  the same square-font measurement.

## Where it will recur

**Any test that asserts a width, a height, a wrap point, or a position derived
from text.** Also any *new* measurement helper: the moment a second helper starts
laying text out, its tests inherit this fixture without anyone choosing it.
