import '../models/models.dart';

/// MockData
/// Provides sample data for development and testing
class MockData {
  /// Sample gear items
  static List<Gear> getSampleGear() {
    return [
      Gear(
        id: 1,
        name: 'Canon R6',
        category: 'Camera',
        isOut: false,
      ),
      Gear(
        id: 2,
        name: 'Sony A7III',
        category: 'Camera',
        isOut: true,
        lastNote: 'Battery at 50%',
      ),
      Gear(
        id: 3,
        name: 'DJI Ronin',
        category: 'Stabilizer',
        isOut: false,
      ),
      Gear(
        id: 4,
        name: 'Sennheiser MKH416',
        category: 'Audio',
        isOut: true,
      ),
      Gear(
        id: 5,
        name: 'Aputure 120D',
        category: 'Lighting',
        isOut: false,
      ),
      Gear(
        id: 6,
        name: 'Canon 24-70mm f/2.8',
        category: 'Lens',
        isOut: false,
      ),
      Gear(
        id: 7,
        name: 'Zoom H6',
        category: 'Audio',
        isOut: false,
        lastNote: 'New SD card installed',
      ),
      Gear(
        id: 8,
        name: 'Manfrotto Tripod',
        category: 'Support',
        isOut: true,
      ),
    ];
  }

  /// Sample members
  static List<Member> getSampleMembers() {
    return [
      Member(
        id: 1,
        name: 'Alex Johnson',
        role: 'Director',
      ),
      Member(
        id: 2,
        name: 'Sam Williams',
        role: 'Cinematographer',
      ),
      Member(
        id: 3,
        name: 'Jordan Lee',
        role: 'Sound Engineer',
      ),
      Member(
        id: 4,
        name: 'Taylor Smith',
        role: 'Producer',
      ),
    ];
  }

  /// Sample projects
  static List<Project> getSampleProjects() {
    return [
      Project(
        id: 1,
        title: 'Brand Commercial',
        client: 'XYZ Corp',
        notes: 'Two-day shoot in studio',
        memberIds: [1, 2],
      ),
      Project(
        id: 2,
        title: 'Music Video',
        client: 'Indie Band',
        notes: 'Outdoor locations, backup gear needed',
        memberIds: [1, 2, 3],
      ),
      Project(
        id: 3,
        title: 'Documentary Interview',
        client: 'Non-profit Org',
        notes: 'Minimal setup, focus on audio quality',
        memberIds: [3, 4],
      ),
    ];
  }

  /// Sample bookings
  static List<Booking> getSampleBookings() {
    final now = DateTime.now();

    return [
      Booking(
        id: 1,
        projectId: 1,
        title: 'Commercial Shoot',
        startDate: DateTime(now.year, now.month, now.day + 3, 9),
        endDate: DateTime(now.year, now.month, now.day + 3, 18),
        isProductionStudio: true,
        gearIds: [1, 3, 5, 6],
        assignedGearToMember: {
          1: 2, // Camera assigned to Cinematographer
          3: 2, // Stabilizer assigned to Cinematographer
        },
      ),
      Booking(
        id: 2,
        projectId: 2,
        title: 'Music Video',
        startDate: DateTime(now.year, now.month, now.day + 5, 10),
        endDate: DateTime(now.year, now.month, now.day + 6, 16),
        isRecordingStudio: true,
        gearIds: [2, 4, 7],
        assignedGearToMember: {
          4: 3, // Mic assigned to Sound Engineer
          7: 3, // Recorder assigned to Sound Engineer
        },
      ),
      Booking(
        id: 3,
        projectId: 3,
        title: 'Documentary Shoot',
        startDate: DateTime(now.year, now.month, now.day + 10, 13),
        endDate: DateTime(now.year, now.month, now.day + 10, 17),
        isRecordingStudio: true,
        gearIds: [4, 7, 8],
      ),
    ];
  }

  /// Sample activity logs
  static List<ActivityLog> getSampleActivityLogs() {
    final now = DateTime.now();

    return [
      ActivityLog(
        id: 1,
        gearId: 2,
        memberId: 2,
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 9, 30),
        note: 'Taking for outdoor shoot',
      ),
      ActivityLog(
        id: 2,
        gearId: 4,
        memberId: 3,
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 10, 15),
      ),
      ActivityLog(
        id: 3,
        gearId: 8,
        memberId: 2,
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 1, 10, 20),
      ),
      ActivityLog(
        id: 4,
        gearId: 1,
        memberId: 1,
        checkedOut: true,
        timestamp: DateTime(now.year, now.month, now.day - 2, 14, 0),
        note: 'For client meeting demo',
      ),
      ActivityLog(
        id: 5,
        gearId: 1,
        memberId: null,
        checkedOut: false,
        timestamp: DateTime(now.year, now.month, now.day - 1, 17, 45),
        note: 'Returned with full battery',
      ),
    ];
  }

  /// Sample status notes
  static List<StatusNote> getSampleStatusNotes() {
    final now = DateTime.now();

    return [
      StatusNote(
        id: 1,
        gearId: 2,
        note: 'Battery at 50%',
        timestamp: DateTime(now.year, now.month, now.day - 1, 17, 30),
      ),
      StatusNote(
        id: 2,
        gearId: 7,
        note: 'New SD card installed',
        timestamp: DateTime(now.year, now.month, now.day - 3, 11, 15),
      ),
      StatusNote(
        id: 3,
        gearId: 3,
        note: 'Needs calibration soon',
        timestamp: DateTime(now.year, now.month, now.day - 5, 9, 0),
      ),
    ];
  }
}
