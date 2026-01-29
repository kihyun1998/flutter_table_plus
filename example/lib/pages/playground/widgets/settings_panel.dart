import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'performance_monitor.dart';

/// Playground settings configuration
class PlaygroundSettings {
  // Data settings
  final int rowCount;

  // Style settings
  final double rowHeight;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  // Feature toggles
  final bool sortingEnabled;
  final SelectionMode selectionMode;
  final bool editingEnabled;
  final bool mergedRowsEnabled;
  final bool columnReorderEnabled;
  final bool showAlternateRows;
  final bool showDividers;
  final bool dynamicRowHeight;
  final bool dimInactiveRows;
  final bool showCheckboxColumn;
  final bool selectAllEnabled;
  final SortCycleOrder sortCycleOrder;
  final TooltipBehavior tooltipBehavior;

  const PlaygroundSettings({
    this.rowCount = 100,
    this.rowHeight = 50.0,
    this.fontSize = 14.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 12.0,
    this.sortingEnabled = true,
    this.selectionMode = SelectionMode.multiple,
    this.editingEnabled = true,
    this.mergedRowsEnabled = false,
    this.columnReorderEnabled = true,
    this.showAlternateRows = true,
    this.showDividers = true,
    this.dynamicRowHeight = false,
    this.dimInactiveRows = false,
    this.showCheckboxColumn = true,
    this.selectAllEnabled = true,
    this.sortCycleOrder = SortCycleOrder.ascendingFirst,
    this.tooltipBehavior = TooltipBehavior.always,
  });

  PlaygroundSettings copyWith({
    int? rowCount,
    double? rowHeight,
    double? fontSize,
    double? horizontalPadding,
    double? verticalPadding,
    bool? sortingEnabled,
    SelectionMode? selectionMode,
    bool? editingEnabled,
    bool? mergedRowsEnabled,
    bool? columnReorderEnabled,
    bool? showAlternateRows,
    bool? showDividers,
    bool? dynamicRowHeight,
    bool? dimInactiveRows,
    bool? showCheckboxColumn,
    bool? selectAllEnabled,
    SortCycleOrder? sortCycleOrder,
    TooltipBehavior? tooltipBehavior,
  }) {
    return PlaygroundSettings(
      rowCount: rowCount ?? this.rowCount,
      rowHeight: rowHeight ?? this.rowHeight,
      fontSize: fontSize ?? this.fontSize,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      sortingEnabled: sortingEnabled ?? this.sortingEnabled,
      selectionMode: selectionMode ?? this.selectionMode,
      editingEnabled: editingEnabled ?? this.editingEnabled,
      mergedRowsEnabled: mergedRowsEnabled ?? this.mergedRowsEnabled,
      columnReorderEnabled: columnReorderEnabled ?? this.columnReorderEnabled,
      showAlternateRows: showAlternateRows ?? this.showAlternateRows,
      showDividers: showDividers ?? this.showDividers,
      dynamicRowHeight: dynamicRowHeight ?? this.dynamicRowHeight,
      dimInactiveRows: dimInactiveRows ?? this.dimInactiveRows,
      showCheckboxColumn: showCheckboxColumn ?? this.showCheckboxColumn,
      selectAllEnabled: selectAllEnabled ?? this.selectAllEnabled,
      sortCycleOrder: sortCycleOrder ?? this.sortCycleOrder,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
    );
  }
}

