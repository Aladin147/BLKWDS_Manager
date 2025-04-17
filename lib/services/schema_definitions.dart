import 'package:sqflite/sqflite.dart';

/// SchemaDefinitions
/// Single source of truth for database schema definitions
class SchemaDefinitions {
  /// Get the list of required tables
  static List<String> get requiredTables => [
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

  /// Get the expected columns for each table
  static Map<String, List<String>> get expectedColumns => {
        'gear': [
          'id',
          'name',
          'category',
          'description',
          'serialNumber',
          'purchaseDate',
          'thumbnailPath',
          'isOut',
          'lastNote'
        ],
        'member': ['id', 'name', 'role'],
        'project': ['id', 'title', 'client', 'notes'],
        'project_member': ['projectId', 'memberId'],
        'booking': [
          'id',
          'projectId',
          'title',
          'startDate',
          'endDate',
          'isRecordingStudio',
          'isProductionStudio',
          'studioId',
          'notes',
          'color'
        ],
        'booking_gear': ['bookingId', 'gearId', 'assignedMemberId'],
        'status_note': ['id', 'gearId', 'note', 'timestamp'],
        'activity_log': [
          'id',
          'gearId',
          'memberId',
          'checkedOut',
          'timestamp',
          'note'
        ],
        'settings': ['id', 'key', 'value'],
        'studio': [
          'id',
          'name',
          'type',
          'description',
          'features',
          'hourlyRate',
          'status',
          'color'
        ],
        'studio_settings': [
          'id',
          'openingTime',
          'closingTime',
          'minBookingDuration',
          'maxBookingDuration',
          'minAdvanceBookingTime',
          'maxAdvanceBookingTime',
          'cleanupTime',
          'allowOverlappingBookings',
          'enforceStudioHours'
        ],
      };

  /// Create a table based on its name
  static Future<void> createTable(Database db, String tableName) async {
    switch (tableName) {
      case 'gear':
        await db.execute('''
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
        ''');
        break;

      case 'member':
        await db.execute('''
          CREATE TABLE member (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            role TEXT
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

      case 'project_member':
        await db.execute('''
          CREATE TABLE project_member (
            projectId INTEGER,
            memberId INTEGER,
            PRIMARY KEY (projectId, memberId),
            FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE,
            FOREIGN KEY (memberId) REFERENCES member (id) ON DELETE CASCADE
          )
        ''');
        break;

      case 'booking':
        await db.execute('''
          CREATE TABLE booking (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            projectId INTEGER NOT NULL,
            title TEXT,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            isRecordingStudio INTEGER NOT NULL DEFAULT 0,
            isProductionStudio INTEGER NOT NULL DEFAULT 0,
            studioId INTEGER,
            notes TEXT,
            color TEXT,
            FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE
          )
        ''');
        break;

      case 'booking_gear':
        await db.execute('''
          CREATE TABLE booking_gear (
            bookingId INTEGER,
            gearId INTEGER,
            assignedMemberId INTEGER,
            PRIMARY KEY (bookingId, gearId),
            FOREIGN KEY (bookingId) REFERENCES booking (id) ON DELETE CASCADE,
            FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE,
            FOREIGN KEY (assignedMemberId) REFERENCES member (id) ON DELETE SET NULL
          )
        ''');
        break;

      case 'status_note':
        await db.execute('''
          CREATE TABLE status_note (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gearId INTEGER NOT NULL,
            note TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE
          )
        ''');
        break;

      case 'activity_log':
        await db.execute('''
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

      default:
        throw Exception('Unknown table: $tableName');
    }
  }

  /// Get the column definition for a specific column in a table
  static String getColumnDefinition(String table, String column) {
    switch ('${table}_$column') {
      // Gear table columns
      case 'gear_name':
      case 'gear_category':
        return 'TEXT NOT NULL';
      case 'gear_description':
      case 'gear_serialNumber':
      case 'gear_purchaseDate':
      case 'gear_thumbnailPath':
      case 'gear_lastNote':
        return 'TEXT DEFAULT NULL';
      case 'gear_isOut':
        return 'INTEGER NOT NULL DEFAULT 0';

      // Member table columns
      case 'member_name':
        return 'TEXT NOT NULL';
      case 'member_role':
        return 'TEXT DEFAULT NULL';

      // Project table columns
      case 'project_title':
        return 'TEXT NOT NULL';
      case 'project_client':
      case 'project_notes':
        return 'TEXT DEFAULT NULL';

      // Project Member table columns
      case 'project_member_projectId':
      case 'project_member_memberId':
        return 'INTEGER NOT NULL';

      // Booking table columns
      case 'booking_projectId':
        return 'INTEGER NOT NULL';
      case 'booking_title':
      case 'booking_notes':
      case 'booking_color':
        return 'TEXT DEFAULT NULL';
      case 'booking_startDate':
      case 'booking_endDate':
        return 'TEXT NOT NULL';
      case 'booking_isRecordingStudio':
      case 'booking_isProductionStudio':
        return 'INTEGER NOT NULL DEFAULT 0';
      case 'booking_studioId':
        return 'INTEGER DEFAULT NULL';

      // Booking Gear table columns
      case 'booking_gear_bookingId':
      case 'booking_gear_gearId':
        return 'INTEGER NOT NULL';
      case 'booking_gear_assignedMemberId':
        return 'INTEGER DEFAULT NULL';

      // Status Note table columns
      case 'status_note_gearId':
      case 'status_note_note':
      case 'status_note_timestamp':
        return 'TEXT NOT NULL';

      // Activity Log table columns
      case 'activity_log_gearId':
      case 'activity_log_timestamp':
        return 'TEXT NOT NULL';
      case 'activity_log_memberId':
      case 'activity_log_note':
        return 'TEXT DEFAULT NULL';
      case 'activity_log_checkedOut':
        return 'INTEGER NOT NULL';

      // Settings table columns
      case 'settings_key':
      case 'settings_value':
        return 'TEXT NOT NULL';

      // Studio table columns
      case 'studio_name':
      case 'studio_type':
        return 'TEXT NOT NULL';
      case 'studio_description':
      case 'studio_features':
      case 'studio_color':
        return 'TEXT DEFAULT NULL';
      case 'studio_hourlyRate':
        return 'REAL DEFAULT NULL';
      case 'studio_status':
        return "TEXT NOT NULL DEFAULT 'available'";

      // Studio Settings table columns
      case 'studio_settings_openingTime':
      case 'studio_settings_closingTime':
        return 'TEXT NOT NULL';
      case 'studio_settings_minBookingDuration':
      case 'studio_settings_maxBookingDuration':
      case 'studio_settings_minAdvanceBookingTime':
      case 'studio_settings_maxAdvanceBookingTime':
      case 'studio_settings_cleanupTime':
        return 'INTEGER NOT NULL';
      case 'studio_settings_allowOverlappingBookings':
      case 'studio_settings_enforceStudioHours':
        return 'INTEGER NOT NULL DEFAULT 0';

      // Default for ID columns
      case 'gear_id':
      case 'member_id':
      case 'project_id':
      case 'booking_id':
      case 'status_note_id':
      case 'activity_log_id':
      case 'settings_id':
      case 'studio_id':
      case 'studio_settings_id':
        return 'INTEGER PRIMARY KEY AUTOINCREMENT';

      // Default for any other columns
      default:
        return 'TEXT DEFAULT NULL';
    }
  }
}
