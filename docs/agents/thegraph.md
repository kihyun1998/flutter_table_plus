# thegraph build (flutter_table_plus)

The compiled graph for the `thegraph` skill: **which nodes this repo has**, how
many, each one's guard and decider, and the artifacts generated for them.
`thegraph` holds the portable *method* (node-type catalog, four invariants,
reasoning habits); this file is its **contract** for this repo.

Per-incident evidence lives in [`lessons.md`](lessons.md); identity and
invariants in `CLAUDE.md`.

**Build stamp: `thegraph@3b21e3da2b66`** (SKILL.md sha256[0:12], 2026-09-03).
Every generated artifact carries it. When the stamp is behind, `thegraph` says so
and continues — it never rebuilds on its own.

**Run state:** `.thegraph/` at the repo root, append-only, git-ignored. It is a
cache; the GitHub issue is the durable record.

---

## Compile notes — the 2026-09-03 update (second)

An **update build**, and the first one whose findings all came from a slot the
assertions call green.

**`slot-authority.sh` printed `every derived slot agrees with its authority,
both directions` while three derived copies were wrong.** Each was a hand-copied
count, and each dodged the check for its own reason: L4's *"six fields"* was
spelled out, so the count guard's `[0-9]+` pattern never saw it; `place`'s
*"2 public / 13 internal"* and *"(10 / 5)"* sum to fifteen against sixteen files;
and `CLAUDE.md`'s *"9 gates"* is a third copy of a number this doc and the runner
both put at ten, which the check misses because it never reads `CLAUDE.md`. All
three are **deleted rather than corrected** — this doc already states, twice,
that rows carry no counts, and a better count-checker is an enumeration problem
answered with an enumeration.

**The build stamp had been wrong in two directions at once.** The header said
`8820d1293c04`, the compile notes below said `b7d8ca969712` "on all 10 generated
artifacts", and the measured value was **`3b21e3da2b66`** — so the doc disagreed
with itself *and* both values were behind. A stamp labels; it warns nobody. This
is the fifth consecutive build to find it behind.

**And it moved again during this build.** Measured `684a549ca5c2` early in the
session and `3b21e3da2b66` an hour later, same command and same path — the second
consecutive build to catch the catalog moving mid-run. The first stamp was
written into all eleven files before `slot-authority.sh` said `BEHIND` and the
value was corrected. **That is the check earning its place**: the number a human
measures by hand and carries across a session is exactly the kind that goes stale
between measuring and writing, and nothing but an assertion at write time can see
it.

**One gate was red on the first run and green on the second, with no edit
between.** `analyze` exited 1 while `pub get` was still resolving, then passed
alone and passed again in a full re-run. Recorded rather than shrugged off: #55's
lesson is that a gate which fails for reasons unrelated to the change is one
everybody learns to ignore, and a **flaky** gate reaches that destination by a
shorter road than a permanently red one. Not repaired here — one observation is
not a pattern — but it is now written down, so a second sighting is a second and
not a first.

**Divergence row 9 was three months expired, and it is the expensive kind.**
#135 shipped the by-value `rowId` compare and cleared the blocker that had
deferred it — `no-hand-enumeration.md` even recorded that *"that reason had an
expiry date the first one did not"* — and nobody reclaimed the sentence when the
date passed. It survived in four places: `row_measurement.dart` (a sacred path),
this doc's row 9, and **both generated lens briefs**, which told every `verify`
pass that a shipped guard was pending. A lens re-proposing `idsMatch` would have
been graded correct.

**Why nothing caught it, stated as a build fact rather than an apology.**
`slot-authority.sh` prints the divergence list under `unassertable, by design`.
That marking works — it announces a known hole — but announcing is not checking,
and the sentence sitting in the hole was `verify`'s own grading rule. **And the
row was mixed in class**: its conclusion is *decided* (we do not assert `rowId`),
while *"not switched on yet"* is *derived* from `lib/`. Slot-level classification
cannot reach a derived clause inside a decided slot, so no assertion could ever
have been written for it. That is a limit of 2b's granularity, recorded here
rather than worked around.

**Two sacred paths added**, both from incidents measured this session:
`text_overflow_detector.dart` (three call sites behind one file; #156's four
silent defects) and `table_header.dart` (#160's silent 2.0px header/body offset).
The list goes from fourteen to sixteen; the cost is a mandatory two-lens pass on
any diff touching either.

**Also this session, outside the build:** `check_map.py` gains a hub-reachability
check — it reported `clean` over 32 notes while an invariant note sat on disk
unlinked from the MAP's own roster, and the note that went missing was the one
#156 needed.

---

## Compile notes — the 2026-09-03 update (first)

An **update build**. The graph was the input, diffed against the repo. The
bindings were not read; they no longer exist.

**The stamp had moved, and it moved mid-session.** `SKILL.md` was
`2b3c8d4b5d03` when `/thegraph 155` started and `b7d8ca969712` when this build
ran — the catalog's own files are dated 2026-09-03 10:17 and 10:32. The
**node-type catalog and the state-slot table are unchanged**, so no node or slot
was added; what moved is the rules, and two of them are what this build is for.

| # | Slot | Was | Now |
|---|---|---|---|
| 1 | build stamp | `2b3c8d4b5d03` | `b7d8ca969712`, on all 10 generated artifacts |
| 2 | **slot roots** | **absent entirely** | a new `## Slot roots` section. `grill-the-graph` step 2b now requires every slot to record whether it is *derived* (a copy of a fact that lives elsewhere — never empty, fails by being silently wrong) or *decided* (the maintainer's judgement, nothing to check it against), and for a derived slot to name its authority |
| 3 | **`slot-authority.sh`** | **did not exist** | generated, and joined to the gate list. Every machine-readable authority is now asserted **both directions**. The values were all correct when checked by hand this build — 13 sacred paths resolve, 10 surfaces resolve, 9 artifacts present — which is exactly the condition under which nobody notices there is no check |
| 4 | `verify` sacred paths | 13 | **14** — `lib/src/widgets/cells/table_plus_cell.dart`. #155 routed the merged row through it, so a defect there now lands on every plain row *and* every group member. #156 already records two live ones in it |
| 5 | `sweep` surfaces | 10 | **11** — `docs/agents/lessons.md`, read differently from the other ten |
| 6 | `gate` commands | 9 | **10** |
| 7 | BG1 — `ftp-gap-lens` hand-copied `test/` at 57 | the tree said 59 | **cause fixed, not the number.** The no-copied-counts rule reached the graph doc and not the artifacts it emits. Extended: a generated artifact carries U2's *shape* and never its count |
| 8 | BG2 — `ftp-source-fetcher`'s `Runs:` named 4 commands | `peers` needs a 5th to read blobs | declaration widened. The node reported this itself, unprompted — the obligation invariant ① places on a node whose brief outruns its grant, working as written |
| 9 | BG3 — `gates.sh` called `tree-rule.sh` with no base ref | 0 paths considered after a commit; it passed vacuously | base ref passed. The script already accepted one |

**Two `build_gaps` from earlier runs were checked and are closed**: #101's (a
spine roster filed as prose) was resolved in that run by enrolling all twelve
through the sub-issues API, and #108's (four agents granted `Bash` with no
`Runs:` declaration) is closed by `agent-grants.sh` plus the one declaration that
now exists.

