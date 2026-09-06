import 'package:flutter/material.dart';

import 'settings_host.dart';

/// The named combinations, above the table.
///
/// A preset is the first thing anyone will feel, which is why it arrived before
/// the panel was rebuilt: a set of feature switches applied to the settings,
/// and `copyWith` was always enough for that.
class PresetBar extends StatelessWidget {
  const PresetBar({super.key, required this.host});

  final SettingsHost host;

  @override
  Widget build(BuildContext context) {
    final presets = host.presets;
    // A host with no named combinations draws nothing at all -- not an empty
    // strip with a rule under it, which is a piece of chrome announcing a
    // feature that is not there.
    if (presets.isEmpty) return const SizedBox.shrink();

    final activeId = host.activePresetId;
    final active = presets.where((p) => p.id == activeId).firstOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      // No ground of its own: the Scaffold already paints `colorScheme.surface`
      // beneath this, and painting white over it is what left the bar bright in
      // a dark app. Only the rule is decided here.
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in presets)
                ChoiceChip(
                  label: Text(preset.title),
                  selected: preset.id == activeId,
                  onSelected: (picked) =>
                      picked ? host.applyPreset(preset.id) : null,
                ),
            ],
          ),
          if (active != null) ...[
            const SizedBox(height: 8),
            // The line that makes a preset worth its name: not which features
            // it turned on, but what to watch now that they are.
            Text(
              active.lookFor,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
