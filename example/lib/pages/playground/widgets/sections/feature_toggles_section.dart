import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class FeatureTogglesSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final String query;

  const FeatureTogglesSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.query = '',
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      query: query,
      title: 'Feature Toggles',
      icon: Icons.toggle_on,
      color: Colors.orange.shade700,
      borderColor: Colors.orange.shade200,
      children: [
        const SizedBox(height: 12),

        buildSwitchTile(
          label: 'Sorting',
          value: settings.sortingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortingEnabled: value));
          },
        ),

        buildSwitchTile(
          label: 'Editing',
          value: settings.editingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(editingEnabled: value));
          },
        ),

        buildSwitchTile(
          label: 'Column Reorder',
          value: settings.columnReorderEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(columnReorderEnabled: value));
          },
        ),

        buildSwitchTile(
          label: 'Column Resize',
          value: settings.resizableEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(resizableEnabled: value));
          },
        ),

        buildSwitchTile(
          label: 'Stretch Last Column',
          value: settings.stretchLastColumn,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(stretchLastColumn: value));
          },
        ),

        buildSwitchTile(
          label: 'Alternate Rows',
          value: settings.showAlternateRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showAlternateRows: value));
          },
        ),

        buildSwitchTile(
          label: 'Row Card Tooltip',
          value: settings.rowCardTooltip,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowCardTooltip: value));
          },
        ),

        buildDropdownRow<InkColorOption>(
          label: 'Splash Color',
          value: settings.splashColor,
          items: InkColorOption.values,
          itemLabel: (option) => option.label,
          onChanged: (option) {
            onSettingsChanged(settings.copyWith(splashColor: option));
          },
        ),

        buildDropdownRow<InkColorOption>(
          label: 'Hover Color',
          value: settings.hoverColor,
          items: InkColorOption.values,
          itemLabel: (option) => option.label,
          onChanged: (option) {
            onSettingsChanged(settings.copyWith(hoverColor: option));
          },
        ),

        buildDropdownRow<InkColorOption>(
          label: 'Highlight Color',
          value: settings.highlightColor,
          items: InkColorOption.values,
          itemLabel: (option) => option.label,
          onChanged: (option) {
            onSettingsChanged(settings.copyWith(highlightColor: option));
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Row splash needs Selection on and Editing off — while editing, the '
            'ink layer stays for row gestures but the selection splash is '
            'suppressed.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ),

        buildSwitchTile(
          label: 'Show Dividers',
          value: settings.showDividers,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showDividers: value));
          },
        ),

        buildSwitchTile(
          label: 'Merged Rows',
          value: settings.mergedRowsEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(mergedRowsEnabled: value));
          },
        ),

        buildSwitchTile(
          label: 'Dynamic Row Height',
          value: settings.dynamicRowHeight,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dynamicRowHeight: value));
          },
        ),

        buildSwitchTile(
          label: 'Dim Inactive Rows',
          value: settings.dimInactiveRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dimInactiveRows: value));
          },
        ),

        buildSwitchTile(
          label: 'Selection (Checkbox)',
          value: settings.selectionEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(selectionEnabled: value));
          },
        ),

        if (settings.selectionEnabled) ...[
          buildSwitchTile(
            label: 'Show Checkbox Column',
            value: settings.showCheckboxColumn,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showCheckboxColumn: value));
            },
          ),
          buildSwitchTile(
            label: 'Select All',
            value: settings.selectAllEnabled,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(selectAllEnabled: value));
            },
          ),
          buildSwitchTile(
            label: 'Drag Selection',
            value: settings.dragSelectionEnabled,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(dragSelectionEnabled: value));
            },
          ),
          buildSwitchTile(
            label: 'Cell Tap Toggles Checkbox',
            value: settings.cellTapTogglesCheckbox,
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(cellTapTogglesCheckbox: value));
            },
          ),
          buildSwitchTile(
            label: 'Show Row Checkbox',
            value: settings.showRowCheckbox,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(showRowCheckbox: value));
            },
          ),
        ],

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // Selection mode dropdown
        buildDropdownRow<SelectionMode>(
          label: 'Selection Mode',
          value: settings.selectionMode,
          items: SelectionMode.values,
          itemLabel: (mode) => mode.name.toUpperCase(),
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(selectionMode: value));
          },
        ),
        const SizedBox(height: 8),

        // Sort cycle order dropdown
        buildDropdownRow<SortCycleOrder>(
          label: 'Sort Cycle',
          value: settings.sortCycleOrder,
          items: SortCycleOrder.values,
          itemLabel: (order) => order == SortCycleOrder.ascendingFirst
              ? 'ASC First'
              : 'DESC First',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortCycleOrder: value));
          },
        ),
      ],
    );
  }
}
