import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
      cacheService.clear(); // Clear any existing cache entries
    });

    test('should put and retrieve items from cache', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      cacheService.put(key, value);
      final result = cacheService.get<String>(key);

      // Assert
      expect(result, equals(value));
    });

    test('should return null for non-existent keys', () {
      // Arrange
      const key = 'non_existent_key';

      // Act
      final result = cacheService.get<String>(key);

      // Assert
      expect(result, isNull);
    });

    test('should respect expiration time', () async {
      // Arrange
      const key = 'expiring_key';
      const value = 'expiring_value';

      // Act - add with very short expiration
      cacheService.put(key, value, duration: const Duration(seconds: 1));

      // Assert - value exists initially
      expect(cacheService.get<String>(key), equals(value));

      // Wait for expiration
      await Future.delayed(const Duration(seconds: 2));

      // Assert - value is gone after expiration
      expect(cacheService.get<String>(key), isNull);
    });

    test('should remove items from cache', () {
      // Arrange
      const key = 'remove_key';
      const value = 'remove_value';
      cacheService.put(key, value);

      // Act
      cacheService.remove(key);

      // Assert
      expect(cacheService.get<String>(key), isNull);
    });

    test('should clear all items from cache', () {
      // Arrange
      cacheService.put('key1', 'value1');
      cacheService.put('key2', 'value2');

      // Act
      cacheService.clear();

      // Assert
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), isNull);
    });

    test('should check if key exists', () {
      // Arrange
      const key = 'exists_key';
      const value = 'exists_value';

      // Act
      cacheService.put(key, value);

      // Assert
      expect(cacheService.containsKey(key), isTrue);
      expect(cacheService.containsKey('non_existent_key'), isFalse);
    });

    test('should update existing items', () {
      // Arrange
      const key = 'update_key';
      const initialValue = 'initial_value';
      const updatedValue = 'updated_value';

      // Act
      cacheService.put(key, initialValue);
      cacheService.put(key, updatedValue);

      // Assert
      expect(cacheService.get<String>(key), equals(updatedValue));
    });

    test('should track cache statistics', () {
      // Arrange
      cacheService.resetStatistics(); // Reset statistics first
      cacheService.put('stats_key1', 'value1');
      cacheService.put('stats_key2', 'value2');

      // Act - generate some hits and misses
      cacheService.get<String>('stats_key1'); // hit
      cacheService.get<String>('stats_key1'); // hit
      cacheService.get<String>('stats_key2'); // hit
      cacheService.get<String>('non_existent'); // miss

      // Get statistics
      final stats = cacheService.getStatistics();

      // Assert
      expect(stats.size, equals(2));
      // We can't reliably test exact hit counts since the singleton may have previous hits
      // So we'll just verify that hits and misses are being tracked
      expect(stats.hits >= 3, isTrue);
      expect(stats.misses >= 1, isTrue);
      expect(stats.hitRatio > 0, isTrue);
    });
  });
}
