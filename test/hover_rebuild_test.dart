import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// #35: a row must not rebuild on pointer hover when there are no hover buttons
// (the _isHovered setState only drives the hover button). Observed through the
// public interface by counting cell builds via a statefulCellBuilder.

void main() {
  testWidgets('no hover buttons: hovering a row does not rebuild its cells',
      (tester) async {
    var cellBuilds = 0;
    final columns = {
      'name': TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 0,
        valueAccessor: (r) => r['name'],
        width: 200,
        statefulCellBuilder: (context, row, isSelected, isDim) =>
            Builder(builder: (_) {
          cellBuilds++;
          return Text(row['name'] as String);
        }),
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterTablePlus<Map<String, dynamic>>(
            columns: columns,
            data: const [
              {'id': '0', 'name': 'R0'},
              {'id': '1', 'name': 'R1'},
            ],
            rowId: (r) => r['id'] as String,
            isSelectable: true, // interaction layer active
            onRowSelectionChanged: (_, __) {},
            // hoverButtonBuilder: null (no hover buttons)
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = cellBuilds;

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('R0')));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('R1')));
    await tester.pump();

    expect(cellBuilds, before,
        reason: 'rows must not rebuild on hover when there are no hover buttons');
  });

  testWidgets('with hover buttons: hovering a row reveals its hover button',
      (tester) async {
    final columns = {
      'name': TablePlusColumn<Map<String, dynamic>>(
        key: 'name',
        label: 'Name',
        order: 0,
        valueAccessor: (r) => r['name'],
        width: 200,
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterTablePlus<Map<String, dynamic>>(
            columns: columns,
            data: const [
              {'id': '0', 'name': 'R0'},
            ],
            rowId: (r) => r['id'] as String,
            isSelectable: true,
            onRowSelectionChanged: (_, __) {},
            hoverButtonBuilder: (id, row) => const Icon(Icons.delete),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Hidden until hovered.
    expect(find.byIcon(Icons.delete), findsNothing);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('R0')));
    await tester.pumpAndSettle();

    // Revealed on hover — the hover-tracking path still works when needed.
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
