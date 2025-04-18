import 'package:flutter/material.dart';
import '../services/version_service.dart';
import '../config/environment_config.dart';

/// AppConfig
/// Centralized configuration for the application
class AppConfig {
  /// Database configuration
  final DatabaseConfig database;

  /// Studio configuration
  final StudioConfig studio;

  /// UI configuration
  final UIConfig ui;

  /// App information
  final AppInfo appInfo;

  /// Data seeder configuration
  final DataSeederDefaults dataSeeder;

  /// Constructor
  const AppConfig({
    this.database = const DatabaseConfig(),
    this.studio = const StudioConfig(),
    this.ui = const UIConfig(),
    this.appInfo = const AppInfo(),
    this.dataSeeder = const DataSeederDefaults(),
  });

  /// Create a copy with modified fields
  AppConfig copyWith({
    DatabaseConfig? database,
    StudioConfig? studio,
    UIConfig? ui,
    AppInfo? appInfo,
    DataSeederDefaults? dataSeeder,
  }) {
    return AppConfig(
      database: database ?? this.database,
      studio: studio ?? this.studio,
      ui: ui ?? this.ui,
      appInfo: appInfo ?? this.appInfo,
      dataSeeder: dataSeeder ?? this.dataSeeder,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'database': database.toMap(),
      'studio': studio.toMap(),
      'ui': ui.toMap(),
      'appInfo': appInfo.toMap(),
      'dataSeeder': dataSeeder.toMap(),
    };
  }

  /// Create from a map
  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      database: DatabaseConfig.fromMap(map['database'] ?? {}),
      studio: StudioConfig.fromMap(map['studio'] ?? {}),
      ui: UIConfig.fromMap(map['ui'] ?? {}),
      appInfo: AppInfo.fromMap(map['appInfo'] ?? {}),
      dataSeeder: DataSeederDefaults.fromMap(map['dataSeeder'] ?? {}),
    );
  }

  /// Default configuration
  static AppConfig get defaults {
    // Create environment-specific configuration
    final dataSeeder = DataSeederDefaults(
      // Disable data seeding in production environment
      enableDataSeeding: !EnvironmentConfig.isProduction,
    );

    return AppConfig(
      database: const DatabaseConfig(),
      studio: const StudioConfig(),
      ui: const UIConfig(),
      appInfo: const AppInfo(),
      dataSeeder: dataSeeder,
    );
  }

  @override
  String toString() {
    return 'AppConfig(database: $database, studio: $studio, ui: $ui, appInfo: $appInfo, dataSeeder: $dataSeeder)';
  }
}

/// Database configuration
class DatabaseConfig {
  /// Database name
  final String databaseName;

  /// Database version
  final int databaseVersion;

  /// Whether to enable database integrity checks
  final bool enableIntegrityChecks;

  /// Interval between integrity checks in hours
  final int integrityCheckIntervalHours;

  /// Whether to automatically fix integrity issues
  final bool databaseIntegrityAutoFix;

  /// Constructor
  const DatabaseConfig({
    this.databaseName = 'blkwds_manager.db',
    this.databaseVersion = 8,
    this.enableIntegrityChecks = true,
    this.integrityCheckIntervalHours = 24,
    this.databaseIntegrityAutoFix = false,
  });

  /// Create a copy with modified fields
  DatabaseConfig copyWith({
    String? databaseName,
    int? databaseVersion,
    bool? enableIntegrityChecks,
    int? integrityCheckIntervalHours,
    bool? databaseIntegrityAutoFix,
  }) {
    return DatabaseConfig(
      databaseName: databaseName ?? this.databaseName,
      databaseVersion: databaseVersion ?? this.databaseVersion,
      enableIntegrityChecks: enableIntegrityChecks ?? this.enableIntegrityChecks,
      integrityCheckIntervalHours: integrityCheckIntervalHours ?? this.integrityCheckIntervalHours,
      databaseIntegrityAutoFix: databaseIntegrityAutoFix ?? this.databaseIntegrityAutoFix,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'databaseName': databaseName,
      'databaseVersion': databaseVersion,
      'enableIntegrityChecks': enableIntegrityChecks,
      'integrityCheckIntervalHours': integrityCheckIntervalHours,
      'databaseIntegrityAutoFix': databaseIntegrityAutoFix,
    };
  }

