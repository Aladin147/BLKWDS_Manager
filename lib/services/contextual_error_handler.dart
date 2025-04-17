import 'package:flutter/material.dart';
import 'error_service.dart';
import 'error_type.dart';
import 'error_feedback_level.dart';
import 'log_service.dart';
import 'snackbar_service.dart';
import 'banner_service.dart';
import 'exceptions/exceptions.dart';

// Using ErrorFeedbackLevel from error_feedback_level.dart

/// Contextual error handler
///
/// Handles errors based on the current context and provides appropriate feedback
class ContextualErrorHandler {
  /// Handle an error with context-aware feedback
  ///
  /// [context] is the build context
  /// [error] is the error to handle
  /// [type] is the error type
  /// [feedbackLevel] determines the type of feedback to show
  /// [stackTrace] is the stack trace of the error
  static void handleError(
    BuildContext context,
    Object error, {
    ErrorType? type,
    ErrorFeedbackLevel feedbackLevel = ErrorFeedbackLevel.snackbar,
    StackTrace? stackTrace,
  }) {
    // Determine error type if not provided
    final errorType = type ?? _determineErrorType(error);

    // Log the error
    LogService.error(
      'Error in ${context.widget.runtimeType}',
      error,
      stackTrace,
    );

    // Get user-friendly message
    final message = _getUserFriendlyMessage(error, errorType);

    // Show feedback based on specified level
    _showFeedback(context, message, errorType, feedbackLevel);
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

  /// Get a user-friendly message for the error
  static String _getUserFriendlyMessage(Object error, ErrorType type) {
    if (error is BLKWDSException) {
      return error.message;
    }

    return ErrorService.getUserFriendlyMessage(type, error);
  }

  /// Show feedback based on the specified level
  static void _showFeedback(
    BuildContext context,
    String message,
    ErrorType type,
    ErrorFeedbackLevel feedbackLevel,
  ) {
    switch (feedbackLevel) {
      case ErrorFeedbackLevel.silent:
        // No user feedback, just logging
        break;
      case ErrorFeedbackLevel.snackbar:
        SnackbarService.showError(context, message);
        break;
      case ErrorFeedbackLevel.dialog:
        ErrorService.showErrorDialog(context, message);
        break;
      case ErrorFeedbackLevel.banner:
        BannerService.showError(message);
        break;
      case ErrorFeedbackLevel.page:
        // TODO: Implement page feedback
        ErrorService.showErrorDialog(context, message);
        break;
    }
  }

  /// Handle an exception with context-aware feedback
  ///
  /// [context] is the build context
  /// [exception] is the exception to handle
  /// [feedbackLevel] determines the type of feedback to show
  static void handleException(
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

    // Show feedback based on specified level
    _showFeedback(context, exception.message, exception.type, feedbackLevel);
  }

  /// Determine the appropriate feedback level for an error type
  static ErrorFeedbackLevel getFeedbackLevelForErrorType(ErrorType type) {
    switch (type) {
      // Critical errors that might require user action
      case ErrorType.database:
      case ErrorType.network:
      case ErrorType.fileSystem:
      case ErrorType.state:
      case ErrorType.configuration:
        return ErrorFeedbackLevel.dialog;

      // User input errors
      case ErrorType.validation:
      case ErrorType.input:
      case ErrorType.format:
        return ErrorFeedbackLevel.snackbar;

      // Operational errors
      case ErrorType.conflict:
      case ErrorType.notFound:
        return ErrorFeedbackLevel.snackbar;

      // Security-related errors
      case ErrorType.permission:
      case ErrorType.auth:
        return ErrorFeedbackLevel.dialog;

      // Unknown errors
      case ErrorType.unknown:
        return ErrorFeedbackLevel.dialog;
    }
  }
}
