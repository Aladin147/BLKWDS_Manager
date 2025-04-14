/// Gear Model
/// Represents equipment items in the studio inventory
class Gear {
  final int? id;
  final String name;
  final String category;
  final String? description;
  final String? serialNumber;
  final DateTime? purchaseDate;
  final String? thumbnailPath;
  final bool isOut;
  final String? lastNote;

  Gear({
    this.id,
    required this.name,
    required this.category,
    this.description,
    this.serialNumber,
    this.purchaseDate,
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
      description: map['description'] as String?,
      serialNumber: map['serialNumber'] as String?,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'] as String)
          : null,
      thumbnailPath: map['thumbnailPath'] as String?,
      isOut: (map['isOut'] as int) == 1,
      lastNote: map['lastNote'] as String?,
    );
  }

  /// Convert Gear object to a map (for database operations)
  Map<String, dynamic> toMap() {
    // Create a map with non-null values only
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'isOut': isOut ? 1 : 0,
    };

    // Only add non-null values
    if (id != null) map['id'] = id;
    if (description != null) map['description'] = description;
    if (serialNumber != null) map['serialNumber'] = serialNumber;
    if (purchaseDate != null) map['purchaseDate'] = purchaseDate!.toIso8601String();
    if (thumbnailPath != null) map['thumbnailPath'] = thumbnailPath;
    if (lastNote != null) map['lastNote'] = lastNote;

    return map;
  }

  /// Create a copy of this Gear with modified fields
  Gear copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? serialNumber,
    DateTime? purchaseDate,
    String? thumbnailPath,
    bool? isOut,
    String? lastNote,
  }) {
    return Gear(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isOut: isOut ?? this.isOut,
      lastNote: lastNote ?? this.lastNote,
    );
  }

  @override
  String toString() {
    return 'Gear(id: $id, name: $name, category: $category, serialNumber: $serialNumber, isOut: $isOut)';
  }
}
