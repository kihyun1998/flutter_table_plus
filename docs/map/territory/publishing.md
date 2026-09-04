# Publishing and release

## What it is

Everything between a green tree and a version on pub.dev: the declared SDK and
dependency floors, what the archive contains, the changelog entry, the tag, and
the release itself.

It is the territory with **zero issues about it and two incidents in it**, and
every failure here is irreversible in a way no code failure is: an archive cannot
be un-published, and a published changelog entry is snapshotted at the moment of
publish.

## Governing decisions

**None.**

Both incidents are recorded in `docs/agents/lessons.md` as war stories, and the
three files they happened in are on the register in
[a defect in these files produces no signal](../invariant/no-signal-on-failure.md).
Neither is a decision record: nothing states the release policy — when
a dependency bump is breaking, what the tagging rule is, what may be edited after
a publish — as a rule that resolves the *next* case rather than the last one.

## Design model

- **A dependency floor rise is BREAKING for us even when `lib/` is untouched.** A
  pub package's semver covers the declared SDK range, not just the API: when
  `flutter_checkbox` 0.3.0 corrected its own floor to Flutter 3.35, taking
  `^0.3.0` made 3.35 our transitive requirement, and users below it lost the
  package while every test here still passed.
- **`pub get` succeeding is not evidence that a constraint is honest.** A caret
  range can already resolve a version whose real floor is higher than what this
  package declares — the break then appears only to users on the older SDK.
- **Publish state is queried, never assumed** — `pub.dev/api/packages/…`. The
  steps not run locally are the ones whose result most needs confirming.
- **The published commit is identified by the archive**, not by timestamp: fetch
  `archive_url`, unpack, compare against `git show <commit>:<path>` normalising
  CRLF. If *all* candidates fail — or all pass — suspect the checker.
- **The archive's contents are decided by `.pubignore`**, and a root `.pubignore`
  **disables git-based file listing**, so anything unlisted ships. The dry-run's
  git warning does not close that gap, and it is easy to over-trust in **both**
  directions. Measured 2026-09-01 on a working tree: it named all four
  *tracked and modified* files that were inside the archive, and said nothing at
  all about **two untracked files it packed** — both of them listed, by name, a
  hundred lines earlier in its own output. It is equally silent about a modified
  file `.pubignore` excludes, because that one is not in the archive to begin
  with. So: a green dry-run is not evidence of a clean tree, and a dry-run
  *with* warnings has still not told you what is being shipped. **Read the file
  listing.** An earlier version of this line said the dry-run never warns about
  uncommitted changes at all; that was measured false here, and the sharper
  claim is the one that catches something.

## Code

**None.** This territory has no source. Its artifacts are `pubspec.yaml`,
`CHANGELOG.md`, `.pubignore` and the git tag — none of which a symbol check can
reach, which is exactly why nothing in the code gates any of it.

## Reference behaviour

→ [lessons.md — Step 7, gates and release](../../agents/lessons.md#step-7--게이트--릴리스) — the two measured incidents: a published changelog entry edited in place with the tag moved twice, and a tag placed past an unmerged PR whose tree was broken for a range of users

The registry itself is the other reference and is queried live rather than
recorded here, because a stored answer about a registry is stale on the next
publish.

## Cross-cutting invariants

→ [Do not work around an upstream contract here](../invariant/upstream-contract.md) — the floor half of that invariant lands here: a sibling's floor becomes ours the moment the constraint is raised
→ [A defect in these files produces no signal](../invariant/no-signal-on-failure.md) — the three release-surface entries, and the only ones whose failure cannot be repaired by a later commit

## Blast radius

→ [Public barrel and re-exports](public-barrel.md) — the export list is what a breaking change is measured against
→ [Example app](example-app.md) — it has its own manifest and lockfile, and a lockfile once recorded a version that did not exist
→ [Tooltips](tooltips.md) — the `just_tooltip` constraint is the one most often raised, and `^0.4.4` is a floor rather than a preference
→ [Row selection](row-selection.md) — the `flutter_checkbox` constraint is the other one

## Known holes / open

**None.**
