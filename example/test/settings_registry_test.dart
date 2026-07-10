import 'package:example/pages/playground/models/settings_spec.dart';
import 'package:example/pages/playground/widgets/settings_registry.dart';
import 'package:flutter_test/flutter_test.dart';

// The description says what the settings are and what owns what. The registry
// says how each one is drawn. Neither can check the other by itself, so this
// does: the ids they cover must be the same set.
//
// An id in the description with no entry is a control that vanishes from the
// panel. An entry naming an id the description never mentions is a control
// nobody can reach.

Set<String> _describedIds() => {
      for (final group in settingsSpec)
        for (final f in group.features) ...[
          if (f.switchId != null) f.switchId!,
          ...f.options,
        ],
    };

void main() {
  test('the registry draws exactly what the description describes', () {
    final described = _describedIds();
    final drawn = settingsRegistry.keys.toSet();

    expect(described, hasLength(58),
        reason: 'the description still covers every field');

    expect(described.difference(drawn), isEmpty,
        reason: 'described but never drawn — the control would disappear');
    expect(drawn.difference(described), isEmpty,
        reason: 'drawn but never described — the control would be unreachable');
  });
}
