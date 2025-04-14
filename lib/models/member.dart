/// Member Model
/// Represents team members who can check out gear
class Member {
  final int? id;
  final String name;
  final String? role;

  Member({
    this.id,
    required this.name,
    this.role,
  });

  /// Create a Member object from a map (for database operations)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int,
      name: map['name'] as String,
      role: map['role'] as String?,
    );
  }

  /// Convert Member object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  /// Create a copy of this Member with modified fields
  Member copyWith({
    int? id,
    String? name,
    String? role,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, role: $role)';
  }

  // TODO: Fix equality comparison for Member class
  // This implementation doesn't seem to fully resolve the dropdown assertion error
  // Need to investigate further why the dropdown still has issues with equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member &&
        other.id == id &&
        other.name == name &&
        other.role == role;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ (role?.hashCode ?? 0);
}
