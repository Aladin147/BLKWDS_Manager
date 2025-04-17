# Database Migration System

## Overview

The database migration system provides a structured approach to managing database schema changes. It ensures that migrations are the single source of truth for schema evolution and provides a reliable way to upgrade the database from any version to the latest version.

## Key Components

### Migration Interface

The `Migration` interface defines the contract that all migrations must implement:

```dart
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
```

### MigrationManager

The `MigrationManager` class manages the execution of migrations:

```dart
class MigrationManager {
  /// List of all available migrations
  static final List<Migration> _migrations = [...allMigrations];

  /// Execute migrations from oldVersion to newVersion
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    // Implementation details...
  }

  /// Get the latest migration version
  static int getLatestVersion() {
    // Implementation details...
  }
}
```

### Individual Migrations

Each migration is implemented as a separate class that implements the `Migration` interface. For example:

```dart
class MigrationV1ToV2 implements Migration {
  @override
  int get fromVersion => 1;

  @override
  int get toVersion => 2;

  @override
  String get description => 'Adds description, serialNumber, and purchaseDate columns to gear table';

  @override
  Future<bool> execute(Database db) async {
    // Implementation details...
  }
}
```

## Migration Process

1. **Database Initialization**: When the app starts, the database is initialized with the latest migration version.
2. **Version Check**: The current database version is compared with the latest migration version.
3. **Migration Execution**: If the current version is less than the latest version, the necessary migrations are executed in order.
4. **Version Tracking**: After successful migration, the new version is stored in the settings table.

## Adding a New Migration

To add a new migration:

1. Create a new class that implements the `Migration` interface.
2. Set the `fromVersion` to the current latest version.
3. Set the `toVersion` to the new version.
4. Implement the `execute` method to perform the necessary schema changes.
5. Add the new migration to the `allMigrations` list in `migrations.dart`.

## Best Practices

- **Atomic Migrations**: Use transactions to ensure migrations are atomic.
- **Validation**: Verify that migrations have been applied correctly.
- **Error Handling**: Provide comprehensive error handling and logging.
- **Idempotence**: Ensure migrations can be applied multiple times without side effects.
- **Documentation**: Document the purpose and changes of each migration.

## Example Usage

```dart
// In DBService._upgradeDatabase
static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
  try {
    // Use the MigrationManager to execute all necessary migrations
    await MigrationManager.migrate(db, oldVersion, newVersion);
    
    // Store the current database version in the settings table
    await _storeDbVersion(db, newVersion);
    
    LogService.info('Database upgrade completed successfully');
  } catch (e, stackTrace) {
    LogService.error('Error upgrading database', e, stackTrace);
    rethrow;
  }
}
```
