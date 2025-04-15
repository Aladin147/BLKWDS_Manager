import '../error_type.dart';
import 'blkwds_exception.dart';

/// Validation exception class
///
/// This class represents validation-related exceptions in the application.
class ValidationException extends BLKWDSException {
  /// The field that failed validation
  final String? field;

  /// Create a new ValidationException
  ///
  /// [message] is the error message
  /// [field] is the field that failed validation
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  ValidationException(
    String message, {
    this.field,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.validation,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
