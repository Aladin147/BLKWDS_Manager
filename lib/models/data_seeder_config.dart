import 'package:flutter/foundation.dart';

/// DataSeederVolumeType
/// Enum for data seeder volume types
enum DataSeederVolumeType {
  /// Minimal data set (1-2 of each entity)
  minimal,
  
  /// Standard data set (5-10 of each entity)
  standard,
  
  /// Comprehensive data set (20+ of each entity)
  comprehensive,
}

/// DataSeederRandomizationType
/// Enum for data seeder randomization types
enum DataSeederRandomizationType {
  /// Fixed data (same data every time)
  fixed,
  
  /// Semi-randomized data (fixed structure with some randomization)
  semiRandomized,
  
  /// Fully randomized data (completely random data)
  fullyRandomized,
}

/// DataSeederConfig
/// Configuration options for the data seeder
class DataSeederConfig {
  /// Whether to seed members
  final bool seedMembers;
  
  /// Whether to seed gear
  final bool seedGear;
  
  /// Whether to seed projects
  final bool seedProjects;
  
  /// Whether to seed bookings
  final bool seedBookings;
  
  /// Whether to seed activity logs
  final bool seedActivityLogs;
  
  /// Whether to seed studios
  final bool seedStudios;
  
  /// The volume of data to seed
  final DataSeederVolumeType volumeType;
  
  /// The type of randomization to use
  final DataSeederRandomizationType randomizationType;
  
  /// Whether to include future data (e.g., future bookings)
  final bool includeFutureData;
  
  /// Whether to include past data (e.g., past bookings)
  final bool includePastData;
  
  /// Whether to seed the database on first run
  final bool seedOnFirstRun;
  
  /// Constructor
  const DataSeederConfig({
    this.seedMembers = true,
    this.seedGear = true,
    this.seedProjects = true,
    this.seedBookings = true,
    this.seedActivityLogs = true,
    this.seedStudios = true,
    this.volumeType = DataSeederVolumeType.standard,
    this.randomizationType = DataSeederRandomizationType.semiRandomized,
    this.includeFutureData = true,
    this.includePastData = true,
    this.seedOnFirstRun = true,
  });
  
  /// Create a copy with updated values
  DataSeederConfig copyWith({
    bool? seedMembers,
    bool? seedGear,
    bool? seedProjects,
    bool? seedBookings,
    bool? seedActivityLogs,
    bool? seedStudios,
    DataSeederVolumeType? volumeType,
    DataSeederRandomizationType? randomizationType,
    bool? includeFutureData,
    bool? includePastData,
    bool? seedOnFirstRun,
  }) {
    return DataSeederConfig(
      seedMembers: seedMembers ?? this.seedMembers,
      seedGear: seedGear ?? this.seedGear,
      seedProjects: seedProjects ?? this.seedProjects,
      seedBookings: seedBookings ?? this.seedBookings,
      seedActivityLogs: seedActivityLogs ?? this.seedActivityLogs,
      seedStudios: seedStudios ?? this.seedStudios,
      volumeType: volumeType ?? this.volumeType,
      randomizationType: randomizationType ?? this.randomizationType,
      includeFutureData: includeFutureData ?? this.includeFutureData,
      includePastData: includePastData ?? this.includePastData,
      seedOnFirstRun: seedOnFirstRun ?? this.seedOnFirstRun,
    );
  }
  
  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'seedMembers': seedMembers,
      'seedGear': seedGear,
      'seedProjects': seedProjects,
      'seedBookings': seedBookings,
      'seedActivityLogs': seedActivityLogs,
      'seedStudios': seedStudios,
      'volumeType': volumeType.index,
      'randomizationType': randomizationType.index,
      'includeFutureData': includeFutureData,
      'includePastData': includePastData,
      'seedOnFirstRun': seedOnFirstRun,
    };
  }
  
  /// Create from a map
  factory DataSeederConfig.fromMap(Map<String, dynamic> map) {
    return DataSeederConfig(
      seedMembers: map['seedMembers'] ?? true,
      seedGear: map['seedGear'] ?? true,
      seedProjects: map['seedProjects'] ?? true,
      seedBookings: map['seedBookings'] ?? true,
      seedActivityLogs: map['seedActivityLogs'] ?? true,
      seedStudios: map['seedStudios'] ?? true,
      volumeType: DataSeederVolumeType.values[map['volumeType'] ?? 1],
      randomizationType: DataSeederRandomizationType.values[map['randomizationType'] ?? 1],
      includeFutureData: map['includeFutureData'] ?? true,
      includePastData: map['includePastData'] ?? true,
      seedOnFirstRun: map['seedOnFirstRun'] ?? true,
    );
  }
  
  /// Minimal preset
  static DataSeederConfig minimal() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.minimal,
      randomizationType: DataSeederRandomizationType.fixed,
    );
  }
  
  /// Standard preset
  static DataSeederConfig standard() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.standard,
      randomizationType: DataSeederRandomizationType.semiRandomized,
    );
  }
  
  /// Comprehensive preset
  static DataSeederConfig comprehensive() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.comprehensive,
      randomizationType: DataSeederRandomizationType.fullyRandomized,
    );
  }
  
  /// Demo preset
  static DataSeederConfig demo() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.standard,
      randomizationType: DataSeederRandomizationType.fixed,
      includeFutureData: true,
      includePastData: true,
    );
  }
  
  /// Testing preset
  static DataSeederConfig testing() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.comprehensive,
      randomizationType: DataSeederRandomizationType.fullyRandomized,
      includeFutureData: true,
      includePastData: true,
    );
  }
  
  /// Development preset
  static DataSeederConfig development() {
    return const DataSeederConfig(
      volumeType: DataSeederVolumeType.minimal,
      randomizationType: DataSeederRandomizationType.fixed,
      includeFutureData: true,
      includePastData: true,
    );
  }
  
  /// Empty preset (no data)
  static DataSeederConfig empty() {
    return const DataSeederConfig(
      seedMembers: false,
      seedGear: false,
      seedProjects: false,
      seedBookings: false,
      seedActivityLogs: false,
      seedStudios: false,
      seedOnFirstRun: false,
    );
  }
  
  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DataSeederConfig &&
      other.seedMembers == seedMembers &&
      other.seedGear == seedGear &&
      other.seedProjects == seedProjects &&
      other.seedBookings == seedBookings &&
      other.seedActivityLogs == seedActivityLogs &&
      other.seedStudios == seedStudios &&
      other.volumeType == volumeType &&
      other.randomizationType == randomizationType &&
      other.includeFutureData == includeFutureData &&
      other.includePastData == includePastData &&
      other.seedOnFirstRun == seedOnFirstRun;
  }
  
  /// Hash code
  @override
  int get hashCode {
    return seedMembers.hashCode ^
      seedGear.hashCode ^
      seedProjects.hashCode ^
      seedBookings.hashCode ^
      seedActivityLogs.hashCode ^
      seedStudios.hashCode ^
      volumeType.hashCode ^
      randomizationType.hashCode ^
      includeFutureData.hashCode ^
      includePastData.hashCode ^
      seedOnFirstRun.hashCode;
  }
  
  /// String representation
  @override
  String toString() {
    return 'DataSeederConfig(seedMembers: $seedMembers, seedGear: $seedGear, seedProjects: $seedProjects, seedBookings: $seedBookings, seedActivityLogs: $seedActivityLogs, seedStudios: $seedStudios, volumeType: $volumeType, randomizationType: $randomizationType, includeFutureData: $includeFutureData, includePastData: $includePastData, seedOnFirstRun: $seedOnFirstRun)';
  }
}
