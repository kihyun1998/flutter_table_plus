# 0001 — A table theme derived from the app's `ColorScheme`

- **Status:** Accepted
- **Date:** 2026-09-24
- **Issues:** #112 (with #177, #113, and flutter_checkbox#13)

## Decision

> **`TablePlusTheme.fromColorScheme(ColorScheme scheme)` is an opt-in factory
> that sets every colour the table draws from a role of `scheme`, and nothing
> else. The constructor and its defaults are unchanged.**

| Question | Answer | Kind |
|---|---|---|
| API shape | One static factory on the root. No `of(context)`, no factory per sub-theme | judgement |
| Selected row | `secondaryContainer`; its text `onSecondaryContainer` | judgement |
| Editing markers | Follow the scheme: `primary` border and cursor, `primaryContainer` cell, `error` for a rejected cell | judgement |
| Column divider (#177) | Stays split: header 1.0px opaque, body 0.5px at alpha 0.5, both from `outlineVariant` | judgement |
| A scheme with no hue | Followed as given. No chroma detection and no substituted hue | judgement |
| How prominent | The README's first theme example uses it; the constructor is presented as setting every value yourself | judgement |
| Every other role | Material 3's own component defaults (table in `docs/THEMING.md`) | derivation |
| `focusedErrorBorderColor` | Set to `error` | derivation |
| Nullable colours not in the table | Left `null` | derivation |

A **judgement** was made by the maintainer and only the maintainer reverses it;
a later argument, however strong, is context for them and not a reason to
reopen it here. A **derivation** falls to a better derivation.

## What it was decided on

The six judgements were made on 2026-09-23 against a swatch page that rendered
each option with real `ColorScheme.fromSeed` output on Flutter 3.47.1. It used
three seeds: `#1565C0` and `#2E7D32` (tonal spot), and `Colors.black`
(monochrome, the example app's own). Each was shown in both brightnesses, beside
today's package defaults. The page showed a hovered row next to the selected
one, an editing cell, a rejected cell, the drag band, a tooltip, the scrollbar,
and a 10× magnification of the column divider where header meets body.

Two facts reached the maintainer after the swatch page, from reading the code
before implementing. They were decided on separately:

- **`selectedRowTextStyle` replaces `textStyle`; it is not merged over it.**
  Setting it therefore freezes the selected row's size and weight at factory
  time: a later `copyWith` of the body text style misses selected rows. Shown
  the alternative, leaving it `null` with `onSurface` measured ≥ 7.2:1 on
  `secondaryContainer` in all six schemes, the maintainer kept it set. The cost
  is documented to callers in `docs/THEMING.md`.
- **flutter_checkbox drew a white check on any `primary`** (1.7:1 on dark
  tonal-spot schemes, 1.0:1 on dark monochrome), and every table inherited it,
  factory or not. Setting `onPrimary` here would have fixed it only for factory
  users. It was fixed upstream first (flutter_checkbox#13, 0.3.3) and the floor
  raised here, before this factory was written.

The derivations:

- **Other roles** follow what Material 3 itself uses for the same part: M3
  `Checkbox` for the check (`onPrimary`) and unchecked border (`outline`), and
  M3 `InputDecorator` for focused and rejected borders.
- **`focusedErrorBorderColor` is set, although the brief said to leave it
  null.** The brief's reason was that its fallback derives from
  `errorBorderColor`. It does not: the fallback is a literal `#E53935`. M3's
  `InputDecorator` uses `error` for the focused error border as well as the
  unfocused one.
- **Nullable colours stay `null`** because since #171 their fallbacks are
  expressions over the fields this factory sets. `verticalDividerColor` becomes
  `outlineVariant` at alpha 0.5 without being named, for example. Setting them
  would state the hierarchy a second time.

## Consequences

- The factory is built on `copyWith` from the default constructors and names
  only colours, as `scaledBy` does (`no-hand-enumeration`). A size, padding or
  flag added to a sub-theme later is carried through without an edit here.
- Because it names colours, **a colour field added later is not derived until
  someone adds it here.** Left alone, the new field would keep its light default
  inside a dark table and nothing would fail — the shape #110 closed green on.
  `test/theme_colour_field_set_test.dart` is what fails instead: it reads every
  `Color` and `TextStyle` field out of the theme sources and requires each one
  to be listed as derived or as deliberately left null.
- The checkbox takes its colours from the scheme passed in, so it matches the
  table even when that scheme differs from `Theme.of(context)`.

## What it did not cover

- **Two nullable fields whose fallback is a literal, not an expression.**
  `effectiveEmptyStateTextStyle` and `effectiveMergedRowCountTextStyle` fall
  back to `#757575`. They are left `null` like the rest, so both stay that grey
  in a factory-built table. Measured at 4.0:1 on the dark surfaces tested
  against 4.4:1 on the light ones, so they are no less readable than today.
  But they do not follow the scheme, and nobody decided they should not.
- `SortIcons.defaultIcons`' `Colors.grey`. `SortIcons` holds widgets, not
  colours.
- Changing any default, and making the default theme read the ambient
  `ColorScheme`. That would be BREAKING and needs its own issue.
