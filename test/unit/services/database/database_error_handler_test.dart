import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/database/database_error_handler.dart';
import 'package:blkwds_manager/services/database/errors/errors.dart';

void main() {
  group('DatabaseErrorHandler', () {
    test('should classify connection error correctly', () {
      // Arrange
      final error = Exception('database is locked');

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
      );

      // Assert
      expect(classifiedError, isA<ConnectionError>());
      expect(classifiedError.isTransient, isTrue);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.message, contains('database is locked'));
    });

    test('should classify constraint error correctly', () {
      // Arrange
      final error = Exception('UNIQUE constraint failed: table.column');

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
        table: 'test_table',
      );

      // Assert
      expect(classifiedError, isA<ConstraintError>());
      expect(classifiedError.isTransient, isFalse);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.table, equals('test_table'));
      expect(classifiedError.message, contains('UNIQUE constraint failed'));

      // Note: The constraint extraction depends on the exact error message format
      // which may vary between SQLite versions and platforms
    });

    test('should classify schema error correctly', () {
      // Arrange
      final error = Exception('no such table: non_existent_table');

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
      );

      // Assert
      expect(classifiedError, isA<SchemaError>());
      expect(classifiedError.isTransient, isFalse);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.message, contains('no such table'));
    });

    test('should classify query error correctly', () {
      // Arrange
      final error = Exception('syntax error');
      final query = 'SELECT * FORM test_table'; // Intentional typo

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
        query: query,
      );

      // Assert
      expect(classifiedError, isA<QueryError>());
      expect(classifiedError.isTransient, isFalse);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.message, contains('syntax error'));

      // Check query info
      final queryError = classifiedError as QueryError;
      expect(queryError.query, equals(query));
    });

    // Note: DatabaseException is abstract and can't be instantiated directly
    // We'll test with a generic Exception instead
    test('should classify generic database error correctly', () {
      // Arrange
      final error = Exception('database error');

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
        table: 'test_table',
      );

      // Assert
      expect(classifiedError, isA<DatabaseError>());
      expect(classifiedError.isTransient, isFalse);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.table, equals('test_table'));
      expect(classifiedError.message, contains('database error'));
    });

    test('should classify unknown error correctly', () {
      // Arrange
      final error = Exception('unknown error');

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        error,
        'test_operation',
      );

      // Assert
      expect(classifiedError, isA<DatabaseError>());
      expect(classifiedError.isTransient, isFalse);
      expect(classifiedError.operation, equals('test_operation'));
      expect(classifiedError.message, contains('unknown error'));
    });

    test('should return original error if already a DatabaseError', () {
      // Arrange
      final originalError = DatabaseError(
        'original error',
        'original_operation',
        table: 'original_table',
      );

      // Act
      final classifiedError = DatabaseErrorHandler.classifyError(
        originalError,
        'test_operation',
        table: 'test_table',
      );

      // Assert
      expect(classifiedError, same(originalError));
      expect(classifiedError.operation, equals('original_operation'));
      expect(classifiedError.table, equals('original_table'));
    });

    test('should identify transient errors correctly', () {
      // Test transient errors
      expect(DatabaseErrorHandler.isTransientError(Exception('database is locked')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('database is busy')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('disk i/o error')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('disk full')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('connection')), isTrue);
      expect(DatabaseErrorHandler.isTransientError(Exception('timeout')), isTrue);

      // Test non-transient errors
      expect(DatabaseErrorHandler.isTransientError(Exception('syntax error')), isFalse);
      expect(DatabaseErrorHandler.isTransientError(Exception('no such table')), isFalse);
      expect(DatabaseErrorHandler.isTransientError(Exception('constraint failed')), isFalse);

      // Test DatabaseError with isTransient flag
      expect(DatabaseErrorHandler.isTransientError(
        DatabaseError('error', 'operation', isTransient: true)
      ), isTrue);
      expect(DatabaseErrorHandler.isTransientError(
        DatabaseError('error', 'operation', isTransient: false)
      ), isFalse);
    });

    test('should handle error and return DatabaseError', () {
      // Arrange
      final error = Exception('test error');
      final stackTrace = StackTrace.current;

      // Act
      final handledError = DatabaseErrorHandler.handleError(
        error,
        'test_operation',
        table: 'test_table',
        query: 'SELECT * FROM test_table',
        parameters: [1, 2, 3],
        stackTrace: stackTrace,
      );

      // Assert
      expect(handledError, isA<DatabaseError>());
      expect(handledError.operation, equals('test_operation'));
      expect(handledError.table, equals('test_table'));
      expect(handledError.message, contains('test error'));
      expect(handledError.originalError, same(error));
      expect(handledError.stackTrace, same(stackTrace));
    });
  });
}
