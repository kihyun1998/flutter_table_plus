import 'package:example/demo_data/demo_data.dart';
import 'package:example/preview/device_wall.dart';
import 'package:example/preview/preview_frame.dart';
import 'package:example/preview/viewport_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// The wall draws every viewport at once and takes no pointer input.
//
// The second group is the one that has to be right, and it is not the obvious
// test. `tester.tap` runs a hit test and *warns* when the finder's widget would
// not receive the event — but the warning is non-fatal by default
// (`WidgetController.hitTestWarningShouldBeFatal` is false) and the pointer is
// dispatched anyway. So a test that taps a row and expects the tap itself to
// fail cannot fail: it prints a stack trace and passes. The observation has to
// be the callback.
//
// `tapAt` is used instead of `tap` for the same reason from the other side: it
// takes a raw offset, performs no hit-test check, and dispatches exactly what a
// finger would. Nothing about the assertion then depends on the SDK's warning
// machinery.
//
// And the inert half is asserted against a control — the same table, the same
// viewport, the same arithmetic, in a plain frame — because "the callback did
// not fire" is also what a test with the wrong coordinates reports.

const double _rowHeight = 40;
const double _headerHeight = 40;

Map<String, TablePlusColumn<Map<String, dynamic>>> _columns() {
  final b = TableColumnsBuilder<Map<String, dynamic>>();
  for (final key in ['a', 'b', 'c']) {
    b.addColumn(
      key,
      TablePlusColumn<Map<String, dynamic>>(
        key: key,
        label: key,
        order: 0,
        width: 200,
        valueAccessor: (r) => r[key],
      ),
    );
  }
  return b.build();
}

List<Map<String, dynamic>> _rows(int n) => List.generate(
      n,
      (i) => {'id': '$i', 'a': 'a$i', 'b': 'b$i', 'c': 'c$i'},
    );

