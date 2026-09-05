/// A Dart tokenizer for the Code pane — kinds only, never colours.
///
/// **This file imports nothing.** Not Flutter, not `dart:*`. That is the seam:
/// the pane decides what a kind looks like, and this decides what a kind *is*,
/// so the hard part is a pure function that a test can drive with no widget and
/// no pump. A tokenizer that knew about `ColorScheme` would be a tokenizer you
/// could only test by rendering it.
///
/// ## The property that matters more than the colours
///
/// [tokenizeDart] returns a **partition**: concatenating every token's text
/// reproduces the input byte for byte. The Code pane's whole thesis is that
/// what is on screen is the file you can paste (`shell_destination.dart` —
/// *"not a general source viewer; it is the affordance of the pasteable
/// claim"*), and a highlighter is the first thing in this pane's history that
/// stands between the bundle's bytes and the clipboard.
///
/// The partition is **structural rather than asserted**: the scanner records
/// end offsets into the source and the tokens are cut from those offsets, so
/// there is no path on which a character is dropped, duplicated or rewritten.
/// A token's text is always `source.substring(previousEnd, thisEnd)`.
///
/// Two ways a highlighter breaks the paste that this shape rules out by
/// construction, both of which a hand-written scanner reaches for naturally:
/// splitting on `\n` and re-joining (which silently normalises CRLF — which
/// this corpus carries on any Windows checkout, `.gitattributes` being
/// `* text=auto`), and lower-casing a word to match a keyword and emitting the
/// lower-cased form.
///
/// ## A comment is consumed whole, and that is the correctness argument
///
/// Measured 2026-09-02 over the 11 recipes: 54 comment lines contain a lone
/// apostrophe (`somebody's`, `API's`) — a number that goes stale on any comment
/// edit, dated so it reads as the measurement it is rather than as a current
/// fact. A scanner that examined characters one at a time would open a string
/// on every one of them, running to end of line, and — if it carried string
/// state across lines — to the next apostrophe several paragraphs down. That is
/// 54 sites against the 3 that the interpolation handling exists for, and it is
/// the one that would make the pane look broken at a glance.
///
/// What prevents it is that [_lineCommentEnd] and [_blockCommentEnd] consume
/// the **entire** comment in one step, so no character inside one is ever
/// dispatched on. **It is not the order of the branches**, and an earlier
/// version of this comment said it was: a character is either `/` or `'` and
/// never both, so the two arms are mutually exclusive and their order in the
/// chain is a no-op. That was measured — reversing them changed nothing, and
/// the mutation had to cripple [_lineCommentEnd] instead before the guarding
/// test would redden. `docs/agents/lessons.md` records it.
///
/// ## What the real corpus actually contains
///
/// Grepped over `lib/recipes/` 2026-09-02, not assumed: **no** raw strings,
/// **no** triple-quoted strings, **no** block comments, **no** escaped quotes,
/// and **no** `//` inside a string literal. All five are handled anyway — they
/// cost a few lines each and a recipe added later is not required to stay tame,
/// which is also why none of these counts is a guard.
///
/// What the corpus *did* contain, at that date, is three
/// nested-string-in-interpolation sites, in three different files:
///
/// ```dart
/// final text = '${newValue ?? ''}'.trim();          // cell_editing_recipe
/// : 'selectedRows: ${selected.join(', ')}',         // merged_rows_recipe
/// '${term.value ? '✓' : '✗'} ${term.key}',          // drag_selection_recipe
/// ```
///
/// Naive quote-pairing renders the third as string / `✓` as code / ` : ` as
/// string / `✗` as code — inverted, on the two glyphs that strip exists to
/// show. So [_stringEnd] and [_interpolationEnd] are **mutually recursive**: an
/// interpolation is scanned with a brace counter that itself understands
/// nested strings. A whole literal is one token, interpolations included.
library;

