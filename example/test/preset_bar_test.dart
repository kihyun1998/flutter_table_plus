import 'package:example/pages/playground/models/settings_presets.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The playground opens bare, because an addition needs a zero to be measured
// against. A preset is not a label on the settings — pressing one changes the
// table, and that is what these check.
//
// The checkbox column is the visible proof: it exists only while selection is
// on, which `Bare` turns off and `Everything` turns back on.

Future<void> _pumpPlayground(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the playground opens bare, and says what to look for',
      (tester) async {
    await _pumpPlayground(tester);

    for (final preset in presets) {
      expect(find.text(preset.title), findsOneWidget, reason: preset.id);
    }
    expect(find.text(presetById('bare').lookFor), findsOneWidget);

    expect(find.byType(FlutterCheckbox), findsNothing,
        reason: 'selection is off, so there is no checkbox column');
  });

  testWidgets('pressing a preset changes the table, not just the label',
      (tester) async {
    await _pumpPlayground(tester);

    await tester.tap(find.text('Everything'));
    await tester.pumpAndSettle();

    expect(find.text(presetById('everything').lookFor), findsOneWidget);
    expect(find.byType(FlutterCheckbox), findsWidgets,
        reason: 'selection is on now');
  });

  testWidgets('changing a setting by hand releases the preset', (tester) async {
    await _pumpPlayground(tester);
    expect(find.text(presetById('bare').lookFor), findsOneWidget);

    // Any control will do; the row-count quick buttons are always visible.
    await tester.tap(find.text('1.0K'));
    await tester.pumpAndSettle();

    expect(find.text(presetById('bare').lookFor), findsNothing,
        reason: 'the settings no longer match any preset');
  });
}
