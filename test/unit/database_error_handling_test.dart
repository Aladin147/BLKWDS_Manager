import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/services/database/database_error_handler.dart';
import 'package:blkwds_manager/services/database/db_service_wrapper.dart';
import 'package:blkwds_manager/services/database/errors/errors.dart';

void main() {
  // Initialize sqflite_ffi for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    // Create a test database
    databaseFactory = databaseFactoryFfi;
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE test_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            value INTEGER
          )
        ''');
      },
    );
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('DatabaseErrorHandler', () {
    test('classifyError should classify database errors correctly', () {
      // Test connection error
      final connectionError = DatabaseErrorHandler.classifyError(
        Exception('database is locked'),
        'test_operation',
      );
      expect(connectionError, isA<ConnectionError>());
      expect(connectionError.isTransient, isTrue);

      // Test constraint error
      final constraintError = DatabaseErrorHandler.classifyError(
        Exception('UNIQUE constraint failed: test_table.name'),
        'test_operation',
        table: 'test_table',
      );
      expect(constraintError, isA<ConstraintError>());
      expect(constraintError.isTransient, isFalse);

      // Test schema error
      final schemaError = DatabaseErrorHandler.classifyError(
        Exception('no such table: non_existent_table'),
        'test_operation',
      );
      expect(schemaError, isA<SchemaError>());
      expect(schemaError.isTransient, isFalse);

      // Test query error
      final queryError = DatabaseErrorHandler.classifyError(
        Exception('syntax error'),
        'test_operation',
        query: 'SELECT * FORM test_table', // Intentional typo
      );
      expect(queryError, isA<QueryError>());
      expect(queryError.isTransient, isFalse);

      // Test unknown error
      final unknownError = DatabaseErrorHandler.classifyError(
        Exception('unknown error'),
        'test_operation',
      );
      expect(unknownError, isA<DatabaseError>());
      expect(unknownError.isTransient, isFalse);
    });

    test('isTransientError should identify transient errors correctly', () {
      expect(DatabaseErrorHandler.isTransientError(Exception('database is locked')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('database is busy')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('disk i/o error')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('connection')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('timeout')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('syntax error')), isFalse);
      expect(DatabaseErrorHandler.isTransientError(Exception('no such table')), isFalse);
      expect(DatabaseErrorHandler.isTransientError(Exception('constraint failed')), isFalse);
    });
  });

  group('DBServiceWrapper', () {
    test('query should execute a query successfully', () async {
      // Insert test data
      await db.insert('test_table', {'name': 'Test 1', 'value': 100});
      await db.insert('test_table', {'name': 'Test 2', 'value': 200});

      // Query using the wrapper
      final result = await DBServiceWrapper.query(
        db,
        'test_table',
        operationName: 'test_query',
      );

      expect(result, isNotEmpty);
      expect(result.length, equals(2));
      expect(result[0]['name'], equals('Test 1'));
      expect(result[1]['name'], equals('Test 2'));
    });

    test('insert should insert data successfully', () async {
      // Insert using the wrapper
      final id = await DBServiceWrapper.insert(
        db,
        'test_table',
        {'name': 'Test 3', 'value': 300},
        operationName: 'test_insert',
      );

      expect(id, isPositive);

      // Verify the data was inserted
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result[0]['name'], equals('Test 3'));
      expect(result[0]['value'], equals(300));
    });

    test('update should update data successfully', () async {
      // Insert test data
      final id = await db.insert('test_table', {'name': 'Test 4', 'value': 400});

      // Update using the wrapper
      final count = await DBServiceWrapper.update(
        db,
        'test_table',
        {'name': 'Updated Test 4', 'value': 450},
        where: 'id = ?',
        whereArgs: [id],
        operationName: 'test_update',
      );

      expect(count, equals(1));

      // Verify the data was updated
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result[0]['name'], equals('Updated Test 4'));
      expect(result[0]['value'], equals(450));
    });

    test('delete should delete data successfully', () async {
      // Insert test data
      final id = await db.insert('test_table', {'name': 'Test 5', 'value': 500});

      // Delete using the wrapper
      final count = await DBServiceWrapper.delete(
        db,
        'test_table',
        where: 'id = ?',
        whereArgs: [id],
        operationName: 'test_delete',
      );

      expect(count, equals(1));

      // Verify the data was deleted
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isEmpty);
    });

    test('executeTransaction should execute a transaction successfully', () async {
      // Execute a transaction using the wrapper
      final result = await DBServiceWrapper.executeTransaction(
        db,
        (txn) async {
          // Insert multiple records in a transaction
          await txn.insert('test_table', {'name': 'Txn 1', 'value': 1000});
          await txn.insert('test_table', {'name': 'Txn 2', 'value': 2000});
          await txn.insert('test_table', {'name': 'Txn 3', 'value': 3000});

          // Return the count of records
          final count = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM test_table'));
          return count;
        },
        'test_transaction',
      );

      expect(result, isNotNull);
      expect(result, isPositive);

      // Verify the data was inserted
      final queryResult = await db.query('test_table', where: 'name LIKE ?', whereArgs: ['Txn %']);
      expect(queryResult.length, equals(3));
    });
  });
}
