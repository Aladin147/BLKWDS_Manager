/// DEPRECATED: Legacy Booking Model
/// This file is kept for reference only and should not be used.
/// Use the Booking class from booking_v2.dart instead.
///
/// This model represents a scheduled booking for gear and studio space
/// using both boolean flags and studioId, which is inconsistent.
@Deprecated('Use Booking from booking_v2.dart instead')
class BookingLegacy {
  final int? id;
  final int projectId;
  final String? title;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecordingStudio;
  final bool isProductionStudio;
  final int? studioId; // ID of the studio for this booking
  final String? notes; // Additional notes for the booking
  final List<int> gearIds;
  final Map<int, int>? assignedGearToMember; // {gearId: memberId}
  final String? color; // Hex color code for visual identification

  BookingLegacy({
    this.id,
    required this.projectId,
    this.title,
    required this.startDate,
    required this.endDate,
    this.isRecordingStudio = false,
    this.isProductionStudio = false,
    this.studioId,
    this.notes,
    this.gearIds = const [],
    this.assignedGearToMember,
    this.color,
  });

  /// Create a BookingLegacy object from a map (for database operations)
  factory BookingLegacy.fromMap(Map<String, dynamic> map) {
    return BookingLegacy(
      id: map['id'] as int,
      projectId: map['projectId'] as int,
      title: map['title'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isRecordingStudio: (map['isRecordingStudio'] as int) == 1,
      isProductionStudio: (map['isProductionStudio'] as int) == 1,
      studioId: map['studioId'] as int?,
      notes: map['notes'] as String?,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
      gearIds: const [],
      assignedGearToMember: {},
      color: map['color'] as String?,
    );
  }

  /// Create a BookingLegacy object from JSON
  factory BookingLegacy.fromJson(Map<String, dynamic> json) {
    Map<int, int>? assignments;
    if (json['assignedGearToMember'] != null) {
      assignments = {};
      final Map<String, dynamic> assignMap = json['assignedGearToMember'] as Map<String, dynamic>;
      assignMap.forEach((key, value) {
        assignments![int.parse(key)] = value as int;
      });
    }

    return BookingLegacy(
      id: json['id'] as int?,
      projectId: json['projectId'] as int,
      title: json['title'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isRecordingStudio: json['isRecordingStudio'] as bool,
      isProductionStudio: json['isProductionStudio'] as bool,
      studioId: json['studioId'] as int?,
      notes: json['notes'] as String?,
      gearIds: json['gearIds'] != null
          ? List<int>.from(json['gearIds'] as List)
          : const [],
      assignedGearToMember: assignments,
      color: json['color'] as String?,
    );
  }

  /// Convert BookingLegacy object to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'projectId': projectId,
      if (title != null) 'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isRecordingStudio': isRecordingStudio ? 1 : 0,
      'isProductionStudio': isProductionStudio ? 1 : 0,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
    };

    // Only add non-null values
    if (id != null) map['id'] = id;
    if (studioId != null) map['studioId'] = studioId;
    if (notes != null) map['notes'] = notes;
    if (color != null) map['color'] = color;

    return map;
  }

  /// Convert BookingLegacy object to JSON
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
      'isRecordingStudio': isRecordingStudio,
      'isProductionStudio': isProductionStudio,
      'studioId': studioId,
      'notes': notes,
      'gearIds': gearIds,
      'assignedGearToMember': assignments,
      'color': color,
    };
  }

  /// Create a copy of this BookingLegacy with modified fields
  BookingLegacy copyWith({
    int? id,
    int? projectId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecordingStudio,
    bool? isProductionStudio,
    int? studioId,
    String? notes,
    List<int>? gearIds,
    Map<int, int>? assignedGearToMember,
    String? color,
  }) {
    return BookingLegacy(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecordingStudio: isRecordingStudio ?? this.isRecordingStudio,
      isProductionStudio: isProductionStudio ?? this.isProductionStudio,
      studioId: studioId ?? this.studioId,
      notes: notes ?? this.notes,
      gearIds: gearIds ?? this.gearIds,
      assignedGearToMember: assignedGearToMember ?? this.assignedGearToMember,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'BookingLegacy(id: $id, projectId: $projectId, title: $title, startDate: $startDate, endDate: $endDate, studioId: $studioId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingLegacy &&
        other.id == id &&
        other.projectId == projectId &&
        other.title == title &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isRecordingStudio == isRecordingStudio &&
        other.isProductionStudio == isProductionStudio &&
        other.studioId == studioId &&
        other.notes == notes &&
        other.color == color;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      title.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isRecordingStudio.hashCode ^
      isProductionStudio.hashCode ^
      studioId.hashCode ^
      notes.hashCode ^
      color.hashCode;
}
