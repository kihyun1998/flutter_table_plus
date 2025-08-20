/// Demo employee model for comprehensive table demonstration
class DemoEmployee {
  const DemoEmployee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.salary,
    required this.avatar,
    required this.performance,
    required this.skills,
    required this.joinDate,
    this.isActive = true,
    this.email = '',
    this.phone = '',
  });

  final String id;
  final String name;
  final String position;
  final String department;
  final double salary;
  final String avatar;
  final double performance; // 0.0 to 1.0
  final List<String> skills;
  final DateTime joinDate;
  final bool isActive;
  final String email;
  final String phone;

  /// Convert to Map for table data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'salary': salary,
      'avatar': avatar,
      'performance': performance,
      'skills': skills,
      'joinDate': joinDate,
      'isActive': isActive,
      'email': email,
      'phone': phone,
    };
  }

  /// Create from Map
  factory DemoEmployee.fromMap(Map<String, dynamic> map) {
    return DemoEmployee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      position: map['position'] ?? '',
      department: map['department'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
      avatar: map['avatar'] ?? '',
      performance: (map['performance'] ?? 0).toDouble(),
      skills: List<String>.from(map['skills'] ?? []),
      joinDate: map['joinDate'] ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  /// Copy with modifications
  DemoEmployee copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    double? salary,
    String? avatar,
    double? performance,
    List<String>? skills,
    DateTime? joinDate,
    bool? isActive,
    String? email,
    String? phone,
  }) {
    return DemoEmployee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      avatar: avatar ?? this.avatar,
      performance: performance ?? this.performance,
      skills: skills ?? this.skills,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'DemoEmployee(id: $id, name: $name, position: $position, department: $department)';
  }
}