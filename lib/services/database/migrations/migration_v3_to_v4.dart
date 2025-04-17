import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';

/// Migration from v3 to v4
/// Adds title column to booking table
class MigrationV3ToV4 implements Migration {
  @override
  int get fromVersion => 3;

  @override
  int get toVersion => 4;

  @override
  String get description => 'Adds title column to booking table';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v3 to v4');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Add title column to booking table
        await txn.execute('ALTER TABLE booking ADD COLUMN title TEXT DEFAULT NULL');

        // Verify migration success
        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        if (!bookingColumns.contains('title')) {
          throw Exception('Migration v3 to v4 failed: title column not added correctly');
        }

        LogService.info('Migration v3 to v4 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v3 to v4', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
