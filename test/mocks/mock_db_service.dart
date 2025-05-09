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
      title: 'Test Booking',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      studioId: 1,
      gearIds: [1, 2],
      assignedGearToMember: {
        1: 1,
        2: 2,
      },
    ),
  ];

  // Mock implementations
  static Future<List<Gear>> getAllGear() async {
    return _gearList;
  }

  static Future<List<Member>> getAllMembers() async {
    return _memberList;
  }

  static Future<List<Project>> getAllProjects() async {
    return _projectList;
  }

  static Future<List<Booking>> getAllBookings() async {
    return _bookingList;
  }

  static Future<int> insertGear(Gear gear) async {
    return 3; // Return a new ID
  }

  static Future<int> updateGear(Gear gear) async {
    return 1; // Return number of rows affected
  }

  static Future<int> deleteGear(int id) async {
    return 1; // Return number of rows affected
  }

  // Add more mock implementations as needed

  /// Check if a booking conflicts with existing bookings
  static Future<bool> hasBookingConflicts(Booking booking, {int? excludeBookingId}) async {
    // This is a mock implementation for testing
    return false;
  }
}
