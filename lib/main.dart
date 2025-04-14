import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/db_service.dart';
import 'services/data_seeder.dart';

/// Main entry point for the BLKWDS Manager app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_ffi for Windows support
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize the database
  await DBService.database;

  // Seed the database with sample data
  await DataSeeder.seedDatabase();

  // Run the app
  runApp(const BLKWDSApp());
}