void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// A table that reports the row a tap landed on.
Widget _table({
  required List<Map<String, dynamic>> rows,
  void Function(String rowId, bool selected)? onSelected,
}) {
  return FlutterTablePlus<Map<String, dynamic>>(
    columns: _columns(),
    data: rows,
    rowId: (r) => r['id'] as String,
    isSelectable: onSelected != null,
    onRowSelectionChanged: onSelected,
    theme: const TablePlusTheme(
      bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
      headerTheme: TablePlusHeaderTheme(height: _headerHeight),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget child, Size surface) async {
  _surface(tester, surface);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

/// Where row [row] sits on screen inside the first table on the page.
///
/// Row offsets are logical and the rect is screen space, so the factor has to
/// be applied to the offset rather than assumed away. Mixing the two is the
/// arithmetic error that made #101 believe a scaled stage broke drag selection.
Offset _rowCentre(WidgetTester tester, ViewportSpec spec, double row) {
  final rect =
      tester.getRect(find.byType(FlutterTablePlus<Map<String, dynamic>>).first);
  final scale = rect.width / spec.width;
  return rect.topLeft +
      Offset(60 * scale, (_headerHeight + (row + 0.5) * _rowHeight) * scale);
}

void main() {
  group('every viewport at once', () {
    testWidgets('draws each one, saying which size and at what factor',
        (tester) async {
      await _pump(
        tester,
        DeviceWall(stage: (context) => _table(rows: _rows(8))),
        const Size(1600, 900),
      );

      // Observed at the screen, and by the dimensions rather than by a widget
      // type: the numbers are what tells a reader which frame is which, which
      // is the reason `ViewportSpec` puts them in the label in the first place.
      for (final spec in ViewportSpec.values) {
        expect(
          find.textContaining(
            '${spec.width.toInt()} × ${spec.height.toInt()}',
          ),
          findsOneWidget,
          reason: '${spec.id} is not on the wall',
        );
      }

      // Not every frame is shrunk, and the wall says which is which. A third
      // of a 1600px window is roughly 518, so 1440 cannot fit and 390 already
      // does — and a frame that fits is drawn at real pixels, because the
      // frame never scales *up*. Asserting "everything is scaled" here would
      // have been asserting a coincidence of this window size.
      expect(find.textContaining('1440 × 900 · 1:1'), findsNothing,
          reason: 'the desktop viewport was not shrunk into its column, so it '
              'is being clipped rather than compared');
      expect(find.textContaining('390 × 844 · 1:1'), findsOneWidget,
          reason: 'the mobile viewport fits at real pixels and should say so');
    });

    testWidgets('each frame constrains its subtree to its own viewport',
        (tester) async {
      // The premise the whole view rests on. Three frames that all laid their
      // subtree out at the same width would satisfy the label assertion above
      // and show nothing — the labels are drawn from the spec, not measured.
      await _pump(
        tester,
        DeviceWall(stage: (context) => _table(rows: _rows(4))),
        const Size(1600, 900),
      );

      final tables = find.byType(FlutterTablePlus<Map<String, dynamic>>);
      expect(tables, findsNWidgets(3));

      // `getSize`, not `getRect`. Inside a `FittedBox` the subtree still lays
      // out at its full viewport size — that is the point, the child is
      // unaware it is being shrunk — and only the screen rect carries the
      // factor. These two spaces are the ones #101 mixed up.
      for (var i = 0; i < ViewportSpec.values.length; i++) {
        expect(tester.getSize(tables.at(i)).width, ViewportSpec.values[i].width,
            reason: '${ViewportSpec.values[i].id} was laid out at somebody '
                "else's width");
      }

      // And the desktop frame really is drawn smaller than it was laid out,
      // which is what makes the first assertion a comparison rather than three
      // clipped slices.
      expect(tester.getRect(tables.first).width,
          lessThan(ViewportSpec.desktop.width));
    });

    testWidgets('one knob change reaches all three', (tester) async {
      var rowCount = 4;

      _surface(tester, const Size(1600, 900));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                TextButton(
                  onPressed: () => setState(() => rowCount = 8),
                  child: const Text('more'),
                ),
                Expanded(
                  child: DeviceWall(
                    stage: (context) => _table(rows: _rows(rowCount)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('a7'), findsNothing);

      await tester.tap(find.text('more'));
      await tester.pumpAndSettle();

      // Three, not one: a wall whose frames were driven by three independent
      // copies of the state would show the new row in whichever one the knob
      // happened to be wired to.
      expect(find.text('a7'), findsNWidgets(3));
    });

    testWidgets('a frame never needs a scroll the wall refuses to deliver',
        (tester) async {
      // Measured, not guessed: inside the shell at a 1200px window the menu and
      // the 320px knob pane leave each wall column 200px, and the frame's label
      // measures 211.5 under the test font. `PreviewFrame` reaches its label
      // through a horizontal `SingleChildScrollView` whose child is only
      // *floor*-constrained, so a label wider than its column widens the frame
      // and makes it scroll sideways to finish its own caption. The clipped end
      // is the scale factor, which is the one thing on a shrunken frame a
      // reader cannot infer from the picture.
      //
      // The narrow folded layout is *wider* than this (217px), so this is the
      // worst case and not the obvious one. And the test surface is 620 rather
      // than 1200 because the wall is pumped directly here, without the menu
      // and knob pane eating the width.
      //
      // This was first justified by the wall being pointer-inert, which made
      // the scroll unreachable. The wall ships live and that reason is gone; the
      // assertion stays, because a caption you have to scroll to is wrong even
      // when the scrolling works.
      await _pump(
        tester,
        DeviceWall(stage: (context) => _table(rows: _rows(4))),
        const Size(620, 900),
      );

      final column = tester.getSize(find.byType(PreviewFrame).first).width;
      final label =
          tester.getSize(find.textContaining('1440 × 900').first).width;

      expect(label, lessThanOrEqualTo(column),
          reason: 'the label is wider than the column it sits in, so the frame '
              'is horizontally scrollable inside a wall that delivers no '
              'pointer events');
    });
  });

  _dataGroup();

  group('every frame is live', () {
    testWidgets('a tap inside a frame selects the row it landed on',
        (tester) async {
      // The desktop frame, which is the *most* scaled of the three (0.28x in
      // the shell at 1800px). If hit testing survives here it survives in the
      // other two, and it does survive: `Transform` applies the inverse, so the
      // pointer arrives in the child's untransformed space.
      final selected = <String>[];

      await _pump(
        tester,
        DeviceWall(
          stage: (context) => _table(
            rows: _rows(8),
            onSelected: (id, _) => selected.add(id),
          ),
        ),
        const Size(1600, 900),
      );

      await tester.tapAt(_rowCentre(tester, ViewportSpec.desktop, 1));
      await tester.pumpAndSettle();

      expect(selected, ['1'],
          reason: 'either the wall is refusing pointers, or the scale '
              'arithmetic landed the tap on a different row');
    });

    testWidgets('and the other two frames show that selection immediately',
        (tester) async {
      // This is the wall's whole purpose, and the only assertion here that the
      // single-viewport modes could not also make: one interaction, three
      // widths, at the same time rather than one remembered against the other.
      final selected = <String>{};

      _surface(tester, const Size(1600, 900));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DeviceWall(
              stage: (context) => FlutterTablePlus<Map<String, dynamic>>(
                columns: _columns(),
                data: _rows(8),
                rowId: (r) => r['id'] as String,
                isSelectable: true,
                selectedRows: selected,
                onRowSelectionChanged: (id, isSelected) => setState(() {
                  isSelected ? selected.add(id) : selected.remove(id);
                }),
                theme: const TablePlusTheme(
                  bodyTheme: TablePlusBodyTheme(rowHeight: _rowHeight),
                  headerTheme: TablePlusHeaderTheme(height: _headerHeight),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(_rowCentre(tester, ViewportSpec.desktop, 1));
      await tester.pumpAndSettle();

      expect(selected, {'1'});

      // Read off the widgets rather than the pixels: every frame was handed the
      // same selection set. Three frames each holding their own would be the
      // failure, and it would look identical from one frame alone.
      final shown = tester
          .widgetList<FlutterTablePlus<Map<String, dynamic>>>(
              find.byType(FlutterTablePlus<Map<String, dynamic>>))
          .map((t) => t.selectedRows)
          .toList();

      expect(shown, hasLength(3));
      expect(shown.every((s) => s.contains('1')), isTrue,
          reason: 'the frames are not sharing one selection, so the wall shows '
              'three independent tables rather than one at three widths: '
              '$shown');
    });
  });
}

// Added after an adversarial pass found it: the wall builds its stage once per
// frame, so a destination that generates its own data in `State` handed each
// column a different dataset. Every column then differed by data *and* width,
// which is the one thing a comparison view cannot afford. Fixed in the shared
// generator — see `RandomDataGenerator._randomFor`.
void _dataGroup() {
  group('every frame shows the same data', () {
    testWidgets('a stage that generates rows in State is still identical '
        'across the three frames', (tester) async {
      _surface(tester, const Size(1600, 900));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DeviceWall(stage: (context) => const _GeneratingStage()),
        ),
      ));
      await tester.pumpAndSettle();

      // Observed at the screen: the generated cell, in each of the three
      // frames. One dataset shows one string three times; three datasets show
      // three strings once each.
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => s.startsWith('gen-'))
          .toSet();

      expect(texts, hasLength(1),
          reason: 'the three frames generated their own data, so the wall is '
              'comparing datasets rather than widths: $texts');
    });
  });
}

/// A stage in the shape the seven recipes use: rows generated in `State`.
class _GeneratingStage extends StatefulWidget {
  const _GeneratingStage();
  @override
  State<_GeneratingStage> createState() => _GeneratingStageState();
}

class _GeneratingStageState extends State<_GeneratingStage> {
  late final List<Map<String, dynamic>> _generated = _rows(4)
      .map((r) => {
            ...r,
            'a': 'gen-${RandomDataGenerator.generateEmployees(1).first.name}'
          })
      .toList();

  @override
  Widget build(BuildContext context) => _table(rows: _generated);
}
