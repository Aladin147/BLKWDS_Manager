import 'member.dart';

/// ActivityLog Model
/// Represents a log entry for gear check-out or check-in
class ActivityLog {
  final int? id;
  final int gearId;
  final int? memberId;
  final bool checkedOut;
  final DateTime timestamp;
  final String? note;
  final Member? member;

  ActivityLog({
    this.id,
    required this.gearId,
    this.memberId,
    required this.checkedOut,
    required this.timestamp,
    this.note,
    this.member,
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
      // Member is loaded separately and attached later
      member: null,
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
    Member? member,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      gearId: gearId ?? this.gearId,
      memberId: memberId ?? this.memberId,
      checkedOut: checkedOut ?? this.checkedOut,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      member: member ?? this.member,
    );
  }

  @override
  String toString() {
    return 'ActivityLog(id: $id, gearId: $gearId, memberId: $memberId, checkedOut: $checkedOut, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityLog &&
        other.id == id &&
        other.gearId == gearId &&
        other.memberId == memberId &&
        other.checkedOut == checkedOut &&
        other.timestamp == timestamp &&
        other.note == note &&
        other.member == member;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      gearId.hashCode ^
      (memberId?.hashCode ?? 0) ^
      checkedOut.hashCode ^
      timestamp.hashCode ^
      (note?.hashCode ?? 0) ^
      (member?.hashCode ?? 0);
}
