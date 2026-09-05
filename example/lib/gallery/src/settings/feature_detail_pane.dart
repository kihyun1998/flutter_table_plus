import 'package:flutter/material.dart';

import 'setting_spec.dart';
import 'settings_host.dart';

/// One feature, opened.
///
/// Sixty-eight controls stood in a column. At most twelve stand here, and they
/// all belong to the feature whose name is at the top: its switch, and the
/// options it owns. `test/feature_detail_test.dart` counts them against the
/// description, so a control that drifts to the wrong feature turns it red.
///
/// The pane draws no chrome of its own — the page gives it its width and hangs
/// the performance monitor beneath it, because a monitor belongs to no feature.
class FeatureDetailPane extends StatelessWidget {
  const FeatureDetailPane({
    super.key,
    required this.host,
    required this.feature,
  });

  final SettingsHost host;
  final SettingFeature feature;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            feature.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (feature.interactions.isNotEmpty) _affects(context),
          const SizedBox(height: 12),
          if (feature.switchId != null) _draw(feature.switchId!),
          ...host.extrasBeforeOptions(feature.id, context),
          if (feature.options.isNotEmpty) _options(),
          ...host.extrasAfterOptions(feature.id, context),
        ],
      ),
    );
  }

  /// What this feature does to the others.
  ///
  /// A reader flips a switch and something unrelated behaves differently, with
  /// nothing on screen to say why — and an agent reading the code concludes the
  /// features are independent. These are the couplings the description records,
  /// each carrying a citation that a human has read.
  ///
  /// Stated in the direction it happens. "A merged row carries no card" and
  /// "the card is never built for a merged row" are different claims; only one
  /// of them is what `table_body.dart` does.
  Widget _affects(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      // A callout, so it needs a ground of its own — but a fixed amber slab is
      // a light-theme decision, and this pane is drawn in both. The container
      // roles carry the same "set apart from the surface" meaning through the
      // scheme, whatever the scheme happens to be.
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Affects',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.amber.shade900,
            ),
          ),
          for (final i in feature.interactions) ...[
            const SizedBox(height: 8),
            Text(
              featureIn(host.spec, i.otherFeatureId).title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            // The pane is 380 wide and the widget-test font draws every glyph
            // as a square of the font size. This wraps; it must never be a Row.
            Text(
              i.effect,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The options, live or not.
  ///
  /// An option means nothing while its feature is off, but hiding it leaves a
  /// reader unable to tell whether the setting does not exist or merely cannot
  /// be used. So it is drawn, unreachable, under a line naming the switch that
  /// would make it work. The switch itself sits outside this — it is the way
  /// out.
  Widget _options() {
    final on = feature.switchId == null || host.isOn(feature.switchId!);
    final drawn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final option in feature.options) _draw(option)],
    );
    if (on) return drawn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Turn on ${feature.title} to use these',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
          ),
        ),
        Opacity(opacity: 0.5, child: IgnorePointer(child: drawn)),
      ],
    );
  }

  Widget _draw(String id) => host.control(id);
}
