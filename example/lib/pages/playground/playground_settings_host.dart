/// Binds this playground's settings to the gallery's settings panel.
library;

import 'package:flutter/material.dart';

import '../../gallery/gallery.dart';
import 'models/feature_switches.dart';
import 'models/playground_settings.dart';
import 'models/settings_presets.dart';
import 'models/settings_spec.dart';
import 'widgets/settings_registry.dart';

/// The adapter, and everything about this app the panes used to know.
///
/// `extends` rather than `implements`, so a host with no extras inherits the
/// empty ones instead of restating them. This one has extras: the `data`
/// feature carries a row count badge, five quick counts and a Generate button,
/// which no registry entry can express because none of them is handed
/// [onGenerateData]. That used to be two `if (feature.id == 'data')` branches
/// inside a pane that claims to render any description.
///
/// Rebuilt on every settings change, like the panes it feeds. It holds nothing.
class PlaygroundSettingsHost extends SettingsHost {
  PlaygroundSettingsHost({
    required this.settings,
    required this.onChanged,
    required this.onGenerateData,
    required this.isGenerating,
    this.activePresetId,
    this.onPresetSelected,
  });

  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onChanged;
  final VoidCallback onGenerateData;
  final bool isGenerating;

  @override
  final String? activePresetId;

  /// Applying a preset is more than writing switches — the page also records
  /// which one is now active, and every other settings change clears it. That
  /// bookkeeping is the page's, so the host forwards rather than deciding.
  ///
  /// Optional, because not every place that draws these panes has anywhere to
  /// put a preset: a recipe's knob pane shows one feature's controls. **A host
  /// with no way to apply one offers none** — [presets] is empty rather than
  /// listing combinations whose chips would do nothing.
  final ValueChanged<SettingsPreset>? onPresetSelected;

  @override
  List<PresetSummary> get presets =>
      onPresetSelected == null ? const [] : allPresets;

  @override
  void applyPreset(String presetId) =>
      onPresetSelected?.call(presetById(presetId));

  @override
  List<SettingGroup> get spec => settingsSpec;

  @override
  bool isOn(String switchId) => featureSwitches[switchId]!.read(settings);

  @override
  void setSwitch(String switchId, bool on) =>
      onChanged(featureSwitches[switchId]!.write(settings, on));

  @override
  SettingsControl control(String settingId) =>
      settingsRegistry[settingId]!(settings, onChanged);

  @override
  List<Widget> extrasBeforeOptions(String featureId, BuildContext context) =>
      featureId == 'data' ? [_rowCountBadge(context)] : const [];

  @override
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) =>
      featureId == 'data' ? _dataExtras(context) : const [];

  Widget _rowCountBadge(BuildContext context) {
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
            color: Theme.of(context).colorScheme.secondaryContainer,
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

  List<Widget> _dataExtras(BuildContext context) {
    return [
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in [5, 100, 1000, 10000, 100000])
            _quickButton(context, value),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    ];
  }

  Widget _quickButton(BuildContext context, int value) {
    final selected = settings.rowCount == value;
    return ElevatedButton(
      onPressed: () => onChanged(settings.copyWith(rowCount: value)),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
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