/// What a run of characters is, for the purpose of drawing it differently.
///
/// Deliberately coarse. Anything finer — distinguishing a type from a variable,
/// a method call from a field — needs a parser rather than a scanner, and a
/// half-right answer about what a name *means* is worse here than no answer,
/// because it is wrong in a way a reader would believe.
enum DartTokenKind {
  /// Identifiers, whitespace, and anything unclassified.
  plain,

  /// `//` to end of line, and `/* */` including nested pairs.
  comment,

  /// A reserved word, a built-in identifier, or a contextual keyword.
  keyword,

  /// A string literal in full, interpolations included.
  string,

  /// An integer, double, or hex literal.
  number,

  /// Brackets, operators, separators.
  punctuation,
}

/// A run of source text and what it is.
class DartToken {
  const DartToken(this.text, this.kind);

  /// The exact characters, cut from the source. Never rewritten.
  final String text;

  final DartTokenKind kind;

  @override
  String toString() => 'DartToken(${kind.name}, ${text.length} chars)';
}

/// Splits [source] into a partition of typed runs.
///
/// Adjacent runs of the same kind are coalesced, which is not cosmetic: the
/// pane turns one token into one `TextSpan`, `SelectableText` rebuilds its
/// controller whenever the span tree compares unequal, and `TextSpan` equality
/// is a deep walk. Emitting a span per bracket would put thousands of
/// `TextStyle` comparisons on every rebuild to no visible end.
List<DartToken> tokenizeDart(String source) {
  // Two parallel lists rather than a token list built as we go: the scanner
  // only ever appends an end offset, so "the tokens tile the source" is a
  // property of the loop rather than something to remember at each branch.
  final kinds = <DartTokenKind>[];
  final ends = <int>[];

  var i = 0;
  while (i < source.length) {
    final c = source.codeUnitAt(i);
    final DartTokenKind kind;

    if (c == _slash && i + 1 < source.length) {
      final next = source.codeUnitAt(i + 1);
      if (next == _slash) {
        kind = DartTokenKind.comment;
        i = _lineCommentEnd(source, i);
      } else if (next == _star) {
        kind = DartTokenKind.comment;
        i = _blockCommentEnd(source, i);
      } else {
        kind = DartTokenKind.punctuation;
        i++;
      }
    } else if (c == _singleQuote || c == _doubleQuote) {
      kind = DartTokenKind.string;
      i = _stringEnd(source, i, raw: false);
    } else if (_isIdentifierStart(c)) {
      final end = _identifierEnd(source, i);
      // `r'...'` — the `r` is a prefix only where an identifier could not have
      // continued, which is exactly when the identifier scan stops on a quote.
      if (end == i + 1 &&
          c == _lowerR &&
          end < source.length &&
          (source.codeUnitAt(end) == _singleQuote ||
              source.codeUnitAt(end) == _doubleQuote)) {
        kind = DartTokenKind.string;
        i = _stringEnd(source, end, raw: true);
      } else {
        kind = _keywords.contains(source.substring(i, end))
            ? DartTokenKind.keyword
            : DartTokenKind.plain;
        i = end;
      }
    } else if (_isDigit(c)) {
      kind = DartTokenKind.number;
      i = _numberEnd(source, i);
    } else if (_isPunctuation(c)) {
      kind = DartTokenKind.punctuation;
      i++;
    } else {
      // Whitespace, and anything outside the classes above — including the
      // halves of a surrogate pair, which arrive as two `plain` runs and are
      // coalesced back into one token below.
      kind = DartTokenKind.plain;
      i++;
    }

    kinds.add(kind);
    ends.add(i);
  }

  final tokens = <DartToken>[];
  var runStart = 0;
  for (var n = 0; n < ends.length; n++) {
    if (n == ends.length - 1 || kinds[n + 1] != kinds[n]) {
      tokens.add(DartToken(source.substring(runStart, ends[n]), kinds[n]));
      runStart = ends[n];
    }
  }
  return tokens;
}

