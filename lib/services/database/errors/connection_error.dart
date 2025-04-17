import 'database_error.dart';

/// Connection error class
///
/// This class represents database connection errors in the application.
class ConnectionError extends DatabaseError {
  /// Create a new ConnectionError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  ConnectionError(
    String message,
    String operation, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          operation,
          isTransient: true, // Connection errors are typically transient
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
