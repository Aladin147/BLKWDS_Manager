import 'database_error.dart';

/// Schema error class
///
/// This class represents database schema errors in the application.
class SchemaError extends DatabaseError {
  /// Create a new SchemaError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [table] is the table that was being accessed
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  SchemaError(
    super.message,
    super.operation, {
    super.table,
    super.originalError,
    super.stackTrace,
  }) : super(
          isTransient: false, // Schema errors are typically not transient
        );
}
