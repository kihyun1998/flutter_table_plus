import 'package:flutter/material.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class StyleSettingsSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final String query;
  final VoidCallback? onRandomizeWidths;

  const StyleSettingsSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.query = '',
    this.onRandomizeWidths,
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      query: query,
      title: 'Style Settings',
      icon: Icons.palette,
      color: Colors.purple.shade700,
      borderColor: Colors.purple.shade200,
      children: [
        const SizedBox(height: 12),

        // Font family
        buildDropdownRow<String>(
          label: 'Font Family',
          value: settings.fontFamily,
          items: const [
            'default',
            'pretendard',
            'notoSansKr',
            'inter',
            'firaCode'
          ],
          itemLabel: (font) => switch (font) {
            'default' => 'Default (Roboto)',
            'pretendard' => 'Pretendard',
            'notoSansKr' => 'Noto Sans KR',
            'inter' => 'Inter',
            'firaCode' => 'Fira Code',
            _ => font,
          },
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(fontFamily: value));
          },
        ),
        const SizedBox(height: 16),

        // Scale (zoom)
        buildSliderSetting(
          label: 'Scale',
          value: settings.scale,
          min: 0.25,
          max: 3.0,
          unit: 'x',
          decimalPlaces: 2,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(scale: value));
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              onSettingsChanged(settings.copyWith(scale: 1.0));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
            ),
            child: const Text('Reset (1.0x)', style: TextStyle(fontSize: 11)),
          ),
        ),
        buildSwitchTile(
          label: 'Block Modifier+Scroll',
          value: settings.blockModifierScroll,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(blockModifierScroll: value));
          },
        ),
        const SizedBox(height: 12),

        // Column min width
        buildSliderSetting(
          label: 'Col Min Width',
          value: settings.columnMinWidth,
          min: 20,
          max: 150,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(columnMinWidth: value));
          },
        ),
        const SizedBox(height: 12),

        // Randomize column widths button
        if (onRandomizeWidths != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRandomizeWidths,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Randomize Column Widths'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple.shade700,
                side: BorderSide(color: Colors.purple.shade300),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Row height
        buildSliderSetting(
          label: 'Row Height',
          value: settings.rowHeight,
          min: 30,
          max: 100,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowHeight: value));
          },
        ),
        const SizedBox(height: 16),

        // Font size
        buildSliderSetting(
          label: 'Font Size',
          value: settings.fontSize,
          min: 10,
          max: 24,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(fontSize: value));
          },
        ),
        const SizedBox(height: 16),

        // Horizontal padding
        buildSliderSetting(
          label: 'H-Padding',
          value: settings.horizontalPadding,
          min: 4,
          max: 32,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(horizontalPadding: value));
          },
        ),
        const SizedBox(height: 16),

        // Vertical padding
        buildSliderSetting(
          label: 'V-Padding',
          value: settings.verticalPadding,
          min: 4,
          max: 24,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(verticalPadding: value));
          },
        ),
        const SizedBox(height: 16),

        // Checkbox tap target size
        buildSliderSetting(
          label: 'Checkbox Tap Size',
          value: settings.checkboxTapTargetSize,
          min: 18,
          max: 56,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(checkboxTapTargetSize: value));
          },
        ),
        const SizedBox(height: 16),

        // Sort icon width
        buildSliderSetting(
          label: 'Sort Icon Width',
          value: settings.sortIconWidth,
          min: 8,
          max: 32,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortIconWidth: value));
          },
        ),
      ],
    );
  }
}
