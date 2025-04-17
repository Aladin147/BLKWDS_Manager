import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/services.dart';

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

  // Only seed the database on first run if enabled in config and database is empty
  final dataSeederConfig = await DataSeeder.getConfig();
  if (dataSeederConfig.seedOnFirstRun) {
    // Check if database is empty before seeding
    final isEmpty = await DataSeeder.isDatabaseEmpty();
    if (isEmpty) {
      LogService.info('Database is empty, seeding with initial data');
      await DataSeeder.seedDatabase(dataSeederConfig);
      LogService.info('Data seeding completed');
    } else {
      LogService.info('Database already contains data, skipping seeding');
    }
  } else {
    LogService.info('Data seeding on first run is disabled in configuration');
  }

  // Initialize error analytics service
  await ErrorAnalyticsService.initialize();
  LogService.info('Error analytics service initialized');

  // Run the app
  runApp(const BLKWDSApp());
}
