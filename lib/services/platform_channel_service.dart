import 'package:flutter/services.dart';
import 'log_service.dart';

/// PlatformChannelService
/// Service for communicating with platform-specific code
class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('com.blkwds.manager/platform');
  
  /// Get the Android version
  static Future<String?> getAndroidVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getAndroidVersion');
      return version;
    } on PlatformException catch (e, stackTrace) {
      LogService.error('Failed to get Android version', e, stackTrace);
      return null;
    }
  }
  
  /// Get the device model
  static Future<String?> getDeviceModel() async {
    try {
      final String? model = await _channel.invokeMethod('getDeviceModel');
      return model;
    } on PlatformException catch (e, stackTrace) {
      LogService.error('Failed to get device model', e, stackTrace);
      return null;
    }
  }
  
  /// Check if the device is running Android 6.0 (Marshmallow) or higher
  static Future<bool> isMarshmallowOrHigher() async {
    try {
      final String? version = await getAndroidVersion();
      if (version == null) return false;
      
      // Parse the version string
      final List<String> versionParts = version.split('.');
      if (versionParts.isEmpty) return false;
      
      final int majorVersion = int.tryParse(versionParts[0]) ?? 0;
      return majorVersion >= 6;
    } catch (e, stackTrace) {
      LogService.error('Failed to check Android version', e, stackTrace);
      return false;
    }
  }
}
