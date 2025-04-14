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
}
