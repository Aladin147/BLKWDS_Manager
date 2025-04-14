import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/db_service.dart';
import 'services/data_seeder.dart';
import 'services/log_service.dart';
import 'services/log_level.dart';

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

  // Run the app
  runApp(const BLKWDSApp());
}
