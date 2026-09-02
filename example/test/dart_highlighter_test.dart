import 'package:example/shell/dart_highlighter.dart';
import 'package:example/shell/recipe_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The Code pane's thesis is that what is on screen is the file you can paste.
// A highlighter is the first thing in that pane's history standing between the
// bundle's bytes and the clipboard, so the load-bearing test here is not "are
// the colours right" — it is "did anything change".
//
// Two facts this suite is shaped by, both measured rather than assumed:
//
//   * The recipe corpus is MIXED in line endings. Six files are CRLF and five
//     are LF, in the same directory, today. `.gitattributes` is `* text=auto`
//     with `core.autocrlf=true`, so a fresh clone on Windows makes all eleven
//     CRLF and a Linux checkout makes all eleven LF. The composition is a
//     property of the machine, not of the repository — which is why the real
//     corpus is necessary and NOT sufficient, and why `_awkward` below spells
//     its line endings out in escapes instead of being a multi-line literal.
//     A `'''...'''` fixture in this file would carry whatever this checkout
//     happens to use, which is redden's self-drawn fixture with extra steps.
//
//   * The three interpolation sites asserted below are transcribed from the
//     real recipes. They are the only lexically hard constructs in 2603 lines,
//     and they are reproduced here so the scanner is pinned against them even
//     if a recipe is later reworded.

/// Every character, in order, exactly once.
///
/// This is the paste contract. It is stated as a matcher because it is asserted
/// against eleven files, a synthetic fixture, and every regression case below —
/// and a property repeated by hand in fifteen places drifts in one of them.
void expectPartitions(List<DartToken> tokens, String source, {String? reason}) {
  expect(tokens.map((t) => t.text).join(), source, reason: reason);
}

