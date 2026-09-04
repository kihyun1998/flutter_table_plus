# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) follow the **`thegraph`**
skill — run `/thegraph` at the start. The skill carries its own nodes, guards and
deciders. **`docs/agents/thegraph.md`** carries only what the skill cannot know and
no file here answers: **the outside sources this package is read against, and
whether each one binds.** Everything else a run needs is read from the repository
itself rather than from a second copy of it — that document held one for months,
and the copies went stale on their own, three times inside the file. The
per-incident evidence lives in **`docs/agents/lessons.md`**. Read both before starting; add new
war-stories to lessons. **Neither file keeps a roster of issue numbers** — a
hand-copied one drifts the moment lessons grows; grep `lessons.md` for the
current set.

**Before drawing a boundary, read the MAP — [`docs/map/README.md`](docs/map/README.md).**
Territories and cross-cutting invariants, indexed by *what the system does*
rather than by the event that produced them. **How many of each is the MAP's own
fact and is not copied here** — the same reason the issue roster above is not,
and it drifted the same way: the invariant count was corrected in `## map` and
left wrong four lines from a paragraph forbidding exactly that. Open the
territory your change enters and treat its `## Blast radius` as a checklist. On
the way out, ask whether the fact you just found is true outside that territory —
if it is, an invariant note is part of the change.

Two invariant notes are read **before** the work rather than during it, because
both decide how the change is done rather than what it says.
[`no-signal-on-failure`](docs/map/invariant/no-signal-on-failure.md) is the
register of files whose defects produce no error, no failing test and no warning
— a diff touching one is **not** finished when the gates are green, because green
was never evidence there. [`tree-rule`](docs/map/invariant/tree-rule.md) decides
which directory a new file belongs in, and it is read before the file is written:
placement is where a seam is physically expressed, and read afterwards it arrives
as rework.

**`theflow` is retired**, and its bindings doc is **deleted**. Bindings are
consumed by the *first* build; a graph exists, so every run from here is an
**update** that reads `docs/agents/thegraph.md` and never the bindings — nothing
read that file and nothing maintained it. Its Step 7 gate matrix had already gone
stale, listing 6 bare commands against the 9 that were real **at that time**,
which is what a document nobody reads does next. Everything in it lives on: the
reference sources in `thegraph.md`, the layout rule and the silent-failure
register in the MAP, the tooltip boundary in the MAP's
[`tooltips`](docs/map/territory/tooltips.md) territory, the incidents in
`lessons.md`. `git log` has it if it is ever wanted back.

**The compiled agent build went the same way, on 2026-09-04.** It generated four
subagents and six scripts from a 965-line document that was mostly a second copy
of this repository — a gate list, a surface list, a node roster, counts. The
copies drifted exactly as `theflow`'s had. What a person actually answered was
kept: the reference sources are in `thegraph.md`, the layout rule and the
silent-failure register are MAP invariant notes, the seams are below. What went
was every fact the repository already states.

## Package philosophy

Flutter Table Plus is a **UI-only, data-agnostic** table widget: synchronized
scrolling, theming, sorting, selection, column reorder/resize, cell editing,
merged rows. It does **not** manage or mutate your data.

1. **No data management** — sort/filter/paginate stay with you.
2. **Callback-driven** — interactions come back as callbacks; you decide.
3. **Convenience first** — ready-made helpers with sensible defaults; always opt-out-able.
4. **State-management agnostic** — setState / Provider / Riverpod / Bloc alike.

## Identity & invariants (the boundary)

- **Generic, data-agnostic rows.** `FlutterTablePlus<T>` takes `List<T>`; identity
  comes from the required `rowId: String Function(T)`. Columns read via `valueAccessor`.
- **Synchronized scrolling.** Header/body/scrollbar each scroll horizontally;
  `SyncedScrollControllers` keeps them aligned — the **body is the input master**,
  the header uses `NeverScrollableScrollPhysics`.
- **Drag selection is one viewport-local coordinate frame.** A `Listener` sits
  *outside* the body's horizontal `Scrollable`, so `event.localPosition` is
  viewport-local on both axes. The gesture state machine, auto-scroll `Timer`, and
  rubber-band geometry live in a `DragSelectionController` (unit-testable in
  isolation); row lookups go through the narrow `RowLocator` port the body implements.
