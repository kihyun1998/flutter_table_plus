/// A recipe's own source, read back out of the bundle it shipped in.
library;

import 'dart:async';

import 'package:example/shell/dart_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders the bytes of [assetPath], not a copy of them.
///
/// A snippet pasted into a string drifts from the code it claims to show, and
/// this repo has no CI to notice. Reading the bundled file makes the displayed
/// code and the running code the same thing by construction — the pane cannot
/// be stale, because there is nothing for it to be stale *against*.
///
/// **The path on screen is part of the evidence.** Without it the pane is a
/// block of code that could have come from anywhere; with it a reader can open
/// the file and compare.
///
/// One thing it cannot do: show an edit made while the app is running.
/// [AssetBundle.loadString] caches, so the pane holds the bytes that shipped
/// until a restart clears them. That is what makes the ticket's visual check —
/// edit a comment, hot restart, see it — a real test of where the text came
/// from.
class SourcePane extends StatefulWidget {
  const SourcePane({
    super.key,
    required this.assetPath,
    this.bundle,
  });

  /// The asset key, which is the path exactly as `pubspec.yaml` declares it.
  final String assetPath;

  /// The monospace face this pane asks for.
  ///
  /// **Naming a family is what displaces the inherited one**, and that is the
  /// whole reason this constant exists apart from [monoFallback]. Flutter
  /// resolves `fontFamily` first and reaches `fontFamilyFallback` only for
  /// glyphs that family lacks; a `TextStyle` with `inherit: true` — the default
  /// — merges the ambient `DefaultTextStyle`, which carries
  /// [exampleChromeFont] from `ThemeData.fontFamily`. So a style that lists
  /// only fallbacks renders in the proportional chrome font, and the list below
  /// is reached by nothing but the few characters Pretendard's subset is
  /// missing. This pane did exactly that from #104 until #123.
  static const monoFamily = 'Consolas';

  /// Platform monospace faces, in the order they are likely to exist, for where
  /// [monoFamily] does not.
  ///
  /// [monoFamily] is deliberately **not** repeated here: a family that is also
  /// the first fallback reads as belt-and-braces and is the shape that hid the
  /// bug, because `monoFallback.first` looked like the family was set.
  ///
  /// Not `GoogleFonts.firaCode`, which the playground uses: that fetches over
  /// the network on first use, and a pane whose whole job is to show bytes
  /// already on disk should not need the network to draw them.
  static const monoFallback = [
    'SF Mono',
    'Menlo',
    'DejaVu Sans Mono',
    'Liberation Mono',
    'monospace',
  ];

  /// The bundle to read from. Defaults to [rootBundle]; injected in tests so
  /// the failure path can be driven, because a pane that renders empty on error
  /// is indistinguishable from a pane that loaded an empty file.
  final AssetBundle? bundle;

  @override
  State<SourcePane> createState() => _SourcePaneState();
}

class _SourcePaneState extends State<SourcePane> {
  late Future<String> _source;

  @override
  void initState() {
    super.initState();
    _source = _load();
  }

  @override
  void didUpdateWidget(SourcePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching recipes without this leaves the previous recipe's source on
    // screen under the new recipe's path — the one failure mode this pane
    // exists to make impossible.
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.bundle != widget.bundle) {
      // A block, not an arrow: `() => _source = _load()` returns the assigned
      // Future, and `setState` asserts on a callback that returns one.
      setState(() {
        _source = _load();
      });
    }
  }

  Future<String> _load() =>
      (widget.bundle ?? rootBundle).loadString(widget.assetPath);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // The `FutureBuilder` wraps the whole pane rather than just the body, and
    // that is the copy control's doing. The path bar still draws in all three
    // states — which is what keeps the pane from being blank while the asset
    // loads — but it now also *sees* the snapshot.
    //
    // Hosting the control in a bar drawn outside the boundary was the obvious
    // arrangement and is the broken one: the same property that makes the bar
    // a good "not blank" affordance makes it a bad host for anything needing
    // the data. A copy button there is live over `_Failure`'s "Could not read",
    // copying nothing, silently — which is the failure `_Failure` exists to
    // refuse, arriving through the control added to complete the pane.
    return FutureBuilder<String>(
      future: _source,
      builder: (context, snapshot) {
        // **`ConnectionState.done`, never `hasData`.** `AsyncSnapshot.inState`
        // carries `data`, `error` and `stackTrace` across a re-subscribe —
        // documented in `async.dart` as persisting *"even if the new state is
        // `ConnectionState.none`"* — and `FutureBuilder.didUpdateWidget` does
        // exactly that when the future is replaced. So for at least one frame
        // after the path changes, the snapshot reports `waiting` while still
        // holding the PREVIOUS recipe's bytes.
        //
        // Reading `hasData` there puts file A's source on screen under file B's
        // path, which is the one failure this pane exists to make impossible,
        // and hands file A's bytes to a copy button labelled B. The path bar
        // is evidence; a control beside it must not contradict it.
        final settled = snapshot.connectionState == ConnectionState.done;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PathBar(
              path: widget.assetPath,
              source: settled ? snapshot.data : null,
            ),
            Expanded(child: _body(snapshot, settled, scheme)),
          ],
        );
      },
    );
  }

  Widget _body(
    AsyncSnapshot<String> snapshot,
    bool settled,
    ColorScheme scheme,
  ) {
    if (settled && snapshot.hasError) {
      return _Failure(path: widget.assetPath, error: snapshot.error!);
    }
    if (!settled || !snapshot.hasData) {
      // Deliberately not a spinner. The asset is in this app's own bundle, so
      // the wait is a frame or two and an indicator would only flash — and an
      // indeterminate one animates forever, which means `pumpAndSettle` never
      // settles and every widget test that reaches this pane times out instead
      // of failing on something informative. The path bar above is already on
      // screen, so the pane is not blank.
      return const SizedBox.shrink();
    }
    return _Code(source: snapshot.data!, scheme: scheme);
  }
}

