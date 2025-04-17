import 'package:sqflite/sqflite.dart';
import '../log_service.dart';
import 'migration.dart';
import 'migrations/migrations.dart';

/// MigrationManager
/// Manages database migrations
class MigrationManager {
  /// List of all available migrations
  static final List<Migration> _migrations = [
    // Import all migrations from migrations/migrations.dart
    ...allMigrations,
  ];

  /// Execute migrations from oldVersion to newVersion
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    LogService.info('Migrating database from version $oldVersion to $newVersion');

    // Sort migrations by fromVersion to ensure they're executed in order
    _migrations.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));

    // Filter migrations that need to be executed
    final migrationsToExecute = _migrations.where(
      (migration) => migration.fromVersion >= oldVersion && migration.toVersion <= newVersion
    ).toList();

    if (migrationsToExecute.isEmpty) {
      LogService.info('No migrations to execute');
      return;
    }

    LogService.info('Found ${migrationsToExecute.length} migrations to execute');

    // Execute each migration in order
    for (final migration in migrationsToExecute) {
      LogService.info('Executing migration ${migration.fromVersion} to ${migration.toVersion}: ${migration.description}');
      
      try {
        final success = await migration.execute(db);
        if (success) {
          LogService.info('Migration ${migration.fromVersion} to ${migration.toVersion} completed successfully');
        } else {
          LogService.error('Migration ${migration.fromVersion} to ${migration.toVersion} failed');
          throw Exception('Migration ${migration.fromVersion} to ${migration.toVersion} failed');
        }
      } catch (e, stackTrace) {
        LogService.error('Error executing migration ${migration.fromVersion} to ${migration.toVersion}', e, stackTrace);
        rethrow;
      }
    }

    LogService.info('All migrations completed successfully');
  }

  /// Get the latest migration version
  static int getLatestVersion() {
    if (_migrations.isEmpty) return 1;
    return _migrations.map((m) => m.toVersion).reduce((a, b) => a > b ? a : b);
  }
}
