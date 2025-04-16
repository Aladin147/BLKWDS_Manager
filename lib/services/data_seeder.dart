import '../models/models.dart';
import 'db_service.dart';
import 'log_service.dart';

/// DataSeeder
/// Utility class for seeding the database with sample data
class DataSeeder {
  /// Seed the database with sample data
  static Future<void> seedDatabase() async {
    // Check if database is already seeded
    final members = await DBService.getAllMembers();
    if (members.isNotEmpty) {
      LogService.info('Database already seeded');
      return;
    }

    LogService.info('Seeding database...');

    // Seed members
    final memberIds = await _seedMembers();

    // Seed gear
    final gearIds = await _seedGear();

    // Seed projects
    final projectIds = await _seedProjects(memberIds);

    // Seed bookings
    await _seedBookings(projectIds, gearIds, memberIds);

    // Seed activity logs
    await _seedActivityLogs(gearIds, memberIds);

    LogService.info('Database seeded successfully');
  }

  /// Seed members
  static Future<List<int>> _seedMembers() async {
    final members = [
      Member(
        name: 'Alex Johnson',
        role: 'Director',
      ),
      Member(
        name: 'Sam Williams',
        role: 'Cinematographer',
      ),
      Member(
        name: 'Jordan Lee',
        role: 'Sound Engineer',
      ),
      Member(
        name: 'Taylor Smith',
        role: 'Producer',
      ),
    ];

    final memberIds = <int>[];
    for (final member in members) {
      final id = await DBService.insertMember(member);
      memberIds.add(id);
    }

    return memberIds;
  }

  /// Seed gear
  static Future<List<int>> _seedGear() async {
    final gear = [
      Gear(
        name: 'Canon R6',
        category: 'Camera',
        isOut: false,
      ),
      Gear(
        name: 'Sony A7III',
        category: 'Camera',
        isOut: true,
        lastNote: 'Battery at 50%',
      ),
      Gear(
        name: 'DJI Ronin',
        category: 'Stabilizer',
        isOut: false,
      ),
      Gear(
        name: 'Sennheiser MKH416',
        category: 'Audio',
        isOut: true,
      ),
      Gear(
        name: 'Aputure 120D',
        category: 'Lighting',
        isOut: false,
      ),
      Gear(
        name: 'Canon 24-70mm f/2.8',
        category: 'Lens',
        isOut: false,
      ),
      Gear(
        name: 'Zoom H6',
        category: 'Audio',
        isOut: false,
        lastNote: 'New SD card installed',
      ),
      Gear(
        name: 'Manfrotto Tripod',
        category: 'Support',
        isOut: true,
      ),
    ];

    final gearIds = <int>[];
    for (final item in gear) {
      final id = await DBService.insertGear(item);
      gearIds.add(id);
    }

    return gearIds;
  }

  /// Seed projects
  static Future<List<int>> _seedProjects(List<int> memberIds) async {
    final projects = [
      Project(
        title: 'Brand Commercial',
        client: 'XYZ Corp',
        notes: 'Two-day shoot in studio',
        memberIds: [memberIds[0], memberIds[1]],
      ),
      Project(
        title: 'Music Video',
        client: 'Indie Band',
        notes: 'Outdoor locations, backup gear needed',
        memberIds: [memberIds[0], memberIds[1], memberIds[2]],
      ),
      Project(
        title: 'Documentary Interview',
        client: 'Non-profit Org',
        notes: 'Minimal setup, focus on audio quality',
        memberIds: [memberIds[2], memberIds[3]],
      ),
    ];

    final projectIds = <int>[];
    for (final project in projects) {
      final id = await DBService.insertProject(project);
      projectIds.add(id);
    }

    return projectIds;
  }

  /// Seed bookings
  static Future<List<int>> _seedBookings(
    List<int> projectIds,
    List<int> gearIds,
    List<int> memberIds,
  ) async {
    final now = DateTime.now();

    final bookings = [
      Booking(
        projectId: projectIds[0],
        title: 'Commercial Shoot',
        startDate: DateTime(now.year, now.month, now.day + 3, 9),
        endDate: DateTime(now.year, now.month, now.day + 3, 18),
        studioId: 2, // Production studio
        gearIds: [gearIds[0], gearIds[2], gearIds[4], gearIds[5]],
        assignedGearToMember: {
          gearIds[0]: memberIds[1], // Camera assigned to Cinematographer
          gearIds[2]: memberIds[1], // Stabilizer assigned to Cinematographer
        },
      ),
      Booking(
        projectId: projectIds[1],
        title: 'Music Video',
        startDate: DateTime(now.year, now.month, now.day + 5, 10),
        endDate: DateTime(now.year, now.month, now.day + 6, 16),
        studioId: 1, // Recording studio
        gearIds: [gearIds[1], gearIds[3], gearIds[6]],
        assignedGearToMember: {
          gearIds[3]: memberIds[2], // Mic assigned to Sound Engineer
          gearIds[6]: memberIds[2], // Recorder assigned to Sound Engineer
        },
      ),
      Booking(
        projectId: projectIds[2],
        title: 'Documentary Shoot',
        startDate: DateTime(now.year, now.month, now.day + 10, 13),
        endDate: DateTime(now.year, now.month, now.day + 10, 17),
        studioId: 1, // Recording studio
        gearIds: [gearIds[3], gearIds[6], gearIds[7]],
      ),
    ];

    final bookingIds = <int>[];
    for (final booking in bookings) {
      final id = await DBService.insertBooking(booking);
      bookingIds.add(id);
    }

    return bookingIds;
  }

  /// Seed activity logs
  static Future<void> _seedActivityLogs(
    List<int> gearIds,
    List<int> memberIds,
  ) async {
    final now = DateTime.now();

    final activityLogs = [
      ActivityLog(
        gearId: gearIds[1],
        memberId: memberIds[1],
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 9, 30),
        note: 'Taking for outdoor shoot',
      ),
      ActivityLog(
        gearId: gearIds[3],
        memberId: memberIds[2],
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 10, 15),
      ),
      ActivityLog(
        gearId: gearIds[7],
        memberId: memberIds[1],
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 10, 20),
      ),
      ActivityLog(
        gearId: gearIds[0],
        memberId: memberIds[0],
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 2, 14, 0),
        note: 'For client meeting demo',
      ),
      ActivityLog(
        gearId: gearIds[0],
        memberId: null,
        checkedOut: false,
        timestamp: DateTime(now.year, now.month, now.day - 1, 17, 45),
        note: 'Returned with full battery',
      ),
    ];

    for (final log in activityLogs) {
      await DBService.insertActivityLog(log);
    }

    // Add status notes
    final statusNotes = [
      StatusNote(
        gearId: gearIds[1],
        note: 'Battery at 50%',
        timestamp: DateTime(now.year, now.month, now.day - 1, 17, 30),
      ),
      StatusNote(
        gearId: gearIds[6],
        note: 'New SD card installed',
        timestamp: DateTime(now.year, now.month, now.day - 3, 11, 15),
      ),
      StatusNote(
        gearId: gearIds[2],
        note: 'Needs calibration soon',
        timestamp: DateTime(now.year, now.month, now.day - 5, 9, 0),
      ),
    ];

    for (final note in statusNotes) {
      await DBService.insertStatusNote(note);
    }
  }
}
