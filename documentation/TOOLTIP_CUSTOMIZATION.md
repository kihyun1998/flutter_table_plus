# Tooltip Customization

Flutter Table Plus provides comprehensive tooltip customization options, allowing you to display rich, contextual information when users hover over table cells.

## Overview

The package offers two main ways to customize tooltips:

1. **Styling**: Control appearance using `TablePlusTooltipTheme`
2. **Content**: Generate custom content using `tooltipFormatter`

## Basic Tooltip Configuration

### Enabling/Disabling Tooltips

Control when tooltips are displayed using the `tooltipBehavior` property:

```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  tooltipBehavior: TooltipBehavior.always,        // Always show (default)
  // tooltipBehavior: TooltipBehavior.onOverflowOnly, // Only when text overflows  
  // tooltipBehavior: TooltipBehavior.never,          // Never show
)
```

### Default Tooltip Behavior

By default, tooltips display the cell's text content when `textOverflow` is set to `TextOverflow.ellipsis`:

```dart
TablePlusColumn(
  key: 'description',
  label: 'Description',
  textOverflow: TextOverflow.ellipsis,
  tooltipBehavior: TooltipBehavior.always,
  // Tooltip will show the full description text
)
```

## Styling Tooltips

### Global Tooltip Styling

Configure tooltip appearance using `TablePlusTooltipTheme`:

```dart
FlutterTablePlus(
  // ... other properties
  theme: TablePlusTheme(
    tooltipTheme: TablePlusTooltipTheme(
      enabled: true,
      textStyle: TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.all(8),
      waitDuration: Duration(milliseconds: 800),
      showDuration: Duration(seconds: 3),
      preferBelow: false,
    ),
  ),
)
```

### Advanced Styling Examples

#### Material Design Style
```dart
TablePlusTooltipTheme(
  decoration: BoxDecoration(
    color: Color(0xFF424242),
    borderRadius: BorderRadius.circular(4),
  ),
  textStyle: TextStyle(fontSize: 12, color: Colors.white),
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
)
```

#### Custom Branded Style
```dart
TablePlusTooltipTheme(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
  ),
  textStyle: TextStyle(
    fontSize: 13,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  ),
  padding: EdgeInsets.all(12),
)
```

## Custom Tooltip Content

### Using tooltipFormatter

The `tooltipFormatter` function allows you to generate completely custom tooltip content based on the entire row data:

```dart
TablePlusColumn(
  key: 'employee_name',
  label: 'Employee',
  tooltipFormatter: (rowData) {
    return '''Employee Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Name: ${rowData['name']}
🏢 Department: ${rowData['department']}
💼 Position: ${rowData['position']}
📧 Email: ${rowData['email']}
📞 Phone: ${rowData['phone']}''';
  },
)
```

### Practical Examples

#### Financial Data
```dart
TablePlusColumn(
  key: 'salary',
  label: 'Compensation',
  tooltipFormatter: (rowData) {
    final salary = rowData['salary'] as int? ?? 0;
    final bonus = rowData['bonus'] as int? ?? 0;
    final benefits = salary * 0.3; // Estimated benefits value
    final total = salary + bonus + benefits;
    
    return '''💰 Compensation Breakdown:
Base Salary: \$${_formatCurrency(salary)}
Annual Bonus: \$${_formatCurrency(bonus)}
Est. Benefits: \$${_formatCurrency(benefits.round())}
Total Package: \$${_formatCurrency(total.round())}''';
  },
)
```

#### Performance Metrics
```dart
TablePlusColumn(
  key: 'performance',
  label: 'Performance',
  tooltipFormatter: (rowData) {
    final score = rowData['performance_score'] as double? ?? 0.0;
    final projects = rowData['completed_projects'] as int? ?? 0;
    final reviews = rowData['peer_reviews'] as double? ?? 0.0;
    
    String rating = _getPerformanceRating(score);
    String trend = _getPerformanceTrend(rowData);
    
    return '''📊 Performance Overview:
$rating (${(score * 100).toStringAsFixed(1)}%)
Projects Completed: $projects
Peer Review Score: ${reviews.toStringAsFixed(1)}/5.0
Trend: $trend''';
  },
)
```

#### Status Information
```dart
TablePlusColumn(
  key: 'status',
  label: 'Status',
  tooltipFormatter: (rowData) {
    final isActive = rowData['active'] as bool? ?? false;
    final lastLogin = rowData['last_login'] as DateTime?;
    final role = rowData['role'] as String? ?? 'User';
    
    return '''Account Status:
${isActive ? '✅ Active' : '❌ Inactive'}
Role: $role
Last Login: ${lastLogin != null ? _formatDate(lastLogin) : 'Never'}
Access Level: ${_getAccessLevel(role)}''';
  },
)
```

