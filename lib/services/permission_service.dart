import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_util.dart';
import 'log_service.dart';

/// PermissionService
/// Service for handling platform-specific permissions
class PermissionService {
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return true; // No runtime permissions needed on desktop
    }
    
    try {
      // Request permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        LogService.info('Requesting storage permission');
        status = await Permission.storage.request();
      }
      
      if (status.isGranted) {
        LogService.info('Storage permission granted');
      } else {
        LogService.warning('Storage permission denied');
      }
      
      return status.isGranted;
    } catch (e, stackTrace) {
      LogService.error('Error requesting storage permission', e, stackTrace);
      return false;
    }
  }
  
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return true; // No runtime permissions needed on desktop
    }
    
    try {
      // Request permission
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        LogService.info('Requesting camera permission');
        status = await Permission.camera.request();
      }
      
      if (status.isGranted) {
        LogService.info('Camera permission granted');
      } else {
        LogService.warning('Camera permission denied');
      }
      
      return status.isGranted;
    } catch (e, stackTrace) {
      LogService.error('Error requesting camera permission', e, stackTrace);
      return false;
    }
  }
  
  /// Check and request all required permissions
  static Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return {}; // No runtime permissions needed on desktop
    }
    
    try {
      LogService.info('Requesting all required permissions');
      final permissions = await [
        Permission.storage,
        Permission.camera,
      ].request();
      
      // Log results
      permissions.forEach((permission, status) {
        if (status.isGranted) {
          LogService.info('Permission $permission granted');
        } else {
          LogService.warning('Permission $permission denied');
        }
      });
      
      return permissions;
    } catch (e, stackTrace) {
      LogService.error('Error requesting permissions', e, stackTrace);
      return {};
    }
  }
  
  /// Check if all required permissions are granted
  static Future<bool> checkAllRequiredPermissions() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return true; // No runtime permissions needed on desktop
    }
    
    try {
      final storageStatus = await Permission.storage.status;
      final cameraStatus = await Permission.camera.status;
      
      return storageStatus.isGranted && cameraStatus.isGranted;
    } catch (e, stackTrace) {
      LogService.error('Error checking permissions', e, stackTrace);
      return false;
    }
  }
}
