import 'package:flutter/material.dart';
import 'log_service.dart';
import 'error_type.dart';
import 'error_feedback_level.dart';
import 'snackbar_service.dart';
import 'error_dialog_service.dart';
import 'exceptions/exceptions.dart';

/// ErrorService
/// A centralized error handling service for the application
class ErrorService {
  // Using ErrorType enum from error_type.dart

  /// Get a user-friendly error message based on the error type and original error
  static String getUserFriendlyMessage(ErrorType type, Object error) {
    switch (type) {
      case ErrorType.database:
        return 'There was an issue with the database. Please try again.';
      case ErrorType.network:
        return 'Network error. Please check your connection and try again.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.auth:
        return 'Authentication error. Please log in again.';
      case ErrorType.fileSystem:
        return 'There was an issue with the file system. Please try again.';
      case ErrorType.permission:
        return 'You do not have permission to perform this action.';
      case ErrorType.format:
        return 'The data format is invalid. Please try again with a valid format.';
      case ErrorType.conflict:
        return 'There is a conflict with existing data. Please resolve the conflict and try again.';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.input:
        return 'Invalid input. Please check your input and try again.';
      case ErrorType.state:
        return 'The application is in an invalid state. Please restart the application.';
      case ErrorType.configuration:
        return 'There is an issue with the application configuration. Please contact support.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle an error and return a user-friendly message
  static String handleError(Object error, {ErrorType type = ErrorType.unknown, StackTrace? stackTrace}) {
    // Determine error type if not provided
    final errorType = type == ErrorType.unknown ? _determineErrorType(error) : type;

    // Log the error
    LogService.error('Error occurred', error, stackTrace);

    // Return a user-friendly message
    return getUserFriendlyMessage(errorType, error);
  }

  /// Handle an error with context-aware feedback
  ///
  /// This method handles an error and provides feedback to the user based on the
  /// specified feedback level. It also logs the error and returns a user-friendly message.
  ///
  /// Parameters:
  /// - context: The BuildContext for showing UI feedback
  /// - error: The error object
  /// - type: The type of error (default: ErrorType.unknown)
  /// - stackTrace: The stack trace of the error
  /// - feedbackLevel: The level of feedback to provide to the user (default: ErrorFeedbackLevel.snackbar)
  ///
  /// Returns a user-friendly error message
  static String handleErrorWithFeedback(
    BuildContext context,
    Object error, {
    ErrorType type = ErrorType.unknown,
    StackTrace? stackTrace,
    ErrorFeedbackLevel feedbackLevel = ErrorFeedbackLevel.snackbar,
  }) {
    // Determine error type if not provided
    final errorType = type == ErrorType.unknown ? _determineErrorType(error) : type;

    // Log the error
    LogService.error('Error occurred', error, stackTrace);

    // Get a user-friendly message
    final message = getUserFriendlyMessage(errorType, error);

    // Provide feedback based on the specified level
    switch (feedbackLevel) {
      case ErrorFeedbackLevel.silent:
        // No feedback, just logging
        break;
      case ErrorFeedbackLevel.snackbar:
        showErrorSnackBar(context, message);
        break;
      case ErrorFeedbackLevel.dialog:
        showErrorDialog(context, message);
        break;
      case ErrorFeedbackLevel.banner:
        // TODO: Implement banner feedback
        showErrorSnackBar(context, message);
        break;
      case ErrorFeedbackLevel.page:
        // TODO: Implement page feedback
        showErrorDialog(context, message);
        break;
    }

    return message;
  }

  /// Determine the error type from the error object
  static ErrorType _determineErrorType(Object error) {
    if (error is BLKWDSException) {
      return error.type;
    } else if (error is FormatException) {
      return ErrorType.format;
    } else if (error is ArgumentError) {
      return ErrorType.input;
    } else if (error is StateError) {
      return ErrorType.state;
    } else if (error is Exception) {
      // Try to determine the type from the exception class name
      final className = error.runtimeType.toString().toLowerCase();
      if (className.contains('database') || className.contains('sql')) {
        return ErrorType.database;
      } else if (className.contains('network') || className.contains('socket')) {
        return ErrorType.network;
      } else if (className.contains('file') || className.contains('io')) {
        return ErrorType.fileSystem;
      } else if (className.contains('permission')) {
        return ErrorType.permission;
      } else if (className.contains('format')) {
        return ErrorType.format;
      } else if (className.contains('conflict')) {
        return ErrorType.conflict;
      } else if (className.contains('notfound') || className.contains('not_found')) {
        return ErrorType.notFound;
      } else if (className.contains('validation')) {
        return ErrorType.validation;
      } else if (className.contains('auth')) {
        return ErrorType.auth;
      }
    }

    return ErrorType.unknown;
  }

  /// Show an error dialog
  static Future<ErrorAction?> showErrorDialog(BuildContext context, String message) async {
    return ErrorDialogService.showErrorDialog(
      context,
      'Error',
      message,
    );
  }

  /// Show an error dialog with custom title and actions
  static Future<ErrorAction?> showCustomErrorDialog(
    BuildContext context,
    String title,
    String message, {
    List<ErrorAction> actions = const [ErrorAction.ok],
  }) async {
    return ErrorDialogService.showErrorDialog(
      context,
      title,
      message,
      actions: actions,
    );
  }

  /// Show a warning dialog
  static Future<ErrorAction?> showWarningDialog(
    BuildContext context,
    String title,
    String message, {
    List<ErrorAction> actions = const [ErrorAction.ok, ErrorAction.cancel],
  }) async {
    return ErrorDialogService.showWarningDialog(
      context,
      title,
      message,
      actions: actions,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    SnackbarService.showError(context, message);
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    SnackbarService.showSuccess(context, message);
  }

  /// Show a warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    SnackbarService.showWarning(context, message);
  }

  /// Show an info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    SnackbarService.showInfo(context, message);
  }

  /// Handle an exception with context-aware feedback
  ///
  /// This method handles a BLKWDSException and provides feedback to the user based on the
  /// specified feedback level. It also logs the exception and returns a user-friendly message.
  ///
  /// Parameters:
  /// - context: The BuildContext for showing UI feedback
  /// - exception: The BLKWDSException object
  /// - feedbackLevel: The level of feedback to provide to the user (default: ErrorFeedbackLevel.snackbar)
  ///
  /// Returns a user-friendly error message
  static String handleException(
    BuildContext context,
    BLKWDSException exception, {
    ErrorFeedbackLevel feedbackLevel = ErrorFeedbackLevel.snackbar,
  }) {
    // Log the exception
    LogService.error(
      'Exception in ${context.widget.runtimeType}',
      exception,
      exception.stackTrace,
    );

    // Get a user-friendly message
    final message = exception.message;

    // Provide feedback based on the specified level
    switch (feedbackLevel) {
      case ErrorFeedbackLevel.silent:
        // No feedback, just logging
        break;
      case ErrorFeedbackLevel.snackbar:
        showErrorSnackBar(context, message);
        break;
      case ErrorFeedbackLevel.dialog:
        showErrorDialog(context, message);
        break;
      case ErrorFeedbackLevel.banner:
        // TODO: Implement banner feedback
        showErrorSnackBar(context, message);
        break;
      case ErrorFeedbackLevel.page:
        // TODO: Implement page feedback
        showErrorDialog(context, message);
        break;
    }

    return message;
  }
}
