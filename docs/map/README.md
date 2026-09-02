# MAP — flutter_table_plus

A dependency graph over what this package *does*. It exists to answer two
questions that nothing else in the repository can:

| Question | Open |
|---|---|
| **If I touch this, what else moves?** | the territory note, then its `## Blast radius` — a checklist, not a summary |
| **What design is this derived from, and what decided that design?** | the territory note's `## Design model`, then `## Governing decisions` and `## Reference behaviour` |

Every other layer here is indexed by an **event** — an issue closes, a changelog
entry is pinned to a version, a war story is filed under the step it happened at.
None is indexed by the **territory**, and none survives its event. That is the
gap this layer fills.

## Reading protocol

**Read before the work, write after it.** The read is bound into `thegraph`'s
`map` node, which runs **before `boundary`** — early enough that what the map
tells you arrives as design rather than as rework. The write is `sweep`'s tenth
surface.

There is no separate rule to remember, because the copy this replaces is gone:
`docs/agents/thegraph.md` used to hand-list the module layout, and it now points
here instead. This is the only place that answer exists.

Section by section, what you are expected to *do*:

- `## Blast radius` — **a checklist.** Open each linked territory. Finding
  nothing to change there is a correct outcome; not opening it is the failure
  this map exists to prevent.
- `## Cross-cutting invariants` — read each one's `## Where it will recur` and
  check your change against it.
- `## Governing decisions` — answers *why*. `**None.**` is itself the answer:
  nothing decided this, so you are not contradicting anything — and nothing
  protects it either.
- `## Known holes / open` — what is undecided here.

And one obligation on the way out: **is the fact this change revealed also true
outside this territory?** If yes, an invariant note for it is part of the change,
not a follow-up. The first site to hit a cross-cutting fact is where it is
cheapest to record and where no node for it exists yet.

## Why this layer exists — the measured rediscoveries

Not hypothetical. Two facts in this repository were each found more than once,
and in one case by two different packages independently:

- **The tooltip workaround.** #33 routed around an upstream anchor defect and it
  worked, so the defect survived; just_tooltip 0.4.2's changelog recorded that
  *"both known downstreams had independently adopted it as a workaround."* Then
  #88 grew a local empty-message guard for the same seam, correctly judged and
  never reported, until 0.4.4 fixed it upstream noting *"Two packages had
  independently grown the same local guard rather than report it."* #96 removed
  it here. **Two rediscoveries, two packages, one fact** — now
  [one note](invariant/upstream-contract.md).
- **The square test font.** #55 spent a viewport enlargement on it and still
  failed; #65 then estimated 12 overflows and measured 34, all resolving to two
  shared helper lines. **Two rediscoveries, one fact** — now
  [one note](invariant/test-font-square.md).

## What was measured while building this

These numbers exist in no note file, and they re-ordered the map:

- **58 public types and 40 public constructor parameters. Zero governing
  records.** `docs/adr/` does not exist. The de facto record store — CHANGELOG,
  67 issues, `docs/agents/lessons.md` — is entirely event-indexed.
- **Publishing has 0 issues about it and 2 incidents in it** (a published
  changelog entry edited in place with the tag moved twice; a tag placed past an
  unmerged PR whose tree was broken for a range of users). Ordering work by
  commit frequency puts it last; it is one of the four areas the maintainer names
  as quiet and expensive.
- **`widgets/flutter_table_plus.dart` is 1235 lines — 14.5% of `lib/`** — and
  holds at least five concerns. The map is deliberately finer than the file tree
  there.
- **18 `clamp` sites across 7 files**, none of which call each other. That is a
  cross-cutting invariant, not a rule in one territory.
