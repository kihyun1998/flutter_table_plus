# Example app

## What it is

`example/` — a Flutter application with its own manifest, its own analyzer run
and its own test suite, containing a shell menu whose entries are recipes (one
feature per self-contained file, shown beside its own source), a viewport
preview stage, a feature list with per-feature detail panes, a playground with
named presets, and a settings registry that drives every table option from the
UI.

It is the single largest area by issue count in this repository, and it is a
**gate**, not a demo folder.

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
- **A recipe may carry demo scaffolding, and says so in the file.** Some
  recipes draw a strip above the table, marked in its own doc-comment with
  *"This is the demo explaining itself; delete it when you paste."* — **grep
  that sentence rather than counting them.** The count was written as "three of
  the seven" in the same commit that added a fourth, and stayed wrong for two
  tickets; the marker is the index and a number is not. A strip exists where the
  feature's mechanism has no on-screen consequence to point at — a four-term
  activation condition, a column's `order` values, a width in logical pixels,
  the `Set<String>` a merged-row selection actually reports. Everything else in
  a recipe is code a reader keeps.
- **The preview frame owns an overlay, because a viewport does.** Everything
  that opens *above* the page — a `Draggable`'s feedback, a tooltip, a menu —
  goes to `Overlay.of(context)`, the *nearest* one, and `just_tooltip` also reads
  that overlay's render box to position itself. With no overlay inside the frame
  they resolve to the app's root, which sits above the fit transform: the table
  draws at 0.46× and the thing dragged out of it at 1:1, over the whole window.
  Measured 2026-08-26 — 91.7px against 200px. The frame therefore contains its
  own overlay, which is a statement about what a viewport *is* rather than a
  workaround for the scaling.
- **The Device Wall is live, and the criterion that said otherwise was
  withdrawn on measurement.** Drawing every viewport at once answers what the
  single-viewport modes cannot — *what changed between two widths* — and #108
  originally asked for it to take no pointer input. Both reasons behind that
  failed. The technical one (a scaled frame endangers the drag coordinate frame)
  is corrected in
  [the coordinate-frame invariant](../invariant/viewport-local-frame.md). The
  design one (three frames are too small to operate) is true of **one** of them:
  the three do not share a scale, because each viewport is fit into an equal
  column and the frame never scales up. Measured 2026-09-01 in the shell at
  1800px — desktop 0.28× (an 11px row), tablet 0.48× (19px), **mobile 1.0×, at
  its full 40px**. The narrowest viewport is both the one a reader most wants to
  poke at and the one drawn at real size.
  What being live buys is the only thing here the single-viewport modes cannot
  do: the frames share one state, so an interaction in the mobile frame paints
  its result in the other two at the same time. The cost is that the desktop
  frame's rows are ~11px and imprecise to hit — precision lives in the
  single-viewport modes. An `IgnorePointer` would also have been half a decision:
  it vetoes hit testing only, and focus traversal plus `Actions` bypass it, so
  rows stayed keyboard-activatable regardless — 20 of 40 Tab presses landed
  inside a wall table. Live in both routes is one rule; live in one and dead in
  the other was two.
  Every column is always fit: a wall column is whatever a third of the region
  happens to be, so 1:1 there is three clipped slices at three arbitrary widths,
  which is why the Fit / 1:1 control is not drawn in that mode.
- **The bundled font is a subset, and the subset is a claim.** Four Pretendard
  weights ship with the app, cut from the full faces to a Latin charset written
  down as Unicode ranges in `scripts/fonts/subset_pretendard.py`. Two properties
  follow and neither is obvious. A missing glyph **does not throw** — Flutter
  draws it from a platform face, so the failure looks like a typeface seam
  mid-sentence rather than like an error, which is how the em dash stayed
  missing for six commits under a comment claiming the subset carried Korean it
  had never had (#122). And `fontFamilyFallback` **cannot** displace the family:
  Flutter resolves `fontFamily` first, a `TextStyle` inherits the ambient one,
  so a style listing only fallbacks renders in the chrome font — which is what
  the Code pane did from #104 to #123 while looking monospace-configured.
  Charset changes are checked by reading the shipped `cmap`, never by reading
  the script that produced it.
- **A knob pane only draws its own feature's controls**, so an interaction
  between two features is not reachable from either one's knobs. Where the
  interaction is the point — resized widths against zoom, a row card against a
  merged row — the second control goes in the stage as scaffolding rather than
  widening the pane. Two independent arrivals at the same shape, so it is the
  rule rather than one recipe's workaround.

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
`lib/recipes/` — one file per feature. Listed as a directory on purpose: the
pasteability rule is a property of the *directory* and
`test/recipe_seam_test.dart` walks it rather than the catalogue, so naming the
files here would be a second roster to keep in step and nothing would catch it
drifting
`lib/theme/table_palette.dart`
`lib/theme/example_theme.dart`
`lib/shell/source_pane.dart`
`../scripts/fonts/subset_pretendard.py` — the font charset, as ranges
`lib/preview/preview_stage.dart`
`lib/preview/preview_frame.dart`
`lib/preview/device_wall.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

→ [The widget-test font is a square per glyph](../invariant/test-font-square.md) — the demo's own suite is where this was measured: a 19-character label measures 304px in a test against roughly 190 on screen
→ [Observe at the screen, assert by count](../invariant/observe-at-the-screen.md) — the demo's tests count controls rather than naming them, which is what let its widgets be reorganised without rewriting the suite
→ [Viewport-local coordinates come from one frame](../invariant/viewport-local-frame.md) — the preview scales the table, and the belief that scaling broke the frame is the one thing here that was asserted, measured, and withdrawn

## Blast radius

→ [Publishing and release](publishing.md) — the example is a gate and has its own lockfile, which has been wrong before
→ [Theme system](theme-system.md) — the demo assembles themes, and that is its actual responsibility
→ [Tooltips](tooltips.md) — the anchor page exists to show behaviour the package's own tests already pin

## Known holes / open

- **The Device Wall and the very-large-row-count scenario (#109) are mutually
  exclusive, and the exclusion is written down in three places and enforced in
  none.** The wall draws three tables over the same data at once; that scenario
  is a single-table performance claim, so a frame rate measured on the wall is
  measuring the wall. `shell_page.dart` passes `showsWall: true` unconditionally,
  which is correct only while every destination is a single table — whoever
  builds #109 will be in `shell/` and in a new scenario file, and has no reason
  to open `device_wall.dart`. The comment at the call site is the thing most
  likely to be read; this line is the thing most likely to be *found*.
