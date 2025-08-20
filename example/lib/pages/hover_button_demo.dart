import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class HoverButtonDemo extends StatefulWidget {
  const HoverButtonDemo({super.key});

  @override
  State<HoverButtonDemo> createState() => _HoverButtonDemoState();
}

class _HoverButtonDemoState extends State<HoverButtonDemo> {
  HoverButtonPosition _currentPosition = HoverButtonPosition.right;
  bool _useThemeButtons = true;
  bool _showEditButton = true;
  bool _showDeleteButton = true;
  final Color _buttonBackgroundColor = Colors.white;
  double _buttonOpacity = 0.9;
  double _iconSize = 16.0;
  double _horizontalOffset = 8.0;
  Color _editIconColor = Colors.blue;
  Color _deleteIconColor = Colors.red;

  final List<Map<String, dynamic>> _data = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Developer',
      'salary': 75000,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'Designer',
      'salary': 65000,
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'email': 'bob@example.com',
      'role': 'Manager',
      'salary': 85000,
    },
    {
      'id': '4',
      'name': 'Alice Brown',
      'email': 'alice@example.com',
      'role': 'Developer',
      'salary': 72000,
    },
    {
      'id': '5',
      'name': 'Charlie Wilson',
      'email': 'charlie@example.com',
      'role': 'QA Tester',
      'salary': 55000,
    },
  ];

  final Map<String, TablePlusColumn> _columns = {
    'name': TablePlusColumn(key: 'name', label: 'Name', width: 150, order: 0),
    'email':
        TablePlusColumn(key: 'email', label: 'Email', width: 200, order: 1),
    'role': TablePlusColumn(key: 'role', label: 'Role', width: 120, order: 2),
    'salary': TablePlusColumn(
      key: 'salary',
      label: 'Salary',
      width: 100,
      order: 3,
      cellBuilder: (context, data) {
        return Text(
          '\$${data['salary'].toString()}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        );
      },
    ),
  };

  void _handleEdit(String rowId, Map<String, dynamic> rowData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit clicked for: ${rowData['name']}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDelete(String rowId, Map<String, dynamic> rowData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${rowData['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _data.removeWhere((item) => item['id'] == rowId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${rowData['name']} has been deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getPositionDescription(HoverButtonPosition position) {
    switch (position) {
      case HoverButtonPosition.left:
        return 'Left side of the row';
      case HoverButtonPosition.center:
        return 'Center of the row';
      case HoverButtonPosition.right:
        return 'Right side of the row (default)';
    }
  }

  TablePlusHoverButtonTheme get _currentHoverButtonTheme {
    return TablePlusHoverButtonTheme(
      backgroundColor: _buttonBackgroundColor,
      opacity: _buttonOpacity,
      iconSize: _iconSize,
      horizontalOffset: _horizontalOffset,
      editIconColor: _editIconColor,
      deleteIconColor: _deleteIconColor,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hover Button Demo - NEW Theme System!'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Row(
        children: [
          // Settings Panel
          Container(
            width: 320,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hover Button Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                ),
                const SizedBox(height: 16),

                // Button Type Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Button Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Use Theme Buttons'),
                          subtitle: Text(_useThemeButtons
                              ? 'Using built-in theme system'
                              : 'Using custom builder'),
                          value: _useThemeButtons,
                          onChanged: (value) {
                            setState(() {
                              _useThemeButtons = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (_useThemeButtons) ...[
                  // Button Visibility
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Button Visibility',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          CheckboxListTile(
                            title: const Text('Show Edit Button'),
                            value: _showEditButton,
                            onChanged: (value) {
                              setState(() {
                                _showEditButton = value ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Show Delete Button'),
                            value: _showDeleteButton,
                            onChanged: (value) {
                              setState(() {
                                _showDeleteButton = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Theme Customization
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Theme Customization',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          // Icon Size
                          Text('Icon Size: ${_iconSize.round()}px'),
                          Slider(
                            value: _iconSize,
                            min: 12,
                            max: 24,
                            divisions: 12,
                            onChanged: (value) {
                              setState(() {
                                _iconSize = value;
                              });
                            },
                          ),

                          // Opacity
                          Text(
                              'Background Opacity: ${(_buttonOpacity * 100).round()}%'),
                          Slider(
                            value: _buttonOpacity,
                            min: 0.5,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _buttonOpacity = value;
                              });
                            },
                          ),

                          // Button Distance
                          Text('Button Distance: ${_horizontalOffset.round()}px'),
                          Slider(
                            value: _horizontalOffset,
                            min: 0,
                            max: 32,
                            divisions: 32,
                            onChanged: (value) {
                              setState(() {
                                _horizontalOffset = value;
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          // Color Pickers
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Edit Color'),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _editIconColor,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: InkWell(
                                        onTap: () => _showColorPicker(
                                            _editIconColor, (color) {
                                          setState(() {
                                            _editIconColor = color;
                                          });
                                        }),
                                        child: const Center(
                                          child: Icon(Icons.edit,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Delete Color'),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _deleteIconColor,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: InkWell(
                                        onTap: () => _showColorPicker(
                                            _deleteIconColor, (color) {
                                          setState(() {
                                            _deleteIconColor = color;
                                          });
                                        }),
                                        child: const Center(
                                          child: Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Position Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Button Position',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<HoverButtonPosition>(
                          segments: const [
                            ButtonSegment(
                              value: HoverButtonPosition.left,
                              label: Text('Left'),
                              icon: Icon(Icons.align_horizontal_left),
                            ),
                            ButtonSegment(
                              value: HoverButtonPosition.center,
                              label: Text('Center'),
                              icon: Icon(Icons.align_horizontal_center),
                            ),
                            ButtonSegment(
                              value: HoverButtonPosition.right,
                              label: Text('Right'),
                              icon: Icon(Icons.align_horizontal_right),
                            ),
                          ],
                          selected: {_currentPosition},
                          onSelectionChanged:
                              (Set<HoverButtonPosition> selected) {
                            setState(() {
                              _currentPosition = selected.first;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPositionDescription(_currentPosition),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Theme System Demo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hover over any row to see the buttons appear. Use the settings panel to customize the appearance and behavior.',
                                  style: TextStyle(color: Colors.blue.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FlutterTablePlus(
                          columns: _columns,
                          data: _data,
                          theme: TablePlusTheme(
                            headerTheme: TablePlusHeaderTheme(
                              backgroundColor: Colors.orange.shade50,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            bodyTheme: TablePlusBodyTheme(
                              alternateRowColor: Colors.grey.shade50,
                            ),
                            hoverButtonTheme: _currentHoverButtonTheme,
                          ),
                          hoverButtonPosition: _currentPosition,
                          // Use either theme-based buttons or custom builder
                          hoverButtonBuilder: _useThemeButtons
                              ? null
                              : (rowId, rowData) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              size: 18, color: Colors.white),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              minWidth: 32, minHeight: 32),
                                          onPressed: () =>
                                              _handleEdit(rowId, rowData),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.white),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              minWidth: 32, minHeight: 32),
                                          onPressed: () =>
                                              _handleDelete(rowId, rowData),
                                        ),
                                      ],
                                    ),
                                  ),
                          onEdit: (_useThemeButtons && _showEditButton)
                              ? _handleEdit
                              : null,
                          onDelete: (_useThemeButtons && _showDeleteButton)
                              ? _handleDelete
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _colorOptions.length,
            itemBuilder: (context, index) {
              final color = _colorOptions[index];
              return InkWell(
                onTap: () {
                  onColorChanged(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color == currentColor ? Colors.black : Colors.grey,
                      width: color == currentColor ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static const List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
}
