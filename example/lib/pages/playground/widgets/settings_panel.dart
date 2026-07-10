import 'package:flutter/material.dart';

import '../models/playground_settings.dart';
import '../models/settings_spec.dart';
import 'performance_monitor.dart';
import 'settings_controls.dart';
import 'settings_registry.dart';

/// Settings panel widget for the playground
///
/// Provides controls for:
/// - Data quantity (slider + quick buttons)
/// - Table styling (row height, font size, padding)
/// - Feature toggles (sorting, selection, editing, etc.)
/// - Performance monitoring display
class SettingsPanel extends StatefulWidget {
  final PlaygroundSettings settings;
  final PerformanceMetrics performanceMetrics;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final VoidCallback onGenerateData;
  final VoidCallback? onRandomizeWidths;
  final VoidCallback? onRestoreWidths;
  final VoidCallback? onRandomSavedWidths;
  final bool hasSavedWidths;
  final bool isGenerating;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.performanceMetrics,
    required this.onSettingsChanged,
    required this.onGenerateData,
    this.onRandomizeWidths,
    this.onRestoreWidths,
    this.onRandomSavedWidths,
    this.hasSavedWidths = false,
    this.isGenerating = false,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text;
    return Container(
      width: 380,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search settings',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(_search.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            for (final group in settingsSpec) ...[
              _buildGroup(group, query),
              const SizedBox(height: 24),
            ],

            // Performance Monitor
            PerformanceMonitor(metrics: widget.performanceMetrics),
          ],
        ),
      ),
    );
  }

  /// One group of the description, drawn as a collapsible section.
  ///
  /// The panel walks the description for structure and asks the registry how to
  /// draw each id. Nothing here knows what a setting means.
  Widget _buildGroup(SettingGroup group, String query) {
    return buildSection(
      query: query,
      title: group.title,
      icon: _groupIcons[group.id]!,
      color: _groupColors[group.id]!,
      borderColor: _groupBorders[group.id]!,
      initiallyExpanded: group.id == 'data',
      children: [
        for (final feature in group.features) ..._buildFeature(feature),
      ],
    );
  }

  /// A feature's switch, then the options it owns — which only appear while it
  /// is on. Eight of these were guarded by hand; the description knows all of
  /// them.
  List<Widget> _buildFeature(SettingFeature feature) {
    final s = widget.settings;
    final on = feature.switchId == null || _isOn(feature.switchId!);

    return [
      if (feature.switchId != null) _draw(feature.switchId!),
      if (feature.id == 'data') _rowCountBadge(s),
      if (on) ...[
        for (final option in feature.options) _draw(option),
        if (feature.id == 'data') ..._dataExtras(s),
      ],
      const SizedBox(height: 8),
    ];
  }

  Widget _draw(String id) =>
      settingsRegistry[id]!(widget.settings, widget.onSettingsChanged);

  bool _isOn(String switchId) => switch (switchId) {
        'sortingEnabled' => widget.settings.sortingEnabled,
        'selectionEnabled' => widget.settings.selectionEnabled,
        'dragSelectionEnabled' => widget.settings.dragSelectionEnabled,
        'editingEnabled' => widget.settings.editingEnabled,
        'columnReorderEnabled' => widget.settings.columnReorderEnabled,
        'resizableEnabled' => widget.settings.resizableEnabled,
        'tooltipEnabled' => widget.settings.tooltipEnabled,
        'rowCardTooltip' => widget.settings.rowCardTooltip,
        'mergedRowsEnabled' => widget.settings.mergedRowsEnabled,
        'dynamicRowHeight' => widget.settings.dynamicRowHeight,
        'dimInactiveRows' => widget.settings.dimInactiveRows,
        'showAlternateRows' => widget.settings.showAlternateRows,
        'showDividers' => widget.settings.showDividers,
        'headerTopBorderShow' => widget.settings.headerTopBorderShow,
        'headerBottomBorderShow' => widget.settings.headerBottomBorderShow,
        'headerVerticalDividerShow' =>
          widget.settings.headerVerticalDividerShow,
        _ => true,
      };

  Widget _rowCountBadge(PlaygroundSettings s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Row Count',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            formatNumber(s.rowCount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }

  /// The quick presets and the generate button need `onGenerateData`, which no
  /// registry entry is handed, so the panel draws them itself.
  List<Widget> _dataExtras(PlaygroundSettings s) {
    return [
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in [5, 100, 1000, 10000, 100000])
            _quickButton(s, value),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: widget.isGenerating ? null : widget.onGenerateData,
          icon: widget.isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(widget.isGenerating ? 'Generating...' : 'Generate Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    ];
  }

  Widget _quickButton(PlaygroundSettings s, int value) {
    final selected = s.rowCount == value;
    return ElevatedButton(
      onPressed: () => widget.onSettingsChanged(s.copyWith(rowCount: value)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? Colors.green.shade600 : Colors.grey.shade200,
        foregroundColor: selected ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
      ),
      child: Text(
        formatNumber(value),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Playground',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Test FlutterTablePlus with various configurations',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

const _groupIcons = {
  'data': Icons.data_array,
  'interaction': Icons.touch_app,
  'content': Icons.view_agenda_outlined,
  'appearance': Icons.palette_outlined,
};

final _groupColors = {
  'data': Colors.green.shade700,
  'interaction': Colors.blue.shade700,
  'content': Colors.indigo.shade700,
  'appearance': Colors.purple.shade700,
};

final _groupBorders = {
  'data': Colors.green.shade200,
  'interaction': Colors.blue.shade200,
  'content': Colors.indigo.shade200,
  'appearance': Colors.purple.shade200,
};
