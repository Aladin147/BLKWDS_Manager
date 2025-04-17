import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';
import '../../schema_definitions.dart';

/// Migration from v7 to v8
/// Ensures all tables use the schema definitions as the single source of truth
class MigrationV7ToV8 implements Migration {
  @override
  int get fromVersion => 7;

  @override
  int get toVersion => 8;

  @override
  String get description => 'Ensures all tables use the schema definitions as the single source of truth';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v7 to v8');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Get all existing tables
        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final existingTables = tableResult.map((t) => t['name'] as String).toList();
        
        // Filter out system tables
        final userTables = existingTables.where(
          (table) => !table.startsWith('sqlite_') && !table.startsWith('android_')
        ).toList();
        
        // Check each table against the schema definitions
        for (final table in userTables) {
          // Skip tables that aren't in our schema definitions
          if (!SchemaDefinitions.expectedColumns.containsKey(table)) {
            LogService.warning('Table $table is not in schema definitions, skipping');
            continue;
          }
          
          // Get the expected columns for this table
          final expectedColumns = SchemaDefinitions.expectedColumns[table]!;
          
          // Get the actual columns in the table
          final columnResult = await txn.rawQuery('PRAGMA table_info($table)');
          final existingColumns = columnResult.map((col) => col['name'] as String).toList();
          
          // Find missing columns
          final missingColumns = expectedColumns.where((col) => !existingColumns.contains(col)).toList();
          
          // Add missing columns
          for (final column in missingColumns) {
            LogService.info('Adding missing column $column to table $table');
            final columnDef = SchemaDefinitions.getColumnDefinition(table, column);
            await txn.execute('ALTER TABLE $table ADD COLUMN $column $columnDef');
          }
          
          // Log the results
          if (missingColumns.isNotEmpty) {
            LogService.info('Added ${missingColumns.length} missing columns to table $table');
          } else {
            LogService.info('Table $table has all expected columns');
          }
        }
        
        // Create any missing tables
        final requiredTables = SchemaDefinitions.requiredTables;
        final missingTables = requiredTables.where((table) => !existingTables.contains(table)).toList();
        
        for (final table in missingTables) {
          LogService.info('Creating missing table $table');
          await SchemaDefinitions.createTable(txn, table);
        }
        
        // Log the results
        if (missingTables.isNotEmpty) {
          LogService.info('Created ${missingTables.length} missing tables');
        } else {
          LogService.info('All required tables exist');
        }
        
        // Store the database version in the settings table
        await txn.delete(
          'settings',
          where: 'key = ?',
          whereArgs: ['database_version'],
        );
        
        await txn.insert('settings', {
          'key': 'database_version',
          'value': '8',
        });
        
        LogService.info('Migration v7 to v8 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v7 to v8', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
