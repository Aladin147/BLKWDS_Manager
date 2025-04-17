import 'package:sqflite/sqflite.dart';
import 'log_service.dart';

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

      final requiredTables = [
        'gear',
        'member',
        'project',
        'booking',
        'settings',
        'studio',
        'studio_settings',
      ];

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

        switch (table) {
          case 'gear':
            await db.execute('''
              CREATE TABLE gear (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT NOT NULL,
                isOut INTEGER NOT NULL DEFAULT 0,
                description TEXT,
                serialNumber TEXT,
                purchaseDate TEXT
              )
            ''');
            break;

          case 'member':
            await db.execute('''
              CREATE TABLE member (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                role TEXT,
                email TEXT,
                phone TEXT
              )
            ''');
            break;

          case 'project':
            await db.execute('''
              CREATE TABLE project (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                client TEXT,
                notes TEXT
              )
            ''');
            break;

          case 'booking':
            await db.execute('''
              CREATE TABLE booking (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                projectId INTEGER,
                startDate TEXT NOT NULL,
                endDate TEXT NOT NULL,
                isRecordingStudio INTEGER NOT NULL DEFAULT 0,
                isProductionStudio INTEGER NOT NULL DEFAULT 0,
                color TEXT,
                title TEXT,
                studioId INTEGER,
                notes TEXT,
                FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE
              )
            ''');
            break;

          case 'settings':
            await db.execute('''
              CREATE TABLE settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                key TEXT NOT NULL UNIQUE,
                value TEXT NOT NULL
              )
            ''');
            break;

          case 'studio':
            await db.execute('''
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
            break;

          case 'studio_settings':
            await db.execute('''
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
            break;
        }
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

      // Define expected columns for each table
      final expectedColumns = {
        'gear': ['id', 'name', 'category', 'isOut', 'description', 'serialNumber', 'purchaseDate'],
        'member': ['id', 'name', 'role', 'email', 'phone'],
        'project': ['id', 'title', 'client', 'notes'],
        'booking': ['id', 'projectId', 'startDate', 'endDate', 'isRecordingStudio', 'isProductionStudio', 'color', 'title', 'studioId', 'notes'],
        'settings': ['id', 'key', 'value'],
        'studio': ['id', 'name', 'type', 'description', 'features', 'hourlyRate', 'status', 'color'],
        'studio_settings': ['id', 'openingTime', 'closingTime', 'minBookingDuration', 'maxBookingDuration', 'minAdvanceBookingTime', 'maxAdvanceBookingTime', 'cleanupTime', 'allowOverlappingBookings', 'enforceStudioHours'],
      };

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

        // Define column definitions based on table and column name
        String columnDef;

        switch ('${table}_$column') {
          case 'gear_description':
          case 'gear_serialNumber':
          case 'gear_purchaseDate':
          case 'member_email':
          case 'member_phone':
          case 'project_client':
          case 'project_notes':
          case 'booking_color':
          case 'booking_title':
          case 'booking_notes':
          case 'studio_description':
          case 'studio_features':
          case 'studio_color':
            columnDef = 'TEXT DEFAULT NULL';
            break;

          case 'gear_isOut':
          case 'booking_isRecordingStudio':
          case 'booking_isProductionStudio':
          case 'studio_settings_allowOverlappingBookings':
          case 'studio_settings_enforceStudioHours':
            columnDef = 'INTEGER NOT NULL DEFAULT 0';
            break;

          case 'booking_studioId':
          case 'booking_projectId':
            columnDef = 'INTEGER DEFAULT NULL';
            break;

          case 'studio_hourlyRate':
            columnDef = 'REAL DEFAULT NULL';
            break;

          case 'studio_status':
            columnDef = "TEXT NOT NULL DEFAULT 'available'";
            break;

          case 'member_role':
            columnDef = 'TEXT DEFAULT NULL';
            break;

          default:
            // For any other columns, use a generic TEXT type
            columnDef = 'TEXT DEFAULT NULL';
            break;
        }

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
