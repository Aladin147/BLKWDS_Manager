import 'package:sqflite/sqflite.dart';
import 'log_service.dart';

/// DatabaseValidator
/// Validates and repairs the database schema
class DatabaseValidator {
  /// Required tables that must exist in the database
  static const List<String> requiredTables = [
    'gear',
    'member',
    'project',
    'project_member',
    'booking',
    'booking_gear',
    'status_note',
    'activity_log',
    'settings',
    'studio',
    'studio_settings',
  ];

  /// Table definitions for automatic repair
  static final Map<String, String> tableDefinitions = {
    'gear': '''
      CREATE TABLE gear (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        serialNumber TEXT,
        purchaseDate TEXT,
        thumbnailPath TEXT,
        isOut INTEGER NOT NULL DEFAULT 0,
        lastNote TEXT
      )
    ''',
    'member': '''
      CREATE TABLE member (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT
      )
    ''',
    'project': '''
      CREATE TABLE project (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        client TEXT,
        notes TEXT
      )
    ''',
    'project_member': '''
      CREATE TABLE project_member (
        projectId INTEGER,
        memberId INTEGER,
        PRIMARY KEY (projectId, memberId),
        FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE,
        FOREIGN KEY (memberId) REFERENCES member (id) ON DELETE CASCADE
      )
    ''',
    'booking': '''
      CREATE TABLE booking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL,
        title TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isRecordingStudio INTEGER NOT NULL DEFAULT 0,
        isProductionStudio INTEGER NOT NULL DEFAULT 0,
        color TEXT,
        studioId INTEGER,
        notes TEXT,
        FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE
      )
    ''',
    'booking_gear': '''
      CREATE TABLE booking_gear (
        bookingId INTEGER,
        gearId INTEGER,
        assignedMemberId INTEGER,
        PRIMARY KEY (bookingId, gearId),
        FOREIGN KEY (bookingId) REFERENCES booking (id) ON DELETE CASCADE,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE,
        FOREIGN KEY (assignedMemberId) REFERENCES member (id) ON DELETE SET NULL
      )
    ''',
    'status_note': '''
      CREATE TABLE status_note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER NOT NULL,
        note TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE
      )
    ''',
    'activity_log': '''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER NOT NULL,
        memberId INTEGER,
        checkedOut INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE,
        FOREIGN KEY (memberId) REFERENCES member (id) ON DELETE SET NULL
      )
    ''',
    'settings': '''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''',
    'studio': '''
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
    ''',
    'studio_settings': '''
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
    ''',
  };

  /// Default studio settings
  static final Map<String, dynamic> defaultStudioSettings = {
    'openingTime': '9:0',
    'closingTime': '22:0',
    'minBookingDuration': 60,
    'maxBookingDuration': 480,
    'minAdvanceBookingTime': 1,
    'maxAdvanceBookingTime': 90,
    'cleanupTime': 30,
    'allowOverlappingBookings': 0,
    'enforceStudioHours': 1,
  };

  /// Default studios
  static final List<Map<String, dynamic>> defaultStudios = [
    {
      'name': 'Recording Studio',
      'type': 'recording',
      'description': 'Main recording studio space',
      'status': 'available',
    },
    {
      'name': 'Production Studio',
      'type': 'production',
      'description': 'Main production studio space',
      'status': 'available',
    },
  ];

  /// Validate the database schema
  /// Returns a list of missing tables
  static Future<List<String>> validateSchema(Database db) async {
    LogService.info('Validating database schema');

    // Get all tables in the database
    final tableResult = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final existingTables = tableResult.map((t) => t['name'] as String).toList();

    // Filter out SQLite system tables
    final filteredTables = existingTables.where((t) => !t.startsWith('sqlite_')).toList();

    LogService.info('Found tables: $filteredTables');

    // Check for missing tables
    final missingTables = requiredTables.where((t) => !filteredTables.contains(t)).toList();

    if (missingTables.isEmpty) {
      LogService.info('All required tables exist');
    } else {
      LogService.warning('Missing tables: $missingTables');
    }

    return missingTables;
  }

  /// Repair the database schema
  /// Creates missing tables and adds default data
  static Future<void> repairSchema(Database db, List<String> missingTables) async {
    LogService.info('Repairing database schema');

    // Begin transaction for atomicity
    await db.transaction((txn) async {
      try {
        // Create missing tables
        for (final tableName in missingTables) {
          if (tableDefinitions.containsKey(tableName)) {
            LogService.info('Creating missing table: $tableName');
            await txn.execute(tableDefinitions[tableName]!);
          } else {
            LogService.error('No definition found for table: $tableName');
          }
        }

        // Add default data if needed
        if (missingTables.contains('studio_settings')) {
          LogService.info('Adding default studio settings');
          await txn.insert('studio_settings', defaultStudioSettings);
        }

        if (missingTables.contains('studio')) {
          LogService.info('Adding default studios');
          for (final studio in defaultStudios) {
            await txn.insert('studio', studio);
          }
        }

        LogService.info('Schema repair completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during schema repair', e, stackTrace);
        rethrow; // This will roll back the transaction
      }
    });
  }

