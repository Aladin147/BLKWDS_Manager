# Database Migration System

## Overview

The BLKWDS Manager application uses SQLite for local data storage. As the application evolves, the database schema needs to change to accommodate new features and improvements. The database migration system provides a structured way to manage these changes.

## Migration Architecture

The migration system follows these principles:

1. **Version-based**: Each database schema has a version number.
2. **Sequential**: Migrations are applied in order, from the current version to the target version.
3. **Atomic**: Each migration is wrapped in a transaction to ensure consistency.
4. **Verifiable**: Migrations include verification steps to ensure they were applied correctly.
5. **Isolated**: Each migration is implemented in its own method for clarity and maintainability.

## Migration Process

When the application starts, the database system:

1. Checks the current database version
2. Compares it with the target version defined in the code
3. If they differ, applies all migrations sequentially
4. Verifies each migration was successful

## Migration History

### Version 1 (Initial Schema)

The initial database schema includes the following tables:

- `gear`: Equipment items
- `member`: Team members
- `project`: Production projects
- `project_member`: Many-to-many relationship between projects and members
- `booking`: Scheduled bookings
- `booking_gear`: Many-to-many relationship between bookings and gear
- `status_note`: Notes about gear status
- `activity_log`: Records of gear check-in/check-out activities

### Version 2

Added the following columns to the `gear` table:

- `description`: Detailed description of the gear
- `serialNumber`: Serial number for identification
- `purchaseDate`: Date when the gear was purchased

### Version 3 (Current)

Added the following:

- New `settings` table for application configuration
  - `id`: Primary key
  - `key`: Setting name (unique)
  - `value`: Setting value
- New `color` column to the `booking` table for visual identification

## Adding New Migrations

To add a new migration:

1. Increment the database version in `DBService._initDB()`
2. Add a new migration method (e.g., `_migrateV3ToV4()`)
3. Add the migration call in `_upgradeDatabase()`
4. Update this documentation

## Testing Migrations

Migrations should be tested with:

1. Fresh installs (creating a new database)
2. Upgrades from each previous version
3. Edge cases (e.g., empty tables, maximum values)

## Best Practices

1. Always use transactions for atomicity
2. Verify migrations were applied correctly
3. Handle errors gracefully
4. Document all schema changes
5. Test thoroughly before releasing
