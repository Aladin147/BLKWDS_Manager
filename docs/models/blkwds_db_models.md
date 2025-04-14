// BLKWDS Manager — Data Models and DB Schema (using SQLite-friendly Dart models)

class Gear {
  final int id;
  final String name;
  final String category;
  final String? thumbnailPath;
  final bool isOut;
  final String? lastNote;

  Gear({
    required this.id,
    required this.name,
    required this.category,
    this.thumbnailPath,
    this.isOut = false,
    this.lastNote,
  });
}

class Member {
  final int id;
  final String name;
  final String? role;
  // Note: email and phone fields were removed to match database schema

  Member({
    required this.id,
    required this.name,
    this.role,
  });
}

class Project {
  final int id;
  final String title;
  final String? client;
  final String? notes;
  // Note: description field was removed to match database schema
  final List<int> memberIds;

  Project({
    required this.id,
    required this.title,
    this.client,
    this.notes,
    this.memberIds = const [],
  });
}

class Booking {
  final int id;
  final int projectId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecordingStudio;
  final bool isProductionStudio;
  final List<int> gearIds;
  final Map<int, int>? assignedGearToMember; // {gearId: memberId}

  Booking({
    required this.id,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    this.isRecordingStudio = false,
    this.isProductionStudio = false,
    this.gearIds = const [],
    this.assignedGearToMember,
  });
}

class StatusNote {
  final int id;
  final int gearId;
  final String note;
  final DateTime timestamp;

  StatusNote({
    required this.id,
    required this.gearId,
    required this.note,
    required this.timestamp,
  });
}

class ActivityLog {
  final int id;
  final int gearId;
  final int? memberId;
  final bool checkedOut;
  final DateTime timestamp;
  final String? note;

  ActivityLog({
    required this.id,
    required this.gearId,
    this.memberId,
    required this.checkedOut,
    required this.timestamp,
    this.note,
  });
}
