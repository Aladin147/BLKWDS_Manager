import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

/// Initialize the database factory for tests
class TestDatabaseHelper {
  /// Initialize the database factory for tests
  static void initializeDatabase() {
    // Initialize FFI
    sqfliteFfiInit();
    
    // Set the database factory to use FFI
    databaseFactory = databaseFactoryFfi;
  }
}
