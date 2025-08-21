/// Demo project model for expandable rows demonstration
class DemoProject {
  const DemoProject({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.startDate,
    this.endDate,
    required this.progress,
    this.budget = 0.0,
    this.priority = ProjectPriority.medium,
    this.status = ProjectStatus.active,
  });

  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final DateTime startDate;
  final DateTime? endDate;
  final double progress; // 0.0 to 1.0
  final double budget;
  final ProjectPriority priority;
  final ProjectStatus status;

  /// Get project duration in days
  int get durationDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  /// Check if project is overdue
  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && progress < 1.0;
  }

  /// Convert to Map for table data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'startDate': startDate,
      'endDate': endDate,
      'progress': progress,
      'budget': budget,
      'priority': priority.index,
      'status': status.index,
    };
  }

  /// Create from Map
  factory DemoProject.fromMap(Map<String, dynamic> map) {
    return DemoProject(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      startDate: map['startDate'] ?? DateTime.now(),
      endDate: map['endDate'],
      progress: (map['progress'] ?? 0).toDouble(),
      budget: (map['budget'] ?? 0).toDouble(),
      priority: ProjectPriority.values[map['priority'] ?? 1],
      status: ProjectStatus.values[map['status'] ?? 0],
    );
  }

  /// Copy with modifications
  DemoProject copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memberIds,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    double? budget,
    ProjectPriority? priority,
    ProjectStatus? status,
  }) {
    return DemoProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      budget: budget ?? this.budget,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'DemoProject(id: $id, name: $name, progress: ${(progress * 100).toInt()}%)';
  }
}

/// Project priority levels
enum ProjectPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.critical:
        return 'Critical';
    }
  }
}

/// Project status
enum ProjectStatus {
  active,
  completed,
  paused,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.paused:
        return 'Paused';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}
