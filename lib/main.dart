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

  // Seed the database with sample data
  await DataSeeder.seedDatabase();
  LogService.info('Data seeding completed');

  // Initialize error analytics service
  await ErrorAnalyticsService.initialize();
  LogService.info('Error analytics service initialized');

  // Run the app
  runApp(const BLKWDSApp());
}
