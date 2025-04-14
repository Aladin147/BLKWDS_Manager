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
  final String? color; // Hex color code for visual identification

  Booking({
    this.id,
    required this.projectId,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecordingStudio: isRecordingStudio ?? this.isRecordingStudio,
      isProductionStudio: isProductionStudio ?? this.isProductionStudio,
      gearIds: gearIds ?? this.gearIds,
      assignedGearToMember: assignedGearToMember ?? this.assignedGearToMember,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, projectId: $projectId, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.projectId == projectId &&
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
      startDate.hashCode ^
      endDate.hashCode ^
      isRecordingStudio.hashCode ^
      isProductionStudio.hashCode ^
      color.hashCode;
}