- **Only 2 open issues** (#2, #37). The backlog is not this map's blind spot.

## Conventions

- **Territories overlap.** A fact that holds in three places belongs to an
  invariant note, not to whichever territory found it first.
- **Empty sections stay.** `**None.**` is a finding — greppable, so the hub can
  *ask* rather than store a list.
- **Symbols, never line numbers.** `file.dart — Type.method` survives an edit;
  `file.dart:1591` is stale on the next one and stale *silently*, because it
  still points at real code.
- **Plain markdown relative links**, never wikilinks: Obsidian resolves both,
  GitHub only the first.
- **English throughout**, matching `thegraph.md`, because this is read at the
  start of every task alongside it.
- **Section names are exact strings.** The queries below grep them; a note that
  spells one differently drops silently out of every count.

## Coverage, and what an absent note means

**Coverage is complete** for `lib/`, `example/`, and the release surface — 23
territories, 7 invariants. This is not a pilot.

So **an absent note is not a backlog item; it means the area is not part of the
system.** A note becomes owed when either of these happens:

1. **A new public capability lands** — a new constructor parameter, a new
   exported type, a new callback. It gets a territory, or it is a part of an
   existing one and that note's `## Design model` grows.
2. **A fact turns out to hold in more than one territory.** It gets an invariant
   note in the same change that found it — see the reading protocol's last
   paragraph.

Everything else — a refactor, a bug fix, a doc change — updates notes rather than
creating one.

## Asking the map questions

Stored answers rot; these do not. **Scope every sentinel query to its heading** —
the same sentinel marks three different holes, and an unscoped query conflates
them. Measured here: `rg -l '\*\*None\.\*\*' docs/map/territory/` returns **all
23** territories, which answers nothing.

```sh
# nobody decided it — territories with no governing record
rg -lU '## Governing decisions\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/

# nobody checked it — territories never compared against a reference
rg -lU '## Reference behaviour\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/

# nobody built it — territories with no code at all
rg -lU '## Code\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/

# what exists — the folder is the roster
ls docs/map/territory/ docs/map/invariant/

# the gate: links, anchors, symbols, file attribution, sections, reciprocity
python scripts/map/check_map.py docs/map
```

At the time of writing those return **23 / 18 / 1**. The first number is the one
worth watching.

## What this map cannot answer

- **Only `.md` files in this repository are nodes.** Issues are not, and in this
  repo the hottest material often is one — the tooltip history is #33, #88 and
  #96, and the graph shows none of them. Where an issue matters, it is cited as
  *evidence* inside a note, phrased so it stays true after the issue closes.
- **Source files are not nodes either.** `## Code` names symbols as text; the
  graph draws no edge to them.
- **The sibling packages are outside this repository.** `../just_tooltip` and
  `../flutter_checkbox` are named as paths, never linked — a link that resolves
  only on one machine is worse than none.
- **`todo.md` is the maintainer's personal scratchpad, not a repository record.**
  It is not an input to this map and should not be read as a plan: at least one
  of its entries describes a feature that shipped long ago.
- **Blast edges are behavioural, not call-graph.** A pure move or rename has doc
  impact by *symbol mention*, which no blast list knows about — use the symbol
  sweep in the gate for that shape of change.

## Nodes

**Territories** —
[cell editing](territory/cell-editing.md) ·
[column model and ordering](territory/column-model.md) ·
[column reordering](territory/column-reorder.md) ·
[column resizing](territory/column-resize.md) ·
[column width resolution](territory/column-width.md) ·
[drag selection](territory/drag-selection.md) ·
[empty state](territory/empty-state.md) ·
[example app](territory/example-app.md) ·
[hover buttons](territory/hover-buttons.md) ·
[merged rows](territory/merged-rows.md) ·
[public barrel and re-exports](territory/public-barrel.md) ·
[publishing and release](territory/publishing.md) ·
[row height](territory/row-height.md) ·
[row identity and data binding](territory/row-identity.md) ·
[row interaction](territory/row-interaction.md) ·
[row rendering and geometry](territory/row-render-geometry.md) ·
[row selection](territory/row-selection.md) ·
[scale / zoom](territory/scale-zoom.md) ·
[sorting](territory/sorting.md) ·
[synced scrolling](territory/synced-scrolling.md) ·
[text overflow detection](territory/text-overflow.md) ·
[theme system](territory/theme-system.md) ·
[tooltips](territory/tooltips.md)

**Cross-cutting invariants** —
[widths and offsets are clamped on every path](invariant/clamped-dimensions.md) ·
[the widget-test font is a square per glyph](invariant/test-font-square.md) ·
[do not work around an upstream contract here](invariant/upstream-contract.md) ·
[never re-assemble by hand-listing fields](invariant/no-hand-enumeration.md) ·
[viewport-local coordinates come from one frame](invariant/viewport-local-frame.md) ·
[observe at the screen, assert by count](invariant/observe-at-the-screen.md) ·
[a guard reads the destination, never the source](invariant/guard-the-destination.md)
