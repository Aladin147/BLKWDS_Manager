import '../error_type.dart';
import 'blkwds_exception.dart';

/// Not found exception class
///
/// This class represents not found exceptions in the application.
class NotFoundException extends BLKWDSException {
  /// The resource that was not found
  final String? resource;

  /// The identifier of the resource that was not found
  final dynamic identifier;

  /// Create a new NotFoundException
  ///
  /// [message] is the error message
  /// [resource] is the resource that was not found
  /// [identifier] is the identifier of the resource that was not found
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  NotFoundException(
    String message, {
    this.resource,
    this.identifier,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.notFound,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
