import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

/// AppBar actions for the table example
class TableAppBarActions extends StatelessWidget {
  const TableAppBarActions({
    super.key,
    required this.sortColumnKey,
    required this.isSelectable,
    required this.selectionMode,
    required this.isEditable,
    required this.isReorderable,
    required this.isSortable,
    required this.showVerticalDividers,
    required this.onResetSort,
    required this.onResetColumnOrder,
    required this.onToggleVerticalDividers,
    required this.onToggleEditingMode,
    required this.onToggleSelectionMode,
    required this.onToggleSelectionModeType,
    required this.onToggleColumnReordering,
    required this.onToggleSorting,
  });

  final String? sortColumnKey;
  final bool isSelectable;
  final SelectionMode selectionMode;
  final bool isEditable;
  final bool isReorderable;
  final bool isSortable;
  final bool showVerticalDividers;
  
  final VoidCallback onResetSort;
  final VoidCallback onResetColumnOrder;
  final VoidCallback onToggleVerticalDividers;
  final VoidCallback onToggleEditingMode;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onToggleSelectionModeType;
  final VoidCallback onToggleColumnReordering;
  final VoidCallback onToggleSorting;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reset sort button
        if (sortColumnKey != null)
          IconButton(
            onPressed: onResetSort,
            icon: const Icon(Icons.sort_outlined),
            tooltip: 'Clear Sort',
          ),
        
        // Reset column order button
        IconButton(
          onPressed: onResetColumnOrder,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset Column Order',
        ),
        
        // Toggle vertical dividers button
        IconButton(
          onPressed: onToggleVerticalDividers,
          icon: Icon(
            showVerticalDividers
                ? Icons.grid_on
                : Icons.format_list_bulleted,
          ),
          tooltip: showVerticalDividers
              ? 'Hide Vertical Lines'
              : 'Show Vertical Lines',
        ),
        
        // Toggle editing mode button
        IconButton(
          onPressed: onToggleEditingMode,
          icon: Icon(
            isEditable ? Icons.edit : Icons.edit_outlined,
            color: isEditable ? Colors.orange : null,
          ),
          tooltip: isEditable ? 'Disable Editing' : 'Enable Editing',
        ),
        
        // Toggle selection mode button
        IconButton(
          onPressed: onToggleSelectionMode,
          icon: Icon(
            isSelectable ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          tooltip: isSelectable ? 'Disable Selection' : 'Enable Selection',
        ),
        
        // Toggle selection mode type button (single/multiple)
        if (isSelectable)
          IconButton(
            onPressed: onToggleSelectionModeType,
            icon: Icon(
              selectionMode == SelectionMode.single 
                  ? Icons.radio_button_checked 
                  : Icons.check_box_outlined,
              color: selectionMode == SelectionMode.single 
                  ? Colors.orange 
                  : Colors.blue,
            ),
            tooltip: selectionMode == SelectionMode.single 
                ? 'Switch to Multiple Selection' 
                : 'Switch to Single Selection',
          ),
        
        // Toggle column reordering button
        IconButton(
          onPressed: onToggleColumnReordering,
          icon: Icon(
            isReorderable ? Icons.swap_horiz : Icons.swap_horiz_outlined,
            color: isReorderable ? Colors.green : null,
          ),
          tooltip: isReorderable ? 'Disable Reordering' : 'Enable Reordering',
        ),
        
        // Toggle sorting button
        IconButton(
          onPressed: onToggleSorting,
          icon: Icon(
            isSortable ? Icons.sort : Icons.sort_outlined,
            color: isSortable ? Colors.purple : null,
          ),
          tooltip: isSortable ? 'Disable Sorting' : 'Enable Sorting',
        ),
      ],
    );
  }
}