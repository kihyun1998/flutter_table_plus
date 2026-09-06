/// What a settings panel needs from whoever owns the settings.
library;

import 'package:flutter/widgets.dart';

import 'setting_spec.dart';
import 'settings_controls.dart';

/// The port between the panes and a settings object they must not name.
///
/// **Every member here was read off a call site, not designed.** The three panes
/// were typed on the demonstrated package's own settings class, and what they
/// actually did with it was: walk the spec, read a switch, write a switch, build
/// one control, and — in one place — draw something no registry entry could
/// express. Five operations, so five members. A sixth would be a guess.
///
/// The panes are rebuilt whenever the settings change, so an implementation is
/// an ordinary short-lived value wrapping the current settings and the callback
/// that replaces them. It is not a store and holds no state of its own.
///
/// Prior art in this repository: `RowLocator`, which is how the drag-selection
/// controller asks "which row is at this offset" without knowing the body, and
/// `ShellDestinations`, which is how the shell receives a menu it cannot name.
abstract class SettingsHost {
  /// Every group, in the order the panel shows them.
  List<SettingGroup> get spec;

  /// Whether the switch with this id is on.
  ///
  /// Keyed by [SettingFeature.switchId] rather than by feature: a feature with
  /// no switch is always live, and the panes decide that themselves rather than
  /// asking about an id that does not exist.
  bool isOn(String switchId);

  /// Turns that switch on or off.
  ///
  /// **The write is a command, not a value.** The pane used to compute the new
  /// settings object and hand it back through a callback, which meant it had to
  /// know the type it was building. Who applies it, and how, is the host's.
  void setSwitch(String switchId, bool on);

  /// The control for one setting id.
  ///
  /// Read for its `label` as well as drawn — the search matches on labels, and
  /// asking the host for the control is how it gets one without a registry of
  /// its own.
  SettingsControl control(String settingId);

  /// Widgets the registry cannot express, drawn before this feature's options.
  ///
  /// The escape hatch, and it exists because there was already one in the code:
  /// the detail pane carried `if (feature.id == 'data')` twice, guarding a row
  /// count badge and a Generate button that need a callback no control is
  /// handed. A hardcoded feature id in a pane that claims to render any
  /// description is the tell that a slot was missing.
  ///
  /// Empty by default, so a host that needs none says nothing.
  List<Widget> extrasBeforeOptions(String featureId, BuildContext context) =>
      const [];

  /// Widgets drawn after this feature's options. See [extrasBeforeOptions].
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) =>
      const [];

  /// The named combinations this host offers, in the order to show them.
  ///
  /// Empty by default, and `PresetBar` draws nothing at all for an empty list —
  /// not an empty strip with a rule under it. A package with no named
  /// combinations should not have to say so.
  List<PresetSummary> get presets => const [];

  /// The preset the current settings still match, or null once anything has
  /// been changed by hand.
  ///
  /// The host's, not the bar's: whether a hand-edit clears it is a question
  /// about what a preset *means*, which only the side owning the settings can
  /// answer.
  String? get activePresetId => null;

  /// Applies one, by id.
  ///
  /// A command like [setSwitch], and for the same reason: the bar used to hand
  /// back a preset object, which meant knowing the type it was handing back.
  void applyPreset(String presetId) {}
}
