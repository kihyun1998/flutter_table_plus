import 'package:example/main.dart';
import 'package:example/pages/playground/models/employee.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A smoke test for the example app: the playground builds, lays out, and paints
// a table. `pumpWidget` and `pumpAndSettle` rethrow anything the framework
// caught, so an overflow or a build-time throw fails this outright.

void main() {
  testWidgets('the playground renders its table', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(); // the playground generates its rows async

    expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
    expect(find.text('Name'), findsOneWidget, reason: 'a header cell painted');
  });
}
