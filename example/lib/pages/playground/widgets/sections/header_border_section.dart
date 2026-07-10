import 'package:flutter/material.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class HeaderBorderSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;

  const HeaderBorderSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      title: 'Header Border / Divider',
      icon: Icons.border_all,
      color: Colors.teal.shade700,
      borderColor: Colors.teal.shade200,
      children: [
        // --- Top Border ---
        buildSwitchTile(
          label: 'Top Border',
          value: settings.headerTopBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerTopBorderShow: value));
          },
        ),
        if (settings.headerTopBorderShow)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildSliderSetting(
              label: 'Thickness',
              value: settings.headerTopBorderThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerTopBorderThickness: value));
              },
            ),
          ),
        const SizedBox(height: 4),

        // --- Bottom Border ---
        buildSwitchTile(
          label: 'Bottom Border',
          value: settings.headerBottomBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerBottomBorderShow: value));
          },
        ),
        if (settings.headerBottomBorderShow)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildSliderSetting(
              label: 'Thickness',
              value: settings.headerBottomBorderThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerBottomBorderThickness: value));
              },
            ),
          ),

        const Divider(height: 24),

        // --- Vertical Divider ---
        buildSwitchTile(
          label: 'Vertical Divider',
          value: settings.headerVerticalDividerShow,
          onChanged: (value) {
            onSettingsChanged(
                settings.copyWith(headerVerticalDividerShow: value));
          },
        ),
        if (settings.headerVerticalDividerShow) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildSliderSetting(
              label: 'Thickness',
              value: settings.headerVerticalDividerThickness,
              min: 0.5,
              max: 6,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerThickness: value));
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildSliderSetting(
              label: 'Indent (top)',
              value: settings.headerVerticalDividerIndent,
              min: 0,
              max: 24,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerIndent: value));
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildSliderSetting(
              label: 'End Indent (bottom)',
              value: settings.headerVerticalDividerEndIndent,
              min: 0,
              max: 24,
              unit: 'px',
              onChanged: (value) {
                onSettingsChanged(
                    settings.copyWith(headerVerticalDividerEndIndent: value));
              },
            ),
          ),
        ],

        const Divider(height: 24),

        // --- Resize Handle ---
        if (settings.resizableEnabled) ...[
          buildSliderSetting(
            label: 'Handle Hit Width',
            value: settings.resizeHandleWidth,
            min: 4,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(resizeHandleWidth: value));
            },
          ),
          const SizedBox(height: 8),
          buildSliderSetting(
            label: 'Handle Thickness',
            value: settings.resizeHandleThickness,
            min: 1,
            max: 6,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(resizeHandleThickness: value));
            },
          ),
          const SizedBox(height: 8),
          buildSliderSetting(
            label: 'Handle Indent (top)',
            value: settings.resizeHandleIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(resizeHandleIndent: value));
            },
          ),
          const SizedBox(height: 8),
          buildSliderSetting(
            label: 'Handle End Indent',
            value: settings.resizeHandleEndIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(resizeHandleEndIndent: value));
            },
          ),
        ],
      ],
    );
  }
}
