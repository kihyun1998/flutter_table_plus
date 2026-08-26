import 'dart:io';
import 'dart:typed_data';

import 'package:example/theme/example_theme.dart';
import 'package:flutter_test/flutter_test.dart';

// The bundled Pretendard is a subset, and a subset is a claim about which
// characters this app is allowed to draw.
//
// #122: the subset held U+2018-201F, U+2022 and U+2026 out of General
// Punctuation and nothing else, so the em dash was missing while the curly
// quotes were there. Nine rendered strings used one. Nothing noticed for six
// commits, because a missing glyph does not throw — Flutter falls back to a
// platform face and the text renders in a different typeface mid-sentence,
// which reads as a rendering quirk rather than as a bug.
//
// So the check has to read the font's own `cmap`. A test that greps the sources
// for a character it already knows about only catches the character somebody
// already thought of, which is the thing that failed the first time.
//
// `scripts/fonts/subset_pretendard.py` regenerates the files from the full
// faces; the charset lives there, and this asserts the result.

/// The weights `example/pubspec.yaml` declares.
const _weights = ['Regular', 'Medium', 'SemiBold', 'Bold'];

/// Characters with no glyph by definition — a zero-width joiner or a variation
/// selector is an instruction to the shaper, not something a face draws. A font
/// that lacks them is correct, so demanding coverage would be demanding a wrong
/// thing.
bool _isFormatChar(int c) =>
    (c >= 0x200B && c <= 0x200F) || c == 0xFEFF || c == 0xFE0F;

/// Where a text face stops being responsible.
///
/// U+2600 is where Miscellaneous Symbols begins and, for practical purposes,
/// where emoji begin — the demo data's avatars are `👨‍💻` and friends, and two of
/// them (`👨‍⚕️` U+2695, `👨‍⚖️` U+2696, `👨‍✈️` U+2708) sit just above the line in
/// blocks that predate emoji. None of them belong in a Latin text subset;
/// every platform draws them from a dedicated emoji face and always has.
///
/// Below the line is a different matter: `·`, `×`, `•`, an en dash, the sort
/// triangles. Those are typography, they are what this font is bundled for, and
/// a fallback for one of them is a visible seam.
///
/// The floor is not the whole rule — see [_nonAsciiInSources] on U+FE0F. A
/// codepoint below it can still be an emoji if it is *asked* to be one, and
/// this test found exactly that on its first run.
const _emojiFloor = 0x2600;

void main() {
  late final Map<String, Set<int>> coverage = {
    for (final w in _weights)
      w: _cmapCodepoints(
        File('assets/fonts/Pretendard-$w.ttf').readAsBytesSync(),
      ),
  };

  group('the bundled subset covers what the app draws', () {
    test('every weight covers the same characters', () {
      // A per-weight difference is worse than a uniform gap: the text renders
      // correctly until someone bolds it. `subset_pretendard.py` runs one
      // charset over every face, so a divergence means a file was replaced by
      // hand.
      final regular = coverage['Regular']!;
      expect(regular, isNotEmpty);
      for (final w in _weights.skip(1)) {
        expect(coverage[w], regular,
            reason: 'Pretendard-$w.ttf covers a different set than Regular — '
                're-run scripts/fonts/subset_pretendard.py over all four');
      }
    });

    test('every non-ASCII character the sources can draw', () {
      final used = _nonAsciiInSources(Directory('lib'));
      expect(used, isNotEmpty, reason: 'the scan found nothing — it is broken');

      final required = used.keys
          .where((c) => c < _emojiFloor && !_isFormatChar(c))
          .toList()
        ..sort();
      expect(required, isNotEmpty,
          reason: 'no text punctuation found at all — the scan is broken, not '
              'the font');

      final missing = required.where((c) => !coverage['Regular']!.contains(c));

      expect(missing, isEmpty,
          reason: 'the subset cannot draw:\n'
              '${missing.map((c) => '  U+${c.toRadixString(16).toUpperCase().padLeft(4, '0')} '
                  '${String.fromCharCode(c)}  first at ${used[c]}').join('\n')}\n'
              'Widen the charset in scripts/fonts/subset_pretendard.py and '
              're-run it, or use a character the subset has.');
    });

    test(
        'the dashes specifically, because those are the ones that went missing',
        () {
      // Named as well as scanned. The scan above goes green the day somebody
      // deletes the last em dash from the app, and that is not the same fact —
      // the next person to type one would find it gone again.
      for (final c in [0x2013, 0x2014]) {
        expect(coverage['Regular'], contains(c),
            reason: 'U+${c.toRadixString(16).toUpperCase()} is missing again');
      }
    });
  });

  group('the subset carries no Hangul, and neither do the sources', () {
    // These two facts are asserted together on purpose.
    //
    // `example_theme.dart` justified bundling Pretendard by saying it "carries
    // Korean text — which the demo data contains". Both halves were false, and
    // each half alone looks plausible enough to survive review. Checking them
    // as a pair means the day one changes, the test says so instead of the
    // comment quietly becoming true again for the wrong reason.

    test('the font has none', () {
      final hangul =
          coverage['Regular']!.where((c) => c >= 0xAC00 && c <= 0xD7A3);
      expect(hangul, isEmpty,
          reason: 'the subset gained Hangul — if that is deliberate, say so in '
              'exampleChromeFont\'s doc-comment and in subset_pretendard.py');
    });

    test('and the sources use none', () {
      final korean = _nonAsciiInSources(Directory('lib'))
          .entries
          .where((e) => e.key >= 0xAC00 && e.key <= 0xD7A3)
          .map((e) => '${String.fromCharCode(e.key)} at ${e.value}');

      expect(korean, isEmpty,
          reason: 'Korean reached example/lib:\n  ${korean.join('\n  ')}\n'
              'The bundled $exampleChromeFont subset has no Hangul, so this '
              'renders in a platform fallback. Add the range to '
              'scripts/fonts/subset_pretendard.py.');
    });
  });
}

