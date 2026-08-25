/// A recipe's own source, read back out of the bundle it shipped in.
library;

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

  /// Platform monospace faces, in the order they are likely to exist.
  ///
  /// Not `GoogleFonts.firaCode`, which the playground uses: that fetches over
  /// the network on first use, and a pane whose whole job is to show bytes
  /// already on disk should not need the network to draw them.
  static const monoFallback = [
    'Consolas',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PathBar(path: widget.assetPath),
        Expanded(
          child: FutureBuilder<String>(
            future: _source,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _Failure(
                  path: widget.assetPath,
                  error: snapshot.error!,
                );
              }
              if (!snapshot.hasData) {
                // Deliberately not a spinner. The asset is in this app's own
                // bundle, so the wait is a frame or two and an indicator would
                // only flash — and an indeterminate one animates forever, which
                // means `pumpAndSettle` never settles and every widget test
                // that reaches this pane times out instead of failing on
                // something informative. The path bar above is already on
                // screen, so the pane is not blank.
                return const SizedBox.shrink();
              }
              return _Code(source: snapshot.data!, scheme: scheme);
            },
          ),
        ),
      ],
    );
  }
}

class _PathBar extends StatelessWidget {
  const _PathBar({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              path,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontFamilyFallback: SourcePane.monoFallback,
                color: scheme.onSurfaceVariant,
              ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: SelectableText(
              widget.source,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
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

