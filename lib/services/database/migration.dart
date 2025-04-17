import 'package:sqflite/sqflite.dart';

/// Migration interface
/// All database migrations should implement this interface
abstract class Migration {
  /// The version this migration upgrades from
  int get fromVersion;
  
  /// The version this migration upgrades to
  int get toVersion;
  
  /// Description of the migration
  String get description;
  
  /// Execute the migration
  /// Returns true if the migration was successful
  Future<bool> execute(Database db);
}
