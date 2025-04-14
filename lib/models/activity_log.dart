/// ActivityLog Model
/// Represents a log entry for gear check-out or check-in
class ActivityLog {
  final int? id;
  final int gearId;
  final int? memberId;
  final bool checkedOut;
  final DateTime timestamp;
  final String? note;

  ActivityLog({
    this.id,
    required this.gearId,
    this.memberId,
    required this.checkedOut,
    required this.timestamp,
    this.note,
  });

  /// Create an ActivityLog object from a map (for database operations)
  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as int,
      gearId: map['gearId'] as int,
      memberId: map['memberId'] as int?,
      checkedOut: (map['checkedOut'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      note: map['note'] as String?,
    );
  }

  /// Convert ActivityLog object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gearId': gearId,
      'memberId': memberId,
      'checkedOut': checkedOut ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  /// Create a copy of this ActivityLog with modified fields
  ActivityLog copyWith({
    int? id,
    int? gearId,
    int? memberId,
    bool? checkedOut,
    DateTime? timestamp,
    String? note,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      gearId: gearId ?? this.gearId,
      memberId: memberId ?? this.memberId,
      checkedOut: checkedOut ?? this.checkedOut,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'ActivityLog(id: $id, gearId: $gearId, memberId: $memberId, checkedOut: $checkedOut, timestamp: $timestamp)';
  }
}
