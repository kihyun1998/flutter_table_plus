# 0001 — A table theme derived from the app's `ColorScheme`

- **Status:** Accepted
- **Date:** 2026-09-24
- **Issues:** #112 (with #177, #113, and flutter_checkbox#13)

## Decision

> **`TablePlusTheme.fromColorScheme(ColorScheme scheme)` is an opt-in factory
> that sets every theme colour with a non-null default, and the checkbox's,
> from a role of `scheme`, plus `editableTheme.filled: true`, and nothing
> else. The constructor and its defaults are unchanged.**

| Question | Answer | Kind |
|---|---|---|
| API shape | One static factory on the root. No `of(context)`, no factory per sub-theme | judgement |
| Selected row | `secondaryContainer`; its text `onSecondaryContainer` | judgement |
| Editing markers | Follow the scheme: `primary` border and cursor, `primaryContainer` cell, `error` for a rejected cell | judgement |
| The editing cell is filled | `filled: true`, so `primaryContainer` is painted behind `onPrimaryContainer` text | judgement, made again (below) |
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
- **The swatch page drew an editing cell the table does not draw.** It filled
  the cell with `editingCellColor`. But the package only paints that colour as
  the `TextField` fill, and `filled` defaults to `false`, so no default theme has
  ever painted it; today's `#FFF9C4` yellow never appears either. Implemented
  as first decided, the `onPrimaryContainer` text landed on the row itself:
  1.1:1 on a monochrome scheme's row, invisible, and ≥ 7.2:1 on the tonal-spot
  ones. Both reviewers of the finished change found it independently. The page
  could not have revealed it, so the decision was untested, not settled. It
  went back to the maintainer with three options: fill the cell; leave it
  unfilled with `onSurface` text; or leave it unfilled and point both colours
  at the row. The maintainer chose to fill it, which is what the page showed.
  This is the one non-colour value the factory sets.
- **flutter_checkbox drew a white check on any `primary`** (1.7:1 on dark
  tonal-spot schemes, 1.0:1 on dark monochrome), and every table inherited it,
  factory or not. Setting `onPrimary` here would have fixed it only for factory
  users. It was fixed upstream first (flutter_checkbox#13, 0.3.3) and the floor
  raised here, before this factory was written.

The derivations:

- **Other roles**: the check is `onPrimary`, which is M3 `Checkbox`'s own.
  The unchecked border is `outline`, which is flutter_checkbox's own default.
  M3 `Checkbox` uses `onSurfaceVariant` there, so this follows the widget
  actually drawn, not Material. Focused and rejected borders follow M3
  `InputDecorator`. The tooltip's `inverseSurface` is the M3 spec's role for an
  inverted surface (`SnackBar` uses it); Flutter's own `Tooltip` reads no
  scheme at all. The scrollbar's `onSurfaceVariant` / `surfaceContainerHighest`
  is **not** Material's default, which is `onSurface` at low alpha. It was
  chosen here to keep the package's opaque thumb and track.
- **`focusedErrorBorderColor` is set, although the brief said to leave it
  null.** The brief's reason was that its fallback derives from
  `errorBorderColor`. It does not: the fallback is a literal `#E53935`. M3's
  `InputDecorator` uses `error` for the focused error border as well as the
  unfocused one.
- **Nullable colours stay `null`.** Most fall back, since #171, to expressions
  over the fields this factory sets. `verticalDividerColor` becomes
  `outlineVariant` at alpha 0.5 without being named, for example, and setting
  them would state the hierarchy a second time. **Not all of them do.** Row
  hover, splash and highlight fall back to `Theme.of(context)` inside
  `InkWell`, and the sort arrows and editing hint also take the ambient theme.
  These match whenever the scheme passed in is the app's own, which is the
  documented use, and they are what Material's `DataTable` leaves to the app
  too. With a different scheme passed in, they follow the app. Deriving them
  from the scheme would be a new decision, not a correction.

## Consequences

- The factory is built on `copyWith` from the default constructors and names
  only colours and `filled`, as `scaledBy` does (`no-hand-enumeration`). A size, padding or
  flag added to a sub-theme later is carried through without an edit here.
- Because it names colours, **a colour field added later is not derived until
  someone adds it here.** Left alone, the new field would keep its light default
  inside a dark table and nothing would fail — the shape #110 closed green on.
  `test/theme_colour_field_set_test.dart` is what fails instead: it reads every
  field whose type can carry a colour (`Color`, `TextStyle`, `Border`,
  `Decoration`, `BoxShadow` and the like) out of the theme sources and requires
  each one to be listed as derived or as deliberately left null.
- The checkbox takes its colours from the scheme passed in, so it matches the
  table even when that scheme differs from `Theme.of(context)`.

## What it did not cover

- **Two nullable fields whose fallback was a literal, not an expression.**
  `effectiveEmptyStateTextStyle` and `effectiveMergedRowCountTextStyle` fell
  back to `#757575`. They are left `null` like the rest, so both stayed that
  grey in a factory-built table. Measured at 4.0:1 on the dark surfaces tested
  against 4.4:1 on the light ones, so they were no less readable than before.
  But they did not follow the scheme, and nobody had decided they should not.

  **Amended 2026-09-24 (#192): both now follow the body text colour, and the
  factory still leaves them `null`.** The fallback is `textStyle.color` with its
  opacity multiplied by 0.62, or `#757575` when that colour is null.
  - *Judgement — the maintainer's, on a measured table.* Three options were
    shown with WCAG contrast over three dark and two light `fromSeed` schemes:
    (a) derive from `textStyle`, (b) have the caption follow
    `selectedRowTextStyle` on a selected group, (c) have the factory set
    `onSurfaceVariant`. The maintainer chose (a). (b) was measured worse than
    the literal in a light `#1565C0` scheme, 3.0:1 against 3.6:1, because an
    `on*Container` colour at reduced alpha sinks into its own container.
  - *Judgement — the maintainer's.* `scaledBy` still materialises the caption
    to scale its 10px, and the colour is fixed with it. That was chosen over
    deriving the size from `textStyle` too, which would reverse #171's "10 is a
    caption size", and over a private scale field, which would need a second
    constructor listing every field. It reaches only a caller who runs
    `scaledBy` themselves and recolours afterwards, because the table scales
    `widget.theme` again on every build.
  - *Derivation.* 0.62 is where `#212121` over white rounds to `0x75`, so the
    default theme draws the same pixel it drew before. Multiplying rather than
    replacing the alpha keeps a translucent text colour from getting darker.
  - *Not covered.* A selected group in a dark scheme now shows its caption at
    3.9:1, up from 2.0:1 but short of 4.5:1 for 10px text. Reaching 4.5 is
    option (c), which fixes size and style at factory time. It was left open,
    not rejected.
  - *Judgement — the maintainer's, on a case the first table could not show.*
    The table above sampled only `fromSeed` schemes, where the selected
    container has the surface's brightness. A light table that sets its own
    dark `selectedRowColor` or `dimRowColor`, leaving `textStyle` alone, now
    draws the caption at 1.14:1 on `#303030` (it was 2.86:1) and 1.36:1 on
    `#424242` (it was 2.18:1). Following each row state's text style would fix
    it, but that is (b), which regresses light schemes. Kept as it is. A caller
    in that case sets `mergedRowCountTextStyle`.
- `SortIcons.defaultIcons`' `Colors.grey`. `SortIcons` holds widgets, not
  colours.
- Changing any default, and making the default theme read the ambient
  `ColorScheme`. That would be BREAKING and needs its own issue.
