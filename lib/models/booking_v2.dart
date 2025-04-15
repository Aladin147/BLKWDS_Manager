/// BookingV2 Model
/// Represents a scheduled booking for gear and studio space
/// This is an updated version that uses studio IDs instead of boolean flags
class BookingV2 {
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

  BookingV2({
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

  /// Create a BookingV2 object from a map (for database operations)
  factory BookingV2.fromMap(Map<String, dynamic> map) {
    return BookingV2(
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

  /// Create a BookingV2 object from JSON
  factory BookingV2.fromJson(Map<String, dynamic> json) {
    Map<int, int>? assignments;
    if (json['assignedGearToMember'] != null) {
      assignments = {};
      final Map<String, dynamic> assignMap = json['assignedGearToMember'] as Map<String, dynamic>;
      assignMap.forEach((key, value) {
        assignments![int.parse(key)] = value as int;
      });
    }

    return BookingV2(
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

  /// Convert BookingV2 object to a map (for database operations)
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

  /// Convert BookingV2 object to JSON
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

  /// Create a copy of this BookingV2 with modified fields
  BookingV2 copyWith({
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
    return BookingV2(
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

  /// Convert from Booking to BookingV2
  factory BookingV2.fromBooking(Booking booking) {
    return BookingV2(
      id: booking.id,
      projectId: booking.projectId,
      title: booking.title,
      startDate: booking.startDate,
      endDate: booking.endDate,
      studioId: null, // No studio ID in the original booking
      gearIds: booking.gearIds,
      assignedGearToMember: booking.assignedGearToMember,
      color: booking.color,
      notes: null, // No notes in the original booking
    );
  }

  @override
  String toString() {
    return 'BookingV2(id: $id, projectId: $projectId, title: $title, startDate: $startDate, endDate: $endDate, studioId: $studioId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingV2 &&
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

/// Original Booking Model
/// Kept for backward compatibility
class Booking {
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

  Booking({
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

  /// Create a Booking object from a map (for database operations)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int,
      projectId: map['projectId'] as int,
      title: map['title'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isRecordingStudio: (map['isRecordingStudio'] as int) == 1,
      isProductionStudio: (map['isProductionStudio'] as int) == 1,
      // Gear IDs and assignments are stored in a separate table, so they're not in the map
      gearIds: const [],
      assignedGearToMember: {},
      color: map['color'] as String?,
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
      isRecordingStudio: json['isRecordingStudio'] as bool,
      isProductionStudio: json['isProductionStudio'] as bool,
      gearIds: json['gearIds'] != null
          ? List<int>.from(json['gearIds'] as List)
          : const [],
      assignedGearToMember: assignments,
      color: json['color'] as String?,
    );
  }

  /// Convert Booking object to a map (for database operations)
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
    if (color != null) map['color'] = color;

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
      'isRecordingStudio': isRecordingStudio,
      'isProductionStudio': isProductionStudio,
      'gearIds': gearIds,
      'assignedGearToMember': assignments,
      'color': color,
    };
  }

  /// Create a copy of this Booking with modified fields
  Booking copyWith({
    int? id,
    int? projectId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecordingStudio,
    bool? isProductionStudio,
    List<int>? gearIds,
    Map<int, int>? assignedGearToMember,
    String? color,
  }) {
    return Booking(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecordingStudio: isRecordingStudio ?? this.isRecordingStudio,
      isProductionStudio: isProductionStudio ?? this.isProductionStudio,
      gearIds: gearIds ?? this.gearIds,
      assignedGearToMember: assignedGearToMember ?? this.assignedGearToMember,
      color: color ?? this.color,
    );
  }

  /// Convert to BookingV2
  BookingV2 toBookingV2() {
    return BookingV2.fromBooking(this);
  }

  @override
  String toString() {
    return 'Booking(id: $id, projectId: $projectId, title: $title, startDate: $startDate, endDate: $endDate)';
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
        other.isRecordingStudio == isRecordingStudio &&
        other.isProductionStudio == isProductionStudio &&
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
      color.hashCode;
}
