# thegraph build (flutter_table_plus)

## What this project is

A UI-only, data-agnostic Flutter table widget — synchronized scrolling, theming,
sorting, selection, column reorder/resize, cell editing, merged rows. It never
manages or mutates the caller's data.

## References

| Source | Informs | Reached by | Binding |
|---|---|---|---|
| `../just_tooltip`, `../flutter_checkbox` | how it works | their source trees + CHANGELOGs at `../` — raw | **binding** — a wrong contract is fixed there, never worked around here |
| Flutter SDK | how it works | the SDK source tree on `PATH` — raw | **binding** — coordinates, gestures, scroll physics; source plus a probe, never the doc comment |
| `flutter/packages` → `two_dimensional_scrollables` · `bosskmk/pluto_grid` · `maxim-saplin/data_table_2` | where files go | `gh api repos/OWNER/REPO/git/trees/BRANCH?recursive=1` — raw | example — peer set confirmed by the maintainer 2026-08-31, deliberately excluding this author's own packages so shared habits surface as differences rather than as agreements |
| the reporting consumer, found via `../*/pubspec.yaml` | how it works | that repo's own source — raw | example — a downstream claim is verified, never assumed |
| pub.dev registry | how it works | `https://pub.dev/api/packages/flutter_table_plus`, and `archive_url` for the published tree | **binding** — publish state is queried, never assumed |

**summarized: none.** Every source above is read as raw source, so any of them can
settle a question outright.
