import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';
import '../../app_config_service.dart';

/// Migration from v4 to v5
/// Adds studio tables and updates booking table for studio management
class MigrationV4ToV5 implements Migration {
  @override
  int get fromVersion => 4;

  @override
  int get toVersion => 5;

  @override
  String get description => 'Adds studio tables and updates booking table for studio management';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v4 to v5');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Check if tables already exist
        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tables = tableResult.map((t) => t['name'] as String).toList();

        // Create studio table if it doesn't exist
        if (!tables.contains('studio')) {
          LogService.info('Creating studio table');
          await txn.execute('''
            CREATE TABLE studio (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              type TEXT NOT NULL,
              description TEXT,
              features TEXT,
              hourlyRate REAL,
              status TEXT NOT NULL DEFAULT 'available',
              color TEXT
            )
          ''');
        } else {
          LogService.info('Studio table already exists, skipping creation');
        }

        // Create studio_settings table if it doesn't exist
        if (!tables.contains('studio_settings')) {
          LogService.info('Creating studio_settings table');
          await txn.execute('''
            CREATE TABLE studio_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              openingTime TEXT NOT NULL,
              closingTime TEXT NOT NULL,
              minBookingDuration INTEGER NOT NULL,
              maxBookingDuration INTEGER NOT NULL,
              minAdvanceBookingTime INTEGER NOT NULL,
              maxAdvanceBookingTime INTEGER NOT NULL,
              cleanupTime INTEGER NOT NULL,
              allowOverlappingBookings INTEGER NOT NULL,
              enforceStudioHours INTEGER NOT NULL
            )
          ''');
        } else {
          LogService.info('Studio settings table already exists, skipping creation');
        }

        // Check if booking table already has the required columns
        final bookingColumnsResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final existingBookingColumns = bookingColumnsResult.map((col) => col['name'] as String).toList();

        // Add studioId column if it doesn't exist
        if (!existingBookingColumns.contains('studioId')) {
          LogService.info('Adding studioId column to booking table');
          await txn.execute('ALTER TABLE booking ADD COLUMN studioId INTEGER DEFAULT NULL');
        } else {
          LogService.info('studioId column already exists in booking table, skipping');
        }

        // Add notes column if it doesn't exist
        if (!existingBookingColumns.contains('notes')) {
          LogService.info('Adding notes column to booking table');
          await txn.execute('ALTER TABLE booking ADD COLUMN notes TEXT DEFAULT NULL');
        } else {
          LogService.info('notes column already exists in booking table, skipping');
        }

        // Check if studio settings already exist
        final settingsCount = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM studio_settings'));

        // Insert default studio settings if none exist
        if (settingsCount == 0) {
          LogService.info('Inserting default studio settings');
          final studioConfig = AppConfigService.config.studio;
          await txn.insert('studio_settings', {
            'openingTime': '${studioConfig.openingTime.hour}:${studioConfig.openingTime.minute}',
            'closingTime': '${studioConfig.closingTime.hour}:${studioConfig.closingTime.minute}',
            'minBookingDuration': studioConfig.minBookingDuration,
            'maxBookingDuration': studioConfig.maxBookingDuration,
            'minAdvanceBookingTime': studioConfig.minAdvanceBookingTime,
            'maxAdvanceBookingTime': studioConfig.maxAdvanceBookingTime,
            'cleanupTime': studioConfig.cleanupTime,
            'allowOverlappingBookings': studioConfig.allowOverlappingBookings ? 1 : 0,
            'enforceStudioHours': studioConfig.enforceStudioHours ? 1 : 0,
          });
        } else {
          LogService.info('Studio settings already exist, skipping insertion');
        }

        // Check if default studios already exist
        final studioMaps = await txn.query('studio');
        bool hasRecordingStudio = false;
        bool hasProductionStudio = false;

        for (final studioMap in studioMaps) {
          final type = studioMap['type'] as String;
          if (type == 'recording') {
            hasRecordingStudio = true;
          } else if (type == 'production') {
            hasProductionStudio = true;
          }
        }

        // Create recording studio if it doesn't exist
        if (!hasRecordingStudio) {
          LogService.info('Creating default Recording Studio');
          await txn.insert('studio', {
            'name': 'Recording Studio',
            'type': 'recording',
            'description': 'Main recording studio space',
            'status': 'available',
          });
        } else {
          LogService.info('Recording Studio already exists, skipping creation');
        }

        // Create production studio if it doesn't exist
        if (!hasProductionStudio) {
          LogService.info('Creating default Production Studio');
          await txn.insert('studio', {
            'name': 'Production Studio',
            'type': 'production',
            'description': 'Main production studio space',
            'status': 'available',
          });
        } else {
          LogService.info('Production Studio already exists, skipping creation');
        }

        // Verify migration success
        final verifyTableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final verifyTables = verifyTableResult.map((t) => t['name'] as String).toList();

        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        if (!verifyTables.contains('studio') ||
            !verifyTables.contains('studio_settings') ||
            !bookingColumns.contains('studioId') ||
            !bookingColumns.contains('notes')) {
          throw Exception('Migration v4 to v5 failed: schema changes not applied correctly');
        }

        LogService.info('Migration v4 to v5 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v4 to v5', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
