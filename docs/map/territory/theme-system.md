# Theme system

## What it is

One root theme composed of ten sub-theme fields over eight classes, the `copyWith` chain that produces
variants, the `scaledBy` factor that produces a zoomed variant, and the fallback
rules that decide which tooltip theme a given tooltip actually gets.

## Governing decisions

**None.**

`docs/THEMING.md` documents every field and shows what `scaledBy` scales — but as
a guide, not a decision: it records *that* colours and radii do not scale, not
why, and nothing records the fallback chain's precedence as a decision either.

## Design model

- **`scaledBy` is built on `copyWith` at every level, and names only what it
  changes.** Everything else is carried through unenumerated, so a field added
  later cannot be dropped by forgetting to list it. This is not a style
  preference: hand-listing is exactly how `rowTooltipTheme` went missing.

  **The rule holds at every level, and it did not always.** #50 fixed the root
  and left the sub-themes alone, so `TablePlusCheckboxTheme.scaledBy` went on
  re-assembling `CheckboxStyle` field by field. That type belongs to
  `flutter_checkbox` and grew: by the pinned 0.3.1 the list was five fields
  behind, and every one of them — `checkScale`, `hoverColor`, `focusColor`,
  `splashColor`, `disabledOpacity` — reverted to its default at any factor but
  1.0. #116. **A list cannot stay complete against a type it does not own**,
  which is the sharpest form of this rule the repository has met.
- **`scaledBy(1.0)` returns the receiver.** Convenient, and the reason a dropped
  field is invisible at the factor everyone tests with — any test of this area
  that uses 1.0 proves nothing. Eight short-circuits, one per `scaledBy`.

  This is *not* what hid #50: measured at `60c2a58^`, the tree before that fix,
  `theme_scaling_test.dart` already carried eight non-1.0 assertions and named
  `rowTooltipTheme` in none of them. A factor other than 1.0 is necessary for a
  test here and it is not sufficient — see the semantic-versus-regression
  distinction in
  [the invariant](../invariant/no-hand-enumeration.md).
- **A field being reachable is not the same as the value being reachable, and a
  default should be the derivation rather than what it evaluates to.** Six
  values this package painted had no field at all — the column rule's hardcoded
  0.5px, three alphas multiplied onto `dividerColor`, two placeholder styles,
  and `Colors.red` for a rejected edit, in a theme family where the word *error*
  appeared nowhere. Each is now `field ?? <what it drew before>`, and the
  fallback is deliberately the *expression*: move `dividerColor` and all three
  lines still move together. Writing the produced colour into the default would
  make every new field a second place the hierarchy is stated, which is the
  hand-list failure one level down from the one above. #171.

  **#153 is why this is a rule here rather than a repair there.** It found four
  hardcoded widths, fixed them, and recorded that the colours "do follow the
  theme; only the widths do not". Both halves measured false three months later:
  two more widths did not follow, and a literal multiplier over a theme colour
  is not that colour following the theme. Fixing instances without retiring the
  shape leaves the shape free to produce more — the same sequence #135 → #151
  ran in the merged-rows territory.
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
→ [tip.md §6 — Material checkbox caveat](../../../tip.md#6-material-checkbox-주의) — settled why a Material `Checkbox` could not simply be wrapped in a scaling box. **The question is closed** — 2.10.0 adopted `flutter_checkbox` and scaling goes through `CheckboxStyle.scale`; the entry is kept because it records why the sibling dependency exists at all

## Cross-cutting invariants

→ [Never re-assemble by hand-listing fields](../invariant/no-hand-enumeration.md) — this territory is where the invariant was learned
→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — the checkbox sub-theme wraps a sibling package's widget, and its `colored()` factory sits on that seam
→ [A guard reads the destination, never the source](../invariant/guard-the-destination.md) — a theme object is a source by construction, and #110 closed green while four blues survived in the sub-themes nobody had rendered
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — the sub-theme field set is on the register, and a dropped field is invisible at the factor everyone tests with (#50, #116)

## Blast radius

→ [Scale / zoom](scale-zoom.md) — it supplies the factor; this territory decides what the factor *means*
→ [Tooltips](tooltips.md) — three tooltip themes and one fallback chain
→ [Row selection](row-selection.md) — checkbox theming, including the hover ring — there is no ripple, since `overlayColor` and `splashRadius` went with Material `Checkbox` in 2.10.0
→ [Row rendering and geometry](row-render-geometry.md) — body colours, borders and the dim treatment
→ [Column resizing](column-resize.md) — the resize handle's theme lives in the header sub-theme, not a resize one

## Known holes / open

**`copyWith` closes the carry-through half of this and not the scaling half.**
A field added upstream is now carried faithfully — and if it is *dimensional* it
travels unscaled, which is wrong in the other direction and just as quiet.
`shadows` (0.3.2) is safe only because upstream's changelog says it does not
scale; the next one may not come with that sentence.

Neither `CheckboxStyle` nor `TablePlusResizeHandleTheme` implements `==` or
`toString`, and Flutter has no reflection, so no *value* assertion can fail when
a field appears. `test/checkbox_style_field_set_test.dart` gets there another
way: it resolves the package through `.dart_tool/package_config.json` and pins
the field set read out of the source. Verified 2026-08-26 — green at the pinned
0.3.1, red at 0.3.2 naming `shadows`. An earlier version of this note said no
test was possible; that was written before anyone tried.

**One vertical line, two owners that cannot see each other.** The header half
is `headerTheme.verticalDivider`, the body half is `bodyTheme`'s
`verticalDividerSide`, and they have never referred to each other. Probed on the
default theme, 500px viewport, two 150px columns:

| | header | body |
|---|---|---|
| x at the same column edge | **[249.0, 250.0]** | **[249.5, 250.0]** |
| width | `1.0` | `0.5` |
| painted on white | `#E0E0E0` | `#EFEFEF` — `#E0E0E0` at alpha 0.5 |

Right-aligned to the same edge, so the step is on the left. They do **not** abut:
`headerTheme.bottomBorder` sits between them at 1.0px opaque, full width, which
is most of why nobody has reported this.

**Neither value was decided.** `dfa2f5f` (2026-03-05) extracted the body's
`alpha: 0.5, width: 0.5` from **five** copy-pasted widget sites into one getter;
the header's `1.0` at full colour is `TablePlusHeaderDividerTheme`'s constructor
default, written separately. Nothing connects them and no record chooses either.

**And a default cannot reconcile them, which is the part worth keeping.** A
default expression can only name fields of its own class, and these are sibling
sub-themes — only the root `TablePlusTheme` sees both. So the obvious repair
runs backwards: making the body half follow `dividerThickness` *widens* the
seam, because the header half does not follow it. Measured shape — at
`dividerThickness: 8` the body rule would be 8.0px against the header's
unchanged 1.0, a 7px step where there is now a 0.5px one.

Both halves are settable since #171 and neither default moved with it, and #177
holds the open question. The current difference is also defensible on its own: a lighter body rule under a
stronger header is what `DataTable`, `pluto_grid` and AG Grid all default to.
The open question is not which value is right — it is that a shared visual
element has no owner that can hold it.

**The example app could not have caught this, and still cannot.**
`example/lib/theme/table_palette.dart`'s demo style sets `size`, `activeColor`,
`checkColor` and `borderColor` — none of the five that were dropped — and the
zoom recipe renders no checkbox at all. *"A demo would have shown it"* is the
assumption that failed here.
