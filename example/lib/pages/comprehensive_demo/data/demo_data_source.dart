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
      DemoEmployee(
        id: 'emp_011',
        name: 'Sarah Wilson',
        position: 'HR Specialist',
        department: 'HR',
        salary: 65000,
        avatar: '👩‍💼',
        performance: 0.85,
        skills: [
          'Onboarding',
          'Benefits Administration',
          'Compliance',
          'Documentation'
        ],
        joinDate: DateTime(2021, 7, 15),
        email: 'sarah.wilson@company.com',
        phone: '+1-555-0111',
      ),

      // More Engineering Department
      DemoEmployee(
        id: 'emp_012',
        name: 'Michael Chen',
        position: 'Backend Developer',
        department: 'Engineering',
        salary: 98000,
        avatar: '👨‍💻',
        performance: 0.89,
        skills: ['Python', 'Django', 'PostgreSQL', 'Redis'],
        joinDate: DateTime(2021, 12, 1),
        email: 'michael.chen@company.com',
        phone: '+1-555-0112',
      ),
      DemoEmployee(
        id: 'emp_013',
        name: 'Lisa Park',
        position: 'QA Engineer',
        department: 'Engineering',
        salary: 75000,
        avatar: '👩‍🔬',
        performance: 0.93,
        skills: ['Test Automation', 'Selenium', 'Jest', 'Quality Assurance'],
        joinDate: DateTime(2022, 4, 20),
        email: 'lisa.park@company.com',
        phone: '+1-555-0113',
      ),
      DemoEmployee(
        id: 'emp_014',
        name: 'David Rodriguez',
        position: 'Full Stack Developer',
        department: 'Engineering',
        salary: 105000,
        avatar: '👨‍💻',
        performance: 0.87,
        skills: ['React', 'Node.js', 'MongoDB', 'GraphQL'],
        joinDate: DateTime(2020, 11, 8),
        email: 'david.rodriguez@company.com',
        phone: '+1-555-0114',
      ),

      // More Sales Department
      DemoEmployee(
        id: 'emp_015',
        name: 'Emma Thompson',
        position: 'Account Manager',
        department: 'Sales',
        salary: 78000,
        avatar: '👩‍💼',
        performance: 0.88,
        skills: [
          'Account Management',
          'Customer Relations',
          'Upselling',
          'CRM'
        ],
        joinDate: DateTime(2021, 5, 12),
        email: 'emma.thompson@company.com',
        phone: '+1-555-0115',
      ),
      DemoEmployee(
        id: 'emp_016',
        name: 'James Foster',
        position: 'Business Development',
        department: 'Sales',
        salary: 85000,
        avatar: '👨‍💼',
        performance: 0.83,
        skills: [
          'Partnership Development',
          'Market Analysis',
          'Strategic Planning'
        ],
        joinDate: DateTime(2022, 8, 3),
        email: 'james.foster@company.com',
        phone: '+1-555-0116',
      ),

      // More Marketing Department
      DemoEmployee(
        id: 'emp_017',
        name: 'Rachel Kim',
        position: 'Social Media Manager',
        department: 'Marketing',
        salary: 62000,
        avatar: '👩‍💻',
        performance: 0.86,
        skills: [
          'Social Media',
          'Content Creation',
          'Analytics',
          'Community Management'
        ],
        joinDate: DateTime(2022, 2, 14),
        email: 'rachel.kim@company.com',
        phone: '+1-555-0117',
      ),
      DemoEmployee(
        id: 'emp_018',
        name: 'Kevin Lee',
        position: 'Digital Marketing Specialist',
        department: 'Marketing',
        salary: 68000,
        avatar: '👨‍💻',
        performance: 0.84,
        skills: [
          'PPC Advertising',
          'Google Ads',
          'Email Marketing',
          'Conversion Optimization'
        ],
        joinDate: DateTime(2021, 10, 25),
        email: 'kevin.lee@company.com',
        phone: '+1-555-0118',
      ),

      // More Design Department
      DemoEmployee(
        id: 'emp_019',
        name: 'Sophie Miller',
        position: 'Product Designer',
        department: 'Design',
        salary: 88000,
        avatar: '👩‍🎨',
        performance: 0.92,
        skills: [
          'Product Design',
          'User Research',
          'Wireframing',
          'Design Systems'
        ],
        joinDate: DateTime(2020, 6, 10),
        email: 'sophie.miller@company.com',
        phone: '+1-555-0119',
      ),
      DemoEmployee(
        id: 'emp_020',
        name: 'Alex Turner',
        position: 'Graphic Designer',
        department: 'Design',
        salary: 65000,
        avatar: '👨‍🎨',
        performance: 0.80,
        skills: ['Illustration', 'Brand Design', 'Print Design', 'Photography'],
        joinDate: DateTime(2022, 9, 5),
        email: 'alex.turner@company.com',
        phone: '+1-555-0120',
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
        memberCount: 6,
        budget: 800000,
        projects: ['Project Alpha', 'Project Beta', 'API Development'],
        color: Colors.blue,
        description: 'Software development and technical infrastructure',
        location: 'Building A, Floor 3',
      ),
      DemoDepartment(
        id: 'dept_002',
        name: 'Design',
        manager: 'Diana Wilson',
        memberCount: 4,
        budget: 350000,
        projects: ['UI Redesign', 'Brand Identity', 'Design System'],
        color: Colors.purple,
        description: 'User experience and visual design',
        location: 'Building A, Floor 2',
      ),
      DemoDepartment(
        id: 'dept_003',
        name: 'Marketing',
        manager: 'Fiona Green',
        memberCount: 4,
        budget: 450000,
        projects: ['Campaign 2024', 'SEO Optimization', 'Content Strategy'],
        color: Colors.orange,
        description: 'Marketing and brand promotion',
        location: 'Building B, Floor 1',
      ),
      DemoDepartment(
        id: 'dept_004',
        name: 'Sales',
        manager: 'Hannah White',
        memberCount: 4,
        budget: 400000,
        projects: [
          'Q1 Sales Drive',
          'Client Expansion',
          'Partnership Development'
        ],
        color: Colors.green,
        description: 'Sales and client relationships',
        location: 'Building B, Floor 2',
      ),
      DemoDepartment(
        id: 'dept_005',
        name: 'HR',
        manager: 'Julia Martinez',
        memberCount: 2,
        budget: 200000,
        projects: [
          'Recruitment Drive',
          'Training Program',
          'Employee Wellness'
        ],
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