  /// Create from a map
  factory DatabaseConfig.fromMap(Map<String, dynamic> map) {
    return DatabaseConfig(
      databaseName: map['databaseName'] ?? 'blkwds_manager.db',
      databaseVersion: map['databaseVersion'] ?? 8,
      enableIntegrityChecks: map['enableIntegrityChecks'] ?? true,
      integrityCheckIntervalHours: map['integrityCheckIntervalHours'] ?? 24,
      databaseIntegrityAutoFix: map['databaseIntegrityAutoFix'] ?? false,
    );
  }

  @override
  String toString() {
    return 'DatabaseConfig(databaseName: $databaseName, databaseVersion: $databaseVersion, enableIntegrityChecks: $enableIntegrityChecks, integrityCheckIntervalHours: $integrityCheckIntervalHours, databaseIntegrityAutoFix: $databaseIntegrityAutoFix)';
  }
}

/// Studio configuration
class StudioConfig {
  /// Default opening time
  final TimeOfDay openingTime;

  /// Default closing time
  final TimeOfDay closingTime;

  /// Default minimum booking duration in minutes
  final int minBookingDuration;

  /// Default maximum booking duration in minutes
  final int maxBookingDuration;

  /// Default minimum advance booking time in hours
  final int minAdvanceBookingTime;

  /// Default maximum advance booking time in days
  final int maxAdvanceBookingTime;

  /// Default cleanup time between bookings in minutes
  final int cleanupTime;

  /// Default setting for allowing overlapping bookings
  final bool allowOverlappingBookings;

  /// Default setting for enforcing studio hours
  final bool enforceStudioHours;

  /// Default studio types
  final List<String> studioTypes;

  /// Default studio statuses
  final List<String> studioStatuses;

  /// Constructor
  const StudioConfig({
    this.openingTime = const TimeOfDay(hour: 9, minute: 0),
    this.closingTime = const TimeOfDay(hour: 22, minute: 0),
    this.minBookingDuration = 60,
    this.maxBookingDuration = 480,
    this.minAdvanceBookingTime = 1,
    this.maxAdvanceBookingTime = 90,
    this.cleanupTime = 30,
    this.allowOverlappingBookings = false,
    this.enforceStudioHours = true,
    this.studioTypes = const ['recording', 'production', 'hybrid'],
    this.studioStatuses = const ['available', 'unavailable', 'maintenance'],
  });

  /// Create a copy with modified fields
  StudioConfig copyWith({
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    int? minBookingDuration,
    int? maxBookingDuration,
    int? minAdvanceBookingTime,
    int? maxAdvanceBookingTime,
    int? cleanupTime,
    bool? allowOverlappingBookings,
    bool? enforceStudioHours,
    List<String>? studioTypes,
    List<String>? studioStatuses,
  }) {
    return StudioConfig(
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      minBookingDuration: minBookingDuration ?? this.minBookingDuration,
      maxBookingDuration: maxBookingDuration ?? this.maxBookingDuration,
      minAdvanceBookingTime: minAdvanceBookingTime ?? this.minAdvanceBookingTime,
      maxAdvanceBookingTime: maxAdvanceBookingTime ?? this.maxAdvanceBookingTime,
      cleanupTime: cleanupTime ?? this.cleanupTime,
      allowOverlappingBookings: allowOverlappingBookings ?? this.allowOverlappingBookings,
      enforceStudioHours: enforceStudioHours ?? this.enforceStudioHours,
      studioTypes: studioTypes ?? this.studioTypes,
      studioStatuses: studioStatuses ?? this.studioStatuses,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'openingTime': '${openingTime.hour}:${openingTime.minute}',
      'closingTime': '${closingTime.hour}:${closingTime.minute}',
      'minBookingDuration': minBookingDuration,
      'maxBookingDuration': maxBookingDuration,
      'minAdvanceBookingTime': minAdvanceBookingTime,
      'maxAdvanceBookingTime': maxAdvanceBookingTime,
      'cleanupTime': cleanupTime,
      'allowOverlappingBookings': allowOverlappingBookings,
      'enforceStudioHours': enforceStudioHours,
      'studioTypes': studioTypes,
      'studioStatuses': studioStatuses,
    };
  }

