# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) follow the **`thegraph`**
skill — run `/thegraph` at the start. It runs against this repo's own compiled
node graph, **`docs/agents/thegraph.md`**: which nodes exist, each one's guard and
decider, and this package's bindings (module map, reference routing, boundary
rule, proof methods, surfaces, tree rule, gate list). The per-incident evidence
lives in **`docs/agents/lessons.md`**. Read both before starting; add new
war-stories to lessons. **Neither file keeps a roster of issue numbers** — a
hand-copied one drifts the moment lessons grows; grep `lessons.md` for the
current set.

**Before drawing a boundary, read the MAP — [`docs/map/README.md`](docs/map/README.md).**
23 territories and 6 cross-cutting invariants, indexed by *what the system does*
rather than by the event that produced them. Open the territory your change
enters and treat its `## Blast radius` as a checklist. On the way out, ask
whether the fact you just found is true outside that territory — if it is, an
invariant note is part of the change.

**`theflow` is retired** — the skill is gone, and its fixed step list with it.
`docs/agents/thegraph.md` is the *single* source for bindings and gates.
`docs/agents/theflow.md` is **spent**. Bindings are consumed by the *first* build;
a graph exists, so every run from here is an **update** that reads the graph and
never the bindings. Nothing reads that file and nothing maintains it — deleting it
is the maintainer's call, not a prerequisite. It is certainly not a route: its
Step 7 gate matrix is **stale** (5 lines / 6 bare commands, missing the MAP gate
and the agent-grants gate; the real list is **9**, stated once in `thegraph.md`).

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

## Environment

Claude Code and the user share the same Windows machine; the Flutter SDK is on
`PATH`, so run `flutter test` / `analyze` / `dart format` directly. Ask the user
only for anything that opens a window (`flutter run`). **There is no CI** — the
9 gates in `docs/agents/thegraph.md` (`## gate`) are the only gates and run
here, each invoked **bare** (`scripts/thegraph/gates.sh`).

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
