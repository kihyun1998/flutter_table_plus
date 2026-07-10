import 'feature_switches.dart';
import 'playground_settings.dart';

/// A named set of features to turn on, and what to watch once they are.
///
/// Two of these are structural — a bare table, and everything at once. The rest
/// are named for the **interaction** they demonstrate, not for the features they
/// enable: `Selection` and `Editing` are switches the panel already has, and a
/// preset named after one of them says nothing a switch did not. `Selection +
/// Editing` earns its name, because it answers whether a tap edits the cell or
/// selects the row.
///
/// A preset that names an interaction must actually produce it. Turning on drag
/// selection over data with no merged group demonstrates nothing, so
/// `dragOverMergedRows` names all three features the interaction needs.
class SettingsPreset {
  const SettingsPreset({
    required this.id,
    required this.title,
    required this.lookFor,
    required this.featuresOn,
  });

  final String id;
  final String title;

  /// What to watch for once the preset is applied.
  final String lookFor;

  /// The switch ids to turn on. Everything else is turned off.
  final Set<String> featuresOn;
}

/// `bare` is first because the playground opens on it: an addition needs a zero
/// to be measured against, and the row count is not what makes a table bare —
/// a table with no scroll cannot show drag selection or auto-scroll.
final List<SettingsPreset> presets = [
  SettingsPreset(
    id: 'bare',
    title: 'Bare',
    lookFor: 'A plain table. Nothing is on. Add one thing at a time and watch '
        'what it changes.',
    featuresOn: const {},
  ),
  SettingsPreset(
    id: 'everything',
    title: 'Everything',
    lookFor: 'Every feature at once. This is where tables break — on '
        'combinations, not on any single feature.',
    featuresOn: featureSwitches.keys.toSet(),
  ),
  SettingsPreset(
    id: 'selectionAndEditing',
    title: 'Selection + Editing',
    lookFor: 'Tap an editable column and the cell edits. Tap anywhere else on '
        'the row and it selects. The cell wins the gesture arena.',
    featuresOn: const {'selectionEnabled', 'editingEnabled'},
  ),
  SettingsPreset(
    id: 'dragOverMergedRows',
    title: 'Drag select over merged rows',
    lookFor: 'Drag across a merged group. One group id arrives, not the ids of '
        'the rows inside it.',
    featuresOn: const {
      'selectionEnabled',
      'dragSelectionEnabled',
      'mergedRowsEnabled',
    },
  ),
];

SettingsPreset presetById(String id) => presets.firstWhere((p) => p.id == id);

/// Turns on exactly the features [preset] names, and turns off every other one.
///
/// Settings that are not feature switches — the row count, a slider's value —
/// are left as they were. A preset chooses which features are on, not what they
/// are configured to do.
PlaygroundSettings applyPreset(PlaygroundSettings base, SettingsPreset preset) {
  var result = base;
  for (final entry in featureSwitches.entries) {
    result = entry.value.write(result, preset.featuresOn.contains(entry.key));
  }
  return result;
}