**What this build could not measure.** No copy of the old `SKILL.md` survives, so
*"what changed in `thegraph`"* is still not answerable by diff. What was compared
instead is the node-type catalog and the state-slot table, both quoted from the
current file and both unchanged, plus `grill-the-graph`'s own step list. That is
not the same thing, and this sentence is here so a later reader does not mistake
one for the other.

---

## Slot roots

**Every slot is one of two classes, and the class decides what can go wrong.**

A **derived** slot is a copy of a fact that lives somewhere else. Being a copy,
it is *never empty* — it fails by being **silently wrong**, and no node will
notice, because a node that receives a value uses it. That is why `build_gaps`
covers the smaller half of the problem: it fires on an empty slot, and a derived
slot is never empty. Two consecutive updates here carried in **zero**
`build_gaps` and both found real drift, all of it in derived slots.

A **decided** slot is the maintainer's judgement with no fact anywhere to check
it against. Those, and only those, are what a re-grill asks about.

**The authority is the fact, never a summary of it.** Where the fact is outside
this repository — another project's tree, a platform limit — the slot is derived
and **unassertable**; it says so, and the measurement is dated.

**A value and its existence are separate facts.** A path list can be a judgement
nothing can rank while every path in it is still a string that must resolve. The
two `— existence` rows below are that split applied: without them a rename empties
a guard and every copy of the list stays in perfect agreement about a file that
is gone.

| Slot | Class | Authority | Asserted |
|---|---|---|---|
| build stamp | derived | `sha256` of the installed `thegraph/SKILL.md`, first 12 | **yes** |
| tree rule — paths | derived | the tree | **yes** — `tree-rule.sh`, both directions |
| `gate` command list | derived | `scripts/thegraph/gates.sh` | **yes** |
| `search` record roster | derived | `ls docs/map/invariant/*.md` | **yes**, and derived at read time rather than stored |
| extraction plan | derived | the artifacts on disk | **yes**, both directions |
| MAP counts | derived | `ls docs/map/territory/*.md docs/map/invariant/*.md` | **yes** — and deliberately **not copied** into this file |
| war-story index | derived | `docs/agents/lessons.md` | **yes**, derived by grep rather than rostered |
| `promote` destinations | derived | `docs/map/invariant/` exists; `docs/adr/` declared in `domain.md` | **yes** |
| `downstream` — publishes | derived | `pubspec.yaml` | **yes** |
| sacred paths — existence | derived | each path resolves on disk | **yes** |
| `sweep` surfaces — existence | derived | each path resolves on disk | **yes** |
| `reference` siblings — existence | derived | `../just_tooltip`, `../flutter_checkbox` on disk | **yes** |
| `reference` peers — trees | derived | the peer repositories | **unassertable** — outside this repo, and stored as names only. Confirmed 2026-08-31 |
| `boundary` rule and seams | derived | `CLAUDE.md` | **no** — prose, not machine-readable. Stated rather than checked |
| sacred paths — value | decided | none. *Where a bug costs more than a wrong number* | no |
| `sweep` surfaces — value | decided | none. *Which docs describe behaviour here* | no |
| `reference` classes and routing | decided | none | no |
| `summarized:` flags | decided | none | no |
| layers, and the proof method per layer | decided | none | no |
| tautological traps | decided | none | no |
| tie-breaker per layer | decided | none | no |
| deliberate-divergence list | decided | none | no |
| `gate` blind spots | decided | none | no |
| U1 / U2 | decided | none — deliberately unresolved, and a guard that enforced one would ratify drift | no |

**`slot-authority.sh` asserts every row marked yes**, and carries the roster of
rows marked **no** so a slot cannot leave the map by going quiet. An unassertable
slot that announces itself is a known hole; one that says nothing is
indistinguishable from a checked one.

---

## Compile notes — the 2026-09-02 update (second)

An **update build**, the second today. The graph was the input, diffed against
the repo. The bindings were not read; they no longer exist.

