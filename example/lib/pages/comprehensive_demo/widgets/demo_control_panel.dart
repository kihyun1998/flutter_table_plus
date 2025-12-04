import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Control panel widget for the comprehensive table demo
///
/// Handles selection mode controls, editing toggles, merged rows configuration,
/// and displays current phase status information.
class DemoControlPanel extends StatelessWidget {
  final SelectionMode selectionMode;
  final ValueChanged<SelectionMode> onSelectionModeChanged;
  final Set<String> selectedRows;
  final VoidCallback onClearSelections;
  final bool isEditable;
  final bool showMergedRows;
  final VoidCallback onToggleMergedRows;
  final bool expandedGroups;
  final VoidCallback onToggleGroupExpansion;
  final List<dynamic> mergedGroups;

  // Phase 6: Hover buttons and row expansion
  final bool showHoverButtons;
  final VoidCallback onToggleHoverButtons;

  const DemoControlPanel({
    super.key,
    required this.selectionMode,
    required this.onSelectionModeChanged,
    required this.selectedRows,
    required this.onClearSelections,
    required this.isEditable,
    required this.showMergedRows,
    required this.onToggleMergedRows,
    required this.expandedGroups,
    required this.onToggleGroupExpansion,
    required this.mergedGroups,
    required this.showHoverButtons,
    required this.onToggleHoverButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Status Row
          _buildStatusRow(),

          // Selection and editing controls
          const SizedBox(height: 12),
          _buildSelectionControls(),

          // Merged rows controls
          const SizedBox(height: 12),
          _buildMergedRowsControls(),

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.handshake, color: Colors.amber.shade600),
              SizedBox(width: 8),
              Text(
                'Hovered Button: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: showHoverButtons,
                onChanged: (value) => onToggleHoverButtons(),
                activeThumbColor: Colors.amber.shade600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Icon(Icons.settings, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          'Control Panel (Phase 9)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _buildPhaseChip('Phase 1 ✅', Colors.green),
        const SizedBox(width: 8),
        _buildPhaseChip('Phase 2 ✅', Colors.green),
        const SizedBox(width: 8),
        _buildPhaseChip('Phase 3 ✅', Colors.green),
        const SizedBox(width: 8),
        _buildPhaseChip('Phase 4 🔄', Colors.orange),
      ],
    );
  }

  Widget _buildPhaseChip(String label, MaterialColor color) {
    return Chip(
      label: Text(label),
      backgroundColor: color.shade100,
      labelStyle: TextStyle(color: color.shade800),
    );
  }

  Widget _buildSelectionControls() {
    return Row(
      children: [
        // Selection controls
        Icon(Icons.check_box, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Text(
          'Selection:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<SelectionMode>(
          value: selectionMode,
          onChanged: (SelectionMode? newValue) {
            if (newValue != null) {
              onSelectionModeChanged(newValue);
            }
          },
          items: SelectionMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Text(mode.name.toUpperCase()),
            );
          }).toList(),
        ),
        const SizedBox(width: 16),

        // Selected count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selectedRows.isNotEmpty
                ? Colors.blue.shade100
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Selected: ${selectedRows.length}',
            style: TextStyle(
              color: selectedRows.isNotEmpty
                  ? Colors.blue.shade700
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),

        // Clear selection button
        if (selectedRows.isNotEmpty) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onClearSelections,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade700,
              minimumSize: const Size(0, 32),
            ),
          ),
        ],

        const Spacer(),

        // Editing toggle
        Icon(Icons.edit, color: Colors.orange.shade600),
        const SizedBox(width: 8),
        Text(
          'Editing: ${isEditable ? "ON" : "OFF"} (Position, Dept, Salary, Performance)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isEditable ? Colors.orange.shade700 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMergedRowsControls() {
    return Row(
      children: [
        // Merged rows toggle
        Icon(Icons.merge_type, color: Colors.purple.shade600),
        const SizedBox(width: 8),
        Text(
          'Merged Rows:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: showMergedRows,
          onChanged: (value) => onToggleMergedRows(),
          activeThumbColor: Colors.purple.shade600,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 16),

        // Group expansion toggle (only show when merged rows are enabled)
        if (showMergedRows) ...[
          Icon(Icons.expand_more, color: Colors.indigo.shade600),
          const SizedBox(width: 8),
          Text(
            'Expand Groups:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: expandedGroups,
            onChanged: (value) => onToggleGroupExpansion(),
            activeThumbColor: Colors.indigo.shade600,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 16),
        ],

        // Merged groups count
        if (showMergedRows)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Groups: ${mergedGroups.length}',
              style: TextStyle(
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),

        const Spacer(),

        // Phase 4 status
        Text(
          'Phase 4: ${showMergedRows ? "Active" : "Disabled"}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                showMergedRows ? Colors.purple.shade700 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
