import 'package:flutter/material.dart';

/// Formatting the playground shares between its columns and its own chrome.

String formatPlaygroundNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

Color performanceColor(double performance) {
  if (performance >= 0.9) {
    return Colors.green.shade600;
  } else if (performance >= 0.75) {
    return Colors.blue.shade600;
  } else if (performance >= 0.6) {
    return Colors.orange.shade600;
  } else {
    return Colors.red.shade600;
  }
}