| # | Slot | Was | Now |
|---|---|---|---|
| 1 | build stamp | `b188918a1bba` | `2b3c8d4b5d03`, on all 9 generated artifacts. It moved **twice** since the last build — `.thegraph/113.md` recorded `a277bd90e220` mid-run — making this the **fourth consecutive** build to find it behind. The catalog entry below is why |
| 2 | `place` → `docs/map/invariant/*.md` | `(6)` | the count is **gone**. It was 7: #113 (`70f45f9`) added `guard-the-destination.md` and updated `## map` from 6 → 7 **in the same commit**, leaving this row wrong from the moment the other was made right |
| 3 | `place` → `lib/src/utils/*.dart` | `(0/15 — clean)` | the count is **gone**; the `0` stays, because the `0` is the rule and the `15` was only its denominator. There were already **16** files at the build commit, so this one did not drift — it shipped stale |
| 4 | `tree-rule.sh` banner | `rules evaluated (17)` above **19** printed lines | it counts what it prints. `${#RULES[@]}` left out the two `FREE_PREFIXES`, which are rules and are evaluated. The same treatment goes to U1/U2's hardcoded `3` and `57`: measured at run time now |
| 5 | `promote` · `search` | `docs/adr/` alone · *"areas carrying a record: none"* | **two destinations, split by scope** — a rule that holds across territories goes to `docs/map/invariant/`, a single-context decision to `docs/adr/`. So `search`'s roster is no longer empty: it is the 7 invariant notes. Maintainer's call, 2026-09-02 |
| 6 | everything else | — | **no drift, measured.** 13 sacred paths present · 10 surfaces present, `CONTEXT.md` and `docs/adr/` still absent · both siblings at `../`, the consumer derive returns empty · MAP 23 territories, its gate clean · `test/` still flat · `tree-rule.sh` and `agent-grants.sh` exit 0 · `gates.sh` runs 9, each bare · **the roster is unchanged** — nothing in the repo moved a count |
| 7 | Schema coverage | 0 unowned | **0 unowned.** `BUILD_CONTRACT.md` is byte-identical to the last walk; re-walked rather than assumed, because the walk is once per *build*, not once per contract change |

**Rows 2–4 are one defect, and this is its third recurrence in this file.** The
last build wrote *"a count restated in two places drifts in exactly one of them"*
and applied it to the **roster alone**. It never swept its own file for the rule
it had just written — and two counts inside that same file were wrong within the
day, one of them already wrong when the sentence was written. So the counts are
**deleted rather than corrected**: `tree-rule.sh` carries none of them and stayed
right through both. A newly written rule is itself a hit, and it is the one most
often spent on its own instance.

**`build_gaps`: none outstanding**, read first as the drift detector.
`.thegraph/113.md` is the newest flush and the last build did not cite it — it
cited `109`, which `113` supersedes. `113` flushed `build_gaps: none` and
`catalog_gaps: none new`; no open issue holds one. Its two recorded compliance
misses — `classify`'s open-decision route skipped, and a recommendation attached
to a `decide` option before the maintainer had reached one — are wrong **runs**,
not wrong build values, and stop short of `build_gaps` for the same reason
`101`'s spine roster did.

**`catalog_gaps`: the same one, recurring exactly as predicted.** The stamp is
`SKILL.md`'s sha256, so it moves for **any** byte in that file; `113` watched it
move for a frontmatter flag carrying no method at all. It stays filed against the
catalog's own tracker rather than here — a re-grill of this repo would not stop
it, and it recurs in every repo that compiles this graph. Four builds behind in a
row is what that costs, and a stamp that moves without the method moving trains a
reader to ignore the one warning `thegraph` gives at startup.

**What this build could not measure.** No copy of the old `SKILL.md` survives, so
*"what changed in `thegraph`"* is again not answerable by diff. The coverage check
in row 7 is what was run instead. It is not the same thing, and this sentence is
here so a later reader does not mistake one for the other.

---

## Node roster

| Node | Count | Why this count |
|---|---|---|
| `classify` | 1 | catalog |
| `spine` | 1 | GitHub sub-issues are live here (`gh api repos/{owner}/{repo}/issues/N/sub_issues` returns `[]`, not 404) — the roster is a **relation**, never prose |
| `map` | 1 | the MAP — [`docs/map/`](../map/README.md). Its size is stated in `## map`, not here |
| `reference` | 5 | the routing table's rows naming an external source (below) |
| `enumerate` | 1 | catalog · never delegated |
| `boundary` | 1 | catalog · never delegated. The seam is the published package plus the `../just_tooltip` / `../flutter_checkbox` membrane |
| `place` | 1 | catalog, unconditional — nothing in the input settles whether it exists. What the input settled is the **tree rule** (below) |
| `implement` | 3 | one per layer |
| `proof` | 3 | one per layer |
| `verify` | 2 | 1 gap-hunter + 1 refuter, bought by a non-empty sacred-path list |
| `sweep` | 1 | fanning out over the surface list below |
| `gate` | 1 | the only gates — there is no CI. The command list is below, and states its own count |
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
Territory notes and cross-cutting invariant notes, indexed by *what the system
does* rather than by the event that produced them. **How many of each is the
MAP's fact, not this file's** — `ls docs/map/territory/*.md docs/map/invariant/*.md`.
The number used to be written here and #113 had to come back and correct it in
the same commit that changed it; the copy in `CLAUDE.md` is the maintainer's to
retire the same way.

This node used to carry a hand-written module table. It does not any more, on
purpose: a second copy of the same answer is somewhere for the two to disagree,
and the MAP is now the only place it lives. Open the territory your change
enters, and read its `## Blast radius` as a **checklist** — each linked territory
gets opened. Finding nothing to change in one is a correct outcome; not opening
it is the failure the layer exists to prevent.

The MAP's own gate is `python scripts/map/check_map.py docs/map` — links,
anchors, symbol names, file attribution, section sets, and invariant reciprocity.
It is now in the `gate` command list, where it belongs; naming it only here is
how it stayed out of every gate run.

**It checks attribution, not location.** `resolve_dart` searches
`lib/src → lib → example → .` in order, so a `.dart` path in a territory note
resolves wherever the file actually sits. The MAP therefore cannot enforce the
tree rule, and `place`'s guard does not duplicate it.

---

## `reference` — 5 source classes, none summarized

Every class is read as **raw source**, so any of them can produce a `CONFIRMED`
finding. Read whole files, then grep the actual lines; never a summarizing fetch.

