import 'dart:async';
import 'dart:math' as math;

import '../log_service.dart';
import 'database_error_handler.dart';

/// Database retry configuration
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Initial delay in milliseconds
  final int initialDelayMs;

  /// Maximum delay in milliseconds
  final int maxDelayMs;

  /// Factor by which the delay increases with each attempt
  final double backoffFactor;

  /// Create a new RetryConfig
  ///
  /// [maxAttempts] is the maximum number of retry attempts
  /// [initialDelayMs] is the initial delay in milliseconds
  /// [maxDelayMs] is the maximum delay in milliseconds
  /// [backoffFactor] is the factor by which the delay increases with each attempt
  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelayMs = 100,
    this.maxDelayMs = 5000,
    this.backoffFactor = 2.0,
  });

  /// Default retry configuration
  static const RetryConfig defaultConfig = RetryConfig();

  /// Aggressive retry configuration (more attempts, longer delays)
  static const RetryConfig aggressiveConfig = RetryConfig(
    maxAttempts: 5,
    initialDelayMs: 200,
    maxDelayMs: 10000,
    backoffFactor: 3.0,
  );

  /// Minimal retry configuration (fewer attempts, shorter delays)
  static const RetryConfig minimalConfig = RetryConfig(
    maxAttempts: 2,
    initialDelayMs: 50,
    maxDelayMs: 1000,
    backoffFactor: 1.5,
  );

  /// Calculate the delay for a retry attempt
  ///
  /// This method calculates the delay for a retry attempt using exponential backoff.
  int calculateDelay(int attempt) {
    final delay = initialDelayMs * math.pow(backoffFactor, attempt - 1).toInt();
    return math.min(delay, maxDelayMs);
  }
}

/// Database retry utilities
///
/// This class provides methods for retrying database operations.
class DatabaseRetry {
  /// Retry a database operation with exponential backoff
  ///
  /// This method retries a database operation if it fails with a transient error.
  /// It uses exponential backoff to increase the delay between retries.
  ///
  /// [operation] is the operation to retry
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<T> retry<T>(
    Future<T> Function() operation,
    String operationName, {
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    int attempt = 1;

    while (true) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        // Check if we've reached the maximum number of attempts
        if (attempt >= config.maxAttempts) {
          LogService.error(
            'Database operation "$operationName" failed after $attempt attempts',
            error,
            stackTrace,
          );
          rethrow;
        }

        // Check if the error is transient
        if (!DatabaseErrorHandler.isTransientError(error)) {
          // If the error is not transient, don't retry
          final dbError = DatabaseErrorHandler.handleError(
            error,
            operationName,
            stackTrace: stackTrace,
          );
          throw dbError;
        }

        // Calculate the delay for this attempt
        final delay = config.calculateDelay(attempt);

        LogService.warning(
          'Database operation "$operationName" failed (attempt $attempt/${config.maxAttempts}), '
          'retrying in ${delay}ms: ${error.toString()}',
        );

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delay));

        // Increment the attempt counter
        attempt++;
      }
    }
  }

  /// Retry a database operation with a transaction
  ///
  /// This method retries a database operation with a transaction if it fails with a transient error.
  /// It uses exponential backoff to increase the delay between retries.
  ///
  /// [db] is the database instance
  /// [operation] is the operation to retry
  /// [operationName] is the name of the operation (for logging)
  /// [config] is the retry configuration
  static Future<T> retryWithTransaction<T>(
    dynamic db,
    Future<T> Function(dynamic txn) operation,
    String operationName, {
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    return retry(
      () => db.transaction(operation),
      operationName,
      config: config,
    );
  }
}
