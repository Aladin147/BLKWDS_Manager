import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';

/// Migration from v1 to v2
/// Adds description, serialNumber, and purchaseDate columns to gear table
class MigrationV1ToV2 implements Migration {
  @override
  int get fromVersion => 1;

  @override
  int get toVersion => 2;

  @override
  String get description => 'Adds description, serialNumber, and purchaseDate columns to gear table';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v1 to v2');

    // Begin transaction for atomicity
    bool success = false;
    await db.transaction((txn) async {
      try {
        // Add new columns to gear table
        await txn.execute('ALTER TABLE gear ADD COLUMN description TEXT DEFAULT NULL');
        await txn.execute('ALTER TABLE gear ADD COLUMN serialNumber TEXT DEFAULT NULL');
        await txn.execute('ALTER TABLE gear ADD COLUMN purchaseDate TEXT DEFAULT NULL');

        // Verify migration success
        final result = await txn.rawQuery('PRAGMA table_info(gear)');
        final columns = result.map((col) => col['name'] as String).toList();

        if (!columns.contains('description') ||
            !columns.contains('serialNumber') ||
            !columns.contains('purchaseDate')) {
          throw Exception('Migration v1 to v2 failed: columns not added correctly');
        }

        LogService.info('Migration v1 to v2 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v1 to v2', e, stackTrace);
        rethrow; // This will roll back the transaction
      }
    });

    return success;
  }
}
