import 'package:example/main.dart';
import 'package:example/pages/playground/models/employee.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Smoke tests for the example app. `pumpWidget` and `pumpAndSettle` rethrow
// whatever the framework caught, so a build-time throw or an overflow fails
// these outright — which is how the layout bug in #55 surfaced.

void main() {
  testWidgets('the app opens on a list of demos', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The settings panel also paints the word 'Playground', so the entry's
    // description is what tells the home apart from the demo it links to.
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('Every feature at once, with a knob for each'),
        findsOneWidget);
    expect(find.byType(FlutterTablePlus<Employee>), findsNothing,
        reason: 'the home lists demos; it does not host one');
  });

  testWidgets('opening the playground renders its table', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Playground'));
    await tester.pumpAndSettle(); // route transition, then async row generation

    expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
    expect(find.text('Name'), findsOneWidget, reason: 'a header cell painted');
  });
}