#### Multi-field Summary
```dart
TablePlusColumn(
  key: 'summary',
  label: 'Summary',
  tooltipFormatter: (rowData) {
    final skills = rowData['skills'] as List<String>? ?? [];
    final experience = rowData['years_experience'] as int? ?? 0;
    final location = rowData['location'] as String? ?? 'Unknown';
    
    return '''Professional Summary:
🛠️ Skills: ${skills.take(3).join(', ')}${skills.length > 3 ? ' (+${skills.length - 3} more)' : ''}
📅 Experience: $experience years
📍 Location: $location
🎯 Expertise: ${_getExpertiseLevel(experience)}''';
  },
)
```

### Conditional Content

You can create conditional tooltip content based on data values:

```dart
TablePlusColumn(
  key: 'priority',
  label: 'Priority',
  tooltipFormatter: (rowData) {
    final priority = rowData['priority'] as String? ?? 'Normal';
    final dueDate = rowData['due_date'] as DateTime?;
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    
    if (isOverdue) {
      return '''🚨 OVERDUE TASK
Priority: $priority
Due Date: ${_formatDate(dueDate!)}
Days Overdue: ${DateTime.now().difference(dueDate).inDays}''';
    }
    
    return '''Task Information:
Priority: ${_getPriorityIcon(priority)} $priority
Due Date: ${dueDate != null ? _formatDate(dueDate) : 'Not set'}
Status: ${isOverdue ? 'Overdue' : 'On Track'}''';
  },
)
```

## Best Practices

### Content Guidelines

1. **Keep it Relevant**: Only include information that adds value
2. **Use Visual Hierarchy**: Employ emojis, separators, and formatting
3. **Be Concise**: Avoid overwhelming users with too much information
4. **Handle Edge Cases**: Always provide fallbacks for null/missing data

### Performance Considerations

1. **Avoid Heavy Computations**: Keep formatter functions lightweight
2. **Cache Calculated Values**: If possible, pre-calculate complex values
3. **Limit Text Length**: Very long tooltips can impact user experience

### Accessibility

1. **Meaningful Content**: Ensure tooltip content is descriptive and helpful
2. **Contrast**: Use appropriate color contrast in styling
3. **Fallback Behavior**: Ensure critical information is available without tooltips

## Integration Examples

### With State Management

```dart
TablePlusColumn(
  key: 'user_status',
  label: 'Status',
  tooltipFormatter: (rowData) {
    final userId = rowData['id'] as String;
    final userStatus = context.read<UserStatusProvider>().getStatus(userId);
    
    return '''Live Status Information:
Current Status: ${userStatus.displayName}
Last Updated: ${_formatTimestamp(userStatus.lastUpdated)}
Online Duration: ${_formatDuration(userStatus.onlineDuration)}''';
  },
)
```

### With Localization

```dart
TablePlusColumn(
  key: 'localized_content',
  label: 'Content',
  tooltipFormatter: (rowData) {
    final l10n = AppLocalizations.of(context)!;
    final status = rowData['status'] as String;
    
    return '''${l10n.tooltipTitle}:
${l10n.status}: ${l10n.getLocalizedStatus(status)}
${l10n.lastModified}: ${_formatDate(rowData['modified_at'])}''';
  },
)
```

## Troubleshooting

### Common Issues

#### Tooltip Not Showing
- Check `tooltipBehavior` is not set to `TooltipBehavior.never`
- Verify `TablePlusTooltipTheme.enabled` is `true`
- Ensure `textOverflow` is `TextOverflow.ellipsis` for default behavior

#### Performance Issues
- Avoid complex calculations in `tooltipFormatter`
- Consider pre-computing values during data preparation
- Limit tooltip content length

#### Styling Not Applied
- Verify theme is properly configured in `FlutterTablePlus`
- Check that custom `decoration` properties are valid
- Ensure proper color contrast for visibility

### Debug Tips

```dart
TablePlusColumn(
  tooltipFormatter: (rowData) {
    // Add debug output during development
    print('Tooltip data: $rowData');
    
    return '''Debug Info:
Row Data Keys: ${rowData.keys.join(', ')}
Sample Value: ${rowData.values.first}''';
  },
)
```

## Migration Guide

### From Basic Tooltips

**Before (basic tooltip):**
```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  // Default tooltip shows cell content
)
```

**After (custom tooltip):**
```dart
TablePlusColumn(
  key: 'name',
  label: 'Name',
  tooltipFormatter: (rowData) => 'Custom: ${rowData['name']}',
)
```

This guide covers all aspects of tooltip customization in Flutter Table Plus. The combination of flexible styling and powerful content generation makes it possible to create rich, informative tooltips that enhance the user experience significantly.