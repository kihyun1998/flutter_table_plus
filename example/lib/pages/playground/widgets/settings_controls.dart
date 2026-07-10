import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The controls the settings panel is built from. Each is pure: it renders what
/// it is handed and reports back through its callback, knowing nothing of
/// PlaygroundSettings or of which section it sits in.
Widget buildSection({
  required String title,
  required IconData icon,
  required Color color,
  required Color borderColor,
  required List<Widget> children,
  bool initiallyExpanded = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      initiallyExpanded: initiallyExpanded,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      children: children,
    ),
  );
}

Widget buildSliderSetting({
  required String label,
  required double value,
  required double min,
  required double max,
  required String unit,
  required ValueChanged<double> onChanged,
  int decimalPlaces = 0,
}) {
  final displayValue = decimalPlaces > 0
      ? value.toStringAsFixed(decimalPlaces)
      : '${value.round()}';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$displayValue$unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: ((max - min) / (decimalPlaces > 0 ? 0.05 : 2)).round(),
        onChanged: onChanged,
      ),
    ],
  );
}

Widget buildSwitchTile({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}

Widget buildDropdownRow<T>({
  required String label,
  required T value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T> onChanged,
}) {
  return Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      DropdownButton<T>(
        value: value,
        onChanged: (T? newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget buildLogSlider({
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  // Convert to logarithmic scale
  final logMin = math.log(min) / math.ln10;
  final logMax = math.log(max) / math.ln10;
  final logValue = math.log(value) / math.ln10;

  return Slider(
    value: logValue,
    min: logMin,
    max: logMax,
    divisions: 100,
    onChanged: (logVal) {
      final actualValue = math.pow(10, logVal).toDouble();
      onChanged(actualValue);
    },
  );
}

String formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}
