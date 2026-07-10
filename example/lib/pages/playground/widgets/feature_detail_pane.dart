import 'package:flutter/material.dart';

import '../models/feature_switches.dart';
import '../models/playground_settings.dart';
import '../models/settings_spec.dart';
import 'settings_controls.dart';
import 'settings_registry.dart';

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
    required this.settings,
    required this.feature,
    required this.onSettingsChanged,
    required this.onGenerateData,
    this.isGenerating = false,
  });

  final PlaygroundSettings settings;
  final SettingFeature feature;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final VoidCallback onGenerateData;
  final bool isGenerating;

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
          if (feature.interactions.isNotEmpty) _affects(),
          const SizedBox(height: 12),
          if (feature.switchId != null) _draw(feature.switchId!),
          if (feature.id == 'data') _rowCountBadge(),
          if (feature.options.isNotEmpty) _options(),
          if (feature.id == 'data') ..._dataExtras(),
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
  Widget _affects() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade200),
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
              featureById(i.otherFeatureId).title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            // The pane is 380 wide and the widget-test font draws every glyph
            // as a square of the font size. This wraps; it must never be a Row.
            Text(
              i.effect,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
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
    final on = feature.switchId == null ||
        featureSwitches[feature.switchId!]!.read(settings);
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

  Widget _draw(String id) => settingsRegistry[id]!(settings, onSettingsChanged);

  Widget _rowCountBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Row Count',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            formatNumber(settings.rowCount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }

  /// The quick counts and the generate button need [onGenerateData], which no
  /// registry entry is handed, so the pane draws them itself.
  List<Widget> _dataExtras() {
    return [
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in [5, 100, 1000, 10000, 100000])
            _quickButton(value),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isGenerating ? null : onGenerateData,
          icon: isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(isGenerating ? 'Generating...' : 'Generate Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    ];
  }

  Widget _quickButton(int value) {
    final selected = settings.rowCount == value;
    return ElevatedButton(
      onPressed: () => onSettingsChanged(settings.copyWith(rowCount: value)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? Colors.green.shade600 : Colors.grey.shade200,
        foregroundColor: selected ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
      ),
      child: Text(
        formatNumber(value),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
