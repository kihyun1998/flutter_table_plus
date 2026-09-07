/// What this example measures, in the shell's vocabulary.
library;

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

/// A table's numbers, and the one place that knows how to say them.
///
/// **This is the consumer half of a seam the shell draws.** `MetricsPanel`
/// takes [Reading]s whose `value` is already a `String`, because `128.4K`,
/// `1.28s` and `40K rows/sec` are three different formatting decisions and
/// every one of them belongs to whoever knows that one field is a tally and
/// another is a stopwatch. The shell knows neither. So the three formatters
/// below are here rather than there, and they are the same three that used to
/// sit inside the panel.
///
/// The fields are what the two call sites actually write — the playground
/// builds this up over two operations with [copyWith], and `LargeTableDemo`
/// replaces it whole on every regeneration.
@immutable
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.rowCount,
    this.dataGenerationTimeMs,
    this.lastSortTimeMs,
    required this.lastUpdate,
  });

  final int rowCount;
  final int? dataGenerationTimeMs;
  final int? lastSortTimeMs;
  final DateTime lastUpdate;

  PerformanceMetrics copyWith({
    int? rowCount,
    int? dataGenerationTimeMs,
    int? lastSortTimeMs,
    DateTime? lastUpdate,
  }) {
    return PerformanceMetrics(
      rowCount: rowCount ?? this.rowCount,
      dataGenerationTimeMs: dataGenerationTimeMs ?? this.dataGenerationTimeMs,
      lastSortTimeMs: lastSortTimeMs ?? this.lastSortTimeMs,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  /// These numbers as the panel's readings.
  ///
  /// A null time draws no row at all, which is the same as before: a
  /// measurement that has not been taken is not a measurement of zero.
  Metrics toMetrics() => Metrics(
        lastUpdate: lastUpdate,
        readings: [
          Reading(
            label: 'Total Rows',
            value: _count(rowCount),
            icon: Icons.table_rows,
            severity: _severityFor(rowCount),
          ),
          if (dataGenerationTimeMs case final ms?)
            Reading(
              label: 'Data Generation',
              value: _duration(ms),
              subtitle: _rate(rowCount, ms),
              icon: Icons.construction,
            ),
          if (lastSortTimeMs case final ms?)
            Reading(
              label: 'Last Sort',
              value: _duration(ms),
              icon: Icons.sort,
            ),
        ],
      );
}

/// How loud a row count is, and the one thing here the shell could not decide.
///
/// **These three numbers are a fact about tables and about nothing else**,
/// which is exactly why the panel stopped holding them. They are not invented
/// for this file: they were already written down in this example, inside a
/// compact `PerformanceIndicator` that nothing ever built — declared, rendered
/// and reached by no call site, the same shape as the `lastRenderTimeMs` field
/// #109 removed. Deleting the widget without moving the thresholds would have
/// dropped the one judgement it contained.
///
/// **So the panel now carries severity where it used to carry decoration**, and
/// that is a deliberate change rather than a port. Each row had a fixed hue —
/// indigo, green, orange — chosen per field and meaning nothing, which is what
/// an achromatic chrome exists to not do. A hundred thousand rows now reads in
/// `error`, which is what `LargeTableDemo` says its largest count is *for*:
/// making the claim uncomfortable rather than flattering.
///
/// The two durations stay [ReadingSeverity.normal] and therefore achromatic.
/// Nothing in this repository has ever established what a slow generation or a
/// slow sort is, and a threshold invented here would be a number on screen with
/// no measurement behind it.
ReadingSeverity _severityFor(int rowCount) {
  if (rowCount >= 50000) return ReadingSeverity.critical;
  if (rowCount >= 10000) return ReadingSeverity.high;
  if (rowCount >= 1000) return ReadingSeverity.notable;
  return ReadingSeverity.normal;
}

String _count(int number) {
  if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
  if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
  return number.toString();
}

String _duration(int milliseconds) {
  if (milliseconds >= 1000) {
    return '${(milliseconds / 1000).toStringAsFixed(2)}s';
  }
  return '${milliseconds}ms';
}

/// **Null rather than the empty string when there is nothing to divide by.**
/// The panel draws a subtitle whenever one is non-null, so returning `''` — as
/// this did while it lived in the panel — spends a line and a gap on nothing.
/// A zero here is ordinary: a sort of a small list rounds to 0ms.
String? _rate(int count, int timeMs) {
  if (timeMs == 0) return null;
  return '${_count((count / (timeMs / 1000)).round())} rows/sec';
}
