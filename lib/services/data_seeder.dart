import 'dart:math';
import '../models/models.dart';
import '../utils/data_generator.dart';
import 'db_service.dart';
import 'log_service.dart';
import 'preferences_service.dart';
import 'app_config_service.dart';

/// DataSeeder
/// Utility class for seeding the database with sample data
class DataSeeder {
  /// Get the current data seeder configuration
  static Future<DataSeederConfig> getConfig() async {
    try {
      // Try to load config from preferences
      final configMap = await PreferencesService.getMap('dataSeederConfig');
      if (configMap != null) {
        return DataSeederConfig.fromMap(configMap);
      }
    } catch (e) {
      LogService.error('Error loading data seeder config', e);
    }

    // Return default config if none exists
    return DataSeederConfig.standard();
  }

  /// Save the data seeder configuration
  static Future<void> saveConfig(DataSeederConfig config) async {
    try {
      await PreferencesService.setMap('dataSeederConfig', config.toMap());
      LogService.info('Data seeder config saved');
    } catch (e) {
      LogService.error('Error saving data seeder config', e);
    }
  }

  /// Check if the database is empty
  static Future<bool> isDatabaseEmpty() async {
    try {
      // Check if any members exist
      final members = await DBService.getAllMembers();
      if (members.isNotEmpty) return false;

      // Check if any gear exists
      final gear = await DBService.getAllGear();
      if (gear.isNotEmpty) return false;

      // Check if any projects exist
      final projects = await DBService.getAllProjects();
      if (projects.isNotEmpty) return false;

      // Check if any studios exist
      final studios = await DBService.getAllStudios();
      if (studios.isNotEmpty) return false;

      // If we get here, the database is empty
      return true;
    } catch (e, stackTrace) {
      LogService.error('Error checking if database is empty', e, stackTrace);
      // Assume not empty on error to prevent accidental data loss
      return false;
    }
  }

  /// Seed the database with sample data
  static Future<void> seedDatabase([DataSeederConfig? config]) async {
    // Get configuration
    final seederConfig = config ?? await getConfig();

    // Check if database is already seeded
    final isEmpty = await isDatabaseEmpty();
    if (!isEmpty) {
      LogService.info('Database already contains data, skipping seeding');
      return;
    }

    // Check if seeding is enabled on first run
    if (!seederConfig.seedOnFirstRun) {
      LogService.info('Seeding on first run is disabled in configuration');
      return;
    }

    // Log that we're about to seed the database
    LogService.info('Starting database seeding with config: $seederConfig');

    // Seed members
    final memberIds = seederConfig.seedMembers
        ? await _seedMembers(seederConfig)
        : <int>[];

    // Seed gear
    final gearIds = seederConfig.seedGear
        ? await _seedGear(seederConfig)
        : <int>[];

    // Seed studios
    final studioIds = seederConfig.seedStudios
        ? await _seedStudios(seederConfig)
        : <int>[];

    // Seed projects
    final projectIds = seederConfig.seedProjects
        ? await _seedProjects(memberIds, seederConfig)
        : <int>[];

    // Seed bookings
    if (seederConfig.seedBookings) {
      await _seedBookings(
        projectIds,
        gearIds,
        memberIds,
        studioIds,
        seederConfig,
      );
    }

    // Seed activity logs
    if (seederConfig.seedActivityLogs) {
      await _seedActivityLogs(
        gearIds,
        memberIds,
        seederConfig,
      );
    }

    LogService.info('Database seeded successfully');
  }

  /// Reseed the database with the given configuration
  /// This method should be used with caution as it will clear all existing data
  static Future<void> reseedDatabase(DataSeederConfig config) async {
    // Log warning about data loss
    LogService.warning('Reseeding database will clear all existing data');

    try {
      // Clear existing data
      await DBService.clearAllData();
      LogService.info('Database cleared');

      // Save the new configuration
      await saveConfig(config);
      LogService.info('Data seeder configuration saved');

      // Seed the database with the new configuration
      await seedDatabase(config);
      LogService.info('Database reseeded successfully');
    } catch (e, stackTrace) {
      LogService.error('Error reseeding database', e, stackTrace);
      rethrow;
    }
  }

  /// Seed members
  static Future<List<int>> _seedMembers(DataSeederConfig config) async {
    final memberIds = <int>[];

    // Determine number of members to create based on volume type
    int memberCount;
    final dataSeederDefaults = AppConfigService.config.dataSeeder;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        memberCount = dataSeederDefaults.minimalMemberCount;
        break;
      case DataSeederVolumeType.standard:
        memberCount = dataSeederDefaults.standardMemberCount;
        break;
      case DataSeederVolumeType.comprehensive:
        memberCount = dataSeederDefaults.comprehensiveMemberCount;
        break;
    }

