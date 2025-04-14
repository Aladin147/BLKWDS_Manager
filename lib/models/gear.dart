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

  /// Create a Gear object from JSON
  factory Gear.fromJson(Map<String, dynamic> json) {
    return Gear(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      serialNumber: json['serialNumber'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      thumbnailPath: json['thumbnailPath'] as String?,
      isOut: json['isOut'] as bool,
      lastNote: json['lastNote'] as String?,
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

  /// Convert Gear object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'serialNumber': serialNumber,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'isOut': isOut,
      'lastNote': lastNote,
    };
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gear &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.description == description &&
        other.serialNumber == serialNumber &&
        other.purchaseDate == purchaseDate &&
        other.thumbnailPath == thumbnailPath &&
        other.isOut == isOut &&
        other.lastNote == lastNote;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      (description?.hashCode ?? 0) ^
      (serialNumber?.hashCode ?? 0) ^
      (purchaseDate?.hashCode ?? 0) ^
      (thumbnailPath?.hashCode ?? 0) ^
      isOut.hashCode ^
      (lastNote?.hashCode ?? 0);
}
