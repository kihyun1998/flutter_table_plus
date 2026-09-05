/// The vocabulary a settings panel is described in: what owns what, and what
/// changes what.
///
/// **Types only — no settings.** A gallery renders a description; which
/// settings exist is the demonstrated package's business, and lives beside it.
/// The split is what lets the same panel draw a table's 58 options and some
/// other package's twelve.
///
/// A spec is held honest by the app that owns it — see
/// `test/settings_spec_test.dart`, which reddens on a field left undescribed or
/// an id naming nothing. A map written in prose would be stale within a month.
library;

/// One thing a reader might be trying to do.
///
/// Groups are cut by intent, not by what a setting configures. A feature's own
/// options do not share an effect — `tooltipBehavior` builds a column while
/// `tooltipDirection` builds a theme — so cutting by effect would tear the
/// tooltip feature in half and hide half of it from anyone looking for it.
class SettingGroup {
  const SettingGroup({
    required this.id,
    required this.title,
    required this.features,
  });

  final String id;
  final String title;
  final List<SettingFeature> features;
}

/// A capability of the table, and the settings that only mean something once it
/// is on.
///
/// [switchId] names the boolean field that turns it on, when there is one; a
/// feature without a switch is a heading over settings that are always live.
/// The hierarchy *is* the dependency — an option is reachable exactly when the
/// feature holding it is on — so there is no separate `dependsOn` to drift out
/// of step with it.
class SettingFeature {
  const SettingFeature({
    required this.id,
    required this.title,
    this.switchId,
    this.options = const [],
    this.interactions = const [],
  });

  final String id;
  final String title;

  /// The settings field that enables this feature, or null when it is always on.
  final String? switchId;

  /// Settings fields that are only meaningful while this feature is enabled.
  final List<String> options;

  /// Other features whose behaviour this one changes, or which change it.
  final List<Interaction> interactions;
}

/// One feature changing another, and the evidence that it does.
///
/// A test can insist that [evidence] is present. It cannot read the code the
/// citation points at and confirm that [effect] is what happens there — that is
/// a reviewer's job. So the rule is narrow and enforceable: no interaction is
/// asserted without a citation.
class Interaction {
  const Interaction({
    required this.otherFeatureId,
    required this.effect,
    required this.evidence,
  });

  final String otherFeatureId;

  /// What actually happens, in the direction it happens.
  final String effect;

  /// Where in the library, its tests, or the changelog this is established.
  final String evidence;
}

/// The feature with this id, in this spec. Throws when nothing has it — an id
/// that names nothing is a typo, not a null.
///
/// Takes the spec rather than reading a global, because the gallery has none:
/// the app binds this to its own spec and exports the one-argument form its
/// call sites already use.
SettingFeature featureIn(List<SettingGroup> spec, String id) =>
    spec.expand((g) => g.features).firstWhere((f) => f.id == id);

