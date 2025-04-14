/// Project Model
/// Represents a production project that can have bookings
class Project {
  final int? id;
  final String title;
  final String? client;
  final String? notes;
  final List<int> memberIds;

  Project({
    this.id,
    required this.title,
    this.client,
    this.notes,
    this.memberIds = const [],
  });

  /// Create a Project object from a map (for database operations)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int,
      title: map['title'] as String,
      client: map['client'] as String?,
      notes: map['notes'] as String?,
      // Member IDs are stored in a separate table, so they're not in the map
      memberIds: const [],
    );
  }

  /// Create a Project object from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int?,
      title: json['title'] as String,
      client: json['client'] as String?,
      notes: json['notes'] as String?,
      memberIds: json['memberIds'] != null
          ? List<int>.from(json['memberIds'] as List)
          : const [],
    );
  }

  /// Convert Project object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'client': client,
      'notes': notes,
      // Member IDs are stored in a separate table, so they're not in the map
    };
  }

  /// Convert Project object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'client': client,
      'notes': notes,
      'memberIds': memberIds,
    };
  }

  /// Create a copy of this Project with modified fields
  Project copyWith({
    int? id,
    String? title,
    String? client,
    String? notes,
    List<int>? memberIds,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      client: client ?? this.client,
      notes: notes ?? this.notes,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, client: $client, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.title == title &&
        other.client == client &&
        other.notes == notes &&
        _listEquals(other.memberIds, memberIds);
  }

  // Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      (client?.hashCode ?? 0) ^
      (notes?.hashCode ?? 0) ^
      memberIds.fold(0, (hash, id) => hash ^ id.hashCode);


}
