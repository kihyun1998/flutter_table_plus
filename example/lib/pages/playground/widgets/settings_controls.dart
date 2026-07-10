import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Whether a control named [label] should survive a search for [query].
///
/// A blank query is not a search, so everything survives it. Otherwise the
/// query is a substring of the label, in any case and anywhere within it —
/// someone hunting the tooltip anchors types "anchor", not "Cell Anchor".
bool settingMatches(String label, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  return label.toLowerCase().contains(needle);
}

/// One labelled control in the settings panel.
///
/// The label travels with the widget rather than being buried inside it, so a
/// section can ask what its children are before it builds them — which is what
/// searching across 68 controls needs and a bare `Widget` cannot answer.
class SettingsControl extends StatelessWidget {
  const SettingsControl({
    super.key,
    required this.id,
    required this.label,
    required this.child,
    this.indent = false,
  });

  /// Names the settings field this control edits, and nothing else.
  ///
  /// The label is prose: it repeats across sections and a redesign is free to
  /// rewrite it. The id is what anything wanting to reason about a control —
  /// which feature owns it, what it depends on — has to hold onto instead.
  final String id;

  /// The text the user reads, and the text a search matches against.
  final String label;

  /// Whether this control belongs under the one above it.
  final bool indent;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!indent) return child;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: child,
    );
  }
}

/// The controls the settings panes are built from. Each is pure: it renders
/// what it is handed and reports back through its callback, knowing nothing of
/// PlaygroundSettings or of which feature it belongs to.
SettingsControl buildSliderSetting({
  required String id,
  required String label,
  required double value,
  required double min,
  required double max,
  required String unit,
  required ValueChanged<double> onChanged,
  int decimalPlaces = 0,
  bool indent = false,
}) {
  final displayValue = decimalPlaces > 0
      ? value.toStringAsFixed(decimalPlaces)
      : '${value.round()}';
  return SettingsControl(
    id: id,
    label: label,
    indent: indent,
    child: Column(
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
    ),
  );
}

SettingsControl buildSwitchTile({
  required String id,
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
  bool indent = false,
}) {
  return SettingsControl(
    id: id,
    label: label,
    indent: indent,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // The panel is a fixed 380 wide. The label has to yield the space the
          // control needs, not push it off the edge — a wider text scale, or a
          // longer translation, will ask it to.
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    ),
  );
}

SettingsControl buildDropdownRow<T>({
  required String id,
  required String label,
  required T value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T> onChanged,
  bool indent = false,
}) {
  return SettingsControl(
    id: id,
    label: label,
    indent: indent,
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
    ),
  );
}

SettingsControl buildLogSlider({
  required String id,
  required String label,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  // Convert to logarithmic scale
  final logMin = math.log(min) / math.ln10;
  final logMax = math.log(max) / math.ln10;
  final logValue = math.log(value) / math.ln10;

  return SettingsControl(
    id: id,
    label: label,
    child: Slider(
      value: logValue,
      min: logMin,
      max: logMax,
      divisions: 100,
      onChanged: (logVal) {
        final actualValue = math.pow(10, logVal).toDouble();
        onChanged(actualValue);
      },
    ),
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
