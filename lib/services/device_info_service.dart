import 'package:device_info_plus/device_info_plus.dart';
import '../utils/platform_util.dart';
import 'log_service.dart';

/// DeviceInfoService
/// Service for getting information about the device
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  /// Get the device name
  static Future<String> getDeviceName() async {
    try {
      if (PlatformUtil.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (PlatformUtil.isWindows) {
        final WindowsDeviceInfo windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return windowsInfo.computerName;
      } else {
        return 'Unknown Device';
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to get device name', e, stackTrace);
      return 'Unknown Device';
    }
  }
  
  /// Get the operating system name and version
  static Future<String> getOSInfo() async {
    try {
      if (PlatformUtil.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (PlatformUtil.isWindows) {
        final WindowsDeviceInfo windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}.${windowsInfo.buildNumber}';
      } else {
        return 'Unknown OS';
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to get OS info', e, stackTrace);
      return 'Unknown OS';
    }
  }
  
  /// Get detailed device information
  static Future<Map<String, dynamic>> getDetailedDeviceInfo() async {
    try {
      if (PlatformUtil.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'device': androidInfo.device,
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'supportedABIs': androidInfo.supportedAbis,
          'systemFeatures': androidInfo.systemFeatures,
        };
      } else if (PlatformUtil.isWindows) {
        final WindowsDeviceInfo windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return {
          'computerName': windowsInfo.computerName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
          'platformId': windowsInfo.platformId,
          'productType': windowsInfo.productType,
          'productName': windowsInfo.productName,
          'displayVersion': windowsInfo.displayVersion,
        };
      } else {
        return {'error': 'Unsupported platform'};
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to get detailed device info', e, stackTrace);
      return {'error': e.toString()};
    }
  }
  
  /// Check if the device meets the minimum requirements
  static Future<bool> meetsMinimumRequirements() async {
    try {
      if (PlatformUtil.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        // Check if the device is running Android 6.0 (Marshmallow) or higher
        return androidInfo.version.sdkInt >= 23;
      } else {
        // For other platforms, assume they meet the requirements
        return true;
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to check minimum requirements', e, stackTrace);
      return false;
    }
  }
}
