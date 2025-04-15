import '../error_type.dart';
import 'blkwds_exception.dart';

/// File system exception class
///
/// This class represents file system-related exceptions in the application.
class FileSystemException extends BLKWDSException {
  /// The path of the file or directory that caused the exception
  final String? path;

  /// Create a new FileSystemException
  ///
  /// [message] is the error message
  /// [path] is the path of the file or directory that caused the exception
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  FileSystemException(
    String message, {
    this.path,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.fileSystem,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
