import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/services/schema_definitions.dart';
import 'package:blkwds_manager/services/log_service.dart';

/// Helper class for creating a test database
class MockDatabase {
  /// Create a test database in memory
  static Future<Database> createTestDatabase() async {
    // Open an in-memory database
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Create all required tables
          for (final table in SchemaDefinitions.requiredTables) {
            await SchemaDefinitions.createTable(db, table);
          }

          // Insert some test data
          await _insertTestData(db);
        },
      ),
    );

    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    LogService.info('Foreign key constraints enabled for test database');

    return db;
  }

  /// Insert test data into the database
  static Future<void> _insertTestData(Database db) async {
    // Insert a test project
    await db.insert('project', {
      'id': 1,
      'title': 'Test Project',
      'client': 'Test Client',
      'notes': 'Test Notes',
    });

    // Insert a test member
    await db.insert('member', {
      'id': 1,
      'name': 'Test Member',
      'role': 'Test Role',
    });

    // Insert a test gear item
    await db.insert('gear', {
      'id': 1,
      'name': 'Test Gear',
      'category': 'Test Category',
      'isOut': 0,
    });

    // Insert test studio settings
    await db.insert('studio_settings', {
      'id': 1,
      'openingTime': '8:0',
      'closingTime': '18:0',
      'minBookingDuration': 60,
      'maxBookingDuration': 480,
      'minAdvanceBookingTime': 24,
      'maxAdvanceBookingTime': 720,
      'cleanupTime': 30,
      'allowOverlappingBookings': 0,
      'enforceStudioHours': 1,
    });

    // Insert test studio
    await db.insert('studio', {
      'id': 1,
      'name': 'Recording Studio',
      'type': 'recording',
      'status': 'available',
    });

    // Insert test studio
    await db.insert('studio', {
      'id': 2,
      'name': 'Production Studio',
      'type': 'production',
      'status': 'available',
    });

    LogService.info('Test database created with initial data');
  }
}
