"""Re-subset Pretendard for `example/`, from a charset that is written down.

The example bundles four Pretendard weights so the demo has a font of its own.
The full faces are ~2.6 MB each; the app draws Latin text and punctuation, so
almost all of that is Hangul nobody looks at.

`7902b7b` did this subsetting by hand and recorded only the resulting sizes, so
the charset itself was unrecoverable — which is how `#122` happened: the em dash
was missing for six commits and the only way to find out was to parse the `cmap`
of the shipped file. This script exists so the charset is a thing in the
repository rather than a thing in someone's shell history.

    python scripts/fonts/subset_pretendard.py <dir-with-full-ttfs>

`example/test/font_coverage_test.dart` checks the *result*, so this script being
right is not load-bearing — a wrong charset here shows up as a red test rather
than as text in a different typeface six commits later.

Requires `fonttools` (`pip install fonttools`).
"""

import os
import subprocess
import sys

# The weights the example declares in its `pubspec.yaml`. ExtraBold and Light
# were dropped by `7902b7b` as unreferenced; adding one back means adding it
# there too, or the manifest points at an asset that is not built.
WEIGHTS = ['Regular', 'Medium', 'SemiBold', 'Bold']

# Whole blocks, not the characters that happen to be in use today.
#
# A charset picked from current usage is one that goes wrong the next time
# somebody types a character — which is exactly what #122 was. A block is a
# thing a reader can check a character against without running anything.
#
# General Punctuation is the block this used to be missing: it held U+2018-201F,
# U+2022 and U+2026 and nothing else, so the em and en dashes fell out while the
# curly quotes stayed. Latin-1 Supplement was already taken whole (96 of 96),
# which is the precedent being followed rather than a new policy.
RANGES = [
    ('0020-007E', 'Basic Latin, printable'),
    ('00A0-00FF', 'Latin-1 Supplement — accented Latin, punctuation, symbols'),
    ('2000-206F', 'General Punctuation — dashes, quotes, spaces, ellipsis'),
    ('20A9', 'Won sign'),
    ('20AC', 'Euro sign'),
    ('2190-2193', 'Arrows, the four cardinal ones'),
    ('25A0-25EF', 'Geometric Shapes — bullets and the triangles a table sorts by'),
    ('2713', 'Check mark'),
]

# No Hangul. The full face carries it and the subset never has: the demo data is
# English and a `[가-힣]` scan of `example/lib` returns nothing. `example_theme
# .dart` claimed otherwise until #122 — if that ever stops being true, add the
# range here *and* say so there.

OUT_DIR = os.path.join('example', 'assets', 'fonts')


def main(argv):
    if len(argv) != 2:
        sys.stderr.write(__doc__ + '\n')
        return 2

    src_dir = argv[1]
    unicodes = ','.join(r for r, _ in RANGES)

    print('charset:')
    for r, why in RANGES:
        print('  U+%-12s %s' % (r, why))
    print()

    if not os.path.isdir(OUT_DIR):
        sys.stderr.write('run this from the repository root: %s not found\n'
                         % OUT_DIR)
        return 2

    for weight in WEIGHTS:
        name = 'Pretendard-%s.ttf' % weight
        src = os.path.join(src_dir, name)
        if not os.path.isfile(src):
            sys.stderr.write('missing full face: %s\n' % src)
            return 1
        dst = os.path.join(OUT_DIR, name)

        subprocess.run(
            [sys.executable, '-m', 'fontTools.subset', src,
             '--unicodes=' + unicodes,
             # Keep the font legal rather than merely small: dropping `name`
             # entries loses the licence, and Pretendard ships under OFL.
             '--name-IDs=*',
             '--layout-features=*',
             '--output-file=' + dst],
            check=True)

        before = os.path.getsize(src) // 1024
        after = os.path.getsize(dst) // 1024
        print('  %-10s %6d KB -> %4d KB' % (weight, before, after))

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
