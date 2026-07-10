import 'package:example/pages/playground/models/feature_switches.dart';
import 'package:example/pages/playground/models/playground_settings.dart';
import 'package:example/pages/playground/models/settings_presets.dart';
import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:flutter_test/flutter_test.dart';

// A preset is a set of feature switches applied to the settings. It needed none
// of the description, the registry or the rendering rewrite — `copyWith` was
// always enough — which is why it now goes first.
//
// Reading and writing a switch by name is the one thing Dart cannot do for us.
// `featureSwitches` holds that knowledge, and the first test holds it to the
// description: a feature whose switch nobody taught the map to read would be
// silently reported as on.

Set<String> _specSwitchIds() => {
      for (final g in settingsSpec)
        for (final f in g.features)
          if (f.switchId != null) f.switchId!,
    };

void main() {
  test('every feature switch the description declares can be read and written',
      () {
    final declared = _specSwitchIds();
    expect(declared, hasLength(16));
    expect(featureSwitches.keys.toSet(), declared,
        reason: 'a switch nobody can read is a feature that is always on');
  });

  group('applyPreset', () {
    test('bare turns every feature off', () {
      final bare = applyPreset(const PlaygroundSettings(), presets.first);
      expect(presets.first.id, 'bare');

      for (final entry in featureSwitches.entries) {
        expect(entry.value.read(bare), isFalse, reason: entry.key);
      }
    });

    test('bare leaves the row count alone', () {
      const base = PlaygroundSettings(rowCount: 100);
      expect(applyPreset(base, presetById('bare')).rowCount, 100,
          reason: 'a table with no scroll cannot show drag selection');
    });

    test('everything turns every feature on', () {
      final all =
          applyPreset(const PlaygroundSettings(), presetById('everything'));
      for (final entry in featureSwitches.entries) {
        expect(entry.value.read(all), isTrue, reason: entry.key);
      }
    });

    test('a preset switches off what it does not name', () {
      const on = PlaygroundSettings(mergedRowsEnabled: true);
      final after = applyPreset(on, presetById('selectionAndEditing'));
      expect(after.mergedRowsEnabled, isFalse);
      expect(after.selectionEnabled, isTrue);
      expect(after.editingEnabled, isTrue);
    });
  });

  group('a preset named for an interaction must produce it', () {
    test('selection + editing turns on both, and nothing else', () {
      final s = applyPreset(
          const PlaygroundSettings(), presetById('selectionAndEditing'));
      expect(s.selectionEnabled, isTrue);
      expect(s.editingEnabled, isTrue);
      expect(s.dragSelectionEnabled, isFalse);
    });

    test('drag over merged rows turns on all three it needs', () {
      // Dragging selects nothing without selection, and a merged group cannot
      // be crossed if there are none. A preset that named the interaction and
      // left one of these off would demonstrate nothing.
      final s = applyPreset(
          const PlaygroundSettings(), presetById('dragOverMergedRows'));
      expect(s.dragSelectionEnabled, isTrue);
      expect(s.selectionEnabled, isTrue);
      expect(s.mergedRowsEnabled, isTrue);
    });
  });

  test('every preset says what to look for', () {
    for (final p in presets) {
      expect(p.title.trim(), isNotEmpty, reason: p.id);
      expect(p.lookFor.trim(), isNotEmpty, reason: p.id);
    }
  });

  test('every preset names features the description knows', () {
    final declared = _specSwitchIds();
    for (final p in presets) {
      expect(p.featuresOn.difference(declared), isEmpty, reason: p.id);
    }
  });
}