/// Every non-ASCII code point on a line that is not a comment, mapped to the
/// first `path:line` it was seen at.
///
/// Deliberately coarse. Parsing Dart string literals properly means handling
/// `'''`, `r'...'`, adjacent concatenation and interpolation, and getting one
/// of those wrong makes the test silently narrower — the failure mode this is
/// meant to prevent. Taking every character off a non-comment line
/// over-approximates instead: at worst it demands the font cover something in
/// a trailing comment, and widening the font is the right answer to that
/// anyway.
///
/// **One narrowing, and it is about meaning rather than convenience.** A
/// character followed by U+FE0F is an emoji presentation sequence: the variation
/// selector is a request for the platform emoji face, so the codepoint is not
/// being used as typography no matter which block it lives in. Without this the
/// first run failed on U+2194 in `debugPrint('↔️ Resized column …')` — a console
/// string, drawn by a terminal, that this font could not be responsible for if
/// it wanted to be. Widening the subset to satisfy it would have added a glyph
/// nothing renders and called the test green for the wrong reason.
Map<int, String> _nonAsciiInSources(Directory dir) {
  final found = <int, String>{};

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final lines = entity.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('//')) continue;

      final runes = lines[i].runes.toList();
      for (var r = 0; r < runes.length; r++) {
        if (runes[r] <= 0x7F) continue;
        if (r + 1 < runes.length && runes[r + 1] == 0xFE0F) continue;

        found.putIfAbsent(
            runes[r], () => '${entity.path.replaceAll(r'\', '/')}:${i + 1}');
      }
    }
  }

  return found;
}

/// The code points a TrueType file's `cmap` maps to a glyph.
///
/// Reads the format 4 subtable, which covers the Basic Multilingual Plane. That
/// is the whole range this test cares about — everything above it is emoji, and
/// [_emojiFloor] excludes those regardless.
Set<int> _cmapCodepoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final numTables = data.getUint16(4);

  var cmap = -1;
  for (var i = 0; i < numTables; i++) {
    final record = 12 + 16 * i;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') cmap = data.getUint32(record + 8);
  }
  if (cmap < 0) throw StateError('no cmap table');

  var subtable = -1;
  final numSubtables = data.getUint16(cmap + 2);
  for (var i = 0; i < numSubtables; i++) {
    final offset = cmap + data.getUint32(cmap + 4 + 8 * i + 4);
    if (data.getUint16(offset) == 4) subtable = offset;
  }
  if (subtable < 0) throw StateError('no format 4 cmap subtable');

  final segCountX2 = data.getUint16(subtable + 6);
  final endBase = subtable + 14;
  final startBase = endBase + segCountX2 + 2;
  final deltaBase = startBase + segCountX2;
  final rangeBase = deltaBase + segCountX2;

  final codepoints = <int>{};
  for (var s = 0; s < segCountX2 ~/ 2; s++) {
    final end = data.getUint16(endBase + 2 * s);
    final start = data.getUint16(startBase + 2 * s);
    final delta = data.getInt16(deltaBase + 2 * s);
    final rangeOffset = data.getUint16(rangeBase + 2 * s);
    if (start == 0xFFFF) continue;

    for (var c = start; c <= end; c++) {
      int glyph;
      if (rangeOffset == 0) {
        glyph = (c + delta) & 0xFFFF;
      } else {
        final at = rangeBase + 2 * s + rangeOffset + 2 * (c - start);
        if (at + 2 > bytes.length) continue;
        glyph = data.getUint16(at);
        if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
      }
      if (glyph != 0) codepoints.add(c);
    }
  }

  return codepoints;
}
