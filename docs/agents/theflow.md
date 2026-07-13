# theflow bindings (flutter_table_plus)

Project-specific data for the `theflow` skill. The skill holds the portable
*method*; this file holds this package's *bindings* — which reference to read,
where the boundary falls, how to prove behavior, which surfaces to sweep, which
gates to run. Per-incident evidence lives in [`lessons.md`](lessons.md).

Identity & invariants (the **UI-only, data-agnostic** philosophy) live in
`CLAUDE.md`. `CONTEXT.md` / `docs/adr/` do not exist yet — created lazily.

**Environment:** Claude Code and the user share the same Windows machine; the
Flutter SDK is on `PATH`, so run `flutter test` / `analyze` / `dart format`
directly (do not ask). The exception is anything that opens a window
(`flutter run`) — ask the user to drive and say what to look for. **There is no
CI**: the Step 7 gates are the only gates and they run here.

## Crate / module map

Single Flutter package. Public surface is the barrel `lib/flutter_table_plus.dart`.

| Module (`lib/src/`) | Role |
|---|---|
| `widgets/flutter_table_plus.dart` | main `FlutterTablePlus<T>` widget; owns the `DragSelectionController`, falls back `rowTooltipTheme`/`headerTooltipTheme` → `tooltipTheme` at the call site |
| `widgets/table_header.dart` | header row — sorting, reordering, column resizing |
| `widgets/table_body.dart` | body `ListView`, a **pure row renderer**; implements the `RowLocator` port via public `TablePlusBodyState`, reached by the parent through `GlobalKey` |
| `widgets/row_locator.dart` | `RowLocator` — the narrow port (`indexAt`, `idsBetween`) decoupling drag-select from the body's caching |
| `widgets/drag_selection_controller.dart` | drag-to-select state machine + rubber-band geometry + auto-scroll `Timer`; scroll application injected as callbacks → **unit-testable without pumping** (`fakeAsync`) |
| `widgets/synced_scroll_controllers.dart` | header/body/scrollbar horizontal sync (body is the input master; header uses `NeverScrollableScrollPhysics`) |
| `widgets/table_plus_merged_row.dart`, `custom_ink_well.dart` | merged-row rendering; custom tap handling |
| `models/` | `table_column`, `table_columns_builder` (ordered columns safely), `merged_row_group`, `theme/theme` (nested theme classes), `tooltip_behavior` |
| `utils/` | `table_row_height_calculator`, `text_overflow_detector` |

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **`just_tooltip` / `flutter_checkbox` behavior** | their **source + CHANGELOG** at `../just_tooltip` · `../flutter_checkbox` (same author, each with its own tracker) — not pub docs. They are not strangers' code; fix there what belongs there (Step 2) |
| **Text width / overflow in tests** | the **widget-test font is a `fontSize` square per glyph** → text measures far wider than on screen (`'Performance Metrics'` 19×16=304px vs ~190px real). Overflow in a test is a *worst-case width simulator*, not a nuisance — investigate before enlarging the viewport (#55) |
| **Rendering / gesture / coordinates** | Flutter SDK source |
| **Downstream bug claim** | the reporting consumer's repo directly (a sibling under `../`, derived on the spot) — verify, don't assume |

## Step 2 — boundary rule

**UI-only, data-agnostic.** The package never stores or mutates table data;
sort/filter/paginate stay with the caller, communicated through callbacks.

- **Mechanism / core (this package owns):** synced scrolling, the single
  viewport-local drag-selection coordinate frame (`Listener` outside the body's
  horizontal `Scrollable` so `event.localPosition` is viewport-local on both
  axes), the `RowLocator` port, `minWidth`/`maxWidth` `clamp()` in every layout
  path, merged rows, and the tooltip-gating logic.
- **Policy / consumer:** the data and all operations on it, selection state,
  what a callback does. `rowId: String Function(T)` is the caller's — identity
  comes from there.

**The `just_tooltip` boundary (read `../just_tooltip` before touching this).**
Nesting is arbitrated **by just_tooltip** (innermost wins) — this package holds
no priority logic. **Since just_tooltip 0.4.4, "innermost" means the innermost
tooltip that *has something to draw*:** an empty-message tooltip under
`hideOnEmptyMessage` is inert — built, silent, and it yields the row card. That
is why **`^0.4.4` is a floor, not a preference.** 0.4.3 claimed the ancestor at
`MouseRegion.onEnter` and only *afterwards* declined to draw, so this package
answered by never building a tooltip that could not show (#88) — **that local
guard is now gone (#96)**, with the floor standing in its place. Do **not**
re-introduce it. (`table_header_cell.dart`'s `label.isEmpty` is different and
stays — a `shouldShow` policy; a header tooltip nests inside nothing.)

- **A row tooltip uses `TooltipAnchor.pointer` as a correctness requirement**,
  not a workaround: a row is `contentWidth` wide, so hover region ≠ anchor. Since
  0.4.2 a `child` anchor targets the *visible* slice of a clipped child (not off
  screen), so the old "child aims off screen" reason is false (corrected #69).
- **Judging ≠ reporting (#88 → #96).** This package correctly judged the
  ancestor-suppression as just_tooltip's *intended* contract and fixed here — but
  did **not report upstream**, so the trap in the upstream default lived until
  0.4.4 fixed it there. A workaround that works well silences upstream forever.
  **Judge where to fix *and* report upstream** — they are separate duties.

## Step 4 — proof method per layer

| Layer | Real proof |
|---|---|
| **pure logic** (`DragSelectionController`) | unit test with a fake `RowLocator` + `fakeAsync` for the auto-scroll `Timer` — no widget pump |
| **widget behavior** | widget test observing at the **screen**, not the implementation (`find.byIcon(Icons.expand_more)` survives a widget swap; `find.byType(ExpansionTile)` does not — #62). Use counts, not names, so a move stays green (#59) |
| **overflow** | `pumpWidget`/`pumpAndSettle` rethrow framework exceptions — an overflow in a test means *investigate why* (the square-font worst case), do not just enlarge the viewport |
| **example** | `cd example && flutter analyze && flutter test` — a **gate**, not an afterthought |
| **sibling deps** | read `../just_tooltip` / `../flutter_checkbox` source + CHANGELOG, not pub docs |
| **downstream** | link into a consumer's suite (derive the consumer on the spot at Step 10) |

Test-trust: a **semantic guard** (passes without the fix — protects a meaning,
e.g. "`null` selects the fallback") is not a **regression guard**; label which in
the commit (#50/#52). To revert-to-see-red, use `git stash push -- <file>` /
`git stash pop`, **never `git checkout -- <file>`** (it nukes uncommitted work).

## Step 6 — behavior-describing surfaces

- **`CHANGELOG.md`** — pub.dev snapshots it at publish. Never edit a published
  entry; open a new version. This repo's changelog doubles as a bug inventory.
- **Reclaim now-false rationale** — a wrong *rationale* is more dangerous than a
  wrong *conclusion*: no test catches a wrong reason, and the next reader follows
  it. #69: just_tooltip 0.4.2 made `child` anchor the *visible* slice, so six
  "the row centre scrolls off screen" rationales went false while the conclusion
  (`pointer`) stood. #96: withdrew the "a tooltip that cannot show must never be
  built" reason from five call sites once 0.4.4 made it upstream law.
- **`README.md` · `docs/THEMING.md` · `docs/FEATURES.md` · `docs/MIGRATION.md`**
  — public API grows here too; and when a documented constraint lapses, *deleting*
  it is part of that issue's work (#51 wrote "header and cell share an anchor",
  #52 deleted it).
- **`example/`** — a package of its own with its own analyzer run and suite (both
  gates). The demo is an *example*, not policy: open everything, document the traps.
- **lockfile** — `example/pubspec.lock` once recorded a nonexistent `2.16.0`; a
  self-contradictory tree is not a thing to tag.
- **`.pubignore`** — excludes `docs/`, `.github/`, `CLAUDE.md`, `coverage/`,
  `benchmark/`, `build/`. A root `.pubignore` disables git-based file listing.
  The pub.dev archive cannot be un-published.

## Step 7 — gate matrix + downstream loop

**No CI.** Run these locally, in order — they are the only gates:

```
flutter analyze                                     # 0 issues
dart format --output=none --set-exit-if-changed lib test
flutter test
cd example && flutter analyze && flutter test        # the example is a gate
flutter pub publish --dry-run                        # 0 warnings, clean tree
```

- `cd example && flutter test` is a gate — a leftover `flutter create` counter
  template once kept it permanently red, which trains everyone to ignore it (#55).
- Branch → `feat|fix|refactor|test(<scope>): …` → PR (`Closes #issue`) →
  **rebase-merge** (linear history; zero merge commits on `main`).
- **Tag only after docs + example are in, and after checking open PRs + local
  branches** — 2.15.0 was tagged past an unmerged PR #69 whose tree was broken
  for 3.10–3.12 users. Only an *unpublished* tag is free to move.
- **Publish state is queried, not assumed:** `curl -s
  https://pub.dev/api/packages/flutter_table_plus`. The steps the agent does
  *not* run are the ones whose result most needs confirming (2.15.0: a published
  CHANGELOG entry was edited in place and the tag moved twice because publication
  was not confirmed first).
- **Identify the published commit by the archive, not by timestamp** — fetch
  `archive_url`, unpack, compare each file to `git show <commit>:<path>`,
  normalizing `tr -d '\r'` (archive is CRLF, git blob is LF). If *all* candidates
  fail — or all pass — suspect the checker, not the candidates.
- `flutter pub publish` is irreversible (retract only) — **the agent does not run
  it; the user does.**
- **Downstream loop:** derive consumers on the spot (`for d in ../*/; do grep -l
  'flutter_table_plus:' "$d/pubspec.yaml"; done`); after a release, in each,
  raise the constraint and remove workarounds the fix made unnecessary. The list
  is never stored here.

## War-story index

The per-incident evidence (#22, #33, #38, #50–#52, #55, #58–#63, #65, #69,
#88→#96, and the 2.15.0 publish/tag incident) lives in
[`lessons.md`](lessons.md), indexed by step. Read it before starting.
