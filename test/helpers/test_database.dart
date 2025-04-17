import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/schema_definitions.dart';

/// A helper class for managing test databases
class TestDatabase {
  /// The database instance
  late Database db;

  /// Create a new test database
  ///
  /// This creates an in-memory database for testing.
  /// [version] is the database version to create.
  /// [onCreate] is a callback to execute when the database is created.
  static Future<Database> createTestDatabase({
    int version = 1,
    Future<void> Function(Database db, int version)? onCreate,
  }) async {
    // Initialize sqflite_ffi
    sqfliteFfiInit();

    // Use the ffi database factory
    databaseFactory = databaseFactoryFfi;

    // Create an in-memory database
    return await openDatabase(
      inMemoryDatabasePath,
      version: version,
      onCreate: onCreate ?? _defaultOnCreate,
    );
  }

  /// Default onCreate callback
  ///
  /// This creates the default schema for testing.
  static Future<void> _defaultOnCreate(Database db, int version) async {
    // Create all required tables
    for (final tableName in SchemaDefinitions.requiredTables) {
      await SchemaDefinitions.createTable(db, tableName);
    }
  }

  /// Initialize the test database
  ///
  /// This creates an in-memory database for testing.
  Future<void> initialize() async {
    db = await createTestDatabase();
  }

  /// Close the test database
  Future<void> close() async {
    await db.close();
  }

  /// Clear all data from the test database
  Future<void> clearAllData() async {
    await db.transaction((txn) async {
      // Get all table names
      final tables = await txn.query(
        'sqlite_master',
        where: 'type = ?',
        whereArgs: ['table'],
        columns: ['name'],
      );

      // Delete all data from each table
      for (final table in tables) {
        final tableName = table['name'] as String;
        if (tableName != 'android_metadata' &&
            tableName != 'sqlite_sequence' &&
            !tableName.startsWith('sqlite_')) {
          await txn.delete(tableName);
        }
      }
    });
  }
}
