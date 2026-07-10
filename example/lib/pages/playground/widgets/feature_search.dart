import '../models/feature_switches.dart';
import '../models/playground_settings.dart';
import '../models/settings_spec.dart';
import 'settings_controls.dart';
import 'settings_registry.dart';

/// A feature the search kept, and why it kept it.
class FeatureMatch {
  const FeatureMatch({
    required this.feature,
    required this.nameMatched,
    required this.matchedLabels,
    required this.isOn,
  });

  final SettingFeature feature;

  /// The feature's own name matched the query.
  final bool nameMatched;

  /// The labels of its settings that matched, in the order the feature lists
  /// them. Empty when only the name matched, and always empty for a blank
  /// query.
  final List<String> matchedLabels;

  /// Whether the feature is switched on. A feature that is off still matches;
  /// silence cannot say whether a setting is missing or merely unusable.
  final bool isOn;
}

/// The features a search for [query] keeps.
///
/// A blank query is not a search: every feature survives it, and nothing is
/// reported as having matched.
///
/// The search reads a control's **label**, which only exists once the control
/// is built — so the registry is run, with a callback that goes nowhere. It
/// also reads the feature's **name**, because the names are what is on screen,
/// and typing what you can see and getting nothing back reads as a broken
/// search rather than as a narrow contract.
List<FeatureMatch> searchFeatures(String query, PlaygroundSettings settings) {
  final searching = query.trim().isNotEmpty;

  final matches = <FeatureMatch>[];
  for (final feature in settingsSpec.expand((g) => g.features)) {
    final nameMatched = searching && settingMatches(feature.title, query);

    // Only the options. A feature's switch *is* the feature, and listing "Drag
    // Selection" underneath "Drag selection" says nothing the row above it did
    // not.
    final matchedLabels = <String>[];
    if (searching) {
      for (final id in feature.options) {
        final label = settingsRegistry[id]!(settings, (_) {}).label;
        if (settingMatches(label, query)) matchedLabels.add(label);
      }
    }

    if (searching && !nameMatched && matchedLabels.isEmpty) continue;

    matches.add(FeatureMatch(
      feature: feature,
      nameMatched: nameMatched,
      matchedLabels: matchedLabels,
      isOn: feature.switchId == null ||
          featureSwitches[feature.switchId!]!.read(settings),
    ));
  }
  return matches;
}
