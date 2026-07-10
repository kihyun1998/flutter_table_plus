import 'package:flutter/material.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class HeaderBorderSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final String query;

  const HeaderBorderSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.query = '',
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      query: query,
      title: 'Header Border / Divider',
      icon: Icons.border_all,
      color: Colors.teal.shade700,
      borderColor: Colors.teal.shade200,
      children: [
        // --- Top Border ---
        buildSwitchTile(
          id: 'headerTopBorderShow',
          label: 'Top Border',
          value: settings.headerTopBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerTopBorderShow: value));
          },
        ),
        if (settings.headerTopBorderShow)
          buildSliderSetting(
            id: 'headerTopBorderThickness',
            label: 'Thickness',
            value: settings.headerTopBorderThickness,
            min: 0.5,
            max: 6,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerTopBorderThickness: value));
            },
            indent: true,
          ),
        const SizedBox(height: 4),

        // --- Bottom Border ---
        buildSwitchTile(
          id: 'headerBottomBorderShow',
          label: 'Bottom Border',
          value: settings.headerBottomBorderShow,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(headerBottomBorderShow: value));
          },
        ),
        if (settings.headerBottomBorderShow)
          buildSliderSetting(
            id: 'headerBottomBorderThickness',
            label: 'Thickness',
            value: settings.headerBottomBorderThickness,
            min: 0.5,
            max: 6,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerBottomBorderThickness: value));
            },
            indent: true,
          ),

        const Divider(height: 24),

        // --- Vertical Divider ---
        buildSwitchTile(
          id: 'headerVerticalDividerShow',
          label: 'Vertical Divider',
          value: settings.headerVerticalDividerShow,
          onChanged: (value) {
            onSettingsChanged(
                settings.copyWith(headerVerticalDividerShow: value));
          },
        ),
        if (settings.headerVerticalDividerShow) ...[
          buildSliderSetting(
            id: 'headerVerticalDividerThickness',
            label: 'Thickness',
            value: settings.headerVerticalDividerThickness,
            min: 0.5,
            max: 6,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerVerticalDividerThickness: value));
            },
            indent: true,
          ),
          const SizedBox(height: 8),
          buildSliderSetting(
            id: 'headerVerticalDividerIndent',
            label: 'Indent (top)',
            value: settings.headerVerticalDividerIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerVerticalDividerIndent: value));
            },
            indent: true,
          ),
          const SizedBox(height: 8),
          buildSliderSetting(
            id: 'headerVerticalDividerEndIndent',
            label: 'End Indent (bottom)',
            value: settings.headerVerticalDividerEndIndent,
            min: 0,
            max: 24,
            unit: 'px',
            onChanged: (value) {
              onSettingsChanged(
                  settings.copyWith(headerVerticalDividerEndIndent: value));
            },
            indent: true,
          ),
        ],

        const Divider(height: 24),

        // --- Resize Handle ---
        if (settings.resizableEnabled) ...[
          buildSliderSetting(
            id: 'resizeHandleWidth',
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
            id: 'resizeHandleThickness',
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
            id: 'resizeHandleIndent',
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
            id: 'resizeHandleEndIndent',
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
