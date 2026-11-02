import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A screen reader hears a tooltip's text on its child (just_tooltip 0.5.1).
// Where the tooltip only repeats the text the child already shows — a header
// label, a cell's own value — it is kept off the child, so the text is not
// read twice. A tooltip whose text the table did not draw is still heard.

Widget _table({String Function(Map<String, dynamic>)? tooltipFormatter}) {
  return MaterialApp(
    home: Scaffold(
      body: FlutterTablePlus<Map<String, dynamic>>(
        columns: {
          'name': TablePlusColumn<Map<String, dynamic>>(
            key: 'name',
            label: 'Name',
            order: 0,
            width: 200,
            valueAccessor: (r) => r['name'],
            tooltipFormatter: tooltipFormatter,
          ),
        },
        data: const [
          {'id': '1', 'name': 'Alpha'},
        ],
        rowId: (r) => r['id'] as String,
      ),
    ),
  );
}

/// The tooltip text on the semantics node the [text] widget belongs to.
String _heardAt(WidgetTester tester, String text) =>
    tester.getSemantics(find.text(text)).getSemanticsData().tooltip;

void main() {
  testWidgets('a header tooltip repeating its label is not heard', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_table());

    expect(_heardAt(tester, 'Name'), '');
    handle.dispose();
  });

  testWidgets('a cell tooltip repeating the cell text is not heard', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_table());

    expect(_heardAt(tester, 'Alpha'), '');
    handle.dispose();
  });

  testWidgets('a cell tooltip from tooltipFormatter is heard', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_table(tooltipFormatter: (r) => 'Name: Alpha'));

    expect(_heardAt(tester, 'Alpha'), 'Name: Alpha');
    handle.dispose();
  });
}
