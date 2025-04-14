/// Gear Model
/// Represents equipment items in the studio inventory
class Gear {
  final int? id;
  final String name;
  final String category;
  final String? thumbnailPath;
  final bool isOut;
  final String? lastNote;

  Gear({
    this.id,
    required this.name,
    required this.category,
    this.thumbnailPath,
    this.isOut = false,
    this.lastNote,
  });

  /// Create a Gear object from a map (for database operations)
  factory Gear.fromMap(Map<String, dynamic> map) {
    return Gear(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      thumbnailPath: map['thumbnailPath'] as String?,
      isOut: (map['isOut'] as int) == 1,
      lastNote: map['lastNote'] as String?,
    );
  }

  /// Convert Gear object to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'thumbnailPath': thumbnailPath,
      'isOut': isOut ? 1 : 0,
      'lastNote': lastNote,
    };
  }

  /// Create a copy of this Gear with modified fields
  Gear copyWith({
    int? id,
    String? name,
    String? category,
    String? thumbnailPath,
    bool? isOut,
    String? lastNote,
  }) {
    return Gear(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isOut: isOut ?? this.isOut,
      lastNote: lastNote ?? this.lastNote,
    );
  }

  @override
  String toString() {
    return 'Gear(id: $id, name: $name, category: $category, isOut: $isOut)';
  }
}
