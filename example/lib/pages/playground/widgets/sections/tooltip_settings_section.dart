import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class TooltipSettingsSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final String query;

  const TooltipSettingsSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.query = '',
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      query: query,
      title: 'Tooltip Settings',
      icon: Icons.chat_bubble_outline,
      color: Colors.indigo.shade700,
      borderColor: Colors.indigo.shade200,
      children: [
        const SizedBox(height: 12),

        // Tooltip enabled toggle
        buildSwitchTile(
          id: 'tooltipEnabled',
          label: 'Tooltip Enabled',
          value: settings.tooltipEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(tooltipEnabled: value));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            'Off silences the row card too, not just cells and headers',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),

        if (settings.tooltipEnabled) ...[
          const SizedBox(height: 8),

          // Cell tooltip behavior
          buildDropdownRow<TooltipBehavior>(
            id: 'tooltipBehavior',
            label: 'Cell Tooltip',
            value: settings.tooltipBehavior,
            items: TooltipBehavior.values,
            itemLabel: (behavior) => switch (behavior) {
              TooltipBehavior.always => 'Always',
              TooltipBehavior.never => 'Never',
              TooltipBehavior.onlyTextOverflow => 'On Overflow',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipBehavior: value));
            },
          ),
          const SizedBox(height: 4),

          // Header tooltip behavior
          buildDropdownRow<TooltipBehavior>(
            id: 'headerTooltipBehavior',
            label: 'Header Tooltip',
            value: settings.headerTooltipBehavior,
            items: TooltipBehavior.values,
            itemLabel: (behavior) => switch (behavior) {
              TooltipBehavior.always => 'Always',
              TooltipBehavior.never => 'Never',
              TooltipBehavior.onlyTextOverflow => 'On Overflow',
            },
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerTooltipBehavior: value));
            },
          ),

          const Divider(height: 24),

          // Wait duration slider
          buildSliderSetting(
            id: 'tooltipWaitDurationMs',
            label: 'Wait Duration',
            value: settings.tooltipWaitDurationMs.toDouble(),
            min: 0,
            max: 2000,
            unit: 'ms',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(tooltipWaitDurationMs: value.round()));
            },
          ),

          // The card is bigger and more interruptive than a line of text, so
          // it gets its own pause rather than borrowing the cells'.
          buildSliderSetting(
            id: 'rowCardWaitDurationMs',
            label: 'Row Card Wait',
            value: settings.rowCardWaitDurationMs.toDouble(),
            min: 0,
            max: 2000,
            unit: 'ms',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(rowCardWaitDurationMs: value.round()));
            },
          ),

          const Divider(height: 24),

          // Direction
          buildDropdownRow<TooltipDirection>(
            id: 'tooltipDirection',
            label: 'Direction',
            value: settings.tooltipDirection,
            items: TooltipDirection.values,
            itemLabel: (d) => switch (d) {
              TooltipDirection.top => 'Top',
              TooltipDirection.bottom => 'Bottom',
              TooltipDirection.left => 'Left',
              TooltipDirection.right => 'Right',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipDirection: value));
            },
          ),
          const SizedBox(height: 4),

          // Anchor — cells
          buildDropdownRow<TooltipAnchor>(
            id: 'tooltipAnchor',
            label: 'Cell Anchor',
            value: settings.tooltipAnchor,
            items: TooltipAnchor.values,
            itemLabel: (a) => switch (a) {
              TooltipAnchor.child => 'Child',
              TooltipAnchor.pointer => 'Pointer',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipAnchor: value));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              'The row card always anchors at the pointer; it ignores this',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),

          // Anchor — headers
          buildDropdownRow<HeaderTooltipAnchor>(
            id: 'headerTooltipAnchor',
            label: 'Header Anchor',
            value: settings.headerTooltipAnchor,
            items: HeaderTooltipAnchor.values,
            itemLabel: (a) => switch (a) {
              HeaderTooltipAnchor.followCells => 'Follow Cells',
              HeaderTooltipAnchor.child => 'Child',
              HeaderTooltipAnchor.pointer => 'Pointer',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(headerTooltipAnchor: value));
            },
          ),
          const SizedBox(height: 4),

          // Alignment
          buildDropdownRow<TooltipAlignment>(
            id: 'tooltipAlignment',
            label: 'Alignment',
            value: settings.tooltipAlignment,
            items: TooltipAlignment.values,
            itemLabel: (a) => switch (a) {
              TooltipAlignment.start => 'Start',
              TooltipAlignment.center => 'Center',
              TooltipAlignment.end => 'End',
              TooltipAlignment.startTargetCenter => 'Start Target Center',
              TooltipAlignment.endTargetCenter => 'End Target Center',
            },
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipAlignment: value));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              settings.tooltipAnchor == TooltipAnchor.pointer
                  ? "Against the pointer there are no target edges, so this "
                      "picks which of the tooltip's own edges lands on the cursor"
                  : 'Picks which edge of the target the tooltip lines up with',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),

          // Show Arrow
          buildSwitchTile(
            id: 'tooltipShowArrow',
            label: 'Show Arrow',
            value: settings.tooltipShowArrow,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(tooltipShowArrow: value));
            },
          ),

          // Offset slider
          buildSliderSetting(
            id: 'tooltipOffset',
            label: 'Offset',
            value: settings.tooltipOffset,
            min: 0,
            max: 32,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(tooltipOffset: value.roundToDouble()));
            },
          ),

          const Divider(height: 24),

          // Demo: tooltipFormatter
          buildSwitchTile(
            id: 'showTooltipFormatter',
            label: 'tooltipFormatter (Email)',
            value: settings.showTooltipFormatter,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showTooltipFormatter: value));
            },
          ),
          if (settings.showTooltipFormatter)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'Email column shows "Send to: {email}" tooltip',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),

          // Demo: tooltipBuilder
          buildSwitchTile(
            id: 'showTooltipBuilder',
            label: 'tooltipBuilder (Name)',
            value: settings.showTooltipBuilder,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showTooltipBuilder: value));
            },
          ),
          if (settings.showTooltipBuilder)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'Name column shows rich widget tooltip with employee details',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
        ],
      ],
    );
  }
}
