import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// Status indicators showing current table state
class TableStatusIndicators extends StatelessWidget {
  const TableStatusIndicators({
    super.key,
    required this.sortColumnKey,
    required this.sortDirection,
    required this.isSelectable,
    required this.selectionMode,
    required this.selectedCount,
    required this.isEditable,
    required this.isReorderable,
    required this.isSortable,
  });

  final String? sortColumnKey;
  final SortDirection sortDirection;
  final bool isSelectable;
  final SelectionMode selectionMode;
  final int selectedCount;
  final bool isEditable;
  final bool isReorderable;
  final bool isSortable;

  Widget _buildStatusChip({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        // Sort status
        if (sortColumnKey != null)
          _buildStatusChip(
            text: 'Sorted by $sortColumnKey (${sortDirection.name})',
            backgroundColor: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),

        // Selection status
        if (isSelectable)
          _buildStatusChip(
            text: selectedCount > 0
                ? '$selectedCount selected (${selectionMode == SelectionMode.single ? 'Single' : 'Multi'})'
                : '${selectionMode == SelectionMode.single ? 'Single' : 'Multi'} Selection',
            backgroundColor: selectionMode == SelectionMode.single
                ? Colors.orange.shade100
                : Colors.blue.shade100,
            textColor: selectionMode == SelectionMode.single
                ? Colors.orange.shade800
                : Colors.blue.shade800,
          ),

        // Editing mode status
        if (isEditable)
          _buildStatusChip(
            text: 'Editing Mode',
            backgroundColor: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),

        // Reordering disabled status
        if (!isReorderable)
          _buildStatusChip(
            text: 'Reordering Disabled',
            backgroundColor: Colors.grey.shade100,
            textColor: Colors.grey.shade700,
          ),

        // Sorting disabled status
        if (!isSortable)
          _buildStatusChip(
            text: 'Sorting Disabled',
            backgroundColor: Colors.grey.shade100,
            textColor: Colors.grey.shade700,
          ),
      ],
    );
  }
}
