# Do not work around an upstream contract here

## The fact

When behaviour from `just_tooltip` or `flutter_checkbox` is wrong or surprising,
the fix belongs **in that package**, not in a local guard here. And the seam
leaks the other way too: when one of them raises its own floor, that floor
becomes this package's requirement and a **breaking change for its users**, with
no code change on either side.

Judging *where* to fix and *reporting* upstream are separate duties. Doing the
first well is what makes skipping the second feel safe.

## Why it is cross-cutting

The two sibling packages are consumed in four unrelated places — tooltip
wrapping, the checkbox cell, the theme's checkbox factory, and the barrel's
re-export list — and their floors are consumed in a fifth, the manifest. None of
those call each other. What they share is a *dependency*, which no call graph
shows and no territory owns.

The sibling sources sit at `../just_tooltip` and `../flutter_checkbox`. They are
not strangers' code and each has its own tracker.

## Territories it holds in

→ [Tooltips](../territory/tooltips.md) — where it was learned, twice, and where the removed local guard must not return
→ [Row selection](../territory/row-selection.md) — the checkbox is the sibling's widget
→ [Theme system](../territory/theme-system.md) — the checkbox sub-theme and its `colored()` factory sit on the seam
→ [Public barrel and re-exports](../territory/public-barrel.md) — seven sibling type names are re-exported by hand
→ [Publishing and release](../territory/publishing.md) — the floor half: a sibling's floor becomes ours the moment the constraint is raised

## What a violation looks like

- A local guard that makes a symptom go away and reads as defensive
  programming — the measured phrasing is *"a tooltip that cannot show must never
  be built"*, which was true, correct, and still the wrong place.
- A constraint bump described as routine because `lib/` did not change and every
  test passed.
- `pub get` resolving cleanly while a user on an older SDK cannot install the
  package at all.

The tell for the first: **the urge to write code here so a test passes, when the
thing that is wrong is one layer down.**

## Discovery history

- **#33** — the row tooltip avoided the `child` anchor and used `pointer`. It
  worked, so the upstream defect survived; just_tooltip 0.4.2's changelog then
  recorded that *"both known downstreams had independently adopted it as a
  workaround"*. A workaround that works well is what keeps a defect alive.
- **#88 → #96** — an ancestor-suppression behaviour was correctly judged to be
  just_tooltip's intended contract and fixed here. The judgement was right and it
  was **not reported upstream**; 0.4.4 later fixed it there, recording *"Two
  packages had independently grown the same local guard rather than report it."*
- **#69 / #38** — upstream required a newer Flutter, so this package's declared
  `environment` had to follow. Change does not only flow downward.
- **2.16.0** — `flutter_checkbox` 0.3.0 corrected its own floor from a
  `flutter create` default to its real minimum. Taking `^0.3.0` made that our
  transitive requirement: `lib/` unchanged, 382+67 tests green, and a breaking
  release for users below it.

  It was also, unnoticed, a **behaviour regression** (#116). 0.3.0 *added* five
  `CheckboxStyle` fields, and this package hand-listed that type, so every one
  was reset at any non-unit scale. `lib/` unchanged and every test green were
  both true and neither was evidence: **a green suite says nothing about a field
  no assertion names**, and against a hand-listed upstream type the newest
  fields are exactly the unnamed ones. The entry called 0.3.0 *"purely
  additive"* while naming `CheckboxStyle.copyWith` and `CheckboxStyle.checkScale`
  in the same sentence — the remedy and the defect, neither recognised.

## Where it will recur

**Any new use of a sibling package, and any dependency bump.** The concrete test,
answerable by reading rather than judgement: *does the fix I am about to write
here exist because the layer below does something I disagree with?* And on every
constraint change: *did the dependency's changelog move its `environment:` or its
own floors?* A "just bump the version" request is exactly when that goes unread.