  /// Validate and repair the database schema
  /// This is the main method that should be called during app initialization
  static Future<bool> validateAndRepair(Database db) async {
    try {
      bool repairPerformed = false;

      // Validate schema
      final missingTables = await validateSchema(db);

      // Repair schema if needed
      if (missingTables.isNotEmpty) {
        await repairSchema(db, missingTables);
        LogService.info('Database tables repaired successfully');
        repairPerformed = true;
      }

      // Validate columns
      final validationResults = await validateComprehensive(db);

      // Remove missing_tables entry since we already handled it
      validationResults.remove('missing_tables');

      // Repair missing columns if needed
      if (validationResults.isNotEmpty) {
        await repairAllColumns(db, validationResults);
        LogService.info('Database columns repaired successfully');
        repairPerformed = true;
      }

      return repairPerformed;
    } catch (e, stackTrace) {
      LogService.error('Error during schema validation and repair', e, stackTrace);
      return false;
    }
  }

  /// Validate column structure for a specific table
  /// Returns a list of missing columns
  static Future<List<String>> validateTableColumns(
    Database db,
    String tableName,
    List<String> requiredColumns
  ) async {
    try {
      // Get columns for the table
      final result = await db.rawQuery('PRAGMA table_info($tableName)');
      final existingColumns = result.map((col) => col['name'] as String).toList();

      // Check for missing columns
      final missingColumns = requiredColumns.where((c) => !existingColumns.contains(c)).toList();

      if (missingColumns.isEmpty) {
        LogService.info('All required columns exist in table: $tableName');
      } else {
        LogService.warning('Missing columns in table $tableName: $missingColumns');
      }

      return missingColumns;
    } catch (e, stackTrace) {
      LogService.error('Error validating columns for table: $tableName', e, stackTrace);
      return [];
    }
  }

  /// Column definitions for automatic repair
  static final Map<String, Map<String, String>> columnDefinitions = {
    'booking': {
      'studioId': 'ALTER TABLE booking ADD COLUMN studioId INTEGER DEFAULT NULL',
      'notes': 'ALTER TABLE booking ADD COLUMN notes TEXT DEFAULT NULL',
    },
    // Add more tables and their column definitions as needed
  };

  /// Repair missing columns in a table
  static Future<void> repairTableColumns(Database db, String tableName, List<String> missingColumns) async {
    LogService.info('Repairing columns in table: $tableName');

    // Begin transaction for atomicity
    await db.transaction((txn) async {
      try {
        // Check if we have definitions for this table
        if (!columnDefinitions.containsKey(tableName)) {
          LogService.warning('No column definitions found for table: $tableName');
          return;
        }

        // Add missing columns
        for (final columnName in missingColumns) {
          if (columnDefinitions[tableName]!.containsKey(columnName)) {
            LogService.info('Adding missing column: $columnName to table: $tableName');
            await txn.execute(columnDefinitions[tableName]![columnName]!);
          } else {
            LogService.warning('No definition found for column: $columnName in table: $tableName');
          }
        }

        LogService.info('Column repair completed successfully for table: $tableName');
      } catch (e, stackTrace) {
        LogService.error('Error during column repair for table: $tableName', e, stackTrace);
        rethrow; // This will roll back the transaction
      }
    });
  }

  /// Repair all missing columns identified in validation
  static Future<void> repairAllColumns(Database db, Map<String, List<String>> missingColumnsMap) async {
    for (final entry in missingColumnsMap.entries) {
      final tableName = entry.key;
      final missingColumns = entry.value;

      // Skip missing_tables entry
      if (tableName == 'missing_tables') continue;

      await repairTableColumns(db, tableName, missingColumns);
    }
  }

  /// Perform a comprehensive validation of the database
  /// Checks all tables and their required columns
  static Future<Map<String, List<String>>> validateComprehensive(Database db) async {
    final Map<String, List<String>> validationResults = {};

    // Define required columns for each table
    final Map<String, List<String>> requiredColumns = {
      'studio': ['id', 'name', 'type', 'status'],
      'studio_settings': [
        'id', 'openingTime', 'closingTime', 'minBookingDuration',
        'maxBookingDuration', 'minAdvanceBookingTime', 'maxAdvanceBookingTime',
        'cleanupTime', 'allowOverlappingBookings', 'enforceStudioHours'
      ],
      'booking': ['id', 'projectId', 'startDate', 'endDate', 'studioId'],
      // Add more tables and their required columns as needed
    };

    // Validate schema first
    final missingTables = await validateSchema(db);
    if (missingTables.isNotEmpty) {
      validationResults['missing_tables'] = missingTables;
    }

    // Validate columns for each table
    for (final entry in requiredColumns.entries) {
      final tableName = entry.key;
      final columns = entry.value;

      // Skip tables that don't exist
      if (missingTables.contains(tableName)) {
        continue;
      }

      final missingColumns = await validateTableColumns(db, tableName, columns);
      if (missingColumns.isNotEmpty) {
        validationResults[tableName] = missingColumns;
      }
    }

    return validationResults;
  }
}
