# thegraph build (flutter_table_plus)

The compiled graph for the `thegraph` skill: **which nodes this repo has**, how
many, each one's guard and decider, and the artifacts generated for them.
`thegraph` holds the portable *method* (node-type catalog, four invariants,
reasoning habits); this file is its **contract** for this repo.

Compiled from [`theflow.md`](theflow.md) — the frozen predecessor's bindings,
which stay valid while both coexist. Per-incident evidence lives in
[`lessons.md`](lessons.md); identity and invariants in `CLAUDE.md`.

**Build stamp: `thegraph@100dbdb10d85`** (SKILL.md sha256[0:12], 2026-08-24).
Every generated artifact carries it. When the stamp is behind, `thegraph` says so
and continues — it never rebuilds on its own.

**Run state:** `.thegraph/` at the repo root, append-only, git-ignored. It is a
cache; the GitHub issue is the durable record.

---

## Node roster

| Node | Count | Why this count |
|---|---|---|
| `classify` | 1 | catalog |
| `spine` | 1 | GitHub sub-issues are live here (`gh api repos/{owner}/{repo}/issues/N/sub_issues` returns `[]`, not 404) — the roster is a **relation**, never prose |
| `map` | 1 | the MAP — [`docs/map/`](../map/README.md), 23 territories + 6 cross-cutting invariants |
| `reference` | 4 | the routing table's rows naming an external source (below) |
| `enumerate` | 1 | catalog · never delegated |
| `boundary` | 1 | catalog · never delegated. The seam is the published package plus the `../just_tooltip` / `../flutter_checkbox` membrane |
| `implement` | 3 | one per layer |
| `proof` | 3 | one per layer |
| `verify` | 2 | 1 gap-hunter + 1 refuter, bought by a non-empty sacred-path list |
| `sweep` | 1 | fanning out over 10 surfaces |
| `gate` | 1 | 5 commands, extracted as a script |
| `search` | once per candidate | catalog |
| `batch` | 1+ | catalog · human · never bypassed |
| `stop` | edge-triggered | catalog · human |
| `decide` | edge-triggered | catalog · human |
| `promote` | 1 | the project declares a record format (`docs/adr/`, single-context) in [`domain.md`](domain.md) — created lazily, holds nothing yet |
| `downstream` | 1 | the package publishes to pub.dev |

**None are absent.** Every catalog type has at least one instance here.

---

## `map` — the MAP

**Read [`docs/map/README.md`](../map/README.md) before drawing the boundary.**
23 territories and 6 cross-cutting invariants, indexed by *what the system does*
rather than by the event that produced them.

This node used to carry a hand-written module table. It does not any more, on
purpose: a second copy of the same answer is somewhere for the two to disagree,
and the MAP is now the only place it lives. Open the territory your change
enters, and read its `## Blast radius` as a **checklist** — each linked territory
gets opened. Finding nothing to change in one is a correct outcome; not opening
it is the failure the layer exists to prevent.

The MAP's own gate is `python scripts/map/check_map.py docs/map` — links,
anchors, symbol names, file attribution, section sets, and invariant reciprocity.

---

## `reference` — 4 source classes, none summarized

Every class is read as **raw source**, so any of them can produce a `CONFIRMED`
finding. Read whole files, then grep the actual lines; never a summarizing fetch.

| Class | Where | Read for |
|---|---|---|
| `siblings` | `../just_tooltip`, `../flutter_checkbox` — **source + CHANGELOG**, not pub docs | tooltip arbitration, checkbox behavior, and any `environment:` / floor change in their changelogs. Same author, each with its own tracker: fix there what belongs there |
| `sdk` | Flutter SDK source | rendering, gestures, coordinates, scroll physics |
| `consumer` | the reporting repo, derived on the spot from `../*/pubspec.yaml` | any downstream bug claim — verify, do not assume |
| `registry` | `https://pub.dev/api/packages/flutter_table_plus`, and `archive_url` for the published tree | publish state, which is **queried, never assumed**; identify the published commit by unpacking the archive and diffing against `git show <commit>:<path>` with `tr -d '\r'` (archive is CRLF, git blob is LF). If *all* candidates fail — or all pass — suspect the checker |

**summarized: none.**

