# Expandable Summary Rows

Flutter Table Plus supports expandable summary functionality within merged row groups, allowing you to show/hide detailed rows while maintaining calculated totals and summary information.

## Overview

Expandable summary rows work in conjunction with the merged rows feature to provide collapsible groups with summary calculations. This is particularly useful for scenarios like:

- Product packages with individual items
- Department employees with team totals  
- Project tasks with milestone summaries
- Financial reports with category breakdowns

## Key Features

- **Expand/Collapse Control**: Toggle visibility of detailed rows within groups
- **Summary Calculations**: Automatic total calculations for numeric fields
- **Persistent State**: Maintain expanded/collapsed state across operations
- **Integration with Merged Rows**: Works seamlessly with the existing merged row system
- **Custom Summary Content**: Full control over summary row appearance

## Basic Implementation

### Setting Up Expandable Groups

```dart
class _ExpandableExampleState extends State<ExpandableExamplePage> {
  // Track expand/collapse state for each group
  Map<String, bool> expandedStates = {
    'package-1': false,
    'package-2': true,  // Start expanded
    'package-3': false,
  };

  List<MergedRowGroup> _createExpandableGroups() {
    return [
      MergedRowGroup(
        groupId: 'package-1',
        rowKeys: ['item-1', 'item-2', 'item-3'],
        isExpanded: expandedStates['package-1'] ?? false,
        summaryContent: _buildSummaryContent('package-1'),
        mergeConfig: {
          'package': MergeCellConfig.custom(
            content: _buildExpandablePackageCell('package-1'),
          ),
          'total': MergeCellConfig.sum(), // Auto-calculate totals
        },
      ),
      // More groups...
    ];
  }
}
```

### Expandable Cell Builder

```dart
Widget _buildExpandablePackageCell(String packageId) {
  final isExpanded = expandedStates[packageId] ?? false;
  final packageData = _getPackageData(packageId);
  
  return InkWell(
    onTap: () {
      setState(() {
        expandedStates[packageId] = !isExpanded;
        _updateMergedGroups(); // Refresh the groups
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageData['packageName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_getItemCount(packageId)} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Summary Content Builder

```dart
Widget _buildSummaryContent(String packageId) {
  final packageData = _getPackageData(packageId);
  final totalValue = _calculatePackageTotal(packageId);
  final itemCount = _getItemCount(packageId);
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.shade200),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Package Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Items: $itemCount',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                'Package Value: ¥${_formatCurrency(totalValue)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.inventory_2,
          color: Colors.blue.shade600,
          size: 24,
        ),
      ],
    ),
  );
}
```

## Advanced Configuration

### MergedRowGroup with Expansion

```dart
MergedRowGroup(
  groupId: 'department-engineering',
  rowKeys: ['emp-001', 'emp-002', 'emp-003', 'emp-004'],
  isExpanded: expandedStates['department-engineering'] ?? true,
  
  // Summary content shown when collapsed
  summaryContent: Container(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        const Icon(Icons.group, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          'Engineering Department (4 employees)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade700,
          ),
        ),
      ],
    ),
  ),
  
  // Column merge configurations
  mergeConfig: {
    'department': MergeCellConfig.custom(
      content: _buildDepartmentExpandCell('department-engineering'),
    ),
    'salary': MergeCellConfig.sum(), // Auto-sum salaries
    'experience': MergeCellConfig.average(), // Average experience
    'status': MergeCellConfig.constant('Active'), // Same for all
  },
)
```

### Conditional Expansion

```dart
Widget _buildConditionalExpandCell(String groupId) {
  final isExpanded = expandedStates[groupId] ?? false;
  final canExpand = _canExpandGroup(groupId); // Custom logic
  
  return InkWell(
    onTap: canExpand ? () => _toggleExpansion(groupId) : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: canExpand 
            ? (isExpanded ? Colors.blue.shade100 : Colors.grey.shade100)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (canExpand)
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 16,
              color: isExpanded ? Colors.blue.shade700 : Colors.grey.shade600,
            )
          else
            Icon(Icons.lock, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getGroupDisplayName(groupId),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: canExpand ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ),
          if (canExpand)
            Text(
              '${_getGroupItemCount(groupId)} items',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    ),
  );
}
```

## State Management

### Tracking Expansion State

```dart
class _ExpandableTableState extends State<ExpandableTablePage> {
  // Method 1: Simple Map for basic use cases
  Map<String, bool> expandedStates = {};
  
  // Method 2: Custom class for complex scenarios
  final ExpandableTableController _controller = ExpandableTableController();
  
  void _toggleExpansion(String groupId) {
    setState(() {
      expandedStates[groupId] = !(expandedStates[groupId] ?? false);
      _updateMergedGroups();
    });
  }
  