/// End of a `//` comment: the newline itself is **not** part of it.
///
/// A trailing `\r` is, wherever the checkout produced CRLF. That is deliberate
/// — it keeps the carriage return inside a token rather than inventing a rule
/// about where a line ends, and the partition protects the paste either way.
///
/// **Whether any recipe carries CRLF today is checkout state, not a fact about
/// this repository.** `.gitattributes` is `* text=auto`, so a fresh Windows
/// clone makes all eleven CRLF and a Linux one makes all eleven LF; this
/// working tree happens to hold a mix. `dart_highlighter_test.dart` asserts
/// only that *at least one* still does, and says why it refuses to assert more.
int _lineCommentEnd(String source, int i) {
  var j = i;
  while (j < source.length && source.codeUnitAt(j) != _newline) {
    j++;
  }
  return j;
}

/// End of a `/* */` comment, counting nested pairs.
///
/// Dart nests block comments where C does not, so `/* /* */ */` is one comment
/// and a scanner that stops at the first `*/` leaves the tail of the file
/// mis-coloured. The corpus contains none today; this costs four lines.
int _blockCommentEnd(String source, int i) {
  var j = i + 2;
  var depth = 1;
  while (j + 1 < source.length) {
    if (source.codeUnitAt(j) == _slash && source.codeUnitAt(j + 1) == _star) {
      depth++;
      j += 2;
    } else if (source.codeUnitAt(j) == _star &&
        source.codeUnitAt(j + 1) == _slash) {
      depth--;
      j += 2;
      if (depth == 0) return j;
    } else {
      j++;
    }
  }
  return source.length;
}

/// End of a string literal that starts at [i], interpolations included.
///
/// [raw] suppresses escape handling: in `r'a\'` the backslash is a character,
/// so consuming two would run past the closing quote.
///
/// An unterminated single-quoted string stops at the newline rather than
/// running to end of file. That bounds the damage of a construct this scanner
/// does not understand to the line it appears on, instead of colouring the rest
/// of the recipe as a string.
int _stringEnd(String source, int i, {required bool raw}) {
  final quote = source.codeUnitAt(i);
  final triple = i + 2 < source.length &&
      source.codeUnitAt(i + 1) == quote &&
      source.codeUnitAt(i + 2) == quote;
  var j = i + (triple ? 3 : 1);

  while (j < source.length) {
    final c = source.codeUnitAt(j);

    if (!raw && c == _backslash) {
      j += 2;
      continue;
    }
    if (!raw && c == _dollar && j + 1 < source.length &&
        source.codeUnitAt(j + 1) == _openBrace) {
      // The newline bound has to be handed down, or `${` is a hole in it: an
      // unclosed interpolation would run to end of file and colour the rest of
      // the recipe as a string, which is precisely what the bound below exists
      // to stop. A triple-quoted literal genuinely may span lines, so only it
      // is exempt.
      j = _interpolationEnd(source, j + 2, stopAtNewline: !triple);
      continue;
    }
    if (c == quote) {
      if (!triple) return j + 1;
      if (j + 2 < source.length &&
          source.codeUnitAt(j + 1) == quote &&
          source.codeUnitAt(j + 2) == quote) {
        return j + 3;
      }
    }
    if (!triple && c == _newline) return j;
    j++;
  }
  return source.length;
}

/// End of a `${...}` interpolation, given [j] just past the opening brace.
///
/// Mutually recursive with [_stringEnd], and that is the point: the brace
/// counter alone gets `'${selected.join(', ')}'` wrong, because the `'` inside
/// would end the outer literal. Handing nested quotes back to the string
/// scanner is what makes the three real sites in this repo come out whole.
int _interpolationEnd(String source, int j, {required bool stopAtNewline}) {
  var depth = 1;
  while (j < source.length) {
    final c = source.codeUnitAt(j);
    if (c == _singleQuote || c == _doubleQuote) {
      j = _stringEnd(source, j, raw: false);
      continue;
    }
    // Inherited from the enclosing literal. Without it, `'${oops` would return
    // `source.length` and the newline bound in [_stringEnd] would never be
    // reached — an unbounded run through a branch whose entire purpose is to
    // bound one.
    if (stopAtNewline && c == _newline) return j;
    if (c == _openBrace) {
      depth++;
    } else if (c == _closeBrace) {
      depth--;
      if (depth == 0) return j + 1;
    }
    j++;
  }
  return source.length;
}

