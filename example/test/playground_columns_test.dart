import 'package:example/pages/playground/models/employee.dart';
import 'package:example/pages/playground/playground_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A characterisation test, written before the column definitions are lifted out
// of the page. Nothing else in the example would notice a column going missing:
// the smoke test looks for one header, and the theme test never sees a column.

const _headers = [
  '\u{1F464}',
  'Name',
  'Position',
  'Department',
  'Salary',
  'Performance',
  'Email',
  'Phone',
];

void main() {
  testWidgets('the playground renders every column it defines', (tester) async {
    // The table is wider than a default test surface. Headers still build —
    // the header row is a plain scroll view, not a lazy list — but give it room
    // so nothing has to be scrolled into existence.
    tester.view.physicalSize = const Size(2400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PlaygroundPage()));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
    for (final header in _headers) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
  });
}
