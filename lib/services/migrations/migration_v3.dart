import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../log_service.dart';

/// Migration for database version 3
class MigrationV3 {
  /// Migrate the database to version 3
  static Future<void> migrate(Database db) async {
    LogService.info('Running migration to version 3');
    
    try {
      // Add studio_settings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS studio_settings (
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
      
      // Insert default studio settings
      await db.insert('studio_settings', {
        'openingTime': '9:0',
        'closingTime': '22:0',
        'minBookingDuration': 60,
        'maxBookingDuration': 480,
        'minAdvanceBookingTime': 1,
        'maxAdvanceBookingTime': 90,
        'cleanupTime': 30,
        'allowOverlappingBookings': 0,
        'enforceStudioHours': 1,
      });
      
      LogService.info('Migration to version 3 completed successfully');
    } catch (e, stackTrace) {
      LogService.error('Error during migration to version 3', e, stackTrace);
      rethrow;
    }
  }
}
