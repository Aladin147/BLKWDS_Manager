import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/services/database/db_service_wrapper.dart';
import 'package:blkwds_manager/services/database/errors/errors.dart';
import '../../../helpers/test_database.dart';

void main() {
  late Database db;

  setUp(() async {
    // Create a test database
    db = await TestDatabase.createTestDatabase();

    // Create a test table
    await db.execute('''
      CREATE TABLE test_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value INTEGER
      )
    ''');
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('DBServiceWrapper', () {
    test('should execute query successfully', () async {
      // Arrange
      await db.insert('test_table', {'name': 'Test 1', 'value': 100});
      await db.insert('test_table', {'name': 'Test 2', 'value': 200});

      // Act
      final result = await DBServiceWrapper.query(
        db,
        'test_table',
        operationName: 'test_query',
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(2));
      expect(result[0]['name'], equals('Test 1'));
      expect(result[1]['name'], equals('Test 2'));
    });

    test('should insert data successfully', () async {
      // Act
      final id = await DBServiceWrapper.insert(
        db,
        'test_table',
        {'name': 'Test 3', 'value': 300},
        operationName: 'test_insert',
      );

      // Assert
      expect(id, isPositive);

      // Verify the data was inserted
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result[0]['name'], equals('Test 3'));
      expect(result[0]['value'], equals(300));
    });

    test('should update data successfully', () async {
      // Arrange
      final id = await db.insert('test_table', {'name': 'Test 4', 'value': 400});

      // Act
      final count = await DBServiceWrapper.update(
        db,
        'test_table',
        {'name': 'Updated Test 4', 'value': 450},
        where: 'id = ?',
        whereArgs: [id],
        operationName: 'test_update',
      );

      // Assert
      expect(count, equals(1));

      // Verify the data was updated
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result[0]['name'], equals('Updated Test 4'));
      expect(result[0]['value'], equals(450));
    });

    test('should delete data successfully', () async {
      // Arrange
      final id = await db.insert('test_table', {'name': 'Test 5', 'value': 500});

      // Act
      final count = await DBServiceWrapper.delete(
        db,
        'test_table',
        where: 'id = ?',
        whereArgs: [id],
        operationName: 'test_delete',
      );

      // Assert
      expect(count, equals(1));

      // Verify the data was deleted
      final result = await db.query('test_table', where: 'id = ?', whereArgs: [id]);
      expect(result, isEmpty);
    });

    test('should execute raw query successfully', () async {
      // Arrange
      await db.insert('test_table', {'name': 'Test 6', 'value': 600});
      await db.insert('test_table', {'name': 'Test 7', 'value': 700});

      // Act
      final result = await DBServiceWrapper.rawQuery(
        db,
        'SELECT * FROM test_table WHERE value > ?',
        [650],
        'test_raw_query',
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(1));
      expect(result[0]['name'], equals('Test 7'));
      expect(result[0]['value'], equals(700));
    });

    test('should execute transaction successfully', () async {
      // Act
      final result = await DBServiceWrapper.executeTransaction(
        db,
        (txn) async {
          // Insert multiple records in a transaction
          await txn.insert('test_table', {'name': 'Txn 1', 'value': 1000});
          await txn.insert('test_table', {'name': 'Txn 2', 'value': 2000});

          // Return the count of records
          final count = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM test_table'));
          return count;
        },
        'test_transaction',
      );

      // Assert
      expect(result, equals(2));

      // Verify the data was inserted
      final queryResult = await db.query('test_table');
      expect(queryResult.length, equals(2));
      expect(queryResult[0]['name'], equals('Txn 1'));
      expect(queryResult[1]['name'], equals('Txn 2'));
    });

    test('should handle query errors correctly', () async {
      // Act & Assert
      expect(
        () => DBServiceWrapper.rawQuery(
          db,
          'SELECT * FROM non_existent_table',
          null,
          'test_error_query',
        ),
        throwsA(isA<SchemaError>()),
      );
    });

    test('should handle constraint errors correctly', () async {
      // Arrange
      // Create a table with a unique constraint directly
      await db.execute('''
        CREATE TABLE unique_test (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          value INTEGER
        )
      ''');
      await db.insert('unique_test', {'name': 'Unique Name', 'value': 100});

      // Act & Assert
      expect(
        () => DBServiceWrapper.insert(
          db,
          'unique_test',
          {'name': 'Unique Name', 'value': 200},
          operationName: 'test_constraint_error',
        ),
        throwsA(isA<ConstraintError>()),
      );
    });
  });
}
