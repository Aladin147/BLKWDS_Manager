import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';

/// Migration from v2 to v3
/// Adds a settings table and color column to booking table
class MigrationV2ToV3 implements Migration {
  @override
  int get fromVersion => 2;

  @override
  int get toVersion => 3;

  @override
  String get description => 'Adds a settings table and color column to booking table';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v2 to v3');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Add settings table for app configuration
        await txn.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            value TEXT NOT NULL
          )
        ''');

        // Add color column to booking table for visual identification
        await txn.execute('ALTER TABLE booking ADD COLUMN color TEXT DEFAULT NULL');

        // Verify migration success
        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tables = tableResult.map((t) => t['name'] as String).toList();

        if (!bookingColumns.contains('color') || !tables.contains('settings')) {
          throw Exception('Migration v2 to v3 failed: schema changes not applied correctly');
        }

        LogService.info('Migration v2 to v3 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v2 to v3', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
