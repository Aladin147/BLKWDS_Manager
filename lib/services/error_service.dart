import 'package:flutter/material.dart';
import 'log_service.dart';
import 'error_type.dart';

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
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle an error and return a user-friendly message
  static String handleError(Object error, {ErrorType type = ErrorType.unknown, StackTrace? stackTrace}) {
    // Log the error
    LogService.error('Error occurred', error, stackTrace);

    // Return a user-friendly message
    return getUserFriendlyMessage(type, error);
  }

  /// Show an error dialog
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
