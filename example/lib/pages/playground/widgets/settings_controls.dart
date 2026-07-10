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
    required this.label,
    required this.child,
    this.indent = false,
  });

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
  String query = '',
}) {
  return SettingsSection(
    title: title,
    icon: icon,
    color: color,
    borderColor: borderColor,
    initiallyExpanded: initiallyExpanded,
    query: query,
    children: children,
  );
}

/// A collapsible group of controls, which a search can see through.
///
/// While [query] is blank the section behaves as it always has: it remembers
/// whether the reader opened it. While a search is running it shows only the
/// [SettingsControl]s whose labels match, opens itself to show them, and stands
/// aside entirely when it holds none — and it does not disturb the expanded
/// state it will go back to once the query is cleared.
class SettingsSection extends StatefulWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.children,
    this.initiallyExpanded = false,
    this.query = '',
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final List<Widget> children;
  final bool initiallyExpanded;
  final String query;

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _searching => widget.query.trim().isNotEmpty;

  /// Under a search, only the labelled controls survive. The dividers, spacers
  /// and explanatory notes between them belong to the section as it reads, not
  /// to the control the reader is hunting for.
  List<Widget> get _visibleChildren {
    if (!_searching) return widget.children;
    return widget.children
        .whereType<SettingsControl>()
        .where((c) => settingMatches(c.label, widget.query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final children = _visibleChildren;
    if (_searching && children.isEmpty) return const SizedBox.shrink();

    final expanded = _searching || _expanded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            // A search decides what is open, so the header stops taking taps
            // while one is running rather than fighting it.
            onTap:
                _searching ? null : () => setState(() => _expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.color,
                      ),
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

SettingsControl buildSliderSetting({
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
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
  bool indent = false,
}) {
  return SettingsControl(
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
  required String label,
  required T value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T> onChanged,
  bool indent = false,
}) {
  return SettingsControl(
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
