# BLKWDS Manager - Android Technical Implementation Guide

This document provides technical details for implementing the Android adaptation of BLKWDS Manager.

## Platform Detection Implementation

### Platform Detection Utility

```dart
// lib/utils/platform_util.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtil {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isIOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  
  // For feature-specific checks
  static bool get supportsFileExplorer => isDesktop;
  static bool get requiresRuntimePermissions => isMobile;
  static bool get supportsHover => isDesktop;
}
```

### Usage Example

```dart
if (PlatformUtil.isAndroid) {
  // Android-specific implementation
} else if (PlatformUtil.isWindows) {
  // Windows-specific implementation
} else {
  // Default implementation
}
```

## File Storage Path Adaptation

### Path Provider Implementation

```dart
// lib/services/path_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../utils/platform_util.dart';

class PathService {
  static Future<String> getAppDocumentsPath() async {
    if (PlatformUtil.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else if (PlatformUtil.isWindows) {
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'BLKWDS_Manager');
    } else {
      // Default fallback
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }
  
  static Future<String> getImagesPath() async {
    final basePath = await getAppDocumentsPath();
    return path.join(basePath, 'images');
  }
  
  static Future<String> getDatabasePath() async {
    if (PlatformUtil.isAndroid) {
      final directory = await getDatabasesPath();
      return path.join(directory, 'blkwds_manager.db');
    } else {
      final basePath = await getAppDocumentsPath();
      return path.join(basePath, 'blkwds_manager.db');
    }
  }
  
  // Ensure all required directories exist
  static Future<void> ensureDirectoriesExist() async {
    final basePath = await getAppDocumentsPath();
    final imagesPath = await getImagesPath();
    
    await Directory(basePath).create(recursive: true);
    await Directory(imagesPath).create(recursive: true);
  }
}
```

## Android Permissions

### Required Permissions

Add these to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Storage permissions for database and images -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- For API level 33+ (Android 13+), use more granular permissions -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <!-- Internet permission if needed -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Camera permission for taking gear photos -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- ... rest of manifest ... -->
</manifest>
```

### Runtime Permission Handler

```dart
// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_util.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return true; // No runtime permissions needed on desktop
    }
    
    // Request permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    return status.isGranted;
  }
  
  static Future<bool> requestCameraPermission() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return true; // No runtime permissions needed on desktop
    }
    
    // Request permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    
    return status.isGranted;
  }
  
  // Check and request all required permissions
  static Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    if (!PlatformUtil.requiresRuntimePermissions) {
      return {}; // No runtime permissions needed on desktop
    }
    
    return await [
      Permission.storage,
      Permission.camera,
    ].request();
  }
}
```

## Touch Layout Optimization

### Touch-Friendly Constants

```dart
// lib/theme/blkwds_constants.dart

// Add platform-specific constants
static double get minTouchTargetSize => PlatformUtil.isMobile ? 48.0 : 32.0;
static double get listItemHeight => PlatformUtil.isMobile ? 72.0 : 56.0;
static EdgeInsets get touchPadding => PlatformUtil.isMobile 
    ? const EdgeInsets.all(12.0)
    : const EdgeInsets.all(8.0);
```

### Touch-Friendly Button Implementation

```dart
// lib/widgets/blkwds_button.dart

// Update button to be touch-friendly on mobile
Widget build(BuildContext context) {
  // Adjust size based on platform
  final double height = PlatformUtil.isMobile 
      ? (isSmall ? 40.0 : 56.0)
      : (isSmall ? 32.0 : 40.0);
      
  final double horizontalPadding = PlatformUtil.isMobile
      ? (isSmall ? 16.0 : 24.0)
      : (isSmall ? 12.0 : 16.0);
      
  // Rest of implementation...
}
```

## SQLite Implementation for Android

### Database Configuration

```dart
// lib/services/db_service.dart

static Future<Database> _initDatabase() async {
  final dbPath = await PathService.getDatabasePath();
  
  // Ensure the directory exists
  await Directory(path.dirname(dbPath)).create(recursive: true);
  
  if (PlatformUtil.isWindows) {
    // Windows-specific initialization
    return await openDatabase(
      dbPath,
      version: _latestVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  } else {
    // Android and other platforms
    return await openDatabase(
      dbPath,
      version: _latestVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }
}
```

## Building for 32-bit ARM

### Gradle Configuration

Update `android/app/build.gradle`:

```gradle
android {
    // ...
    
    defaultConfig {
        // ...
        minSdkVersion 23 // Android 6.0 (Marshmallow)
        targetSdkVersion 33
        // ...
        
        ndk {
            // Specify the ABI you want to build for
            abiFilters 'armeabi-v7a' // 32-bit ARM
        }
    }
    
    // ...
    
    buildTypes {
        release {
            // ...
            minifyEnabled true
            shrinkResources true
            // ...
        }
    }
}
```

### Build Command

To build a release APK for 32-bit ARM:

```bash
flutter build apk --release --target-platform=android-arm
```

## Android Lifecycle Management

### App Lifecycle Handling

```dart
// lib/app.dart

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and running
        LogService.info('App resumed');
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        LogService.info('App inactive');
        break;
      case AppLifecycleState.paused:
        // App is in background
        LogService.info('App paused');
        // Close database connections or save state
        break;
      case AppLifecycleState.detached:
        // App is detached
        LogService.info('App detached');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // App build method...
  }
}
```

## Testing on Android

### Test Checklist

1. **Installation Test**
   - App installs correctly
   - First-time setup works properly
   - App icon appears correctly

2. **Functionality Test**
   - All core features work as expected
   - Database operations succeed
   - Image capture and display works
   - File operations succeed

3. **UI/UX Test**
   - All screens render correctly
   - Touch interactions work properly
   - Text is readable on tablet screens
   - Layouts adapt to orientation changes

4. **Performance Test**
   - App launches in reasonable time
   - Screens transition smoothly
   - No UI freezes during operations
   - Memory usage remains stable

5. **Error Handling Test**
   - Permission denials handled gracefully
   - Network errors handled properly
   - Database errors recovered properly
   - Proper error messages displayed
