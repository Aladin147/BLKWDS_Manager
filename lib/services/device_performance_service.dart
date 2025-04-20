import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// DevicePerformanceService
/// A service to detect device capabilities and adjust UI complexity accordingly
class DevicePerformanceService {
  /// Singleton instance
  static final DevicePerformanceService _instance = DevicePerformanceService._internal();

  /// Factory constructor
  factory DevicePerformanceService() => _instance;

  /// Internal constructor
  DevicePerformanceService._internal();

  /// Device performance level
  DevicePerformanceLevel? _performanceLevel;

  /// Get the device performance level
  DevicePerformanceLevel get performanceLevel {
    // Return cached value if available
    if (_performanceLevel != null) {
      return _performanceLevel!;
    }

    // Detect performance level
    _performanceLevel = _detectPerformanceLevel();
    return _performanceLevel!;
  }

  /// Detect the device performance level
  DevicePerformanceLevel _detectPerformanceLevel() {
    // For desktop platforms, assume high performance
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return DevicePerformanceLevel.high;
    }

    // For Android, use heuristics to determine performance level
    if (Platform.isAndroid) {
      // Check if we're running on an emulator
      if (_isEmulator()) {
        return DevicePerformanceLevel.medium;
      }

      // Check Android version
      final androidVersion = _getAndroidVersion();
      
      // Older Android versions likely mean older hardware
      if (androidVersion < 8) { // Android 8.0 Oreo
        return DevicePerformanceLevel.low;
      } else if (androidVersion < 10) { // Android 10
        return DevicePerformanceLevel.medium;
      }
      
      // For newer Android versions, use memory to determine performance
      final totalMemory = _getTotalMemoryInGB();
      
      if (totalMemory < 2) {
        return DevicePerformanceLevel.low;
      } else if (totalMemory < 4) {
        return DevicePerformanceLevel.medium;
      }
    }

    // For iOS, use iOS version as a proxy for device performance
    if (Platform.isIOS) {
      final iosVersion = _getIOSVersion();
      
      if (iosVersion < 13) {
        return DevicePerformanceLevel.low;
      } else if (iosVersion < 15) {
        return DevicePerformanceLevel.medium;
      }
    }

    // Default to high performance for newer devices
    return DevicePerformanceLevel.high;
  }

  /// Check if running on an emulator
  bool _isEmulator() {
    if (Platform.isAndroid) {
      try {
        final brand = Platform.environment['BRAND'] ?? '';
        final device = Platform.environment['DEVICE'] ?? '';
        final fingerprint = Platform.environment['FINGERPRINT'] ?? '';
        final model = Platform.environment['MODEL'] ?? '';
        
        return brand.contains('generic') || 
               device.contains('generic') || 
               fingerprint.contains('generic') || 
               model.contains('sdk') || 
               model.contains('google_sdk') || 
               model.contains('emulator') || 
               model.contains('Android SDK');
      } catch (e) {
        debugPrint('Error checking if device is emulator: $e');
      }
    }
    
    return false;
  }

  /// Get Android version as a number
  int _getAndroidVersion() {
    try {
      final versionString = Platform.operatingSystemVersion;
      final regex = RegExp(r'Android (\d+)');
      final match = regex.firstMatch(versionString);
      
      if (match != null && match.groupCount >= 1) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting Android version: $e');
    }
    
    return 0;
  }

  /// Get iOS version as a number
  int _getIOSVersion() {
    try {
      final versionString = Platform.operatingSystemVersion;
      final regex = RegExp(r'Version (\d+)');
      final match = regex.firstMatch(versionString);
      
      if (match != null && match.groupCount >= 1) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting iOS version: $e');
    }
    
    return 0;
  }

  /// Get total memory in GB
  double _getTotalMemoryInGB() {
    try {
      // This is a very rough approximation
      // A more accurate approach would use platform-specific code
      return (Platform.numberOfProcessors * 0.5).clamp(1.0, 16.0);
    } catch (e) {
      debugPrint('Error getting total memory: $e');
    }
    
    return 2.0; // Default to 2GB
  }

  /// Should use pagination for list views
  bool get shouldUsePagination => performanceLevel != DevicePerformanceLevel.high;

  /// Maximum number of items to load at once in a list view
  int get paginationPageSize {
    switch (performanceLevel) {
      case DevicePerformanceLevel.low:
        return 10;
      case DevicePerformanceLevel.medium:
        return 20;
      case DevicePerformanceLevel.high:
        return 50;
    }
  }

  /// Should use animations
  bool get shouldUseAnimations => performanceLevel != DevicePerformanceLevel.low;

  /// Should use complex UI effects (shadows, gradients, etc.)
  bool get shouldUseComplexEffects => performanceLevel == DevicePerformanceLevel.high;

  /// Should use image caching
  bool get shouldUseImageCaching => true; // Always use caching, but with different strategies

  /// Maximum image cache size in MB
  int get maxImageCacheSizeMB {
    switch (performanceLevel) {
      case DevicePerformanceLevel.low:
        return 20;
      case DevicePerformanceLevel.medium:
        return 50;
      case DevicePerformanceLevel.high:
        return 100;
    }
  }
}

/// Device performance levels
enum DevicePerformanceLevel {
  /// Low-end devices (older tablets, budget phones)
  low,
  
  /// Mid-range devices (mainstream tablets, mid-range phones)
  medium,
  
  /// High-end devices (flagship tablets, phones, desktops)
  high,
}
