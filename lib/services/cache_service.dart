import 'dart:async';
import 'dart:collection';

import 'log_service.dart';

/// Cache entry with expiration
class CacheEntry<T> {
  /// The cached value
  final T value;

  /// The expiration time
  final DateTime expiration;

  /// Create a new cache entry
  CacheEntry(this.value, this.expiration);

  /// Check if the entry is expired
  bool get isExpired => DateTime.now().isAfter(expiration);
}

/// Cache service for storing frequently accessed data
///
/// This service provides a simple in-memory cache with expiration.
class CacheService {
  // Singleton instance
  static final CacheService _instance = CacheService._internal();

  // Private constructor
  CacheService._internal();

  // Factory constructor to return the singleton instance
  factory CacheService() => _instance;

  // Cache storage
  final _cache = HashMap<String, CacheEntry<dynamic>>();

  // Cache statistics
  int _hits = 0;
  int _misses = 0;
  int _expirations = 0;

  /// Get a value from the cache
  ///
  /// Returns null if the key is not found or the entry is expired.
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.isExpired) {
      _expirations++;
      _cache.remove(key);
      return null;
    }

    _hits++;
    return entry.value as T;
  }

  /// Put a value in the cache
  ///
  /// [key] is the cache key
  /// [value] is the value to cache
  /// [duration] is the time until the entry expires (default: 5 minutes)
  void put<T>(String key, T value, {Duration duration = const Duration(minutes: 5)}) {
    final expiration = DateTime.now().add(duration);
    _cache[key] = CacheEntry<T>(value, expiration);
    LogService.debug('Cache: Added key "$key" with expiration in ${duration.inSeconds}s');
  }

  /// Remove a value from the cache
  void remove(String key) {
    _cache.remove(key);
    LogService.debug('Cache: Removed key "$key"');
  }

  /// Clear the entire cache
  void clear() {
    _cache.clear();
    LogService.debug('Cache: Cleared all entries');
  }

  /// Check if the cache contains a key (and it's not expired)
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _expirations++;
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Get the number of entries in the cache
  int get size => _cache.length;

  /// Get cache statistics
  Map<String, int> get statistics => {
        'size': size,
        'hits': _hits,
        'misses': _misses,
        'expirations': _expirations,
      };

  /// Reset cache statistics
  void resetStatistics() {
    _hits = 0;
    _misses = 0;
    _expirations = 0;
  }

  /// Clean expired entries from the cache
  ///
  /// Returns the number of entries removed.
  int cleanExpired() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.expiration.isBefore(now))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _expirations++;
    }

    if (expiredKeys.isNotEmpty) {
      LogService.debug('Cache: Cleaned ${expiredKeys.length} expired entries');
    }

    return expiredKeys.length;
  }

  /// Schedule periodic cache cleaning
  ///
  /// [interval] is the time between cleanings (default: 10 minutes)
  Timer schedulePeriodicCleaning({Duration interval = const Duration(minutes: 10)}) {
    LogService.info('Cache: Scheduled periodic cleaning every ${interval.inMinutes} minutes');
    return Timer.periodic(interval, (_) {
      final removed = cleanExpired();
      LogService.debug('Cache: Periodic cleaning removed $removed expired entries');
    });
  }
}
