import 'dart:async';
import 'package:flutter/material.dart';
import 'log_service.dart';
import 'error_type.dart';
import 'exceptions/exceptions.dart';
import 'snackbar_service.dart';
import 'toast_service.dart';

/// Recovery action
///
/// Defines the possible recovery actions for an error
enum RecoveryAction {
  /// Retry the operation
  retry,

  /// Use a fallback value or operation
  fallback,

  /// Ignore the error and continue
  ignore,

  /// Cancel the operation
  cancel,
}

/// Recovery service
///
/// Provides error recovery functionality for the application
class RecoveryService {
  /// Execute an operation with fallback
  ///
  /// [operation] is the primary operation to execute
  /// [fallback] is the fallback operation to execute if the primary operation fails
  /// [shouldUseFallback] is a function that determines whether the fallback should be used based on the error
  static Future<T> withFallback<T>({
    required Future<T> Function() operation,
    required Future<T> Function() fallback,
    bool Function(Object error)? shouldUseFallback,
  }) async {
    try {
      return await operation();
    } catch (e) {
      // Determine if we should use the fallback
      final useFallback = shouldUseFallback?.call(e) ?? true;

      if (useFallback) {
        LogService.info('Using fallback due to error', e);
        return await fallback();
      } else {
        LogService.error('Error in operation and fallback not used', e);
        rethrow;
      }
    }
  }

  /// Execute an operation with a default value fallback
  ///
  /// [operation] is the operation to execute
  /// [defaultValue] is the default value to return if the operation fails
  /// [shouldUseDefault] is a function that determines whether the default value should be used based on the error
  static Future<T> withDefault<T>({
    required Future<T> Function() operation,
    required T defaultValue,
    bool Function(Object error)? shouldUseDefault,
  }) async {
    try {
      return await operation();
    } catch (e) {
      // Determine if we should use the default value
      final useDefault = shouldUseDefault?.call(e) ?? true;

      if (useDefault) {
        LogService.info('Using default value due to error', e);
        return defaultValue;
      } else {
        LogService.error('Error in operation and default value not used', e);
        rethrow;
      }
    }
  }

  /// Execute an operation with recovery options
  ///
  /// [context] is the build context
  /// [operation] is the operation to execute
  /// [fallback] is the fallback operation to execute if the primary operation fails
  /// [defaultValue] is the default value to return if both the operation and fallback fail
  /// [recoveryStrategy] is a function that determines the recovery action based on the error
  /// [showFeedback] determines whether to show feedback to the user
  /// [onSuccess] is a callback that is called when the operation succeeds
  /// [onError] is a callback that is called when the operation fails
  static Future<T?> withRecovery<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    Future<T> Function()? fallback,
    T? defaultValue,
    RecoveryAction Function(Object error)? recoveryStrategy,
    bool showFeedback = true,
    void Function(T result)? onSuccess,
    void Function(Object error, RecoveryAction action)? onError,
  }) async {
    try {
      // Try the primary operation
      final result = await operation();

      // Call onSuccess callback if provided
      if (onSuccess != null) {
        onSuccess(result);
      } else if (showFeedback && context.mounted) {
        ToastService.showSuccess(context, 'Operation completed successfully');
      }

      return result;
    } catch (e) {
      LogService.error('Error in operation, attempting recovery', e);

      // Determine recovery action
      final action = recoveryStrategy?.call(e) ?? _defaultRecoveryStrategy(e);

      // Call onError callback if provided
      if (onError != null) {
        onError(e, action);
      }

      switch (action) {
        case RecoveryAction.retry:
          // Show retry feedback if requested
          if (showFeedback && context.mounted) {
            SnackbarService.showInfo(context, 'Retrying operation...');
          }

          // Check if context is still valid
          if (!context.mounted) {
            // If context is no longer valid, just try the operation again
            try {
              return await operation();
            } catch (retryError) {
              // If it fails again and we have a default value, use it
              if (defaultValue != null) {
                return defaultValue;
              }
              // Otherwise rethrow
              rethrow;
            }
          }

          // Retry the operation with recovery
          return withRecovery(
            context: context,
            operation: operation,
            fallback: fallback,
            defaultValue: defaultValue,
            recoveryStrategy: recoveryStrategy,
            showFeedback: showFeedback,
            onSuccess: onSuccess,
            onError: onError,
          );

        case RecoveryAction.fallback:
          // Check if fallback is provided
          if (fallback != null) {
            // Show fallback feedback if requested
            if (showFeedback && context.mounted) {
              SnackbarService.showInfo(context, 'Using alternative method...');
            }

            try {
              // Try the fallback operation
              return await fallback();
            } catch (fallbackError) {
              LogService.error('Fallback operation failed', fallbackError);

              // If fallback fails, use default value if provided
              if (defaultValue != null) {
                if (showFeedback && context.mounted) {
                  SnackbarService.showWarning(context, 'Using default value');
                }
                return defaultValue;
              } else {
                // If no default value, show error and rethrow
                if (showFeedback && context.mounted) {
                  SnackbarService.showError(context, 'Operation failed');
                }
                rethrow;
              }
            }
          } else if (defaultValue != null) {
            // If no fallback but default value is provided, use it
            if (showFeedback && context.mounted) {
              SnackbarService.showWarning(context, 'Using default value');
            }
            return defaultValue;
          } else {
            // If no fallback and no default value, show error and rethrow
            if (showFeedback && context.mounted) {
              SnackbarService.showError(context, 'Operation failed');
            }
            rethrow;
          }

        case RecoveryAction.ignore:
          // Show ignore feedback if requested
          if (showFeedback && context.mounted) {
            SnackbarService.showInfo(context, 'Continuing without completing operation');
          }

          // Return default value if provided, otherwise null
          return defaultValue;

        case RecoveryAction.cancel:
          // Show cancel feedback if requested
          if (showFeedback && context.mounted) {
            SnackbarService.showWarning(context, 'Operation cancelled');
          }

          // Rethrow the error
          rethrow;
      }
    }
  }

  /// Default recovery strategy based on error type
  static RecoveryAction _defaultRecoveryStrategy(Object error) {
    if (error is BLKWDSException) {
      switch (error.type) {
        case ErrorType.network:
          // Network errors are often temporary, so retry
          return RecoveryAction.retry;
        case ErrorType.database:
          // Database errors might be recoverable with a fallback
          return RecoveryAction.fallback;
        case ErrorType.validation:
        case ErrorType.input:
        case ErrorType.format:
          // Input errors usually require user intervention, so cancel
          return RecoveryAction.cancel;
        case ErrorType.notFound:
          // Not found errors might be handled with a default value
          return RecoveryAction.fallback;
        case ErrorType.permission:
        case ErrorType.auth:
          // Permission errors usually require user intervention, so cancel
          return RecoveryAction.cancel;
        default:
          // For other errors, try fallback
          return RecoveryAction.fallback;
      }
    } else {
      // For unknown errors, try fallback
      return RecoveryAction.fallback;
    }
  }

  /// Check if an error is recoverable
  ///
  /// By default, network errors, some database errors, and not found errors are considered recoverable
  static bool isRecoverableError(Object error) {
    if (error is BLKWDSException) {
      switch (error.type) {
        case ErrorType.network:
        case ErrorType.notFound:
          return true;
        case ErrorType.database:
          // Some database errors might be recoverable
          final errorMessage = error.message.toLowerCase();
          return errorMessage.contains('timeout') ||
                 errorMessage.contains('connection');
        default:
          return false;
      }
    }

    // For non-BLKWDSExceptions, check the error type
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('not found');
  }
}
