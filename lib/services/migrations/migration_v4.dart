import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../log_service.dart';

/// Migration for database version 4
class MigrationV4 {
  /// Migrate the database to version 4
  static Future<void> migrate(Database db) async {
    LogService.info('Running migration to version 4');
    
    try {
      // Add title to booking table
      await db.execute('''
        ALTER TABLE booking ADD COLUMN title TEXT
      ''');
      
      // Add color to booking table
      await db.execute('''
        ALTER TABLE booking ADD COLUMN color TEXT
      ''');
      
      // Add notes to booking table
      await db.execute('''
        ALTER TABLE booking ADD COLUMN notes TEXT
      ''');
      
      LogService.info('Migration to version 4 completed successfully');
    } catch (e, stackTrace) {
      LogService.error('Error during migration to version 4', e, stackTrace);
      rethrow;
    }
  }
}
