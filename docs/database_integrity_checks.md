# Database Integrity Checks

## Overview

The database integrity check system provides a comprehensive approach to ensuring data integrity in the application. It includes checks for foreign key constraints, orphaned records, and data consistency issues, as well as mechanisms to fix these issues.

## Key Components

### 1. Database Integrity Checker

The `DatabaseIntegrityChecker` class provides methods for checking and fixing database integrity issues:

- **checkIntegrity**: Performs a comprehensive check of database integrity
- **checkForeignKeyConstraints**: Checks if all foreign key constraints are satisfied
- **checkOrphanedRecords**: Checks for orphaned records in the database
- **checkDataConsistency**: Checks for data consistency issues in the database
- **fixIntegrityIssues**: Fixes integrity issues found by checkIntegrity

### 2. Database Integrity Service

The `DatabaseIntegrityService` class provides a service for running database integrity checks periodically:

- **start**: Starts the integrity check service with the specified interval
- **stop**: Stops the integrity check service
- **runManualCheck**: Runs a manual integrity check

### 3. Database Integrity Screen

The `DatabaseIntegrityScreen` provides a user interface for managing database integrity checks:

- Configure integrity check settings
- Run manual integrity checks
- View integrity check results
- Fix integrity issues

## Types of Checks

### 1. Foreign Key Constraints

Checks if all foreign key constraints are satisfied. This includes:

- Project-member relationships
- Booking-project relationships
- Booking-studio relationships
- Booking-gear relationships
- Status note-gear relationships
- Activity log-gear relationships

### 2. Orphaned Records

Checks for orphaned records in the database. This includes:

- Bookings without associated projects
- Booking-gear entries without associated bookings or gear
- Project-member entries without associated projects or members
- Status notes without associated gear
- Activity logs without associated gear

### 3. Data Consistency

Checks for data consistency issues in the database. This includes:

- Bookings with end date before start date
- Bookings with invalid studio type
- Gear with isOut=1 but no activity log entry
- Gear with isOut=0 but last activity log entry is checkout
- Overlapping bookings for the same studio

## Configuration

The database integrity check system can be configured through the app configuration:

- **enableIntegrityChecks**: Whether to enable database integrity checks
- **integrityCheckIntervalHours**: Interval between integrity checks in hours
- **databaseIntegrityAutoFix**: Whether to automatically fix integrity issues

## Usage

### Periodic Checks

The system can be configured to run integrity checks periodically. The interval between checks can be configured in the app configuration.

### Manual Checks

Manual integrity checks can be run from the Database Integrity screen. The user can choose to run a check only or run a check and fix any issues found.

### Automatic Fixes

The system can be configured to automatically fix integrity issues when found. This can be enabled in the app configuration or when running a manual check.

## Benefits

1. **Data Integrity**: Ensures data integrity by checking for and fixing integrity issues
2. **Orphaned Records**: Identifies and removes orphaned records that could cause issues
3. **Data Consistency**: Ensures data consistency across related tables
4. **Automatic Fixes**: Provides mechanisms to automatically fix integrity issues
5. **User Interface**: Provides a user interface for managing integrity checks

## Best Practices

1. **Regular Checks**: Run integrity checks regularly to ensure data integrity
2. **Manual Checks**: Run manual checks before important operations
3. **Fix Issues**: Fix integrity issues as soon as they are found
4. **Backup Data**: Always backup data before fixing integrity issues
5. **Monitor Results**: Monitor integrity check results to identify patterns
