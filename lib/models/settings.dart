/// Settings Model
/// Represents application settings stored in the database
class Settings {
  final int? id;
  final String key;
  final String value;

  Settings({
    this.id,
    required this.key,
    required this.value,
  });

  /// Create a Settings object from a map (for database operations)
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int,
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }

  /// Create a Settings object from JSON
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'] as int?,
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  /// Convert Settings object to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'key': key,
      'value': value,
    };
    
    // Only add non-null values
    if (id != null) map['id'] = id;
    
    return map;
  }

  /// Convert Settings object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
    };
  }

  /// Create a copy of this Settings with modified fields
  Settings copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return Settings(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'Settings(id: $id, key: $key, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.id == id &&
        other.key == key &&
        other.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode ^ value.hashCode;
}
