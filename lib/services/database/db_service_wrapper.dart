import 'package:sqflite/sqflite.dart';
import '../log_service.dart';
import 'database_error_handler.dart';
import 'database_retry.dart';
import 'errors/errors.dart';

/// Database service wrapper
///
/// This class provides a wrapper around the database service with enhanced error handling.
class DBServiceWrapper {
  /// Execute a database query with error handling and retry
  ///
  /// This method executes a database query with error handling and retry.
  /// It will retry the query if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [operation] is the operation to execute
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<T> executeQuery<T>(
    Database db,
    Future<T> Function() operation,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retry(
        operation,
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a database transaction with error handling and retry
  ///
  /// This method executes a database transaction with error handling and retry.
  /// It will retry the transaction if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [operation] is the operation to execute
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<T> executeTransaction<T>(
    Database db,
    Future<T> Function(Transaction txn) operation,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retryWithTransaction(
        db,
        operation,
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // If the error is already a DatabaseError, rethrow it
      if (error is DatabaseError) {
        throw error;
      }

      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        stackTrace: stackTrace,
      );

      // Log the transaction failure
      LogService.error(
        'Transaction failed: $operationName',
        dbError,
        stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a raw SQL query with error handling and retry
  ///
  /// This method executes a raw SQL query with error handling and retry.
  /// It will retry the query if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [query] is the SQL query to execute
  /// [parameters] are the query parameters
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<List<Map<String, dynamic>>> rawQuery(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retry(
        () => db.rawQuery(query, parameters),
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        query: query,
        parameters: parameters,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a raw SQL insert with error handling and retry
  ///
  /// This method executes a raw SQL insert with error handling and retry.
  /// It will retry the insert if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [query] is the SQL query to execute
  /// [parameters] are the query parameters
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<int> rawInsert(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retry(
        () => db.rawInsert(query, parameters),
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        query: query,
        parameters: parameters,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a raw SQL update with error handling and retry
  ///
  /// This method executes a raw SQL update with error handling and retry.
  /// It will retry the update if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [query] is the SQL query to execute
  /// [parameters] are the query parameters
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<int> rawUpdate(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retry(
        () => db.rawUpdate(query, parameters),
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        query: query,
        parameters: parameters,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a raw SQL delete with error handling and retry
  ///
  /// This method executes a raw SQL delete with error handling and retry.
  /// It will retry the delete if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [query] is the SQL query to execute
  /// [parameters] are the query parameters
  /// [operationName] is the name of the operation (for logging)
  /// [table] is the table being accessed (for error reporting)
  /// [config] is the retry configuration
  static Future<int> rawDelete(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    try {
      return await DatabaseRetry.retry(
        () => db.rawDelete(query, parameters),
        operationName,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operationName,
        table: table,
        query: query,
        parameters: parameters,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a SQL query with error handling and retry
  ///
  /// This method executes a SQL query with error handling and retry.
  /// It will retry the query if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [table] is the table to query
  /// [columns] are the columns to select
  /// [where] is the where clause
  /// [whereArgs] are the where arguments
  /// [groupBy] is the group by clause
  /// [having] is the having clause
  /// [orderBy] is the order by clause
  /// [limit] is the limit clause
  /// [offset] is the offset clause
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<List<Map<String, dynamic>>> query(
    Database db,
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'query_$table';
    try {
      return await DatabaseRetry.retry(
        () => db.query(
          table,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        ),
        operation,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operation,
        table: table,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a SQL insert with error handling and retry
  ///
  /// This method executes a SQL insert with error handling and retry.
  /// It will retry the insert if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [table] is the table to insert into
  /// [values] are the values to insert
  /// [conflictAlgorithm] is the conflict algorithm to use
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<int> insert(
    Database db,
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'insert_$table';
    try {
      return await DatabaseRetry.retry(
        () => db.insert(
          table,
          values,
          conflictAlgorithm: conflictAlgorithm,
        ),
        operation,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operation,
        table: table,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a SQL update with error handling and retry
  ///
  /// This method executes a SQL update with error handling and retry.
  /// It will retry the update if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [table] is the table to update
  /// [values] are the values to update
  /// [where] is the where clause
  /// [whereArgs] are the where arguments
  /// [conflictAlgorithm] is the conflict algorithm to use
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<int> update(
    Database db,
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'update_$table';
    try {
      return await DatabaseRetry.retry(
        () => db.update(
          table,
          values,
          where: where,
          whereArgs: whereArgs,
          conflictAlgorithm: conflictAlgorithm,
        ),
        operation,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operation,
        table: table,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }

  /// Execute a SQL delete with error handling and retry
  ///
  /// This method executes a SQL delete with error handling and retry.
  /// It will retry the delete if it fails with a transient error.
  ///
  /// [db] is the database instance
  /// [table] is the table to delete from
  /// [where] is the where clause
  /// [whereArgs] are the where arguments
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<int> delete(
    Database db,
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'delete_$table';
    try {
      return await DatabaseRetry.retry(
        () => db.delete(
          table,
          where: where,
          whereArgs: whereArgs,
        ),
        operation,
        config: config,
      );
    } catch (error, stackTrace) {
      // Handle the error
      final dbError = DatabaseErrorHandler.handleError(
        error,
        operation,
        table: table,
        stackTrace: stackTrace,
      );

      // Rethrow the error
      throw dbError;
    }
  }
}
