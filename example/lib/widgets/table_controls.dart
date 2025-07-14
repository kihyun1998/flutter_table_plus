import 'package:flutter/material.dart';

class TableControls extends StatelessWidget {
  const TableControls({
    super.key,
    required this.isSelectable,
    required this.selectedCount,
    required this.selectedNames,
    required this.onClearSelections,
    required this.onSelectActive,
    required this.onShowSelected,
  });

  final bool isSelectable;
  final int selectedCount;
  final List<String> selectedNames;
  final VoidCallback onClearSelections;
  final VoidCallback onSelectActive;
  final VoidCallback onShowSelected;

  @override
  Widget build(BuildContext context) {
    if (!isSelectable) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Selection actions
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: onClearSelections,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onSelectActive,
              icon: const Icon(Icons.people, size: 16),
              label: const Text('Select Active'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade700,
              ),
            ),
            if (selectedCount > 0)
              ElevatedButton.icon(
                onPressed: onShowSelected,
                icon: const Icon(Icons.info, size: 16),
                label: const Text('Show Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class SelectionDialog extends StatelessWidget {
  const SelectionDialog({
    super.key,
    required this.selectedCount,
    required this.selectedNames,
  });

  final int selectedCount;
  final List<String> selectedNames;

  static void show(
    BuildContext context, {
    required int selectedCount,
    required List<String> selectedNames,
  }) {
    showDialog(
      context: context,
      builder: (context) => SelectionDialog(
        selectedCount: selectedCount,
        selectedNames: selectedNames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selected Employees'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected $selectedCount employees:'),
          const SizedBox(height: 8),
          ...selectedNames.map((name) => Text('• $name')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
