# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) follow the **`thegraph`**
skill — run `/thegraph` at the start. The skill carries its own nodes, guards and
deciders. **`docs/agents/thegraph.md`** carries only what the skill cannot know and
no file here answers: **the outside sources this package is read against, and
whether each one binds.** Everything else a run needs is read from the repository
itself. The per-incident evidence lives in **`docs/agents/lessons.md`**. Read both
before starting; add new war-stories to lessons.

**Read counts and rosters from the repository; a copy here drifts, and nothing
checks this file.** The issue set is
`grep -o '#[0-9]\+' docs/agents/lessons.md | sort -u`; the MAP's notes are
`ls docs/map/territory docs/map/invariant`.

**Before drawing a boundary, read the MAP — [`docs/map/README.md`](docs/map/README.md).**
Territories and cross-cutting invariants, indexed by *what the system does*
rather than by the event that produced them. Open the territory your change
enters and treat its `## Blast radius` as a checklist. On the way out, ask
whether the fact you just found is true outside that territory — if it is, an
invariant note is part of the change.

Two invariant notes are read **before** the work rather than during it, because
both decide how the change is done rather than what it says.
[`no-signal-on-failure`](docs/map/invariant/no-signal-on-failure.md) is the
register of files whose defects produce no error, no failing test and no warning
— a diff touching one is **not** finished when the gates are green, because green
was never evidence there. [`tree-rule`](docs/map/invariant/tree-rule.md) decides
which directory a new file belongs in, and it is read before the file is written:
placement is where a seam is physically expressed, and read afterwards it arrives
as rework.

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
  changes, so a field added later cannot be dropped by forgetting to list it —
  including fields of `CheckboxStyle`, a set owned by `flutter_checkbox` that
  grows with no commit here.
- **Tooltips are arbitrated by `just_tooltip`, not here.** Nesting = innermost
  wins, and since 0.4.4 "innermost" means *the innermost tooltip with something to
  draw*. `^0.5.1` is a **floor, not a preference**. A row tooltip uses
  `TooltipAnchor.pointer` as a **correctness requirement** (a row is
  `contentWidth` wide, so hover region ≠ anchor), not a workaround.

### The seams, and which side owns what

- **Mechanism — this package owns it.** Synced scrolling; the single
  viewport-local drag-selection coordinate frame; the `RowLocator` port;
  `minWidth`/`maxWidth` `clamp()` in every layout path; merged rows; the
  tooltip-gating logic. These are only correct with the whole layout state in
  hand, so they cannot be pushed outward.
- **Policy — the consumer owns it.** The data and every operation on it,
  selection state, and what a callback does. `rowId` is the caller's, and
  identity is a `(data, rowId)` snapshot contract this package deliberately does
  **not** assert.
- **Two seams, and both leak in both directions.** The published package, and the
  `../just_tooltip` / `../flutter_checkbox` / `../flutter_smooth_wheel_scroll`
  membrane. When upstream raises a floor it lands on us with `lib/` untouched;
  when we change a contract, the *rationale* a consumer already wrote can
  quietly go false.

**Do not misdiagnose a contract as a defect.** When a consumer brings a "bug",
the first question is *whose invariant broke* — a report against behaviour this
package deliberately holds is a contract, and treating it as a defect deletes the
contract instead of the workaround. **Judging where to fix and reporting upstream
are separate duties**: a workaround that works well silences upstream forever.

**And the urge to write a workaround here for a defect one layer deeper is a
stop, not a task.** Come to the maintainer.

## Environment

**Read the machine, don't remember it** — `uname -s`. The Flutter SDK is on
`PATH`, so run `flutter test` / `analyze` / `dart format` directly, and ask the
user only for anything that opens a window (`flutter run`). Writing a test whose
fixture is a checked-out file? Read the line-endings note in
[`example-app`](docs/map/territory/example-app.md) first.

**There is no CI** — these are the only gates, and they run here, one line per
bare command:

```
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
flutter analyze                             (in example/)
flutter test                                (in example/)
python scripts/map/check_map.py docs/map
flutter pub publish --dry-run               (checks the archive, never the version)
```

**Each runs bare, never piped.** A pipeline's exit status is the last command's,
so `flutter test | tail -1 && commit` always commits — a gate you cannot fail is
not a gate. **Never move a threshold to turn a build green.**

- `example/` is **outside** the top-level `flutter test` — its own manifest, its
  own analyzer run.
- `dart format` covers `lib test` only, so **`example/lib` is outside the
  formatter gate**, deliberately.
- `flutter pub publish --dry-run` is the **archive** gate and runs on every
  change: it resolves `.pubignore` and prints every file that would ship, and
  the archive is the one artifact here that **cannot be un-published**. Read the
  file tree it prints. It never checks the version, so **a green dry-run is not
  evidence that a publish will succeed** — ask the registry for that,
  separately. Before a release, or when the dry-run surprises you, read
  [`publishing`](docs/map/territory/publishing.md).

A gate that genuinely cannot run here reports N/A **with the reason on screen**,
never a quiet pass.

## Agent skills

### Issue tracker
Issues are tracked in this repo's GitHub Issues via the `gh` CLI; external PRs
are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Default vocabulary (`needs-triage` / `needs-info` / `ready-for-agent` /
`ready-for-human` / `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context: `GLOSSARY.md` + `docs/adr/` at the repo root (created lazily). See
`docs/agents/domain.md`.

## Comments and the map

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`.
Where none seems to hold it, search the folder and the code symbol first; only
then start a new note, named for what the system does there, not for the file.
History goes to the commit message. Comments written before this rule still
carry the rest: never delete one whose content the map does not yet hold — move
it first (`decant`).
