import 'package:flutter/material.dart';

import '../models/feature_switches.dart';
import '../models/playground_settings.dart';
import '../models/settings_spec.dart';

/// The twenty features, in a column of their own.
///
/// Sixty-eight controls used to stand here. Each row now answers two questions —
/// is this on, and how much is inside it — and defers the rest to whatever pane
/// shows the feature you pick.
///
/// Four features own no switch. Rows, Zoom, Rows and text and Row ink are
/// headings over settings that are always live, and a dot beside them would
/// offer to turn off something that cannot be turned off.
class FeatureListPane extends StatelessWidget {
  const FeatureListPane({
    super.key,
    required this.settings,
    required this.selectedFeatureId,
    required this.onSettingsChanged,
    required this.onFeatureSelected,
  });

  final PlaygroundSettings settings;
  final String? selectedFeatureId;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final ValueChanged<String> onFeatureSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final group in settingsSpec) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                group.title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            for (final feature in group.features) _entry(feature),
          ],
        ],
      ),
    );
  }

  Widget _entry(SettingFeature feature) {
    final switchId = feature.switchId;
    final on = switchId != null && featureSwitches[switchId]!.read(settings);

    return KeyedSubtree(
      key: ValueKey('feature-${feature.id}'),
      child: ListTile(
        dense: true,
        selected: feature.id == selectedFeatureId,
        contentPadding: const EdgeInsets.only(left: 4, right: 12),
        // The name selects. Selecting is not enabling — a reader must be able to
        // look at a feature that is off, and see what it would offer.
        onTap: () => onFeatureSelected(feature.id),
        leading: switchId == null
            ? const SizedBox(width: 40)
            : _Dot(
                key: ValueKey('feature-dot-${feature.id}'),
                on: on,
                onTap: () => onSettingsChanged(
                  featureSwitches[switchId]!.write(settings, !on),
                ),
              ),
        title: Text(
          feature.title,
          // The list is 180 wide and the widget-test font draws every glyph as a
          // square of the font size, so a name that fits on screen overflows
          // there. Let it ellipsize.
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: feature.options.isEmpty
            ? null
            : Text(
                '${feature.options.length}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Icon(
          on ? Icons.circle : Icons.circle_outlined,
          size: 14,
          color: on ? Colors.blue.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
