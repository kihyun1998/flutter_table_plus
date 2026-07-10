import 'package:flutter/material.dart';

import '../../models/playground_settings.dart';
import '../settings_controls.dart';

class DataSettingsSection extends StatelessWidget {
  final PlaygroundSettings settings;
  final ValueChanged<PlaygroundSettings> onSettingsChanged;
  final String query;
  final VoidCallback onGenerateData;
  final bool isGenerating;

  const DataSettingsSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.query = '',
    required this.onGenerateData,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return buildSection(
      query: query,
      title: 'Data Settings',
      icon: Icons.data_array,
      color: Colors.green.shade700,
      borderColor: Colors.green.shade200,
      initiallyExpanded: true,
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
                formatNumber(settings.rowCount),
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

        // Logarithmic slider (5 to 100,000)
        buildLogSlider(
          label: 'Row Count',
          value: settings.rowCount.toDouble(),
          min: 5,
          max: 100000,
          onChanged: (value) {
            onSettingsChanged(settings.copyWith(rowCount: value.round()));
          },
        ),
        const SizedBox(height: 16),

        // Quick select buttons. The "5" preset leaves a large empty area
        // below the last row, useful for testing drag-selection edge cases.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton('5', 5),
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
}
