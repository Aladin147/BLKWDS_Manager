import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';
import '../../database_validator.dart';

/// Migration from v6 to v7
/// Adds schema validation and repair
class MigrationV6ToV7 implements Migration {
  @override
  int get fromVersion => 6;

  @override
  int get toVersion => 7;

  @override
  String get description => 'Adds schema validation and repair';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v6 to v7');

    try {
      // This migration doesn't make any schema changes
      // It just validates and repairs the schema if needed
      final missingTables = await DatabaseValidator.validateSchema(db);

      if (missingTables.isNotEmpty) {
        LogService.warning('Found missing tables during migration: $missingTables');
        await DatabaseValidator.repairSchema(db, missingTables);
        LogService.info('Repaired missing tables during migration');
      }

      // Perform comprehensive validation
      final validationResults = await DatabaseValidator.validateComprehensive(db);

      // Remove missing_tables entry since we already handled it
      validationResults.remove('missing_tables');

      // Repair missing columns if needed
      if (validationResults.isNotEmpty) {
        LogService.warning('Comprehensive validation found issues during migration: $validationResults');
        await DatabaseValidator.repairAllColumns(db, validationResults);
        LogService.info('Repaired missing columns during migration');
      }

      LogService.info('Migration v6 to v7 completed successfully');
      return true;
    } catch (e, stackTrace) {
      LogService.error('Error during migration v6 to v7', e, stackTrace);
      // Don't rethrow - we want the migration to continue even if validation fails
      // This is different from other migrations where we want to roll back on failure
      return false;
    }
  }
}
