import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../log_service.dart';

/// Migration for database version 2
class MigrationV2 {
  /// Migrate the database to version 2
  static Future<void> migrate(Database db) async {
    LogService.info('Running migration to version 2');
    
    try {
      // Add studio table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS studio (
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
      
      // Add studioId to booking table
      await db.execute('''
        ALTER TABLE booking ADD COLUMN studioId INTEGER
      ''');
      
      LogService.info('Migration to version 2 completed successfully');
    } catch (e, stackTrace) {
      LogService.error('Error during migration to version 2', e, stackTrace);
      rethrow;
    }
  }
}
