import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show EdgeInsets;

/// PlatformUtil
/// Utility class for platform-specific checks and functionality
class PlatformUtil {
  /// Check if the app is running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if the app is running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if the app is running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if the app is running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if the app is running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if the app is running on Fuchsia
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  /// Check if the app is running on the web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on a mobile platform (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Check if the app is running on a desktop platform (Windows, macOS, or Linux)
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  // Feature-specific checks

  /// Check if the platform supports a file explorer
  static bool get supportsFileExplorer => isDesktop;

  /// Check if the platform requires runtime permissions
  static bool get requiresRuntimePermissions => isMobile;

  /// Check if the platform supports hover effects
  static bool get supportsHover => isDesktop;

  /// Check if the platform supports a physical keyboard
  static bool get hasPhysicalKeyboard => isDesktop;

  /// Check if the platform is touch-primary
  static bool get isTouchPrimary => isMobile;

  /// Get the appropriate minimum touch target size based on platform
  static double get minTouchTargetSize => isMobile ? 48.0 : 32.0;

  /// Get the appropriate list item height based on platform
  static double get listItemHeight => isMobile ? 72.0 : 56.0;

  /// Get the appropriate padding for touch targets based on platform
  static EdgeInsets get touchPadding => isMobile
      ? const EdgeInsets.all(12.0)
      : const EdgeInsets.all(8.0);
}
