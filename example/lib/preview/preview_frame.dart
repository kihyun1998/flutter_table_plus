/// A [PreviewStage] scaled to fit the room it is given, and told how much.
library;

import 'package:flutter/material.dart';

import 'preview_stage.dart';
import 'viewport_spec.dart';

/// Shows a whole viewport at once, shrinking it when it does not fit.
///
/// Seeing *all* of a desktop layout at 0.7× answers "what does this look like on
/// a desktop" — the question the preview exists for. Rendering the same layout
/// at 1:1 and clipping it answers a different, less useful one, and looks like a
/// bug besides.
///
/// **Scaling was measured, not assumed.** An earlier version of this refused to
/// scale on the grounds that a transform above the table put drag selection's
/// viewport-local coordinate frame in question. That was recorded at the time as
/// unproven, and it was wrong: `Transform` applies the inverse to hit testing, so
/// `event.localPosition` reaches the gesture code already in the child's own
/// untransformed frame. A probe at 0.5× dragged rows 0..2 and selected exactly
/// rows 0..2. The earlier evidence had been a test whose own arithmetic mixed
/// scaled screen coordinates with unscaled logical ones.
///
/// It never scales *up*. A phone viewport blown up to fill a desktop pane would
/// be showing something no phone shows.
class PreviewFrame extends StatelessWidget {
  const PreviewFrame({
    super.key,
    required this.spec,
    required this.child,
    this.fit = true,
    this.padding = const EdgeInsets.all(20),
  });

  final ViewportSpec spec;
  final Widget child;

  /// Shrink to fit. When false the viewport renders at 1:1 and the frame
  /// scrolls — real pixels, for when the question is about real pixels.
  final bool fit;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = Size(
          (constraints.maxWidth - padding.horizontal)
              .clamp(1.0, double.infinity),
          (constraints.maxHeight - padding.vertical - _labelHeight)
              .clamp(1.0, double.infinity),
        );

        final scale = fit
            ? [
                1.0,
                available.width / spec.width,
                available.height / spec.height,
              ].reduce((a, b) => a < b ? a : b)
            : 1.0;

        final framed = _Framed(spec: spec, scheme: scheme, child: child);

        final body = scale == 1.0
            ? framed
            : SizedBox(
                width: spec.width * scale,
                height: spec.height * scale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: spec.width,
                    height: spec.height,
                    child: framed,
                  ),
                ),
              );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      body,
                      SizedBox(
                        height: _labelHeight,
                        child: Center(
                          child: Text(
                            _label(scale),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static const _labelHeight = 26.0;

  /// The dimensions, and the factor when there is one.
  ///
  /// Said out loud because a shrunken preview is otherwise indistinguishable
  /// from a small table: the reader has to know these are 1440 logical pixels
  /// drawn at 0.7×, not 1000 pixels drawn honestly.
  String _label(double scale) {
    final size = '${spec.width.toInt()} × ${spec.height.toInt()}';
    if (scale == 1.0) return '$size · 1:1';
    return '$size · ${scale.toStringAsFixed(2)}×';
  }
}

class _Framed extends StatelessWidget {
  const _Framed({
    required this.spec,
    required this.scheme,
    required this.child,
  });

  final ViewportSpec spec;
  final ColorScheme scheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        color: scheme.surface,
      ),
      child: PreviewStage(spec: spec, child: child),
    );
  }
}
