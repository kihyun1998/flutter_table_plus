import 'package:flutter/widgets.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/row_hover_button.dart';
import 'package:flutter_test/flutter_test.dart';

// buildRowHoverButton is a pure guard: it returns null unless the row is
// hovered AND a builder, id, and data are all present (and the builder itself
// returns non-null); otherwise it positions the built button.

void main() {
  group('buildRowHoverButton', () {
    Widget? build({
      bool hovered = true,
      Widget? Function(String, Map<String, dynamic>)? builder,
      String? id = 'a',
      Map<String, dynamic>? data = const {},
    }) {
      return buildRowHoverButton<Map<String, dynamic>>(
        isHovered: hovered,
        builder: builder ?? (i, d) => const Text('B'),
        id: id,
        data: data,
        position: HoverButtonPosition.right,
        horizontalOffset: 8,
      );
    }

    test('null when not hovered', () => expect(build(hovered: false), isNull));

    test('null when the builder is null', () {
      expect(
        buildRowHoverButton<Map<String, dynamic>>(
          isHovered: true,
          builder: null,
          id: 'a',
          data: const {},
          position: HoverButtonPosition.right,
          horizontalOffset: 8,
        ),
        isNull,
      );
    });

    test('null when the builder returns null', () {
      expect(build(builder: (i, d) => null), isNull);
    });

    test('null when the id is null', () => expect(build(id: null), isNull));

    test('null when the data is null', () => expect(build(data: null), isNull));

    test('positions the built button and feeds it the id', () {
      String? gotId;
      final w = buildRowHoverButton<Map<String, dynamic>>(
        isHovered: true,
        builder: (i, d) {
          gotId = i;
          return const Text('B');
        },
        id: 'row7',
        data: const {},
        position: HoverButtonPosition.right,
        horizontalOffset: 8,
      );
      expect(w, isA<Positioned>());
      expect(gotId, 'row7');
    });
  });

  group('HoverButtonPosition.buildPositioned', () {
    test('left anchors to the left with the offset', () {
      final p = HoverButtonPosition.left.buildPositioned(
          child: const SizedBox(), horizontalOffset: 12) as Positioned;
      expect(p.left, 12);
      expect(p.right, isNull);
      expect(p.top, 0);
      expect(p.bottom, 0);
    });

    test('right anchors to the right with the offset', () {
      final p = HoverButtonPosition.right.buildPositioned(
          child: const SizedBox(), horizontalOffset: 12) as Positioned;
      expect(p.right, 12);
      expect(p.left, isNull);
    });

    test('center fills the row', () {
      final p = HoverButtonPosition.center
          .buildPositioned(child: const SizedBox()) as Positioned;
      expect(p.left, 0);
      expect(p.right, 0);
      expect(p.top, 0);
      expect(p.bottom, 0);
    });
  });
}
