// Heap footprint of the per-row structures the table derives on every data
// snapshot: RowLookup (ids + idToIndex + idToGroup) and RowGeometry
// (heights + ids).
//
// NOT part of the default test run. Run it explicitly, with the VM service on:
//
//   flutter test --enable-vmservice benchmark/row_memory_benchmark.dart
//
// Each figure is the VM heap growth, read after a full GC, over many retained
// instances, divided down to bytes per row. It is not a CI gate, and it depends
// on the VM's object layout. A calibration line whose true cost is 64 bytes per
// row is measured first, and the run fails if it reads otherwise.

import 'dart:developer';
import 'dart:isolate' as iso;
import 'dart:typed_data';

import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/row_geometry.dart';
import 'package:flutter_table_plus/src/widgets/row_lookup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Rows built per measurement, summed over every instance in it.
const int _rowsPerMeasurement = 500000;

/// Everything measured stays reachable until the process exits.
final List<Object> _retained = [];

String _idOf(Map<String, dynamic> r) => r['id'] as String;

List<Map<String, dynamic>> _data(int n) =>
    List.generate(n, (i) => {'id': 'r$i'});

/// Three of every ten rows in a group, as `TableMetricsBenchmark` uses.
List<MergedRowGroup<Map<String, dynamic>>> _groups(int n) => [
  for (int i = 0; i + 2 < n; i += 10)
    MergedRowGroup<Map<String, dynamic>>(
      groupId: 'g$i',
      rowKeys: ['r$i', 'r${i + 1}', 'r${i + 2}'],
      mergeConfig: const {},
    ),
];

const TablePlusBodyTheme _theme = TablePlusBodyTheme();

/// A row height that differs from row to row, as a measuring callback returns.
double? _varyingHeight(int i) => 48.0 + (i % 7) * 1.5;

double? _noHeight(int i) => null;

/// Mirrors the body: growable lists filled with `add`, one id per row, and a
/// height of `calculateRowHeight ?? theme.rowHeight`.
RowGeometry _geometry(
  List<Map<String, dynamic>> data,
  double? Function(int) calculateRowHeight,
) {
  final heights = <double>[];
  final ids = <String>[];
  for (int i = 0; i < data.length; i++) {
    heights.add(calculateRowHeight(i) ?? _theme.rowHeight);
    ids.add(_idOf(data[i]));
  }
  return RowGeometry(heights: heights, ids: ids);
}

class _Heap {
  _Heap(this._service, this._isolateId);

  final VmService _service;
  final String _isolateId;

  static Future<_Heap> connect() async {
    final uri = (await Service.getInfo()).serverWebSocketUri;
    if (uri == null) {
      throw StateError(
        'The VM service is off. Run with: '
        'flutter test --enable-vmservice benchmark/row_memory_benchmark.dart',
      );
    }
    return _Heap(
      await vmServiceConnectUri(uri.toString()),
      Service.getIsolateId(iso.Isolate.current)!,
    );
  }

  Future<int> _usedAfterGc() async {
    final profile = await _service.getAllocationProfile(_isolateId, gc: true);
    return profile.memoryUsage!.heapUsage!;
  }

  /// Bytes per row retained by what [build] returns for an [n]-row snapshot.
  Future<double> bytesPerRow(int n, Object Function() build) async {
    final count = _rowsPerMeasurement ~/ n;
    final before = await _usedAfterGc();
    final kept = [for (int i = 0; i < count; i++) build()];
    final after = await _usedAfterGc();
    _retained.add(kept);
    return (after - before) / (count * n);
  }

  Future<void> dispose() => _service.dispose();
}

Future<double> _report(
  _Heap heap,
  String name,
  int n,
  Object Function() build,
) async {
  final perRow = await heap.bytesPerRow(n, build);
  // ignore: avoid_print
  print('$name(n=$n)(Bytes per row): ${perRow.toStringAsFixed(1)}');
  return perRow;
}

void main() {
  test('measure per-row heap footprint', () async {
    final heap = await _Heap.connect();
    for (final n in [1000, 10000]) {
      final calibration = await _report(
        heap,
        'calibration.Uint8List(64 per row)',
        n,
        () => Uint8List(n * 64),
      );
      expect(calibration, closeTo(64, 3.2), reason: 'the method is off');
    }
    for (final n in [1000, 10000]) {
      final data = _data(n);
      final groups = _groups(n);
      await _report(
        heap,
        'RowLookup',
        n,
        () => RowLookup.build(data: data, mergedGroups: groups, rowId: _idOf),
      );
      await _report(
        heap,
        'RowGeometry.uniformHeights',
        n,
        () => _geometry(data, _noHeight),
      );
      await _report(
        heap,
        'RowGeometry.varyingHeights',
        n,
        () => _geometry(data, _varyingHeight),
      );
    }
    await heap.dispose();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
