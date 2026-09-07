/// The typeface this example's chrome wears.
library;

/// The family name, and the one thing this app hands the shell about fonts.
///
/// The four weights behind it are at `example/assets/fonts/`, declared in
/// `example/pubspec.yaml`, and cut from the full faces by
/// `scripts/fonts/subset_pretendard.py`. The constant lives beside that
/// declaration rather than beside the theme that consumes it, because a name
/// whose files are somewhere else is a name that stops resolving the moment the
/// code moves — which is what happened when the theme entered the portable zone
/// (#179), and the zone has since moved again, out of this package entirely.
/// The constant did not have to follow either time.
///
/// The subset is a **claim about which characters this app may draw**, and a
/// missing glyph does not throw: Flutter draws it from a platform face, so the
/// failure reads as a typeface seam mid-sentence. `test/font_coverage_test.dart`
/// reads the shipped `cmap` rather than the script that produced it (#122).
const exampleChromeFont = 'Pretendard';
