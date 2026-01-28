import 'dart:math';

/// Utility class for generating random employee data for testing
/// Supports generating 10 to 100,000+ records efficiently
class RandomDataGenerator {
  static final Random _random = Random();

  // Sample data pools for realistic random generation
  static const List<String> _firstNames = [
    'James',
    'Mary',
    'John',
    'Patricia',
    'Robert',
    'Jennifer',
    'Michael',
    'Linda',
    'William',
    'Elizabeth',
    'David',
    'Barbara',
    'Richard',
    'Susan',
    'Joseph',
    'Jessica',
    'Thomas',
    'Sarah',
    'Charles',
    'Karen',
    'Christopher',
    'Nancy',
    'Daniel',
    'Lisa',
    'Matthew',
    'Betty',
    'Anthony',
    'Margaret',
    'Mark',
    'Sandra',
    'Donald',
    'Ashley',
    'Steven',
    'Kimberly',
    'Paul',
    'Emily',
    'Andrew',
    'Donna',
    'Joshua',
    'Michelle',
    'Kenneth',
    'Dorothy',
    'Kevin',
    'Carol',
    'Brian',
    'Amanda',
    'George',
    'Melissa',
    'Edward',
    'Deborah',
    'Ronald',
    'Stephanie',
    'Timothy',
    'Rebecca',
    'Jason',
    'Sharon',
    'Jeffrey',
    'Laura',
    'Ryan',
    'Cynthia',
    'Jacob',
    'Kathleen',
    'Gary',
    'Amy',
    'Nicholas',
    'Shirley',
    'Eric',
    'Angela',
    'Jonathan',
    'Helen',
    'Stephen',
    'Anna',
    'Larry',
    'Brenda',
    'Justin',
    'Pamela',
    'Scott',
    'Nicole',
    'Brandon',
    'Emma',
    'Benjamin',
    'Samantha',
    'Samuel',
    'Katherine',
    'Raymond',
    'Christine',
    'Gregory',
    'Debra',
    'Frank',
    'Rachel',
    'Alexander',
    'Catherine',
    'Patrick',
    'Carolyn',
    'Raymond',
    'Janet',
    'Jack',
    'Ruth',
    'Dennis',
    'Maria',
    'Jerry',
    'Heather',
    'Tyler',
    'Diane',
    'Aaron',
    'Virginia',
    'Jose',
    'Julie',
    'Adam',
    'Joyce',
    'Nathan',
    'Victoria',
    'Henry',
    'Olivia',
    'Douglas',
    'Kelly',
    'Zachary',
    'Christina',
    'Peter',
    'Lauren',
    'Kyle',
    'Joan',
    'Walter',
    'Evelyn',
    'Ethan',
    'Judith',
    'Jeremy',
    'Megan',
    'Harold',
    'Cheryl',
    'Keith',
    'Andrea',
    'Christian',
    'Hannah',
    'Roger',
    'Jacqueline',
    'Noah',
    'Martha',
    'Gerald',
    'Gloria',
    'Carl',
    'Teresa',
    'Terry',
    'Ann',
    'Sean',
    'Sara',
    'Austin',
    'Madison',
    'Arthur',
    'Frances',
    'Lawrence',
    'Kathryn',
    'Jesse',
    'Janice',
    'Dylan',
    'Jean',
    'Bryan',
    'Abigail',
    'Joe',
    'Alice',
  ];

