/// StatusNote Model
/// Represents notes about gear status
class StatusNote {
  final int? id;
  final int gearId;
  final String note;
  final DateTime timestamp;

  StatusNote({
    this.id,
    required this.gearId,
    required this.note,
    required this.timestamp,
  });

  /// Create a StatusNote object from a map (for database operations)
  factory StatusNote.fromMap(Map<String, dynamic> map) {
    return StatusNote(
      id: map['id'] as int,
      gearId: map['gearId'] as int,
      note: map['note'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Convert StatusNote object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gearId': gearId,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a copy of this StatusNote with modified fields
  StatusNote copyWith({
    int? id,
    int? gearId,
    String? note,
    DateTime? timestamp,
  }) {
    return StatusNote(
      id: id ?? this.id,
      gearId: gearId ?? this.gearId,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'StatusNote(id: $id, gearId: $gearId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusNote &&
        other.id == id &&
        other.gearId == gearId &&
        other.note == note &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      gearId.hashCode ^
      note.hashCode ^
      timestamp.hashCode;
}
