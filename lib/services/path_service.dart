import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../utils/platform_util.dart';
import 'log_service.dart';

/// PathService
/// Service for handling platform-specific file paths
class PathService {
  /// Get the application documents directory path
  static Future<String> getAppDocumentsPath() async {
    try {
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
    } catch (e, stackTrace) {
      LogService.error('Error getting app documents path', e, stackTrace);
      // Fallback to a temporary directory
      final tempDir = await getTemporaryDirectory();
      return path.join(tempDir.path, 'BLKWDS_Manager');
    }
  }

  /// Get the path for storing images
  static Future<String> getImagesPath() async {
    final basePath = await getAppDocumentsPath();
    return path.join(basePath, 'images');
  }

  /// Get the path for the database file
  static Future<String> getDatabasePath() async {
    try {
      if (PlatformUtil.isAndroid) {
        final directory = await getDatabasesPath();
        return path.join(directory, 'blkwds_manager.db');
      } else {
        final basePath = await getAppDocumentsPath();
        return path.join(basePath, 'blkwds_manager.db');
      }
    } catch (e, stackTrace) {
      LogService.error('Error getting database path', e, stackTrace);
      // Fallback to app documents path
      final basePath = await getAppDocumentsPath();
      return path.join(basePath, 'blkwds_manager.db');
    }
  }

  /// Get the path for storing logs
  static Future<String> getLogsPath() async {
    final basePath = await getAppDocumentsPath();
    return path.join(basePath, 'logs');
  }

  /// Get the path for storing exports
  static Future<String> getExportsPath() async {
    final basePath = await getAppDocumentsPath();
    return path.join(basePath, 'exports');
  }

  /// Ensure all required directories exist
  static Future<void> ensureDirectoriesExist() async {
    try {
      final basePath = await getAppDocumentsPath();
      final imagesPath = await getImagesPath();
      final logsPath = await getLogsPath();
      final exportsPath = await getExportsPath();

      await Directory(basePath).create(recursive: true);
      await Directory(imagesPath).create(recursive: true);
      await Directory(logsPath).create(recursive: true);
      await Directory(exportsPath).create(recursive: true);

      LogService.info('All required directories created');
    } catch (e, stackTrace) {
      LogService.error('Error creating directories', e, stackTrace);
    }
  }
}
