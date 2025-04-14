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
    return 'Project(id: $id, title: $title, client: $client)';
  }
}