- **`scaledBy()` is built on `copyWith` at every level** and names only what it
  changes, so a field added later cannot be dropped by forgetting to list it.
  Hand-listing is exactly how `rowTooltipTheme` went missing at the root (#50)
  and how five `CheckboxStyle` fields went missing one level down (#116) — a
  field set owned by `flutter_checkbox`, which grows with no commit here. Saying
  this of the root alone is what let the second one live for six releases.
- **Tooltips are arbitrated by `just_tooltip`, not here.** Nesting = innermost
  wins, and since 0.4.4 "innermost" means *the innermost tooltip with something to
  draw*. `^0.4.4` is a **floor, not a preference** — the old local
  empty-message guard is gone (#96). A row tooltip uses `TooltipAnchor.pointer` as
  a **correctness requirement** (a row is `contentWidth` wide, so hover region ≠
  anchor), not a workaround. `just_tooltip` / `flutter_checkbox` sources sit at
  `../` — read them, don't guess from pub docs.

### The seams, and which side owns what

- **Mechanism — this package owns it.** Synced scrolling; the single
  viewport-local drag-selection coordinate frame; the `RowLocator` port;
  `minWidth`/`maxWidth` `clamp()` in every layout path; merged rows; the
  tooltip-gating logic. These are only correct with the whole layout state in
  hand, so they cannot be pushed outward.
- **Policy — the consumer owns it.** The data and every operation on it,
  selection state, and what a callback does. `rowId` is the caller's, and
  identity is a `(data, rowId)` snapshot contract this package deliberately does
  **not** assert (#132, #135).
- **Two seams, and both leak in both directions.** The published package, and the
  `../just_tooltip` / `../flutter_checkbox` membrane. When upstream raises a
  floor it lands on us with `lib/` untouched (#69, 2.16.0); when we change a
  contract, the *rationale* a consumer already wrote can quietly go false.

**Do not misdiagnose a contract as a defect.** When a consumer brings a "bug",
the first question is *whose invariant broke* — a report against behaviour this
package deliberately holds is a contract, and treating it as a defect deletes the
contract instead of the workaround. **Judging where to fix and reporting upstream
are separate duties**: a workaround that works well silences upstream forever
(#33, #88 → #96).

**And the urge to write a workaround here for a defect one layer deeper is a
stop, not a task.** Come to the maintainer.

## Environment

Claude Code and the user share **one** machine, and **which** one is a fact to
read rather than to remember: this paragraph said *Windows* until 2026-09-04,
when it was macOS. The Flutter SDK is on `PATH` either way, so run
`flutter test` / `analyze` / `dart format` directly, and ask the user only for
anything that opens a window (`flutter run`).

The line endings a checkout carries follow from that, and they are **a property
of the machine, not of the repository** — `.gitattributes` is `* text=auto`, so
a Windows clone makes the recipe corpus CRLF and a macOS or Linux clone makes it
LF. A test that uses that corpus as a fixture is therefore testing the checkout
as much as the code. One did: `example/test/dart_highlighter_test.dart` asserted
that at least one bundled recipe carried CRLF, was written on the Windows
machine where that held, and could only fail on this one. It is gone, on the
instruction its own failure message carried; the escape-literal test beside it
is the witness now, because escapes are immune to the checkout.

**There is no CI** — these are the only gates, and they run here:

```
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
flutter analyze                             (in example/)
flutter test                                (in example/)
python scripts/map/check_map.py docs/map
flutter pub publish --dry-run               (only when the version is ahead of the registry)
```

**Each runs bare, never piped.** A pipeline's exit status is the last command's,
so `flutter test | tail -1 && commit` always commits — a gate you cannot fail is
not a gate. **Never move a threshold to turn a build green.**

**No count is written here, and that is deliberate.** This file said *nine* for
the three days after a tenth was added, four dozen lines below a paragraph whose
whole point is that a document nobody reads goes stale by miscounting gates. No
assertion reads `CLAUDE.md`, so nothing could have caught it — and the list
above is one line per bare command precisely so that writing it as an `&&` chain
cannot make two gates look like one.

Three things the list does not make obvious. `example/` is **outside** the
top-level `flutter test` — its own manifest, its own analyzer run — and a
leftover `flutter create` template once kept it permanently red, which trains
everyone to ignore it (#55). `dart format` covers `lib test` only, so
**`example/lib` is outside the formatter gate**, deliberately. And
`publish:dry-run` insists the version is an *increment* over what is published,
so between releases it would be red for every change that is not a release —
ask the registry first, and report **N/A with the reason on screen** rather than
a quiet pass.

## Agent skills

### Issue tracker
Issues are tracked in this repo's GitHub Issues via the `gh` CLI; external PRs
are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Default vocabulary (`needs-triage` / `needs-info` / `ready-for-agent` /
`ready-for-human` / `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context: `CONTEXT.md` + `docs/adr/` at the repo root (created lazily). See
`docs/agents/domain.md`.
