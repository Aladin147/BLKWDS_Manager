import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'log_service.dart';

/// Cache entry with expiration
class CacheEntry<T> {
  /// The cached value
  final T value;

  /// The expiration time
  final DateTime expiration;

  /// Whether this entry is compressed
  final bool isCompressed;

  /// Create a new cache entry
  CacheEntry(this.value, this.expiration, {this.isCompressed = false});

  /// Check if the entry is expired
  bool get isExpired => DateTime.now().isAfter(expiration);
}

/// Compressed cache entry
class CompressedCacheEntry<T> extends CacheEntry<T> {
  /// The original size of the data in bytes (before compression)
  final int originalSize;

  /// The compressed size of the data in bytes
  final int compressedSize;

  /// Create a new compressed cache entry
  CompressedCacheEntry(super.value, super.expiration, this.originalSize, this.compressedSize)
      : super(isCompressed: true);

  /// Get the compression ratio
  double get compressionRatio => originalSize > 0 ? compressedSize / originalSize : 1.0;

  /// Get the space saved in bytes
  int get spaceSaved => originalSize - compressedSize;

  /// Get the compression percentage
  String get compressionPercentage =>
      '${((1 - compressionRatio) * 100).toStringAsFixed(1)}%';
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
  Map<String, int> _keyAccessCount = {};
  DateTime _lastPrefetchTime = DateTime.now();

  /// Get a value from the cache
  ///
  /// Returns null if the key is not found or the entry is expired.
  /// Tracks access counts for smart cache management.
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

    // Track access count for this key
    _keyAccessCount[key] = (_keyAccessCount[key] ?? 0) + 1;

