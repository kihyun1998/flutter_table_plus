import 'package:flutter/material.dart';
import '../models/demo_employee.dart';
import '../models/demo_department.dart';
import '../models/demo_project.dart';

/// Demo data source for comprehensive table demonstration
class DemoDataSource {
  static List<DemoEmployee> _employees = [];
  static List<DemoDepartment> _departments = [];
  static List<DemoProject> _projects = [];

  /// Get all employees
  static List<DemoEmployee> get employees {
    if (_employees.isEmpty) {
      _generateEmployees();
    }
    return _employees;
  }

  /// Get all departments
  static List<DemoDepartment> get departments {
    if (_departments.isEmpty) {
      _generateDepartments();
    }
    return _departments;
  }

  /// Get all projects
  static List<DemoProject> get projects {
    if (_projects.isEmpty) {
      _generateProjects();
    }
    return _projects;
  }

  /// Convert employees to table data format
  static List<Map<String, dynamic>> get employeeTableData {
    return employees.map((e) => e.toMap()).toList();
  }

  /// Generate sample employees
  static void _generateEmployees() {
    _employees = [
      // Engineering Department
      DemoEmployee(
        id: 'emp_001',
        name: 'Alice Johnson',
        position: 'Senior Software Engineer',
        department: 'Engineering',
        salary: 120000,
        avatar: '👩‍💻',
        performance: 0.92,
        skills: ['Flutter', 'Dart', 'React', 'TypeScript'],
        joinDate: DateTime(2021, 3, 15),
        email: 'alice.johnson@company.com',
        phone: '+1-555-0101',
      ),
      DemoEmployee(
        id: 'emp_002',
        name: 'Bob Smith',
        position: 'Frontend Developer',
        department: 'Engineering',
        salary: 85000,
        avatar: '👨‍💻',
        performance: 0.88,
        skills: ['React', 'Vue.js', 'JavaScript', 'CSS'],
        joinDate: DateTime(2022, 1, 10),
        email: 'bob.smith@company.com',
        phone: '+1-555-0102',
      ),
      DemoEmployee(
        id: 'emp_003',
        name: 'Carol Davis',
        position: 'DevOps Engineer',
        department: 'Engineering',
        salary: 95000,
        avatar: '👩‍🔧',
        performance: 0.95,
        skills: ['Docker', 'Kubernetes', 'AWS', 'Terraform'],
        joinDate: DateTime(2020, 8, 22),
        email: 'carol.davis@company.com',
        phone: '+1-555-0103',
      ),

      // Design Department
      DemoEmployee(
        id: 'emp_004',
        name: 'Diana Wilson',
        position: 'UX Designer',
        department: 'Design',
        salary: 78000,
        avatar: '👩‍🎨',
        performance: 0.90,
        skills: ['Figma', 'Sketch', 'Adobe XD', 'Prototyping'],
        joinDate: DateTime(2021, 11, 5),
        email: 'diana.wilson@company.com',
        phone: '+1-555-0104',
      ),
      DemoEmployee(
        id: 'emp_005',
        name: 'Ethan Brown',
        position: 'UI Designer',
        department: 'Design',
        salary: 72000,
        avatar: '👨‍🎨',
        performance: 0.85,
        skills: ['Figma', 'Adobe Creative Suite', 'Animation'],
        joinDate: DateTime(2022, 6, 18),
        email: 'ethan.brown@company.com',
        phone: '+1-555-0105',
      ),

      // Marketing Department
      DemoEmployee(
        id: 'emp_006',
        name: 'Fiona Green',
        position: 'Marketing Manager',
        department: 'Marketing',
        salary: 90000,
        avatar: '👩‍💼',
        performance: 0.87,
        skills: ['Digital Marketing', 'SEO', 'Analytics', 'Content Strategy'],
        joinDate: DateTime(2020, 4, 12),
        email: 'fiona.green@company.com',
        phone: '+1-555-0106',
      ),
      DemoEmployee(
        id: 'emp_007',
        name: 'George Taylor',
        position: 'Content Writer',
        department: 'Marketing',
        salary: 58000,
        avatar: '👨‍✍️',
        performance: 0.82,
        skills: ['Content Writing', 'SEO', 'Copywriting', 'Social Media'],
        joinDate: DateTime(2021, 9, 28),
        email: 'george.taylor@company.com',
        phone: '+1-555-0107',
      ),

      // Sales Department
      DemoEmployee(
        id: 'emp_008',
        name: 'Hannah White',
        position: 'Sales Director',
        department: 'Sales',
        salary: 110000,
        avatar: '👩‍💼',
        performance: 0.94,
        skills: ['Sales Strategy', 'CRM', 'Negotiation', 'Team Leadership'],
        joinDate: DateTime(2019, 2, 14),
        email: 'hannah.white@company.com',
        phone: '+1-555-0108',
      ),
      DemoEmployee(
        id: 'emp_009',
        name: 'Ian Clark',
        position: 'Sales Representative',
        department: 'Sales',
        salary: 65000,
        avatar: '👨‍💼',
        performance: 0.79,
        skills: ['Cold Calling', 'Lead Generation', 'Presentations'],
        joinDate: DateTime(2022, 3, 7),
        email: 'ian.clark@company.com',
        phone: '+1-555-0109',
      ),

      // HR Department
      DemoEmployee(
        id: 'emp_010',
        name: 'Julia Martinez',
        position: 'HR Manager',
        department: 'HR',
        salary: 82000,
        avatar: '👩‍💼',
        performance: 0.91,
        skills: ['Recruitment', 'Employee Relations', 'HR Policy', 'Training'],
        joinDate: DateTime(2020, 10, 3),
        email: 'julia.martinez@company.com',
        phone: '+1-555-0110',
      ),
    ];
  }

