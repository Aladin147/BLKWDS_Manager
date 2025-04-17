import 'package:sqflite/sqflite.dart';
import '../log_service.dart';
import 'errors/errors.dart';

/// Database error handler
///
/// This class provides methods for handling database errors.
class DatabaseErrorHandler {
  /// Classify a database error
  ///
  /// This method classifies a database error into a specific error type.
  static DatabaseError classifyError(
    Object error,
    String operation, {
    String? table,
    String? query,
    List<dynamic>? parameters,
    StackTrace? stackTrace,
  }) {
    // If the error is already a DatabaseError, return it
    if (error is DatabaseError) {
      return error;
    }

    // Get the error message
    final errorMessage = error.toString();

    // Check for specific error types
    if (errorMessage.contains('database is locked') ||
        errorMessage.contains('database is busy') ||
        errorMessage.contains('database disk image is malformed')) {
      return ConnectionError(
        errorMessage,
        operation,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (errorMessage.contains('UNIQUE constraint failed') ||
        errorMessage.contains('FOREIGN KEY constraint failed') ||
        errorMessage.contains('CHECK constraint failed') ||
        errorMessage.contains('NOT NULL constraint failed')) {
      // Extract constraint name from error message
      final constraintMatch = RegExp(r'constraint failed: (.+)').firstMatch(errorMessage);
      final constraint = constraintMatch?.group(1);

      return ConstraintError(
        errorMessage,
        operation,
        table: table,
        constraint: constraint,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (errorMessage.contains('no such table') ||
        errorMessage.contains('no such column') ||
        errorMessage.contains('table') && errorMessage.contains('already exists')) {
      return SchemaError(
        errorMessage,
        operation,
        table: table,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (errorMessage.contains('syntax error') ||
        errorMessage.contains('near') ||
        errorMessage.contains('SQL logic error')) {
      return QueryError(
        errorMessage,
        operation,
        table: table,
        query: query,
        parameters: parameters,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is DatabaseException) {
      // Generic database exception
      return DatabaseError(
        errorMessage,
        operation,
        table: table,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else {
      // Unknown error
      return DatabaseError(
        'An unexpected database error occurred: $errorMessage',
        operation,
        table: table,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle a database error
  ///
  /// This method handles a database error by logging it and returning a DatabaseError.
  static DatabaseError handleError(
    Object error,
    String operation, {
    String? table,
    String? query,
    List<dynamic>? parameters,
    StackTrace? stackTrace,
  }) {
    // Get the stack trace if not provided
    final trace = stackTrace ?? StackTrace.current;

    // Classify the error
    final databaseError = classifyError(
      error,
      operation,
      table: table,
      query: query,
      parameters: parameters,
      stackTrace: trace,
    );

    // Log the error
    LogService.error(
      'Database error: ${databaseError.toString()}',
      databaseError.originalError ?? databaseError,
      databaseError.stackTrace ?? trace,
    );

    return databaseError;
  }

  /// Determine if an error is transient and can be retried
  ///
  /// This method determines if a database error is transient and can be retried.
  static bool isTransientError(Object error) {
    if (error is DatabaseError) {
      return error.isTransient;
    }

    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('database is locked') ||
        errorMessage.contains('database is busy') ||
        errorMessage.contains('disk i/o error') ||
        errorMessage.contains('disk full') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout');
  }
}
