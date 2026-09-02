import 'package:example/demo_data/demo_data.dart';
import 'package:example/main.dart';
import 'package:example/pages/tooltip_anchor/tooltip_anchor_page.dart';
import 'package:example/shell/shell_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Smoke tests for the example app. `pumpWidget` and `pumpAndSettle` rethrow
// whatever the framework caught, so a build-time throw or an overflow fails
// these outright — which is how the layout bug in #55 surfaced.
//
// What this file pins that nothing else does is the **composition root**. Every
// test here goes through `MyApp`, so it sees the real theme scope, the real
// `MaterialApp`, and whatever `home:` actually points at. `shell_test.dart`
// pumps `ShellPage` directly and would stay green if `main.dart` opened
// something else entirely — which is precisely the line #147 moved.

void _desktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the app opens on the recipe browser', (tester) async {
    // Left at the default surface on purpose. 800px is under
    // `ShellPage.narrowBreakpoint`, so this builds the *folded* layout, and an
    // overflow there fails here rather than waiting for someone with a phone.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(ShellMenu), findsOneWidget);
  });

  testWidgets('and a table is already on screen at a desktop width',
      (tester) async {
    _desktop(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The inverse of what this file asserted until #147: the old home was a
    // list of four tiles that deliberately hosted no table, and the assertion
    // read `findsNothing` with the reason "the home lists demos; it does not
    // host one". The shell hosts one on open, so flipping this is the change.
    expect(find.byType(ShellMenu), findsOneWidget);
    expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
  });

  testWidgets('a page destination opens from the app root', (tester) async {
    _desktop(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Asserted before the tap, and it is what makes this test able to fail.
    // The old home carried a 'Tooltip anchors' tile, so tap-then-assert was
    // green against the list this ticket deletes — the label alone cannot tell
    // the two entry points apart, and only the menu's presence can.
    expect(find.byType(ShellMenu), findsOneWidget);

    await tester.tap(find.text('Tooltip anchors'));
    await tester.pumpAndSettle();

    // The shell is the root now, so this is the first push on the stack rather
    // than the second. The shell below is offstage, which is why the table
    // count is one and not two.
    expect(find.byType(FlutterTablePlus<TooltipAnchorRow>), findsOneWidget);
  });

  testWidgets('and so does the playground', (tester) async {
    _desktop(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Every setting'));
    await tester.pumpAndSettle(); // route transition, then async row generation

    expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
    expect(find.text('Name'), findsOneWidget, reason: 'a header cell painted');
  });
}