  /// Create from a map
  factory StudioConfig.fromMap(Map<String, dynamic> map) {
    return StudioConfig(
      openingTime: _timeFromString(map['openingTime'] ?? '9:0'),
      closingTime: _timeFromString(map['closingTime'] ?? '22:0'),
      minBookingDuration: map['minBookingDuration'] ?? 60,
      maxBookingDuration: map['maxBookingDuration'] ?? 480,
      minAdvanceBookingTime: map['minAdvanceBookingTime'] ?? 1,
      maxAdvanceBookingTime: map['maxAdvanceBookingTime'] ?? 90,
      cleanupTime: map['cleanupTime'] ?? 30,
      allowOverlappingBookings: map['allowOverlappingBookings'] ?? false,
      enforceStudioHours: map['enforceStudioHours'] ?? true,
      studioTypes: map['studioTypes'] != null
          ? List<String>.from(map['studioTypes'])
          : const ['recording', 'production', 'hybrid'],
      studioStatuses: map['studioStatuses'] != null
          ? List<String>.from(map['studioStatuses'])
          : const ['available', 'unavailable', 'maintenance'],
    );
  }

  /// Helper method to convert a string to TimeOfDay
  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toString() {
    return 'StudioConfig(openingTime: $openingTime, closingTime: $closingTime, minBookingDuration: $minBookingDuration, maxBookingDuration: $maxBookingDuration, minAdvanceBookingTime: $minAdvanceBookingTime, maxAdvanceBookingTime: $maxAdvanceBookingTime, cleanupTime: $cleanupTime, allowOverlappingBookings: $allowOverlappingBookings, enforceStudioHours: $enforceStudioHours, studioTypes: $studioTypes, studioStatuses: $studioStatuses)';
  }
}

/// UI configuration
class UIConfig {
  /// Default theme mode
  final ThemeMode themeMode;

  /// Default snackbar duration in seconds
  final int snackbarDuration;

  /// Default animation duration in milliseconds
  final int animationDuration;

  /// Constructor
  const UIConfig({
    this.themeMode = ThemeMode.dark,
    this.snackbarDuration = 3,
    this.animationDuration = 300,
  });

  /// Create a copy with modified fields
  UIConfig copyWith({
    ThemeMode? themeMode,
    int? snackbarDuration,
    int? animationDuration,
  }) {
    return UIConfig(
      themeMode: themeMode ?? this.themeMode,
      snackbarDuration: snackbarDuration ?? this.snackbarDuration,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'snackbarDuration': snackbarDuration,
      'animationDuration': animationDuration,
    };
  }

  /// Create from a map
  factory UIConfig.fromMap(Map<String, dynamic> map) {
    return UIConfig(
      themeMode: ThemeMode.values[map['themeMode'] ?? 2], // Default to dark mode
      snackbarDuration: map['snackbarDuration'] ?? 3,
      animationDuration: map['animationDuration'] ?? 300,
    );
  }

  @override
  String toString() {
    return 'UIConfig(themeMode: $themeMode, snackbarDuration: $snackbarDuration, animationDuration: $animationDuration)';
  }
}

/// App information
class AppInfo {
  /// App name
  final String appName;

  /// App version
  final String appVersion;

  /// App build number
  final String appBuildNumber;

  /// App copyright
  final String appCopyright;

  /// Constructor
  const AppInfo({
    this.appName = 'BLKWDS Manager',
    this.appVersion = '1.0.0',
    this.appBuildNumber = '1',
    this.appCopyright = '© 2025 BLKWDS Studios',
  });

  /// Create from version service
  factory AppInfo.fromVersionService() {
    return AppInfo(
      appName: VersionService.appName,
      appVersion: VersionService.version,
      appBuildNumber: VersionService.buildNumber,
      appCopyright: VersionService.copyright,
    );
  }

  /// Create a copy with modified fields
  AppInfo copyWith({
    String? appName,
    String? appVersion,
    String? appBuildNumber,
    String? appCopyright,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      appCopyright: appCopyright ?? this.appCopyright,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'appCopyright': appCopyright,
    };
  }

