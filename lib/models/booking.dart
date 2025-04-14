/// Booking Model
/// Represents a scheduled booking for gear and studio space
class Booking {
  final int? id;
  final int projectId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecordingStudio;
  final bool isProductionStudio;
  final List<int> gearIds;
  final Map<int, int>? assignedGearToMember; // {gearId: memberId}

  Booking({
    this.id,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    this.isRecordingStudio = false,
    this.isProductionStudio = false,
    this.gearIds = const [],
    this.assignedGearToMember,
  });

  /// Create a Booking object from a map (for database operations)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int,
      projectId: map['projectId'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isRecordingStudio: (map['isRecordingStudio'] as int) == 1,
      isProductionStudio: (map['isProductionStudio'] as int) == 1,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
      gearIds: const [],
      assignedGearToMember: {},
    );
  }

  /// Convert Booking object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isRecordingStudio': isRecordingStudio ? 1 : 0,
      'isProductionStudio': isProductionStudio ? 1 : 0,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
    };
  }

  /// Create a copy of this Booking with modified fields
  Booking copyWith({
    int? id,
    int? projectId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecordingStudio,
    bool? isProductionStudio,
    List<int>? gearIds,
    Map<int, int>? assignedGearToMember,
  }) {
    return Booking(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecordingStudio: isRecordingStudio ?? this.isRecordingStudio,
      isProductionStudio: isProductionStudio ?? this.isProductionStudio,
      gearIds: gearIds ?? this.gearIds,
      assignedGearToMember: assignedGearToMember ?? this.assignedGearToMember,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, projectId: $projectId, startDate: $startDate, endDate: $endDate)';
  }
}
