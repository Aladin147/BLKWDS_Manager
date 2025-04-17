import '../../error_type.dart';
import '../../exceptions/blkwds_exception.dart';

/// Base class for database errors
///
/// This class represents database-related errors in the application.
/// It provides a consistent way to handle database errors with appropriate
/// error types and user-friendly messages.
class DatabaseError extends BLKWDSException {
  /// The operation that was being performed when the error occurred
  final String operation;

  /// The table that was being accessed when the error occurred
  final String? table;

  /// Whether this error is transient and can be retried
  final bool isTransient;

  /// Create a new DatabaseError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [table] is the table that was being accessed
  /// [isTransient] indicates if the error is transient and can be retried
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  DatabaseError(
    String message,
    this.operation, {
    this.table,
    this.isTransient = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.database,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Create a user-friendly error message
  @override
  String toString() {
    final tableInfo = table != null ? ' on table "$table"' : '';
    return 'Database error during $operation$tableInfo: $message';
  }
}
