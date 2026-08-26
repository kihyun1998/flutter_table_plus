# Example app

## What it is

`example/` — a Flutter application with its own manifest, its own analyzer run
and its own test suite, containing a feature list, per-feature detail panes, a
playground with named presets, and a settings registry that drives every table
option from the UI.

It is the single largest area by issue count in this repository (19 issues are
about it), and it is a **gate**, not a demo folder.

## Governing decisions

**None.**

The demo's own philosophy — open everything, document the traps, and do not let
the demo re-test what the package already pins — is recorded only as incident
notes.

## Design model

- **The demo is an example, not policy.** Every option is exposed, including
  combinations a real app would not use, because the point is to show what the
  package can be asked to do.
- **The demo does not re-test the package.** A behaviour the package pins in its
  own suite is not re-asserted here; doing so would mean fighting the demo's own
  fixtures for a fact that is already proven.
- **Settings are data, not widgets.** A registry describes each control, so a new
  option is a row rather than a new widget — which is what keeps the settings
  panel from becoming the god-file it started as.
- **Presets are named combinations**, so a bug report can name a state instead of
  describing a sequence of toggles.
- **`lib/recipes/` is the pasteable zone.** One feature, one self-contained
  file, importing only Flutter, this package, and the example's shared demo data
  and palette. The rule is a property of the *directory*, checked by reading the
  imports, so "copy-pasteable" is a thing that can fail rather than a claim.
- **A recipe is knob-driven without knowing about knobs.** The shell holds the
  settings object and translates it into the recipe's plain parameters, so the
  same file serves the demo and the reader. The catalogue names the feature; the
  feature never names a recipe, because pointing the playground's description at
  the shell would invert the dependency.
- **The code on screen is the file, read from the bundle at runtime.** A recipe's
  `.dart` is declared as an asset and displayed from those bytes, so the shown
  code cannot drift from the running code — there is nothing for it to drift
  *against*. Two consequences that are not obvious: `build/**` leaves the
  analyzer, because the bundler copies the file outside its package where every
  relative import is unresolvable; and the Code view replaces the stage
  **region** rather than the stage's child, because source has no viewport and
  scaling it into one answers a question nobody asked.
- **A recipe may carry demo scaffolding, and says so in the file.** Three of the
  seven draw a strip the reader is told to delete on paste. They exist where the
  feature's mechanism has no on-screen consequence to point at: drag selection's
  four-term activation condition, a column's `order` values, a resized width in
  logical pixels. Everything else in a recipe is code a reader keeps.
- **A knob pane only draws its own feature's controls**, so an interaction
  between two features is not reachable from either one's knobs. Where the
  interaction is the point — resized widths against zoom — the second control
  goes in the stage as scaffolding rather than widening the pane.

## Code

`lib/pages/playground/playground_page.dart`
`lib/pages/playground/widgets/settings_registry.dart`
`lib/pages/playground/models/playground_settings.dart`
`lib/pages/playground/widgets/feature_list_pane.dart`
`lib/pages/playground/widgets/feature_detail_pane.dart`
`lib/pages/tooltip_anchor/tooltip_anchor_page.dart`
`lib/shell/shell_page.dart`
`lib/shell/recipe_catalog.dart`
`lib/shell/destinations/recipe_destination.dart`
`lib/recipes/selection_recipe.dart`
`lib/recipes/sorting_recipe.dart`
`lib/recipes/drag_selection_recipe.dart`
`lib/recipes/cell_editing_recipe.dart`
`lib/recipes/column_reorder_recipe.dart`
`lib/recipes/column_resize_recipe.dart`
`lib/recipes/zoom_recipe.dart`
`lib/theme/table_palette.dart`
`lib/shell/source_pane.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — the demo's own suite is where this was measured: a 19-character label measures 304px in a test against roughly 190 on screen
→ [Observe at the screen, assert by count](../invariant/observe-at-the-screen.md) — the demo's tests count controls rather than naming them, which is what let its widgets be reorganised without rewriting the suite

## Blast radius

→ [Publishing and release](publishing.md) — the example is a gate and has its own lockfile, which has been wrong before
→ [Theme system](theme-system.md) — the demo assembles themes, and that is its actual responsibility
→ [Tooltips](tooltips.md) — the anchor page exists to show behaviour the package's own tests already pin

## Known holes / open

**None.**
