/// Data model representing an employee in the playground table.
class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final int salary;
  final String avatar;
  final double performance;
  final DateTime joinDate;
  final String email;
  final String phone;
  final bool isActive;

  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.salary,
    required this.avatar,
    required this.performance,
    required this.joinDate,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  /// Creates a copy of this employee with the given fields replaced.
  Employee copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    int? salary,
    String? avatar,
    double? performance,
    DateTime? joinDate,
    String? email,
    String? phone,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      avatar: avatar ?? this.avatar,
      performance: performance ?? this.performance,
      joinDate: joinDate ?? this.joinDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