  /// Create from a map
  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      appName: map['appName'] ?? 'BLKWDS Manager',
      appVersion: map['appVersion'] ?? '1.0.0-rc19',
      appBuildNumber: map['appBuildNumber'] ?? '1',
      appCopyright: map['appCopyright'] ?? '© 2025 BLKWDS Studios',
    );
  }

  @override
  String toString() {
    return 'AppInfo(appName: $appName, appVersion: $appVersion, appBuildNumber: $appBuildNumber, appCopyright: $appCopyright)';
  }
}

/// Data seeder defaults
class DataSeederDefaults {
  /// Whether to enable data seeding on first run
  final bool enableDataSeeding;

  /// Whether to show a confirmation dialog before seeding data
  final bool showSeedingConfirmation;

  /// Default number of members for minimal volume
  final int minimalMemberCount;

  /// Default number of members for standard volume
  final int standardMemberCount;

  /// Default number of members for comprehensive volume
  final int comprehensiveMemberCount;

  /// Default number of gear items for minimal volume
  final int minimalGearCount;

  /// Default number of gear items for standard volume
  final int standardGearCount;

  /// Default number of gear items for comprehensive volume
  final int comprehensiveGearCount;

  /// Default number of projects for minimal volume
  final int minimalProjectCount;

  /// Default number of projects for standard volume
  final int standardProjectCount;

  /// Default number of projects for comprehensive volume
  final int comprehensiveProjectCount;

  /// Default number of bookings for minimal volume
  final int minimalBookingCount;

  /// Default number of bookings for standard volume
  final int standardBookingCount;

  /// Default number of bookings for comprehensive volume
  final int comprehensiveBookingCount;

  /// Default gear categories
  final List<String> gearCategories;

  /// Default member roles
  final List<String> memberRoles;

  /// Constructor
  const DataSeederDefaults({
    this.enableDataSeeding = true,
    this.showSeedingConfirmation = true,
    this.minimalMemberCount = 2,
    this.standardMemberCount = 5,
    this.comprehensiveMemberCount = 15,
    this.minimalGearCount = 3,
    this.standardGearCount = 10,
    this.comprehensiveGearCount = 30,
    this.minimalProjectCount = 1,
    this.standardProjectCount = 3,
    this.comprehensiveProjectCount = 10,
    this.minimalBookingCount = 2,
    this.standardBookingCount = 5,
    this.comprehensiveBookingCount = 20,
    this.gearCategories = const [
      'Camera',
      'Lens',
      'Audio',
      'Lighting',
      'Stabilizer',
      'Support',
      'Power',
      'Storage',
      'Other',
    ],
    this.memberRoles = const [
      'Director',
      'Producer',
      'Cinematographer',
      'Sound Engineer',
      'Gaffer',
      'Editor',
      'Production Assistant',
      'Other',
    ],
  });

