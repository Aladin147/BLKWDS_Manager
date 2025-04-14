import 'package:mockito/mockito.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';

/// Mock DBService for testing
class MockDBService extends Mock implements DBService {
  // Sample data for testing
  static final List<Gear> _gearList = [
    Gear(
      id: 1,
      name: 'Test Camera',
      category: 'Camera',
      isOut: false,
    ),
    Gear(
      id: 2,
      name: 'Test Microphone',
      category: 'Audio',
      isOut: true,
      lastNote: 'Being used for testing',
    ),
  ];

  static final List<Member> _memberList = [
    Member(
      id: 1,
      name: 'Test User',
      role: 'Tester',
    ),
    Member(
      id: 2,
      name: 'Another Tester',
      role: 'QA',
    ),
  ];

  static final List<Project> _projectList = [
    Project(
      id: 1,
      title: 'Test Project',
      client: 'Test Client',
      notes: 'This is a test project',
      memberIds: [1, 2],
    ),
  ];

  static final List<Booking> _bookingList = [
    Booking(
      id: 1,
      projectId: 1,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      isProductionStudio: true,
      gearIds: [1, 2],
      assignedGearToMember: {
        1: 1,
        2: 2,
      },
    ),
  ];

  // Mock implementations
  @override
  static Future<List<Gear>> getAllGear() async {
    return _gearList;
  }

  @override
  static Future<List<Member>> getAllMembers() async {
    return _memberList;
  }

  @override
  static Future<List<Project>> getAllProjects() async {
    return _projectList;
  }

  @override
  static Future<List<Booking>> getAllBookings() async {
    return _bookingList;
  }

  @override
  static Future<int> insertGear(Gear gear) async {
    return 3; // Return a new ID
  }

  @override
  static Future<int> updateGear(Gear gear) async {
    return 1; // Return number of rows affected
  }

  @override
  static Future<int> deleteGear(int id) async {
    return 1; // Return number of rows affected
  }

  // Add more mock implementations as needed
}