/// The file's name, and the control that hands you the file.
///
/// **The copy button is not a convenience here.** `shell_destination.dart` says
/// what this pane is: *"not a general source viewer; it is the affordance of
/// the pasteable claim."* A control that performs the paste is that affordance
/// completing itself. (An earlier ticket downgraded it to discoverability and a
/// later one tried to rescue it as a touch-platform capability; both were
/// wrong on the same measurement — `SelectableText` defaults its
/// `contextMenuBuilder` to `AdaptiveTextSelectionToolbar`, so long-press →
/// Select all → Copy already works on Android. The button is worth having for
/// what the pane *is*, not for what the platform lacks.)
class _PathBar extends StatefulWidget {
  const _PathBar({required this.path, required this.source});

  final String path;

  /// The loaded bytes, or `null` while loading and on failure.
  ///
  /// Null is what disables the button rather than hiding it: a control that
  /// vanishes and returns is harder to read than one that is visibly not ready,
  /// and the two states it is null in are exactly the two where copying would
  /// silently yield nothing.
  final String? source;

  @override
  State<_PathBar> createState() => _PathBarState();
}

class _PathBarState extends State<_PathBar> {
  Timer? _confirmation;
  bool _copied = false;

  @override
  void didUpdateWidget(_PathBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // **The confirmation belongs to the file it was shown for.** `SourcePane`
    // sits in a keyless conditional slot in the shell, and opening another
    // recipe does not close the Code view — so the element is reused and this
    // State survives the path change. Without this, copying recipe A and
    // picking recipe B within 1400ms leaves a green "Copied ✓" sitting beside
    // B's path, for a file that was never copied. The pane's own doc-comment
    // calls the path bar *evidence*; this is the bar asserting something false
    // about the file it names, which is worse than offering no confirmation.
    if (oldWidget.path != widget.path) {
      _confirmation?.cancel();
      _copied = false;
    }
  }

