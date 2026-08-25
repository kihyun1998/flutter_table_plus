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

## Code

`lib/pages/playground/playground_page.dart`
`lib/pages/playground/widgets/settings_registry.dart`
`lib/pages/playground/models/playground_settings.dart`
`lib/pages/playground/widgets/feature_list_pane.dart`
`lib/pages/playground/widgets/feature_detail_pane.dart`
`lib/pages/tooltip_anchor/tooltip_anchor_page.dart`

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
