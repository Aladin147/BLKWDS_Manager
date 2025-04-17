import 'package:sqflite/sqflite.dart';
import 'log_service.dart';
import 'schema_definitions.dart';

/// DatabaseValidator
/// Validates and repairs the database schema
class DatabaseValidator {
  /// Validate and repair the database schema
  static Future<bool> validateAndRepair(Database db) async {
    try {
      final missingTables = await validateSchema(db);
      if (missingTables.isNotEmpty) {
        await repairSchema(db, missingTables);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      LogService.error('Error validating and repairing database schema', e, stackTrace);
      return false;
    }
  }

  /// Validate the database schema
  static Future<List<String>> validateSchema(Database db) async {
    try {
      final tableResult = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final existingTables = tableResult.map((t) => t['name'] as String).toList();

      final requiredTables = SchemaDefinitions.requiredTables;

      final missingTables = requiredTables.where((table) => !existingTables.contains(table)).toList();

      if (missingTables.isNotEmpty) {
        LogService.warning('Missing tables: $missingTables');
      } else {
        LogService.info('All required tables exist');
      }

      return missingTables;
    } catch (e, stackTrace) {
      LogService.error('Error validating database schema', e, stackTrace);
      return [];
    }
  }

  /// Repair the database schema
  static Future<void> repairSchema(Database db, List<String> missingTables) async {
    try {
      for (final table in missingTables) {
        LogService.info('Repairing missing table: $table');
        await SchemaDefinitions.createTable(db, table);
      }

      LogService.info('Schema repair completed');
    } catch (e, stackTrace) {
      LogService.error('Error repairing database schema', e, stackTrace);
      rethrow;
    }
  }

  /// Perform comprehensive validation of the database
  static Future<Map<String, dynamic>> validateComprehensive(Database db) async {
    try {
      final results = <String, dynamic>{};

      // Check for missing tables
      final missingTables = await validateSchema(db);
      if (missingTables.isNotEmpty) {
        results['missing_tables'] = missingTables;
      }

      // Check for missing columns in each table
      final tableResult = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final existingTables = tableResult.map((t) => t['name'] as String).toList();

      // Get expected columns for each table from SchemaDefinitions
      final expectedColumns = SchemaDefinitions.expectedColumns;

      // Check each existing table for missing columns
      for (final table in existingTables) {
        // Skip system tables
        if (table.startsWith('sqlite_') || table.startsWith('android_')) {
          continue;
        }

        // Skip tables that aren't in our expected list
        if (!expectedColumns.containsKey(table)) {
          continue;
        }

        final columnResult = await db.rawQuery('PRAGMA table_info($table)');
        final existingColumns = columnResult.map((col) => col['name'] as String).toList();

        final missingColumns = expectedColumns[table]!.where((col) => !existingColumns.contains(col)).toList();

        if (missingColumns.isNotEmpty) {
          results['missing_columns_$table'] = missingColumns;
        }
      }

      return results;
    } catch (e, stackTrace) {
      LogService.error('Error performing comprehensive validation', e, stackTrace);
      return {};
    }
  }

  /// Repair all missing columns
  static Future<void> repairAllColumns(Database db, Map<String, dynamic> validationResults) async {
    try {
      for (final entry in validationResults.entries) {
        final key = entry.key;

        if (key.startsWith('missing_columns_')) {
          final table = key.substring('missing_columns_'.length);
          final missingColumns = entry.value as List;

          await repairColumns(db, table, missingColumns.cast<String>());
        }
      }

      LogService.info('Column repair completed');
    } catch (e, stackTrace) {
      LogService.error('Error repairing columns', e, stackTrace);
      rethrow;
    }
  }

  /// Repair missing columns in a table
  static Future<void> repairColumns(Database db, String table, List<String> missingColumns) async {
    try {
      for (final column in missingColumns) {
        LogService.info('Repairing missing column: $column in table $table');

        // Get column definition from SchemaDefinitions
        final columnDef = SchemaDefinitions.getColumnDefinition(table, column);

        // Add the column to the table
        await db.execute('ALTER TABLE $table ADD COLUMN $column $columnDef');
      }

      LogService.info('Column repair for table $table completed');
    } catch (e, stackTrace) {
      LogService.error('Error repairing columns for table $table', e, stackTrace);
      rethrow;
    }
  }
}
