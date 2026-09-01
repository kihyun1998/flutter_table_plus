/// Every named viewport at once, side by side, and inert.
library;

import 'package:flutter/material.dart';

import 'preview_frame.dart';
import 'viewport_spec.dart';

/// The Device Wall — desktop, tablet and mobile rendered together.
///
/// The single-viewport modes answer *"what does this look like at that width"*.
/// This one answers a question they cannot: **what changed between them.** A
/// reader switching between two modes compares one layout against a memory of
/// the other; here both are on screen, reacting to the same knobs at the same
/// time, and the difference is the thing being looked at rather than something
/// being recalled.
///
/// **Every frame is live, and that was decided against this ticket's own
/// acceptance criteria.** #108 asked for a wall that took no pointer input and
/// for a test asserting a tap could not reach a row. It shipped the other way,
/// on the maintainer's call, because the two reasons behind that criterion did
/// not survive being measured.
///
/// The first reason was technical: a scaled frame would put drag selection's
/// viewport-local coordinate frame, the rubber-band geometry and the auto-scroll
/// `Timer` under a transform. **Measured and withdrawn** — `Transform` applies
/// the inverse to hit testing, so a drag inside a frame at half size selects
/// exactly the rows it crosses. That is why [PreviewFrame]'s fit mode is
/// interactive at all; see `test/preview_frame_test.dart`, "interaction survives
/// the scale".
///
/// The second was that three frames side by side are too small to operate. That
/// is true of *one* of them. The three do not share a scale: each viewport is
/// fit into an equal column, so a wide viewport shrinks further than a narrow
/// one, and the frame never scales **up**. Measured 2026-09-01 in the shell at
/// 1800px — desktop 0.28× (a 40px row drawn 11px tall), tablet 0.48× (19px),
/// **mobile 1.0×, at its full 40px**. The narrowest viewport is the one a reader
/// most wants to poke at, and it is the one rendered at real size.
///
/// What that buys is the thing the single-viewport modes cannot do at all. The
/// frames share one state, so a drag in the mobile frame paints its selection in
/// the tablet and desktop frames at the same time: *how this renders at three
/// widths*, at once, instead of held against a memory of the other mode.
///
/// Two consequences worth knowing rather than discovering. The desktop frame's
/// rows really are ~11px on screen and clicking one is imprecise — the
/// single-viewport modes are where precision lives. And an `IgnorePointer` here
/// would have been half a decision anyway: it vetoes hit testing only, while
/// focus traversal and `Actions` bypass it entirely, so a row's ink well and the
/// row checkbox stayed keyboard-activatable throughout. Measured: 20 of 40 Tab
/// presses landed inside a wall table. Live in both routes is one rule; live in
/// one and dead in the other was two.
///
/// **Mutually exclusive with the very-large-row-count scenario, and that is now
/// a property rather than a convention.** That scenario is a single-table
/// performance claim; this draws three tables over the same data at once, so a
/// frame rate measured here would be measuring the wall. The rule lives on
/// `StageDestination.allowsWall` — the destination's call, not this
/// widget's — and `ShellPage._select` leaves the wall when a
/// destination that refuses it is opened, because hiding the segment alone is
/// silent (#109).
class DeviceWall extends StatelessWidget {
  const DeviceWall({
    super.key,
    required this.stage,
    this.specs = ViewportSpec.values,
    this.spacing = 12,
  });

  /// Builds the subtree each frame shows.
  ///
  /// A builder rather than a widget, so each frame gets its own subtree and its
  /// own element — three frames over one widget instance would share whatever
  /// state that subtree keeps, and the point of the wall is three independent
  /// layouts over one set of *knobs*.
  final WidgetBuilder stage;

  final List<ViewportSpec> specs;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: Row(
        children: [
          for (final spec in specs)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: PreviewFrame(
                  spec: spec,
                  // Always. A wall column is whatever a third of the stage
                  // region happens to be, so 1:1 here would be three clipped
                  // slices at three arbitrary widths — which is neither a
                  // comparison nor a real-pixel view.
                  fit: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Builder(builder: stage),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
