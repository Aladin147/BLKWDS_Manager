import 'package:flutter/material.dart';

/// StudioType
/// Enum for studio types
enum StudioType {
  recording('Recording'),
  production('Production'),
  hybrid('Hybrid');

  final String label;
  const StudioType(this.label);

  /// Get the icon for this studio type
  IconData get icon {
    switch (this) {
      case StudioType.recording:
        return Icons.mic;
      case StudioType.production:
        return Icons.videocam;
      case StudioType.hybrid:
        return Icons.dashboard;
    }
  }
}

/// StudioStatus
/// Enum for studio status
enum StudioStatus {
  available('Available'),
  booked('Booked'),
  maintenance('Maintenance'),
  unavailable('Unavailable');

  final String label;
  const StudioStatus(this.label);

  /// Get the color for this status
  Color get color {
    switch (this) {
      case StudioStatus.available:
        return Colors.green;
      case StudioStatus.booked:
        return Colors.orange;
      case StudioStatus.maintenance:
        return Colors.red;
      case StudioStatus.unavailable:
        return Colors.grey;
    }
  }
}

/// Studio
/// Model class for studio spaces
class Studio {
  /// Unique ID for the studio
  final int? id;
  
  /// Name of the studio
  final String name;
  
  /// Type of studio
  final StudioType type;
  
  /// Description of the studio
  final String? description;
  
  /// Features/equipment in the studio
  final List<String> features;
  
  /// Hourly rate for the studio (optional)
  final double? hourlyRate;
  
  /// Status of the studio
  final StudioStatus status;
  
  /// Color for visual identification
  final String? color;
  
  /// Constructor
  const Studio({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.features = const [],
    this.hourlyRate,
    this.status = StudioStatus.available,
    this.color,
  });
  
  /// Create a Studio object from a map (for database operations)
  factory Studio.fromMap(Map<String, dynamic> map) {
    return Studio(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: StudioType.values.firstWhere(
        (e) => e.name == (map['type'] as String),
        orElse: () => StudioType.recording,
      ),
      description: map['description'] as String?,
      features: map['features'] != null
          ? (map['features'] as String).split(',').where((f) => f.isNotEmpty).toList()
          : [],
      hourlyRate: map['hourlyRate'] != null ? (map['hourlyRate'] as num).toDouble() : null,
      status: StudioStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => StudioStatus.available,
      ),
      color: map['color'] as String?,
    );
  }
  
  /// Convert Studio object to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'type': type.name,
      'status': status.name,
    };
    
    // Add optional fields if they exist
    if (id != null) map['id'] = id;
    if (description != null) map['description'] = description;
    if (features.isNotEmpty) map['features'] = features.join(',');
    if (hourlyRate != null) map['hourlyRate'] = hourlyRate;
    if (color != null) map['color'] = color;
    
    return map;
  }
  
  /// Create a copy of this Studio with modified fields
  Studio copyWith({
    int? id,
    String? name,
    StudioType? type,
    String? description,
    List<String>? features,
    double? hourlyRate,
    StudioStatus? status,
    String? color,
  }) {
    return Studio(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      features: features ?? this.features,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      color: color ?? this.color,
    );
  }
  
  @override
  String toString() {
    return 'Studio(id: $id, name: $name, type: ${type.name})';
  }
}