| Class | Where | Read for |
|---|---|---|
| `siblings` | `../just_tooltip`, `../flutter_checkbox` — **source + CHANGELOG**, not pub docs | tooltip arbitration, checkbox behavior, and any `environment:` / floor change in their changelogs. Same author, each with its own tracker: fix there what belongs there |
| `sdk` | Flutter SDK source | rendering, gestures, coordinates, scroll physics |
| `peers` | `flutter/packages` → `packages/two_dimensional_scrollables` · `bosskmk/pluto_grid` · `maxim-saplin/data_table_2` | layout prior art for `place`. **Named, never stored** — read the repository's real tree (`gh api repos/OWNER/REPO/git/trees/BRANCH?recursive=1`), never a write-up about one. Confirmed by the maintainer 2026-08-31, who deliberately excluded this author's own packages so shared habits would surface as differences rather than as agreements |
| `consumer` | the reporting repo, derived on the spot from `../*/pubspec.yaml` | any downstream bug claim — verify, do not assume |
| `registry` | `https://pub.dev/api/packages/flutter_table_plus`, and `archive_url` for the published tree | publish state, which is **queried, never assumed**; identify the published commit by unpacking the archive and diffing against `git show <commit>:<path>` with `tr -d '\r'` (archive is CRLF, git blob is LF). If *all* candidates fail — or all pass — suspect the checker |

**summarized: none.**

To pin a runtime fact (a coordinate, a call order, an emitted event), instrument a
throwaway probe, read the number, delete the probe, and record the number in the
issue. Reading the code is not observing what it does.

---

## `place` — the tree rule

**Decider: AI. Never delegated.** This node runs **before `implement`**: a file
written to the wrong directory breaks the seam while producing no error, no
failing test, and no warning, and reading the rule after the tests are green
means everything it would have told you arrives as rework.

Established 2026-08-31 by `plat` against the three confirmed `peers` above, read
at full depth via the git-trees API. **No layout rule was declared anywhere** —
`CLAUDE.md` states identity, not directories, and the MAP checks attribution
rather than location — so induction was the only input, and `plat`'s
*"a declaration outranks the tree"* never fired.

### The rule, as concrete paths

```
lib/flutter_table_plus.dart      the barrel — the only public entry point.
                                 A new public symbol is exported here or it is not public.
lib/src/models/*.dart            value types the consumer constructs and passes in
lib/src/models/theme/*.dart      theme value types
lib/src/utils/*.dart             computation that does not know the widget tree.
                                 No Widget subclass — measured, and clean.
lib/src/widgets/*.dart           widgets, or collaborators only a widget uses
lib/src/widgets/cells/*.dart     cell widgets a body row draws
test/*.dart                      tests. Flat — no subdirectories
benchmark/*.dart                 standalone benchmarks. Outside every gate, excluded from the archive
example/lib/**                   the example, a package of its own
example/test/**                  the example's gate (#55)
docs/*.md                        public prose — THEMING, FEATURES, MIGRATION
docs/map/README.md               the MAP's entry point
docs/map/territory/*.md          MAP territory notes
docs/map/invariant/*.md          MAP cross-cutting invariant notes
docs/agents/*.md                 agent bindings
scripts/thegraph/*.sh            generated scripts (bash)
scripts/map/*.py                 the MAP gate (python)
scripts/fonts/*.py               one-off asset tooling (python)
.claude/agents/ftp-*.md          generated agents
```

Everything outside those roots — `pubspec.yaml`, `CHANGELOG.md`, `README.md`,
`LICENSE`, `analysis_options.yaml`, `.pubignore`, `coverage/`, `build/`, and
`example/`'s platform scaffolding — is **out of scope**, not unruled. The tree
rule assigns ownership inside the roots it names; it does not adjudicate where a
manifest goes. `tree-rule.sh` counts those files and checks nothing about them.

**The rows carry no file counts, deliberately.** They used to — `(5/5 exported)`,
`(0/15 — clean)`, `(23)`, `(6)` — and two of the four were wrong inside a day: the
invariant count the moment #113 added a note, the `utils` count before the build
that wrote it had even finished. The tree is the authority for how many files are
in it, `tree-rule.sh` reads the tree, and a number copied out of it here is a
second answer with nowhere to be checked. What survives is the part that is a
**rule** rather than a measurement: `lib/src/utils` holds no Widget subclass.

**Four of the rows above came from auditing the rule against the whole tree
rather than from the peer comparison** — `benchmark/`, `docs/*.md`,
`docs/map/README.md`, and `scripts/fonts/*.py` all exist and none was named until
the rule was run over what is actually on disk. A rule that has never been
matched against the tree it describes is a rule with unmeasured holes, which is
why `tree-rule.sh` carries an `--audit` mode.

**The `utils` / `widgets` axis is *widget-awareness*, not Widget-subclass-hood.**
Four axes were sorted by content and only this one came out clean. Exported-ness
does not sort them; importing Flutter does not; holding mutable state does not —
`overflow_cache.dart` is stateful and stays in `utils/` because it does not know
the widget tree.
That is the rule, not drift. Equally, `drag_selection_controller.dart` stays in
`widgets/` though it is not a Widget: `CLAUDE.md`'s *"unit-testable in isolation"*
is a claim about testability, not about location.

### Unclassified — reported, not resolved

`plat` forbids settling these by majority; a difference nobody decided is drift
wearing a rule's clothes, and the guard script does **not** check them.

- **U1 — `widgets/cells/` (3) vs `widgets/table_header_cell.dart`.** All four are
  `StatelessWidget` cells. The only axis that splits them is the consumer: a body
  row draws the first three, the header draws the fourth.
- **U2 — `test/` is flat.** The peers split 2:1 —
  `two_dimensional_scrollables` mirrors `lib/src`, `pluto_grid` splits by
  scenario, `data_table_2` is flat like us.

### Guard and edges

