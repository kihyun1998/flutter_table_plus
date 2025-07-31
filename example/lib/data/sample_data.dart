import '../models/employee.dart';

class SampleData {
  static final List<Employee> employees = [
    const Employee(
      id: 1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      age: 28,
      department: 'Engineering',
      salary: 75000,
      active: true,
    ),
    const Employee(
      id: 2,
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      age: 32,
      department: 'Marketing',
      salary: 68000,
      active: true,
    ),
    const Employee(
      id: 3,
      name: 'Vert Stlong',
      email: 'veryveryveryveryveryveryveryveryveryveryveryverylong@example.com',
      age: 45,
      department: 'Sales',
      salary: 82000,
      active: false,
    ),
    const Employee(
      id: 4,
      name: 'Alice Brown',
      email: 'alice.brown@example.com',
      age: 29,
      department: 'Engineering',
      salary: 79000,
      active: true,
    ),
    const Employee(
      id: 5,
      name: 'Charlie Wilson',
      email: 'charlie.wilson@example.com',
      age: 38,
      department: 'HR',
      salary: 65000,
      active: true,
    ),
    const Employee(
      id: 6,
      name: 'Diana Davis',
      email: 'diana.davis@example.com',
      age: 31,
      department: 'Finance',
      salary: 72000,
      active: true,
    ),
    const Employee(
      id: 7,
      name: 'Eva Garcia',
      email: 'eva.garcia@example.com',
      age: 26,
      department: 'Design',
      salary: 63000,
      active: false,
    ),
    const Employee(
      id: 8,
      name: 'Frank Miller',
      email: 'frank.miller@example.com',
      age: 42,
      department: 'Operations',
      salary: 71000,
      active: true,
    ),
  ];

  /// Get employees as List<Map<String, dynamic>> for table
  static List<Map<String, dynamic>> get employeeData =>
      employees.map((e) => e.toMap()).toList();

  /// Get active employees only
  static List<Employee> get activeEmployees =>
      employees.where((e) => e.active).toList();
}
