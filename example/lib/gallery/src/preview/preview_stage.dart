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
/// **It also owns an overlay, and that is a third thing.** `Draggable` puts its
/// feedback in `Overlay.of(context)` — the *nearest* one — and `just_tooltip`
/// does the same with its tooltip, going further and reading that overlay's
/// render box to place itself. With no overlay inside the frame, "nearest" is
/// the app's root one, which sits above [PreviewFrame]'s `FittedBox`: the table
/// is drawn at 0.46× and the header cell dragged out of it at 1:1, measured
/// 2026-08-26 at 91.7px against 200px, floating over the whole window at more
/// than twice the size of the row it came from. A real viewport contains its own
/// overlays, so a preview of one has to as well — which is what makes this
/// containment rather than a scaling workaround.
///
/// **This one never scales.** It constrains and it reports; scaling a whole
/// viewport down so all of it is visible is [PreviewFrame]'s job, one layer up.
///
/// An earlier version of this comment said scale must stay at 1.0 because a
/// transform above the table would put drag selection's viewport-local
/// coordinate frame in question. **Measured afterwards and withdrawn:**
/// `Transform` applies the inverse to hit testing, so `event.localPosition`
/// reaches the gesture code already in the child's untransformed frame, and a
/// drag inside a frame rendered at roughly half size selects exactly the rows it
/// crosses. See `test/preview_frame_test.dart`, "interaction survives the
/// scale". The evidence that had looked damning was a test whose own arithmetic
/// mixed scaled screen coordinates with unscaled logical ones.
///
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
        child: _ContainedOverlay(child: child),
      ),
    );
  }
}

/// An [Overlay] whose only entry is [child].
///
/// A `StatefulWidget` because `Overlay.initialEntries` is read once, in
/// `initState` — a fresh `OverlayEntry` handed over on a later build is simply
/// ignored. So the entry is created once, and its builder reads `widget.child`
/// rather than a value captured when it was made. That distinction is the whole
/// of this class: capturing the first child instead freezes the stage on
/// whatever it was showing when the frame opened, with nothing on screen to say
/// why. Measured 2026-08-26 — three existing tests redden, including "its knobs
/// reach the table".
///
/// Nothing here asks the entry to rebuild. It does not need to: this widget's
/// own `build` produces a new `Overlay`, which rebuilds its entries, which
/// re-reads `widget.child`. An explicit `markNeedsBuild` in `didUpdateWidget`
/// was written here first and removed after mutation testing showed it changed
/// nothing.
///
/// There is no `dispose` either. The entry is this overlay's only entry and dies
/// with it; disposing it from here asserts, because an `OverlayEntry` has to
/// leave its `Overlay` before it can be disposed and this one never does.
class _ContainedOverlay extends StatefulWidget {
  const _ContainedOverlay({required this.child});

  final Widget child;

  @override
  State<_ContainedOverlay> createState() => _ContainedOverlayState();
}

class _ContainedOverlayState extends State<_ContainedOverlay> {
  late final OverlayEntry _entry =
      OverlayEntry(builder: (context) => widget.child);

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}

/// Chooses what the stage is showing — one named viewport, or all of them.
///
/// **The selection is an id rather than a [ViewportSpec], because one of the
/// modes is not a viewport.** The wall has no size of its own and no chrome
/// policy, so a fourth `ViewportSpec` would have to invent both. The id is what
/// this control has always dealt in internally, and [ViewportSpec.values] stays
/// the only roster of viewports there is — a second list of the same three,
/// kept in step by hand, is the shape `docs/map/invariant/no-hand-enumeration.md`
/// is about.
class ViewportBar extends StatelessWidget {
  const ViewportBar({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.compact = false,
    this.showsWall = false,
  });

  /// The mode that draws every viewport at once instead of one.
  ///
  /// Lives here rather than on `DeviceWall` so that this file does not have to
  /// import it: the wall builds on the frame, which builds on this stage, and
  /// pulling the id from the far end of that chain would close the loop for a
  /// string.
  static const wallId = 'all';

  static const wallLabel = 'All · side by side';

  /// Either a [ViewportSpec.id] or [wallId].
  final String selectedId;

  final ValueChanged<String> onChanged;

  /// Icons only, with the label moved to the tooltip.
  ///
  /// The labelled form is a page's whole toolbar. Inside the shell the toolbar
  /// is shared with the Preview / Code control on its left, so this one has to
  /// earn its width.
  final bool compact;

  /// Whether the wall is offered as a fourth mode.
  ///
  /// **A flag rather than something the host could infer**, because the reason
  /// to refuse is not a property of this bar. The shell has somewhere to put a
  /// wall and still refuses it for one destination — see
  /// `StageDestination.allowsWall` — because a wall over a hundred thousand
  /// rows measures the wall.
  ///
  /// **A second reason was written here and its example is gone.**
  /// `ViewportLabPage` hosted one frame and had nowhere to put a wall; #147
  /// deleted the page, and `ShellPage` is now the only host — it always passes
  /// `_open.allowsWall` explicitly. So what that reason justified is the
  /// **default below, not the flag**, and the default has no caller today. It
  /// is kept for the reason `ShellMenu`'s empty-category branch is kept: the
  /// next host that draws one frame is written by someone who would not think
  /// to pass this parameter, and `false` is the answer they want.
  ///
  /// **Dropping the segment does not clear the selection.** `SegmentedButton`
  /// asserts `segments.length > 0`, `selected.length > 0 ||
  /// emptySelectionAllowed` and `selected.length < 2 || multiSelectionEnabled`,
  /// and **nothing** that [selectedId] is one of the segments; it decides the
  /// highlight per segment with `selected.contains(segment.value)`. So flipping
  /// this to false while [selectedId] is [wallId] draws a bar with nothing
  /// selected, silently. **The caller owns leaving the mode.**
  final bool showsWall;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        for (final v in ViewportSpec.values)
          ButtonSegment<String>(
            value: v.id,
            icon: Icon(_iconFor(v)),
            label: compact ? null : Text(v.label),
            tooltip: v.label,
          ),
        if (showsWall)
          ButtonSegment<String>(
            value: wallId,
            icon: const Icon(Icons.dashboard_outlined),
            label: compact ? null : Text(wallLabel),
            tooltip: wallLabel,
          ),
      ],
      selected: {selectedId},
      showSelectedIcon: false,
      onSelectionChanged: (ids) => onChanged(ids.first),
    );
  }

  static IconData _iconFor(ViewportSpec v) => switch (v.id) {
        'desktop' => Icons.desktop_windows_outlined,
        'tablet' => Icons.tablet_mac_outlined,
        _ => Icons.smartphone_outlined,
      };
}
