import '../error_type.dart';

/// Base exception class for the application
///
/// This class serves as the base for all custom exceptions in the application.
/// It provides a consistent way to handle errors with appropriate error types
/// and user-friendly messages.
class BLKWDSException implements Exception {
  /// The error message
  final String message;

  /// The error type
  final ErrorType type;

  /// The original error that caused this exception
  final Object? originalError;

  /// The stack trace of the original error
  final StackTrace? stackTrace;

  /// Create a new BLKWDSException
  ///
  /// [message] is the error message
  /// [type] is the error type
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  BLKWDSException(
    this.message,
    this.type, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}
