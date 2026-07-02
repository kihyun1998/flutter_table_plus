import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_table_plus/src/widgets/tooltip_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

// wrapWithTooltip resolves tooltip content by priority: builder > formatter >
// fallback message, and returns the child untouched when it should not show.

const _child = SizedBox();

Widget _wrap({
  required bool shouldShow,
  Widget Function(BuildContext, Map<String, dynamic>)? builder,
  String Function(Map<String, dynamic>)? formatter,
  Map<String, dynamic>? data = const {'id': '1'},
  String fallback = 'FALLBACK',
}) {
  return wrapWithTooltip<Map<String, dynamic>>(
    shouldShow: shouldShow,
    child: _child,
    theme: const TablePlusTooltipTheme(),
    tooltipBuilder: builder,
    tooltipFormatter: formatter,
    rowData: data,
    fallbackMessage: fallback,
  );
}

void main() {
  group('wrapWithTooltip', () {
    test('returns the child unchanged when it should not show', () {
      expect(identical(_wrap(shouldShow: false), _child), isTrue);
    });

    test('uses the builder when present and data is non-null', () {
      final r = _wrap(shouldShow: true, builder: (c, d) => const Text('x'))
          as FlutterTooltipPlus;
      expect(r.tooltipBuilder, isNotNull);
      expect(r.message, isNull);
    });

    test('uses the formatter string when there is no builder', () {
      final r = _wrap(shouldShow: true, formatter: (d) => 'FMT-${d['id']}')
          as FlutterTooltipPlus;
      expect(r.message, 'FMT-1');
      expect(r.tooltipBuilder, isNull);
    });

    test('falls back to the message when neither builder nor formatter', () {
      final r = _wrap(shouldShow: true) as FlutterTooltipPlus;
      expect(r.message, 'FALLBACK');
    });

    test('falls back to the message when data is null even if a builder exists',
        () {
      final r = _wrap(
          shouldShow: true,
          builder: (c, d) => const Text('x'),
          data: null) as FlutterTooltipPlus;
      expect(r.message, 'FALLBACK');
      expect(r.tooltipBuilder, isNull);
    });
  });
}
