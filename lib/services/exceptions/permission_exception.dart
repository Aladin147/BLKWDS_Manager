import '../error_type.dart';
import 'blkwds_exception.dart';

/// Permission exception class
///
/// This class represents permission-related exceptions in the application.
class PermissionException extends BLKWDSException {
  /// The permission that was denied
  final String? permission;

  /// Create a new PermissionException
  ///
  /// [message] is the error message
  /// [permission] is the permission that was denied
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  PermissionException(
    String message, {
    this.permission,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.permission,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