**Guard mechanism: `scripts/thegraph/tree-rule.sh`, a match over the diff** — not
a recollection. **`gate` passes it a base ref and `place` does not**, and that
asymmetry is the whole of it: before `implement` the work is uncommitted and the
working tree *is* the diff, while at `gate` the work is committed and a
base-less run considers **zero paths and passes**. Measured 2026-09-03 — the
same script read 0 paths after the commit and 14 against `main`. Prose alone would make this node a bar with no firing mechanism,
which is the exact defect its own argument is against. It runs twice: here,
before `implement`, and again in `gate` over the final diff.

**Out-edge to `decide`. Guard:** the change needs a new top-level area, or the
rule and the peers disagree and the tie-breaker does not settle it. Both are
structure calls.

**Writes `triggers`** when the same placement is argued twice. A tree rule that
keeps being re-decided is a record waiting to be written, and `promote` counts it.

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
| `lib/src/models/theme/**` | a field can be dropped **silently** — no test breaks, and `scaledBy(1.0)` hides it (#50, #116) |
| `lib/src/widgets/drag_selection_controller.dart` | the auto-scroll `Timer` and the gesture state machine — a leak keeps scrolling in the consumer's app |
| `lib/src/widgets/row_locator.dart` | the port both sides of drag-select agree on |
| `lib/src/widgets/synced_scroll_controllers.dart` | the single-coordinate-frame invariant; break it and every drag coordinate is wrong by an offset |
| `lib/src/widgets/flutter_table_plus.dart` | where edit commits and selection callbacks cross into the **consumer's data** |
| `lib/src/widgets/row_geometry.dart` | drag-select hit-testing reads row geometry, and #128 records that it has **never** been exercised against changing row heights |
| `lib/src/widgets/table_body.dart` | it caches measured row heights; #120 shipped stale ones when `calculateRowHeight` changed identity |
| `lib/src/widgets/table_plus_merged_row.dart` | it owns the height distribution — each member's extent, and which cell absorbs the group's bottom border. #121 shipped every measured height computed and discarded, through 2.16.1 |
| `lib/src/utils/table_row_height_calculator.dart` | a **public API** (exported from the barrel) that every row's geometry is derived from |
| `lib/src/utils/row_measurement.dart` | the **one** list both height caches consult. It is a hand-maintained enumeration Dart cannot derive, so a forgotten fourth input stales the `RowGeometry` every drag hit-test reads *and* the total that decides whether a scrollbar appears — the #120/#128 failure with the two lists collapsed into one site. #137 then measured its `identical` guard wrong, and wrong **differently in JIT and AOT** |
| `lib/src/utils/row_cache_invalidation.dart` | the **response** half of the same rule `row_measurement.dart` holds the inputs for: which caches an update invalidates, for both widgets that hold any. Unifying the predicate and leaving each caller to decide what to drop was half a repair and the halves drifted — the body split structural from measurement-only and the parent did not, so a `scale` change rebuilt a `RowLookup` no scale can move, and the asymmetry survived #120, #128, #132 and #135 (#169). `structural` must dominate `measurementOnly` or a list sorted in place is reported as a height change |
| `pubspec.yaml` | a false floor breaks users' trees while `pub get` still succeeds here (#69); a dep's floor rise is BREAKING for us even with `lib/` untouched (2.16.0) |
| `CHANGELOG.md` | pub.dev snapshots at publish — a published entry edited in place splits the repo from the registry (2.15.0) |
| `.pubignore` | it decides the archive's contents, and the archive **cannot be un-published** |
| `lib/src/widgets/cells/table_plus_cell.dart` | #155 routed the merged row's members through it, so one defect here lands on **every plain row and every group member** at once. #156 already records two live ones in it: the overflow width ignores the divider's own inset, and the detector never reads `MediaQuery.textScaler`. Added 2026-09-03 — this run's derivation, the maintainer having delegated the call rather than ratified it |
| `lib/src/utils/text_overflow_detector.dart` | all **three** overflow call sites go through it — the ordinary cell, the header cell, and the merged row's spanning cell — so a defect here is three at once. #156 found four, every one silent, and the largest was named by neither the ticket nor the first adversarial pass. A diff that changes only this file touches no other sacred path, which is how those four reached release |
| `lib/src/widgets/table_header.dart` | a caller's `headerTheme.decoration` is applied to the box wrapping the whole header, and the body has no equivalent box. One border slid every header column against its body column — measured 2.0px, no exception, no banner — and what it broke is the alignment `CLAUDE.md` names as core (#160). The failure mode here is a silent offset, which no test that does not compare the two rects can see |

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

**Where each pass's tree comes from: the repo working tree, read-only, and both
passes may run concurrently against it.** Neither lens is granted a shell, so
neither can mutate what the other is reading — which is what makes concurrency
safe here rather than a scheduling gamble.

This is the answer to the `build_gaps` entry #131 and #132 both flushed. It cost
a real adjudication to find: two lenses that *could* write ran in parallel, one
applied four mutations to `lib/` while the other was reading it, and the refuter
— the one node whose whole purpose is to be believed when it dissents — graded
the run `UNADJUDICATED` on evidence that was an artifact of its counterpart. It
was reasoning correctly from inside what it could see. **A `git worktree` per
lens would also have fixed it, and would have been the wrong fix**: it arranges
isolation around a capability no brief ever asked for. Removing the capability
removes the need for the arrangement.

**Turning a fix off to see a test redden is `proof`'s act, on the main thread.**
It is a mutation, invariant ① keeps mutations off delegated nodes, and a lens
that spots a test which cannot fail reports *that* — it does not go and prove it
by editing `lib/`.

---

## Tie-breaker — per layer

What wins when prior art and this project's own evidence disagree.

| Layer | Who wins |
|---|---|
| coordinates, gestures, scrolling | **Flutter SDK source** — and source plus a probe's number, never the doc comment |
| public API shape, theming, feature scope | **this repo's measurement + `CLAUDE.md`'s identity.** UI-only / data-agnostic is not a call prior art gets to reverse |
| tooltip / checkbox integration | **`../just_tooltip` · `../flutter_checkbox`'s contract.** If the contract is wrong, fix it **there** — no workaround here (#33, #88→#96) |
| versioning, publishing, semver | **the pub / Dart convention.** A dependency floor rise is BREAKING even when `lib/` is untouched (2.16.0) |
| directory ownership | **this repo's measured sort**, then the confirmed `peers`. A peer's layout answers *their* boundary: `two_dimensional_scrollables` splits `lib/src` by feature because it ships two widgets, and that reason does not transfer to a package shipping one |

---

## Deliberate divergence — arguments that are already over

The tie-breaker says who wins an argument; this says which arguments are closed.
`verify`'s restatement test is checked against this list. Rows 1–8 are the
project's; **L1–L4 are `plat`'s layout rows** — one list, two contributors.
A run-scoped `human` entry from an issue contract is a *third* contributor, and
is passed **in the invocation**: a generated artifact is built once and cannot
carry a row that changes per run.

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
   went missing at the root, and five `CheckboxStyle` fields one level down. — #50, #116
7. **Widget observation happens at the screen** — `byIcon` over `byType`. — #62
8. **Assert counts, not names.** — #59
9. **`rowId` is deliberately unguarded.** Identity is a `(data, rowId)` *snapshot*
   contract the caller owns, and the package does not assert it — measured, not
   assumed: the guard's technique cannot reach `rowId`, because `rowId` is
   *required*, so every call site writes an inline closure and the cost becomes
   one cache rebuild per build per caller. **Comparing its answers rather than
   its identity shipped in #135**: `RowLookup.idsMatch` re-derives the ids
   through the current `rowId` and both `didUpdateWidget`s call it — measured
   2026-09-03, deleting that term from the two call sites reddens four tests in
   `merged_group_data_disagreement_test.dart`, though no test names `idsMatch`.
   The **order** was the finding: switched on alone it would have traded an
   in-place `RangeError` for a silently missing row, so `computeRenderableIndices`
   was fixed first and the guard second. A finding that proposes the assert is
   still `DELIBERATE`; one that proposes the by-value compare is **re-proposing
   shipped code**, not reviving a deferral, and is graded as such. What the
   caller's contract still covers is the residue no comparison of `rowId`'s
   answers could reach: an element replaced in place under the same id, and
   `mergedGroups` mutated in place. — #132, #135, #137
10. **L1 — `lib/src` is split by layer, not by feature.** `two_dimensional_scrollables`
   splits by feature because it ships two widgets (`TableView`, `TreeView`). We ship
   one, so the axis does not transfer. Judged on role, this is not a difference at
   all. — plat 2026-08-31
11. **L2 — the example lives at `example/`, not `demo/`.** pub.dev gives `example/`
    its own tab. `pluto_grid` uses `demo/` and loses it. — plat 2026-08-31
12. **L3 — `example/test/` is a gate.** Of the three peers only
    `two_dimensional_scrollables` has example tests at all. — #55, plat 2026-08-31
13. **L4 — the `utils` / `widgets` axis is widget-*awareness*.** Not
    Widget-subclass-hood, not exported-ness, not statefulness — those three were
    sorted by content and none came out clean. So `overflow_cache.dart` stays in
    `utils/` though it holds state, and `drag_selection_controller.dart` stays in
    `widgets/` though it is not a Widget. — plat 2026-08-31

---

## `sweep` — 11 surfaces

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
| `docs/agents/lessons.md` | **the one surface read for a different question.** The other ten are read for *which sentence did this change make false*; this one for *does the war-story this change produced exist here*. An incident record is append-only, so a change never falsifies it — it leaves it incomplete, which no drift pattern can see. Missed during #155 by a sweep that walked all ten others |
| the **cluster anchor** | this is `spine`'s flush, not a separate obligation: the root confirmed or falsified, the numbers measured, any new sibling **enrolled as a sub-issue**, what is still open. The roster never goes in the body |

**Judge a sweep by what it cannot see, never by its hit count.** When a hit turns
up, widen the pattern with the phrasing that produced it *before* fixing the hit.

**One surface is read with a different question, and that is why it is here.**
The other ten are read for *"which sentence did this change make false"*.
`docs/agents/lessons.md` is an incident record: it is append-only, so a change
never falsifies it — it leaves it **incomplete**. It was missed for exactly that
reason during #155, by a sweep that walked all ten other surfaces and had no row
telling it to look.

**Glossary and decision trail:** `CONTEXT.md` and `docs/adr/` do not exist yet
(created lazily). Nothing to sweep there until they do — and creating one is a
`promote` act, not a sweep act.

---

## `gate` — 10 commands, each run bare

**There is no CI.** These are the only gates, and they run on this machine — the
Flutter SDK is on `PATH`, so run them; do not ask. (`thegraph`'s "name the CI
workflow the list derives from" clause is **N/A** here: there is no second copy to
drift from. If CI is ever added, this list becomes a third copy and must assert
against it.)

```
flutter analyze                                      # 0 issues
dart format --output=none --set-exit-if-changed lib test
flutter test
flutter analyze          (in example/)               # the example is a gate
flutter test             (in example/)               #   - and it is two gates, not one
python scripts/map/check_map.py docs/map             # the MAP's own gate
scripts/thegraph/tree-rule.sh <base>                  # the tree rule, over the final diff
scripts/thegraph/agent-grants.sh                     # every generated agent's tool grant
scripts/thegraph/slot-authority.sh                   # every derived slot, against its authority
flutter pub publish --dry-run                        # only when the version is ahead
                                                     # of the registry - see below
```

**The count is stated once, here, and `gates.sh` must report the same number.**
It did not: this doc said *seven* because it counted `cd example && flutter
analyze && flutter test` as a single line, while the script — correctly — ran two
bare commands and printed two labels. A doc that writes a gate as an `&&` chain
is teaching the exact shape the rule below forbids, in the file that states the
rule.

**Each runs bare, never piped** — a pipeline's exit status is the last command's,
so `test … | tail -1 && commit` always commits. A gate you cannot fail is not a
gate. **Never move a threshold to turn a build green.**

**`publish:dry-run` runs only when it can mean something.** The dry-run validates
the archive, but it also insists the version is an *increment* over what is
published — and between releases `pubspec.yaml` sits **at** the published
version, so the gate was red for every change that was not a release. A gate
that is always red is a gate everyone learns to ignore, which is #55's lesson
about the example suite arriving at the same destination.

So the script asks the registry first and compares. Version equal to the
published latest → the gate reports **N/A with the reason on screen**, never a
quiet pass. Version ahead, or the registry unreachable → it runs unchanged and
its failure is fatal. This is not a lowered threshold: measured 2026-08-25, with
the version bumped to an unpublished one the gate ran and failed exactly as
before.

### Known blind spots

- `example/` is **outside** the top-level `flutter test` — its own manifest, its
  own analyzer run. A leftover `flutter create` counter template once kept it
  permanently red, which trains everyone to ignore it (#55).
- `dart format` covers `lib test` only — **`example/lib` is outside the formatter
  gate.** Deliberate (the example is a demo, not published API), and recorded here
  so it is not later mistaken for an oversight.
- `flutter pub publish --dry-run` is the only gate that reads the archive. It
  **does** report uncommitted changes to files that are *inside* the archive — measured
  2026-08-25, it named a modified `example/lib/pages/home_page.dart`. What it cannot
  see is anything the root `.pubignore` excludes (`docs/`, `scripts/`, `benchmark/`
  …), because a root `.pubignore` turns off git-based file listing for those paths.
  An earlier note here said it saw nothing at all; that measurement's modified files
  were themselves inside excluded paths. **A green dry-run is still not evidence of a
  clean tree** — check `git status` separately before tagging.
- `check_map.py` verifies **attribution, not location**: `resolve_dart` searches
  `lib/src → lib → example → .`, so a moved file still resolves. The tree rule is
  `tree-rule.sh`'s job, and the two do not overlap.
- `tree-rule.sh` deliberately does **not** check `place`'s unclassified rows U1
  and U2 — an undecided difference is not a rule, and a guard that enforced one
  would be ratifying drift. It prints them as a banner instead.
- `agent-grants.sh` asserts the **default**, never the claim: it asks whether a
  generated agent holds a write-capable tool and whether its brief declares a
  command naming that tool. It does **not** look for the words *"read-only"* — an
  agent granted a shell whose description read *"proposes edits rather than making
  them"* passed a check that did, which is the enumeration problem in another
  costume. It cannot see the opposite error either: a **brief wider than its
  grant** is the caller's mistake, made at invocation time against a static file,
  and what stands in for a check there is the delegated node's obligation to say
  what its brief named and it could not reach.
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

**Areas already carrying a decision record: the MAP's cross-cutting invariant
notes.** `docs/adr/` is still empty, so the accepted-record roster is exactly
`docs/map/invariant/*.md` — derived, never listed here:

```
ls docs/map/invariant/*.md
```

A candidate whose root is one of those areas does **not** get a second anchor; it
gets a comment on the note's cluster. **A territory note still preempts nothing** —
the discriminator is not which directory the file sits in but whether it was
*promoted*: a cross-cutting note derives decisions already taken and prescribes,
a territory note describes what one area does. Only the first is a record.

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

**Two destinations, split by scope** — confirmed by the maintainer 2026-09-02,
against the evidence that the only promotion which has ever run did not go where
this node said it would.

| Scope | Destination | State |
|---|---|---|
| a rule that holds **across territories** — the sites do not call each other and do not look alike | `docs/map/invariant/NNN.md`, a MAP cross-cutting invariant note, reciprocally linked from every territory it names and checked by the MAP gate | **in use.** `guard-the-destination.md` was promoted this way on two triggers in one pass (#110 · #113 · #123) |
| a decision **inside one context** — an interface, a convention, a trade-off with a single home | `docs/adr/NNNN-title.md` at the repo root, single-context, declared in [`domain.md`](domain.md) | created lazily, **still empty** |

The trigger and the bar are the same for both: **two or more** of `thegraph`'s
trigger list in one pass. One is bad luck. A record earns its place by
**deriving** decisions already taken, not by listing them. Promotion closes the
anchor and copies the roster **through the anchor's exclusion list** — into the
record's *context*, never into the record as a list.

**The scope question is answered by grep, not by taste:** does the fact hold at
any site sharing the same dimension, coordinate frame, sibling dependency, or
test fixture? That is `verify`'s way-out question, and a `yes` is what makes the
record cross-cutting. A note that is merely *descriptive* of one territory is not
a promotion at all — it is `sweep`'s work, and it preempts nothing.

`place` can now feed this: it writes `triggers` when the same placement is argued
twice, and the unclassified rows U1 and U2 are the two likeliest sources.

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

Generated artifacts are **thin**: this project's data only, method deferred. Each
carries the build stamp above. An artifact never names *where* a method lives — a
method may move between `thegraph` and a sibling skill, and an artifact holding
only data slots is indifferent to that move.

| Artifact | Node | Tools | Carries |
|---|---|---|---|
| `.claude/agents/ftp-source-fetcher.md` | `reference` | `Read, Grep, Glob, Bash` | the 5 source classes and how each is reached, `summarized: none` |
| `.claude/agents/ftp-gap-lens.md` | `verify` #1 | `Read, Grep, Glob` | corpora paths · the tie-breaker table · the 13-row divergence list · the frontier |
| `.claude/agents/ftp-refute-lens.md` | `verify` #2 | `Read, Grep, Glob` | the same, with the refuting stance in its brief |
| `.claude/agents/ftp-surface-sweeper.md` | `sweep` | `Read, Grep, Glob` | the 10 surfaces and how each is read |
| `scripts/thegraph/sacred-diff.sh` | `verify` guard | — | the 13 sacred paths matched against the diff, **printing the patterns it evaluated** |
| `scripts/thegraph/tree-rule.sh` | `place`, and `gate` on the final diff | — | the tree rule as a path list matched against the changed paths; the `utils/` Widget-subclass check; U1/U2 printed as **not checked** |
| `scripts/thegraph/gates.sh` | `gate` | — | the 9 commands, each invoked **bare** |
| `scripts/thegraph/agent-grants.sh` | `gate` | — | every generated agent's grant, asserted against the read-only default |
| `scripts/thegraph/cluster.sh` | `search` | — | the `gh` query by artifact, and the areas carrying a record — **derived** from `docs/map/invariant/`, never listed in the script |

**A grant is derived from the brief, never defaulted, and read-only is the
default rather than a claim to be matched.** Three of the four agents read and
nothing else, so they carry no tool that can write. `ftp-source-fetcher` is the
one exception, and it declares what it runs in the form invariant (1) fixes —
naming each tool, because a declaration that names none licenses nothing:

> **Runs:** `Bash`, for four things and no others — `gh api .../git/trees/...`
> (a peer's real tree), `curl https://pub.dev/api/...` (registry state),
> `tar -xzf` (the published archive, which `Read` cannot decompress), and
> `git show <commit>:<path>` piped through `tr -d` (the CRLF-vs-LF diff).

**A brief may only name what its grant can reach.** The previous build's fetcher
brief told the agent to *"write a throwaway probe, print the number, delete the
probe"* — a write, from a node holding no write tool, dischargeable only through
a shell nobody had declared. **Probing moves to the main thread**, which is where
invariant (1) already puts work that is not reading, and the measured number is
passed in the invocation. That is the same direction the invariant records for
the archive-unpacking case, arrived at here from the opposite end.

**Script language: bash** (Git Bash, on `PATH`), `set -euo pipefail`. The MAP gate
is python and stays python — it is not a generated artifact.

**The grant check is generated *with* the agents, deliberately.** A rule this
file states and nothing reads is the same defect as a read-only claim nothing
enforces, one level up. `agent-grants.sh` joins the `gate` command list like any
other gate, and that is what makes the rule above a check rather than a
paragraph.

**Never extracted** — invariant ①: `enumerate`, `boundary`, `place`, `implement`,
`proof`, `batch`, `stop`, `decide`, `promote`, `downstream`. They adjudicate, so
they run on the main thread.

---

## Schema coverage — 0 unowned

The check runs **once per build**: walk *"What the build must supply"* and confirm
each entry sits on one side of `thegraph`'s invariant / build / issue split. A slot
the schema asks for and the split places on neither side is `unowned` —
answerable, answered correctly by every build that ever ran, and named by nobody.
Being answerable is exactly what lets it pass unnoticed.

**This build: zero.** Every slot is answered here and every one is placed. The
previous build's transition table has been **removed**, on its own instruction —
it existed to record four slots moving from `pending` to placed, and a build with
nothing to say here is exactly the condition it named for its own deletion. The
lesson it carried is the one worth keeping and it is one sentence: **placing a
slot changes no build.** The four rows were already filled and already correct;
what was missing was the sentence saying who answers them, and a missing sentence
is the one kind of gap that leaves the work looking finished.

**A passing check leaves no trace, and that is deliberate.** There is no per-slot
owner column anywhere in this file. Which side of the split owns a slot is
`thegraph`'s fact rather than this project's data, and a column of them would be
stale the day `thegraph` re-places one — the staleness the thin-artifact rule
exists to buy immunity from.

**Not a schema gap, and tracked elsewhere:** whether two lenses that *can* write
may share a working tree. It is a catalog question (`kihyun-skills#19`), not a
slot, so it gets no `pending` marker here — the exposure was removed rather than
waited on. See `verify`'s second-lens section.

---

## War-story index

The evidence that keeps every rule above from reading as an abstraction lives in
[`lessons.md`](lessons.md). **Read it before starting.**

**No roster of issue numbers is kept here.** A hand-copied one drifts the moment
lessons grows, and then argues with the file it points at — this list claimed
#114 … #138 while `lessons.md` had stopped at #96, and a reader copied the claim
onward before checking it. Derive it instead:

```
grep -o '#[0-9]\+' docs/agents/lessons.md | sort -u -V
```

An inline `(#33, #88→#96)` hung on a specific rule above is *evidence*, not a
roster: it names why that rule exists and does not go stale when lessons grows.

The war-stories this build turned on:

- **the count-restatement, third time in this file** — `(6)` wrong the moment a
  sibling line was made right, `(0/15)` wrong before the build that wrote it
  finished, `rules evaluated (17)` printed above 19 rules. The rule against this
  was written by the previous build and applied only to the roster: a newly
  written rule is itself a hit, and the corpus it is least often swept against is
  its own.
- **#110 → #113 → #123** — the promotion that went somewhere this node did not
  name. Three sites where a guard asserted at the source and passed anything that
  reached the destination another way, and the record for it landed in
  `docs/map/invariant/` while `promote` still said `docs/adr/`. A record format
  nobody writes to is indistinguishable from one nobody needs.

- **#131 → #132** — two lens agents holding a shell no brief asked for, mutating
  one shared tree, and the refuter grading a run `UNADJUDICATED` on evidence that
  was its counterpart's artifact. The grant, not the claim, is the license.
- **#135** — `data` and `mergedGroups` disagreeing silently, with one path
  crashing rather than answering stale.
- **#137** — a guard justified by a hazard nobody had measured, and `identical`
  answering **differently in JIT and AOT**. A wrong rationale breaks no test.
- **#138** — `example/README.md` still the `flutter create` template, on a
  package whose example is now a recipe browser: #55's shape, on a new surface,
  three years of surfaces later.
