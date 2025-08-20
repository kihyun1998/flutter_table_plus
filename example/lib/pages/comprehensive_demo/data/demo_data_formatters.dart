/// Data formatting utilities for comprehensive table demo
class DemoDataFormatters {
  /// Format currency (salary)
  static String formatCurrency(double value) {
    // Simple currency formatting without intl
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$${formatted}';
  }

  /// Format percentage (performance)
  static String formatPercentage(double value) {
    final percentage = (value * 100).toInt();
    return '$percentage%';
  }

  /// Format date (joinDate)
  static String formatDate(DateTime date) {
    // Simple date formatting without intl
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, ${date.year}';
  }

  /// Format skills list
  static String formatSkills(List<String> skills) {
    if (skills.isEmpty) return '';
    if (skills.length <= 2) {
      return skills.join(', ');
    }
    return '${skills.take(2).join(', ')} +${skills.length - 2}';
  }

  /// Format phone number
  static String formatPhone(String phone) {
    if (phone.isEmpty) return '';
    // Simple formatting for demo
    return phone;
  }

  /// Get performance color
  static String getPerformanceColor(double performance) {
    if (performance >= 0.9) return 'excellent';
    if (performance >= 0.8) return 'good';
    if (performance >= 0.7) return 'average';
    return 'below_average';
  }

  /// Get salary range
  static String getSalaryRange(double salary) {
    if (salary >= 100000) return 'high';
    if (salary >= 70000) return 'medium';
    return 'entry';
  }

  /// Format department badge color
  static String getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'engineering':
        return 'blue';
      case 'design':
        return 'purple';
      case 'marketing':
        return 'orange';
      case 'sales':
        return 'green';
      case 'hr':
        return 'teal';
      default:
        return 'grey';
    }
  }
}