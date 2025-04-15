import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'log_service.dart';

import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';
import 'migrations/migration_v3.dart';
import 'migrations/migration_v4.dart';
import 'migrations/migration_v5.dart';

/// Service to handle database migrations
class MigrationService {
  static const int currentVersion = 5;

  /// Run migrations if needed
  static Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
    LogService.info('Running migrations from version $oldVersion to $newVersion');

    if (oldVersion < 1) {
      await MigrationV1.migrate(db);
    }

    if (oldVersion < 2) {
      await MigrationV2.migrate(db);
    }

    if (oldVersion < 3) {
      await MigrationV3.migrate(db);
    }

    if (oldVersion < 4) {
      await MigrationV4.migrate(db);
    }
    
    if (oldVersion < 5) {
      await MigrationV5.migrate(db);
    }

    LogService.info('Migrations completed successfully');
  }
}