  static const List<String> _lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
    'Wilson',
    'Anderson',
    'Thomas',
    'Taylor',
    'Moore',
    'Jackson',
    'Martin',
    'Lee',
    'Perez',
    'Thompson',
    'White',
    'Harris',
    'Sanchez',
    'Clark',
    'Ramirez',
    'Lewis',
    'Robinson',
    'Walker',
    'Young',
    'Allen',
    'King',
    'Wright',
    'Scott',
    'Torres',
    'Nguyen',
    'Hill',
    'Flores',
    'Green',
    'Adams',
    'Nelson',
    'Baker',
    'Hall',
    'Rivera',
    'Campbell',
    'Mitchell',
    'Carter',
    'Roberts',
    'Gomez',
    'Phillips',
    'Evans',
    'Turner',
    'Diaz',
    'Parker',
    'Cruz',
    'Edwards',
    'Collins',
    'Reyes',
    'Stewart',
    'Morris',
    'Morales',
    'Murphy',
    'Cook',
    'Rogers',
    'Gutierrez',
    'Ortiz',
    'Morgan',
    'Cooper',
    'Peterson',
    'Bailey',
    'Reed',
    'Kelly',
    'Howard',
    'Ramos',
    'Kim',
    'Cox',
    'Ward',
    'Richardson',
    'Watson',
    'Brooks',
    'Chavez',
    'Wood',
    'James',
    'Bennett',
    'Gray',
    'Mendoza',
    'Ruiz',
    'Hughes',
    'Price',
    'Alvarez',
    'Castillo',
    'Sanders',
    'Patel',
    'Myers',
    'Long',
    'Ross',
    'Foster',
    'Jimenez',
    'Powell',
    'Jenkins',
    'Perry',
    'Russell',
    'Sullivan',
    'Bell',
    'Coleman',
    'Butler',
    'Henderson',
    'Barnes',
    'Gonzales',
    'Fisher',
    'Vasquez',
    'Simmons',
    'Romero',
    'Jordan',
    'Patterson',
    'Alexander',
    'Hamilton',
    'Graham',
    'Reynolds',
    'Griffin',
    'Wallace',
    'Moreno',
    'West',
    'Cole',
    'Hayes',
    'Bryant',
    'Herrera',
    'Gibson',
    'Ellis',
    'Tran',
    'Medina',
    'Aguilar',
    'Stevens',
    'Murray',
    'Ford',
    'Castro',
    'Marshall',
    'Owens',
    'Harrison',
    'Fernandez',
    'McDonald',
    'Woods',
    'Washington',
    'Kennedy',
    'Wells',
    'Vargas',
    'Henry',
    'Chen',
    'Freeman',
    'Webb',
    'Tucker',
    'Guzman',
    'Burns',
    'Crawford',
    'Olson',
    'Simpson',
    'Porter',
    'Hunter',
  ];

  static const List<String> _departments = [
    'Engineering',
    'Design',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'Customer Support',
    'Product',
    'Legal',
  ];

  static const List<String> _positions = [
    'Senior Software Engineer',
    'Software Engineer',
    'Junior Developer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'DevOps Engineer',
    'QA Engineer',
    'Data Scientist',
    'Product Manager',
    'UX Designer',
    'UI Designer',
    'Graphic Designer',
    'Marketing Manager',
    'Content Writer',
    'Social Media Manager',
    'Sales Director',
    'Sales Representative',
    'Account Manager',
    'Business Development',
    'HR Manager',
    'HR Specialist',
    'Recruiter',
    'Financial Analyst',
    'Accountant',
    'Operations Manager',
    'Support Specialist',
    'Team Lead',
    'Technical Writer',
    'System Administrator',
  ];

  static const List<String> _avatars = [
    '👨‍💻',
    '👩‍💻',
    '👨‍🎨',
    '👩‍🎨',
    '👨‍💼',
    '👩‍💼',
    '👨‍🔬',
    '👩‍🔬',
    '👨‍🔧',
    '👩‍🔧',
    '👨‍⚕️',
    '👩‍⚕️',
    '👨‍🏫',
    '👩‍🏫',
    '👨‍🚀',
    '👩‍🚀',
    '👨‍✈️',
    '👩‍✈️',
    '👨‍🎤',
    '👩‍🎤',
    '👨‍🍳',
    '👩‍🍳',
    '👨‍🌾',
    '👩‍🌾',
    '👨‍⚖️',
    '👩‍⚖️',
    '👨‍🏭',
    '👩‍🏭',
    '👨‍💻',
    '👩‍💻',
  ];

  /// Generate a list of random employee data
  ///
  /// Parameters:
  /// - [count]: Number of employees to generate (10 to 100,000+)
  /// - [startId]: Starting ID number (default: 1)
  ///
  /// Returns a list of Map with String keys and dynamic values compatible with FlutterTablePlus
  static List<Map<String, dynamic>> generateEmployees(int count,
      {int startId = 1}) {
    final stopwatch = Stopwatch()..start();

    final List<Map<String, dynamic>> employees = [];

    for (int i = 0; i < count; i++) {
      final id = startId + i;
      final firstName = _firstNames[_random.nextInt(_firstNames.length)];
      final lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final department = _departments[_random.nextInt(_departments.length)];
      final position = _positions[_random.nextInt(_positions.length)];
      final avatar = _avatars[_random.nextInt(_avatars.length)];

      // Generate salary based on position level
      final baseSalary = position.contains('Senior') ||
              position.contains('Manager') ||
              position.contains('Director')
          ? 80000 + _random.nextInt(120000) // 80k - 200k
          : position.contains('Junior')
              ? 45000 + _random.nextInt(35000) // 45k - 80k
              : 55000 + _random.nextInt(60000); // 55k - 115k

      // Generate performance score (0.5 - 1.0)
      final performance = 0.5 + (_random.nextDouble() * 0.5);

      // Generate random join date (last 5 years)
      final now = DateTime.now();
      final daysAgo = _random.nextInt(365 * 5); // Up to 5 years ago
      final joinDate = now.subtract(Duration(days: daysAgo));

      employees.add({
        'id': 'emp_${id.toString().padLeft(6, '0')}',
        'name': '$firstName $lastName',
        'position': position,
        'department': department,
        'salary': baseSalary,
        'avatar': avatar,
        'performance': double.parse(performance.toStringAsFixed(2)),
        'joinDate': joinDate,
        'email':
            '${firstName.toLowerCase()}.${lastName.toLowerCase()}@company.com',
        'phone': '+1-555-${_random.nextInt(9000) + 1000}',
        'isActive': _random.nextDouble() > 0.2, // ~80% active
      });
    }

    stopwatch.stop();
    // ignore: avoid_print
    print('✅ Generated $count employees in ${stopwatch.elapsedMilliseconds}ms');

    return employees;
  }

  /// Generate a random name
  static String generateName() {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];
    return '$firstName $lastName';
  }

  /// Generate a random department
  static String generateDepartment() {
    return _departments[_random.nextInt(_departments.length)];
  }

  /// Generate a random position
  static String generatePosition() {
    return _positions[_random.nextInt(_positions.length)];
  }

  /// Generate a random salary based on position level
  static int generateSalary(String position) {
    if (position.contains('Senior') ||
        position.contains('Manager') ||
        position.contains('Director')) {
      return 80000 + _random.nextInt(120000); // 80k - 200k
    } else if (position.contains('Junior')) {
      return 45000 + _random.nextInt(35000); // 45k - 80k
    } else {
      return 55000 + _random.nextInt(60000); // 55k - 115k
    }
  }

  /// Generate a random performance score (0.5 - 1.0)
  static double generatePerformance() {
    return 0.5 + (_random.nextDouble() * 0.5);
  }

  /// Generate a random join date (last 5 years)
  static DateTime generateJoinDate() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(365 * 5); // Up to 5 years ago
    return now.subtract(Duration(days: daysAgo));
  }

  /// Get performance metrics for generated data
  static Map<String, dynamic> getGenerationMetrics(int count) {
    final stopwatch = Stopwatch()..start();
    generateEmployees(count);
    stopwatch.stop();

    return {
      'count': count,
      'timeMs': stopwatch.elapsedMilliseconds,
      'ratePerSecond': (count / (stopwatch.elapsedMilliseconds / 1000)).round(),
    };
  }
}