    // Create members based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data
      final fixedMembers = [
        Member(name: 'Alex Johnson', role: 'Director'),
        Member(name: 'Sam Williams', role: 'Cinematographer'),
        Member(name: 'Jordan Lee', role: 'Sound Engineer'),
        Member(name: 'Taylor Smith', role: 'Producer'),
        Member(name: 'Morgan Chen', role: 'Editor'),
        Member(name: 'Casey Brown', role: 'Gaffer'),
        Member(name: 'Riley Garcia', role: 'Production Assistant'),
        Member(name: 'Jamie Wilson', role: 'Set Designer'),
        Member(name: 'Quinn Murphy', role: 'Makeup Artist'),
        Member(name: 'Avery Thomas', role: 'Script Supervisor'),
        Member(name: 'Blake Rodriguez', role: 'Location Manager'),
        Member(name: 'Cameron Lee', role: 'VFX Artist'),
        Member(name: 'Charlie Davis', role: 'Colorist'),
        Member(name: 'Dakota Martinez', role: 'Costume Designer'),
        Member(name: 'Drew Hernandez', role: 'Grip'),
      ];

      // Take the required number of members
      final members = fixedMembers.take(memberCount).toList();

      // Insert members
      for (final member in members) {
        final id = await DBService.insertMember(member);
        memberIds.add(id);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < memberCount; i++) {
        final member = DataGenerator.randomMember();
        final id = await DBService.insertMember(member);
        memberIds.add(id);
      }
    }

    return memberIds;
  }

  /// Seed gear
  static Future<List<int>> _seedGear(DataSeederConfig config) async {
    final gearIds = <int>[];

    // Determine number of gear items to create based on volume type
    int gearCount;
    final dataSeederDefaults = AppConfigService.config.dataSeeder;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        gearCount = dataSeederDefaults.minimalGearCount;
        break;
      case DataSeederVolumeType.standard:
        gearCount = dataSeederDefaults.standardGearCount;
        break;
      case DataSeederVolumeType.comprehensive:
        gearCount = dataSeederDefaults.comprehensiveGearCount;
        break;
    }

    // Create gear based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data
      final fixedGear = [
        Gear(name: 'Canon R6', category: 'Camera', isOut: false),
        Gear(name: 'Sony A7III', category: 'Camera', isOut: true, lastNote: 'Battery at 50%'),
        Gear(name: 'DJI Ronin', category: 'Stabilizer', isOut: false),
        Gear(name: 'Sennheiser MKH416', category: 'Audio', isOut: true),
        Gear(name: 'Aputure 120D', category: 'Lighting', isOut: false),
        Gear(name: 'Canon 24-70mm f/2.8', category: 'Lens', isOut: false),
        Gear(name: 'Zoom H6', category: 'Audio', isOut: false, lastNote: 'New SD card installed'),
        Gear(name: 'Manfrotto Tripod', category: 'Support', isOut: true),
        Gear(name: 'Blackmagic Pocket 6K', category: 'Camera', isOut: false),
        Gear(name: 'Sigma 18-35mm f/1.8', category: 'Lens', isOut: false),
        Gear(name: 'Rode NTG3', category: 'Audio', isOut: false),
        Gear(name: 'Godox SL60W', category: 'Lighting', isOut: false),
        Gear(name: 'Zhiyun Crane 3', category: 'Stabilizer', isOut: false),
        Gear(name: 'Atomos Ninja V', category: 'Monitor', isOut: false),
        Gear(name: 'SmallHD 502', category: 'Monitor', isOut: false),
        Gear(name: 'V-Mount Battery', category: 'Power', isOut: false),
        Gear(name: 'SanDisk Extreme Pro', category: 'Storage', isOut: false),
        Gear(name: 'Sachtler Flowtech', category: 'Support', isOut: false),
        Gear(name: 'DJI Mavic 3', category: 'Drone', isOut: false),
        Gear(name: 'Zeiss Milvus 50mm', category: 'Lens', isOut: false),
        Gear(name: 'Samyang 85mm T1.5', category: 'Lens', isOut: false),
        Gear(name: 'Westcott Ice Light', category: 'Lighting', isOut: false),
        Gear(name: 'Rode Wireless Go II', category: 'Audio', isOut: false),
        Gear(name: 'Gitzo GT3543', category: 'Support', isOut: false),
        Gear(name: 'RED Komodo', category: 'Camera', isOut: false),
      ];

      // Take the required number of gear items
      final gear = fixedGear.take(gearCount).toList();

      // Insert gear
      for (final item in gear) {
        final id = await DBService.insertGear(item);
        gearIds.add(id);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < gearCount; i++) {
        final gear = DataGenerator.randomGear();
        final id = await DBService.insertGear(gear);
        gearIds.add(id);
      }
    }

    return gearIds;
  }

  /// Seed studios
  static Future<List<int>> _seedStudios(DataSeederConfig config) async {
    final studioIds = <int>[];

    // Determine number of studios to create based on volume type
    int studioCount;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        studioCount = 2;
        break;
      case DataSeederVolumeType.standard:
        studioCount = 4;
        break;
      case DataSeederVolumeType.comprehensive:
        studioCount = 8;
        break;
    }

    // Create studios based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data
      final fixedStudios = [
        Studio(name: 'Main Studio', type: StudioType.production),
        Studio(name: 'Recording Studio', type: StudioType.recording),
        Studio(name: 'Green Screen Room', type: StudioType.hybrid, description: 'Green screen capabilities'),
        Studio(name: 'Interview Room', type: StudioType.recording, description: 'Quiet space for interviews'),
        Studio(name: 'Sound Stage', type: StudioType.production, description: 'Large sound stage for productions'),
        Studio(name: 'Editing Suite', type: StudioType.hybrid, description: 'Editing workstations'),
        Studio(name: 'Podcast Room', type: StudioType.recording, description: 'Podcast recording setup'),
        Studio(name: 'Photography Studio', type: StudioType.production, description: 'Photography setup'),
      ];

      // Take the required number of studios
      final studios = fixedStudios.take(studioCount).toList();

      // Insert studios
      for (final studio in studios) {
        final id = await DBService.insertStudio(studio);
        studioIds.add(id);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < studioCount; i++) {
        final studio = DataGenerator.randomStudio();
        final id = await DBService.insertStudio(studio);
        studioIds.add(id);
      }
    }

    return studioIds;
  }

  /// Seed projects
  static Future<List<int>> _seedProjects(List<int> memberIds, DataSeederConfig config) async {
    final projectIds = <int>[];

    // If no members, return empty list
    if (memberIds.isEmpty) {
      return projectIds;
    }

    // Determine number of projects to create based on volume type
    int projectCount;
    final dataSeederDefaults = AppConfigService.config.dataSeeder;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        projectCount = dataSeederDefaults.minimalProjectCount;
        break;
      case DataSeederVolumeType.standard:
        projectCount = dataSeederDefaults.standardProjectCount;
        break;
      case DataSeederVolumeType.comprehensive:
        projectCount = dataSeederDefaults.comprehensiveProjectCount;
        break;
    }

    // Create projects based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data with dynamic member IDs
      final fixedProjects = [
        Project(
          title: 'Brand Commercial',
          client: 'XYZ Corp',
          notes: 'Two-day shoot in studio',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Music Video',
          client: 'Indie Band',
          notes: 'Outdoor locations, backup gear needed',
          memberIds: _getRandomSubset(memberIds, 3),
        ),
        Project(
          title: 'Documentary Interview',
          client: 'Non-profit Org',
          notes: 'Minimal setup, focus on audio quality',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Corporate Training',
          client: 'Tech Solutions Inc.',
          notes: 'Series of instructional videos',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Wedding Film',
          client: 'Johnson Family',
          notes: 'Full day coverage with multiple cameras',
          memberIds: _getRandomSubset(memberIds, 3),
        ),
        Project(
          title: 'Product Launch',
          client: 'Innovative Gadgets',
          notes: 'High-end product showcase',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Short Film',
          client: 'Independent Filmmaker',
          notes: 'Three-day shoot with full crew',
          memberIds: _getRandomSubset(memberIds, 4),
        ),
        Project(
          title: 'Fashion Lookbook',
          client: 'Urban Apparel',
          notes: 'Studio and location shots',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Real Estate Tour',
          client: 'Luxury Properties',
          notes: 'Drone and interior footage',
          memberIds: _getRandomSubset(memberIds, 2),
        ),
        Project(
          title: 'Live Event Coverage',
          client: 'Annual Conference',
          notes: 'Multi-camera setup with live switching',
          memberIds: _getRandomSubset(memberIds, 3),
        ),
      ];

      // Take the required number of projects
      final projects = fixedProjects.take(projectCount).toList();

      // Insert projects
      for (final project in projects) {
        final id = await DBService.insertProject(project);
        projectIds.add(id);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < projectCount; i++) {
        final project = DataGenerator.randomProject(memberIds: memberIds);
        final id = await DBService.insertProject(project);
        projectIds.add(id);
      }
    }

    return projectIds;
  }

  /// Get a random subset of a list
  static List<int> _getRandomSubset(List<int> items, int count) {
    if (items.isEmpty) return [];
    if (items.length <= count) return List.from(items);

    final random = Random();
    final shuffled = List<int>.from(items)..shuffle(random);
    return shuffled.take(count).toList();
  }

  /// Seed bookings
  static Future<List<int>> _seedBookings(
    List<int> projectIds,
    List<int> gearIds,
    List<int> memberIds,
    List<int> studioIds,
    DataSeederConfig config,
  ) async {
    final bookingIds = <int>[];

    // If no projects or gear, return empty list
    if (projectIds.isEmpty || gearIds.isEmpty) {
      return bookingIds;
    }

    // Determine number of bookings to create based on volume type
    int bookingCount;
    final dataSeederDefaults = AppConfigService.config.dataSeeder;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        bookingCount = dataSeederDefaults.minimalBookingCount;
        break;
      case DataSeederVolumeType.standard:
        bookingCount = dataSeederDefaults.standardBookingCount;
        break;
      case DataSeederVolumeType.comprehensive:
        bookingCount = dataSeederDefaults.comprehensiveBookingCount;
        break;
    }

    // Create bookings based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data
      final now = DateTime.now();
      final fixedBookings = [
        Booking(
          projectId: projectIds.isNotEmpty ? projectIds[0] : -1,
          title: 'Commercial Shoot',
          startDate: DateTime(now.year, now.month, now.day + 3, 9),
          endDate: DateTime(now.year, now.month, now.day + 3, 18),
          studioId: studioIds.isNotEmpty ? studioIds[0] : null,
          gearIds: gearIds.isNotEmpty ? [
            gearIds[0],
            gearIds.length > 2 ? gearIds[2] : gearIds[0],
            gearIds.length > 4 ? gearIds[4] : gearIds[0],
            gearIds.length > 5 ? gearIds[5] : gearIds[0]
          ] : [],
          assignedGearToMember: memberIds.isNotEmpty ? {
            gearIds[0]: memberIds.length > 1 ? memberIds[1] : memberIds[0],
            gearIds.length > 2 ? gearIds[2] : gearIds[0]: memberIds.length > 1 ? memberIds[1] : memberIds[0],
          } : null,
        ),
        Booking(
          projectId: projectIds.length > 1 ? projectIds[1] : (projectIds.isNotEmpty ? projectIds[0] : -1),
          title: 'Music Video',
          startDate: DateTime(now.year, now.month, now.day + 5, 10),
          endDate: DateTime(now.year, now.month, now.day + 6, 16),
          studioId: studioIds.length > 1 ? studioIds[1] : (studioIds.isNotEmpty ? studioIds[0] : null),
          gearIds: gearIds.isNotEmpty ? [
            gearIds.length > 1 ? gearIds[1] : gearIds[0],
            gearIds.length > 3 ? gearIds[3] : gearIds[0],
            gearIds.length > 6 ? gearIds[6] : gearIds[0]
          ] : [],
          assignedGearToMember: memberIds.isNotEmpty ? {
            gearIds.length > 3 ? gearIds[3] : gearIds[0]: memberIds.length > 2 ? memberIds[2] : memberIds[0],
            gearIds.length > 6 ? gearIds[6] : gearIds[0]: memberIds.length > 2 ? memberIds[2] : memberIds[0],
          } : null,
        ),
        Booking(
          projectId: projectIds.length > 2 ? projectIds[2] : (projectIds.isNotEmpty ? projectIds[0] : -1),
          title: 'Documentary Shoot',
          startDate: DateTime(now.year, now.month, now.day + 10, 13),
          endDate: DateTime(now.year, now.month, now.day + 10, 17),
          studioId: studioIds.length > 1 ? studioIds[1] : (studioIds.isNotEmpty ? studioIds[0] : null),
          gearIds: gearIds.isNotEmpty ? [
            gearIds.length > 3 ? gearIds[3] : gearIds[0],
            gearIds.length > 6 ? gearIds[6] : gearIds[0],
            gearIds.length > 7 ? gearIds[7] : gearIds[0]
          ] : [],
        ),
      ];

      // Take the required number of bookings
      final bookings = fixedBookings.take(bookingCount).toList();

      // Insert bookings
      for (final booking in bookings) {
        final id = await DBService.insertBooking(booking);
        bookingIds.add(id);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < bookingCount; i++) {
        final booking = DataGenerator.randomBooking(
          projectIds: projectIds,
          gearIds: gearIds,
          memberIds: memberIds,
          studioIds: studioIds,
          includePastData: config.includePastData,
          includeFutureData: config.includeFutureData,
        );
        final id = await DBService.insertBooking(booking);
        bookingIds.add(id);
      }
    }

    return bookingIds;
  }

  /// Seed activity logs
  static Future<void> _seedActivityLogs(
    List<int> gearIds,
    List<int> memberIds,
    DataSeederConfig config,
  ) async {
    // If no gear or members, return
    if (gearIds.isEmpty || memberIds.isEmpty) {
      return;
    }

    // Determine number of activity logs to create based on volume type
    int activityLogCount;
    int statusNoteCount;
    switch (config.volumeType) {
      case DataSeederVolumeType.minimal:
        activityLogCount = 3;
        statusNoteCount = 2;
        break;
      case DataSeederVolumeType.standard:
        activityLogCount = 5;
        statusNoteCount = 3;
        break;
      case DataSeederVolumeType.comprehensive:
        activityLogCount = 15;
        statusNoteCount = 8;
        break;
    }

    // Create activity logs based on randomization type
    if (config.randomizationType == DataSeederRandomizationType.fixed) {
      // Use fixed data
      final now = DateTime.now();
      final fixedActivityLogs = [
        ActivityLog(
          gearId: gearIds.length > 1 ? gearIds[1] : gearIds[0],
          memberId: memberIds.length > 1 ? memberIds[1] : memberIds[0],
          checkedOut: true,
          timestamp: DateTime(now.year, now.month, now.day - 1, 9, 30),
          note: 'Taking for outdoor shoot',
        ),
        ActivityLog(
          gearId: gearIds.length > 3 ? gearIds[3] : gearIds[0],
          memberId: memberIds.length > 2 ? memberIds[2] : memberIds[0],
          checkedOut: true,
          timestamp: DateTime(now.year, now.month, now.day - 1, 10, 15),
        ),
        ActivityLog(
          gearId: gearIds.length > 7 ? gearIds[7] : gearIds[0],
          memberId: memberIds.length > 1 ? memberIds[1] : memberIds[0],
          checkedOut: true,
          timestamp: DateTime(now.year, now.month, now.day - 1, 10, 20),
        ),
        ActivityLog(
          gearId: gearIds[0],
          memberId: memberIds[0],
          checkedOut: true,
          timestamp: DateTime(now.year, now.month, now.day - 2, 14, 0),
          note: 'For client meeting demo',
        ),
        ActivityLog(
          gearId: gearIds[0],
          memberId: null,
          checkedOut: false,
          timestamp: DateTime(now.year, now.month, now.day - 1, 17, 45),
          note: 'Returned with full battery',
        ),
      ];

      // Take the required number of activity logs
      final activityLogs = fixedActivityLogs.take(activityLogCount).toList();

      // Insert activity logs
      for (final log in activityLogs) {
        await DBService.insertActivityLog(log);
      }

      // Add status notes
      final fixedStatusNotes = [
        StatusNote(
          gearId: gearIds.length > 1 ? gearIds[1] : gearIds[0],
          note: 'Battery at 50%',
          timestamp: DateTime(now.year, now.month, now.day - 1, 17, 30),
        ),
        StatusNote(
          gearId: gearIds.length > 6 ? gearIds[6] : gearIds[0],
          note: 'New SD card installed',
          timestamp: DateTime(now.year, now.month, now.day - 3, 11, 15),
        ),
        StatusNote(
          gearId: gearIds.length > 2 ? gearIds[2] : gearIds[0],
          note: 'Needs calibration soon',
          timestamp: DateTime(now.year, now.month, now.day - 5, 9, 0),
        ),
      ];

      // Take the required number of status notes
      final statusNotes = fixedStatusNotes.take(statusNoteCount).toList();

      // Insert status notes
      for (final note in statusNotes) {
        await DBService.insertStatusNote(note);
      }
    } else {
      // Use randomized data
      for (int i = 0; i < activityLogCount; i++) {
        final activityLog = DataGenerator.randomActivityLog(
          gearIds: gearIds,
          memberIds: memberIds,
          includePastData: config.includePastData,
          includeFutureData: false, // Activity logs are always in the past
        );
        await DBService.insertActivityLog(activityLog);
      }

      // Add status notes
      for (int i = 0; i < statusNoteCount; i++) {
        final statusNote = DataGenerator.randomStatusNote(
          gearIds: gearIds,
          includePastData: config.includePastData,
          includeFutureData: false, // Status notes are always in the past
        );
        await DBService.insertStatusNote(statusNote);
      }
    }
  }
}
