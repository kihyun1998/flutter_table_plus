import 'package:flutter/material.dart';

import '../models/settings_presets.dart';

/// The named combinations, above the table.
///
/// A preset is the first thing anyone will feel, which is why it arrived before
/// the panel was rebuilt: a set of feature switches applied to the settings,
/// and `copyWith` was always enough for that.
class PresetBar extends StatelessWidget {
  const PresetBar({
    super.key,
    required this.activePresetId,
    required this.onPresetSelected,
  });

  final String? activePresetId;
  final ValueChanged<SettingsPreset> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final active = activePresetId == null ? null : presetById(activePresetId!);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
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
                  selected: preset.id == activePresetId,
                  onSelected: (picked) =>
                      picked ? onPresetSelected(preset) : null,
                ),
            ],
          ),
          if (active != null) ...[
            const SizedBox(height: 8),
            // The line that makes a preset worth its name: not which features
            // it turned on, but what to watch now that they are.
            Text(
              active.lookFor,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}
