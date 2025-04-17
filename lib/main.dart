import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/services.dart';
import 'services/database/database_integrity_service.dart';

/// Main entry point for the BLKWDS Manager app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  LogService.setLogLevel(LogLevel.debug);
  LogService.info('Starting BLKWDS Manager');

  // Initialize sqflite_ffi for Windows support
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  LogService.info('SQLite initialized');

  // Initialize the database
  await DBService.database;
  LogService.info('Database initialized');

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
  if (appConfig.database.enableIntegrityChecks) {
    await DatabaseIntegrityService().start(
      checkIntervalHours: appConfig.database.integrityCheckIntervalHours,
      runImmediately: false,
    );
    LogService.info('Database integrity service initialized');
  } else {
    LogService.info('Database integrity checks are disabled in application configuration');
  }

  // Run the app
  runApp(const BLKWDSApp());
}
