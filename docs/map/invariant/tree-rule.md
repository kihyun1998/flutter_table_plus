# A file's directory is decided before it is written

## The fact

**Layout is where a seam is physically expressed.** A file in the wrong directory
breaks the seam while producing no error, no failing test and no warning — so
placement is decided *before* the code is written, not tidied afterwards. Read
after the tests are green, this rule arrives as rework.

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
scripts/map/*.py                 the MAP gate (python)
scripts/fonts/*.py               one-off asset tooling (python)
```

Everything outside those roots — `pubspec.yaml`, `CHANGELOG.md`, `README.md`,
`LICENSE`, `analysis_options.yaml`, `.pubignore`, `coverage/`, `build/`, and
`example/`'s platform scaffolding — is **out of scope, not unruled.** The rule
assigns ownership inside the roots it names; it does not adjudicate where a
manifest goes.

**The rows carry no file counts, deliberately.** They used to — `(5/5 exported)`,
`(0/15 — clean)`, `(23)`, `(6)` — and two of the four were wrong inside a day: the
invariant count the moment #113 added a note, the `utils` count before the
document that wrote it was finished. The tree is the authority for how many files
are in it, and a number copied out of it here is a second answer with nowhere to
be checked. What survives is the part that is a **rule** rather than a
measurement: `lib/src/utils` holds no Widget subclass.

### The axis is widget-*awareness*, not Widget-subclass-hood

Four axes were sorted by content and **only this one came out clean.**
Exported-ness does not sort them; importing Flutter does not; holding mutable
state does not. So `overflow_cache.dart` is stateful and stays in `utils/`
because it does not know the widget tree, and `drag_selection_controller.dart`
stays in `widgets/` though it is not a `Widget` — `CLAUDE.md`'s *"unit-testable
in isolation"* is a claim about testability, not about location. **Both are the
rule, not drift.**

### Unclassified — reported, not resolved

A difference nobody decided is drift wearing a rule's clothes. These two were
found by the peer comparison and deliberately left open rather than settled by
majority:

- **U1 — `widgets/cells/` versus `widgets/table_header_cell.dart`.** All four are
  `StatelessWidget` cells. The only axis that splits them is the consumer: a body
  row draws the first three, the header draws the fourth.
- **U2 — `test/` is flat.** The peers split 2:1 — `two_dimensional_scrollables`
  mirrors `lib/src`, `pluto_grid` splits by scenario, `data_table_2` is flat like
  us.

## Why it is cross-cutting

**It is the only rule here that no file's contents can express.** Every other
invariant in this folder is checkable by reading the code it governs; this one is
a statement about the tree, and the tree is the one structure a compiler, an
analyzer and a test suite are all indifferent to. Dart resolves an import the
same way whichever directory the target sits in.

It holds across territories because the roots do: a new value type, a new widget,
a new pure computation and a new test each land in a different root, and none of
those changes calls any of the others. The `utils` / `widgets` split in
particular has named exceptions on **both** sides, in two territories that share
no code — which is what makes it a rule to be read rather than a habit to be
copied from whatever file you happened to open.

**It was derived, not declared.** No layout rule existed anywhere in this
repository: `CLAUDE.md` states identity rather than directories, and the MAP
checks attribution rather than location. So induction against real peer trees was
the only available input, and the *"a declaration outranks the tree"* rule never
fired.

## Territories it holds in

→ [Public barrel and re-exports](../territory/public-barrel.md) — the barrel row is the sharpest one: a symbol is exported there or it is not public, and nothing else in the tree makes that decision visible
→ [Drag selection](../territory/drag-selection.md) — `drag_selection_controller.dart` is the named exception on the `widgets/` side, kept there though it is not a `Widget`
→ [Text overflow detection](../territory/text-overflow.md) — `overflow_cache.dart` is the named exception on the `utils/` side, kept there though it holds state
→ [Example app](../territory/example-app.md) — `example/` is a package of its own with its own manifest, and `example/test/` is a gate rather than a demo detail (#55)

## What a violation looks like

**A green build.** A misplaced file compiles, passes the analyzer, passes every
test, and ships. There is no symptom at all until someone reads the tree and
derives the wrong rule from it — at which point the drift has a precedent and
propagates.

The concrete shapes:

- A `Widget` subclass under `lib/src/utils/`, which makes the directory's one
  stated rule false and removes the only mechanical check the layout has.
- A new public symbol that is never added to the barrel: it is importable through
  a `src/` path, so it *works*, and it is not part of the published API. The
  consumer who found it that way is broken by a change nobody considered
  breaking.
- A test subdirectory, which is not wrong on its merits — U2 is explicitly open —
  but is wrong as an unremarked drift, because it settles by accident a question
  recorded as undecided.

## Discovery history

- **2026-08-31** — authored by the `plat` skill against three peer trees
  confirmed by the maintainer: `flutter/packages` →
  `two_dimensional_scrollables`, `bosskmk/pluto_grid`, and
  `maxim-saplin/data_table_2`, each read at full depth through the git-trees API
  rather than from a write-up. The maintainer deliberately excluded this author's
  own packages, so shared habits would surface as differences rather than as
  agreements.
- **Four rows came from auditing the rule against the whole tree, not from the
  peer comparison** — `benchmark/`, `docs/*.md`, `docs/map/README.md` and
  `scripts/fonts/*.py` all existed and none was named until the rule was matched
  against what is actually on disk. **A rule never matched against the tree it
  describes is a rule with unmeasured holes.**
- **L1 — `lib/src` is split by layer, not by feature.**
  `two_dimensional_scrollables` splits by feature because it ships two widgets
  (`TableView`, `TreeView`). This package ships one, so the axis does not
  transfer. Judged on role, this is not a difference at all.
- **L2 — the example lives at `example/`, not `demo/`.** pub.dev gives
  `example/` its own tab; `pluto_grid` uses `demo/` and loses it.
- **L3 — `example/test/` is a gate.** Of the three peers only
  `two_dimensional_scrollables` has example tests at all (#55).
- **2026-09-04** — two roots removed with the generated agent build they
  described (`scripts/thegraph/*.sh`, `.claude/agents/ftp-*.md`). The rule's
  enforcement went with them: it was a script matching these paths against the
  diff, and it is now this note. **The rule survives its check**, which is the
  ordinary condition for everything else in this folder.

## Where it will recur

**Any new top-level directory, and any file whose home is not obvious in under a
few seconds.** The second is the real trigger: hesitating about placement means
the rule does not cover the case, and that is the moment to extend it rather than
to guess and move on.

Two specific recurrences to expect:

- **A collaborator that is not a `Widget`.** The question is never "is it a
  widget" but "does it know the widget tree" — and the honest test is whether it
  can be unit-tested without a pump.
- **A new public capability.** The barrel row is the one with a consumer-visible
  consequence, so it is the row worth checking on every release rather than on
  every commit.

And **U1 and U2 stay open until something decides them.** Closing either by
adding a file that matches one side is the drift this note exists to name; if a
change needs the question settled, it is settled deliberately and this section is
what gets rewritten.
