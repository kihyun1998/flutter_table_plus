import 'package:flutter/material.dart';

/// Performance metrics data model
class PerformanceMetrics {
  final int rowCount;
  final int? dataGenerationTimeMs;
  final int? lastSortTimeMs;
  final int? lastRenderTimeMs;
  final DateTime lastUpdate;

  const PerformanceMetrics({
    required this.rowCount,
    this.dataGenerationTimeMs,
    this.lastSortTimeMs,
    this.lastRenderTimeMs,
    required this.lastUpdate,
  });

  PerformanceMetrics copyWith({
    int? rowCount,
    int? dataGenerationTimeMs,
    int? lastSortTimeMs,
    int? lastRenderTimeMs,
    DateTime? lastUpdate,
  }) {
    return PerformanceMetrics(
      rowCount: rowCount ?? this.rowCount,
      dataGenerationTimeMs: dataGenerationTimeMs ?? this.dataGenerationTimeMs,
      lastSortTimeMs: lastSortTimeMs ?? this.lastSortTimeMs,
      lastRenderTimeMs: lastRenderTimeMs ?? this.lastRenderTimeMs,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Performance monitoring widget for the playground
///
/// Displays real-time performance metrics including:
/// - Current row count
/// - Data generation time
/// - Sort operation time
/// - Render time
class PerformanceMonitor extends StatelessWidget {
  final PerformanceMetrics metrics;

  const PerformanceMonitor({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row count
          _buildMetricRow(
            icon: Icons.table_rows,
            label: 'Total Rows',
            value: _formatNumber(metrics.rowCount),
            color: Colors.indigo,
          ),
          const SizedBox(height: 12),

          // Data generation time
          if (metrics.dataGenerationTimeMs != null)
            _buildMetricRow(
              icon: Icons.construction,
              label: 'Data Generation',
              value: _formatTime(metrics.dataGenerationTimeMs!),
              color: Colors.green,
              subtitle: _formatRate(metrics.rowCount, metrics.dataGenerationTimeMs!),
            ),
          if (metrics.dataGenerationTimeMs != null) const SizedBox(height: 12),

          // Sort time
          if (metrics.lastSortTimeMs != null)
            _buildMetricRow(
              icon: Icons.sort,
              label: 'Last Sort',
              value: _formatTime(metrics.lastSortTimeMs!),
              color: Colors.orange,
            ),
          if (metrics.lastSortTimeMs != null) const SizedBox(height: 12),

          // Render time
          if (metrics.lastRenderTimeMs != null)
            _buildMetricRow(
              icon: Icons.brush,
              label: 'Last Render',
              value: _formatTime(metrics.lastRenderTimeMs!),
              color: Colors.purple,
            ),
          if (metrics.lastRenderTimeMs != null) const SizedBox(height: 12),

          // Last update time
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_formatDateTime(metrics.lastUpdate)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTime(int milliseconds) {
    if (milliseconds >= 1000) {
      return '${(milliseconds / 1000).toStringAsFixed(2)}s';
    }
    return '${milliseconds}ms';
  }

  String _formatRate(int count, int timeMs) {
    if (timeMs == 0) return '';
    final rate = (count / (timeMs / 1000)).round();
    return '${_formatNumber(rate)} rows/sec';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Simplified performance indicator for compact display
class PerformanceIndicator extends StatelessWidget {
  final PerformanceMetrics metrics;

  const PerformanceIndicator({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPerformanceColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPerformanceIcon(),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '${_formatNumber(metrics.rowCount)} rows',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (metrics.lastSortTimeMs != null) ...[
            const SizedBox(width: 8),
            const Text(
              '•',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 8),
            Text(
              'Sort: ${_formatTime(metrics.lastSortTimeMs!)}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPerformanceColor() {
    if (metrics.rowCount >= 50000) {
      return Colors.red.shade600;
    } else if (metrics.rowCount >= 10000) {
      return Colors.orange.shade600;
    } else if (metrics.rowCount >= 1000) {
      return Colors.blue.shade600;
    }
    return Colors.green.shade600;
  }

  IconData _getPerformanceIcon() {
    if (metrics.rowCount >= 50000) {
      return Icons.warning_amber;
    } else if (metrics.rowCount >= 10000) {
      return Icons.speed;
    }
    return Icons.check_circle;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTime(int milliseconds) {
    if (milliseconds >= 1000) {
      return '${(milliseconds / 1000).toStringAsFixed(2)}s';
    }
    return '${milliseconds}ms';
  }
}
