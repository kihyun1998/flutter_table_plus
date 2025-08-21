import 'package:flutter/material.dart';

/// Demo department model for comprehensive table demonstration
class DemoDepartment {
  const DemoDepartment({
    required this.id,
    required this.name,
    required this.manager,
    required this.memberCount,
    required this.budget,
    required this.projects,
    required this.color,
    this.description = '',
    this.location = '',
  });

  final String id;
  final String name;
  final String manager;
  final int memberCount;
  final double budget;
  final List<String> projects;
  final Color color;
  final String description;
  final String location;

  /// Convert to Map for table data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manager': manager,
      'memberCount': memberCount,
      'budget': budget,
      'projects': projects,
      'color': color,
      'description': description,
      'location': location,
    };
  }

  /// Create from Map
  factory DemoDepartment.fromMap(Map<String, dynamic> map) {
    return DemoDepartment(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      manager: map['manager'] ?? '',
      memberCount: map['memberCount'] ?? 0,
      budget: (map['budget'] ?? 0).toDouble(),
      projects: List<String>.from(map['projects'] ?? []),
      color: Color(map['color'] ?? Colors.blue),
      description: map['description'] ?? '',
      location: map['location'] ?? '',
    );
  }

  /// Copy with modifications
  DemoDepartment copyWith({
    String? id,
    String? name,
    String? manager,
    int? memberCount,
    double? budget,
    List<String>? projects,
    Color? color,
    String? description,
    String? location,
  }) {
    return DemoDepartment(
      id: id ?? this.id,
      name: name ?? this.name,
      manager: manager ?? this.manager,
      memberCount: memberCount ?? this.memberCount,
      budget: budget ?? this.budget,
      projects: projects ?? this.projects,
      color: color ?? this.color,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'DemoDepartment(id: $id, name: $name, manager: $manager, members: $memberCount)';
  }
}
