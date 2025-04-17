import 'package:blkwds_manager/models/models.dart';

/// A helper class for generating test data
class TestData {
  /// Create a test gear item
  ///
  /// [id] is the ID of the gear item.
  /// [name] is the name of the gear item.
  /// [category] is the category of the gear item.
  /// [isOut] indicates if the gear is checked out.
  static Gear createTestGear({
    int? id,
    String name = 'Test Gear',
    String category = 'Camera',
    bool isOut = false,
    String? description,
    String? serialNumber,
    DateTime? purchaseDate,
    String? thumbnailPath,
    String? lastNote,
  }) {
    return Gear(
      id: id,
      name: name,
      category: category,
      isOut: isOut,
      description: description,
      serialNumber: serialNumber,
      purchaseDate: purchaseDate,
      thumbnailPath: thumbnailPath,
      lastNote: lastNote,
    );
  }

  /// Create a test member
  ///
  /// [id] is the ID of the member.
  /// [name] is the name of the member.
  /// [role] is the role of the member.
  static Member createTestMember({
    int? id,
    String name = 'Test Member',
    String? role,
  }) {
    return Member(
      id: id,
      name: name,
      role: role,
    );
  }

  /// Create a test project
  ///
  /// [id] is the ID of the project.
  /// [title] is the title of the project.
  /// [client] is the client of the project.
  /// [notes] are notes about the project.
  /// [memberIds] are the IDs of members associated with the project.
  static Project createTestProject({
    int? id,
    String title = 'Test Project',
    String? client,
    String? notes,
    List<int> memberIds = const [],
  }) {
    return Project(
      id: id,
      title: title,
      client: client,
      notes: notes,
      memberIds: memberIds,
    );
  }

  /// Create a test studio
  ///
  /// [id] is the ID of the studio.
  /// [name] is the name of the studio.
  /// [type] is the type of studio.
  static Studio createTestStudio({
    int? id,
    String name = 'Test Studio',
    StudioType type = StudioType.recording,
  }) {
    return Studio(
      id: id,
      name: name,
      type: type,
    );
  }

  /// Create a test booking
  ///
  /// [id] is the ID of the booking.
  /// [projectId] is the ID of the associated project.
  /// [studioId] is the ID of the associated studio.
  /// [startDate] is the start date of the booking.
  /// [endDate] is the end date of the booking.
  /// [notes] are notes about the booking.
  static Booking createTestBooking({
    int? id,
    required int projectId,
    int? studioId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return Booking(
      id: id,
      projectId: projectId,
      studioId: studioId,
      startDate: startDate ?? now,
      endDate: endDate ?? now.add(const Duration(hours: 2)),
      notes: notes,
    );
  }

  // Note: BookingGear is no longer a separate model class
  // Gear assignments are now handled through the Booking model's assignedGearToMember map

  /// Create a test status note
  ///
  /// [id] is the ID of the status note.
  /// [gearId] is the ID of the associated gear.
  /// [note] is the content of the note.
  /// [timestamp] is when the note was created.
  static StatusNote createTestStatusNote({
    int? id,
    required int gearId,
    String note = 'Test Note',
    DateTime? timestamp,
  }) {
    return StatusNote(
      id: id,
      gearId: gearId,
      note: note,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a test activity log
  ///
  /// [id] is the ID of the activity log.
  /// [gearId] is the ID of the associated gear.
  /// [memberId] is the ID of the associated member.
  /// [checkedOut] indicates if the gear was checked out.
  /// [timestamp] is when the activity occurred.
  /// [note] is a note about the activity.
  static ActivityLog createTestActivityLog({
    int? id,
    required int gearId,
    int? memberId,
    bool checkedOut = true,
    DateTime? timestamp,
    String? note,
  }) {
    return ActivityLog(
      id: id,
      gearId: gearId,
      memberId: memberId,
      checkedOut: checkedOut,
      timestamp: timestamp ?? DateTime.now(),
      note: note,
    );
  }
}
