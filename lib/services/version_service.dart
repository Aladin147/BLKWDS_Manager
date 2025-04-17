import 'package:package_info_plus/package_info_plus.dart';
import 'log_service.dart';

/// VersionService
/// Service for getting app version information
class VersionService {
  static PackageInfo? _packageInfo;
  static bool _initialized = false;

  /// Initialize the service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _initialized = true;
      LogService.info('VersionService initialized: ${_packageInfo?.version}+${_packageInfo?.buildNumber}');
    } catch (e, stackTrace) {
      LogService.error('Error initializing VersionService', e, stackTrace);
      // Set default values if initialization fails
      _packageInfo = PackageInfo(
        appName: 'BLKWDS Manager',
        packageName: 'com.blkwds.manager',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    }
  }

  /// Get the app name
  static String get appName {
    _ensureInitialized();
    return _packageInfo?.appName ?? 'BLKWDS Manager';
  }

  /// Get the package name
  static String get packageName {
    _ensureInitialized();
    return _packageInfo?.packageName ?? 'com.blkwds.manager';
  }

  /// Get the app version
  static String get version {
    _ensureInitialized();
    return _packageInfo?.version ?? '1.0.0';
  }

  /// Get the build number
  static String get buildNumber {
    _ensureInitialized();
    return _packageInfo?.buildNumber ?? '1';
  }

  /// Get the full version string (version+buildNumber)
  static String get fullVersion {
    _ensureInitialized();
    return '${_packageInfo?.version}+${_packageInfo?.buildNumber}';
  }

  /// Get the copyright string
  static String get copyright {
    final year = DateTime.now().year;
    return '© $year BLKWDS Studios';
  }

  /// Ensure the service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      LogService.warning('VersionService not initialized, using default values');
    }
  }
}