  /// Create a copy with modified fields
  DataSeederDefaults copyWith({
    bool? enableDataSeeding,
    bool? showSeedingConfirmation,
    int? minimalMemberCount,
    int? standardMemberCount,
    int? comprehensiveMemberCount,
    int? minimalGearCount,
    int? standardGearCount,
    int? comprehensiveGearCount,
    int? minimalProjectCount,
    int? standardProjectCount,
    int? comprehensiveProjectCount,
    int? minimalBookingCount,
    int? standardBookingCount,
    int? comprehensiveBookingCount,
    List<String>? gearCategories,
    List<String>? memberRoles,
  }) {
    return DataSeederDefaults(
      enableDataSeeding: enableDataSeeding ?? this.enableDataSeeding,
      showSeedingConfirmation: showSeedingConfirmation ?? this.showSeedingConfirmation,
      minimalMemberCount: minimalMemberCount ?? this.minimalMemberCount,
      standardMemberCount: standardMemberCount ?? this.standardMemberCount,
      comprehensiveMemberCount: comprehensiveMemberCount ?? this.comprehensiveMemberCount,
      minimalGearCount: minimalGearCount ?? this.minimalGearCount,
      standardGearCount: standardGearCount ?? this.standardGearCount,
      comprehensiveGearCount: comprehensiveGearCount ?? this.comprehensiveGearCount,
      minimalProjectCount: minimalProjectCount ?? this.minimalProjectCount,
      standardProjectCount: standardProjectCount ?? this.standardProjectCount,
      comprehensiveProjectCount: comprehensiveProjectCount ?? this.comprehensiveProjectCount,
      minimalBookingCount: minimalBookingCount ?? this.minimalBookingCount,
      standardBookingCount: standardBookingCount ?? this.standardBookingCount,
      comprehensiveBookingCount: comprehensiveBookingCount ?? this.comprehensiveBookingCount,
      gearCategories: gearCategories ?? this.gearCategories,
      memberRoles: memberRoles ?? this.memberRoles,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'enableDataSeeding': enableDataSeeding,
      'showSeedingConfirmation': showSeedingConfirmation,
      'minimalMemberCount': minimalMemberCount,
      'standardMemberCount': standardMemberCount,
      'comprehensiveMemberCount': comprehensiveMemberCount,
      'minimalGearCount': minimalGearCount,
      'standardGearCount': standardGearCount,
      'comprehensiveGearCount': comprehensiveGearCount,
      'minimalProjectCount': minimalProjectCount,
      'standardProjectCount': standardProjectCount,
      'comprehensiveProjectCount': comprehensiveProjectCount,
      'minimalBookingCount': minimalBookingCount,
      'standardBookingCount': standardBookingCount,
      'comprehensiveBookingCount': comprehensiveBookingCount,
      'gearCategories': gearCategories,
      'memberRoles': memberRoles,
    };
  }

  /// Create from a map
  factory DataSeederDefaults.fromMap(Map<String, dynamic> map) {
    return DataSeederDefaults(
      enableDataSeeding: map['enableDataSeeding'] ?? true,
      showSeedingConfirmation: map['showSeedingConfirmation'] ?? true,
      minimalMemberCount: map['minimalMemberCount'] ?? 2,
      standardMemberCount: map['standardMemberCount'] ?? 5,
      comprehensiveMemberCount: map['comprehensiveMemberCount'] ?? 15,
      minimalGearCount: map['minimalGearCount'] ?? 3,
      standardGearCount: map['standardGearCount'] ?? 10,
      comprehensiveGearCount: map['comprehensiveGearCount'] ?? 30,
      minimalProjectCount: map['minimalProjectCount'] ?? 1,
      standardProjectCount: map['standardProjectCount'] ?? 3,
      comprehensiveProjectCount: map['comprehensiveProjectCount'] ?? 10,
      minimalBookingCount: map['minimalBookingCount'] ?? 2,
      standardBookingCount: map['standardBookingCount'] ?? 5,
      comprehensiveBookingCount: map['comprehensiveBookingCount'] ?? 20,
      gearCategories: map['gearCategories'] != null
          ? List<String>.from(map['gearCategories'])
          : const [
              'Camera',
              'Lens',
              'Audio',
              'Lighting',
              'Stabilizer',
              'Support',
              'Power',
              'Storage',
              'Other',
            ],
      memberRoles: map['memberRoles'] != null
          ? List<String>.from(map['memberRoles'])
          : const [
              'Director',
              'Producer',
              'Cinematographer',
              'Sound Engineer',
              'Gaffer',
              'Editor',
              'Production Assistant',
              'Other',
            ],
    );
  }

  @override
  String toString() {
    return 'DataSeederDefaults(enableDataSeeding: $enableDataSeeding, showSeedingConfirmation: $showSeedingConfirmation, minimalMemberCount: $minimalMemberCount, standardMemberCount: $standardMemberCount, comprehensiveMemberCount: $comprehensiveMemberCount, minimalGearCount: $minimalGearCount, standardGearCount: $standardGearCount, comprehensiveGearCount: $comprehensiveGearCount, minimalProjectCount: $minimalProjectCount, standardProjectCount: $standardProjectCount, comprehensiveProjectCount: $comprehensiveProjectCount, minimalBookingCount: $minimalBookingCount, standardBookingCount: $standardBookingCount, comprehensiveBookingCount: $comprehensiveBookingCount, gearCategories: $gearCategories, memberRoles: $memberRoles)';
  }
}
