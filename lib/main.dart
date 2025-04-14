import 'package:flutter/material.dart';
import 'app.dart';
import 'services/db_service.dart';

/// Main entry point for the BLKWDS Manager app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DBService.database;

  // Run the app
  runApp(const BLKWDSApp());
}