  /// Generate sample departments
  static void _generateDepartments() {
    _departments = [
      DemoDepartment(
        id: 'dept_001',
        name: 'Engineering',
        manager: 'Alice Johnson',
        memberCount: 3,
        budget: 500000,
        projects: ['Project Alpha', 'Project Beta'],
        color: Colors.blue,
        description: 'Software development and technical infrastructure',
        location: 'Building A, Floor 3',
      ),
      DemoDepartment(
        id: 'dept_002',
        name: 'Design',
        manager: 'Diana Wilson',
        memberCount: 2,
        budget: 200000,
        projects: ['UI Redesign', 'Brand Identity'],
        color: Colors.purple,
        description: 'User experience and visual design',
        location: 'Building A, Floor 2',
      ),
      DemoDepartment(
        id: 'dept_003',
        name: 'Marketing',
        manager: 'Fiona Green',
        memberCount: 2,
        budget: 300000,
        projects: ['Campaign 2024', 'SEO Optimization'],
        color: Colors.orange,
        description: 'Marketing and brand promotion',
        location: 'Building B, Floor 1',
      ),
      DemoDepartment(
        id: 'dept_004',
        name: 'Sales',
        manager: 'Hannah White',
        memberCount: 2,
        budget: 250000,
        projects: ['Q1 Sales Drive', 'Client Expansion'],
        color: Colors.green,
        description: 'Sales and client relationships',
        location: 'Building B, Floor 2',
      ),
      DemoDepartment(
        id: 'dept_005',
        name: 'HR',
        manager: 'Julia Martinez',
        memberCount: 1,
        budget: 150000,
        projects: ['Recruitment Drive', 'Training Program'],
        color: Colors.teal,
        description: 'Human resources and employee management',
        location: 'Building A, Floor 1',
      ),
    ];
  }

  /// Generate sample projects
  static void _generateProjects() {
    _projects = [
      DemoProject(
        id: 'proj_001',
        name: 'Mobile App Development',
        description: 'Develop a cross-platform mobile application',
        memberIds: ['emp_001', 'emp_002'],
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 6, 30),
        progress: 0.65,
        budget: 150000,
        priority: ProjectPriority.high,
        status: ProjectStatus.active,
      ),
      DemoProject(
        id: 'proj_002',
        name: 'Website Redesign',
        description: 'Complete overhaul of company website',
        memberIds: ['emp_004', 'emp_005', 'emp_002'],
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 5, 15),
        progress: 0.80,
        budget: 80000,
        priority: ProjectPriority.medium,
        status: ProjectStatus.active,
      ),
      DemoProject(
        id: 'proj_003',
        name: 'Marketing Campaign',
        description: 'Q2 product launch marketing campaign',
        memberIds: ['emp_006', 'emp_007'],
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 7, 31),
        progress: 0.45,
        budget: 120000,
        priority: ProjectPriority.high,
        status: ProjectStatus.active,
      ),
    ];
  }

  /// Refresh data (regenerate)
  static void refresh() {
    _employees.clear();
    _departments.clear();
    _projects.clear();
  }

  /// Add new employee
  static void addEmployee(DemoEmployee employee) {
    _employees.add(employee);
  }

  /// Remove employee
  static void removeEmployee(String employeeId) {
    _employees.removeWhere((e) => e.id == employeeId);
  }

  /// Update employee
  static void updateEmployee(String employeeId, DemoEmployee newEmployee) {
    final index = _employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      _employees[index] = newEmployee;
    }
  }
}