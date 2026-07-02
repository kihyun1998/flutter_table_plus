import 'package:flutter_table_plus/src/widgets/row_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

// RowGeometry is the pure hit-test math behind the RowLocator port. Bands are
// hand-computed: a render row i owns the half-open interval
// [sum(heights[0..i)), sum(heights[0..i])).

void main() {
  group('indexAt', () {
    test('empty geometry resolves nothing', () {
      final g = RowGeometry(heights: const [], ids: const []);
      expect(g.renderRowCount, 0);
      expect(g.indexAt(0), isNull);
      expect(g.indexAt(100), isNull);
    });

    test('uniform heights map to the row band', () {
      final g = RowGeometry(
        heights: const <double>[48, 48, 48],
        ids: const ['a', 'b', 'c'],
      );
      expect(g.indexAt(0), 0);
      expect(g.indexAt(47.9), 0);
      expect(g.indexAt(48), 1); // boundary belongs to the next row
      expect(g.indexAt(95), 1);
      expect(g.indexAt(96), 2);
      expect(g.indexAt(143.9), 2);
    });

    test('above the first row and below the last row are null', () {
      final g = RowGeometry(
        heights: const <double>[48, 48, 48],
        ids: const ['a', 'b', 'c'],
      );
      expect(g.indexAt(-0.1), isNull);
      expect(g.indexAt(144), isNull); // exactly past the last band
      expect(g.indexAt(1000), isNull);
    });

    test('variable heights accumulate (dynamic rows / merged extents)', () {
      // bands: [0,50)->0, [50,150)->1, [150,180)->2
      final g = RowGeometry(
        heights: const <double>[50, 100, 30],
        ids: const ['a', 'g1', 'c'],
      );
      expect(g.indexAt(0), 0);
      expect(g.indexAt(49.9), 0);
      expect(g.indexAt(50), 1);
      expect(g.indexAt(149.9), 1);
      expect(g.indexAt(150), 2);
      expect(g.indexAt(179.9), 2);
      expect(g.indexAt(180), isNull);
    });
  });

  group('idsBetween', () {
    final g = RowGeometry(
      heights: const <double>[10, 10, 10, 10],
      ids: const ['a', 'b', 'c', 'd'],
    );

    test('inclusive range, order-agnostic', () {
      expect(g.idsBetween(1, 2), {'b', 'c'});
      expect(g.idsBetween(2, 1), {'b', 'c'});
    });

    test('single index', () {
      expect(g.idsBetween(0, 0), {'a'});
    });

    test('clamps out-of-range endpoints', () {
      expect(g.idsBetween(-5, 1), {'a', 'b'});
      expect(g.idsBetween(2, 99), {'c', 'd'});
    });
  });
}
