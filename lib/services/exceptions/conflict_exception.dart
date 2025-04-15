import '../error_type.dart';
import 'blkwds_exception.dart';

/// Conflict exception class
///
/// This class represents conflict exceptions in the application.
class ConflictException extends BLKWDSException {
  /// The resource that has a conflict
  final String? resource;

  /// The identifier of the resource that has a conflict
  final dynamic identifier;

  /// Create a new ConflictException
  ///
  /// [message] is the error message
  /// [resource] is the resource that has a conflict
  /// [identifier] is the identifier of the resource that has a conflict
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  ConflictException(
    String message, {
    this.resource,
    this.identifier,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.conflict,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
