import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/services.dart';
import 'services/database/database_integrity_service.dart';
import 'config/environment_config.dart';
import 'utils/platform_util.dart';
import 'services/path_service.dart';
import 'services/permission_service.dart';
import 'screens/splash_screen.dart';

/// Main entry point for the BLKWDS Manager app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen immediately
  runApp(const SplashScreen(message: 'Initializing...'));

  try {

    // Initialize logging
    LogService.setLogLevel(LogLevel.debug);
    LogService.info('Starting BLKWDS Manager');

    // Log platform information
    LogService.info('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    LogService.info('Is Android: ${Platform.isAndroid}');
    LogService.info('Is Windows: ${Platform.isWindows}');

    // Log the current environment
    LogService.info('Running in ${EnvironmentConfig.environmentName} environment');

    // Update splash screen
    runApp(const SplashScreen(message: 'Checking storage...'));

    // Ensure directories exist
    await PathService.ensureDirectoriesExist();
    LogService.info('Directories created');

    // Request permissions on Android
    if (Platform.isAndroid) {
      // Update splash screen
      runApp(const SplashScreen(message: 'Requesting permissions...'));

      final hasPermissions = await PermissionService.requestAllRequiredPermissions();
      LogService.info('Permissions granted: $hasPermissions');
    }

    // Update splash screen
    runApp(const SplashScreen(message: 'Initializing database...'));

    // Initialize SQLite based on platform
    if (Platform.isWindows) {
      // Initialize sqflite_ffi for Windows support
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      LogService.info('SQLite initialized for Windows');
    } else {
      LogService.info('Using default SQLite implementation for ${Platform.operatingSystem}');
    }

    // Initialize the database with error handling
    try {
      await DBService.database;
      LogService.info('Database initialized successfully');
    } catch (e, stackTrace) {
      LogService.error('Error initializing database', e, stackTrace);
      // Show a user-friendly error message
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Database Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error initializing database: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Restart the app
                      main();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      return; // Exit the initialization process
    }

    // Update splash screen
    runApp(const SplashScreen(message: 'Loading configuration...'));

    // Initialize app configuration first
    await AppConfigService.initialize();
    LogService.info('App configuration initialized');

    // Only seed the database if enabled in app config and database is empty
    final appConfig = AppConfigService.config;
    if (appConfig.dataSeeder.enableDataSeeding) {
      // Check if database is empty before seeding
      final isEmpty = await DataSeeder.isDatabaseEmpty();
      if (isEmpty) {
        LogService.info('Database is empty, checking if seeding is allowed');

        // Get data seeder config
        final dataSeederConfig = await DataSeeder.getConfig();

        // Check if seeding is enabled in the data seeder config
        if (dataSeederConfig.seedOnFirstRun) {
          LogService.info('Seeding database with initial data');
          await DataSeeder.seedDatabase(dataSeederConfig);
          LogService.info('Data seeding completed');
        } else {
          LogService.info('Seeding on first run is disabled in data seeder configuration');
        }
      } else {
        LogService.info('Database already contains data, skipping seeding');
      }
    } else {
      LogService.info('Data seeding is disabled in application configuration');
    }

    // Initialize error analytics service
    await ErrorAnalyticsService.initialize();
    LogService.info('Error analytics service initialized');

    // Initialize database integrity service
    try {
      final config = await AppConfigService.getConfig();
      if (config.database.enableIntegrityChecks) {
        await DatabaseIntegrityService().start(
          checkIntervalHours: config.database.integrityCheckIntervalHours,
          runImmediately: false,
        );
        LogService.info('Database integrity service initialized');
      } else {
        LogService.info('Database integrity checks are disabled in application configuration');
      }
    } catch (e, stackTrace) {
      LogService.error('Error initializing database integrity service', e, stackTrace);
    }

    // Update splash screen with final message
    runApp(const SplashScreen(message: 'Starting application...'));

    // Add a small delay to ensure splash screen is visible
    await Future.delayed(const Duration(milliseconds: 500));

    // Run the app
    runApp(const BLKWDSApp());
  } catch (e, stackTrace) {
    // Log any errors during startup
    LogService.error('Error during application startup', e, stackTrace);
    // Rethrow to show the error in the console
    rethrow;
  }
}