To pin a runtime fact (a coordinate, a call order, an emitted event), instrument a
throwaway probe, read the number, delete the probe, and record the number in the
issue. Reading the code is not observing what it does.

---

## Layers — `implement` × 3, `proof` × 3

| Layer | Real proof |
|---|---|
| **pure logic** (`DragSelectionController`) | unit test with a fake `RowLocator` + `fakeAsync` for the auto-scroll `Timer` — **no widget pump** |
| **widget behavior** | widget test observing at the **screen**, not the implementation: `find.byIcon(Icons.expand_more)` survives a widget swap, `find.byType(ExpansionTile)` does not (#62). Assert **counts, not names**, so a move stays green and a real change breaks it honestly (#59) |
| **example** | `cd example && flutter analyze && flutter test` — a **gate**, not an afterthought (#55) |

### This project's tautological traps

A check that can only confirm what it assumes, or a measurement that misreads
itself:

1. **The widget-test font is a `fontSize` square per glyph** — `'Performance
   Metrics'` measures 19×16 = 304px against ~190px on screen. An overflow in a
   test is a **worst-case width simulator**, not a nuisance: investigate before
   enlarging the viewport (#55).
2. **`scaledBy(1.0)` returns the receiver**, so the dropped-field bug was
   invisible at the factor everyone tests with (#50).
3. **A semantic guard is not a regression guard.** *"`scaledBy` leaves an unset X
   tooltip theme unset"* passes with the fix removed (drop the field and it is
   `null` either way). The regression is caught by *"carries … through untouched"*.
   Label which one a test is, in the commit (#50/#52).
4. **`find.text` matches anywhere on screen** — a home-less test passed on
   `find.text('Playground')` because `settings_panel.dart` drew the same string
   (#58). A common-word assertion says nothing.

### The proof-artifact bar

**Before recording a proof artifact, name which of its assertions can observe this
change. After recording it, turn the fix off and confirm that *that* one reddens —
and that the others do not.**

Turn the fix off with `git stash push -- <file>` / `git stash pop`. **Never `git
checkout -- <file>`** — it destroys uncommitted work (#52).

The strongest proof runs in a real consumer: link the local build in, run its
**full** suite, and the strongest evidence is a consumer test that pinned the old
bug as its expected value now breaking.

---

## `verify` — the guard, the corpora, the second lens

### Inbound guard — sacred paths (decider: `code`)

The pass is **mandatory** when the diff touches any of these. The check is a
script over the diff, it overrides judgement, and it reports **which patterns it
evaluated** — a path list that matches nothing is otherwise indistinguishable from
a clean diff.

| Path | Why it costs more than a wrong number |
|---|---|
| `lib/src/models/theme/**` | a field can be dropped **silently** — no test breaks, and `scaledBy(1.0)` hides it (#50) |
| `lib/src/widgets/drag_selection_controller.dart` | the auto-scroll `Timer` and the gesture state machine — a leak keeps scrolling in the consumer's app |
| `lib/src/widgets/row_locator.dart` | the port both sides of drag-select agree on |
| `lib/src/widgets/synced_scroll_controllers.dart` | the single-coordinate-frame invariant; break it and every drag coordinate is wrong by an offset |
| `lib/src/widgets/flutter_table_plus.dart` | where edit commits and selection callbacks cross into the **consumer's data** |
| `pubspec.yaml` | a false floor breaks users' trees while `pub get` still succeeds here (#69); a dep's floor rise is BREAKING for us even with `lib/` untouched (2.16.0) |
| `CHANGELOG.md` | pub.dev snapshots at publish — a published entry edited in place splits the repo from the registry (2.15.0) |
| `.pubignore` | it decides the archive's contents, and the archive **cannot be un-published** |

Absent a path hit, the guard is enumeration risk (decider: `AI`): many edges,
domain semantics, cross-feature interaction. A reactive spike that keeps catching
*new* gaps one probe at a time is the signal that the enumeration is incomplete.

### The brief

Both corpora at once — this repo's siblings (the `hidden_state` list plus a walk
against the features already solving the adjacent problem) **and** the reference
sources, systematically enumerated. **Never drop a corpus because the fix is
small.** Plus the grade table (`thegraph`'s, unchanged), the **tie-breaker row for
this layer**, and the **deliberate-divergence list** — both below.

### Promotion — the obligation on the way out

**Is the fact this pass revealed also true outside the territory the change
entered?** If yes, a cross-cutting invariant note is part of *this* change, not a
follow-up: the first site to hit such a fact is where it is cheapest to record
and the one place no node for it exists yet. A map that only gains invariants
after the third rediscovery is a post-hoc archive.

The concrete form here: *does this hold at any site that shares the same
dimension, the same coordinate frame, the same sibling dependency, or the same
test fixture?* — a question answerable by grep rather than by judgement.

### Second lens

Same material, opposite job: the first hunts gaps, the second tries to **refute**
them and to break the convergence claim. Both read everything, so a disagreement
between them is information, not an errand.

---

## Tie-breaker — per layer

What wins when prior art and this project's own evidence disagree.

| Layer | Who wins |
|---|---|
| coordinates, gestures, scrolling | **Flutter SDK source** — and source plus a probe's number, never the doc comment |
| public API shape, theming, feature scope | **this repo's measurement + `CLAUDE.md`'s identity.** UI-only / data-agnostic is not a call prior art gets to reverse |
| tooltip / checkbox integration | **`../just_tooltip` · `../flutter_checkbox`'s contract.** If the contract is wrong, fix it **there** — no workaround here (#33, #88→#96) |
| versioning, publishing, semver | **the pub / Dart convention.** A dependency floor rise is BREAKING even when `lib/` is untouched (2.16.0) |

---

## Deliberate divergence — arguments that are already over

The tie-breaker says who wins an argument; this says which arguments are closed.
`verify`'s restatement test is checked against this list.

1. **No data management.** Sort / filter / paginate stay with the caller,
   communicated through callbacks. — `CLAUDE.md`
2. **`rowId: String Function(T)` is required.** Identity comes from the caller;
   index-based identity is refused. — `CLAUDE.md`
3. **A row tooltip uses `TooltipAnchor.pointer`**, not `child` — a row is
   `contentWidth` wide, so hover region ≠ anchor. A **correctness requirement**,
   not a workaround. The old *"the row centre scrolls off screen"* rationale is
   false since just_tooltip 0.4.2 and was withdrawn; the conclusion stands. — #33,
   corrected #69
4. **No tooltip priority logic here.** Nesting is arbitrated by `just_tooltip`
   (innermost wins; since 0.4.4 "innermost with something to draw"). The local
   empty-message guard is **gone and must not return** — `^0.4.4` is a floor, not a
   preference. — #88 → #96
5. **The body is the input master**; the header uses
   `NeverScrollableScrollPhysics`. — `CLAUDE.md`
6. **`scaledBy()` is built on `copyWith`** and names only the six sub-themes it
   scales. Hand-listing fields is forbidden: that is exactly how `rowTooltipTheme`
   went missing. — #50
7. **Widget observation happens at the screen** — `byIcon` over `byType`. — #62
8. **Assert counts, not names.** — #59

---

## `sweep` — 10 surfaces

| Surface | How it is read |
|---|---|
| `CHANGELOG.md` | pub.dev snapshots it at publish. **Never edit a published entry — open a new version.** This changelog doubles as a bug inventory (2.15.0) |
| `README.md` | the install snippet pins a version; it has been stale before |
| `docs/THEMING.md` · `docs/FEATURES.md` · `docs/MIGRATION.md` | the public API grows here too; when a documented constraint lapses, **deleting it is part of that issue's work** (#51 wrote it, #52 deleted it) |
| public doc-comments in `lib/` | they ship verbatim as the package's reference — the surface most likely to still describe the old behavior |
| `example/` (+ its `README.md`) | a package of its own with its own analyzer run and suite, **both gates**. The demo is an *example*, not policy: open everything, document the traps |
| `example/pubspec.lock` | it once recorded a nonexistent `2.16.0` — a self-contradictory tree is not a thing to tag |
| `.pubignore` | excludes `docs/`, `.github/`, `CLAUDE.md`, `coverage/`, `benchmark/`, `build/`, `scripts/`. A root `.pubignore` **disables git-based file listing**, so anything unlisted ships |
| **now-false rationale** | a wrong *rationale* is more dangerous than a wrong *conclusion*: no test catches a wrong reason, and the next reader follows it. #69 (six rationales), #96 (five call sites + `THEMING.md` + two test comments) |
| **the MAP** (`docs/map/`) | a territory note describes behaviour, so it drifts when behaviour moves. Update the note whose territory the change entered — `## Design model`, `## Code` symbols, `## Blast radius` — and run `python scripts/map/check_map.py docs/map`. A refactor that moves symbols decays **file attribution** and nothing else: the gate catches exactly that |
| the **cluster anchor** | this is `spine`'s flush, not a separate obligation: the root confirmed or falsified, the numbers measured, any new sibling **enrolled as a sub-issue**, what is still open. The roster never goes in the body |

**Judge a sweep by what it cannot see, never by its hit count.** When a hit turns
up, widen the pattern with the phrasing that produced it *before* fixing the hit.

**Glossary and decision trail:** `CONTEXT.md` and `docs/adr/` do not exist yet
(created lazily). Nothing to sweep there until they do — and creating one is a
`promote` act, not a sweep act.

---

## `gate` — 5 commands, each run bare

**There is no CI.** These are the only gates, and they run on this machine — the
Flutter SDK is on `PATH`, so run them; do not ask. (`thegraph`'s "name the CI
workflow the list derives from" clause is **N/A** here: there is no second copy to
drift from. If CI is ever added, this list becomes a third copy and must assert
against it.)

```
flutter analyze                                     # 0 issues
dart format --output=none --set-exit-if-changed lib test
flutter test
cd example && flutter analyze && flutter test        # the example is a gate
flutter pub publish --dry-run                        # 0 warnings — it does NOT check the tree
```

**Each runs bare, never piped** — a pipeline's exit status is the last command's,
so `test … | tail -1 && commit` always commits. A gate you cannot fail is not a
gate. **Never move a threshold to turn a build green.**

### Known blind spots

- `example/` is **outside** the top-level `flutter test` — its own manifest, its
  own analyzer run. A leftover `flutter create` counter template once kept it
  permanently red, which trains everyone to ignore it (#55).
- `dart format` covers `lib test` only — **`example/lib` is outside the formatter
  gate.** Deliberate (the example is a demo, not published API), and recorded here
  so it is not later mistaken for an oversight.
- `flutter pub publish --dry-run` is the only gate that reads the archive — and
  because the root `.pubignore` **disables git-based file listing**, pub never
  consults git and therefore **never warns about uncommitted changes**. Measured
  2026-08-25: a tree with two modified files and three untracked paths passed with
  `0 warnings`. **A green dry-run is not evidence of a clean tree** — check
  `git status` separately before tagging.
- Anything that opens a window (`flutter run`) is **not** an agent gate — ask the
  user to drive and say what to look for.

**Back-edge to `implement`:** any command exited non-zero. **Bound:** three
consecutive failures with the same signature route to `decide` instead.

Then: branch → `feat|fix|refactor|test(<scope>): …` → PR (`Closes #issue`) →
**rebase-merge** (linear history, zero merge commits on `main`). **Tag only after
docs and example are in, and after checking open PRs and local branches** — 2.15.0
was tagged past an unmerged PR whose tree was broken for 3.10–3.12 users. Only an
*unpublished* tag is free to move. **`flutter pub publish` is irreversible; the
agent does not run it — the user does.**

---

## `search` — routing a candidate

Search **by the artifact** (the module, the field, the predicate, the config key),
never by the feature name. The trigger is *naming*, not deciding: search the
moment you can say which artifact a candidate touches, before any probe.

**Areas already carrying a decision record: none** — accepted or proposed.
`docs/adr/` does not exist yet, so **no area preempts an anchor** today. A
descriptive note (the module map above) does **not** preempt one either: it is
descriptive and lives in a file, while a roster is current state and needs a
mutable home.

**Tracker capability: GitHub, with parent/child sub-issues available.** So the
follow-up tree and the anchor's roster are **relations**, never prose — a `spawned
by` line in the body is the fallback for a tracker without the relation, never a
substitute for one that has it. Conventions live in
[`issue-tracker.md`](issue-tracker.md); labels in
[`triage-labels.md`](triage-labels.md).

The script owns the **query** and hands back candidates. The **conflict** out —
*"an existing issue whose proposal this change would break"* — is judgement and
stays on the main thread; a script that silently returns *"nothing"* for it has
mislabelled itself (invariant ④).

---

## `boundary` — the split

**UI-only, data-agnostic.** The package never stores or mutates table data.

- **Mechanism / core (this package owns):** synced scrolling; the single
  viewport-local drag-selection coordinate frame (`Listener` *outside* the body's
  horizontal `Scrollable`, so `event.localPosition` is viewport-local on both
  axes); the `RowLocator` port; `minWidth`/`maxWidth` `clamp()` in every layout
  path; merged rows; the tooltip-gating logic.
- **Policy / consumer:** the data and every operation on it, selection state, what
  a callback does. `rowId` is the caller's.
- **The seams:** the published package (pub.dev consumers) **and** the
  `../just_tooltip` / `../flutter_checkbox` membrane, which leaks **both ways** —
  when upstream raises a floor it lands on us (#69, 2.16.0), and when we change a
  contract the *rationale* a consumer wrote can quietly go false (`sweep`).

**Do not misdiagnose a contract as a defect.** When a consumer brings a "bug", the
first question is whose invariant broke. **Judging where to fix and reporting
upstream are separate duties** — a workaround that works well silences upstream
forever (#33, #88→#96).

**Out-edge to `stop`:** the urge to write a workaround here for a defect in a
deeper layer. Stop and come to the maintainer.

---

## `promote` — the record format

`docs/adr/` at the repo root, single-context, `NNNN-title.md` — declared in
[`domain.md`](domain.md), created lazily, currently empty. Trigger: **two or more**
of `thegraph`'s trigger list in one pass. One is bad luck. A record earns its
place by **deriving** decisions already taken, not by listing them. Promotion
closes the anchor and copies the roster **through the anchor's exclusion list** —
into the record's *context*, never into the record as a list.

---

## `downstream` — after release

The package publishes, so this node exists. **Derive the consumer list at that
moment and never store it:**

```
for d in ../*/; do grep -l 'flutter_table_plus:' "$d/pubspec.yaml"; done
```

In each consumer: raise the constraint, **remove the workarounds the fix made
unnecessary**, and flip the tests that pinned the old bug as expected. Leave any
workaround that was never bug-avoidance, and record *why* in a comment. A purely
additive release obliges consumers to do nothing — **say so explicitly**.

---

## Extraction plan

Generated artifacts are **thin**: this project's data only, method deferred to
`thegraph`. Each carries the build stamp above.

| Artifact | Node | Carries |
|---|---|---|
| `.claude/agents/ftp-source-fetcher.md` | `reference` | the 4 source classes, how each is reached, `summarized: none` |
| `.claude/agents/ftp-gap-lens.md` | `verify` #1 | corpora paths · the tie-breaker table · the 8-item divergence list |
| `.claude/agents/ftp-refute-lens.md` | `verify` #2 | the same, with the refuting stance in its brief |
| `.claude/agents/ftp-surface-sweeper.md` | `sweep` | the 9 surfaces and how each is read |
| `scripts/thegraph/sacred-diff.sh` | `verify` guard | the sacred-path list matched against the diff, **printing the patterns it evaluated** |
| `scripts/thegraph/gates.sh` | `gate` | the 5 commands, each invoked **bare** |
| `scripts/thegraph/cluster.sh` | `search` | the `gh` query by artifact, and the (currently empty) list of areas carrying a record |

**Script language: bash** (Git Bash, on `PATH`), `set -euo pipefail`.

**Never extracted** — invariant ①: `enumerate`, `boundary`, `implement`, `proof`,
`batch`, `stop`, `decide`, `promote`, `downstream`. They adjudicate, so they run
on the main thread.

---

## War-story index

The evidence that keeps every rule above from reading as an abstraction — #22,
#33, #38, #50–#52, #55, #58–#63, #65, #69, #88→#96, the 2.15.0 publish/tag
incident and the 2.16.0 floor-rise incident — lives in [`lessons.md`](lessons.md),
indexed by step. **Read it before starting.**