/// End of a numeric literal. Conservative: over-consuming mis-colours a
/// character, and the partition is unaffected either way.
int _numberEnd(String source, int i) {
  var j = i;
  if (source.codeUnitAt(j) == _zero && j + 1 < source.length) {
    final next = source.codeUnitAt(j + 1);
    if (next == _lowerX || next == _upperX) {
      j += 2;
      while (j < source.length && _isHexDigit(source.codeUnitAt(j))) {
        j++;
      }
      return j;
    }
  }
  while (j < source.length && _isDigit(source.codeUnitAt(j))) {
    j++;
  }
  // A `.` is part of the number only when a digit follows it, so `1.toString()`
  // keeps its method name out of the literal.
  if (j + 1 < source.length &&
      source.codeUnitAt(j) == _dot &&
      _isDigit(source.codeUnitAt(j + 1))) {
    j++;
    while (j < source.length && _isDigit(source.codeUnitAt(j))) {
      j++;
    }
  }
  if (j < source.length &&
      (source.codeUnitAt(j) == _lowerE || source.codeUnitAt(j) == _upperE)) {
    var k = j + 1;
    if (k < source.length &&
        (source.codeUnitAt(k) == _plus || source.codeUnitAt(k) == _minus)) {
      k++;
    }
    if (k < source.length && _isDigit(source.codeUnitAt(k))) {
      j = k;
      while (j < source.length && _isDigit(source.codeUnitAt(j))) {
        j++;
      }
    }
  }
  return j;
}

int _identifierEnd(String source, int i) {
  var j = i;
  while (j < source.length && _isIdentifierPart(source.codeUnitAt(j))) {
    j++;
  }
  return j;
}

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

bool _isHexDigit(int c) =>
    _isDigit(c) ||
    (c >= 0x41 && c <= 0x46) ||
    (c >= 0x61 && c <= 0x66) ||
    c == _underscore;

bool _isIdentifierStart(int c) =>
    (c >= 0x41 && c <= 0x5A) ||
    (c >= 0x61 && c <= 0x7A) ||
    c == _underscore ||
    c == _dollar;

bool _isIdentifierPart(int c) => _isIdentifierStart(c) || _isDigit(c);

/// ASCII punctuation, minus the characters handled earlier in the scan.
bool _isPunctuation(int c) =>
    (c >= 0x21 && c <= 0x2F) ||
    (c >= 0x3A && c <= 0x40) ||
    (c >= 0x5B && c <= 0x60) ||
    (c >= 0x7B && c <= 0x7E);

const _newline = 0x0A;
const _dollar = 0x24;
const _singleQuote = 0x27;
const _plus = 0x2B;
const _minus = 0x2D;
const _dot = 0x2E;
const _slash = 0x2F;
const _zero = 0x30;
const _star = 0x2A;
const _doubleQuote = 0x22;
const _upperE = 0x45;
const _upperX = 0x58;
const _backslash = 0x5C;
const _underscore = 0x5F;
const _lowerE = 0x65;
const _lowerR = 0x72;
const _lowerX = 0x78;
const _openBrace = 0x7B;
const _closeBrace = 0x7D;

/// Dart's reserved words, built-in identifiers, and the contextual keywords a
/// reader of this corpus would expect to see marked.
///
/// A word here is styled wherever it appears, including as a variable named
/// `show` or a field named `base`. That is the accepted cost of a scanner: the
/// alternative is knowing what a name refers to, which is a parser.
const _keywords = <String>{
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
  'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
  'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
  'external', 'factory', 'false', 'final', 'finally', 'for', 'Function', 'get',
  'hide', 'if', 'implements', 'import', 'in', 'interface', 'is', 'late',
  'library', 'mixin', 'new', 'null', 'on', 'operator', 'part', 'required',
  'rethrow', 'return', 'sealed', 'set', 'show', 'static', 'super', 'switch',
  'sync', 'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'when',
  'while', 'with', 'yield',
};
