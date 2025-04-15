import '../error_type.dart';
import 'blkwds_exception.dart';

/// Database exception class
///
/// This class represents database-related exceptions in the application.
class DatabaseException extends BLKWDSException {
  /// Create a new DatabaseException
  ///
  /// [message] is the error message
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  DatabaseException(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.database,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
