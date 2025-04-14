/// Member Model
/// Represents team members who can check out gear
class Member {
  final int? id;
  final String name;
  final String? role;
  final String? email;
  final String? phone;

  Member({
    this.id,
    required this.name,
    this.role,
    this.email,
    this.phone,
  });

  /// Create a Member object from a map (for database operations)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int,
      name: map['name'] as String,
      role: map['role'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
    );
  }

  /// Create a Member object from JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int?,
      name: json['name'] as String,
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  /// Convert Member object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
    };
  }

  /// Convert Member object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
    };
  }

  /// Create a copy of this Member with modified fields
  Member copyWith({
    int? id,
    String? name,
    String? role,
    String? email,
    String? phone,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, role: $role, email: $email, phone: $phone)';
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
        other.role == role &&
        other.email == email &&
        other.phone == phone;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ (role?.hashCode ?? 0) ^ (email?.hashCode ?? 0) ^ (phone?.hashCode ?? 0);
}
