// Microbenchmarks for the hot pure paths extracted out of the table widgets.
//
// These are NOT part of the default test run (they live under benchmark/, not
// test/). Run them explicitly:
//
//   flutter test benchmark/pure_paths_benchmark.dart
//
// Each benchmark reports RunTime in microseconds PER OPERATION (exercise() is
// overridden to a single run()). The numbers are for catching algorithmic
// regressions locally; they are not a CI gate and are machine-dependent.

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/utils/column_width_resolver.dart';
import 'package:flutter_table_plus/src/utils/table_metrics.dart';
import 'package:flutter_table_plus/src/widgets/row_geometry.dart';
import 'package:flutter_table_plus/src/widgets/row_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

String _idOf(Map<String, dynamic> r) => r['id'] as String;

/// computeColumnWidths over N columns (mixed fixed / flexible / max-capped).
class ColumnWidthsBenchmark extends BenchmarkBase {
  ColumnWidthsBenchmark(this.n) : super('computeColumnWidths(n=$n)');

  final int n;
  late final List<TablePlusColumn<Map<String, dynamic>>> _columns;
  late final double _availableWidth;

  @override
  void setup() {
    _columns = List.generate(
      n,
      (i) => TablePlusColumn<Map<String, dynamic>>(
        key: 'c$i',
        label: 'C$i',
        order: i,
        valueAccessor: (r) => r['c$i'],
        width: 100.0 + (i % 5) * 20,
        maxWidth: i % 3 == 0 ? 150.0 : null,
      ),
    );
    final preferred = _columns.fold<double>(0, (s, c) => s + c.width);
    _availableWidth = preferred * 1.5; // triggers proportional redistribution
  }

  @override
  void exercise() => run();

  @override
  void run() {
    computeColumnWidths<Map<String, dynamic>>(
      availableWidth: _availableWidth,
      columns: _columns,
      resizedWidths: const {},
      stretchLastColumn: false,
    );
  }
}

/// RowGeometry hit-testing over N rows: a deep indexAt scan + a wide idsBetween.
class RowGeometryBenchmark extends BenchmarkBase {
  RowGeometryBenchmark(this.n) : super('RowGeometry.query(n=$n)');

  final int n;
  late final RowGeometry _geometry;
  late final double _deepY;
  late final int _halfway;

  @override
  void setup() {
    _geometry = RowGeometry(
      heights: List<double>.filled(n, 48),
      ids: List<String>.generate(n, (i) => 'r$i'),
    );
    _deepY = n * 48 * 0.75; // near the bottom -> long cumulative scan
    _halfway = n ~/ 2;
  }

  @override
  void exercise() => run();

  @override
  void run() {
    _geometry.indexAt(_deepY);
    _geometry.idsBetween(0, _halfway);
  }
}

/// computeTableMetrics + computeRenderableIndices over N rows with ~10% merged.
class TableMetricsBenchmark extends BenchmarkBase {
  TableMetricsBenchmark(this.n, {String name = 'tableMetrics'})
    : super('$name(n=$n)');

  final int n;
  late final List<Map<String, dynamic>> _data;
  late final List<MergedRowGroup<Map<String, dynamic>>> _groups;
  late final RowLookup<Map<String, dynamic>> _lookup;

  Map<String, dynamic> _row(int i) => {'id': 'r$i'};

  double _rowHeightOf(int index) => 48;

  double _mergedGroupHeightOf(MergedRowGroup<Map<String, dynamic>> g) =>
      48.0 * g.rowKeys.length;

  @override
  void setup() {
    _data = List.generate(n, _row);
    _groups = [
      for (int i = 0; i + 2 < n; i += 10)
        MergedRowGroup<Map<String, dynamic>>(
          groupId: 'g$i',
          rowKeys: ['r$i', 'r${i + 1}', 'r${i + 2}'],
          mergeConfig: const {},
        ),
    ];
    _lookup = RowLookup.build(data: _data, mergedGroups: _groups, rowId: _idOf);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    computeTableMetrics<Map<String, dynamic>>(
      data: _data,
      lookup: _lookup,
      rowHeightOf: _rowHeightOf,
      mergedGroupHeightOf: _mergedGroupHeightOf,
    );
    computeRenderableIndices<Map<String, dynamic>>(
      data: _data,
      lookup: _lookup,
      rowId: _idOf,
      hasMergedGroups: _groups.isNotEmpty,
    );
  }
}

/// [TableMetricsBenchmark] with each row's height laid out from its text by
/// [TableRowHeightCalculator.createHeightCalculator], and a group's height as
/// the sum of its members', as the table computes them.
class TextHeightTableMetricsBenchmark extends TableMetricsBenchmark {
  TextHeightTableMetricsBenchmark(super.n)
    : super(name: 'tableMetrics.textHeights');

  late final double? Function(int, Map<String, dynamic>) _heightOf;

  @override
  Map<String, dynamic> _row(int i) => {
    'id': 'r$i',
    'text': List.filled(1 + i % 12, 'lorem ipsum').join(' '),
  };

  @override
  double _rowHeightOf(int index) => _heightOf(index, _data[index]) ?? 48;

  @override
  double _mergedGroupHeightOf(MergedRowGroup<Map<String, dynamic>> g) {
    double total = 0;
    for (final key in g.rowKeys) {
      final index = _lookup.indexOf(key);
      if (index != null) total += _rowHeightOf(index);
    }
    return total;
  }

  @override
  void setup() {
    super.setup();
    _heightOf = TableRowHeightCalculator.createHeightCalculator(
      columns: [
        TablePlusColumn<Map<String, dynamic>>(
          key: 'text',
          label: 'Text',
          order: 0,
          valueAccessor: (r) => r['text'],
          width: 240,
          textOverflow: TextOverflow.visible,
        ),
      ],
      columnWidths: const [240],
      defaultTextStyle: const TextStyle(fontSize: 14),
    );
    final heights = {for (int i = 0; i < 12; i++) _rowHeightOf(i)};
    if (heights.length < 2 || heights.every((h) => h <= 48)) {
      throw StateError('No row height came from its text: $heights');
    }
  }
}

void main() {
  test('run pure-path microbenchmarks', () {
    for (final n in [1000, 10000]) {
      ColumnWidthsBenchmark(n).report();
      RowGeometryBenchmark(n).report();
      TableMetricsBenchmark(n).report();
      TextHeightTableMetricsBenchmark(n).report();
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