  @override
  void dispose() {
    // A pending timer outliving the tree fails the test that pumped it, which
    // is the correct behaviour and the reason this is not optional.
    _confirmation?.cancel();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.source!));
    setState(() => _copied = true);
    _confirmation?.cancel();
    // Finite on purpose. The pane refuses an indeterminate indicator elsewhere
    // for a harness reason — `pumpAndSettle` never settles on one — and the
    // same rule applies to feedback.
    _confirmation = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ready = widget.source != null;

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.path,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontFamily: SourcePane.monoFamily,
                fontFamilyFallback: SourcePane.monoFallback,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            // A Material tooltip, deliberately: `just_tooltip` arbitrates the
            // *table's* tooltips and this is app chrome with no `JustTooltip`
            // ancestor to nest inside. Reaching for the package's tooltip here
            // would import an arbitration question that does not exist.
            tooltip: _copied ? 'Copied' : 'Copy the file',
            iconSize: 17,
            visualDensity: VisualDensity.compact,
            onPressed: ready ? _copy : null,
            icon: Icon(
              _copied ? Icons.check : Icons.copy_all_outlined,
              color: _copied ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The failure state, drawn rather than swallowed.
///
/// An unreadable asset is a build problem — a missing `pubspec.yaml`
/// declaration, or a stale `build/` bundle, which produce the same message and
/// are told apart by rebuilding. Rendering nothing would make it look like an
/// empty file.
class _Failure extends StatelessWidget {
  const _Failure({required this.path, required this.error});

  final String path;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 28),
            const SizedBox(height: 12),
            Text(
              'Could not read $path',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: scheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Code extends StatefulWidget {
  const _Code({required this.source, required this.scheme});

  final String source;
  final ColorScheme scheme;

  @override
  State<_Code> createState() => _CodeState();
}

class _CodeState extends State<_Code> {
  /// Explicit, not `primary: true`.
  ///
  /// [SelectableText] builds an [EditableText], which brings a vertical
  /// [Scrollable] of its own. With `primary` set, two scroll views claim the
  /// same [PrimaryScrollController] and the framework asserts. Naming the
  /// controller also gives the [Scrollbar] something unambiguous to track.
  final _controller = ScrollController();

  /// Cached because tokens are the expensive, stable half; the styles are the
  /// cheap half that has to follow the theme.
  ///
  /// **It removes the re-scan and nothing else, and an earlier version of this
  /// comment claimed more.** `SelectableText.didUpdateWidget` rebuilds its
  /// controller whenever `textSpan != oldWidget.textSpan`, and `TextSpan`
  /// equality short-circuits only on `identical` — while [build] allocates a
  /// fresh span per token every time. So the deep comparison happens whether or
  /// not the tokens were cached, and caching them cannot be justified by it.
  /// Avoiding *that* would mean caching the built tree, which would then have
  /// to be invalidated on every theme change.
  ///
  /// It is not worth doing: measured 2026-09-02, the largest recipe produces
  /// **1436** spans, and only one recipe is on screen at a time.
  late List<DartToken> _tokens;

  @override
  void initState() {
    super.initState();
    _tokens = tokenizeDart(widget.source);
  }

  @override
  void didUpdateWidget(_Code oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only the source. A brightness change re-styles the same tokens.
    if (oldWidget.source != widget.source) {
      _tokens = tokenizeDart(widget.source);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// What a kind looks like — the policy half of the seam, injected here so the
  /// tokenizer never learns what a `ColorScheme` is.
  ///
  /// **Hue-free, and that is a constraint rather than a taste.**
  /// `example_theme.dart` states it outright: *"The chrome carries no hue at
  /// all… A chrome with an accent of its own would put two colours on screen
  /// and lose that"*, and the scheme is `DynamicSchemeVariant.monochrome`
  /// seeded from black, so there is no hue here to take even if one were
  /// wanted.
  ///
  /// `table_palette.dart` reaches the same conclusion from the other side and
  /// is worth not confusing with this one: it says the **table's** colours
  /// cannot be *derived* from the app's `ColorScheme`, which is the measurement
  /// behind #112. Chrome can and does derive from it — that is the difference
  /// between a demo's frame and the thing the demo is showing.
  ///
  /// **Comments are not dimmed, which inverts the usual mapping.** A
  /// conventional highlighter fades comments and lights up keywords, because in
  /// most code the comments are asides. Measured 2026-09-02 over the eleven
  /// recipes, they are 762 of 2603 lines — 29%, and they are the teaching — so
  /// slant separates them while leaving them at full contrast, and what recedes
  /// instead is the punctuation.
  ///
  /// **No leaf sets `fontFamily`.** The mono face is set once on the
  /// [SelectableText] and inherited; a leaf that named a family would render
  /// proportional while the pane's own #123 guard — which reads
  /// `EditableText.style`, the *wrapper* — stayed green.
  TextStyle? _styleFor(DartTokenKind kind) {
    final scheme = widget.scheme;
    return switch (kind) {
      // Inherits the root style. One less object per token, and the root is
      // already the colour plain code should be.
      DartTokenKind.plain => null,
      DartTokenKind.comment => const TextStyle(fontStyle: FontStyle.italic),
      DartTokenKind.keyword => const TextStyle(fontWeight: FontWeight.w600),
      DartTokenKind.string ||
      DartTokenKind.number =>
        TextStyle(color: scheme.onSurfaceVariant),
      DartTokenKind.punctuation => TextStyle(color: scheme.outline),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Code does not wrap — a wrapped line is a different line. So it scrolls on
    // both axes, inside this region and never by moving the shell around it.
    return Scrollbar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              // The root span carries no style of its own: `SelectableText`
              // wraps whatever it is given as `TextSpan(style: style, children:
              // [yours])`, so the face below is what every token inherits and
              // what `EditableText.style` reports.
              TextSpan(
                children: [
                  for (final token in _tokens)
                    TextSpan(text: token.text, style: _styleFor(token.kind)),
                ],
              ),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontFamily: SourcePane.monoFamily,
                fontFamilyFallback: SourcePane.monoFallback,
                color: widget.scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

