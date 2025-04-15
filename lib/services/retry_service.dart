import 'dart:async';
import 'package:flutter/material.dart';
import 'log_service.dart';
import 'toast_service.dart';
import 'snackbar_service.dart';
import 'error_dialog_service.dart';
import 'retry_strategy.dart';
import 'error_type.dart';
import 'exceptions/exceptions.dart';



/// Retry service
///
/// Provides retry functionality for operations that might fail
class RetryService {
  /// Execute an operation with retry logic
  ///
  /// [operation] is the function to execute
  /// [maxAttempts] is the maximum number of retry attempts
  /// [strategy] is the retry strategy to use
  /// [initialDelay] is the initial delay between attempts (for linear and exponential strategies)
  /// [onRetry] is a callback that is called before each retry attempt
  /// [retryCondition] is a function that determines whether a retry should be attempted based on the error
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    RetryStrategy strategy = RetryStrategy.exponential,
    Duration initialDelay = const Duration(seconds: 1),
    void Function(int attempt, Object error)? onRetry,
    bool Function(Object error)? retryCondition,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        attempt++;
        return await operation();
      } catch (e) {
        // Check if we've reached the maximum number of attempts
        if (attempt >= maxAttempts) {
          LogService.error('Retry failed after $attempt attempts', e);
          rethrow;
        }

        // Check if we should retry based on the error
        if (retryCondition != null && !retryCondition(e)) {
          LogService.info('Retry condition not met, not retrying', e);
          rethrow;
        }

        // Calculate delay based on strategy
        final delay = _calculateDelay(attempt, strategy, initialDelay);

        // Log retry attempt
        LogService.info('Retry attempt $attempt/$maxAttempts after $delay', e);

        // Call onRetry callback if provided
        if (onRetry != null) {
          onRetry(attempt, e);
        }

        // Wait before retrying
        await Future.delayed(delay);
      }
    }
  }

  /// Calculate delay based on retry strategy
  static Duration _calculateDelay(
    int attempt,
    RetryStrategy strategy,
    Duration initialDelay,
  ) {
    switch (strategy) {
      case RetryStrategy.immediate:
        return Duration.zero;
      case RetryStrategy.linear:
        return initialDelay;
      case RetryStrategy.exponential:
        // 2^(attempt-1) * initialDelay
        // attempt 1: initialDelay
        // attempt 2: 2 * initialDelay
        // attempt 3: 4 * initialDelay
        // ...
        return initialDelay * (1 << (attempt - 1));
    }
  }

  /// Execute an operation with retry logic and user feedback
  ///
  /// [context] is the build context
  /// [operation] is the function to execute
  /// [maxAttempts] is the maximum number of retry attempts
  /// [strategy] is the retry strategy to use
  /// [initialDelay] is the initial delay between attempts (for linear and exponential strategies)
  /// [retryCondition] is a function that determines whether a retry should be attempted based on the error
  /// [errorMessage] is the error message to show to the user
  /// [successMessage] is the success message to show to the user
  /// [showProgress] determines whether to show progress during retries
  static Future<T> retryWithFeedback<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    int maxAttempts = 3,
    RetryStrategy strategy = RetryStrategy.exponential,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(Object error)? retryCondition,
    String? errorMessage,
    String? successMessage,
    bool showProgress = true,
  }) async {
    try {
      // Execute operation with retry logic
      final result = await retry<T>(
        operation: operation,
        maxAttempts: maxAttempts,
        strategy: strategy,
        initialDelay: initialDelay,
        retryCondition: retryCondition,
        onRetry: (attempt, error) {
          // Show retry progress
          if (showProgress) {
            ToastService.showInfo(
              context,
              'Retrying... Attempt $attempt/$maxAttempts',
            );
          }
        },
      );

      // Show success message if provided
      if (successMessage != null && context.mounted) {
        SnackbarService.showSuccess(context, successMessage);
      }

      return result;
    } catch (e) {
      // Show error message
      final message = errorMessage ?? _getErrorMessage(e);

      // Show error dialog with retry option
      if (!context.mounted) {
        // If context is no longer valid, just rethrow
        rethrow;
      }

      final action = await ErrorDialogService.showErrorDialog(
        context,
        'Operation Failed',
        message,
      );

      // Retry if requested
      if (action == ErrorAction.retry) {
        // Check if context is still valid
        if (!context.mounted) {
          // If context is no longer valid, just rethrow
          rethrow;
        }

        return retryWithFeedback(
          context: context,
          operation: operation,
          maxAttempts: maxAttempts,
          strategy: strategy,
          initialDelay: initialDelay,
          retryCondition: retryCondition,
          errorMessage: errorMessage,
          successMessage: successMessage,
          showProgress: showProgress,
        );
      }

      // Rethrow the error if not retrying
      rethrow;
    }
  }

  /// Get a user-friendly error message
  static String _getErrorMessage(Object error) {
    if (error is BLKWDSException) {
      return error.message;
    } else {
      return 'An error occurred: $error';
    }
  }

  /// Check if an error is retryable
  ///
  /// By default, network errors and some database errors are considered retryable
  static bool isRetryableError(Object error) {
    if (error is BLKWDSException) {
      // Network errors are generally retryable
      if (error.type == ErrorType.network) {
        return true;
      }

      // Some database errors might be retryable
      if (error.type == ErrorType.database) {
        // Check for specific database errors that might be retryable
        // For example, connection timeouts or deadlocks
        final errorMessage = error.message.toLowerCase();
        return errorMessage.contains('timeout') ||
               errorMessage.contains('deadlock') ||
               errorMessage.contains('connection');
      }

      // Other error types are generally not retryable
      return false;
    }

    // For non-BLKWDSExceptions, check the error type
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }
}
