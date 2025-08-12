class Employee {
  final int id;
  final String name;
  final String email;
  final int age;
  final String department;
  final int salary;
  final bool active;
  final String description;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.department,
    required this.salary,
    required this.active,
    required this.description,
  });

  /// Convert Employee to Map for table usage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'department': department,
      'salary': salary,
      'active': active,
      'description': description,
    };
  }

  /// Create Employee from Map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      department: map['department'] as String,
      salary: map['salary'] as int,
      active: map['active'] as bool,
      description: map['description'] as String,
    );
  }
}
