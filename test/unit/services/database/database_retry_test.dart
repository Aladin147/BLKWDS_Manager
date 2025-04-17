import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/database/database_retry.dart';
import 'package:blkwds_manager/services/database/errors/errors.dart';

void main() {
  group('RetryConfig', () {
    test('should create default config correctly', () {
      // Act
      final config = RetryConfig.defaultConfig;

      // Assert
      expect(config.maxAttempts, equals(3));
      expect(config.initialDelayMs, equals(100));
      expect(config.maxDelayMs, equals(5000));
      expect(config.backoffFactor, equals(2.0));
    });

    test('should create aggressive config correctly', () {
      // Act
      final config = RetryConfig.aggressiveConfig;

      // Assert
      expect(config.maxAttempts, equals(5));
      expect(config.initialDelayMs, equals(200));
      expect(config.maxDelayMs, equals(10000));
      expect(config.backoffFactor, equals(3.0));
    });

    test('should create minimal config correctly', () {
      // Act
      final config = RetryConfig.minimalConfig;

      // Assert
      expect(config.maxAttempts, equals(2));
      expect(config.initialDelayMs, equals(50));
      expect(config.maxDelayMs, equals(1000));
      expect(config.backoffFactor, equals(1.5));
    });

    test('should calculate delay correctly', () {
      // Arrange
      final config = RetryConfig(
        initialDelayMs: 100,
        maxDelayMs: 1000,
        backoffFactor: 2.0,
      );

      // Act & Assert
      expect(config.calculateDelay(1), equals(100)); // 100 * 2^0
      expect(config.calculateDelay(2), equals(200)); // 100 * 2^1
      expect(config.calculateDelay(3), equals(400)); // 100 * 2^2
      expect(config.calculateDelay(4), equals(800)); // 100 * 2^3
      expect(config.calculateDelay(5), equals(1000)); // 100 * 2^4 = 1600, but capped at 1000
    });
  });

  group('DatabaseRetry', () {
    test('should retry operation until success', () async {
      // Arrange
      int attempts = 0;
      final operation = () async {
        attempts++;
        if (attempts < 3) {
          // ConnectionError is always transient by default
          throw ConnectionError(
            'database is locked',
            'test_operation',
          );
        }
        return 'success';
      };

      // Act
      final result = await DatabaseRetry.retry(
        operation,
        'test_operation',
        config: RetryConfig(
          maxAttempts: 5,
          initialDelayMs: 10, // Use small delays for testing
          maxDelayMs: 100,
          backoffFactor: 2.0,
        ),
      );

      // Assert
      expect(result, equals('success'));
      expect(attempts, equals(3));
    });

    test('should throw error after max attempts', () async {
      // Arrange
      int attempts = 0;
      final operation = () async {
        attempts++;
        // ConnectionError is always transient by default
        throw ConnectionError(
          'database is locked',
          'test_operation',
        );
      };

      // Act & Assert
      expect(
        () => DatabaseRetry.retry(
          operation,
          'test_operation',
          config: RetryConfig(
            maxAttempts: 3,
            initialDelayMs: 10, // Use small delays for testing
            maxDelayMs: 100,
            backoffFactor: 2.0,
          ),
        ),
        throwsA(isA<ConnectionError>()),
      );

      // Wait for all retries to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      expect(attempts, equals(3));
    });

    test('should not retry for non-transient errors', () async {
      // Arrange
      int attempts = 0;
      final operation = () async {
        attempts++;
        // SchemaError is never transient by default
        throw SchemaError(
          'no such table',
          'test_operation',
        );
      };

      // Act & Assert
      expect(
        () => DatabaseRetry.retry(
          operation,
          'test_operation',
          config: RetryConfig(
            maxAttempts: 3,
            initialDelayMs: 10,
            maxDelayMs: 100,
            backoffFactor: 2.0,
          ),
        ),
        throwsA(isA<SchemaError>()),
      );

      // Wait for all retries to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert
      expect(attempts, equals(1));
    });
  });
}