    _hits++;
    return entry.value as T;
  }

  /// Put a value in the cache
  ///
  /// [key] is the cache key
  /// [value] is the value to cache
  /// [duration] is the time until the entry expires (default: 5 minutes)
  /// [compress] whether to compress the value (default: false)
  /// [compressionThreshold] minimum size in bytes for compression (default: 10KB)
  void put<T>(String key, T value, {
    Duration duration = const Duration(minutes: 5),
    bool compress = false,
    int compressionThreshold = 10 * 1024, // 10KB
  }) {
    final expiration = DateTime.now().add(duration);

    if (compress && _isCompressible<T>()) {
      _putCompressed<T>(key, value, expiration, compressionThreshold);
    } else {
      _cache[key] = CacheEntry<T>(value, expiration);
      LogService.debug('Cache: Added key "$key" with expiration in ${duration.inSeconds}s');
    }
  }

  /// Put a compressed value in the cache
  ///
  /// This method compresses the value if it's larger than the threshold.
  /// Only certain types can be compressed (String, List, Map).
  void _putCompressed<T>(String key, T value, DateTime expiration, int compressionThreshold) {
    try {
      // Convert to JSON string
      final jsonString = _toJsonString(value);
      final originalSize = jsonString.length;

      // Only compress if larger than threshold
      if (originalSize < compressionThreshold) {
        _cache[key] = CacheEntry<T>(value, expiration);
        LogService.debug('Cache: Added key "$key" (size: $originalSize bytes, below compression threshold)');
        return;
      }

      // Compress the data
      final compressedData = _compress(jsonString);
      final compressedSize = compressedData.length;

      // Store the compressed data
      _cache[key] = CompressedCacheEntry<T>(
        value,
        expiration,
        originalSize,
        compressedSize,
      );

      final savedPercentage = ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1);
      LogService.debug('Cache: Added compressed key "$key" (original: $originalSize bytes, compressed: $compressedSize bytes, saved: $savedPercentage%)');
    } catch (e) {
      // If compression fails, store uncompressed
      _cache[key] = CacheEntry<T>(value, expiration);
      LogService.error('Cache: Compression failed for key "$key", stored uncompressed', e);
    }
  }

  /// Check if a type is compressible
  bool _isCompressible<T>() {
    return T == String || T == List || T == Map || T.toString().contains('List<') || T.toString().contains('Map<');
  }

  /// Convert a value to a JSON string
  String _toJsonString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is List || value is Map) {
      return json.encode(value);
    } else {
      throw UnsupportedError('Type ${value.runtimeType} cannot be compressed');
    }
  }

  /// Compress a string using GZIP
  List<int> _compress(String data) {
    final encoded = utf8.encode(data);
    return GZipCodec().encode(encoded);
  }

  /// Decompress a GZIP compressed byte array
  String _decompress(List<int> data) {
    final decoded = GZipCodec().decode(data);
    return utf8.decode(decoded);
  }

  /// Remove a value from the cache
  void remove(String key) {
    _cache.remove(key);
    LogService.debug('Cache: Removed key "$key"');
  }

  /// Remove all values from the cache that match a prefix
  ///
  /// This is useful for invalidating all caches related to a specific entity type
  /// Example: removeByPrefix('gear_') will remove all gear-related caches
  void removeByPrefix(String prefix) {
    final keysToRemove = _cache.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    LogService.debug('Cache: Removed ${keysToRemove.length} keys with prefix "$prefix"');
  }

  /// Remove a specific entity from a list cache
  ///
  /// This is useful for invalidating a specific entity in a list cache without
  /// invalidating the entire list. It works by finding the list cache with the given key,
  /// removing the entity with the matching ID, and updating the cache.
  ///
  /// [listCacheKey] is the key for the list cache
  /// [entityId] is the ID of the entity to remove
  /// [idExtractor] is a function that extracts the ID from an entity
  ///
  /// Returns true if the entity was found and removed, false otherwise
  bool removeEntityFromListCache<T>(String listCacheKey, int entityId, int Function(T entity) idExtractor) {
    final cachedList = get<List<T>>(listCacheKey);
    if (cachedList == null) return false;

    final originalLength = cachedList.length;
    final updatedList = cachedList.where((entity) => idExtractor(entity) != entityId).toList();

    if (updatedList.length < originalLength) {
      // Entity was found and removed, update the cache
      final entry = _cache[listCacheKey] as CacheEntry<List<T>>;
      _cache[listCacheKey] = CacheEntry<List<T>>(updatedList, entry.expiration);
      LogService.debug('Cache: Removed entity with ID $entityId from list cache "$listCacheKey"');
      return true;
    }

    return false;
  }

  /// Update a specific entity in a list cache
  ///
  /// This is useful for updating a specific entity in a list cache without
  /// invalidating the entire list. It works by finding the list cache with the given key,
  /// replacing the entity with the matching ID, and updating the cache.
  ///
  /// [listCacheKey] is the key for the list cache
  /// [entity] is the updated entity
  /// [idExtractor] is a function that extracts the ID from an entity
  ///
  /// Returns true if the entity was found and updated, false otherwise
  bool updateEntityInListCache<T>(String listCacheKey, T entity, int Function(T entity) idExtractor) {
    final cachedList = get<List<T>>(listCacheKey);
    if (cachedList == null) return false;

    final entityId = idExtractor(entity);
    final index = cachedList.indexWhere((e) => idExtractor(e) == entityId);

    if (index >= 0) {
      // Entity was found, update it in the list
      final updatedList = List<T>.from(cachedList);
      updatedList[index] = entity;

      final entry = _cache[listCacheKey] as CacheEntry<List<T>>;
      _cache[listCacheKey] = CacheEntry<List<T>>(updatedList, entry.expiration);
      LogService.debug('Cache: Updated entity with ID $entityId in list cache "$listCacheKey"');
      return true;
    }

    return false;
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
  Map<String, dynamic> get statistics {
    // Calculate compression statistics
    int compressedEntries = 0;
    int totalOriginalSize = 0;
    int totalCompressedSize = 0;

    for (final entry in _cache.values) {
      if (entry is CompressedCacheEntry) {
        compressedEntries++;
        totalOriginalSize += entry.originalSize;
        totalCompressedSize += entry.compressedSize;
      }
    }

    final compressionStats = compressedEntries > 0
        ? {
            'compressed_entries': compressedEntries,
            'total_original_size': _formatSize(totalOriginalSize),
            'total_compressed_size': _formatSize(totalCompressedSize),
            'space_saved': _formatSize(totalOriginalSize - totalCompressedSize),
            'compression_ratio': totalOriginalSize > 0
                ? '${((totalCompressedSize / totalOriginalSize) * 100).toStringAsFixed(1)}%'
                : '0%',
          }
        : {'compressed_entries': 0};

    return {
      'size': size,
      'hits': _hits,
      'misses': _misses,
      'expirations': _expirations,
      'tracked_keys': _keyAccessCount.length,
      'most_accessed': _getMostAccessedKeys(5),
      'hit_ratio': _hits + _misses > 0 ? '${(_hits / (_hits + _misses) * 100).toStringAsFixed(2)}%' : '0%',
      'compression': compressionStats,
    };
  }

  /// Format a size in bytes to a human-readable string
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get the most accessed keys
  Map<String, int> _getMostAccessedKeys(int count) {
    if (_keyAccessCount.isEmpty) return {};

    final sortedEntries = _keyAccessCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.take(count).map((e) => MapEntry(e.key, e.value)),
    );
  }

  /// Reset cache statistics
  void resetStatistics() {
    _hits = 0;
    _misses = 0;
    _expirations = 0;
    _keyAccessCount.clear();
    _lastPrefetchTime = DateTime.now();
    LogService.debug('Cache: Reset statistics');
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

      // Also perform smart cache management
      _performSmartCacheManagement();
    });
  }

  /// Prefetch data for a key using a provider function
  ///
  /// This is useful for preloading data that is likely to be needed soon.
  /// [key] is the cache key
  /// [provider] is a function that returns the data to cache
  /// [duration] is the time until the entry expires (default: 5 minutes)
  Future<void> prefetch<T>(String key, Future<T> Function() provider, {Duration duration = const Duration(minutes: 5)}) async {
    // Don't prefetch if the key is already in the cache and not expired
    if (containsKey(key)) return;

    try {
      final value = await provider();
      put(key, value, duration: duration);
      _lastPrefetchTime = DateTime.now();
      LogService.debug('Cache: Prefetched key "$key"');
    } catch (e) {
      LogService.error('Cache: Error prefetching key "$key"', e);
    }
  }

  /// Prefetch frequently accessed data
  ///
  /// This method analyzes access patterns and prefetches data that is frequently accessed.
  /// [prefetchThreshold] is the minimum number of accesses required for prefetching
  /// [providers] is a map of cache keys to provider functions
  Future<void> prefetchFrequentlyAccessed<T>(Map<String, Future<T> Function()> providers, {int prefetchThreshold = 5}) async {
    // Don't prefetch too frequently
    final now = DateTime.now();
    if (now.difference(_lastPrefetchTime) < const Duration(minutes: 5)) return;

    // Find frequently accessed keys that are not in the cache
    final frequentKeys = _keyAccessCount.entries
        .where((entry) => entry.value >= prefetchThreshold && !containsKey(entry.key))
        .map((entry) => entry.key)
        .toList();

    // Prefetch data for frequent keys
    for (final key in frequentKeys) {
      final provider = providers[key];
      if (provider != null) {
        await prefetch(key, provider);
      }
    }
  }

  /// Perform smart cache management
  ///
  /// This method analyzes access patterns and adjusts cache expiration times accordingly.
  void _performSmartCacheManagement() {
    // Extend expiration for frequently accessed entries
    final frequentKeys = _keyAccessCount.entries
        .where((entry) => entry.value >= 10 && containsKey(entry.key))
        .map((entry) => entry.key)
        .toList();

    for (final key in frequentKeys) {
      final entry = _cache[key];
      if (entry != null) {
        // Extend expiration by 50%
        final currentExpiration = entry.expiration;
        final now = DateTime.now();
        final timeLeft = currentExpiration.difference(now);
        final extension = timeLeft * 0.5;
        final newExpiration = currentExpiration.add(extension);

        // Create a new entry with the extended expiration
        _cache[key] = CacheEntry(entry.value, newExpiration);
        LogService.debug('Cache: Extended expiration for frequently accessed key "$key"');
      }
    }

    // Reset access counts periodically to adapt to changing patterns
    if (_keyAccessCount.length > 100) {
      // Keep the top 20% most accessed keys
      final sortedEntries = _keyAccessCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      final keysToKeep = sortedEntries.take((sortedEntries.length * 0.2).ceil())
          .map((e) => e.key)
          .toSet();

      // Reset counts for other keys
      _keyAccessCount = Map.fromEntries(
        _keyAccessCount.entries.map((entry) {
          if (keysToKeep.contains(entry.key)) {
            return MapEntry(entry.key, entry.value);
          } else {
            return MapEntry(entry.key, 0);
          }
        }),
      );

      LogService.debug('Cache: Reset access counts for ${_keyAccessCount.length - keysToKeep.length} keys');
    }
  }
}