/// Settings panel widget for the playground
///
/// Provides controls for:
/// - Data quantity (slider + quick buttons)
/// - Table styling (row height, font size, padding)
/// - Feature toggles (sorting, selection, editing, etc.)
/// - Performance monitoring display
class SettingsPanel extends StatelessWidget {
  final PlaygroundSettings settings;
  final PerformanceMetrics performanceMetrics;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final VoidCallback onGenerateData;
  final bool isGenerating;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.performanceMetrics,
    required this.onSettingsChanged,
    required this.onGenerateData,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 24),

            // Data Settings
            _buildDataSettings(),
            const SizedBox(height: 24),

            // Style Settings
            _buildStyleSettings(),
            const SizedBox(height: 24),

            // Feature Toggles
            _buildFeatureToggles(),
            const SizedBox(height: 24),

            // Performance Monitor
            PerformanceMonitor(metrics: performanceMetrics),
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

  Widget _buildDataSettings() {
    return _buildSection(
      title: 'Data Settings',
      icon: Icons.data_array,
      color: Colors.green,
      children: [
        const SizedBox(height: 12),

        // Row count label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Row Count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatNumber(settings.rowCount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Logarithmic slider (10 to 100,000)
        _buildLogSlider(
          value: settings.rowCount.toDouble(),
          min: 10,
          max: 100000,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowCount: value.round()));
          },
        ),
        const SizedBox(height: 16),

        // Quick select buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton('100', 100),
            _buildQuickButton('1K', 1000),
            _buildQuickButton('10K', 10000),
            _buildQuickButton('100K', 100000),
          ],
        ),
        const SizedBox(height: 16),

        // Generate button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isGenerating ? null : onGenerateData,
            icon: isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(isGenerating ? 'Generating...' : 'Generate Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSettings() {
    return _buildSection(
      title: 'Style Settings',
      icon: Icons.palette,
      color: Colors.purple,
      children: [
        const SizedBox(height: 12),

        // Row height
        _buildSliderSetting(
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
        _buildSliderSetting(
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
        _buildSliderSetting(
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
        _buildSliderSetting(
          label: 'V-Padding',
          value: settings.verticalPadding,
          min: 4,
          max: 24,
          unit: 'px',
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(verticalPadding: value));
          },
        ),
      ],
    );
  }

  Widget _buildFeatureToggles() {
    return _buildSection(
      title: 'Feature Toggles',
      icon: Icons.toggle_on,
      color: Colors.orange,
      children: [
        const SizedBox(height: 12),

        _buildSwitchTile(
          label: 'Sorting',
          value: settings.sortingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(sortingEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Editing',
          value: settings.editingEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(editingEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Column Reorder',
          value: settings.columnReorderEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(columnReorderEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Alternate Rows',
          value: settings.showAlternateRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showAlternateRows: value));
          },
        ),

        _buildSwitchTile(
          label: 'Show Dividers',
          value: settings.showDividers,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showDividers: value));
          },
        ),

        _buildSwitchTile(
          label: 'Merged Rows',
          value: settings.mergedRowsEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(mergedRowsEnabled: value));
          },
        ),

        _buildSwitchTile(
          label: 'Dynamic Row Height',
          value: settings.dynamicRowHeight,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dynamicRowHeight: value));
          },
        ),

        _buildSwitchTile(
          label: 'Dim Inactive Rows',
          value: settings.dimInactiveRows,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(dimInactiveRows: value));
          },
        ),

        _buildSwitchTile(
          label: 'Show Checkbox Column',
          value: settings.showCheckboxColumn,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(showCheckboxColumn: value));
          },
        ),

        _buildSwitchTile(
          label: 'Select All',
          value: settings.selectAllEnabled,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(selectAllEnabled: value));
          },
        ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // Selection mode dropdown
        _buildDropdownRow<SelectionMode>(
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
        _buildDropdownRow<SortCycleOrder>(
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
        const SizedBox(height: 8),

        // Tooltip behavior dropdown
        _buildDropdownRow<TooltipBehavior>(
          label: 'Tooltip',
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
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color.shade800,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
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
              '${value.round()}$unit',
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
          divisions: ((max - min) / 2).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
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

  Widget _buildDropdownRow<T>({
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

  Widget _buildLogSlider({
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

  Widget _buildQuickButton(String label, int value) {
    final isSelected = settings.rowCount == value;
    return ElevatedButton(
      onPressed: () {
        onSettingsChanged(settings.copyWith(rowCount: value));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.green.shade600 : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
