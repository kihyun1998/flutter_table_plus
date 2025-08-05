import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class ColumnVisibilityControls extends StatelessWidget {
  const ColumnVisibilityControls({
    super.key,
    required this.columns,
    required this.onColumnVisibilityChanged,
  });

  final Map<String, TablePlusColumn> columns;
  final void Function(String columnKey, bool visible) onColumnVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    // Get all columns sorted by order for consistent display
    final sortedColumns = columns.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Column Visibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Show/Hide All buttons
                TextButton.icon(
                  onPressed: () => _toggleAllColumns(true),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Show All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _toggleAllColumns(false),
                  icon: const Icon(Icons.visibility_off, size: 16),
                  label: const Text('Hide All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sortedColumns.map((column) {
                return _ColumnVisibilityItem(
                  column: column,
                  onChanged: (visible) =>
                      onColumnVisibilityChanged(column.key, visible),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAllColumns(bool visible) {
    for (final column in columns.values) {
      onColumnVisibilityChanged(column.key, visible);
    }
  }
}

class _ColumnVisibilityItem extends StatelessWidget {
  const _ColumnVisibilityItem({
    required this.column,
    required this.onChanged,
  });

  final TablePlusColumn column;
  final void Function(bool visible) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!column.visible),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: column.visible ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: column.visible ? Colors.blue.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              column.visible ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color:
                  column.visible ? Colors.blue.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              column.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: column.visible
                    ? Colors.blue.shade700
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColumnVisibilityDialog extends StatefulWidget {
  const ColumnVisibilityDialog({
    super.key,
    required this.columns,
    required this.onColumnVisibilityChanged,
  });

  final Map<String, TablePlusColumn> columns;
  final void Function(String columnKey, bool visible) onColumnVisibilityChanged;

  static Future<void> show(
    BuildContext context, {
    required Map<String, TablePlusColumn> columns,
    required void Function(String columnKey, bool visible)
        onColumnVisibilityChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ColumnVisibilityDialog(
        columns: columns,
        onColumnVisibilityChanged: onColumnVisibilityChanged,
      ),
    );
  }

  @override
  State<ColumnVisibilityDialog> createState() => _ColumnVisibilityDialogState();
}

class _ColumnVisibilityDialogState extends State<ColumnVisibilityDialog> {
  late Map<String, bool> _columnVisibility;

  @override
  void initState() {
    super.initState();
    _columnVisibility = {
      for (final entry in widget.columns.entries)
        entry.key: entry.value.visible,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sortedColumns = widget.columns.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.visibility),
          SizedBox(width: 8),
          Text('Column Visibility'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAllColumns,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Show All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hideAllColumns,
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: const Text('Hide All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Column list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedColumns.length,
                itemBuilder: (context, index) {
                  final column = sortedColumns[index];
                  final isVisible = _columnVisibility[column.key] ?? false;

                  return CheckboxListTile(
                    value: isVisible,
                    onChanged: (value) =>
                        _toggleColumn(column.key, value ?? false),
                    title: Text(column.label),
                    subtitle: Text('Key: ${column.key}'),
                    secondary: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: isVisible ? Colors.blue : Colors.grey,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyChanges,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _toggleColumn(String columnKey, bool visible) {
    setState(() {
      _columnVisibility[columnKey] = visible;
    });
  }

  void _showAllColumns() {
    setState(() {
      for (final key in _columnVisibility.keys) {
        _columnVisibility[key] = true;
      }
    });
  }

  void _hideAllColumns() {
    setState(() {
      for (final key in _columnVisibility.keys) {
        _columnVisibility[key] = false;
      }
    });
  }

  void _applyChanges() {
    for (final entry in _columnVisibility.entries) {
      widget.onColumnVisibilityChanged(entry.key, entry.value);
    }
    Navigator.pop(context);
  }
}