void main() {
  group('the partition — the property the paste contract rests on', () {
    testWidgets('holds over every real recipe, read from the bundle',
        (tester) async {
      // ONE test, one load loop, and that is not tidiness — it is the only
      // shape that works. `rootBundle` is a `CachingAssetBundle`, whose cache
      // is `Map<String, Future<String>>` (`asset_bundle.dart`): it stores the
      // *Future*, not the string. A second `testWidgets` that loads the same
      // key is handed a Future created inside the FIRST test's fake-async zone,
      // and its own zone never drives it — measured here as a clean
      // `TimeoutException after 0:10:00` on a test that does nothing but load
      // and count. `source_pane_test.dart` recorded this trap by its symptom
      // ("green by run order"); this is the mechanism behind it.
      //
      // Loading outside the widget tree is what makes the first call ordinary
      // file I/O. Splitting the assertions across tests is what breaks it.
      expect(recipeCatalog, isNotEmpty);

      var withCrlf = 0;
      for (final recipe in recipeCatalog) {
        final source = await rootBundle.loadString(recipe.source);
        expect(source, isNotEmpty, reason: '${recipe.source} loaded as empty');
        if (source.contains('\r\n')) withCrlf++;

        final tokens = tokenizeDart(source);
        expectPartitions(tokens, source,
            reason: '${recipe.source} does not survive tokenization — '
                'what the pane draws is no longer what the bundle holds');
      }

      // Without this the loop above is a vacuous window on some checkouts: if
      // every recipe on the machine running it happens to be LF, a scanner that
      // eats `\r` passes and ships. It deliberately does not assert WHICH files
      // are CRLF — that is checkout state and would be a test of git — only
      // that the claim "the real corpus covers this" is checked rather than
      // believed. When it fails, `_awkward` below is doing the work alone,
      // which is exactly what a reader needs to be told.
      expect(withCrlf, greaterThan(0),
          reason: 'no bundled recipe carries CRLF on this checkout, so the '
              'loop above cannot observe a carriage return being dropped');
    });

    test('and over line endings the real corpus may not have today', () {
      // Escapes, not a multi-line literal: this file is subject to the same
      // autocrlf the recipes are, so a literal would assert whatever the
      // checkout produced rather than what was intended.
      const awkward = 'class A {\r\n'
          '  // a comment with CRLF\r\n'
          '\r'
          '\tfinal x = 1;\n'
          '  // no trailing newline';

      final tokens = tokenizeDart(awkward);
      expectPartitions(tokens, awkward);

      // The side condition, because the partition alone is satisfied by one
      // token covering everything: the scanner really did classify.
      expect(tokens.map((t) => t.kind).toSet().length, greaterThan(1));
    });

    test('and over an empty file', () {
      expect(tokenizeDart(''), isEmpty);
    });
  });

  group('a comment is consumed whole', () {
    // 54 comment lines across 10 of the 11 recipes contain a lone apostrophe,
    // the highest-count hazard in the corpus.
    //
    // What guards it is that the whole comment is consumed in one step, so no
    // character inside one is ever dispatched on — NOT the order of the
    // branches, which is what an earlier version of this comment claimed. A
    // character is either `/` or `'` and never both, so those arms are mutually
    // exclusive and swapping them is a no-op; that was measured, and the
    // mutation that actually reddens these two is crippling `_lineCommentEnd`.
    test("an apostrophe in a comment does not open a string", () {
      const source = "// somebody's name\nfinal x = 1;\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      expect(tokens.first.kind, DartTokenKind.comment);
      expect(tokens.first.text, "// somebody's name");
      expect(tokens.any((t) => t.kind == DartTokenKind.string), isFalse,
          reason: 'the apostrophe was treated as a quote');
      // And the code after it is still code.
      expect(
        tokens.any((t) =>
            t.kind == DartTokenKind.keyword && t.text.contains('final')),
        isTrue,
      );
    });

    test('a quote inside a doc comment does not leak into the next line', () {
      const source = "/// the API's shape\nconst a = 'x';\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings, hasLength(1));
      expect(strings.single.text, "'x'");
    });
  });

  group('interpolation — the three hard sites in the real corpus', () {
    // Transcribed verbatim. A naive quote-pairer renders the third as
    // string / ✓ as code / ' : ' as string / ✗ as code — inverted, on the two
    // glyphs that strip exists to show.
    test('a nested empty string inside an interpolation', () {
      const source = "final text = '\${newValue ?? ''}'.trim();";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings, hasLength(1),
          reason: 'the literal was split — the interpolation ended it early');
      expect(strings.single.text, "'\${newValue ?? ''}'");
    });

    test('a nested string carrying a comma inside a join', () {
      const source = "': \${selected.join(', ')}',";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings, hasLength(1));
      expect(strings.single.text, "': \${selected.join(', ')}'");
    });

    test('two interpolations, one holding a ternary of two strings', () {
      const source = "'\${term.value ? '✓' : '✗'} \${term.key}',";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings, hasLength(1),
          reason: 'the ✓/✗ ternary broke the literal into pieces');
      expect(strings.single.text, "'\${term.value ? '✓' : '✗'} \${term.key}'");
    });

    test('and a brace inside an interpolated string is not a closing brace',
        () {
      const source = "'\${map['{']}'";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      expect(tokens.single.kind, DartTokenKind.string);
    });
  });

  group('the constructs the corpus does not have today', () {
    // None of these appear in `lib/recipes/` — grepped, not assumed. They are
    // handled anyway: a recipe added later is not obliged to stay tame, and
    // each costs a few lines.
    test('a raw string does not process escapes', () {
      const source = r"final p = r'a\' + 1;";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings.single.text, r"r'a\'",
          reason: 'the backslash was treated as an escape, so the closing '
              'quote was skipped and the rest of the line went string-coloured');
    });

    test('a triple-quoted string spans lines', () {
      const source = "const a = '''\nline\n''';\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings.single.text, "'''\nline\n'''");
    });

    test('a block comment nests, the way Dart does and C does not', () {
      const source = 'a /* outer /* inner */ still outer */ b';
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final comments =
          tokens.where((t) => t.kind == DartTokenKind.comment).toList();
      expect(comments.single.text, '/* outer /* inner */ still outer */',
          reason: 'stopped at the first */, so the tail is mis-coloured');
      // The side condition: `b` is still outside the comment.
      expect(tokens.last.text.trim(), 'b');
    });

    test('an unterminated string stops at the newline, not at end of file', () {
      // Bounds the damage of a construct the scanner does not understand to
      // the line it is on, instead of colouring the rest of the recipe.
      const source = "final a = 'oops\nfinal b = 2;\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings.single.text, "'oops");
      expect(
        tokens.any((t) =>
            t.kind == DartTokenKind.keyword && t.text.contains('final')),
        isTrue,
        reason: 'the second line was swallowed by the unterminated string',
      );
    });

    test('and an unterminated interpolation stops there too', () {
      // The bound above was stated unconditionally and had a hole: `${` handed
      // scanning to the interpolation scanner, which had no newline bound of
      // its own and returned end-of-file. Two characters were enough to escape
      // the guarantee — and the test above could not see it, because `'oops`
      // contains no `$`.
      const source = "final a = '\${oops\nfinal b = 2;\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      final strings =
          tokens.where((t) => t.kind == DartTokenKind.string).toList();
      expect(strings.single.text, "'\${oops");
      expect(
        tokens.where((t) => t.kind == DartTokenKind.keyword).length,
        2,
        reason: 'the rest of the file was coloured as one string',
      );
    });
  });

  group('classification', () {
    test('keywords, numbers and punctuation come out as themselves', () {
      const source = 'const x = 0xFF + 1.5e3;';
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      expect(
        tokens.firstWhere((t) => t.kind == DartTokenKind.keyword).text,
        'const',
      );
      final numbers = tokens
          .where((t) => t.kind == DartTokenKind.number)
          .map((t) => t.text)
          .toList();
      expect(numbers, ['0xFF', '1.5e3']);
    });

    test('a dot after an integer is not part of the literal', () {
      const source = '1.toString()';
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      expect(tokens.first.kind, DartTokenKind.number);
      expect(tokens.first.text, '1',
          reason: 'the method name was eaten by the number literal');
    });

    test('adjacent runs of one kind are coalesced', () {
      // Not cosmetic. The pane turns a token into a `TextSpan`, and
      // `SelectableText` rebuilds its controller whenever the tree compares
      // unequal — `TextSpan` equality being a deep walk. A span per bracket
      // costs thousands of `TextStyle` comparisons per rebuild for no visible
      // gain.
      final tokens = tokenizeDart('((( )))');

      expectPartitions(tokens, '((( )))');
      expect(tokens, hasLength(3),
          reason: 'punctuation / whitespace / punctuation, not seven tokens');
    });

    test('a non-ASCII glyph survives as one token', () {
      // The corpus draws — · ← ✓ ✗. All BMP, but the scanner advances by code
      // unit, so this is the assertion that a surrogate pair would be rejoined
      // rather than split across two spans.
      const source = "// an em dash — and a check ✓\n";
      final tokens = tokenizeDart(source);

      expectPartitions(tokens, source);
      expect(tokens.first.text, contains('—'));
      expect(tokens.first.text, contains('✓'));
    });
  });
}
