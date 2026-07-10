import 'package:flutter/material.dart';

import '../models/playground_settings.dart';
import 'performance_monitor.dart';
import 'sections/data_settings_section.dart';
import 'sections/feature_toggles_section.dart';
import 'sections/header_border_section.dart';
import 'sections/style_settings_section.dart';
import 'sections/tooltip_settings_section.dart';

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

            // Data Settings
            DataSettingsSection(
              query: query,
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
              onGenerateData: widget.onGenerateData,
              isGenerating: widget.isGenerating,
            ),
            const SizedBox(height: 16),

            // Width persistence demo buttons
            if (widget.onRestoreWidths != null)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: widget.onRandomSavedWidths,
                        icon: const Icon(Icons.shuffle, size: 18),
                        label: const Text('Random'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(color: Colors.orange.shade400),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: widget.hasSavedWidths
                            ? widget.onRestoreWidths
                            : null,
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Restore'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(
                            color: widget.hasSavedWidths
                                ? Colors.orange.shade400
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Style Settings
            StyleSettingsSection(
              query: query,
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
              onRandomizeWidths: widget.onRandomizeWidths,
            ),
            const SizedBox(height: 24),

            // Header Border/Divider Settings
            HeaderBorderSection(
              query: query,
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
            ),
            const SizedBox(height: 24),

            // Feature Toggles
            FeatureTogglesSection(
              query: query,
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
            ),
            const SizedBox(height: 24),

            // Tooltip Settings
            TooltipSettingsSection(
              query: query,
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
            ),
            const SizedBox(height: 24),

            // Performance Monitor
            PerformanceMonitor(metrics: widget.performanceMetrics),
          ],
        ),
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
