import 'database_error.dart';

/// Constraint error class
///
/// This class represents database constraint errors in the application.
class ConstraintError extends DatabaseError {
  /// The constraint that was violated
  final String? constraint;

  /// Create a new ConstraintError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [table] is the table that was being accessed
  /// [constraint] is the constraint that was violated
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  ConstraintError(
    super.message,
    super.operation, {
    super.table,
    this.constraint,
    super.originalError,
    super.stackTrace,
  }) : super(
          isTransient: false, // Constraint errors are typically not transient
        );

  /// Create a user-friendly error message
  @override
  String toString() {
    final tableInfo = table != null ? ' on table "$table"' : '';
    final constraintInfo = constraint != null ? ' (constraint: $constraint)' : '';
    return 'Database constraint error during $operation$tableInfo$constraintInfo: $message';
  }
}
