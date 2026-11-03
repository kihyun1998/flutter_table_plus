# Gates

## What it is

The seven commands `CLAUDE.md` lists as the only gates. There is no CI, so they
run on whichever machine does the work, and that machine's SDK is part of each
gate's input: a gate whose tool ships with the SDK can change its result with no
commit in this repository.

## Governing decisions

**None.**

## Design model

- **The formatter gate does not use the SDK's `dart format`.** `dart format` is
  the `dart_style` version bundled with the SDK, and its output differs between
  SDKs. Measured 2026-11-02: two test files that a8dead4 formatted under Dart
  3.13.1 failed `dart format --set-exit-if-changed` under Dart 3.11.5, which
  splits a list argument inside `expect(...)` onto its own lines where 3.13.1
  keeps it against the parenthesis. Neither machine was wrong; the gate was red
  on one and green on the other for the same tree.
- **The gate pins `dart_style` 3.1.14 as a global package.** The script
  activates that version whenever a different one, or none, is active, and runs
  its `format` executable over `lib` and `test`. Measured on Dart 3.11.5: 3.1.14
  changed 0 of 130 files on the tree a8dead4 left, so it agrees with the 3.13.1
  SDK formatter there.
- **It is not a dev dependency, because that does not resolve.** `dart_style`
  3.1.11 and later need an `analyzer` that needs `meta` ^1.18.3, and Flutter
  3.41 pins `meta` 1.17.0, so `flutter pub add --dev dart_style` fails. A global
  package is resolved apart from this package's dependencies.
- **The pin has a floor and a ceiling.** 3.1.14 declares Dart ^3.11.0, so the
  gate needs Dart 3.11 or newer on the machine. It formats language versions up
  to 3.14; once this package's SDK lower bound passes that, the pin has to move.
  Moving it can reformat the tree, so that is a commit of its own.

## Code

[scripts/format/check_format.py](../../../scripts/format/check_format.py) — the
pin is the version constant at its top.

## Reference behaviour

→ [dart_style changelog](https://github.com/dart-lang/dart_style/blob/main/CHANGELOG.md) — what each formatter version changes, and which changes are language-versioned

## Cross-cutting invariants

**None.**

## Blast radius

→ [Publishing and release](publishing.md) — the release bar runs every gate, and the dry-run is one of them
→ [Example app](example-app.md) — its two gates need the SDK floor its dependencies set, the other place the machine's SDK decides whether a gate can run

## Known holes / open

- **`flutter analyze` still uses the SDK's analyzer.** The lint set is pinned
  through `flutter_lints` in `pubspec.yaml`, but the analyzer that applies it
  moves with the SDK, so a new SDK can report diagnostics an older one did not.
  Not measured here.
