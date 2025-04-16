/// Booking Model
/// Represents a scheduled booking for gear and studio space
/// Uses studio IDs instead of boolean flags
class Booking {
  final int? id;
  final int projectId;
  final String? title;
  final DateTime startDate;
  final DateTime endDate;
  final int? studioId; // Reference to a Studio object
  final List<int> gearIds;
  final Map<int, int>? assignedGearToMember; // {gearId: memberId}
  final String? color; // Hex color code for visual identification
  final String? notes; // Additional notes for the booking

  // Legacy compatibility getters
  bool get isRecordingStudio => studioId == 1; // Recording studio has ID 1
  bool get isProductionStudio => studioId == 2; // Production studio has ID 2

  // For compatibility with code that checks for null
  bool? get isRecordingStudioOrNull => studioId == 1 ? true : false;
  bool? get isProductionStudioOrNull => studioId == 2 ? true : false;

  Booking({
    this.id,
    required this.projectId,
    this.title,
    required this.startDate,
    required this.endDate,
    this.studioId,
    this.gearIds = const [],
    this.assignedGearToMember,
    this.color,
    this.notes,
  });

  /// Create a Booking object from a map (for database operations)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int,
      projectId: map['projectId'] as int,
      title: map['title'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      studioId: map['studioId'] as int?,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
      gearIds: const [],
      assignedGearToMember: {},
      color: map['color'] as String?,
      notes: map['notes'] as String?,
    );
  }

  /// Create a Booking object from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    Map<int, int>? assignments;
    if (json['assignedGearToMember'] != null) {
      assignments = {};
      final Map<String, dynamic> assignMap = json['assignedGearToMember'] as Map<String, dynamic>;
      assignMap.forEach((key, value) {
        assignments![int.parse(key)] = value as int;
      });
    }

    return Booking(
      id: json['id'] as int?,
      projectId: json['projectId'] as int,
      title: json['title'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      studioId: json['studioId'] as int?,
      gearIds: json['gearIds'] != null
          ? List<int>.from(json['gearIds'] as List)
          : const [],
      assignedGearToMember: assignments,
      color: json['color'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert Booking object to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'projectId': projectId,
      if (title != null) 'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
    };

    // Only add non-null values
    if (id != null) map['id'] = id;
    if (studioId != null) map['studioId'] = studioId;
    if (color != null) map['color'] = color;
    if (notes != null) map['notes'] = notes;

    return map;
  }

  /// Convert Booking object to JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic>? assignments;
    if (assignedGearToMember != null) {
      assignments = {};
      assignedGearToMember!.forEach((gearId, memberId) {
        assignments![gearId.toString()] = memberId;
      });
    }

    return {
      'id': id,
      'projectId': projectId,
      if (title != null) 'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'studioId': studioId,
      'gearIds': gearIds,
      'assignedGearToMember': assignments,
      'color': color,
      'notes': notes,
    };
  }

  /// Create a copy of this Booking with modified fields
  Booking copyWith({
    int? id,
    int? projectId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? studioId,
    List<int>? gearIds,
    Map<int, int>? assignedGearToMember,
    String? color,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      studioId: studioId ?? this.studioId,
      gearIds: gearIds ?? this.gearIds,
      assignedGearToMember: assignedGearToMember ?? this.assignedGearToMember,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }



  @override
  String toString() {
    return 'Booking(id: $id, projectId: $projectId, title: $title, startDate: $startDate, endDate: $endDate, studioId: $studioId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.projectId == projectId &&
        other.title == title &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.studioId == studioId &&
        other.color == color &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      title.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      studioId.hashCode ^
      color.hashCode ^
      notes.hashCode;
}

/// BookingV2 is now an alias for Booking
typedef BookingV2 = Booking;

/// Legacy Booking Model
/// This class is kept for reference only and should not be used
class LegacyBooking {
  final int? id;
  final int projectId;
  final String? title;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecordingStudio;
  final bool isProductionStudio;
  final List<int> gearIds;
  final Map<int, int>? assignedGearToMember; // {gearId: memberId}
  final String? color; // Hex color code for visual identification

  LegacyBooking({
    this.id,
    required this.projectId,
    this.title,
    required this.startDate,
    required this.endDate,
    this.isRecordingStudio = false,
    this.isProductionStudio = false,
    this.gearIds = const [],
    this.assignedGearToMember,
    this.color,
  });
}
