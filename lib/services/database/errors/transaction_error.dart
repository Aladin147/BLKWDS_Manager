import 'database_error.dart';

/// Transaction error class
///
/// This class represents database transaction errors in the application.
class TransactionError extends DatabaseError {
  /// Create a new TransactionError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [table] is the table that was being accessed
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  TransactionError(
    super.message,
    super.operation, {
    super.table,
    super.originalError,
    super.stackTrace,
  }) : super(
          isTransient: false, // Transaction errors are typically not transient
        );
}
