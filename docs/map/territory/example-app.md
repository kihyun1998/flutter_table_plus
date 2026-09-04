# Example app

## What it is

`example/` — a Flutter application with its own manifest, its own analyzer run
and its own test suite. **It opens on the shell**, whose menu holds recipes (one
feature per self-contained file, shown beside its own source), scenarios
(several features assembled, held to no import rule), and pages (a full page
with its own `Scaffold`, opened on its own route). Also here: a viewport preview
stage, a feature list with per-feature detail panes, a playground with named
presets, and a settings registry that drives every table option from the UI.

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
- **`lib/scenarios/` is the zone that is deliberately *not* pasteable.** A recipe
  is one feature with nothing else switched on, which is what makes it readable
  and what makes it unlike any real screen; a scenario assembles several and may
  reach into whatever the app already has. The distinction is **asserted rather
  than left to the directory names** — the same test that holds recipes to the
  allow-list checks that the scenario files are outside the walk *and* that at
  least one of them really does import something a recipe may not. If that ever
  goes empty the scenarios have quietly become recipes, and the question to ask
  is why they are not in the pasteable zone.
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

  **A third consequence, and the one that decided #113: anything standing
  between the bundle's bytes and the clipboard has to be provably transparent.**
  The pane is highlighted and has a copy button, and the tokenizer that draws it
  returns a **partition** — concatenating the token texts reproduces the source
  exactly. That is structural rather than asserted: tokens are cut from recorded
  end offsets, so the two shapes a hand-written scanner reaches for naturally
  are unreachable — splitting on `\n` and re-joining, and lower-casing a word to
  match a keyword. It is **hue-free** because the chrome is, and comments are
  the one thing *not* dimmed: they are 29% of the corpus and they are the
  teaching, so slant separates them at full contrast and punctuation recedes.
  **Line numbers were refused** on the pane's own ground — it is the affordance
  of the pasteable claim, not a source viewer. Their natural implementation is
  also the broken one: an inline gutter of placeholder spans writes `\u{FFFC}`
  into every copied line, because `SelectableText` leaves `includePlaceholders`
  at its default and only *documents* that children must be `TextSpan`s. That is
  the mechanism the refusal avoided, not the reason for it.
- **Two guards here exist because the obvious ones look sufficient and are
  not, and both are the same shape.** The pane's monospace test reads
  `EditableText.style`, which is the *wrapper* `SelectableText` puts around a
  given span tree — so once the pane went `.rich`, a leaf naming a family would
  render proportional while that test stayed green; a leaf-level assertion was
  added rather than the old one rewritten. And the achromatic-chrome test
  hand-lists four `ColorScheme` roles while the highlighter draws from two
  others, so those two are now named there. **A check that reads a value's
  source rather than its destination passes anything that acquired the value
  another way** — which is what let #110 close as "the demo goes neutral" while
  four blues survived in sub-themes no demo had rendered yet.
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
- **Whether the wall may draw a destination is the destination's call, and
  refusing it is two halves.** `StageDestination.allowsWall` decides, so the
  shell never learns what a scenario is — a page-level test against an id would
  be exactly that. The very-large-row-count scenario is the one that says no:
  three tables over the same hundred thousand rows makes a frame rate a
  measurement of the wall. Hiding the segment is only half of it, because the
  wall is a mode `ShellPage` is already *in*, so `_select` leaves it when a
  destination that refuses it is opened. **Nothing would have reported the other
  outcome.** Measured 2026-09-01 in the SDK: `SegmentedButton` asserts
  `segments.length > 0`, `selected.length > 0 || emptySelectionAllowed` and
  `selected.length < 2 || multiSelectionEnabled`, and **nothing** that `selected`
  is a subset of `segments`; the highlight is decided per segment by
  `selected.contains(segment.value)`. So a selection matching no segment draws
  as no highlight at all, over a wall that should not be there (#109).
  Row count is a **separate axis and is deliberately unguarded**: `EmployeeDemo`
  offers 20 000 rows from a knob pane that sits outside the wall, so the
  expensive shape is reachable without a scenario. The tables build their rows
  lazily, so the cost is three times what is on screen rather than three times
  the data.
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
- **Two menu categories name content and the third names a hosting kind.**
  Recipes are pasteable single features and scenarios are assemblies; `pages` is
  the remainder, and what its two members share is a shape rather than a
  subject — each is a full page with its own `Scaffold`, so the shell points at
  it instead of drawing it. The category was `playground('Playground')` while it
  had one member, which is a set named after its only element; the second member
  is what made that visible, and renaming cost nothing because no test asserts a
  category header (#147). Inventing a content theme to cover "every setting at
  once" and "where a tooltip sits" would have been naming a set after something
  it does not have.
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
`lib/shell/shell_destination.dart` — `ShellCategory`, `StageDestination`, `allowsWall`, `RouteDestination`
`lib/main.dart` — `MyApp`, the entry point that names what the app opens on
`lib/shell/recipe_catalog.dart`
`lib/scenarios/hr_dashboard_scenario.dart` — `HrDashboardDemo`
`lib/scenarios/large_table_scenario.dart` — `LargeTableDemo`
`lib/shell/destinations/recipe_destination.dart`
`lib/recipes/` — one file per feature. Listed as a directory on purpose: the
pasteability rule is a property of the *directory* and
`test/recipe_seam_test.dart` walks it rather than the catalogue, so naming the
files here would be a second roster to keep in step and nothing would catch it
drifting
`lib/theme/table_palette.dart`
`lib/theme/example_theme.dart`
`lib/shell/source_pane.dart`
`lib/shell/dart_highlighter.dart` — `DartTokenKind`, `DartToken`, `tokenizeDart`
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
→ [A guard reads the destination, never the source](../invariant/guard-the-destination.md) — measured here three times: #110’s blues, and both of #113’s guards reading a theme object and a wrapper style instead of what is drawn
→ [A file's directory is decided before it is written](../invariant/tree-rule.md) — `example/` is a package of its own with its own manifest, and `example/test/` is a gate rather than a demo detail (#55)

## Blast radius

→ [Publishing and release](publishing.md) — the example is a gate and has its own lockfile, which has been wrong before
→ [Theme system](theme-system.md) — the demo assembles themes, and that is its actual responsibility
→ [Tooltips](tooltips.md) — the anchor page exists to show behaviour the package's own tests already pin

## Known holes / open

- **`ViewportBar.showsWall` defaults to `false` and no caller uses the
  default.** `ShellPage` is the only host and always passes `_open.allowsWall`
  explicitly; the host that relied on the default drew one frame and was
  retired at #147. Kept for the reason below it is kept: the next host that
  draws a single frame is written by someone who would not think to pass the
  parameter, and `false` is the answer they want. Recorded because an unused
  default reads as dead code to whoever finds it next.
- **Every `ShellCategory` now has entries, so `ShellMenu`'s empty-category
  branch is unreachable from the app.** It is kept on purpose — the next
  category added is added empty, which is exactly when it is needed and exactly
  when nobody would think to write it — and it is pinned by a test that pumps
  `ShellMenu` directly rather than through the shell. Recorded here because
  "unreachable from the app" is what gets a branch deleted as dead code the day
  before someone needs it.
