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

  /// Create a Member object from JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int?,
      name: json['name'] as String,
      role: json['role'] as String?,
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

  /// Convert Member object to JSON
  Map<String, dynamic> toJson() {
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

  // Fixed equality comparison for Member class
  // This implementation should resolve dropdown equality issues
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Member) return false;

    // For dropdown equality, we primarily care about the ID
    // If both IDs are null, compare other fields
    if (id == null && other.id == null) {
      return other.name == name &&
          other.role == role;
    }

    // If IDs are available, use them for equality
    return other.id == id;
  }

  @override
  int get hashCode {
    // For consistent hashing with our equality implementation
    if (id != null) {
      return id.hashCode;
    }
    return name.hashCode ^
        (role?.hashCode ?? 0);
  }
}