  void _expandAll() {
    setState(() {
      for (final groupId in _getAllGroupIds()) {
        expandedStates[groupId] = true;
      }
      _updateMergedGroups();
    });
  }
  
  void _collapseAll() {
    setState(() {
      for (final groupId in _getAllGroupIds()) {
        expandedStates[groupId] = false;
      }
      _updateMergedGroups();
    });
  }
}
```

### Custom Controller Pattern

```dart
class ExpandableTableController extends ChangeNotifier {
  final Map<String, bool> _expandedStates = {};
  final Map<String, List<String>> _groupItems = {};
  
  bool isExpanded(String groupId) => _expandedStates[groupId] ?? false;
  
  void toggle(String groupId) {
    _expandedStates[groupId] = !isExpanded(groupId);
    notifyListeners();
  }
  
  void expandGroup(String groupId) {
    _expandedStates[groupId] = true;
    notifyListeners();
  }
  
  void collapseGroup(String groupId) {
    _expandedStates[groupId] = false;
    notifyListeners();
  }
  
  void expandAll() {
    for (final groupId in _groupItems.keys) {
      _expandedStates[groupId] = true;
    }
    notifyListeners();
  }
  
  void collapseAll() {
    _expandedStates.clear();
    notifyListeners();
  }
  
  int getExpandedCount() => _expandedStates.values.where((e) => e).length;
  int getTotalGroups() => _groupItems.length;
}
```

## Integration Examples

### With Sorting

```dart
void _handleSort(String columnKey, SortDirection direction) {
  setState(() {
    _currentSortColumn = columnKey;
    _currentSortDirection = direction;
    
    // Sort the underlying data
    _sortData(columnKey, direction);
    
    // Rebuild merged groups with current expansion states
    _updateMergedGroupsWithSort();
  });
}

void _updateMergedGroupsWithSort() {
  // Maintain expansion states across sorts
  final currentStates = Map<String, bool>.from(expandedStates);
  
  _mergedGroups = _createMergedGroupsFromSortedData();
  
  // Restore expansion states
  for (final group in _mergedGroups) {
    group.isExpanded = currentStates[group.groupId] ?? false;
  }
}
```

### With Selection

```dart
void _handleGroupSelection(String groupId, bool isSelected) {
  setState(() {
    final group = _mergedGroups.firstWhere((g) => g.groupId == groupId);
    
    if (isSelected) {
      // Select all items in the group
      selectedRows.addAll(group.rowKeys);
    } else {
      // Deselect all items in the group
      selectedRows.removeWhere((rowId) => group.rowKeys.contains(rowId));
    }
  });
}

