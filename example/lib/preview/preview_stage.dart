/// Renders a subtree as if it were running in a smaller viewport.
library;

import 'package:flutter/material.dart';

import 'viewport_spec.dart';

/// Lays [child] out at [spec]'s size, and tells it that is the whole screen.
///
/// **Two things happen here and they are not the same thing.**
///
/// The `SizedBox` is what makes the table narrow. `flutter_table_plus` resolves
/// its column widths from its own `constraints.maxWidth` — the `LayoutBuilder`
/// in `flutter_table_plus.dart` — and reads `MediaQuery` exactly once, for the
/// text scaler, never for the size. So for the table, the constraint alone is
/// the whole story.
///
/// The `MediaQuery` override is for everything *else* in the frame. A recipe or
/// a scenario is consumer code, and consumer code is entitled to branch on
/// `MediaQuery.of(context).size` — a phone preview that reported the desktop
/// window's width would make that branch take the wrong arm and would do it
/// silently, since nothing about the table would look wrong.
///
/// The earlier claim that the override was needed to make the *table* behave was
/// measured and is false. The override is kept for the reason above, which is
/// the real one.
///
/// **Scale stays at 1.0.** Drag selection reads pointer positions in one
/// viewport-local frame, and its rubber-band geometry and auto-scroll timer are
/// written against that frame; putting the stage under a transform would put
/// all three in question. When a viewport is wider than the space available,
/// this scrolls rather than scaling.
class PreviewStage extends StatelessWidget {
  const PreviewStage({
    super.key,
    required this.spec,
    required this.child,
  });

  final ViewportSpec spec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final host = MediaQuery.of(context);

    return MediaQuery(
      // Size alone is not the device. A frame that claims to be a phone while
      // carrying the desktop window's zero insets is telling a consumer's
      // `SafeArea` there is nothing to avoid. The preview is not a device
      // simulator and does not pretend to know a notch's height — so it reports
      // no insets rather than the host's, and says so here rather than leaving
      // the next reader to wonder which it inherited.
      data: host.copyWith(
        size: spec.size,
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: SizedBox.fromSize(
        size: spec.size,
        child: child,
      ),
    );
  }
}

/// Chooses which [ViewportSpec] the stage is showing.
class ViewportBar extends StatelessWidget {
  const ViewportBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ViewportSpec selected;
  final ValueChanged<ViewportSpec> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        for (final v in ViewportSpec.values)
          ButtonSegment<String>(
            value: v.id,
            icon: Icon(_iconFor(v)),
            label: Text(v.label),
          ),
      ],
      selected: {selected.id},
      showSelectedIcon: false,
      onSelectionChanged: (ids) => onChanged(ViewportSpec.byId(ids.first)),
    );
  }

  static IconData _iconFor(ViewportSpec v) => switch (v.id) {
        'desktop' => Icons.desktop_windows_outlined,
        'tablet' => Icons.tablet_mac_outlined,
        _ => Icons.smartphone_outlined,
      };
}
