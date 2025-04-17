import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'preferences_service.dart';
import 'log_service.dart';
import 'version_service.dart';

/// AppConfigService
/// Service for managing application configuration
class AppConfigService {
  static const String _configKey = 'app_config';
  static final ValueNotifier<AppConfig> _config = ValueNotifier<AppConfig>(AppConfig.defaults);

  /// Get the current configuration
  static AppConfig get config => _config.value;

  /// Get the current configuration asynchronously
  /// This is useful when you need to ensure the config is loaded
  static Future<AppConfig> getConfig() async {
    // If config is not loaded yet, load it
    if (_config.value == AppConfig.defaults) {
      await loadConfig();
    }
    return _config.value;
  }

  /// Get the configuration as a ValueNotifier
  static ValueNotifier<AppConfig> get configNotifier => _config;

  /// Initialize the service
  static Future<void> initialize() async {
    try {
      // Initialize version service first
      await VersionService.initialize();

      // Load config
      await loadConfig();

      // Update app info with dynamic values
      await updateAppInfoFromVersionService();

      LogService.info('AppConfigService initialized');
    } catch (e, stackTrace) {
      LogService.error('Error initializing AppConfigService', e, stackTrace);
      // Use defaults if loading fails
      _config.value = AppConfig.defaults;
    }
  }

  /// Update app info from version service
  static Future<void> updateAppInfoFromVersionService() async {
    try {
      final appInfo = AppInfo.fromVersionService();
      await updateAppInfo(appInfo);
      LogService.info('App info updated from version service: ${appInfo.appVersion}+${appInfo.appBuildNumber}');
    } catch (e, stackTrace) {
      LogService.error('Error updating app info from version service', e, stackTrace);
    }
  }

  /// Load configuration from preferences
  static Future<void> loadConfig() async {
    try {
      final jsonString = await PreferencesService.getString(_configKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        _config.value = AppConfig.fromMap(map);
        LogService.info('AppConfig loaded from preferences');
      } else {
        // Use defaults if no saved config
        _config.value = AppConfig.defaults;
        LogService.info('No saved AppConfig found, using defaults');
      }
    } catch (e, stackTrace) {
      LogService.error('Error loading AppConfig', e, stackTrace);
      rethrow;
    }
  }

  /// Save configuration to preferences
  static Future<void> saveConfig(AppConfig config) async {
    try {
      final jsonString = jsonEncode(config.toMap());
      await PreferencesService.setString(_configKey, jsonString);
      _config.value = config;
      LogService.info('AppConfig saved to preferences');
    } catch (e, stackTrace) {
      LogService.error('Error saving AppConfig', e, stackTrace);
      rethrow;
    }
  }

  /// Reset configuration to defaults
  static Future<void> resetConfig() async {
    try {
      await saveConfig(AppConfig.defaults);
      LogService.info('AppConfig reset to defaults');
    } catch (e, stackTrace) {
      LogService.error('Error resetting AppConfig', e, stackTrace);
      rethrow;
    }
  }

  /// Update database configuration
  static Future<void> updateDatabaseConfig(DatabaseConfig databaseConfig) async {
    try {
      final updatedConfig = config.copyWith(database: databaseConfig);
      await saveConfig(updatedConfig);
      LogService.info('Database configuration updated');
    } catch (e, stackTrace) {
      LogService.error('Error updating database configuration', e, stackTrace);
      rethrow;
    }
  }

  /// Update studio configuration
  static Future<void> updateStudioConfig(StudioConfig studioConfig) async {
    try {
      final updatedConfig = config.copyWith(studio: studioConfig);
      await saveConfig(updatedConfig);
      LogService.info('Studio configuration updated');
    } catch (e, stackTrace) {
      LogService.error('Error updating studio configuration', e, stackTrace);
      rethrow;
    }
  }

  /// Update UI configuration
  static Future<void> updateUIConfig(UIConfig uiConfig) async {
    try {
      final updatedConfig = config.copyWith(ui: uiConfig);
      await saveConfig(updatedConfig);
      LogService.info('UI configuration updated');
    } catch (e, stackTrace) {
      LogService.error('Error updating UI configuration', e, stackTrace);
      rethrow;
    }
  }

  /// Update app information
  static Future<void> updateAppInfo(AppInfo appInfo) async {
    try {
      final updatedConfig = config.copyWith(appInfo: appInfo);
      await saveConfig(updatedConfig);
      LogService.info('App information updated');
    } catch (e, stackTrace) {
      LogService.error('Error updating app information', e, stackTrace);
      rethrow;
    }
  }

  /// Update data seeder defaults
  static Future<void> updateDataSeederDefaults(DataSeederDefaults dataSeederDefaults) async {
    try {
      final updatedConfig = config.copyWith(dataSeeder: dataSeederDefaults);
      await saveConfig(updatedConfig);
      LogService.info('Data seeder defaults updated');
    } catch (e, stackTrace) {
      LogService.error('Error updating data seeder defaults', e, stackTrace);
      rethrow;
    }
  }

  /// Export configuration as JSON
  static Future<String> exportConfig() async {
    try {
      final jsonString = jsonEncode(config.toMap());
      return jsonString;
    } catch (e, stackTrace) {
      LogService.error('Error exporting AppConfig', e, stackTrace);
      rethrow;
    }
  }

  /// Import configuration from JSON
  static Future<void> importConfig(String jsonString) async {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final importedConfig = AppConfig.fromMap(map);
      await saveConfig(importedConfig);
      LogService.info('AppConfig imported');
    } catch (e, stackTrace) {
      LogService.error('Error importing AppConfig', e, stackTrace);
      rethrow;
    }
  }
}