Widget _buildGroupSelectionCell(String groupId) {
  final group = _mergedGroups.firstWhere((g) => g.groupId == groupId);
  final selectedInGroup = group.rowKeys.where((id) => selectedRows.contains(id)).length;
  final totalInGroup = group.rowKeys.length;
  
  final isPartiallySelected = selectedInGroup > 0 && selectedInGroup < totalInGroup;
  final isFullySelected = selectedInGroup == totalInGroup;
  
  return Checkbox(
    value: isFullySelected,
    tristate: true,
    onChanged: (value) => _handleGroupSelection(groupId, value ?? false),
    // Custom styling for partial selection
    fillColor: isPartiallySelected 
        ? MaterialStateProperty.all(Colors.orange.shade300)
        : null,
  );
}
```

### With Editing

```dart
void _handleGroupEdit(String groupId) {
  final group = _mergedGroups.firstWhere((g) => g.groupId == groupId);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit ${_getGroupDisplayName(groupId)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Group Name'),
            controller: TextEditingController(text: _getGroupDisplayName(groupId)),
            onChanged: (value) => _updateGroupName(groupId, value),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-expand on load'),
            value: _getGroupAutoExpand(groupId),
            onChanged: (value) => _setGroupAutoExpand(groupId, value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _saveGroupChanges(groupId);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
```

## Performance Optimization

### Lazy Loading

```dart
class LazyExpandableTable extends StatefulWidget {
  @override
  State<LazyExpandableTable> createState() => _LazyExpandableTableState();
}

class _LazyExpandableTableState extends State<LazyExpandableTable> {
  final Map<String, List<Map<String, dynamic>>> _loadedGroupData = {};
  final Set<String> _loadingGroups = {};
  
  Future<void> _loadGroupData(String groupId) async {
    if (_loadedGroupData.containsKey(groupId) || _loadingGroups.contains(groupId)) {
      return;
    }
    
    setState(() {
      _loadingGroups.add(groupId);
    });
    
    try {
      final data = await _fetchGroupDataFromAPI(groupId);
      setState(() {
        _loadedGroupData[groupId] = data;
        _loadingGroups.remove(groupId);
      });
    } catch (e) {
      setState(() {
        _loadingGroups.remove(groupId);
      });
      // Handle error
    }
  }
  
  void _toggleExpansion(String groupId) {
    final wasExpanded = expandedStates[groupId] ?? false;
    
    setState(() {
      expandedStates[groupId] = !wasExpanded;
    });
    
    // Load data when expanding for the first time
    if (!wasExpanded && !_loadedGroupData.containsKey(groupId)) {
      _loadGroupData(groupId);
    }
  }
}
```

### Virtualized Expansion

```dart
Widget _buildVirtualizedExpandCell(String groupId) {
  final isExpanded = expandedStates[groupId] ?? false;
  final isLoading = _loadingGroups.contains(groupId);
  
  return InkWell(
    onTap: isLoading ? null : () => _toggleExpansion(groupId),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_getGroupDisplayName(groupId)),
          ),
          if (!isLoading)
            Text(
              '${_getGroupItemCount(groupId)}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    ),
  );
}
```

## Styling and Theming

### Custom Expansion Icons

```dart
Widget _buildStyledExpandIcon(String groupId, bool isExpanded) {
  return AnimatedRotation(
    turns: isExpanded ? 0.25 : 0,
    duration: const Duration(milliseconds: 200),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.blue.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isExpanded ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: isExpanded ? Colors.blue.shade700 : Colors.grey.shade600,
      ),
    ),
  );
}
```

### Summary Row Styling

```dart
Widget _buildStyledSummaryContent(String groupId) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.blue.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: _buildSummaryContentBody(groupId),
  );
}
```

## Best Practices

### Performance

1. **Lazy Loading**: Load group details only when expanded
2. **Efficient State**: Use appropriate data structures for expansion state
3. **Minimize Rebuilds**: Scope setState to affected groups only

### UX Guidelines

1. **Clear Indicators**: Use consistent expand/collapse icons
2. **Smooth Animations**: Add subtle transitions for better feel
3. **Loading States**: Show progress for async operations
4. **Keyboard Support**: Ensure keyboard navigation works

### Data Management

1. **State Persistence**: Maintain expansion state across operations
2. **Consistent Grouping**: Ensure group IDs remain stable
3. **Summary Accuracy**: Keep calculated totals in sync with detail changes

## Common Patterns

### Master-Detail View

```dart
// Show summary in collapsed state, details when expanded
MergedRowGroup(
  groupId: 'project-alpha',
  rowKeys: projectTasks,
  isExpanded: expandedStates['project-alpha'] ?? false,
  summaryContent: ProjectSummaryCard(projectId: 'project-alpha'),
  mergeConfig: {
    'project': MergeCellConfig.custom(
      content: ProjectExpandButton('project-alpha'),
    ),
    'hours': MergeCellConfig.sum(),
    'budget': MergeCellConfig.sum(),
    'completion': MergeCellConfig.average(),
  },
)
```

### Hierarchical Data

```dart
// Multi-level expansion (departments > teams > employees)
void _buildHierarchicalGroups() {
  final departments = _getDepartments();
  
  for (final dept in departments) {
    final teams = _getTeamsInDepartment(dept.id);
    
    if (teams.length > 1) {
      // Department level group
      _mergedGroups.add(MergedRowGroup(
        groupId: 'dept-${dept.id}',
        rowKeys: teams.expand((team) => _getTeamMembers(team.id)).toList(),
        isExpanded: expandedStates['dept-${dept.id}'] ?? false,
        // ... configuration
      ));
      
      for (final team in teams) {
        // Team level groups (nested)
        _mergedGroups.add(MergedRowGroup(
          groupId: 'team-${team.id}',
          rowKeys: _getTeamMembers(team.id),
          isExpanded: expandedStates['team-${team.id}'] ?? false,
          // ... configuration
        ));
      }
    }
  }
}
```

## Migration and Compatibility

### Upgrading Existing Merged Rows

```dart
// Before: Static merged rows
MergedRowGroup(
  groupId: 'group-1',
  rowKeys: ['row-1', 'row-2'],
  mergeConfig: { /* ... */ },
)

// After: Expandable merged rows
MergedRowGroup(
  groupId: 'group-1',
  rowKeys: ['row-1', 'row-2'],
  isExpanded: expandedStates['group-1'] ?? true, // Default expanded
  summaryContent: _buildSummary('group-1'),      // Add summary
  mergeConfig: {
    'column1': MergeCellConfig.custom(
      content: _buildExpandButton('group-1'),     // Add expand button
    ),
    // ... other configs remain the same
  },
)
```

The expandable summary feature is fully backward compatible and can be gradually adopted in existing applications.